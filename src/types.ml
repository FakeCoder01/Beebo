type token_type =
  | T_IDENT
  | T_INT
  | T_REAL
  | T_STRING
  | T_KW_IF
  | T_KW_ELSE
  | T_KW_WHILE
  | T_KW_FOR
  | T_KW_INPUT
  | T_KW_OUTPUT
  | T_KW_SQRT
  | T_KW_EXP
  | T_KW_LOG
  | T_KW_SIN
  | T_KW_COS
  | T_KW_ABS
  | T_KW_STRING
  | T_KW_REALFN
  | T_KW_INTEGER
  | T_KW_FUNC
  | T_KW_RETURN
  | T_KW_SCHEMA
  | T_DOT
  | T_COLON
  | T_PLUS
  | T_MINUS
  | T_STAR
  | T_SLASH
  | T_EQ
  | T_LT
  | T_GT
  | T_LE
  | T_GE
  | T_EQEQ
  | T_NE
  | T_AND
  | T_OR
  | T_NOT
  | T_LPAREN
  | T_RPAREN
  | T_LBRACE
  | T_RBRACE
  | T_LBRACKET
  | T_RBRACKET
  | T_SEMICOLON
  | T_COMMA
  | T_EOF

type token = {
  typ: token_type;
  lexeme: string;
  line: int;
  col: int;
}

type opcode =
  | OP_PUSH_INT of int
  | OP_PUSH_REAL of float
  | OP_PUSH_STR of string
  | OP_PUSH_ADDR of string
  | OP_LOAD
  | OP_STORE
  | OP_ADD
  | OP_SUB
  | OP_MUL
  | OP_DIV
  | OP_NEG
  | OP_EQ
  | OP_NE
  | OP_LT
  | OP_GT
  | OP_LE
  | OP_GE
  | OP_NOT
  | OP_AND
  | OP_OR
  | OP_JMP of int
  | OP_JMPF of int
  | OP_INPUT_INT
  | OP_INPUT_REAL
  | OP_INPUT_STR
  | OP_OUTPUT
  | OP_CALL of string
  | OP_CALL_USER of int
  | OP_RET
  | OP_ARG of string
  | OP_FUNC_ENTRY of string * int * int
  | OP_GET_FIELD of string
  | OP_SET_FIELD of string
  | OP_MAKE_SCHEMA of string
  | OP_ALLOC_ARR of int
  | OP_INDEX
  | OP_INDEX2
  | OP_LABEL of int
  | OP_HALT

type var_value =
  | V_INT of int
  | V_REAL of float
  | V_STR of string
  | V_ARR of var_value array
  | V_MAT of var_value array array
  | V_ADDR_SIMPLE of string
  | V_ADDR_ARR of string * int
  | V_ADDR_ARR2 of string * int * int
  | V_RET_ADDR of int
  | V_SCHEMA of string * (string, var_value) Hashtbl.t
  | V_NONE

type nonterminal =
  | NT_PROGRAM
  | NT_STMT_LIST
  | NT_STMT_LIST_TAIL
  | NT_STMT
  | NT_BLOCK
  | NT_ASSIGN_STMT
  | NT_ASSIGN_REST
  | NT_ASSIGN_ARR
  | NT_IF_STMT
  | NT_ELSE_PART
  | NT_WHILE_STMT
  | NT_FOR_STMT
  | NT_INPUT_STMT
  | NT_OUTPUT_STMT
  | NT_OUTPUT_ARG
  | NT_LVALUE
  | NT_LVALUE_REST
  | NT_LVALUE_ARR
  | NT_COND
  | NT_COND_REST
  | NT_COND_TERM
  | NT_COND_TERM_REST
  | NT_COND_FACT
  | NT_EXPR
  | NT_EXPR_TAIL
  | NT_TERM
  | NT_TERM_TAIL
  | NT_FACTOR
  | NT_FACTOR_REST
  | NT_FACTOR_ARR
  | NT_RELOP
  | NT_FUNC_NAME
  | NT_FUNC_DEF
  | NT_PARAM_LIST
  | NT_PARAM_LIST_TAIL
  | NT_RETURN_STMT
  | NT_ARG_LIST
  | NT_ARG_LIST_TAIL
  | NT_SCHEMA_DEF
  | NT_FIELD_LIST
  | NT_FIELD_REST
  | NT_FIELD_INIT_LIST
  | NT_FIELD_INIT_TAIL
  | NT_ASSIGN_ARR2

type grammar_symbol =
  | GS_NT of nonterminal
  | GS_T of token_type
  | GS_EPSILON
  | GS_EOF

type semantic_action =
  | SA_NONE
  | SA_EMIT of opcode
  | SA_EMIT_LIST of opcode list
  | SA_ALLOC
  | SA_STORE_ELEM
  | SA_STORE_ELEM2
  | SA_STORE_ARR_DECL
  | SA_STORE_ARR_DECL2
  | SA_BACKPATCH_START
  | SA_BACKPATCH_END
  | SA_BACKPATCH_ELSE
  | SA_BACKPATCH_WHILE_START
  | SA_BACKPATCH_WHILE_END
  | SA_BACKPATCH_FOR_START
  | SA_BACKPATCH_FOR_COND
  | SA_BACKPATCH_FOR_INCR
  | SA_BACKPATCH_FOR_END
  | SA_LABEL of int

type production = {
  lhs: nonterminal;
  rhs: grammar_symbol list;
  action: semantic_action;
  rhs_len: int;
}

type parse_table_key = nonterminal * token_type

module NTTbl = Hashtbl.Make(struct
  type t = nonterminal
  let equal = (==)
  let hash = Hashtbl.hash
end)

module TokenTbl = Hashtbl.Make(struct
  type t = token_type
  let equal = (==)
  let hash = Hashtbl.hash
end)
