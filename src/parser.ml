open Types
open Grammar

type parser_state = {
  mutable ops: opcode list;
  mutable saved_ident: string;
  mutable saved_func: string;
  mutable saved_relop: token_type;
  mutable sem_stack: string Stack.t;
  mutable func_params: string list;
  mutable func_end_label: int;
  mutable label_ctr: int;
  mutable token_idx: int;
  tokens: token array;
  mutable errors: string list;
}

let fresh_label st =
  let l = st.label_ctr in
  st.label_ctr <- l + 1;
  l

let current_token st =
  if st.token_idx < Array.length st.tokens then
    st.tokens.(st.token_idx)
  else
    { typ = T_EOF; lexeme = ""; line = 0; col = 0 }

let advance st =
  let t = current_token st in
  st.token_idx <- st.token_idx + 1;
  t

let emit st op =
  st.ops <- op :: st.ops

type parser_task =
  | TASK_MATCH of token_type
  | TASK_PARSE of nonterminal
  | TASK_ACTION of (unit -> unit)
  | TASK_DONE

let make_actions st prod_id : parser_task list =
  match prod_id with
  | 0 ->
    [TASK_PARSE NT_STMT_LIST;
     TASK_MATCH T_EOF;
     TASK_ACTION (fun () -> emit st OP_HALT)]

  | 1 ->
    [TASK_PARSE NT_STMT;
     TASK_PARSE NT_STMT_LIST_TAIL]

  | 2 ->
    [TASK_MATCH T_SEMICOLON;
     TASK_PARSE NT_STMT;
     TASK_PARSE NT_STMT_LIST_TAIL]

  | 3 -> []

  | 4 -> [TASK_PARSE NT_ASSIGN_STMT]
  | 5 -> [TASK_PARSE NT_IF_STMT]
  | 6 -> [TASK_PARSE NT_WHILE_STMT]
  | 7 -> [TASK_PARSE NT_FOR_STMT]
  | 8 -> [TASK_PARSE NT_INPUT_STMT]
  | 9 -> [TASK_PARSE NT_OUTPUT_STMT]
  | 10 -> [TASK_PARSE NT_BLOCK]

  | 11 ->
    [TASK_MATCH T_LBRACE;
     TASK_PARSE NT_STMT_LIST;
     TASK_MATCH T_RBRACE]

  | 12 ->
    [TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> Stack.push st.saved_ident st.sem_stack);
     TASK_PARSE NT_ASSIGN_REST]

  | 13 ->
    [TASK_MATCH T_EQ;
     TASK_ACTION (fun () ->
       let items = ref [] in
       while not (Stack.is_empty st.sem_stack) do
         items := Stack.pop st.sem_stack :: !items
       done;
       match !items with
       | [] -> ()
       | base :: fields ->
         emit st (OP_PUSH_ADDR base);
         if fields <> [] then emit st OP_LOAD;
         Stack.push base st.sem_stack;
         List.iter (fun f -> Stack.push f st.sem_stack) fields);
     TASK_PARSE NT_EXPR;
     TASK_ACTION (fun () ->
       let items = ref [] in
       while not (Stack.is_empty st.sem_stack) do
         items := Stack.pop st.sem_stack :: !items
       done;
       match !items with
       | [] -> ()
       | _ :: fields ->
         List.iter (fun f -> emit st (OP_SET_FIELD f)) fields;
         if fields = [] then emit st OP_STORE)]

  | 14 ->
    [TASK_MATCH T_LBRACKET;
     TASK_ACTION (fun () ->
       let id = Stack.pop st.sem_stack in
       emit st (OP_PUSH_ADDR id));
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_PARSE NT_ASSIGN_ARR]

  | 15 ->
    [TASK_MATCH T_EQ;
     TASK_ACTION (fun () -> emit st OP_INDEX);
     TASK_PARSE NT_EXPR;
     TASK_ACTION (fun () -> emit st OP_STORE)]

  | 16 ->
    [TASK_ACTION (fun () -> emit st OP_INDEX);
     TASK_MATCH T_LBRACKET;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_PARSE NT_ASSIGN_ARR2]

  | 17 ->
    [TASK_ACTION (fun () ->
       emit st (OP_ALLOC_ARR 1))]

  | 101 ->
    [TASK_ACTION (fun () -> emit st OP_INDEX2);
     TASK_MATCH T_EQ;
     TASK_PARSE NT_EXPR;
     TASK_ACTION (fun () -> emit st OP_STORE)]

  | 102 -> []

  | 18 ->
    let else_lbl = fresh_label st in
    let end_lbl = fresh_label st in
    [TASK_MATCH T_KW_IF;
     TASK_MATCH T_LPAREN;
     TASK_PARSE NT_COND;
     TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () -> emit st (OP_JMPF else_lbl));
     TASK_PARSE NT_STMT;
     TASK_ACTION (fun () ->
       emit st (OP_JMP end_lbl);
       emit st (OP_LABEL else_lbl));
     TASK_PARSE NT_ELSE_PART;
     TASK_ACTION (fun () -> emit st (OP_LABEL end_lbl))]

  | 19 ->
    [TASK_MATCH T_KW_ELSE;
     TASK_PARSE NT_STMT]

  | 20 -> []

  | 21 ->
    let start_lbl = fresh_label st in
    let end_lbl = fresh_label st in
    [TASK_ACTION (fun () -> emit st (OP_LABEL start_lbl));
     TASK_MATCH T_KW_WHILE;
     TASK_MATCH T_LPAREN;
     TASK_PARSE NT_COND;
     TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () -> emit st (OP_JMPF end_lbl));
     TASK_PARSE NT_STMT;
     TASK_ACTION (fun () ->
       emit st (OP_JMP start_lbl);
       emit st (OP_LABEL end_lbl))]

  | 22 ->
    let start_lbl = fresh_label st in
    let cond_lbl = fresh_label st in
    let incr_lbl = fresh_label st in
    let body_lbl = fresh_label st in
    let end_lbl = fresh_label st in
    [TASK_ACTION (fun () -> emit st (OP_LABEL start_lbl));
     TASK_MATCH T_KW_FOR;
     TASK_MATCH T_LPAREN;
     TASK_PARSE NT_ASSIGN_STMT;
     TASK_MATCH T_SEMICOLON;
     TASK_ACTION (fun () -> emit st (OP_LABEL cond_lbl));
     TASK_PARSE NT_COND;
     TASK_MATCH T_SEMICOLON;
     TASK_ACTION (fun () ->
       emit st (OP_JMPF end_lbl);
       emit st (OP_JMP body_lbl));
     TASK_ACTION (fun () -> emit st (OP_LABEL incr_lbl));
     TASK_PARSE NT_ASSIGN_STMT;
     TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () ->
       emit st (OP_JMP cond_lbl);
       emit st (OP_LABEL body_lbl));
     TASK_PARSE NT_STMT;
     TASK_ACTION (fun () ->
       emit st (OP_JMP incr_lbl);
       emit st (OP_LABEL end_lbl))]

  | 23 ->
    [TASK_MATCH T_KW_INPUT;
     TASK_PARSE NT_LVALUE;
     TASK_ACTION (fun () -> emit st OP_INPUT_STR);
     TASK_ACTION (fun () -> emit st OP_STORE)]

  | 24 ->
    [TASK_MATCH T_KW_OUTPUT;
     TASK_PARSE NT_OUTPUT_ARG;
     TASK_ACTION (fun () -> emit st OP_OUTPUT)]

  | 25 ->
    [TASK_PARSE NT_EXPR]

  | 26 ->
    [TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> Stack.push st.saved_ident st.sem_stack);
     TASK_PARSE NT_LVALUE_REST]

  | 27 ->
    [TASK_MATCH T_LBRACKET;
     TASK_ACTION (fun () ->
       let id = Stack.pop st.sem_stack in
       emit st (OP_PUSH_ADDR id));
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_ACTION (fun () -> emit st OP_INDEX);
     TASK_PARSE NT_LVALUE_ARR]

  | 28 ->
    [TASK_ACTION (fun () ->
       let id = Stack.pop st.sem_stack in
       emit st (OP_PUSH_ADDR id))]

  | 29 ->
    [TASK_MATCH T_LBRACKET;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_ACTION (fun () -> emit st OP_INDEX2)]

  | 30 -> []

  | 31 ->
    [TASK_PARSE NT_COND_TERM;
     TASK_PARSE NT_COND_REST]

  | 32 ->
    [TASK_MATCH T_OR;
     TASK_PARSE NT_COND_TERM;
     TASK_ACTION (fun () -> emit st OP_OR);
     TASK_PARSE NT_COND_REST]

  | 33 -> []

  | 34 ->
    [TASK_PARSE NT_COND_FACT;
     TASK_PARSE NT_COND_TERM_REST]

  | 35 ->
    [TASK_MATCH T_AND;
     TASK_PARSE NT_COND_FACT;
     TASK_ACTION (fun () -> emit st OP_AND);
     TASK_PARSE NT_COND_TERM_REST]

  | 36 -> []

  | 37 ->
    [TASK_PARSE NT_EXPR;
     TASK_PARSE NT_RELOP;
     TASK_PARSE NT_EXPR;
     TASK_ACTION (fun () ->
       match st.saved_relop with
       | T_LT -> emit st OP_LT
       | T_GT -> emit st OP_GT
       | T_LE -> emit st OP_LE
       | T_GE -> emit st OP_GE
       | T_EQEQ -> emit st OP_EQ
       | T_NE -> emit st OP_NE
       | _ -> emit st OP_EQ)]

  | 38 ->
    [TASK_MATCH T_NOT;
     TASK_PARSE NT_COND_FACT;
     TASK_ACTION (fun () -> emit st OP_NOT)]

  | 39 ->
    [TASK_MATCH T_LPAREN;
     TASK_PARSE NT_COND;
     TASK_MATCH T_RPAREN]

  | 40 ->
    [TASK_PARSE NT_TERM;
     TASK_PARSE NT_EXPR_TAIL]

  | 41 ->
    [TASK_MATCH T_PLUS;
     TASK_PARSE NT_TERM;
     TASK_ACTION (fun () -> emit st OP_ADD);
     TASK_PARSE NT_EXPR_TAIL]

  | 42 ->
    [TASK_MATCH T_MINUS;
     TASK_PARSE NT_TERM;
     TASK_ACTION (fun () -> emit st OP_SUB);
     TASK_PARSE NT_EXPR_TAIL]

  | 43 -> []

  | 44 ->
    [TASK_PARSE NT_FACTOR;
     TASK_PARSE NT_TERM_TAIL]

  | 45 ->
    [TASK_MATCH T_STAR;
     TASK_PARSE NT_FACTOR;
     TASK_ACTION (fun () -> emit st OP_MUL);
     TASK_PARSE NT_TERM_TAIL]

  | 46 ->
    [TASK_MATCH T_SLASH;
     TASK_PARSE NT_FACTOR;
     TASK_ACTION (fun () -> emit st OP_DIV);
     TASK_PARSE NT_TERM_TAIL]

  | 47 -> []

  | 48 ->
    [TASK_MATCH T_LPAREN;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RPAREN]

  | 49 ->
    [TASK_MATCH T_INT;
     TASK_ACTION (fun () ->
       try emit st (OP_PUSH_INT (int_of_string st.saved_ident))
       with _ -> ())]

  | 50 ->
    [TASK_MATCH T_REAL;
     TASK_ACTION (fun () ->
       try emit st (OP_PUSH_REAL (float_of_string st.saved_ident))
       with _ -> ())]

  | 51 ->
    [TASK_MATCH T_IDENT;
     TASK_ACTION (fun () ->
       emit st (OP_PUSH_ADDR st.saved_ident));
     TASK_PARSE NT_FACTOR_REST]

  | 52 ->
    [TASK_PARSE NT_FUNC_NAME;
     TASK_ACTION (fun () -> Stack.push st.saved_func st.sem_stack);
     TASK_MATCH T_LPAREN;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () ->
       let func = Stack.pop st.sem_stack in
       emit st (OP_CALL func))]

  | 53 ->
    [TASK_MATCH T_MINUS;
     TASK_PARSE NT_FACTOR;
     TASK_ACTION (fun () -> emit st OP_NEG)]

  | 54 ->
    [TASK_MATCH T_STRING;
     TASK_ACTION (fun () ->
       emit st (OP_PUSH_STR st.saved_ident))]

  | 55 ->
    [TASK_MATCH T_LBRACKET;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_ACTION (fun () -> emit st OP_INDEX);
     TASK_PARSE NT_FACTOR_ARR]

  | 56 ->
    [TASK_ACTION (fun () -> emit st OP_LOAD)]

  | 57 ->
    [TASK_MATCH T_LBRACKET;
     TASK_PARSE NT_EXPR;
     TASK_MATCH T_RBRACKET;
     TASK_ACTION (fun () -> emit st OP_INDEX2);
     TASK_ACTION (fun () -> emit st OP_LOAD)]

  | 58 ->
    [TASK_ACTION (fun () -> emit st OP_LOAD)]

  | 59 ->
    [TASK_MATCH T_LT;
     TASK_ACTION (fun () -> st.saved_relop <- T_LT)]

  | 60 ->
    [TASK_MATCH T_GT;
     TASK_ACTION (fun () -> st.saved_relop <- T_GT)]

  | 61 ->
    [TASK_MATCH T_LE;
     TASK_ACTION (fun () -> st.saved_relop <- T_LE)]

  | 62 ->
    [TASK_MATCH T_GE;
     TASK_ACTION (fun () -> st.saved_relop <- T_GE)]

  | 63 ->
    [TASK_MATCH T_EQEQ;
     TASK_ACTION (fun () -> st.saved_relop <- T_EQEQ)]

  | 64 ->
    [TASK_MATCH T_NE;
     TASK_ACTION (fun () -> st.saved_relop <- T_NE)]

  | 65 ->
    [TASK_MATCH T_KW_SQRT;
     TASK_ACTION (fun () -> st.saved_func <- "sqrt")]

  | 66 ->
    [TASK_MATCH T_KW_EXP;
     TASK_ACTION (fun () -> st.saved_func <- "exp")]

  | 67 ->
    [TASK_MATCH T_KW_LOG;
     TASK_ACTION (fun () -> st.saved_func <- "log")]

  | 68 ->
    [TASK_MATCH T_KW_SIN;
     TASK_ACTION (fun () -> st.saved_func <- "sin")]

  | 69 ->
    [TASK_MATCH T_KW_COS;
     TASK_ACTION (fun () -> st.saved_func <- "cos")]

  | 70 ->
    [TASK_MATCH T_KW_ABS;
     TASK_ACTION (fun () -> st.saved_func <- "abs")]

  | 71 ->
    [TASK_MATCH T_STRING;
     TASK_ACTION (fun () -> emit st (OP_PUSH_STR st.saved_ident))]

  | 72 -> [TASK_PARSE NT_FUNC_DEF]

  | 73 -> [TASK_PARSE NT_RETURN_STMT]

  | 74 ->
    let entry_lbl = fresh_label st in
    let end_lbl = fresh_label st in
    [TASK_MATCH T_KW_FUNC; TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> st.func_params <- []; Stack.push st.saved_ident st.sem_stack);
     TASK_MATCH T_LPAREN; TASK_PARSE NT_PARAM_LIST; TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () -> let n = Stack.pop st.sem_stack in let ps = List.rev st.func_params in
       emit st (OP_JMP end_lbl); emit st (OP_LABEL entry_lbl);
       emit st (OP_FUNC_ENTRY (n, entry_lbl, List.length ps));
       List.iter (fun p -> emit st (OP_ARG p)) ps);
     TASK_PARSE NT_BLOCK;
     TASK_ACTION (fun () ->
       emit st (OP_PUSH_INT 0);
       emit st OP_RET;
       emit st (OP_LABEL end_lbl))]

  | 75 ->
    [TASK_MATCH T_IDENT; TASK_ACTION (fun () -> st.func_params <- st.saved_ident :: st.func_params);
     TASK_PARSE NT_PARAM_LIST_TAIL]
  | 76 ->
    [TASK_MATCH T_COMMA; TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> st.func_params <- st.saved_ident :: st.func_params);
     TASK_PARSE NT_PARAM_LIST_TAIL]
  | 77 -> []
  | 78 -> []

  | 79 ->
    [TASK_MATCH T_KW_RETURN; TASK_PARSE NT_EXPR; TASK_ACTION (fun () -> emit st OP_RET)]

  | 80 ->
    [TASK_MATCH T_LPAREN; TASK_PARSE NT_ARG_LIST; TASK_MATCH T_RPAREN;
     TASK_ACTION (fun () -> emit st (OP_CALL_USER 0))]
  | 81 -> [TASK_PARSE NT_EXPR; TASK_PARSE NT_ARG_LIST_TAIL]
  | 82 -> []
  | 83 -> [TASK_MATCH T_COMMA; TASK_PARSE NT_EXPR; TASK_PARSE NT_ARG_LIST_TAIL]
  | 84 -> []

  | 85 ->
    [TASK_MATCH T_LPAREN; TASK_ACTION (fun () -> let id = Stack.pop st.sem_stack in emit st (OP_PUSH_ADDR id));
     TASK_PARSE NT_ARG_LIST; TASK_MATCH T_RPAREN; TASK_ACTION (fun () -> emit st (OP_CALL_USER 0))]

  | 86 -> [TASK_PARSE NT_SCHEMA_DEF]

  | 87 ->
    [TASK_MATCH T_KW_SCHEMA; TASK_MATCH T_IDENT; TASK_MATCH T_LBRACE;
     TASK_PARSE NT_FIELD_LIST; TASK_MATCH T_RBRACE]

  | 88 -> [TASK_MATCH T_IDENT; TASK_PARSE NT_FIELD_REST]
  | 89 -> [TASK_MATCH T_SEMICOLON; TASK_MATCH T_IDENT; TASK_PARSE NT_FIELD_REST]
  | 90 -> []

  | 91 ->
    [TASK_MATCH T_DOT; TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> Stack.push st.saved_ident st.sem_stack);
     TASK_PARSE NT_ASSIGN_REST]

  | 92 ->
    [TASK_MATCH T_DOT; TASK_MATCH T_IDENT;
     TASK_ACTION (fun () -> emit st OP_LOAD; emit st (OP_GET_FIELD st.saved_ident));
     TASK_PARSE NT_FACTOR_REST]

  | 93 ->
    [TASK_MATCH T_LBRACE; TASK_PARSE NT_FIELD_INIT_LIST; TASK_MATCH T_RBRACE;
     TASK_ACTION (fun () -> emit st (OP_MAKE_SCHEMA ""))]

  | 94 ->
    [TASK_MATCH T_IDENT; TASK_ACTION (fun () -> emit st (OP_PUSH_STR st.saved_ident));
     TASK_MATCH T_COLON; TASK_PARSE NT_EXPR; TASK_PARSE NT_FIELD_INIT_TAIL]
  | 95 -> []
  | 96 ->
    [TASK_MATCH T_COMMA; TASK_MATCH T_IDENT; TASK_ACTION (fun () -> emit st (OP_PUSH_STR st.saved_ident));
     TASK_MATCH T_COLON; TASK_PARSE NT_EXPR; TASK_PARSE NT_FIELD_INIT_TAIL]
  | 97 -> []

  | 98 ->
    [TASK_MATCH T_KW_STRING;
     TASK_ACTION (fun () -> st.saved_func <- "string")]

  | 99 ->
    [TASK_MATCH T_KW_REALFN;
     TASK_ACTION (fun () -> st.saved_func <- "real")]

  | 100 ->
    [TASK_MATCH T_KW_INTEGER;
     TASK_ACTION (fun () -> st.saved_func <- "integer")]

  | _ -> []

