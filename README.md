# Beebo - An Interpreter in OCaml

Beebo (`.bbo`) is a simple procedural programming language with a table-driven compiler-interpreter written in OCaml. It features a **finite-state-machine lexical analyzer**, an **LL(1) predictive parser** using a **parse table**, an **OPS/RPN generator**, and a **stack-machine OPS interpreter**.

## Quick Start

### Local Build (requires OCaml 4.13+)

```bash
make build
```

**Check examples**

```bash
./src/beebo examples/demo.bbo
./src/beebo --tokens examples/demo.bbo # shows lexemes
./src/beebo --ops examples/demo.bbo    # shows generated OPS
```

### Docker

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
echo "42" | docker run --rm -i beebo examples/formula.bbo
```

> See `docs/` for the grammar, lexeme table, transition table, OPS description, and the Excel laboratory workbook.

---

## Language Syntax

### Variables

No type declarations are needed. Variables can hold integers, reals, strings, arrays, matrices, or schema objects dynamically.

```beebo
x = 42
pi = 3.14159
name = "Beebo"
```

### Arithmetic

Operators use standard precedence: `*`, `/` higher than `+`, `-`. Parentheses override precedence. Division always produces a **real** result.

```beebo
result = (a + b) * (c - d) / e
neg = -x * y
```

Real literals support both decimal notation and scientific notation:

```beebo
a = 3.14
b = 1e3
c = 2.5e-1
```

### Strings

- String literals use double quotes.
- Escape sequences: `\n` newline, `\\` backslash, `\"` quote, `\t` tab.
- Strings can be concatenated with `+`.
- Numbers are automatically converted to strings during string concatenation.

```beebo
greeting = "Hello, " + "World"
output "Line 1\nLine 2"
output "Value: " + x
```

### Output

`output` prints a value without adding a newline. Use `\n` in strings for line breaks.

```beebo
output "Hello\n"
output x
output "x = " + x + "\n"
```

### Input

`input` reads one line and tries to parse it as **integer** -> **real** -> **string**.

```beebo
input x
input arr[0]
```

Input lines are trimmed before conversion. UTF-8 BOM at the beginning of input is also ignored, which makes file-based input safer on Windows.

### Semicolons

Semicolons are **statement separators**. Place `;` between statements in the same block. The last statement before `}` or EOF does **not** need `;`.

```beebo
x = 5;
y = 10;
output x + y
```

After a block (`}`), use `;` before the next statement:

```beebo
while (i < n) {
  output arr[i];
  i = i + 1
};
output "Done\n"
```

### Arrays

1D and 2D dynamic arrays are supported. Arrays can be explicitly allocated or created on first assignment.

**1D arrays**

```beebo
arr[5]
arr[n]
arr[0] = 42
x = arr[3]
```

**2D arrays**

```beebo
mat[3][4]
mat[0][0] = 10
mat[1][2] = 20
x = mat[0][0]
```

### Schema (like structs)

Schemas define structured values with named fields.

```beebo
schema Point {
    x;
    y
};

p = Point{x: 10, y: 20};
output p.x;
p.x = 42;
output p
```

- **Definition**: `schema Name { field1; field2; };`
- **Literal**: `Name{ field: value, ... }`
- **Access**: `obj.field`
- **Assignment**: `obj.field = value`

Fields are separated by semicolons in schema definitions and by commas in schema literals. The generated OPS now preserves the schema type name, for example `MAKE_SCHEMA Point`.

### Conditionals

```beebo
if (score >= 90) {
  output "Grade: A\n"
}

if (x > y) {
  output "greater\n"
} else {
  output "not greater\n"
}
```

Compound conditions use `&&`, `||`, and `!`.

```beebo
if (a > 0 && b > 0) {
  output "both positive\n"
}
```

Comparison operators: `<`, `>`, `<=`, `>=`, `==`, `!=`.

### Loops

**While loop**

```beebo
i = 0
while (i < 10) {
  output i;
  output "\n";
  i = i + 1
}
```

**For loop**

```beebo
for (i = 0; i < 10; i = i + 1) {
  output i + " "
}
```

