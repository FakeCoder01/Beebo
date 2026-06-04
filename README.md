# Beebo - A Interpreter in OCaml

Beebo (`.bbo`) is a simple procedural programming language with a table-driven compiler-interpreter written in OCaml. It features a **finite-state-machine lexical analyzer**, an **LL(1) predictive parser** using a **parse table**, and a **stack-machine OPS interpreter**.

## Quick Start

### Local Build (requires OCaml 4.13+)

```bash
make build
```

**Check examples**

```bash
./src/beebo examples/demo.bbo
./src/beebo --tokens examples/demo.bbo # shows lexemes
./src/beebo --ops examples/demo.bbo # shows generated OPS
```

### Docker

```bash
docker build -t beebo .
docker run --rm beebo examples/demo.bbo
echo "42" | docker run --rm -i beebo examples/demo.bbo
```

> Take a look at `docs/` for a detailed language specification, architecture overview, and implementation notes.

---

## Language Syntax

### Variables

No type declarations needed. Variables hold integers, reals, strings, or schemas dynamically.

```
x = 42
pi = 3.14159
name = "Beebo"
```

### Arithmetic

Operators with standard precedence: `*`, `/` (higher) > `+`, `-` (lower). Parentheses override precedence. Division always produces a **real** result.

```
result = (a + b) * (c - d) / e
neg = -x * y
```

### Strings

- String literals use double quotes. Escape sequences: `\n` (newline), `\\` (backslash), `\"` (quote), `\t` (tab).
- Strings can be concatenated with `+`. Numbers are auto-converted to strings in concatenation.

```
greeting = "Hello, " + "World"
output "Line 1\nLine 2"
output "Value: " + x
```

### Output

`output` prints a value without adding a newline. Use `\n` in strings for line breaks:

```
output "Hello\n"          // prints "Hello" then newline
output x                  // prints value of x
output "x = " + x + "\n"  // concatenated output with newline
```

### Input

`input` reads a line and tries to parse it as **integer** → **real** → **string** (fallback).

```
input x                   // reads into variable
input arr[0]              // reads into array element
```

### Semicolons

Semicolons are **statement separators**. Place `;` between statements in the same block. The last statement before `}` or EOF does **not** need `;`.

```
x = 5;
y = 10;
output x + y // last statement, no ;
```

After a block (`}`), use `;` before the next statement:

```
while (i < n) {
  output arr[i];
  i = i + 1
};
output "Done\n"        // ; separates block from next statement
```

### Arrays

1D and 2D dynamic arrays. Arrays auto-allocate on first assignment; explicit declaration via `name[size]` is optional.

**1D Arrays:**

```
arr[5]                    // declare array of size 5
arr[n]                    // declare array of size n
arr[0] = 42               // assign element
x = arr[3]                // read element
```

**2D Arrays (matrices):**

```
mat[3][4]                 // declare 3x4 matrix (optional)
mat[0][0] = 10            // assign element (auto-allocates if needed)
mat[1][2] = 20
x = mat[0][0]             // read element
```

### Schema (like structs)

Define structured data with named fields:

```
schema Point {
    x;
    y
};

p = Point{x: 10, y: 20}; // create instance
output p.x;              // field access → 10
p.x = 42;                // field assignment
output p.y;              // → 20

```

- **Definition**: `schema Name { field1; field2; };`
- **Literal**: `Name{ field: value, ... }`
- **Access**: `obj.field` in expressions
- **Assignment**: `obj.field = value`

Fields are separated by semicolons in the definition, and by commas in literals.

### Conditionals

```
if (score >= 90) {
  output "Grade: A\n"
}

if (x > y) {
  output "greater\n"
} else {
  output "not greater\n"
}
```

Compound conditions with `&&` (AND), `||` (OR), `!` (NOT):

```
if (a > 0 && b > 0) {
  output "both positive\n"
}
```

**Comparison operators :** `<`, `>`, `<=`, `>=`, `==`, `!=`

### Loops

**While loop:**

```
i = 0
while (i < 10) {
  output i;
  output "\n";
  i = i + 1
}
```

**For loop:**

```
for (i = 0; i < 10; i = i + 1) {
  output i + " "
};

output "\n";

for (i = 10; i > 0; i = i - 1) {
  output i + " "
}

// Output
// 0 1 2 3 4 5 6 7 8 9
// 10 9 8 7 6 5 4 3 2 1
```

### Functions

User-defined functions with parameters and return values:

```
func square(x) {
  return x \* x
}

func add(a, b) {
  return a + b
}

func factorial(n) {
  if (n <= 1) {
    return 1
  }
return n \* factorial(n - 1)
}

output square(5);       // 25
output "\n"
output add(3, 4)        // 7
output "\n"
output factorial(5)     // 120
output "\n"
```

Functions can have 0 or more parameters. `return` must be explicit. Functions can call themselves recursively.

Functions called as statements (ignoring return value):

```
greet("Beebo") // call without using return value
```

### Built-in Functions

**Math:**

- `sqrt(x)` - square root
- `exp(x)` - e^x
- `log(x)` - natural logarithm
- `sin(x)` - sine (radians)
- `cos(x)` - cosine (radians)
- `abs(x)` - absolute value

**Type conversion:**

