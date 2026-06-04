open Types

let string_of_token_type tt =
  match tt with
  | T_IDENT -> "identifier"
  | T_INT -> "integer"
  | T_REAL -> "real"
  | T_STRING -> "string"
  | T_KW_IF -> "'if'"
  | T_KW_ELSE -> "'else'"
  | T_KW_WHILE -> "'while'"
  | T_KW_FOR -> "'for'"
  | T_KW_INPUT -> "'input'"
  | T_KW_OUTPUT -> "'output'"
  | T_KW_SQRT -> "'sqrt'"
  | T_KW_EXP -> "'exp'"
  | T_KW_LOG -> "'log'"
  | T_KW_SIN -> "'sin'"
  | T_KW_COS -> "'cos'"
  | T_KW_ABS -> "'abs'"
  | T_KW_STRING -> "'string'"
  | T_KW_REALFN -> "'real'"
  | T_KW_INTEGER -> "'integer'"
  | T_KW_FUNC -> "'func'"
  | T_KW_RETURN -> "'return'"
  | T_KW_SCHEMA -> "'schema'"
  | T_DOT -> "'.'"
  | T_COLON -> "':'"
  | T_PLUS -> "'+'"
  | T_MINUS -> "'-'"
  | T_STAR -> "'*'"
  | T_SLASH -> "'/'"
  | T_EQ -> "'='"
  | T_LT -> "'<'"
  | T_GT -> "'>'"
  | T_LE -> "'<='"
  | T_GE -> "'>='"
  | T_EQEQ -> "'=='"
  | T_NE -> "'!='"
  | T_AND -> "'&&'"
  | T_OR -> "'||'"
  | T_NOT -> "'!'"
  | T_LPAREN -> "'('"
  | T_RPAREN -> "')'"
  | T_LBRACE -> "'{'"
  | T_RBRACE -> "'}'"
  | T_LBRACKET -> "'['"
  | T_RBRACKET -> "']'"
  | T_SEMICOLON -> "';'"
  | T_COMMA -> "','"
  | T_EOF -> "end of file"

type production_entry = {
  prod_id: int;
  lhs: nonterminal;
  rhs: grammar_symbol list;
  rhs_len: int;
}

let string_of_gs = function
  | GS_NT nt -> (
      match nt with
      | NT_PROGRAM -> "Program"
      | NT_STMT_LIST -> "StmtList"
      | NT_STMT_LIST_TAIL -> "StmtListTail"
      | NT_STMT -> "Stmt"
      | NT_BLOCK -> "Block"
      | NT_ASSIGN_STMT -> "AssignStmt"
      | NT_ASSIGN_REST -> "AssignRest"
      | NT_ASSIGN_ARR -> "AssignArr"
      | NT_ASSIGN_ARR2 -> "AssignArr2"
      | NT_IF_STMT -> "IfStmt"
      | NT_ELSE_PART -> "ElsePart"
      | NT_WHILE_STMT -> "WhileStmt"
      | NT_FOR_STMT -> "ForStmt"
      | NT_INPUT_STMT -> "InputStmt"
  | NT_OUTPUT_STMT -> "OutputStmt"
  | NT_OUTPUT_ARG -> "OutputArg"
      | NT_LVALUE -> "LValue"
      | NT_LVALUE_REST -> "LValueRest"
      | NT_LVALUE_ARR -> "LValueArr"
      | NT_COND -> "Cond"
      | NT_COND_REST -> "CondRest"
      | NT_COND_TERM -> "CondTerm"
      | NT_COND_TERM_REST -> "CondTermRest"
      | NT_COND_FACT -> "CondFact"
      | NT_EXPR -> "Expr"
      | NT_EXPR_TAIL -> "ExprTail"
      | NT_TERM -> "Term"
      | NT_TERM_TAIL -> "TermTail"
      | NT_FACTOR -> "Factor"
      | NT_FACTOR_REST -> "FactorRest"
      | NT_FACTOR_ARR -> "FactorArr"
      | NT_RELOP -> "Relop"
  | NT_FUNC_NAME -> "FuncName"
  | NT_FUNC_DEF -> "FuncDef"
  | NT_PARAM_LIST -> "ParamList"
  | NT_PARAM_LIST_TAIL -> "ParamListTail"
  | NT_RETURN_STMT -> "ReturnStmt"
  | NT_ARG_LIST -> "ArgList"
  | NT_ARG_LIST_TAIL -> "ArgListTail"
      | NT_SCHEMA_DEF -> "SchemaDef"
  | NT_FIELD_LIST -> "FieldList"
  | NT_FIELD_REST -> "FieldRest"
  | NT_FIELD_INIT_LIST -> "FieldInitList"
  | NT_FIELD_INIT_TAIL -> "FieldInitTail"
    )
  | GS_T tt -> string_of_token_type tt
  | GS_EPSILON -> "epsilon"
  | GS_EOF -> "EOF"