### Functions

User-defined functions have parameters and return values.

```beebo
func square(x) {
  return x * x
}

func add(a, b) {
  return a + b
}

func factorial(n) {
  if (n <= 1) {
    return 1
  };
  return n * factorial(n - 1)
}

output square(5);
output "\n";
output add(3, 4);
output "\n";
output factorial(5)
```

Functions can have zero or more parameters. Functions can call themselves recursively.

Functions can also be called as statements when the return value is ignored:

```beebo
greet("Beebo")
```

### Built-in Functions

**Math**

- `sqrt(x)` - square root
- `exp(x)` - e^x
- `log(x)` - natural logarithm
- `sin(x)` - sine in radians
- `cos(x)` - cosine in radians
- `abs(x)` - absolute value

**Type conversion**

- `string(x)` - convert any value to string
- `real(x)` - convert to real
- `integer(x)` - convert to integer

```beebo
x = sqrt(25.0)
y = string(42)
z = real("3.14")
w = integer(3.9)
```

**Terminal control**

- `sleep(ms)` - pause for `ms` milliseconds
- `clear_screen()` - clear terminal
- `move_cursor(x, y)` - move cursor to column `x`, row `y`
- `get_key()` - non-blocking single-key read
- `cursor_hide()` / `cursor_show()` - hide/show terminal cursor
- `set_color(fg)` / `set_color(fg, bg)` - set text/background colors
- `reset_color()` - reset colors
- `term_width()` / `term_height()` - terminal size

```beebo
clear_screen();
move_cursor(10, 5);
set_color(2);
output "Green text at (10,5)\n";
reset_color()
```

### Comments

```beebo
// Single line comment
/* Multi-line
comment */
```

Multi-line block comments are supported and can span several physical lines.

---

## Architecture

The compiler-interpreter follows the classic **analysis-synthesis** model.

### 1. Lexical Analyzer (`lexer.ml`)

The lexer is a finite-state machine with an explicit transition table:

```text
(state, character_class) -> next_state
```

Main properties:

- states for identifiers, numbers, real literals, strings, operators, line comments, block comments, and errors;
- keyword resolution after identifier tokenization;
- string escape handling;
- decimal and scientific real literals such as `3.14`, `1e3`, `2.5e-1`;
- line/column diagnostics for lexical errors.

### 2. Grammar and Parse Table (`grammar.ml`)

The implementation grammar is an **LL(1)-factored grammar** used by a predictive parser.

Important notes:

- the grammar is stored as numbered productions;
- the parse table maps `(nonterminal, terminal)` to a production id;
- expression grammar is left-factored with helper nonterminals such as `ExprTail` and `TermTail`;
- `docs/grammar.txt` and the Excel workbook contain the laboratory grammar artifacts, including a Greibach-style representation.

### 3. Parser and OPS Generator (`parser.ml`)

The parser uses a task stack:

- `MATCH` tasks match terminal tokens;
- `PARSE` tasks expand nonterminals through the parse table;
- `ACTION` tasks execute semantic actions.

Semantic actions generate OPS/RPN instructions while parsing.

Examples:

- assignment emits address, expression, and `STORE`;
- `if` and `while` emit labels and jumps;
- function definitions emit `FUNC_ENTRY`, `ARG`, and `RET`;
- schema literals emit `MAKE_SCHEMA <type_name>`.

### 4. OPS Interpreter (`interpreter.ml`)

The interpreter executes a stack-machine intermediate representation.

Instruction groups:

- **Memory**: `PUSH_INT`, `PUSH_REAL`, `PUSH_STR`, `PUSH_ADDR`, `LOAD`, `STORE`
- **Arrays**: `ALLOC_ARR`, `INDEX`, `INDEX2`
- **Schemas**: `MAKE_SCHEMA`, `GET_FIELD`, `SET_FIELD`
- **Arithmetic**: `ADD`, `SUB`, `MUL`, `DIV`, `NEG`
- **Comparison**: `EQ`, `NE`, `LT`, `GT`, `LE`, `GE`
- **Logic**: `AND`, `OR`, `NOT`
- **Control flow**: `JMP`, `JMPF`, `LABEL`
- **Functions**: `FUNC_ENTRY`, `CALL_USER`, `RET`, `ARG`
- **I/O**: `INPUT_STR`, `OUTPUT`
- **Built-ins**: `CALL` and terminal built-ins

