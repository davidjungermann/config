#!/bin/bash

# Define the location of your custom .zshrc
TARGET_ZSHRC=~/repos/config/.zshrc

# Create a symbolic link. If ~/.zshrc exists, this will overwrite it!
ln -sf $TARGET_ZSHRC ~/.zshrc

echo "$TARGET_ZSHRC has been updated and symlinked to ~/.zshrc!"
