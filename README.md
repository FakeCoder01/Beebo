# Beebo Compiler-Interpreter

Beebo is a small procedural programming language and a compiler-interpreter written in OCaml. The project was prepared for a compiler construction laboratory work: it contains a finite-state lexical analyzer, an LL(1) table-driven parser, an OPS/RPN intermediate-code generator, and a stack-based interpreter.

The repository is designed to be easy to check by a laboratory teacher. The source code demonstrates all main compiler stages, while the `docs/` and `examples/` folders provide the formal material and test programs required for the report.

---

---

## Documentation Language / Язык документации

Click a language title to open or close the documentation section.

<details open>
<summary><strong>🇬🇧 English Documentation</strong></summary>

## English Documentation

### 1. Project Goal

The goal of Beebo is to translate and execute programs written in the `.bbo` language.

The implementation follows the classic compiler pipeline:

1. Lexical analysis: source text is converted into a list of lexemes/tokens.
2. Syntax analysis: tokens are parsed by a predictive parser using a parse table.
3. Semantic actions: parser productions generate OPS/RPN instructions.
4. Interpretation: OPS instructions are executed by a stack machine.

This structure matches the practical work requirements:

| Requirement | Beebo implementation |
|---|---|
| Lexical analyzer | `src/lexer.ml`, finite-state machine and transition table |
| Lexeme table | `docs/lexemes.txt` |
| Grammar | `src/grammar.ml`, `docs/grammar.txt` |
| Parser table | `src/grammar.ml`, `parse_table` |
| Store/pushdown automaton | `src/parser.ml`, task stack with `MATCH`, `PARSE`, `ACTION` |
| OPS/RPN generation | `src/parser.ml`, semantic actions |
| OPS interpreter | `src/interpreter.ml` |
| Test programs | `examples/*.bbo` |
| Error diagnostics | line/column lexical and syntax messages |

### 2. Repository Structure

```text
beebo/
  Dockerfile
  Makefile
  README.md
  docs/
    beebo_compiler_lab_workbook.xlsx
    grammar.txt
    lexemes.txt
    ops.txt
  examples/
    demo.bbo
    formula.bbo
    sort_array.bbo
    schema_test.bbo
    block_comment.bbo
    exponent_real.bbo
    schema_name.bbo
    ...
  src/
    types.ml
    lexer.ml
    grammar.ml
    parser.ml
    interpreter.ml
    main.ml
```

### 3. Build and Run

#### Docker build

Docker is the most reliable way to run the project on Windows, Linux, or macOS.

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
```

#### Local OCaml build

Requires OCaml 4.13+.

```bash
make build
./src/beebo examples/demo.bbo
```

#### Show lexemes

```bash
docker run --rm beebo --tokens examples/demo.bbo
```

#### Show generated OPS/RPN

```bash
docker run --rm beebo --ops examples/demo.bbo
```

#### Run a program with input

Linux/macOS:

```bash
printf "10\n" | docker run --rm -i beebo examples/formula.bbo
```

Windows `cmd`:

```cmd
type input.txt | docker run --rm -i beebo examples/formula.bbo
```

### 4. Language Overview

Beebo is dynamically typed. Variables do not require declarations. A value can be an integer, real number, string, array, matrix, or schema object.

#### Variables and assignment

```beebo
x = 42;
pi = 3.14159;
name = "Beebo"
```

#### Arithmetic

```beebo
result = (a + b) * c - 10 / 2;
negative = -result
```

Supported arithmetic operators:

| Operator | Meaning |
|---|---|
| `+` | addition or string concatenation |
| `-` | subtraction or unary minus |
| `*` | multiplication |
| `/` | division, result is real |

Real literals support decimal and scientific notation:

```beebo
a = 3.14;
b = 1e3;
c = 2.5e-1
```

#### Strings

```beebo
message = "Hello, " + "world\n";
output message
```

Supported escape sequences:

| Escape | Meaning |
|---|---|
| `\n` | newline |
| `\t` | tab |
| `\\` | backslash |
| `\"` | double quote |

#### Input and output

`input` reads one line. The interpreter tries to convert it as integer, then real, then string.

```beebo
output "Enter x: ";
input x;
output "x * 2 = " + (x * 2) + "\n"
```

Input is also cleaned from a UTF-8 BOM, which is useful when input files are produced on Windows.

#### Semicolons

Semicolons are statement separators, not mandatory terminators. Use `;` between statements in the same block. The final statement before `}` or EOF does not need `;`.

