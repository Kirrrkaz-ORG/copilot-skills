# 🧠 Copilot Skills Library

Персональная библиотека навыков для **GitHub Copilot** — набор готовых `SKILL.md` файлов, которые автоматически подхватываются агентом и расширяют его возможности.

> Все навыки сохранены в `~/.copilot/skills/` и доступны **во всех рабочих пространствах**.

---

## 📚 Навыки

| # | Навык | Описание | Триггеры |
|---|-------|----------|----------|
| 1 | [pdf-table-digitize](./skills/pdf-table-digitize/) | Оцифровка таблиц из отсканированных PDF → Markdown + Excel | `оцифровать pdf`, `перевести в excel`, `извлечь таблицу` |

---

## 🚀 Как использовать

### Установка навыка

Скопируй папку нужного навыка в `~/.copilot/skills/`:

```powershell
# Windows
Copy-Item -Recurse ".\skills\pdf-table-digitize" "$env:USERPROFILE\.copilot\skills\"
```

```bash
# macOS / Linux
cp -r ./skills/pdf-table-digitize ~/.copilot/skills/
```

Перезапусти VS Code — навык появится автоматически.

### Использование в чате

Навыки загружаются **автоматически** когда ты пишешь запрос, соответствующий их описанию.  
Также можно явно вызвать через `/` в поле чата: `/pdf-table-digitize`.

---

## 📁 Структура репозитория

```
copilot-skills/
├── README.md                          # Этот файл
└── skills/
    └── pdf-table-digitize/            # Навык №1
        ├── SKILL.md                   # Основные инструкции (6 шагов)
        ├── scripts/
        │   └── make_xlsx.py           # Шаблон генератора Excel
        └── references/
            └── patterns.md            # Паттерны merge-ячеек, чеклист
```

---

## 🛠️ Добавить новый навык

1. Создай папку `skills/<имя-навыка>/`
2. Добавь `SKILL.md` с frontmatter:
   ```yaml
   ---
   name: имя-навыка
   description: 'Что делает и когда использовать. Триггеры: ...'
   ---
   ```
3. Скопируй в `~/.copilot/skills/` и открой PR

---

## 🤝 Контрибьюция

Если хочешь добавить свой навык — открывай Pull Request!  
Формат навыков соответствует [документации VS Code Agent Skills](https://code.visualstudio.com/docs/copilot/customization/agent-skills).

---

*Библиотека развивается — навыки добавляются по мере реальных задач.*