let string_of_nt = function
  | NT_PROGRAM -> "Program"
  | NT_STMT_LIST -> "StmtList"
  | NT_STMT_LIST_TAIL -> "StmtListTail"
  | NT_STMT -> "Stmt"
  | NT_BLOCK -> "Block"
  | NT_ASSIGN_STMT -> "AssignStmt"
  | NT_ASSIGN_REST -> "AssignRest"
  | NT_ASSIGN_ARR -> "AssignArr"
  | NT_ASSIGN_ARR2 -> "AssignArr2"
  | NT_IF_STMT -> "IfStmt"
  | NT_ELSE_PART -> "ElsePart"
  | NT_WHILE_STMT -> "WhileStmt"
  | NT_FOR_STMT -> "ForStmt"
  | NT_INPUT_STMT -> "InputStmt"
  | NT_OUTPUT_STMT -> "OutputStmt"
  | NT_OUTPUT_ARG -> "OutputArg"
  | NT_LVALUE -> "LValue"
  | NT_LVALUE_REST -> "LValueRest"
  | NT_LVALUE_ARR -> "LValueArr"
  | NT_COND -> "Cond"
  | NT_COND_REST -> "CondRest"
  | NT_COND_TERM -> "CondTerm"
  | NT_COND_TERM_REST -> "CondTermRest"
  | NT_COND_FACT -> "CondFact"
  | NT_EXPR -> "Expr"
  | NT_EXPR_TAIL -> "ExprTail"
  | NT_TERM -> "Term"
  | NT_TERM_TAIL -> "TermTail"
  | NT_FACTOR -> "Factor"
  | NT_FACTOR_REST -> "FactorRest"
  | NT_FACTOR_ARR -> "FactorArr"
  | NT_RELOP -> "Relop"
  | NT_FUNC_NAME -> "FuncName"
  | NT_FUNC_DEF -> "FuncDef"
  | NT_PARAM_LIST -> "ParamList"
  | NT_PARAM_LIST_TAIL -> "ParamListTail"
  | NT_RETURN_STMT -> "ReturnStmt"
  | NT_ARG_LIST -> "ArgList"
  | NT_ARG_LIST_TAIL -> "ArgListTail"
  | NT_SCHEMA_DEF -> "SchemaDef"
  | NT_FIELD_LIST -> "FieldList"
  | NT_FIELD_REST -> "FieldRest"
  | NT_FIELD_INIT_LIST -> "FieldInitList"
  | NT_FIELD_INIT_TAIL -> "FieldInitTail"