```beebo
x = 5;
y = 10;
output x + y
```

After a block, use `;` before the next statement:

```beebo
while (i < 5) {
  output i;
  i = i + 1
};
output "\n"
```

#### Conditions

```beebo
if (x >= 10) {
  output "large\n"
} else {
  output "small\n"
}
```

Comparison and logical operators:

| Operator | Meaning |
|---|---|
| `<`, `>`, `<=`, `>=` | numeric comparison |
| `==`, `!=` | equality and inequality |
| `&&` | logical AND |
| `||` | logical OR |
| `!` | logical NOT |

#### Loops

```beebo
i = 0;
while (i < 5) {
  output i + " ";
  i = i + 1
}
```

```beebo
for (i = 0; i < 10; i = i + 1) {
  output i + " "
}
```

#### Arrays and matrices

Arrays are dynamic. They can be declared explicitly or created on first assignment.

```beebo
arr[5];
arr[0] = 10;
arr[1] = 20;
output arr[0] + arr[1]
```

Two-dimensional arrays are supported:

```beebo
mat[3][3];
mat[0][0] = 1;
mat[1][2] = 5;
output mat[1][2]
```

#### Functions

```beebo
func square(x) {
  return x * x
};

func factorial(n) {
  if (n <= 1) {
    return 1
  };
  return n * factorial(n - 1)
};

output square(5);
output "\n";
output factorial(5)
```

User-defined functions support parameters, return values, nested calls, and recursion.

#### Built-in functions

Math and conversion functions:

| Function | Description |
|---|---|
| `sqrt(x)` | square root |
| `exp(x)` | exponential function |
| `log(x)` | natural logarithm |
| `sin(x)` | sine in radians |
| `cos(x)` | cosine in radians |
| `abs(x)` | absolute value |
| `string(x)` | convert to string |
| `real(x)` | convert to real |
| `integer(x)` | convert to integer |

Terminal-oriented built-ins:

| Function | Description |
|---|---|
| `sleep(ms)` | pause execution |
| `clear_screen()` | clear terminal |
| `move_cursor(x, y)` | move cursor |
| `get_key()` | read one key if available |
| `cursor_hide()` / `cursor_show()` | hide or show cursor |
| `set_color(fg)` / `set_color(fg, bg)` | set ANSI colors |
| `reset_color()` | reset colors |
| `term_width()` / `term_height()` | terminal size |

#### Schemas

Schemas are simple structured objects similar to records or structs.

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

Schema definitions use semicolons between field names. Schema literals use colon/comma syntax.

```beebo
schema Student {
  name;
  age;
  marks
};

s = Student{name: "Alice", age: 20, marks: 95}
```

The generated OPS now preserves the schema type name:

```text
PUSH_ADDR Point
PUSH_STR "x"
PUSH_INT 10
PUSH_STR "y"
PUSH_INT 20
MAKE_SCHEMA Point
```

### 5. Compiler Architecture

#### 5.1 Lexical analyzer

File: `src/lexer.ml`

The lexer is implemented as a finite-state machine. The transition table maps:

```text
(state, character_class) -> next_state
```

Main states:

| State | Meaning |
|---|---|
| `S_START` | initial state |
| `S_ID` | identifier or keyword |
| `S_NUM` | integer part |
| `S_REAL_FRAC` | real number |
| `S_STRING` | string literal |
| `S_OP` | operator or delimiter |
| `S_COMMENT_LINE` | `//` comment |
| `S_COMMENT_BLOCK` | `/* ... */` comment |
| `S_COMMENT_BLOCK_END` | possible end of block comment |
| `S_ERROR` | lexical error |

The lexer supports:

- identifiers and keywords;
- integer and real literals;
- scientific notation such as `1e10` and `2.5e-1`;
- string literals with escape sequences;
- single-line and multi-line comments;
- line/column diagnostics.

#### 5.2 Grammar and parse table

Files: `src/grammar.ml`, `docs/grammar.txt`

The grammar is left-factored and suitable for LL(1) predictive parsing. The parser table maps:

```text
(nonterminal, lookahead_terminal) -> production_id
```

The grammar uses helper nonterminals such as:

- `ExprTail` for `+` and `-`;
- `TermTail` for `*` and `/`;
- `ArgListTail` for function arguments;
- `FieldInitTail` for schema literal fields.

This avoids left recursion and keeps expression precedence explicit.

#### 5.3 Parser and semantic actions

