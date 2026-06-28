---
name: loom-tz-analyzer
description: |
  Analyze technical specifications and requirements from Loom video recordings.
  Extracts transcripts, identifies key requirements, tasks, deadlines, and technical constraints.
  Useful for converting video briefs into structured documentation.
applyTo:
  - "**/*.*"
keywords:
  - loom
  - video
  - technical specification
  - requirements
  - video brief
  - transcript
  - ТЗ из видео
  - loom.com
---

# Loom TZ Analyzer

Этот скилл анализирует техническое задание (ТЗ) из видео записанных в Loom.

## Когда использовать

- Пользователь прикрепил или упомянул Loom URL (https://www.loom.com/share/...)
- Нужно извлечь требования из видео-брифа
- Нужно создать структурированное ТЗ на основе видео
- Клиент/менеджер записал требования в видео вместо текста

## Что НЕ подходит

- Видео не содержит технических требований (entertainment, tutorials без ТЗ)
- Видео с других платформ (YouTube, Vimeo) — для них нужен другой подход
- Видео без звука или субтитров

## Инструкции

### Шаг 1: Получение транскрипта

Используй **автоматический метод** (без API токена):

**Метод A: Автоматический парсинг (RECOMMENDED)**
```bash
# 1. Извлечь video_id из URL
VIDEO_ID=$(echo "https://www.loom.com/share/abc123" | sed 's#.*/##')

# 2. Скачать HTML страницы и извлечь Apollo State
curl -s "https://www.loom.com/share/$VIDEO_ID" | \
  grep -o 'VideoTranscriptDetails[^}]*source_url":"[^"]*' | \
  sed 's/.*source_url":"//' > transcript_url.txt

# 3. Скачать JSON транскрипт
TRANSCRIPT_URL=$(cat transcript_url.txt)
curl -s "$TRANSCRIPT_URL" > transcript.json

# 4. Парсить транскрипт в читаемый формат
python3 -c "
import json, sys
with open('transcript.json') as f:
    data = json.load(f)
    # Полный текст одной строкой
    full_teИзвлечение метаданных

Параллельно с транскриптом извлеки метаданные:

```bash
# Из Apollo State на странице
curl -s "https://www.loom.com/share/$VIDEO_ID" | python3 -c "
import re, json, sys
html = sys.stdin.read()

# Найти Apollo State
match = re.search(r'window\.__APOLLO_STATE__\s*=\s*({.*?});', html, re.DOTALL)
if match:
    state = json.loads(match.group(1))
    
    # Извлечь video данные
    video_key = f'RegularUserVideo:{VIDEO_ID}'
    if video_key in state:
        video = state[video_key]
        print(f\"Title: {video.get('title', 'Untitled')}\")
        print(f\"Duration: {video.get('duration', 'N/A')}s\")
        print(f\"Created: {video.get('createdAt', 'N/A')}\")
        
    # Извлечь автора
    user_ref = video.get('owner', {}).get('__ref', '')
    if user_ref in state:
        user = state[user_ref]
        print(f\"Author: {user.get('display_name', 'Unknown')}\")
"
```

Сохрани в переменные:
- `VIDEO_TITLE` — название видео
- `VIDEO_DURATION` — длительность (секунды)
- `VIDEO_DATE` — дата создания
- `VIDEO_AUTHOR` — автор

### Шаг 3: xt = ' '.join([p['value'] for p in data['phrases']])
    print(full_text)
    
    # С таймштампами (опционально)
    print('\n\n=== WITH TIMESTAMPS ===\n')
    for phrase in data['phrases']:
        print(f\"{int(phrase['ts']//60)}:{int(phrase['ts']%60):02d} - {phrase['value']}\")
"
```

**Метод B: VTT Captions (альтернатива)**
```bash
# Если JSON недоступен, используй VTT captions
curl -s "https://www.loom.com/share/$VIDEO_ID" | \
  grep -o 'captions_source_url":"[^"]*' | \
  sed 's/.*captions_source_url":"//' > captions_url.txt

CAPTIONS_URL=$(cat captions_url.txt)
curl -s "$CAPTIONS_URL" > captions.vtt

# VTT проще читать — уже форматированный текст с таймкодами
cat captions.vtt
```

**Метод C: Ручной ввод (fallback)**
Если автоматические методы не сработали:
1. Открыть видео в Loom
2. Нажать "⋯" (More) → "View transcript"
3. Скопировать текст → вставить в чат

**Метод D: Loom API (если есть токен)**
```bash
curl -H "Authorization: Bearer $LOOM_API_TOKEN" \
  https://api.loom.com/v1/videos/{video_id}/transcription
```

### Шаг 2: Анализ транскрипта

Прочитай транскрипт и выдели следующие секции:
4: Сохранение транскрипта (опционально)

Если работаешь в проекте, сохрани транскрипт для будущего:

```bash
# Создай папку для транскриптов
mkdir -p docs/transcripts

# Сохрани с датой и video_id
DATE=$(date +%Y-%m-%d)
cp transcript.json "docs/transcripts/${DATE}_${VIDEO_ID}.json"

# Сохрани также читаемую версию
python3 -c "
import json
with open('transcript.json') as f:
    data = json.load(f)
    with open('docs/transcripts/${DATE}_${VIDEO_ID}.txt', 'w') as out:
        for phrase in data['phrases']:
            out.write(f\"{phrase['value']} \")
"
```

### Шаг 5
1. **Цель проекта / Mission Statement**
   - Главная проблема, которую решает проект
   - Целевая аудитория
   - Ожидаемый результат

2. **Функциональные требования**
   - Список фич и возможностей
   - User stories (если упоминаются)
   - Workflow / user flow

3. **Технические требования**
   - Стек технологий (если упомянут)
   - Интеграции с внешними сервисами
   - API endpoints (если описаны)
   - Модели данных / структура БД

4. **Дизайн / UX приоритеты**
   - Ключевые элементы интерфейса
   VIDEO_TITLE или "Название проекта из видео"]

**Source:** [Loom URL]  
**Author:** [VIDEO_AUTHOR]  
**Date:** [VIDEO_DATE]  
**Duration:** [MM:SS из VIDEO_DURATION]  
**Language:** [Определить автоматически из транскрипт
   - Сроки / дедлайны
   - Технические ограничения (например, "без backend")
   - Compliance (GDPR, безопасность)

6. **Критерии приемки / MVP scope**
   - Что должно быть в первой версии
   - Что можно отложить на потом
   - Как проверить успешность

7. **Open Questions / Неясности**
   - Вопросы, которые нужно уточнить у клиента
   - Технические решения, требующие обсуждения

### Шаг 3: Структурированный вывод

Создай документ в формате:

```markdown
# [Название проекта из видео]

**Source:** [Loom URL]  
**Date:** [Дата из видео или текущая]  
**Duration:** [Длительность видео, если доступна]

---

## 🎯 Mission / Цель

[1-2 предложения главной цели]

---

## 📋 Functional Requirements

- [ ] Requirement 1
- [ ] Requirement 2
...

---

## 🔧 Technical Requirements

**Stack:**
- Frontend: [технологии]
- Backend: [технологии]
- Database: [БД]

**Integrations:**
- [API 1]
- [API 2]

**Data Model:**
```
[если упомянута структура данных]
```

---

## 🎨 Design / UX Priorities

- Priority 1
- Priority 2
...

**References:**
- [Упомянутые продукты-референсы]

---

## ⏰ Timeline & Constraints

**Deadline:** [если упомянут]  
**Budget:** [если упомянут]  
**Constraints:**
- [Ограничение 1]
- [Ограничение 2]

---

## ✅ Acceptance Criteria (MVP)

**Must Have:**
- [ ] Feature 1
- [ ] Feature 2

**Nice to Have (v2):**
- [ ] Feature 3
- [ ] Feature 4

---

## ❓ Open Questions

1. [Вопрос для уточнения]
2. [Технический вопрос]

---

## 📝 Raw Transcript

<details>
<summary>View full transcript</summary>

[Полный текст транскрипта]

</details>
```6: Дополнительные действия

**Если в видео показывали экран:**
- Упомяни ключевые UI элементы из контекста транскрипта
- Если нужны скриншоты, предложи пользователю сделать их вручную (Loom не даёт frames)

**Если видео длинное (>15 мин):**
- Группируй по временным блокам (0-5 мин, 5-10 мин, и т.д.)
- Используй timestamps для навигации: `[12:34] - Topic discussion`

**Если несколько спикеров:**
- Укажи, кто какие требования озвучил (если транскрипт содержит speaker labels)

**Если транскрипт на иностранном языке:**
- Определи язык автоматически (по Unicode диапазонам)
- Укажи в документе: `Language: Russian / English / etc.`
- Если нужен перевод — предложи ключевые секции
**Если несколько спикеров:**
- Укажи, кто какие требования озвучил (если транскрипт содержит speaker labels)

## Примеры использования

### Пример 1: Простой запрос

**User:**
```
Проанализируй ТЗ из видео: https://www.loom.com/share/abc123def456
```

**Agent:**
1. Извлекает video_id: `abc123def456`
2. Запрашивает транскрипт через API (или просит пользователя)
3. Анализирует текст
4. Создаёт структурированный документ с требованиями

### Пример 2: С уточнениями

**User:**
```
@loom-tz-analyzer https://www.loom.com/share/xyz789
Особенно важно выделить сроки и технический стек
```

**Agent:**
1. Получает транскрипт
2. Фокусируется на секциях "Timeline" и "Technical Requirements"
3. Выделяет эти части жирным/отдельно

### Пример 3: Fallback без API

**User:**
```
Вот транскрипт из Loom видео:
[вставлен длинный текст]

Нужно структурировать как ТЗ
```

**Agent:**
1. Пропускает Шаг 1 (транскрипт уже есть)
2. Сразу анализирует текст
3. Создаёт документ

## Technical Notes

### Loom API

**Endpoint для транскрипта:**
```
GET https://api.loom.com/v1/videos/{video_id}/transcription
Headers:
  Authorization: Bearer {LOOM_API_TOKEN}
```

**Response format:**
```json
{
  "transcription": {
    "text": "Full transcript text...",
    "words": [
      {"text": "Hello", "start": 0.5, "end": 0.8},
      ...
    ]
  }
}
```

**Получение токена:**
- Пользователь должен создать Loom API key: https://www.loom.com/developer/api-keys
- Сохранить в переменную окружения: `export LOOM_API_TOKEN=your_token`

### Альтернативы

Если Loom API недоступен:
1. **YouTube DL** — если видео публичное, можно скачать и использовать Whisper API для транскрипции
2. **Ручной ввод** — попросить пользователя скопировать транскрипт
3. **OCR видео** — последний вариант, если в видео показывают текст на экране

### Стоимость

- **Loom API:** Бесплатен до 25 requests/min (Business plan)
- **Whisper AP`ERR_BLOCKED_BY_CSP` при fetch_webpage  
**Решение:** ✅ Использовать curl вместо fetch_webpage (Loom блокирует JS fetch)

**Проблема:** Signed URL истёк (expired timestamp в URL)  
**Решение:** 
1. Signed URLs живут ~1 час
2. Перезагрузи страницу: `curl -s "https://www.loom.com/share/$VIDEO_ID"` → получи новый URL
3. Если нужен долговременный доступ — сохрани JSON локально (шаг 4)

**Проблема:** Видео приватное (403 Forbidden)  
**Решение:** 
1. Попросить пользователя: Share settings → "Anyone with link can view"
2. Или попросить скопировать транскрипт вручную из Loom UI

**Проблема:** Транскрипт отсутствует (processing_status не "success")  
**Решение:** 
1. Проверить в Apollo State: `transcription_status`
2. Если "processing" — подождать 2-3 минуты, видео ещё транскрибируется
3. Если "failed" — попросить пользователя включить transcription в настройках видео

**Проблема:** Транскрипт содержит много "um", "uh", fillers  
**Решение:** 
1. Loom использует Whisper API — обычно чистый текст
2. Если много шума — очистить через regex: `re.sub(r'\b(um|uh|er|ah)\b', '', text)`
3. Сохранить raw в `<details>` для полноты

**Проблема:** JSON парсинг падает (invalid escape sequences)  
**Решение:** 
1. URL содержит `%7E` вместо `~` — это нормально
2. Использовать `curl -s` (не `-v`) чтобы избежать debug output
3. Helper Script (optional)

Для повторного использования можешь создать bash скрипт:

```bash
#!/bin/bash
# loom-extract.sh - Extract Loom video transcript

VIDEO_URL=$1
VIDEO_ID=$(echo "$VIDEO_URL" | sed 's#.*/##')

echo "📥 Fetching transcript for $VIDEO_ID..."

# Get page and extract transcript URL
TRANSCRIPT_URL=$(curl -s "https://www.loom.com/share/$VIDEO_ID" | \
  grep -o '"source_url":"[^"]*transcription[^"]*' | \
  sed 's/"source_url":"//' | head -1)

if [ -z "$TRANSCRIPT_URL" ]; then
  echo "❌ Could not find transcript URL. Video might be private or processing."
  exit 1
fi

# Download transcript
curl -s "$TRANSCRIPT_URL" > "/tmp/loom_${VIDEO_ID}.json"

# Parse and output
python3 <<EOF
import json
with open('/tmp/loom_${VIDEO_ID}.json') as f:
    data = json.load(f)
    print('\n📝 Full Transcript:\n')
    print(' '.join([p['value'] for p in data['phrases']]))
    print(f"\n\n⏱️  Duration: {data['phrases'][-1]['ts']:.0f}s")
    print(f"📊 Phrases: {len(data['phrases'])}")
EOF

echo "\n✅ Transcript saved to /tmp/loom_${VIDEO_ID}.json"
```

**Usage:**
```bash
chmod +x loom-extract.sh
./loom-extract.sh https://www.loom.com/share/abc123def456
```

## Updates Log

- **2026-06-28 v2:** Improved extraction
  - ✅ Автоматический парсинг без API токена (через Apollo State)
  - ✅ VTT captions fallback
  - ✅ Извлечение метаданных (title, author, duration, date)
  - ✅ Сохранение транскриптов в `docs/transcripts/`
  - ✅ Helper script для переиспользования
  - ✅ Edge cases обработка (expired URLs, private videos)
  
- **2026-06-28 v1Транскрипт содержит много "um", "uh", fillers  
**Решение:** 
1. Очистить текст от междометий
2. Сохранить raw транскрипт в `<details>` для референса

## Related Skills

- **fetch_webpage** — для загрузки страницы Loom (если API недоступен)
- **pdf-table-digitize** — если пользователь прикрепил PDF с требованиями в дополнение к видео
- **agent-customization** — если нужно сохранить стандарты ТЗ документации

## Updates Log

- **2026-06-28:** Initial version
  - Поддержка Loom API
  - Fallback на ручной ввод
  - Структурированный output формат
