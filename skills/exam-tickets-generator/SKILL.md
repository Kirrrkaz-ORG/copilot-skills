---
name: exam-tickets-generator
description: |
  Генерация экзаменационных билетов и эталонных ответов по шаблону в формате Word (.docx).
  
  Когда использовать:
  - Создание экзаменационных билетов по утверждённому образцу
  - Генерация документов с эталонными ответами на теоретические вопросы
  - Парсинг вопросов из Markdown и создание Word документов
  - Автоматизация подготовки КИМ (контрольно-измерительных материалов)
  
  НЕ использовать для:
  - Создания билетов с нуля без исходных данных
  - Редактирования существующих Word документов вручную
  - Генерации содержания вопросов (только форматирование готовых)
---

# Навык: Генератор экзаменационных билетов

## Описание

Этот навык позволяет автоматически создавать экзаменационные билеты в формате Word на основе исходных данных в Markdown или других форматах. Включает генерацию как самих билетов, так и документа с эталонными ответами.

## Возможности

1. **Парсинг исходных данных**
   - Извлечение вопросов из Markdown файлов
   - Извлечение текста из Word документов (.docx)
   - Определение уникальных вопросов (устранение дубликатов)

2. **Генерация билетов**
   - Создание Word документов с таблицей-шапкой
   - Форматирование по стандарту образовательного учреждения
   - Поддержка теоретических вопросов и практических заданий
   - Автоматическая нумерация билетов

3. **Генерация эталонных ответов**
   - Создание приложения с ответами
   - Сопоставление вопросов с ответами
   - Единообразное форматирование

## Структура входных данных

### Формат Markdown для вопросов

```markdown
**Билет №1**

**Теоретические вопросы:**

1. Первый теоретический вопрос?  
2. Второй теоретический вопрос?

**Практические задания:**

1. Описание первого практического задания...
2. Описание второго практического задания...
3. Описание третьего практического задания...

---

**Билет №2**
...
```

## Рабочий процесс

### Шаг 1: Подготовка исходных данных

Пользователь предоставляет:
- Файл с вопросами в формате Markdown или Word
- Образец существующего билета (для референса форматирования)
- Информацию об учебном заведении и дисциплине

### Шаг 2: Анализ структуры

1. Изучить предоставленный образец билета
2. Определить структуру таблицы (количество строк, столбцов, объединение ячеек)
3. Выявить стиль форматирования (шрифты, размеры, выравнивание)
4. Понять требования к шапке документа

### Шаг 3: Извлечение данных

```python
import re

def parse_markdown_tickets(file_path):
    """Парсит Markdown файл с билетами"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    tickets = {}
    ticket_pattern = r'\*\*Билет №(\d+)\*\*(.*?)(?=\*\*Билет №|\Z)'
    matches = re.finditer(ticket_pattern, content, re.DOTALL)
    
    for match in matches:
        ticket_num = int(match.group(1))
        block = match.group(2)
        
        # Извлечение теоретических вопросов
        theory_section = re.search(
            r'\*\*Теоретические вопросы:\*\*(.*?)\*\*Практические задания:\*\*',
            block, re.DOTALL
        )
        theory_questions = []
        if theory_section:
            theory_text = theory_section.group(1).strip()
            for line in theory_text.split('\n'):
                line = line.strip()
                if line and re.match(r'^\d+\.', line):
                    question = re.sub(r'^\d+\.\s*', '', line).strip()
                    theory_questions.append(question)
        
        # Извлечение практических заданий
        practice_section = re.search(
            r'\*\*Практические задания:\*\*(.*?)(?:---|$)',
            block, re.DOTALL
        )
        practice_tasks = []
        if practice_section:
            practice_text = practice_section.group(1).strip()
            current_task = []
            for line in practice_text.split('\n'):
                line = line.strip()
                if line:
                    if re.match(r'^\d+\.', line):
                        if current_task:
                            practice_tasks.append(' '.join(current_task))
                        current_task = [re.sub(r'^\d+\.\s*', '', line)]
                    else:
                        if current_task:
                            current_task.append(line)
            if current_task:
                practice_tasks.append(' '.join(current_task))
        
        tickets[ticket_num] = {
            'theory': theory_questions,
            'practice': practice_tasks
        }
    
    return tickets
```

### Шаг 4: Генерация билетов

```python
from docx import Document
from docx.shared import Pt, Inches
from docx.enum.text import WD_ALIGN_PARAGRAPH

def create_tickets_document(tickets, output_path, org_info):
    """Создает Word документ с билетами"""
    doc = Document()
    
    # Настройка полей
    for section in doc.sections:
        section.top_margin = Inches(0.5)
        section.bottom_margin = Inches(0.5)
        section.left_margin = Inches(0.8)
        section.right_margin = Inches(0.5)
    
    for ticket_num in sorted(tickets.keys()):
        ticket = tickets[ticket_num]
        
        # Создание таблицы-шапки
        table = doc.add_table(rows=1, cols=3)
        table.style = 'Table Grid'
        
        # Заполнение шапки (левая, средняя, правая ячейки)
        # ... код форматирования шапки
        
        # Добавление второй строки для вопросов
        row = table.add_row()
        content_cell = row.cells[0].merge(row.cells[1]).merge(row.cells[2])
        
        # Добавление вопросов
        for i, question in enumerate(ticket['theory'], 1):
            p = content_cell.paragraphs[0] if i == 1 else content_cell.add_paragraph()
            run = p.add_run(f"{i}. {question}")
            run.font.size = Pt(12)
        
        # Добавление практических заданий
        if ticket['practice']:
            p = content_cell.add_paragraph()
            run = p.add_run(f"{len(ticket['theory']) + 1}. Практическое задание:")
            run.font.size = Pt(12)
            
            for i, task in enumerate(ticket['practice'], 1):
                p_task = content_cell.add_paragraph()
                run_task = p_task.add_run(f"   {chr(96+i)}) {task}")
                run_task.font.size = Pt(11)
        
        # Подпись преподавателя
        content_cell.add_paragraph()
        sig_para = content_cell.add_paragraph()
        sig_para.add_run('Подпись преподавателя ________________ [ФИО]')
        
        # Разрыв страницы
        if ticket_num < max(tickets.keys()):
            doc.add_page_break()
    
    doc.save(output_path)
```

