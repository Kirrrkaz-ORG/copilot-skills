---
name: pdf-table-digitize
description: >
  Оцифровка таблиц из отсканированных PDF-файлов. Используй этот навык когда нужно:
  извлечь таблицу из PDF (в том числе отсканированного без текстового слоя);
  перевести таблицу из PDF в Markdown; конвертировать таблицу в Excel (.xlsx);
  сохранить объединённые ячейки (merged cells) при экспорте в xlsx;
  оцифровать нагрузку, расписание, ведомость или любой табличный документ из PDF.
  Triggers: "pdf таблица", "оцифровать pdf", "сканированный pdf", "перевести в excel",
  "извлечь таблицу", "нагрузка pdf", "pdf в xlsx".
argument-hint: 'путь к PDF-файлу'
---

# Навык: Оцифровка таблиц из отсканированных PDF

## Когда применять

- PDF-файл содержит таблицы (расписание, нагрузка, ведомость, реестр и т.д.)
- PDF отсканированный — нет текстового слоя (pdfplumber не находит таблицы)
- Нужен результат в Markdown и/или Excel (.xlsx) с правильными merge-ячейками
- Таблица многоуровневая (объединённые заголовки + подзаголовки)

---

## Процедура

### Шаг 1 — Проверить текстовый слой в PDF

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        text  = page.extract_text()
        print(f"Page {i+1}: tables={len(tables)}, text={bool(text)}")
```

Если `tables=0` и `text=None` → PDF отсканированный → переходим к Шагу 2.

Зависимости: `pip install pdfplumber`

---

### Шаг 2 — Конвертировать страницы PDF в PNG (PyMuPDF)

```python
import fitz  # pymupdf
doc = fitz.open("file.pdf")
for i, page in enumerate(doc):
    mat = fitz.Matrix(2.5, 2.5)   # 250% — хорошее разрешение для OCR
    pix = page.get_pixmap(matrix=mat)
    pix.save(f"page_{i+1}.png")
```

Зависимости: `pip install pymupdf`

**Важно:** если страницы ландшафтные (повёрнутые), используй Pillow для поворота:

```python
from PIL import Image
img = Image.open("page_2.png")
rotated = img.rotate(-90, expand=True)  # CW — для ландшафта из портрета
rotated.save("page_2_rot.png")
```

---

### Шаг 3 — Визуальный анализ таблицы

1. Открыть полученные PNG в VS Code (`view_image`).
2. При необходимости нарезать на секции для детального чтения:
   ```python
   from PIL import Image
   img = Image.open("page_1.png")
   header = img.crop((0, 0, img.width, 500))  # Шапка
   header.save("header.png")
   mid = img.crop((0, 500, img.width, 1300))   # Данные
   mid.save("mid.png")
   ```
3. Зафиксировать:
   - Структуру заголовков (одно- или двухуровневая шапка, объединённые ячейки)
   - Список столбцов и их значений
   - Какие ячейки объединены по строкам (ФИО, дисциплина и т.д.)
   - Строку ИТОГО

---

### Шаг 4 — Перенести в Markdown

Правила оформления:
- Многоуровневые заголовки описывать в секции «Примечания к структуре»
- Объединённые ячейки (продолжение сверху) обозначать `↑`
- Пустые ячейки — пустыми `| |`
- Строку ИТОГО выделять жирным

Шаблон:
```markdown
| ФИО | Дисциплина | Группа | 1 п/г | 2 п/г | Всего |
|---|---|---|---|---|---|
| Иванов И.И. | Математика | 11А | 34 | 36 | 70 |
| ↑ | ↑ | 12А | 34 | 36 | 70 |
| **Итого:** | | | **68** | **72** | **140** |
```

---

### Шаг 5 — Экспортировать в Excel (.xlsx)

Использовать скрипт [make_xlsx.py](./scripts/make_xlsx.py).

Ключевые паттерны openpyxl:

```python
from openpyxl import Workbook
from openpyxl.styles import Font, Alignment, PatternFill, Border, Side
from openpyxl.utils import get_column_letter

wb = Workbook()
ws = wb.active

# Многоуровневые заголовки — merge + заливка
ws.merge_cells("D2:F2")
ws["D2"] = "Кол-во часов"
ws["D2"].fill = PatternFill("solid", fgColor="BDD7EE")
ws["D2"].font = Font(bold=True)
ws["D2"].alignment = Alignment(horizontal="center", vertical="center", wrap_text=True)

# Объединить ФИО по нескольким строкам
ws.merge_cells("A4:A14")
ws["A4"] = "Иванов И.И."

# Строка ИТОГО
ws.merge_cells("A15:C15")
ws["A15"] = "ИТОГО"
ws["A15"].fill = PatternFill("solid", fgColor="FFF2CC")
ws["A15"].font = Font(bold=True)

# Заморозка заголовков
ws.freeze_panes = "A4"

wb.save("output.xlsx")
```

---

### Шаг 6 — Очистить временные файлы

```powershell
Remove-Item "page_*.png", "header.png", "mid.png" -ErrorAction SilentlyContinue
```

---

## Стандартные цвета

| Элемент | HEX |
|---|---|
| Заголовки (шапка) | `BDD7EE` (синий) |
| Строка ИТОГО | `FFF2CC` (жёлтый) |
| Промежуточные | `D9D9D9` (серый) |

## Зависимости Python

```
pdfplumber   — проверка текстового слоя
pymupdf      — конвертация PDF → PNG
Pillow       — поворот, нарезка изображений
openpyxl     — генерация .xlsx
```

Установка одной командой:
```
pip install pdfplumber pymupdf Pillow openpyxl
```
