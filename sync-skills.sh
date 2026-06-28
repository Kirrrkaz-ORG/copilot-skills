#!/bin/bash
# Скрипт для синхронизации Copilot Skills между машинами через GitHub

set -e

REPO_DIR=~/copilot-skills
PROMPTS_DIR=~/Library/Application\ Support/Code/User/prompts

echo "🔄 Copilot Skills Sync"
echo "====================="

# Проверяем существование репозитория
if [ ! -d "$REPO_DIR" ]; then
    echo "📦 Клонирую репозиторий..."
    cd ~
    git clone https://github.com/Kirrrkaz-ORG/copilot-skills.git
else
    echo "📥 Обновляю из GitHub..."
    cd "$REPO_DIR"
    git pull origin main
fi

# Создаём папку prompts если её нет
mkdir -p "$PROMPTS_DIR"

# Создаём симлинки
echo "🔗 Создаю симлинки..."
rm -rf "$PROMPTS_DIR"/*
ln -sf "$REPO_DIR"/skills/* "$PROMPTS_DIR"/

echo "✅ Синхронизация завершена!"
echo ""
echo "Скиллы доступны в VS Code через @ mention"
ls -la "$PROMPTS_DIR"