### Шаг 5: Генерация эталонных ответов

```python
def create_answers_document(questions, answers, output_path):
    """Создает документ с эталонными ответами"""
    doc = Document()
    
    # Заголовок
    title1 = doc.add_paragraph('Приложение 3.')
    title1.runs[0].font.size = Pt(12)
    title1.runs[0].font.bold = True
    
    title2 = doc.add_paragraph('Эталоны ответов на теоретические вопросы')
    title2.runs[0].font.size = Pt(12)
    title2.runs[0].font.bold = True
    
    # Добавление вопросов и ответов
    for i, question in enumerate(questions, 1):
        # Вопрос
        q_para = doc.add_paragraph()
        q_run = q_para.add_run(f'Вопрос {i}. {question}')
        q_run.font.size = Pt(11)
        q_run.font.bold = True
        
        # Ответ
        answer_text = answers.get(question, "Ответ в разработке.")
        a_para = doc.add_paragraph()
        a_run = a_para.add_run(f'Эталон ответа. {answer_text}')
        a_run.font.size = Pt(11)
    
    doc.save(output_path)
```

## Устранение дубликатов вопросов

Часто одинаковые вопросы формулируются по-разному:

```python
def normalize_question(question):
    """Нормализует вопрос для устранения дубликатов"""
    q = question.strip()
    q_lower = q.lower()
    # Убираем служебные слова
    q_lower = q_lower.replace('оператор ', '').replace('операторы ', '')
    return q_lower

def get_unique_questions(tickets):
    """Извлекает уникальные вопросы"""
    questions = []
    seen = set()
    
    for ticket in tickets.values():
        for question in ticket['theory']:
            normalized = normalize_question(question)
            if normalized not in seen:
                seen.add(normalized)
                questions.append(question)
    
    return questions
```

## Извлечение текста из Word

Если исходные данные в .docx:

```python
import zipfile
import xml.etree.ElementTree as ET

def extract_text_from_docx(docx_path):
    """Извлекает текст из Word документа"""
    namespace = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    with zipfile.ZipFile(docx_path) as docx:
        xml_content = docx.read('word/document.xml')
        tree = ET.XML(xml_content)
        
        paragraphs = []
        for paragraph in tree.iter('{...}p'):
            texts = [
                node.text 
                for node in paragraph.iter('{...}t') 
                if node.text
            ]
            if texts:
                paragraphs.append(''.join(texts))
        
        return '\n'.join(paragraphs)
```

## Требования

- Python 3.8+
- python-docx (для работы с Word)

```bash
pip install python-docx
```

## Примеры использования

### Пример 1: Базовая генерация

```python
# Парсинг вопросов
tickets = parse_markdown_tickets('questions.md')

# Создание билетов
org_info = {
    'name': 'ГБПОУ ПК им. П. А. ОВЧИННИКОВА',
    'speciality': '09.02.07 Информационные системы и программирование',
    'subject': 'Название дисциплины'
}
create_tickets_document(tickets, 'tickets.docx', org_info)

# Создание эталонов ответов
questions = get_unique_questions(tickets)
answers = {...}  # Словарь с ответами
create_answers_document(questions, answers, 'answers.docx')
```

### Пример 2: С извлечением из Word

```python
# Извлечение из существующего документа
text = extract_text_from_docx('source.docx')

# Дальнейшая обработка
# ...
```

## Типичные проблемы и решения

### Проблема: Файл открыт в Word

```
PermissionError: [Errno 13] Permission denied
```

**Решение:** Закрыть файл перед запуском скрипта.

### Проблема: Дубликаты вопросов

**Решение:** Использовать функцию `normalize_question()` для устранения.

### Проблема: Неправильное форматирование таблицы

**Решение:** 
- Установить явные ширины столбцов
- Использовать `merge()` для объединения ячеек
- Проверить стиль таблицы

## Советы

1. **Всегда сохраняйте резервные копии** исходных документов
2. **Проверяйте результат** перед массовой генерацией
3. **Используйте образцы** для точного соответствия формату
4. **Нормализуйте вопросы** для устранения дубликатов
5. **Кодировка UTF-8** обязательна для русского текста

## Адаптация под конкретные требования

При использовании навыка:

1. Попросите пользователя предоставить **образец билета**
2. Изучите структуру таблицы и форматирование
3. Уточните требования к шапке документа
4. Спросите о специфичных элементах (подписи, штампы)
5. Адаптируйте код под конкретные нужды

## Расширения

Навык можно расширить для:

- Генерации протоколов экзаменов
- Создания ведомостей оценивания
- Формирования отчётов по результатам
- Экспорта в другие форматы (PDF)

---

**Автор навыка:** Создан на основе практического опыта генерации КИМ  
**Версия:** 1.0  
**Дата:** 2026-06-22