File: `src/parser.ml`

The parser is table-driven. It uses a task stack:

| Task | Meaning |
|---|---|
| `TASK_MATCH token` | match a terminal token |
| `TASK_PARSE nonterminal` | expand a nonterminal using the parse table |
| `TASK_ACTION f` | execute a semantic action |

Semantic actions generate OPS instructions while parsing. For example:

```beebo
x = a + b * 2
```

is translated into stack-machine operations similar to:

```text
PUSH_ADDR x
PUSH_ADDR a
LOAD
PUSH_ADDR b
LOAD
PUSH_INT 2
MUL
ADD
STORE
HALT
```

#### 5.4 OPS interpreter

File: `src/interpreter.ml`

OPS is a stack-based intermediate representation. The interpreter keeps:

- an instruction pointer;
- a data stack;
- a memory table;
- a label table for jumps;
- a function table for user-defined functions.

Important instruction groups:

| Group | Instructions |
|---|---|
| Constants and memory | `PUSH_INT`, `PUSH_REAL`, `PUSH_STR`, `PUSH_ADDR`, `LOAD`, `STORE` |
| Arithmetic | `ADD`, `SUB`, `MUL`, `DIV`, `NEG` |
| Logic and comparison | `EQ`, `NE`, `LT`, `GT`, `LE`, `GE`, `AND`, `OR`, `NOT` |
| Control flow | `LABEL`, `JMP`, `JMPF`, `HALT` |
| Functions | `FUNC_ENTRY`, `CALL_USER`, `ARG`, `RET` |
| Schemas | `MAKE_SCHEMA`, `GET_FIELD`, `SET_FIELD` |
| Arrays | `ALLOC_ARR`, `INDEX`, `INDEX2` |
| I/O | `INPUT_STR`, `OUTPUT` |

Runtime errors are printed to stderr and the program exits with code `1`.

### 6. Diagnostics

Lexical and syntax errors include line and column information:

```text
=== SYNTAX ERRORS ===
Syntax error at line 6, col 15: expected ')', got ';' (';')
Parsing failed. Fix errors and try again.
```

Unterminated block comments also report their starting position:

```text
Unterminated block comment at line 3, col 5
```

### 7. Examples and Tests

