#!bin/bash
# Ce script permettra de changer les config git d'un utilisateur
# Il accepte un paramètre: le numéro d'utilisateur
# Usage: ./switch_git_user.sh perso


# Repertoire des fichiers config
REPERTOIRE_CONFIG=~/.gitconfigs

# Fichier des tokens Git
FICHIER_TOKEN=~/.git_utils/.git_tokens

# Vérifier la présence de l'argument passé au script
if [ -z "$1" ]; then
    echo "Usage: $0 <user.name>"
    exit 1
fi

USER_NAME=$1
FICHIER_CONFIG=$(ls $REPERTOIRE_CONFIG | grep "^$USER_NAME")
echo $FICHIER_CONFIG

if [ -z "$FICHIER_CONFIG" ]; then
    echo "Fichier de config non trouvé pour '$USER_NAME'"
    exit 1
elif [ $(echo $FICHIER_CONFIG | wc -w) -gt 1 ]; then
    echo "Plusieurs fichiers de conf trouvés pour '$USER_NAME'"
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
        TOKEN=${!USER_TOKEN} # !USER_TOKEN est un pointeur vers la valeur du token du user
       
        if [ -z "$TOKEN" ]; then
            echo "No token for this user '$USER_NAME'"
            exit 1
        else

        # Get the existing remote url and and extract the repo name
        REMOTE_URL=$(git remote get-url origin)
        REPO_NAME=$(echo $REMOTE_URL | sed -e 's|.*:||' -e 's|.*\/||' -e 's|\.git$||')

        # Construct the new remote url with the token      
        NEW_URL=$(echo $REMOTE_URL | sed -e "s|https://|https://${USER_NAME}:${TOKEN}@|")
        git remote set-url origin "$NEW_URL"
        echo "Switched to $(git config user.name) <$(git config user.email)> and updated remote URL"
        fi
    else
       echo "Token file not found"
       exit 1
    fi

fi
