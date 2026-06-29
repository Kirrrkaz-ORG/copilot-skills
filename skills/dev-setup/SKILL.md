---
name: dev-setup
description: |
  Automate complete local development environment setup for Next.js + Supabase projects.
  Creates Supabase project, configures env vars, runs migrations, seeds data, creates test user.
  Useful for onboarding new developers or resetting local environment.
applyTo:
  - "**/*.*"
keywords:
  - setup
  - development environment
  - dev environment
  - local setup
  - supabase setup
  - environment variables
  - migrations
  - seed data
  - test user
  - настроить окружение
  - dev env
---

# Dev Environment Setup Skill

Автоматизация полного setup локального dev окружения для Next.js + Supabase проектов.

## Когда использовать

- Настройка проекта на новой машине
- Сброс локального окружения до чистого состояния
- Создание изолированной dev базы данных (отдельно от production)
- Onboarding нового разработчика в команду
- После `git clone` проекта с Supabase

## Что НЕ подходит

- Production deployment (используй Vercel/деплой инструменты)
- Простое `npm install` (просто запусти в терминале)
- Обновление зависимостей (используй `npm update`)
- Debugging существующего окружения (используй логи/errors)

## Инструкции

### Шаг 1: Проверка зависимостей

Убедись что установлены:

```bash
# Node.js (v18+)
node --version

# npm
npm --version

# Git
git --version
```

Если чего-то нет:
- **Node.js**: скачай с https://nodejs.org (LTS версия)
- **Git**: `brew install git` (macOS) или `sudo apt install git` (Linux)

### Шаг 2: Создание Supabase проекта

> **ВАЖНО**: Создавай **НОВЫЙ** проект для локальной разработки, отдельно от production!

**2.1. Открой Supabase Dashboard**
```bash
open https://supabase.com/dashboard/projects
```

**2.2. Создай новый проект:**
1. Нажми **"New Project"**
2. Выбери Organization (или создай Personal)
3. **Name**: `{project-name}-dev` (например `starte-ai-dev`)
4. **Database Password**: Сгенерируй сложный пароль и **СОХРАНИ ЕГО** (нужен для прямого подключения)
5. **Region**: Выбери ближайший (Europe/US East/etc.)
6. **Plan**: Free (для dev достаточно)
7. Нажми **"Create new project"**

Дождись создания (~2 минуты). Проект создан когда статус = "Healthy".

**2.3. Получи API ключи:**

Перейди в **Settings → API**:

1. **Project URL**: `https://xxxxx.supabase.co` → скопируй
2. **anon public** key (начинается с `eyJ...`) → скопируй
3. **service_role** key (тоже `eyJ...`, длиннее) → скопируй

### Шаг 3: Настройка .env.local

Создай (или обнови) файл `.env.local` в корне проекта:

```bash
# Supabase Dev Project (LOCAL ONLY!)
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Другие ключи (опционально)
# ANTHROPIC_API_KEY=
# OPENAI_API_KEY=
# META_ADS_ACCESS_TOKEN=
```

> **Безопасность**: `.env.local` должен быть в `.gitignore`! Не коммить ключи в Git!

Проверь `.gitignore`:
```bash
grep -q ".env.local" .gitignore || echo ".env.local" >> .gitignore
```

### Шаг 4: Установка зависимостей

```bash
npm install
```

Если есть ошибки с версиями:
```bash
npm install --legacy-peer-deps
```

### Шаг 5: Запуск миграций базы данных

> База данных только что создана — таблиц нет. Нужно накатить схему.

**5.1. Проверь наличие миграций:**
```bash
ls -la supabase/migrations/
```

Должны быть файлы типа `0001_initial_schema.sql`, `0002_add_courses.sql`, и т.д.

**5.2. Варианты запуска:**

