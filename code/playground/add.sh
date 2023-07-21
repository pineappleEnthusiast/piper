#!/bin/bash

source_file="pip.sh"

if [ ! -f "$source_file" ]; then
  echo "Source file not found: $source_file"
  exit 1
fi

zshrc_file="$HOME/.zshrc"

cat "$source_file" >> "$zshrc_file"

echo "Contents of $source_file successfully copied to $zshrc_file."