Recommended checks:

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
docker run --rm beebo examples/block_comment.bbo
docker run --rm beebo examples/exponent_real.bbo
docker run --rm beebo examples/schema_name.bbo
docker run --rm beebo --ops examples/schema_name.bbo
```

Input examples:

```bash
printf "10\n" | docker run --rm -i beebo examples/formula.bbo
printf "5\n3\n1\n4\n2\n5\n" | docker run --rm -i beebo examples/sort_array.bbo
```

Local test targets:

```bash
make test-all
```

`examples/error.bbo` is an expected negative test. It should produce syntax errors and exit with code `1`.

### 8. Recent Fixes

The current version includes the following corrections:

| Area | Fix |
|---|---|
| Block comments | Multi-line `/* ... */` comments now handle newlines correctly |
| Real literals | Scientific notation is supported, for example `1e3`, `2.5e-1` |
| Schema literals | `MAKE_SCHEMA` preserves the real schema name |
| Runtime errors | Runtime failures now return exit code `1` |
| Windows input | UTF-8 BOM is stripped from input lines before numeric conversion |
| Grammar helpers | Redundant and partial pattern matches were cleaned up |
| Tests | Makefile test targets were made more deterministic |
| Documentation | Grammar, lexeme, and schema literal documentation were synchronized with code |

### 9. Known Limitations

- The language is dynamically typed; there is no static type checker.
- The parser is LL(1) and table-driven, but the documented grammar is an implementation grammar with helper nonterminals, not a mathematically strict Greibach-only listing.
- Terminal control functions depend on ANSI terminal behavior.
- Arrays grow dynamically and perform forgiving reads for out-of-range values.

</details>

<details>
<summary><strong>🇷🇺 Русская Документация</strong></summary>

## Русская Документация

### 1. Цель проекта

Beebo — это небольшой процедурный язык программирования и компилятор-интерпретатор, написанный на OCaml. Проект подготовлен для лабораторной работы по теме компиляторов: в нем реализованы лексический анализатор на конечном автомате, табличный LL(1)-синтаксический анализатор, генератор ОПС/обратной польской записи и стековый интерпретатор.

Основная цель проекта — выполнить перевод и исполнение программ на языке `.bbo`.

Общая цепочка обработки:

1. Лексический анализ: исходный текст преобразуется в список лексем.
2. Синтаксический анализ: список лексем разбирается табличным предиктивным анализатором.
3. Семантические действия: при применении продукций генерируется ОПС.
4. Интерпретация: ОПС выполняется стековой машиной.

Соответствие требованиям лабораторной работы:

| Требование | Реализация в Beebo |
|---|---|
| Лексический анализатор | `src/lexer.ml`, конечный автомат и таблица переходов |
| Таблица лексем | `docs/lexemes.txt` |
| Грамматика | `src/grammar.ml`, `docs/grammar.txt` |
| Таблица разбора | `src/grammar.ml`, `parse_table` |
| Магазинный автомат | `src/parser.ml`, стек задач `MATCH`, `PARSE`, `ACTION` |
| Генерация ОПС | `src/parser.ml`, семантические действия |
| Интерпретатор ОПС | `src/interpreter.ml` |
| Тестовые программы | `examples/*.bbo` |
| Диагностика ошибок | сообщения с номером строки и столбца |

### 2. Структура проекта

```text
beebo/
  Dockerfile
  Makefile
  README.md
  docs/
    beebo_compiler_lab_workbook.xlsx
    grammar.txt
    lexemes.txt
    ops.txt
  examples/
    demo.bbo
    formula.bbo
    sort_array.bbo
    schema_test.bbo
    block_comment.bbo
    exponent_real.bbo
    schema_name.bbo
    ...
  src/
    types.ml
    lexer.ml
    grammar.ml
    parser.ml
    interpreter.ml
    main.ml
```

### 3. Сборка и запуск

#### Сборка через Docker

Docker является самым надежным способом запуска проекта на Windows, Linux и macOS.

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
```

#### Локальная сборка OCaml

Требуется OCaml 4.13+.

```bash
make build
./src/beebo examples/demo.bbo
```

#### Вывод списка лексем

```bash
docker run --rm beebo --tokens examples/demo.bbo
```

#### Вывод сгенерированной ОПС

```bash
docker run --rm beebo --ops examples/demo.bbo
```

#### Запуск программы с входными данными

Linux/macOS:

```bash
printf "10\n" | docker run --rm -i beebo examples/formula.bbo
```

Windows `cmd`:

```cmd
type input.txt | docker run --rm -i beebo examples/formula.bbo
```

### 4. Обзор языка

Beebo использует динамическую типизацию. Переменные не требуют предварительного объявления. Значение может быть целым числом, вещественным числом, строкой, массивом, матрицей или объектом схемы.

#### Переменные и присваивание

```beebo
x = 42;
pi = 3.14159;
name = "Beebo"
```

#### Арифметика

```beebo
result = (a + b) * c - 10 / 2;
negative = -result
```

Поддерживаемые операции:

| Оператор | Значение |
|---|---|
| `+` | сложение или конкатенация строк |
| `-` | вычитание или унарный минус |
| `*` | умножение |
| `/` | деление, результат вещественный |

Вещественные литералы поддерживают десятичную и экспоненциальную форму:

```beebo
a = 3.14;
b = 1e3;
c = 2.5e-1
```

#### Строки

```beebo
message = "Hello, " + "world\n";
output message
```

Поддерживаемые escape-последовательности:

| Escape | Значение |
|---|---|
| `\n` | новая строка |
| `\t` | табуляция |
| `\\` | обратная косая черта |
| `\"` | двойная кавычка |

#### Ввод и вывод

`input` читает одну строку. Интерпретатор пытается преобразовать ее сначала в целое число, затем в вещественное, затем оставляет как строку.

```beebo
output "Enter x: ";
input x;
output "x * 2 = " + (x * 2) + "\n"
```

Перед преобразованием входная строка очищается от UTF-8 BOM, что полезно при работе с файлами ввода, созданными на Windows.

#### Точки с запятой

Точка с запятой является разделителем операторов, а не обязательным завершителем каждой строки. Ее нужно ставить между операторами одного блока. Последний оператор перед `}` или концом файла может быть без `;`.

```beebo
x = 5;
y = 10;
output x + y
```

После блока перед следующим оператором используется `;`:

```beebo
while (i < 5) {
  output i;
  i = i + 1
};
output "\n"
```

#### Условия

```beebo
if (x >= 10) {
  output "large\n"
} else {
  output "small\n"
}
```

Операторы сравнения и логические операторы:

| Оператор | Значение |
|---|---|
| `<`, `>`, `<=`, `>=` | числовое сравнение |
| `==`, `!=` | равенство и неравенство |
| `&&` | логическое И |
| `||` | логическое ИЛИ |
| `!` | логическое НЕ |

#### Циклы

```beebo
i = 0;
while (i < 5) {
  output i + " ";
  i = i + 1
}
```

```beebo
for (i = 0; i < 10; i = i + 1) {
  output i + " "
}
```

#### Массивы и матрицы

Массивы являются динамическими. Их можно объявлять явно или создавать при первом присваивании.

```beebo
arr[5];
arr[0] = 10;
arr[1] = 20;
output arr[0] + arr[1]
```

Двумерные массивы также поддерживаются:

```beebo
mat[3][3];
mat[0][0] = 1;
mat[1][2] = 5;
output mat[1][2]
```

#### Функции

```beebo
func square(x) {
  return x * x
};

func factorial(n) {
  if (n <= 1) {
    return 1
  };
  return n * factorial(n - 1)
};

output square(5);
output "\n";
output factorial(5)
```

Пользовательские функции поддерживают параметры, возвращаемые значения, вложенные вызовы и рекурсию.

#### Встроенные функции

Математические функции и преобразования типов:

| Функция | Описание |
|---|---|
| `sqrt(x)` | квадратный корень |
| `exp(x)` | экспонента |
| `log(x)` | натуральный логарифм |
| `sin(x)` | синус в радианах |
| `cos(x)` | косинус в радианах |
| `abs(x)` | модуль |
| `string(x)` | преобразование в строку |
| `real(x)` | преобразование в вещественное число |
| `integer(x)` | преобразование в целое число |

Терминальные функции:

| Функция | Описание |
|---|---|
| `sleep(ms)` | пауза выполнения |
| `clear_screen()` | очистка терминала |
| `move_cursor(x, y)` | перемещение курсора |
| `get_key()` | чтение одной клавиши, если она доступна |
| `cursor_hide()` / `cursor_show()` | скрыть или показать курсор |
| `set_color(fg)` / `set_color(fg, bg)` | установка ANSI-цветов |
| `reset_color()` | сброс цветов |
| `term_width()` / `term_height()` | размеры терминала |

#### Схемы

Схемы — это простые структурированные объекты, похожие на записи или структуры.

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

В определении схемы поля разделяются точкой с запятой. В литерале схемы используется синтаксис `поле: значение`, а поля разделяются запятыми.

```beebo
schema Student {
  name;
  age;
  marks
};

s = Student{name: "Alice", age: 20, marks: 95}
```

Сгенерированная ОПС сохраняет имя типа схемы:

```text
PUSH_ADDR Point
PUSH_STR "x"
PUSH_INT 10
PUSH_STR "y"
PUSH_INT 20
MAKE_SCHEMA Point
```

### 5. Архитектура компилятора

#### 5.1 Лексический анализатор

Файл: `src/lexer.ml`

Лексер реализован как конечный автомат. Таблица переходов имеет вид:

```text
(состояние, класс_символа) -> новое_состояние
```

Основные состояния:

| Состояние | Значение |
|---|---|
| `S_START` | начальное состояние |
| `S_ID` | идентификатор или ключевое слово |
| `S_NUM` | целая часть числа |
| `S_REAL_FRAC` | вещественное число |
| `S_STRING` | строковый литерал |
| `S_OP` | оператор или разделитель |
| `S_COMMENT_LINE` | комментарий `//` |
| `S_COMMENT_BLOCK` | комментарий `/* ... */` |
| `S_COMMENT_BLOCK_END` | возможное завершение блочного комментария |
| `S_ERROR` | лексическая ошибка |

Лексер поддерживает:

- идентификаторы и ключевые слова;
- целые и вещественные литералы;
- экспоненциальную запись чисел, например `1e10` и `2.5e-1`;
- строковые литералы с escape-последовательностями;
- однострочные и многострочные комментарии;
- диагностику с номером строки и столбца.

#### 5.2 Грамматика и таблица разбора

Файлы: `src/grammar.ml`, `docs/grammar.txt`

Грамматика факторизована и подходит для LL(1)-предиктивного разбора. Таблица разбора имеет вид:

```text
(нетерминал, текущий_терминал) -> номер_продукции
```

Для устранения левой рекурсии и сохранения приоритетов используются вспомогательные нетерминалы:

- `ExprTail` для `+` и `-`;
- `TermTail` для `*` и `/`;
- `ArgListTail` для списка аргументов;
- `FieldInitTail` для полей литерала схемы.

#### 5.3 Парсер и семантические действия

Файл: `src/parser.ml`

Парсер является табличным. Он использует стек задач:

| Задача | Значение |
|---|---|
| `TASK_MATCH token` | сопоставить терминальный символ |
| `TASK_PARSE nonterminal` | раскрыть нетерминал по таблице разбора |
| `TASK_ACTION f` | выполнить семантическое действие |

Семантические действия генерируют ОПС во время разбора.

Пример:

```beebo
x = a + b * 2
```

соответствует последовательности:

```text
PUSH_ADDR x
PUSH_ADDR a
LOAD
PUSH_ADDR b
LOAD
PUSH_INT 2
MUL
ADD
STORE
HALT
```

#### 5.4 Интерпретатор ОПС

Файл: `src/interpreter.ml`

ОПС — это стековое промежуточное представление. Интерпретатор хранит:

- указатель текущей инструкции;
- стек данных;
- таблицу памяти;
- таблицу меток;
- таблицу пользовательских функций.

Основные группы инструкций:

| Группа | Инструкции |
|---|---|
| Константы и память | `PUSH_INT`, `PUSH_REAL`, `PUSH_STR`, `PUSH_ADDR`, `LOAD`, `STORE` |
| Арифметика | `ADD`, `SUB`, `MUL`, `DIV`, `NEG` |
| Логика и сравнение | `EQ`, `NE`, `LT`, `GT`, `LE`, `GE`, `AND`, `OR`, `NOT` |
| Управление | `LABEL`, `JMP`, `JMPF`, `HALT` |
| Функции | `FUNC_ENTRY`, `CALL_USER`, `ARG`, `RET` |
| Схемы | `MAKE_SCHEMA`, `GET_FIELD`, `SET_FIELD` |
| Массивы | `ALLOC_ARR`, `INDEX`, `INDEX2` |
| Ввод/вывод | `INPUT_STR`, `OUTPUT` |

При runtime-ошибке сообщение выводится в stderr, а программа завершается с кодом `1`.

### 6. Диагностика ошибок

Лексические и синтаксические ошибки содержат номер строки и столбца:

```text
=== SYNTAX ERRORS ===
Syntax error at line 6, col 15: expected ')', got ';' (';')
Parsing failed. Fix errors and try again.
```

Незавершенный блочный комментарий сообщает позицию начала комментария:

```text
Unterminated block comment at line 3, col 5
```

### 7. Примеры и тесты

Рекомендуемые проверки:

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
docker run --rm beebo examples/block_comment.bbo
docker run --rm beebo examples/exponent_real.bbo
docker run --rm beebo examples/schema_name.bbo
docker run --rm beebo --ops examples/schema_name.bbo
```

