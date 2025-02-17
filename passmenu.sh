#!/usr/bin/env zsh

setopt nullglob  # Remove globstar since it's not available

typeit=0
if [[ $1 == "--type" ]]; then
    typeit=1
    shift
fi

prefix=${PASSWORD_STORE_DIR:-~/.password-store}
# Use find to get all .gpg files recursively and read them into an array
password_files=()
while IFS= read -r line; do
    password_files+=("$line")
done < <(find "$prefix" -name '*.gpg')

# Remove the prefix and .gpg extension for display
password_names=()
for i in "${(@f)password_files}"; do
    # Remove the prefix
    password_name="${i#$prefix/}"  # Remove prefix
    password_name="${password_name%.gpg}"  # Remove .gpg extension
    password_names+=("$password_name")  # Add to array
done

# Replace spaces with underscores in the password names for display
password_names_display=()
for j in "${(@f)password_names}"; do
    password_names_display+=("${j// /_}")  # Replace spaces with underscores
done

# Use rofi to select a password
password=$(printf '%s\n' "${password_names_display[@]}" | dmenu -l 30 "$@")

[[ -n $password ]] || exit

# Replace underscores back to spaces for the actual password retrieval
original_password_name="${password//_/ }"

# Conditional logic to check for "Otp/" in the original password name
if [[ $original_password_name == Otp/* ]]; then
    # Use pass otp for OTP entries
    if [[ $typeit -eq 0 ]]; then
        pass otp -c "$original_password_name" 2>/dev/null
    else
        xdotool type --clearmodifiers -- "$(pass otp "$original_password_name" | head -n 1)"
    fi
else
    # Use pass show for regular entries
    if [[ $typeit -eq 0 ]]; then
        pass show -c "$original_password_name" 2>/dev/null
    else
        xdotool type --clearmodifiers -- "$(pass show "$original_password_name" | head -n 1)"
    fi
fi