Runtime errors are printed to stderr and the process exits with code `1`.

### Data Types

| Type | Description |
|---|---|
| `V_INT(n)` | Integer |
| `V_REAL(r)` | Real number |
| `V_STR(s)` | String |
| `V_ARR(arr)` | 1D array |
| `V_MAT(arr)` | 2D matrix |
| `V_SCHEMA(name, fields)` | Named schema object |

Arithmetic supports automatic int-to-real promotion. String `+` converts non-string operands to strings when needed.

---

## Error Diagnostics

The compiler provides error messages with line and column numbers.

```text
=== SYNTAX ERRORS ===
Syntax error at line 10, col 15: expected ')', got ';' (';')
```

Runtime errors are also reported:

```text
=== RUNTIME ERRORS ===
Runtime error at PC=8: Expected numeric value
```

---

## CLI Options

```text
beebo [options] <file.bbo>
--tokens Print token list after lexical analysis
--ops    Print generated OPS/RPN code
--run    Execute the program (default)
--help   Show help
```

---

## Recent Fixes

The current version includes the following laboratory fixes:

- fixed multi-line `/* ... */` block comments;
- added scientific real literals: `1e3`, `1e10`, `2.5e-1`;
- preserved schema names in generated OPS: `MAKE_SCHEMA Point`;
- cleaned UTF-8 BOM from input before numeric conversion;
- made runtime errors return exit code `1`;
- cleaned grammar helper warnings in `grammar.ml`;
- added regression examples:
  - `examples/block_comment.bbo`
  - `examples/exponent_real.bbo`
  - `examples/schema_name.bbo`
- added a reference-style compiler workbook:
  - `docs/beebo_compiler_lab_workbook.xlsx`

---

## Implementation Notes

### Parse Table

The parse table maps `(nonterminal, terminal)` to `production_id`.

```ocaml
add_set NT_STMT [T_KW_IF] 5
add_set NT_STMT [T_KW_FUNC] 72
```

### OPS Stack Convention

**First pushed = bottom, last pushed = top.**

- `STORE`: pop value, pop address, store value at address
- `INDEX`: pop index, pop base, push array element address
- `GET_FIELD`: pop schema, push field value
- `SET_FIELD`: pop value, pop schema, update field
- `MAKE_SCHEMA`: pop field pairs and type marker, push schema object

---

# Beebo - Интерпретатор на OCaml

Beebo (`.bbo`) - это простой процедурный язык программирования с табличным компилятором-интерпретатором на OCaml. Проект содержит **лексический анализатор на конечном автомате**, **LL(1)-предиктивный синтаксический анализатор** с **таблицей разбора**, **генератор ОПС/обратной польской записи** и **стековый интерпретатор ОПС**.

## Быстрый старт

### Локальная сборка (требуется OCaml 4.13+)

```bash
make build
```

**Проверка примеров**

```bash
./src/beebo examples/demo.bbo
./src/beebo --tokens examples/demo.bbo # показать лексемы
./src/beebo --ops examples/demo.bbo    # показать ОПС
```

### Docker

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
echo "42" | docker run --rm -i beebo examples/formula.bbo
```

> В папке `docs/` находятся грамматика, таблица лексем, таблица переходов, описание ОПС и Excel-файл для лабораторной работы.

---

## Синтаксис языка

### Переменные

Объявления типов не требуются. Переменные могут хранить целые числа, вещественные числа, строки, массивы, матрицы и объекты схем.

```beebo
x = 42
pi = 3.14159
name = "Beebo"
```

### Арифметика

Операторы имеют стандартный приоритет: `*`, `/` выше, чем `+`, `-`. Скобки изменяют порядок вычисления. Деление всегда возвращает **вещественное** значение.

```beebo
result = (a + b) * (c - d) / e
neg = -x * y
```

Вещественные литералы поддерживают обычную десятичную и экспоненциальную запись:

```beebo
a = 3.14
b = 1e3
c = 2.5e-1
```

### Строки

- Строковые литералы записываются в двойных кавычках.
- Escape-последовательности: `\n`, `\\`, `\"`, `\t`.
- Строки можно объединять с помощью `+`.
- Числа автоматически преобразуются в строки при конкатенации.

