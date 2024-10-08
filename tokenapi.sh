#!/bin/bash

# URL of your Flask application
API_URL="http://localhost:5001"

# Make a POST request to the /generate_token endpoint
response=$(curl -s -X POST "${API_URL}/generate_token")

# Extract the token from the JSON response
token=$(echo $response | grep -o '"token": "[^"]*' | grep -o '[^"]*$')

if [ -n "$token" ]; then
    echo "API Token generated successfully:"
    echo "$token"
    
    # Secret encryption key (Can be any secret phrase)
    encryption_key=$ENCRYPTION_KEY

    # Encrypt the API token using OpenSSL with PBKDF2 (directly using pipe, no temp file needed)
    encrypted_token=$(echo -n "$token" | openssl enc -aes-256-cbc -pbkdf2 -salt -k "$encryption_key")

    # Append the encrypted token to a file (if the file doesn't exist, it will be created)
    echo "$encrypted_token" >> encrypted_tokens_list.txt
    echo "Encrypted API Token appended to encrypted_tokens_list.txt"
else
    echo "Failed to generate API token. Server response:"
    echo "$response"
fi
