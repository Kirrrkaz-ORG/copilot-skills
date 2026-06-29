---
name: pdf-table-digitize
description: Оцифровка таблиц из отсканированных PDF-файлов. Извлечение таблиц из PDF (в том числе без текстового слоя), конвертация в Markdown и Excel с сохранением объединённых ячеек.
version: 1.0.0
---

# PDF Table Digitize

Автоматическая оцифровка таблиц из отсканированных PDF-файлов в Markdown и Excel с правильной обработкой объединённых ячеек.

## Когда использовать

Используйте этот навык когда:
- PDF-файл содержит таблицы (расписание, нагрузка, ведомость, реестр)
- PDF отсканированный — нет текстового слоя (pdfplumber не находит таблицы)
- Нужен результат в Markdown и/или Excel (.xlsx) с правильными merge-ячейками
- Таблица многоуровневая (объединённые заголовки + подзаголовки)

## Процедура

### Шаг 1: Проверить текстовый слой в PDF

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    for i, page in enumerate(pdf.pages):
        tables = page.extract_tables()
        text  = page.extract_text()
        print(f"Page {i+1}: tables={len(tables)}, text={bool(text)}")
```

Если `tables=0` и `text=None` → PDF отсканированный → переходим к Шагу 2.

**Зависимости:** `pip install pdfplumber`

### Шаг 2: Конвертировать страницы PDF в PNG

```python
import fitz  # pymupdf
doc = fitz.open("file.pdf")
for i, page in enumerate(doc):
    mat = fitz.Matrix(2.5, 2.5)   # 250% — хорошее разрешение для OCR
    pix = page.get_pixmap(matrix=mat)
    pix.save(f"page_{i+1}.png")
```

**Зависимости:** `pip install pymupdf`

**Важно:** если страницы ландшафтные (повёрнутые), используй Pillow для поворота:

```python
from PIL import Image
img = Image.open("page_2.png")
rotated = img.rotate(-90, expand=True)  # CW — для ландшафта
rotated.save("page_2_rot.png")
```

### Шаг 3: Визуальный анализ таблицы

1. Открыть полученные PNG в VS Code (`view_image`)
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

### Шаг 4: Перенести в Markdown

**Правила оформления:**
- Многоуровневые заголовки описывать в секции «Примечания к структуре»
- Объединённые ячейки (продолжение сверху) обозначать `↑`
- Пустые ячейки — пустыми `| |`
- Строку ИТОГО выделять жирным

**Пример:**
```markdown
| ФИО | Дисциплина | Группа | 1 п/г | 2 п/г | Всего |
|---|---|---|---|---|---|
| Иванов И.И. | Математика | 11А | 34 | 36 | 70 |
| ↑ | ↑ | 12А | 34 | 36 | 70 |
| **Итого:** | | | **68** | **72** | **140** |
```

### Шаг 5: Экспортировать в Excel (.xlsx)

Использовать openpyxl для создания файла с объединёнными ячейками и форматированием.

**Ключевые паттерны:**

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

### Шаг 6: Очистить временные файлы

```powershell
Remove-Item "page_*.png", "header.png", "mid.png" -ErrorAction SilentlyContinue
```

## Стандартные цвета

| Элемент | HEX |
|---|---|
| Заголовки (шапка) | `BDD7EE` (синий) |
| Строка ИТОГО | `FFF2CC` (жёлтый) |
| Промежуточные | `D9D9D9` (серый) |

## Зависимости Python

```bash
pip install pdfplumber pymupdf Pillow openpyxl
```

- **pdfplumber** — проверка текстового слоя
- **pymupdf** — конвертация PDF → PNG
- **Pillow** — поворот, нарезка изображений
- **openpyxl** — генерация .xlsx

## Примеры использования

### Пример 1: Оцифровка учебной нагрузки

```
Входные данные: нагрузка_2026.pdf (отсканированный)
Результат: 
- нагрузка_2026.md (таблица в Markdown)
- нагрузка_2026.xlsx (Excel с merge-ячейками)
```

### Пример 2: Расписание экзаменов

```
Входные данные: расписание_июнь.pdf
Результат:
- расписание_июнь.md
- расписание_июнь.xlsx (с цветным выделением шапки)
```

### Пример 3: Ведомость оценок

```
Входные данные: ведомость_ИС-21.pdf
Результат:
- ведомость_ИС-21.md (с символом ↑ для объединённых ФИО)
- ведомость_ИС-21.xlsx (с merge для повторяющихся ФИО)
```

## Типичные проблемы

### Проблема: pdfplumber не находит таблицы

**Решение:** PDF отсканированный без текстового слоя → используй pymupdf для конвертации в PNG

### Проблема: Таблица повёрнута

**Решение:** Используй Pillow для поворота изображения:
```python
img.rotate(-90, expand=True)  # против часовой
img.rotate(90, expand=True)   # по часовой
```

### Проблема: Текст в ячейках слишком мелкий

**Решение:** Увеличь разрешение при конвертации:
```python
mat = fitz.Matrix(3.0, 3.0)  # 300% вместо 250%
```

### Проблема: Не понятна структура объединённых ячеек

**Решение:** Нарежь изображение на секции и рассмотри шапку отдельно от данных