```beebo
greeting = "Hello, " + "World"
output "Line 1\nLine 2"
output "Value: " + x
```

### Вывод

`output` печатает значение без автоматического переноса строки.

```beebo
output "Hello\n"
output x
output "x = " + x + "\n"
```

### Ввод

`input` читает одну строку и пытается распознать ее как **integer** -> **real** -> **string**.

```beebo
input x
input arr[0]
```

Перед преобразованием вход очищается от пробелов и UTF-8 BOM, что полезно при запуске с файлами на Windows.

### Точки с запятой

Точка с запятой является **разделителем операторов**. Ее нужно ставить между операторами одного блока. Последний оператор перед `}` или EOF может быть без `;`.

```beebo
x = 5;
y = 10;
output x + y
```

После блока (`}`) перед следующим оператором используется `;`:

```beebo
while (i < n) {
  output arr[i];
  i = i + 1
};
output "Done\n"
```

### Массивы

Поддерживаются динамические одномерные и двумерные массивы.

```beebo
arr[5]
arr[n]
arr[0] = 42
x = arr[3]
```

```beebo
mat[3][4]
mat[0][0] = 10
mat[1][2] = 20
x = mat[0][0]
```

### Схемы

Схемы похожи на структуры с именованными полями.

```beebo
schema Point {
    x;
    y
};

p = Point{x: 10, y: 20};
output p.x;
p.x = 42;
output p
```

- **Определение**: `schema Name { field1; field2; };`
- **Литерал**: `Name{ field: value, ... }`
- **Доступ**: `obj.field`
- **Присваивание**: `obj.field = value`

В определении поля разделяются точками с запятой, а в литерале - запятыми. Генератор ОПС сохраняет имя схемы, например `MAKE_SCHEMA Point`.

### Условия

```beebo
if (score >= 90) {
  output "Grade: A\n"
}

if (x > y) {
  output "greater\n"
} else {
  output "not greater\n"
}
```

Составные условия используют `&&`, `||` и `!`.

Операторы сравнения: `<`, `>`, `<=`, `>=`, `==`, `!=`.

### Циклы

```beebo
i = 0
while (i < 10) {
  output i;
  output "\n";
  i = i + 1
}
```

```beebo
for (i = 0; i < 10; i = i + 1) {
  output i + " "
}
```

### Функции

Пользовательские функции имеют параметры и возвращаемые значения.

```beebo
func square(x) {
  return x * x
}

func add(a, b) {
  return a + b
}

func factorial(n) {
  if (n <= 1) {
    return 1
  };
  return n * factorial(n - 1)
}
```

Функции могут быть рекурсивными.

### Встроенные функции

**Математика**

- `sqrt(x)` - квадратный корень
- `exp(x)` - экспонента
- `log(x)` - натуральный логарифм
- `sin(x)` - синус в радианах
- `cos(x)` - косинус в радианах
- `abs(x)` - модуль

**Преобразования типов**

- `string(x)` - преобразовать в строку
- `real(x)` - преобразовать в вещественное число
- `integer(x)` - преобразовать в целое число

**Управление терминалом**

- `sleep(ms)` - пауза
- `clear_screen()` - очистка терминала
- `move_cursor(x, y)` - перемещение курсора
- `get_key()` - неблокирующее чтение клавиши
- `cursor_hide()` / `cursor_show()` - скрыть/показать курсор
- `set_color(fg)` / `set_color(fg, bg)` - установить цвет
- `reset_color()` - сброс цвета
- `term_width()` / `term_height()` - размеры терминала

### Комментарии

```beebo
// Однострочный комментарий
/* Многострочный
комментарий */
```

