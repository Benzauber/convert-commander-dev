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

    # Encrypt the API token using OpenSSL with PBKDF2 and store it in a variable
    encrypted_token=$(echo -n "$token" | openssl enc -aes-256-cbc -pbkdf2 -salt -k "$encryption_key" | base64)
    
    echo "Encrypted API Token:"
    echo "$encrypted_token"
    
    # Optionally, you can store the encrypted token in a file (this is optional)
    echo "$encrypted_token" > api_token.enc
    echo "Encrypted API Token saved to api_token.enc (optional)"
else
    echo "Failed to generate API token. Server response:"
    echo "$response"
fi