let parse tokens =
  let st = {
    ops = [];
    saved_ident = "";
    saved_func = "";
    saved_relop = T_EQEQ;
    sem_stack = Stack.create ();
    func_params = [];
    func_end_label = 0;
    label_ctr = 0;
    token_idx = 0;
    tokens = Array.of_list tokens;
    errors = [];
  } in

  let task_stack = Stack.create () in
  Stack.push (TASK_PARSE NT_PROGRAM) task_stack;

  let rec run () =
    if Stack.is_empty task_stack then ()
    else
      let task = Stack.pop task_stack in
      match task with
      | TASK_DONE -> run ()

      | TASK_MATCH tt ->
        let tok = current_token st in
        if tok.typ = tt then begin
          st.saved_ident <- tok.lexeme;
          ignore (advance st);
          run ()
        end else begin
          st.errors <- (Printf.sprintf "Syntax error at line %d, col %d: expected %s, got '%s' (%s)"
            tok.line tok.col
            (Grammar.string_of_token_type tt)
            tok.lexeme
            (Grammar.string_of_token_type tok.typ)) :: st.errors;
          ignore (advance st);
          run ()
        end

      | TASK_ACTION f ->
        f ();
        run ()

      | TASK_PARSE nt ->
        let tok = current_token st in
        begin match lookup nt tok.typ with
        | Some prod_id ->
          let tasks = make_actions st prod_id in
          List.iter (fun t -> Stack.push t task_stack) (List.rev tasks);
          run ()
        | None ->
          let has_epsilon = Array.exists (fun (p : production_entry) -> p.lhs = nt && p.rhs = [GS_EPSILON]) Grammar.productions in
          if has_epsilon then
            run ()
          else begin
            st.errors <- (Printf.sprintf "Syntax error at line %d, col %d: unexpected token '%s' (%s) while parsing %s"
              tok.line tok.col tok.lexeme
              (Grammar.string_of_token_type tok.typ)
              (string_of_nt nt)) :: st.errors;
            ignore (advance st);
            run ()
          end
        end
  in

  run ();
  (List.rev st.ops, List.rev st.errors)
