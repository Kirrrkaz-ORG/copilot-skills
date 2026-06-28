#!/bin/bash
# Скрипт для отправки изменений скиллов в GitHub

set -e

REPO_DIR=~/copilot-skills

cd "$REPO_DIR"

echo "📤 Отправка изменений в GitHub"
echo "=============================="

# Проверяем наличие изменений
if [[ -z $(git status -s) ]]; then
    echo "ℹ️  Нет изменений для отправки"
    exit 0
fi

echo "📝 Изменённые файлы:"
git status -s

echo ""
read -p "💬 Введи описание изменений: " commit_message

if [ -z "$commit_message" ]; then
    commit_message="Update skills from MacBook"
fi

git add .
git commit -m "$commit_message"
git push origin main

echo "✅ Изменения отправлены!"
