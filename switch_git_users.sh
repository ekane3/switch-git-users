#!bin/bash
#
# Git User Switcher : This script helps switch git user for authentication 
# with token in an environment where ssh keys arent allowed
# 
# Usage: ./switch_git_user.sh user1


# Directory containing the git config files
REPERTOIRE_CONFIG=~/.gitconfigs

# File containing the tokens
FICHIER_TOKEN=~/.git_utils/.git_tokens

# Verify the presence of the argument username
if [ -z "$1" ]; then
    echo "Usage: $0 <user.name>"
    exit 1
fi

USER_NAME=$1
FICHIER_CONFIG=$(ls $REPERTOIRE_CONFIG | grep "^$USER_NAME")
echo $FICHIER_CONFIG

if [ -z "$FICHIER_CONFIG" ]; then
    echo "Configuration file not found '$USER_NAME'"
    exit 1
elif [ $(echo $FICHIER_CONFIG | wc -w) -gt 1 ]; then
    echo "More than one configuration file found for this user '$USER_NAME'"
    exit 1
else
    git config --global --unset-all user.name
    git config --global --unset-all user.email
    git config --global --unset-all credential.helper
    git config --global include.path "$REPERTOIRE_CONFIG/$FICHIER_CONFIG"

    # Extract username from config file for token lookup
    USER_NAME=$(git config user.name | awk '{print tolower($0)}' | tr ' ' '_')
    USER_TOKEN="${USER_NAME}_token"

    # Load token from the token file
    if [ -f "$FICHIER_TOKEN" ]; then
        source "$FICHIER_TOKEN"
        TOKEN=${!USER_TOKEN} # !USER_TOKEN points to the value of user_token
       
        if [ -z "$TOKEN" ]; then
            echo "No token for this user '$USER_NAME'"
            exit 1
        else

        # Get the existing remote url and and extract the repo name
        REMOTE_URL=$(git remote get-url origin)

            # Check if credentials are already included
            if [ "$REMOTE_URL" == *"${USER_NAME}:${TOKEN}"* ]; then
                echo "Credentials are already included in the remote URL"
            else
                # Construct the new remote url with the token
                NEW_URL=$(echo $REMOTE_URL | sed -e "s|https://.*@|https://${USER_NAME}:${TOKEN}@|")
                
                # Set the new URL
                git remote set-url origin "$NEW_URL"
                echo "Switched to $(git config user.name) <$(git config user.email)> and updated remote URL"
            fi
        fi
    else
       echo "Token file not found"
       exit 1
    fi

fi