let productions : production_entry array = [|
  { prod_id = 0;  lhs = NT_PROGRAM;          rhs = [GS_NT NT_STMT_LIST; GS_EOF];        rhs_len = 2; };
  { prod_id = 1;  lhs = NT_STMT_LIST;        rhs = [GS_NT NT_STMT; GS_NT NT_STMT_LIST_TAIL]; rhs_len = 2; };
  { prod_id = 2;  lhs = NT_STMT_LIST_TAIL;   rhs = [GS_T T_SEMICOLON; GS_NT NT_STMT; GS_NT NT_STMT_LIST_TAIL]; rhs_len = 3; };
  { prod_id = 3;  lhs = NT_STMT_LIST_TAIL;   rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 4;  lhs = NT_STMT;             rhs = [GS_NT NT_ASSIGN_STMT];          rhs_len = 1; };
  { prod_id = 5;  lhs = NT_STMT;             rhs = [GS_NT NT_IF_STMT];              rhs_len = 1; };
  { prod_id = 6;  lhs = NT_STMT;             rhs = [GS_NT NT_WHILE_STMT];           rhs_len = 1; };
  { prod_id = 7;  lhs = NT_STMT;             rhs = [GS_NT NT_FOR_STMT];             rhs_len = 1; };
  { prod_id = 8;  lhs = NT_STMT;             rhs = [GS_NT NT_INPUT_STMT];           rhs_len = 1; };
  { prod_id = 9;  lhs = NT_STMT;             rhs = [GS_NT NT_OUTPUT_STMT];          rhs_len = 1; };
  { prod_id = 10; lhs = NT_STMT;             rhs = [GS_NT NT_BLOCK];                rhs_len = 1; };
  { prod_id = 11; lhs = NT_BLOCK;            rhs = [GS_T T_LBRACE; GS_NT NT_STMT_LIST; GS_T T_RBRACE]; rhs_len = 3; };
  { prod_id = 12; lhs = NT_ASSIGN_STMT;      rhs = [GS_T T_IDENT; GS_NT NT_ASSIGN_REST]; rhs_len = 2; };
  { prod_id = 13; lhs = NT_ASSIGN_REST;      rhs = [GS_T T_EQ; GS_NT NT_EXPR];     rhs_len = 2; };
  { prod_id = 14; lhs = NT_ASSIGN_REST;      rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET; GS_NT NT_ASSIGN_ARR]; rhs_len = 4; };
  { prod_id = 15; lhs = NT_ASSIGN_ARR;       rhs = [GS_T T_EQ; GS_NT NT_EXPR];     rhs_len = 2; };
  { prod_id = 16; lhs = NT_ASSIGN_ARR;       rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET; GS_NT NT_ASSIGN_ARR2]; rhs_len = 4; };
  { prod_id = 17; lhs = NT_ASSIGN_ARR;       rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 18; lhs = NT_IF_STMT;          rhs = [GS_T T_KW_IF; GS_T T_LPAREN; GS_NT NT_COND; GS_T T_RPAREN; GS_NT NT_STMT; GS_NT NT_ELSE_PART]; rhs_len = 6; };
  { prod_id = 19; lhs = NT_ELSE_PART;        rhs = [GS_T T_KW_ELSE; GS_NT NT_STMT]; rhs_len = 2; };
  { prod_id = 20; lhs = NT_ELSE_PART;        rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 21; lhs = NT_WHILE_STMT;       rhs = [GS_T T_KW_WHILE; GS_T T_LPAREN; GS_NT NT_COND; GS_T T_RPAREN; GS_NT NT_STMT]; rhs_len = 5; };
  { prod_id = 22; lhs = NT_FOR_STMT;         rhs = [GS_T T_KW_FOR; GS_T T_LPAREN; GS_NT NT_ASSIGN_STMT; GS_T T_SEMICOLON; GS_NT NT_COND; GS_T T_SEMICOLON; GS_NT NT_ASSIGN_STMT; GS_T T_RPAREN; GS_NT NT_STMT]; rhs_len = 9; };
  { prod_id = 23; lhs = NT_INPUT_STMT;       rhs = [GS_T T_KW_INPUT; GS_NT NT_LVALUE]; rhs_len = 2; };
  { prod_id = 24; lhs = NT_OUTPUT_STMT;      rhs = [GS_T T_KW_OUTPUT; GS_NT NT_OUTPUT_ARG]; rhs_len = 2; };
  { prod_id = 25; lhs = NT_OUTPUT_ARG;        rhs = [GS_NT NT_EXPR];               rhs_len = 1; };
  { prod_id = 26; lhs = NT_LVALUE;           rhs = [GS_T T_IDENT; GS_NT NT_LVALUE_REST]; rhs_len = 2; };
  { prod_id = 27; lhs = NT_LVALUE_REST;      rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET; GS_NT NT_LVALUE_ARR]; rhs_len = 4; };
  { prod_id = 28; lhs = NT_LVALUE_REST;      rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 29; lhs = NT_LVALUE_ARR;       rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET]; rhs_len = 3; };
  { prod_id = 30; lhs = NT_LVALUE_ARR;       rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 31; lhs = NT_COND;             rhs = [GS_NT NT_COND_TERM; GS_NT NT_COND_REST]; rhs_len = 2; };
  { prod_id = 32; lhs = NT_COND_REST;        rhs = [GS_T T_OR; GS_NT NT_COND_TERM; GS_NT NT_COND_REST]; rhs_len = 3; };
  { prod_id = 33; lhs = NT_COND_REST;        rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 34; lhs = NT_COND_TERM;        rhs = [GS_NT NT_COND_FACT; GS_NT NT_COND_TERM_REST]; rhs_len = 2; };
  { prod_id = 35; lhs = NT_COND_TERM_REST;   rhs = [GS_T T_AND; GS_NT NT_COND_FACT; GS_NT NT_COND_TERM_REST]; rhs_len = 3; };
  { prod_id = 36; lhs = NT_COND_TERM_REST;   rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 37; lhs = NT_COND_FACT;        rhs = [GS_NT NT_EXPR; GS_NT NT_RELOP; GS_NT NT_EXPR]; rhs_len = 3; };
  { prod_id = 38; lhs = NT_COND_FACT;        rhs = [GS_T T_NOT; GS_NT NT_COND_FACT]; rhs_len = 2; };
  { prod_id = 39; lhs = NT_COND_FACT;        rhs = [GS_T T_LPAREN; GS_NT NT_COND; GS_T T_RPAREN]; rhs_len = 3; };
  { prod_id = 40; lhs = NT_EXPR;             rhs = [GS_NT NT_TERM; GS_NT NT_EXPR_TAIL]; rhs_len = 2; };
  { prod_id = 41; lhs = NT_EXPR_TAIL;        rhs = [GS_T T_PLUS; GS_NT NT_TERM; GS_NT NT_EXPR_TAIL]; rhs_len = 3; };
  { prod_id = 42; lhs = NT_EXPR_TAIL;        rhs = [GS_T T_MINUS; GS_NT NT_TERM; GS_NT NT_EXPR_TAIL]; rhs_len = 3; };
  { prod_id = 43; lhs = NT_EXPR_TAIL;        rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 44; lhs = NT_TERM;             rhs = [GS_NT NT_FACTOR; GS_NT NT_TERM_TAIL]; rhs_len = 2; };
  { prod_id = 45; lhs = NT_TERM_TAIL;        rhs = [GS_T T_STAR; GS_NT NT_FACTOR; GS_NT NT_TERM_TAIL]; rhs_len = 3; };
  { prod_id = 46; lhs = NT_TERM_TAIL;        rhs = [GS_T T_SLASH; GS_NT NT_FACTOR; GS_NT NT_TERM_TAIL]; rhs_len = 3; };
  { prod_id = 47; lhs = NT_TERM_TAIL;        rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 48; lhs = NT_FACTOR;           rhs = [GS_T T_LPAREN; GS_NT NT_EXPR; GS_T T_RPAREN]; rhs_len = 3; };
  { prod_id = 49; lhs = NT_FACTOR;           rhs = [GS_T T_INT];                    rhs_len = 1; };
  { prod_id = 50; lhs = NT_FACTOR;           rhs = [GS_T T_REAL];                   rhs_len = 1; };
  { prod_id = 51; lhs = NT_FACTOR;           rhs = [GS_T T_IDENT; GS_NT NT_FACTOR_REST]; rhs_len = 2; };
  { prod_id = 52; lhs = NT_FACTOR;           rhs = [GS_NT NT_FUNC_NAME; GS_T T_LPAREN; GS_NT NT_EXPR; GS_T T_RPAREN]; rhs_len = 4; };
  { prod_id = 53; lhs = NT_FACTOR;           rhs = [GS_T T_MINUS; GS_NT NT_FACTOR]; rhs_len = 2; };
  { prod_id = 54; lhs = NT_FACTOR;           rhs = [GS_T T_STRING];                 rhs_len = 1; };
  { prod_id = 55; lhs = NT_FACTOR_REST;      rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET; GS_NT NT_FACTOR_ARR]; rhs_len = 4; };
  { prod_id = 56; lhs = NT_FACTOR_REST;      rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 57; lhs = NT_FACTOR_ARR;       rhs = [GS_T T_LBRACKET; GS_NT NT_EXPR; GS_T T_RBRACKET]; rhs_len = 3; };
  { prod_id = 58; lhs = NT_FACTOR_ARR;       rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 59; lhs = NT_RELOP;            rhs = [GS_T T_LT];                     rhs_len = 1; };
  { prod_id = 60; lhs = NT_RELOP;            rhs = [GS_T T_GT];                     rhs_len = 1; };
  { prod_id = 61; lhs = NT_RELOP;            rhs = [GS_T T_LE];                     rhs_len = 1; };
  { prod_id = 62; lhs = NT_RELOP;            rhs = [GS_T T_GE];                     rhs_len = 1; };
  { prod_id = 63; lhs = NT_RELOP;            rhs = [GS_T T_EQEQ];                   rhs_len = 1; };
  { prod_id = 64; lhs = NT_RELOP;            rhs = [GS_T T_NE];                     rhs_len = 1; };
  { prod_id = 65; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_SQRT];                rhs_len = 1; };
  { prod_id = 66; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_EXP];                 rhs_len = 1; };
  { prod_id = 67; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_LOG];                 rhs_len = 1; };
  { prod_id = 68; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_SIN];                 rhs_len = 1; };
  { prod_id = 69; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_COS];                 rhs_len = 1; };
  { prod_id = 70; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_ABS];                 rhs_len = 1; };
  { prod_id = 71; lhs = NT_OUTPUT_ARG;        rhs = [GS_T T_STRING];                 rhs_len = 1; };
  { prod_id = 72; lhs = NT_STMT;             rhs = [GS_NT NT_FUNC_DEF];              rhs_len = 1; };
  { prod_id = 73; lhs = NT_STMT;             rhs = [GS_NT NT_RETURN_STMT];           rhs_len = 1; };
  { prod_id = 74; lhs = NT_FUNC_DEF;         rhs = [GS_T T_KW_FUNC; GS_T T_IDENT; GS_T T_LPAREN; GS_NT NT_PARAM_LIST; GS_T T_RPAREN; GS_NT NT_BLOCK]; rhs_len = 6; };
  { prod_id = 75; lhs = NT_PARAM_LIST;       rhs = [GS_T T_IDENT; GS_NT NT_PARAM_LIST_TAIL]; rhs_len = 2; };
  { prod_id = 76; lhs = NT_PARAM_LIST_TAIL;  rhs = [GS_T T_COMMA; GS_T T_IDENT; GS_NT NT_PARAM_LIST_TAIL]; rhs_len = 3; };
  { prod_id = 77; lhs = NT_PARAM_LIST_TAIL;  rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 78; lhs = NT_PARAM_LIST;       rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 79; lhs = NT_RETURN_STMT;      rhs = [GS_T T_KW_RETURN; GS_NT NT_EXPR]; rhs_len = 2; };
  { prod_id = 80; lhs = NT_FACTOR_REST;      rhs = [GS_T T_LPAREN; GS_NT NT_ARG_LIST; GS_T T_RPAREN]; rhs_len = 3; };
  { prod_id = 81; lhs = NT_ARG_LIST;         rhs = [GS_NT NT_EXPR; GS_NT NT_ARG_LIST_TAIL]; rhs_len = 2; };
  { prod_id = 82; lhs = NT_ARG_LIST;         rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 83; lhs = NT_ARG_LIST_TAIL;    rhs = [GS_T T_COMMA; GS_NT NT_EXPR; GS_NT NT_ARG_LIST_TAIL]; rhs_len = 3; };
  { prod_id = 84; lhs = NT_ARG_LIST_TAIL;    rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 85; lhs = NT_ASSIGN_REST;      rhs = [GS_T T_LPAREN; GS_NT NT_ARG_LIST; GS_T T_RPAREN]; rhs_len = 3; };
  { prod_id = 86; lhs = NT_STMT;             rhs = [GS_NT NT_SCHEMA_DEF];              rhs_len = 1; };
  { prod_id = 87; lhs = NT_SCHEMA_DEF;       rhs = [GS_T T_KW_SCHEMA; GS_T T_IDENT; GS_T T_LBRACE; GS_NT NT_FIELD_LIST; GS_T T_RBRACE]; rhs_len = 5; };
  { prod_id = 88; lhs = NT_FIELD_LIST;       rhs = [GS_T T_IDENT; GS_NT NT_FIELD_REST]; rhs_len = 2; };
  { prod_id = 89; lhs = NT_FIELD_REST;       rhs = [GS_T T_SEMICOLON; GS_T T_IDENT; GS_NT NT_FIELD_REST]; rhs_len = 3; };
  { prod_id = 90; lhs = NT_FIELD_REST;       rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 91; lhs = NT_ASSIGN_REST;      rhs = [GS_T T_DOT; GS_T T_IDENT; GS_NT NT_ASSIGN_REST]; rhs_len = 3; };
  { prod_id = 92; lhs = NT_FACTOR_REST;      rhs = [GS_T T_DOT; GS_T T_IDENT; GS_NT NT_FACTOR_REST]; rhs_len = 3; };
  { prod_id = 93; lhs = NT_FACTOR_REST;      rhs = [GS_T T_LBRACE; GS_NT NT_FIELD_INIT_LIST; GS_T T_RBRACE]; rhs_len = 3; };
  { prod_id = 94; lhs = NT_FIELD_INIT_LIST;  rhs = [GS_T T_IDENT; GS_T T_COLON; GS_NT NT_EXPR; GS_NT NT_FIELD_INIT_TAIL]; rhs_len = 4; };
  { prod_id = 95; lhs = NT_FIELD_INIT_LIST;  rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 96; lhs = NT_FIELD_INIT_TAIL;  rhs = [GS_T T_COMMA; GS_T T_IDENT; GS_T T_COLON; GS_NT NT_EXPR; GS_NT NT_FIELD_INIT_TAIL]; rhs_len = 5; };
  { prod_id = 97; lhs = NT_FIELD_INIT_TAIL;  rhs = [GS_EPSILON];                   rhs_len = 1; };
  { prod_id = 98; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_STRING];              rhs_len = 1; };
  { prod_id = 99; lhs = NT_FUNC_NAME;        rhs = [GS_T T_KW_REALFN];              rhs_len = 1; };
  { prod_id = 100; lhs = NT_FUNC_NAME;       rhs = [GS_T T_KW_INTEGER];             rhs_len = 1; };
  { prod_id = 101; lhs = NT_ASSIGN_ARR2;     rhs = [GS_T T_EQ; GS_NT NT_EXPR];     rhs_len = 2; };
  { prod_id = 102; lhs = NT_ASSIGN_ARR2;     rhs = [GS_EPSILON];                   rhs_len = 1; };