**Вариант A: Через Supabase CLI (рекомендуется)**
```bash
# Установи CLI если нет
brew install supabase/tap/supabase

# Залогинься
supabase login

# Подключись к проекту
supabase link --project-ref xxxxx  # Project ID из dashboard

# Накати миграции
supabase db push
```

**Вариант B: Вручную через SQL Editor**

1. Открой https://supabase.com/dashboard/project/xxxxx/sql/new
2. Скопируй содержимое КАЖДОЙ миграции по очереди (начиная с `0001_...`)
3. Вставь в SQL Editor
4. Нажми **"Run"**
5. Повтори для всех миграций в порядке номеров

**Вариант C: Комбинированный SQL файл (если есть)**

Некоторые проекты имеют `setup_dev_db.sql` или `combined.sql`:

```bash
# Скопируй содержимое
cat supabase/setup_dev_db.sql | pbcopy  # macOS
cat supabase/setup_dev_db.sql | xclip -selection clipboard  # Linux

# Открой SQL Editor
open https://supabase.com/dashboard/project/xxxxx/sql/new

# Cmd+V → вставь → Run
```

### Шаг 6: Загрузка seed данных

> Таблицы созданы, но пустые. Нужно залить тестовые данные.

**6.1. Проверь наличие seed файлов:**
```bash
ls -la supabase/seed*.sql
ls -la data/*seed*.ts
```

**6.2. Запусти seed:**

**Если есть `seed.sql`:**
```bash
# Через CLI
supabase db push --file supabase/seed.sql

# Или вручную в SQL Editor (скопируй → вставь → Run)
```

**Если есть TypeScript seed (`data/seed.ts`):**
```bash
# Обычно запускается через npm script
npm run seed

# Или напрямую
npx tsx data/seed.ts
```

### Шаг 7: Создание тестового пользователя

> Нужен аккаунт для логина в dev окружении.

**7.1. Через Admin API (рекомендуется):**

Создай файл `scripts/create-test-user.js`:

```javascript
import { createClient } from '@supabase/supabase-js';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY // service_role для админских действий
);

const { data, error } = await supabase.auth.admin.createUser({
  email: 'dev@test.local',
  password: 'testpass123',
  email_confirm: true, // Пропускаем подтверждение email
});

if (error) {
  console.error('❌ Error:', error.message);
} else {
  console.log('✅ User created!');
  console.log('📧 Email:', 'dev@test.local');
  console.log('🔑 Password:', 'testpass123');
  console.log('🆔 User ID:', data.user.id);
}
```

Запусти:
```bash
node scripts/create-test-user.js
```

**7.2. Или через Dashboard UI:**

1. Открой https://supabase.com/dashboard/project/xxxxx/auth/users
2. Нажми **"Add user" → "Create new user"**
3. Email: `dev@test.local`
4. Password: `testpass123`
5. **Auto Confirm User**: ✅ ВКЛ (пропустить email подтверждение)
6. Нажми **"Create user"**

### Шаг 8: Запуск dev сервера

```bash
npm run dev
```

Открой http://localhost:3000

### Шаг 9: Проверка setup

**9.1. Логин работает:**
- Открой http://localhost:3000/login
- Введи `dev@test.local` / `testpass123`
- Должен успешно залогиниться

**9.2. База данных работает:**
```bash
# Проверь что таблицы созданы
# Открой SQL Editor и запусти:
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';
```

Должны быть твои таблицы (users, courses, и т.д.)

**9.3. Seed данные загружены:**

Открой страницу которая показывает данные (например `/courses`, `/dashboard`)
→ Должен увидеть тестовые данные

### Шаг 10: Сохрани credentials

Создай `DEV-CREDENTIALS.md` (добавь в `.gitignore`!):

