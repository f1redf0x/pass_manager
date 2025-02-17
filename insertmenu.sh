#!/usr/bin/env zsh

# Function to generate a random passphrase using xkcdpass
generate_passphrase() {
    local min_words=$1
    local max_words=$2

    # Generate the passphrase using xkcdpass
    local passphrase=$(xkcdpass --count=1 --delimiter='_' --min=$((min_words - 1)) --max=$max_words --valid-chars='[a-z]' --case=random)

    # Append a random number to each word in the passphrase
    local modified_passphrase=""
    for word in ${(s/_/)passphrase}; do
        local random_number=$((RANDOM % 10))  # Generate a random number between 0 and 9
        modified_passphrase+="${word}${random_number}_"
    done

    # Remove the trailing underscore
    modified_passphrase="${modified_passphrase%_}"

    echo "$modified_passphrase"
}

# Prompt for URL
url=$(echo "" | dmenu -i -p "Enter URL:")
[[ -z $url ]] && exit 1

# Prompt for Email
email=$(echo "" | dmenu -i -p "Enter Email:")
[[ -z $email ]] && exit 1

# Prompt for number of words in passphrase
num_words=$(echo "" |  dmenu -i -p "How many words for the passphrase?")
[[ -z $num_words || ! $num_words =~ ^[0-9]+$ ]] && exit 1

# Generate the passphrase
passphrase=$(generate_passphrase "$num_words" "$num_words")

# Confirm passphrase before insertion
confirm=$(echo "" | dmenu -i -p "The passphrase is $passphrase. Continue? (y/n)")

# Insert the data into pass
if [[ "$confirm" == "y" ]]; then
    # Insert the data into pass
	pass insert -m "Rossgregore/"$url <<EOF
$passphrase
login: $email
url: $url
EOF
echo "Password entry created successfully!"
else
    echo "Password entry not created."
fi