|]

let production_count = Array.length productions

let terminal_first nt =
  let expr_first =
    [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
     T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS;
     T_KW_STRING; T_KW_REALFN; T_KW_INTEGER]
  in
  match nt with
  | NT_PROGRAM | NT_STMT_LIST | NT_STMT ->
      [T_IDENT; T_KW_IF; T_KW_WHILE; T_KW_FOR; T_KW_INPUT; T_KW_OUTPUT; T_LBRACE; T_KW_FUNC; T_KW_RETURN; T_KW_SCHEMA]
  | NT_STMT_LIST_TAIL ->
      [T_SEMICOLON]
  | NT_BLOCK ->
      [T_LBRACE]
  | NT_ASSIGN_STMT ->
      [T_IDENT]
  | NT_ASSIGN_REST ->
      [T_EQ; T_LBRACKET; T_LPAREN; T_DOT]
  | NT_ASSIGN_ARR ->
      [T_EQ; T_LBRACKET]
  | NT_ASSIGN_ARR2 ->
      [T_EQ]
  | NT_IF_STMT ->
      [T_KW_IF]
  | NT_ELSE_PART ->
      [T_KW_ELSE]
  | NT_WHILE_STMT ->
      [T_KW_WHILE]
  | NT_FOR_STMT ->
      [T_KW_FOR]
  | NT_INPUT_STMT ->
      [T_KW_INPUT]
  | NT_OUTPUT_STMT ->
      [T_KW_OUTPUT]
  | NT_OUTPUT_ARG ->
      expr_first
  | NT_LVALUE ->
      [T_IDENT]
  | NT_LVALUE_REST ->
      [T_LBRACKET]
  | NT_LVALUE_ARR ->
      [T_LBRACKET]
  | NT_COND | NT_COND_TERM | NT_COND_FACT ->
      [T_NOT; T_LPAREN; T_IDENT; T_INT; T_REAL; T_STRING; T_MINUS;
       T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER]
  | NT_COND_REST ->
      [T_OR]
  | NT_COND_TERM_REST ->
      [T_AND]
  | NT_EXPR | NT_TERM | NT_FACTOR ->
      expr_first
  | NT_EXPR_TAIL ->
      [T_PLUS; T_MINUS]
  | NT_TERM_TAIL ->
      [T_STAR; T_SLASH]
  | NT_FACTOR_REST ->
      [T_LBRACKET; T_LPAREN; T_DOT; T_LBRACE]
  | NT_FACTOR_ARR ->
      [T_LBRACKET]
  | NT_RELOP ->
      [T_LT; T_GT; T_LE; T_GE; T_EQEQ; T_NE]
  | NT_FUNC_NAME ->
      [T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER]
  | NT_FUNC_DEF ->
      [T_KW_FUNC]
  | NT_PARAM_LIST ->
      [T_IDENT]
  | NT_PARAM_LIST_TAIL ->
      [T_COMMA]
  | NT_RETURN_STMT ->
      [T_KW_RETURN]
  | NT_ARG_LIST ->
      expr_first
  | NT_ARG_LIST_TAIL ->
      [T_COMMA]
  | NT_SCHEMA_DEF ->
      [T_KW_SCHEMA]
  | NT_FIELD_LIST ->
      [T_IDENT]
  | NT_FIELD_REST ->
      [T_SEMICOLON]
  | NT_FIELD_INIT_LIST ->
      [T_IDENT]
  | NT_FIELD_INIT_TAIL ->
      [T_COMMA]