```markdown
# Dev Environment Credentials

## Supabase Project
- **Project Name**: my-project-dev
- **Project ID**: xxxxx
- **Region**: Europe
- **URL**: https://xxxxx.supabase.co
- **Dashboard**: https://supabase.com/dashboard/project/xxxxx
- **Database Password**: [сохраненный при создании]

## Test User
- **Email**: dev@test.local
- **Password**: testpass123
- **User ID**: [из шага 7]

## Notes
- Это **локальное dev окружение** — не трогай production!
- При сбросе просто удали проект в Supabase и создай новый
```

Добавь в `.gitignore`:
```bash
echo "DEV-CREDENTIALS.md" >> .gitignore
```

---

## Troubleshooting

### Проблема: "Cannot find module @supabase/supabase-js"
**Решение:**
```bash
npm install @supabase/supabase-js
```

### Проблема: "Invalid API key" при запуске
**Решение:**
1. Перезапусти dev сервер (чтобы перезагрузить .env.local):
   ```bash
   # Ctrl+C остановить
   npm run dev
   ```
2. Проверь что ключи скопированы правильно (без лишних пробелов/переносов строк)

### Проблема: Миграции падают с ошибкой синтаксиса
**Решение:**
1. Откати последнюю миграцию вручную в SQL Editor:
   ```sql
   -- Посмотри какие таблицы созданы
   \dt
   
   -- Удали проблемную таблицу
   DROP TABLE IF EXISTS problem_table CASCADE;
   ```
2. Исправь SQL в файле миграции
3. Запусти заново

### Проблема: Email rate limit exceeded при создании пользователя
**Решение:** Используй Admin API (шаг 7.1) вместо обычного signup — он пропускает rate limiting.

### Проблема: Courses/данные не появляются на localhost
**Причина:** Localhost использует НОВУЮ пустую dev базу, а production использует базу клиента.

**Решение:** Загрузи seed данные (шаг 6). Это норма — dev и production должны быть разделены!

---

## Итоговый чеклист

После завершения setup у тебя должно быть:

- ✅ Node.js установлен
- ✅ Репозиторий склонирован
- ✅ Зависимости установлены (`npm install`)
- ✅ Supabase dev проект создан
- ✅ `.env.local` настроен с API ключами
- ✅ Миграции накачены (таблицы созданы)
- ✅ Seed данные загружены
- ✅ Тестовый пользователь создан
- ✅ Dev сервер запускается (`npm run dev`)
- ✅ Логин работает
- ✅ Данные отображаются
- ✅ Credentials сохранены в `DEV-CREDENTIALS.md`

---

## Автоматизация (Advanced)

Для повторного setup можно создать скрипт `scripts/setup-dev.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Starting dev environment setup..."

# 1. Check dependencies
echo "📋 Checking dependencies..."
command -v node >/dev/null 2>&1 || { echo "❌ Node.js not found!"; exit 1; }
command -v npm >/dev/null 2>&1 || { echo "❌ npm not found!"; exit 1; }

# 2. Install packages
echo "📦 Installing dependencies..."
npm install

# 3. Check .env.local
if [ ! -f .env.local ]; then
  echo "⚠️  .env.local not found! Create it with Supabase credentials."
  exit 1
fi

# 4. Run migrations (если Supabase CLI установлен)
if command -v supabase >/dev/null 2>&1; then
  echo "🔄 Running migrations..."
  supabase db push
else
  echo "⚠️  Supabase CLI not found. Run migrations manually."
fi

# 5. Run seed (если есть npm script)
if grep -q '"seed"' package.json; then
  echo "🌱 Seeding database..."
  npm run seed
fi

# 6. Create test user
echo "👤 Creating test user..."
node scripts/create-test-user.js

echo "✅ Setup complete! Run 'npm run dev' to start."
```

Использование:
```bash
chmod +x scripts/setup-dev.sh
./scripts/setup-dev.sh
```

---

## Дополнительные ресурсы

- [Supabase Quickstart](https://supabase.com/docs/guides/getting-started)
- [Next.js Documentation](https://nextjs.org/docs)
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- [Environment Variables in Next.js](https://nextjs.org/docs/basic-features/environment-variables)