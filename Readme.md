# Git User Switcher

This repository contains a script to switch between multiple Git user configurations and automate the process of committing and pushing changes with the appropriate credentials.

## Features

- Switch Git user configuration quickly.
- Automatically update the remote URL with the correct username and token.
- Seamless integration with multiple Git user setups.

## Prerequisites

- Bash shell
- Git
- Configuration files for each user in `~/.gitconfigs/` : take a look [here](.gitconfigs/) 👀
- Token file containing tokens for each user in `~/.git_utils/.git_tokens` : see format [here](.git_utils/.git_tokens.tpl) 👀

## Installation

1. **Clone the Repository**:

    ```sh
    git clone https://github.com/ekane3/switch-git-users.git
    ```

2. **Make the Script Executable**:

    ```sh
    chmod +x ~/.git_utils/switch_git_user.sh
    ```

3. **Add `git_utils` to Your PATH**:

    Add the following line to your `~/.bashrc` or `~/.zshrc`:

    ```sh
    echo 'export PATH=$PATH:~/.git_utils' >> ~/.bashrc
    source ~/.bashrc
    ```

## Usage

1. **Prepare Configuration Files**:

    - Create configuration files for each user in the `~/.gitconfigs/` directory. The file name should match the user prefix you will use.
    - Each configuration file should contain the user's `name` and `email`.

    Example configuration file (`~/.gitconfigs/user1.config`):

    ```ini
    [user]
        name = user1
        email = user1@data-engineer.com
    [credential]
        helper = cache
    ```

2. **Prepare the Token File**:

    - Create a token file at `~/.git_utils/.git_tokens` containing the tokens for each user.

    Example token file (`~/.git_utils/.git_tokens`):

    ```sh
    user1_token=ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXX
    user2_token=ghp_YYYYYYYYYYYYYYYYYYYYYYYYYYYY
    ```

3. **Switch User and Push Changes**:

    Navigate to your repository and run the script:

    ```sh
    cd /path/to/your/repo
    switch_git_user.sh <user.prefix>
    ```

    Then push your changes:

    ```sh
    git add .
    git commit -m "Your commit message"
    git push origin <branch-name>
    ```

## Example

To switch to the user with the prefix `perso` and push changes:

```sh
cd /path/to/your/repo
switch_git_user.sh perso
git add .
git commit -m "Your commit message"
git push origin master