let follow_set nt =
  match nt with
  | NT_PROGRAM -> [T_EOF]
  | NT_STMT_LIST -> [T_EOF; T_RBRACE]
  | NT_STMT_LIST_TAIL -> [T_EOF; T_RBRACE]
  | NT_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_BLOCK -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_ASSIGN_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_ASSIGN_REST -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_ASSIGN_ARR -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_ASSIGN_ARR2 -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_IF_STMT -> [T_SEMICOLON; T_KW_ELSE; T_EOF; T_RBRACE]
  | NT_ELSE_PART -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_WHILE_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_FOR_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_INPUT_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_OUTPUT_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_OUTPUT_ARG -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_LVALUE -> [T_SEMICOLON; T_EOF; T_RBRACE; T_RPAREN]
  | NT_LVALUE_REST -> [T_SEMICOLON; T_EOF; T_RBRACE; T_RPAREN]
  | NT_LVALUE_ARR -> [T_SEMICOLON; T_EOF; T_RBRACE; T_RPAREN]
  | NT_COND -> [T_RPAREN; T_SEMICOLON]
  | NT_COND_REST -> [T_RPAREN; T_SEMICOLON]
  | NT_COND_TERM -> [T_OR; T_RPAREN; T_SEMICOLON]
  | NT_COND_TERM_REST -> [T_OR; T_RPAREN; T_SEMICOLON]
  | NT_COND_FACT -> [T_AND; T_OR; T_RPAREN; T_SEMICOLON]
  | NT_EXPR -> [T_SEMICOLON; T_RPAREN; T_RBRACKET; T_EOF; T_RBRACE;
                T_LT; T_GT; T_LE; T_GE; T_EQEQ; T_NE;
                T_AND; T_OR]
  | NT_EXPR_TAIL -> [T_SEMICOLON; T_RPAREN; T_RBRACKET; T_EOF; T_RBRACE;
                     T_LT; T_GT; T_LE; T_GE; T_EQEQ; T_NE;
                     T_AND; T_OR; T_COMMA]
  | NT_TERM -> [T_PLUS; T_MINUS; T_SEMICOLON; T_RPAREN; T_RBRACKET; T_EOF;
                T_RBRACE; T_LT; T_GT; T_LE; T_GE; T_EQEQ; T_NE;
                T_AND; T_OR; T_COMMA]
  | NT_TERM_TAIL -> [T_PLUS; T_MINUS; T_SEMICOLON; T_RPAREN; T_RBRACKET;
                     T_EOF; T_RBRACE; T_LT; T_GT; T_LE; T_GE; T_EQEQ; T_NE;
                     T_AND; T_OR; T_COMMA]
  | NT_FACTOR -> [T_STAR; T_SLASH; T_PLUS; T_MINUS; T_SEMICOLON; T_RPAREN;
                  T_RBRACKET; T_EOF; T_RBRACE; T_LT; T_GT; T_LE; T_GE;
                  T_EQEQ; T_NE; T_AND; T_OR; T_COMMA]
  | NT_FACTOR_REST -> [T_STAR; T_SLASH; T_PLUS; T_MINUS; T_SEMICOLON; T_RPAREN;
                       T_RBRACKET; T_EOF; T_RBRACE; T_LT; T_GT; T_LE; T_GE;
                       T_EQEQ; T_NE; T_AND; T_OR; T_COMMA]
  | NT_FACTOR_ARR -> [T_STAR; T_SLASH; T_PLUS; T_MINUS; T_SEMICOLON; T_RPAREN;
                      T_RBRACKET; T_EOF; T_RBRACE; T_LT; T_GT; T_LE; T_GE;
                      T_EQEQ; T_NE; T_AND; T_OR; T_COMMA]
  | NT_RELOP -> [T_NOT; T_LPAREN; T_IDENT; T_INT; T_REAL; T_STRING; T_MINUS;
                 T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER;
                 T_PLUS; T_MINUS]
  | NT_FUNC_NAME -> [T_LPAREN]
  | NT_FUNC_DEF -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_PARAM_LIST -> [T_RPAREN]
  | NT_PARAM_LIST_TAIL -> [T_RPAREN]
  | NT_RETURN_STMT -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_ARG_LIST -> [T_RPAREN]
  | NT_ARG_LIST_TAIL -> [T_RPAREN]
  | NT_SCHEMA_DEF -> [T_SEMICOLON; T_EOF; T_RBRACE]
  | NT_FIELD_LIST -> [T_RBRACE]
  | NT_FIELD_REST -> [T_RBRACE]
  | NT_FIELD_INIT_LIST -> [T_RBRACE]
  | NT_FIELD_INIT_TAIL -> [T_RBRACE]