Многострочные комментарии могут занимать несколько физических строк.

---

## Архитектура

Компилятор-интерпретатор использует классическую модель **анализ-синтез**.

### 1. Лексический анализатор (`lexer.ml`)

Лексер реализован как конечный автомат с таблицей переходов:

```text
(состояние, класс_символа) -> новое_состояние
```

Особенности:

- состояния для идентификаторов, чисел, вещественных литералов, строк, операторов, комментариев и ошибок;
- распознавание ключевых слов после чтения идентификатора;
- обработка escape-последовательностей в строках;
- поддержка `3.14`, `1e3`, `2.5e-1`;
- диагностика с номером строки и столбца.

### 2. Грамматика и таблица разбора (`grammar.ml`)

В реализации используется **LL(1)-факторизованная грамматика**.

Важно:

- грамматика хранится как набор нумерованных продукций;
- таблица разбора задает отображение `(нетерминал, терминал) -> номер продукции`;
- выражения факторизованы через `ExprTail`, `TermTail` и другие вспомогательные нетерминалы;
- `docs/grammar.txt` и Excel workbook содержат учебные артефакты, включая форму в стиле Грейбах.

### 3. Парсер и генератор ОПС (`parser.ml`)

Парсер использует стек задач:

- `MATCH` сопоставляет терминал;
- `PARSE` раскрывает нетерминал через таблицу разбора;
- `ACTION` выполняет семантическое действие.

Семантические действия генерируют ОПС во время разбора.

### 4. Интерпретатор ОПС (`interpreter.ml`)

Интерпретатор выполняет стековое промежуточное представление.

Группы инструкций:

- **Память**: `PUSH_INT`, `PUSH_REAL`, `PUSH_STR`, `PUSH_ADDR`, `LOAD`, `STORE`
- **Массивы**: `ALLOC_ARR`, `INDEX`, `INDEX2`
- **Схемы**: `MAKE_SCHEMA`, `GET_FIELD`, `SET_FIELD`
- **Арифметика**: `ADD`, `SUB`, `MUL`, `DIV`, `NEG`
- **Сравнение**: `EQ`, `NE`, `LT`, `GT`, `LE`, `GE`
- **Логика**: `AND`, `OR`, `NOT`
- **Управление**: `JMP`, `JMPF`, `LABEL`
- **Функции**: `FUNC_ENTRY`, `CALL_USER`, `RET`, `ARG`
- **Ввод/вывод**: `INPUT_STR`, `OUTPUT`

Ошибки выполнения выводятся в stderr, после чего процесс завершается с кодом `1`.

### Типы данных

| Тип | Описание |
|---|---|
| `V_INT(n)` | целое число |
| `V_REAL(r)` | вещественное число |
| `V_STR(s)` | строка |
| `V_ARR(arr)` | одномерный массив |
| `V_MAT(arr)` | двумерная матрица |
| `V_SCHEMA(name, fields)` | объект схемы |

---

## Диагностика ошибок

Компилятор выводит ошибки со строкой и столбцом.

```text
=== SYNTAX ERRORS ===
Syntax error at line 10, col 15: expected ')', got ';' (';')
```

---

## Параметры CLI

```text
beebo [options] <file.bbo>
--tokens показать список лексем
--ops    показать сгенерированную ОПС
--run    выполнить программу (по умолчанию)
--help   показать справку
```

---

## Последние исправления

- исправлены многострочные комментарии `/* ... */`;
- добавлены вещественные литералы в экспоненциальной форме: `1e3`, `1e10`, `2.5e-1`;
- сохранение имени схемы в ОПС: `MAKE_SCHEMA Point`;
- очистка UTF-8 BOM перед преобразованием input;
- runtime-ошибки завершают процесс с кодом `1`;
- исправлены предупреждения в helper-функциях грамматики;
- добавлены regression-примеры:
  - `examples/block_comment.bbo`
  - `examples/exponent_real.bbo`
  - `examples/schema_name.bbo`
- добавлен Excel workbook в стиле лабораторных артефактов:
  - `docs/beebo_compiler_lab_workbook.xlsx`
