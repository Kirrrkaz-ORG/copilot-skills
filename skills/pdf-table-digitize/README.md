# Навык: Оцифровка таблиц из отсканированных PDF

**Навык для GitHub Copilot** — полная процедура извлечения таблиц из PDF-сканов и экспорта в Markdown / Excel (.xlsx) с сохранением объединённых ячеек.

---

## Когда применять

| Ситуация | Подходит? |
|---|---|
| PDF-файл отсканированный (нет текстового слоя) | ✅ |
| Таблица с многоуровневыми заголовками | ✅ |
| Нужен результат в `.xlsx` с merge-ячейками | ✅ |
| Нагрузка, расписание, ведомость, реестр | ✅ |

---

## Установка

```powershell
# Windows
Copy-Item -Recurse "." "$env:USERPROFILE\.copilot\skills\pdf-table-digitize"
```

```bash
# macOS / Linux
cp -r . ~/.copilot/skills/pdf-table-digitize
```

---

## Триггеры (автозагрузка)

Навык загружается автоматически при фразах:

- `оцифровать pdf`
- `извлечь таблицу из pdf`
- `перевести pdf в excel`
- `pdf таблица`
- `нагрузка pdf`
- `pdf в xlsx`

---

## Процедура (6 шагов)

### Шаг 1 — Проверить текстовый слой

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        text = page.extract_text()
        print(f"Page {i+1}: tables={len(tables)}, text={bool(text)}")
```

Если `tables=0` и `text=None` → PDF отсканированный → идём дальше.

### Шаг 2 — PDF → PNG (PyMuPDF)

```python
import fitz
doc = fitz.open("file.pdf")
for i, page in enumerate(doc):
    pix = page.get_pixmap(matrix=fitz.Matrix(2.5, 2.5))
    pix.save(f"page_{i+1}.png")
```

### Шаг 3 — Поворот страниц (если ландшафт)

```python
from PIL import Image
img = Image.open("page_2.png")
rotated = img.rotate(-90, expand=True)   # CW
rotated.save("page_2_rot.png")
```

### Шаг 4 — Визуальный анализ (нарезка секций)

```python
from PIL import Image
img = Image.open("page_1.png")
img.crop((0, 0, img.width, 500)).save("header.png")    # шапка
img.crop((0, 500, img.width, 1400)).save("rows.png")   # данные
```

### Шаг 5 — Перенести в Markdown

```markdown
| ФИО | Дисциплина | Группа | 1 п/г | 2 п/г | Всего |
|---|---|---|---|---|---|
| Иванов И.И. | Математика | 11А | 34 | 36 | 70 |
| ↑ | ↑ | 12А | 34 | 36 | 70 |
| **Итого:** | | | **68** | **72** | **140** |
```

`↑` = объединённая ячейка (значение из строки выше)

### Шаг 6 — Экспорт в Excel

Используй [`scripts/make_xlsx.py`](./scripts/make_xlsx.py) — замени данные в переменных `*_DATA` и запусти:

```bash
python scripts/make_xlsx.py /путь/к/папке/вывода
```

---

## Зависимости

```
pip install pdfplumber pymupdf Pillow openpyxl
```

---

## Структура файлов

```
pdf-table-digitize/
├── SKILL.md                   # Инструкции для Copilot
├── README.md                  # Этот файл (для людей)
├── scripts/
│   └── make_xlsx.py           # Генератор Excel
└── references/
    └── patterns.md            # Паттерны, чеклист
```

---

## Пример использования

Реальный пример: оцифровка `нагрузка_2025-2026.pdf` (отсканированный документ, 2 страницы, ландшафтная + портретная ориентация):

1. Страница 1 — аудиторная нагрузка Фролова К.В. (11 строк, двухуровневая шапка)
2. Страница 2 — практики Фролова К.А. (12 строк, колонки со ставкой 0,5/1)
3. Результат: `.md` файл + `.xlsx` с правильными merge-ячейками и заморозкой заголовков
