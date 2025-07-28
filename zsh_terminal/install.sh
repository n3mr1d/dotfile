#!/usr/bin/env bash
set -e

echo "📁 Backup your zshrc file to folder ~/backup"

if [ ! -d "$HOME/backup" ]; then
    echo "📂 Folder ~/backup belum ada. Membuat..."
    mkdir -p "$HOME/backup"
else
    echo "✅ Folder ~/backup "
fi

# Backup file .zshrc
cp "$HOME/.zshrc" "$HOME/backup/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
echo "✅ File .zshrc passed backup to ~/backup"
cat ./.zshrc > $HOME/.zshrc
echo "instalation succes !!"