Примеры с входными данными:

```bash
printf "10\n" | docker run --rm -i beebo examples/formula.bbo
printf "5\n3\n1\n4\n2\n5\n" | docker run --rm -i beebo examples/sort_array.bbo
```

Локальные цели Makefile:

```bash
make test-all
```

`examples/error.bbo` является отрицательным тестом. Он должен вывести синтаксические ошибки и завершиться с кодом `1`.

### 8. Последние исправления

| Область | Исправление |
|---|---|
| Блочные комментарии | Многострочные комментарии `/* ... */` теперь корректно обрабатывают переносы строк |
| Вещественные литералы | Добавлена поддержка экспоненциальной записи: `1e3`, `2.5e-1` |
| Схемы | `MAKE_SCHEMA` сохраняет имя типа схемы |
| Runtime-ошибки | Ошибки выполнения теперь возвращают код выхода `1` |
| Ввод на Windows | UTF-8 BOM удаляется перед числовым преобразованием |
| Грамматика | Удалены избыточные и неполные pattern matching случаи |
| Тесты | Цели Makefile стали более детерминированными |
| Документация | Описание грамматики, лексем и схем синхронизировано с кодом |

### 9. Известные ограничения

- Язык динамически типизирован; статического контроля типов нет.
- Парсер является LL(1) и табличным, но документированная грамматика является реализационной грамматикой со вспомогательными нетерминалами, а не строго математической формой только Грейбах.
- Терминальные функции зависят от поддержки ANSI-последовательностей.
- Массивы расширяются динамически, а чтение за пределами массива выполняется в мягком режиме.

</details>