- `string(x)` - convert any value to string
- `real(x)` - convert to real (from int or string)
- `integer(x)` - convert to integer (from real or string)

```
x = sqrt(25.0)     // 5.0
y = string(42)     // "42"
z = real("3.14")   // 3.14
w = integer(3.9)   // 3
```

**Terminal control:**

- `sleep(ms)` — pause for `ms` milliseconds
- `clear_screen()` — clear terminal (ANSI `\033[2J\033[H`)
- `move_cursor(x, y)` — move cursor to column `x`, row `y` (1-based)
- `get_key()` — non-blocking read of a single keystroke; returns empty string if no key pressed
- `cursor_hide()` / `cursor_show()` — hide/show terminal cursor
- `set_color(fg)` / `set_color(fg, bg)` — set text/both colors (0–7)
- `reset_color()` — reset to default color
- `term_width()` / `term_height()` — terminal dimensions (from `$COLUMNS`/`$LINES`)

```
clear_screen();
move_cursor(10, 5);
set_color(2);
output "Green text at (10,5)\n";
reset_color()
```

### Comments

```
// Single line comment
/* Multi-line
comment */
```

---

## Architecture

The compiler-interpreter follows the classic **analysis-synthesis** model with three table-driven phases:

### 1. Lexical Analyzer (`lexer.ml`)

Finite-state machine with an explicit transition table `(state × character_class) → next_state`.

- 10 states: START, ID, NUM, REAL_FRAC, STRING, OPERATOR, COMMENT, etc.
- Character classes: LETTER, DIGIT, DOT, QUOTE, COLON, operators, delimiters
- Keywords resolved via lookup table after identifier tokenization
- Escape sequences (`\n`, `\\`, `\"`, `\t`) processed in string literals

### 2. Parser & OPS Generator (`grammar.ml`, `parser.ml`)

- **Grammar**: 102 productions in **non-strict Greibach Normal Form**
- **Parse table**: `(nonterminal × terminal) → production` using LL(1) predictive parsing
- **Store automaton**: Pushdown automaton using a task stack (MATCH, PARSE, ACTION tasks)
- **OPS generation**: Semantic actions attached to each production emit postfix instructions

### 3. OPS Interpreter (`interpreter.ml`)

Stack machine executing OPS instructions:

- **Memory**: PUSH_INT, PUSH_REAL, PUSH_STR, PUSH_ADDR, LOAD, STORE
- **Arrays**: ALLOC_ARR, INDEX, INDEX2
- **Schemas**: MAKE_SCHEMA, GET_FIELD, SET_FIELD
- **Arithmetic**: ADD, SUB, MUL, DIV, NEG
- **Comparison**: EQ, NE, LT, GT, LE, GE
- **Logic**: AND, OR, NOT
- **Control flow**: JMP, JMPF, LABEL
- **Functions**: FUNC_ENTRY, CALL_USER, RET, ARG
- **I/O**: INPUT_STR, OUTPUT
- **Math**: CALL (sqrt, exp, log, sin, cos, abs)
- **Terminal**: CALL_USER fallback (sleep, get_key, clear_screen, move_cursor, etc.)

### Data Types

| Type                     | Description                       |
| ------------------------ | --------------------------------- |
| `V_INT(n)`               | Integer                           |
| `V_REAL(r)`              | Real (float)                      |
| `V_STR(s)`               | String                            |
| `V_ARR(arr)`             | 1D dynamic array                  |
| `V_MAT(arr)`             | 2D matrix                         |
| `V_SCHEMA(name, fields)` | Named struct with field hashtable |

Arithmetic: automatic int→real promotion, division always yields real.
String `+`: auto-converts non-string operands to string.
Memory model: hash table mapping names → values.

---

## Error Diagnostics

The compiler provides error messages with:

- **Line number** of the error
- **Column number** of the erroneous symbol

```
=== SYNTAX ERRORS ===
Syntax error at line 10, col 15: expected ')', got ';' (';')
```

---

## CLI Options

```
beebo [options] <file.bbo>
--tokens Print token list after lexical analysis
--ops Print generated OPS (Polish notation) code
--run Execute the program (default)
--help Show help
```

---

## Implementation Notes

### Grammar in Greibach Normal Form

The original grammar had left recursion in expression productions. After elimination and left-factoring (non-strict Greibach form):

```
Expr → Term ExprTail
ExprTail → + Term ExprTail | - Term ExprTail | ε
Term → Factor TermTail
TermTail → \* Factor TermTail | / Factor TermTail | ε
```

### Parse Table

The parse table maps `(nonterminal, terminal) → production_id`:

```
add_set NT_STMT [T_KW_IF] 5 // Stmt → IfStmt when seeing 'if'
add_set NT_STMT [T_KW_FUNC] 72 // Stmt → FuncDef when seeing 'func'
```

### OPS Stack Convention

**First pushed = bottom (base/address), second pushed = top (value/index)**.

- STORE: pop value (top), pop address → store value at address
- INDEX: pop index (top), pop base → push ADDR_ARR
- ALLOC: pop size (top), pop name → allocate array
- GET_FIELD: pop schema (top), push field value
- SET_FIELD: pop value (top), pop schema → mutate field, push schema
- MAKE_SCHEMA: pop field pairs, pop type name → push V_SCHEMA