module ParseKey = struct
  type t = nonterminal * token_type
  let equal (a1, b1) (a2, b2) =
    a1 = a2 && b1 = b2
  let hash (a, b) =
    Hashtbl.hash (Hashtbl.hash a, Hashtbl.hash b)
end

module PT = Hashtbl.Make(ParseKey)

let parse_table =
  let t = PT.create 300 in

  let add nt tk prod_id =
    PT.add t (nt, tk) prod_id
  in

  let add_follow nt prod_id =
    List.iter (fun tk -> add nt tk prod_id) (follow_set nt)
  in

  (* Helper: add production for non-terminal with specific terminal set *)
  let add_set nt terminals prod_id =
    List.iter (fun tk -> add nt tk prod_id) terminals
  in

  (* Program → StmtList EOF *)
  add_set NT_PROGRAM [T_IDENT; T_KW_IF; T_KW_WHILE; T_KW_FOR; T_KW_INPUT; T_KW_OUTPUT; T_LBRACE; T_KW_FUNC; T_KW_RETURN; T_KW_SCHEMA] 0;

  add_set NT_STMT_LIST [T_IDENT; T_KW_IF; T_KW_WHILE; T_KW_FOR; T_KW_INPUT; T_KW_OUTPUT; T_LBRACE; T_KW_FUNC; T_KW_RETURN; T_KW_SCHEMA] 1;

  add NT_STMT_LIST_TAIL T_SEMICOLON 2;
  add_follow NT_STMT_LIST_TAIL 3;

  (* Stmt → AssignStmt *)
  add_set NT_STMT [T_IDENT] 4;
  (* Stmt → IfStmt *)
  add_set NT_STMT [T_KW_IF] 5;
  (* Stmt → WhileStmt *)
  add_set NT_STMT [T_KW_WHILE] 6;
  (* Stmt → ForStmt *)
  add_set NT_STMT [T_KW_FOR] 7;
  (* Stmt → InputStmt *)
  add_set NT_STMT [T_KW_INPUT] 8;
  (* Stmt → OutputStmt *)
  add_set NT_STMT [T_KW_OUTPUT] 9;
  (* Stmt → Block *)
  add_set NT_STMT [T_LBRACE] 10;
  add_set NT_STMT [T_KW_FUNC] 72;
  add_set NT_STMT [T_KW_RETURN] 73;

  add_set NT_BLOCK [T_LBRACE] 11;

  add_set NT_ASSIGN_STMT [T_IDENT] 12;

  add NT_ASSIGN_REST T_EQ 13;
  add NT_ASSIGN_REST T_LBRACKET 14;
  add NT_ASSIGN_REST T_LPAREN 85;

  add NT_ASSIGN_ARR T_EQ 15;
  add NT_ASSIGN_ARR T_LBRACKET 16;
  add_follow NT_ASSIGN_ARR 17;

  add NT_ASSIGN_ARR2 T_EQ 101;
  add_follow NT_ASSIGN_ARR2 102;

  add_set NT_IF_STMT [T_KW_IF] 18;

  add NT_ELSE_PART T_KW_ELSE 19;
  add_follow NT_ELSE_PART 20;

  add_set NT_WHILE_STMT [T_KW_WHILE] 21;

  add_set NT_FOR_STMT [T_KW_FOR] 22;

  add_set NT_INPUT_STMT [T_KW_INPUT] 23;

  add_set NT_OUTPUT_STMT [T_KW_OUTPUT] 24;

  add_set NT_OUTPUT_ARG [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
                         T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 25;

  add_set NT_FUNC_DEF [T_KW_FUNC] 74;

  add_set NT_PARAM_LIST [T_IDENT] 75;
  add_follow NT_PARAM_LIST 78;

  add NT_PARAM_LIST_TAIL T_COMMA 76;
  add_follow NT_PARAM_LIST_TAIL 77;

  add_set NT_RETURN_STMT [T_KW_RETURN] 79;

  add NT_FACTOR_REST T_LPAREN 80;

  add_set NT_ARG_LIST [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
                       T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 81;
  add_follow NT_ARG_LIST 82;

  add NT_ARG_LIST_TAIL T_COMMA 83;
  add_follow NT_ARG_LIST_TAIL 84;
  add NT_ASSIGN_REST T_LPAREN 85;

  add_set NT_STMT [T_KW_SCHEMA] 86;

  add_set NT_SCHEMA_DEF [T_KW_SCHEMA] 87;

  add_set NT_FIELD_LIST [T_IDENT] 88;

  add NT_FIELD_REST T_SEMICOLON 89;
  add_follow NT_FIELD_REST 90;

  add NT_ASSIGN_REST T_DOT 91;

  add NT_FACTOR_REST T_DOT 92;
  add NT_FACTOR_REST T_LBRACE 93;

  add_set NT_FIELD_INIT_LIST [T_IDENT] 94;
  add_follow NT_FIELD_INIT_LIST 95;

  add NT_FIELD_INIT_TAIL T_COMMA 96;
  add_follow NT_FIELD_INIT_TAIL 97;

  add_set NT_LVALUE [T_IDENT] 26;
  add NT_LVALUE_REST T_LBRACKET 27;
  add_follow NT_LVALUE_REST 28;
  add NT_LVALUE_ARR T_LBRACKET 29;
  add_follow NT_LVALUE_ARR 30;
  add_set NT_COND [T_NOT; T_LPAREN; T_IDENT; T_INT; T_REAL; T_STRING; T_MINUS;
                   T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 31;
  add NT_COND_REST T_OR 32;
  add_follow NT_COND_REST 33;
  add_set NT_COND_TERM [T_NOT; T_LPAREN; T_IDENT; T_INT; T_REAL; T_STRING; T_MINUS;
                        T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 34;
  add NT_COND_TERM_REST T_AND 35;
  add_follow NT_COND_TERM_REST 36;
  add_set NT_COND_FACT [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
                        T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 37;
  add NT_COND_FACT T_NOT 38;
  add NT_COND_FACT T_LPAREN 39;
  add_set NT_EXPR [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
                   T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 40;
  add NT_EXPR_TAIL T_PLUS 41;
  add NT_EXPR_TAIL T_MINUS 42;
  add_follow NT_EXPR_TAIL 43;
  add_set NT_TERM [T_LPAREN; T_INT; T_REAL; T_IDENT; T_MINUS; T_STRING;
                   T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 44;
  add NT_TERM_TAIL T_STAR 45;
  add NT_TERM_TAIL T_SLASH 46;
  add_follow NT_TERM_TAIL 47;
  add NT_FACTOR T_LPAREN 48;
  add NT_FACTOR T_INT 49;
  add NT_FACTOR T_REAL 50;
  add NT_FACTOR T_IDENT 51;
  add_set NT_FACTOR [T_KW_SQRT; T_KW_EXP; T_KW_LOG; T_KW_SIN; T_KW_COS; T_KW_ABS; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER; T_KW_STRING; T_KW_REALFN; T_KW_INTEGER] 52;
  add NT_FACTOR T_MINUS 53;
  add NT_FACTOR T_STRING 54;
  add NT_FACTOR_REST T_LBRACKET 55;
  add_follow NT_FACTOR_REST 56;
  add NT_FACTOR_ARR T_LBRACKET 57;
  add_follow NT_FACTOR_ARR 58;
  add NT_RELOP T_LT 59;
  add NT_RELOP T_GT 60;
  add NT_RELOP T_LE 61;
  add NT_RELOP T_GE 62;
  add NT_RELOP T_EQEQ 63;
  add NT_RELOP T_NE 64;
  add NT_FUNC_NAME T_KW_SQRT 65;
  add NT_FUNC_NAME T_KW_EXP 66;
  add NT_FUNC_NAME T_KW_LOG 67;
  add NT_FUNC_NAME T_KW_SIN 68;
  add NT_FUNC_NAME T_KW_COS 69;
  add NT_FUNC_NAME T_KW_ABS 70;
  add NT_FUNC_NAME T_KW_STRING 98;
  add NT_FUNC_NAME T_KW_REALFN 99;
  add NT_FUNC_NAME T_KW_INTEGER 100;

  t

let lookup nt tok =
  PT.find_opt parse_table (nt, tok)
