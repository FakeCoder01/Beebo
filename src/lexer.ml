open Types

type lexer_state =
  | S_START
  | S_ID
  | S_NUM
  | S_REAL_FRAC
  | S_STRING
  | S_OP
  | S_COMMENT_LINE
  | S_COMMENT_BLOCK
  | S_COMMENT_BLOCK_END
  | S_ERROR

type char_class =
  | CC_LETTER
  | CC_DIGIT
  | CC_DOT
  | CC_QUOTE
  | CC_PLUS
  | CC_MINUS
  | CC_STAR
  | CC_SLASH
  | CC_EQ
  | CC_LT
  | CC_GT
  | CC_LPAREN
  | CC_RPAREN
  | CC_LBRACE
  | CC_RBRACE
  | CC_LBRACKET
  | CC_RBRACKET
  | CC_SEMICOLON
  | CC_COMMA
  | CC_COLON
  | CC_EXCLAM
  | CC_AMPERSAND
  | CC_PIPE
  | CC_NEWLINE
  | CC_WHITESPACE
  | CC_OTHER
  | CC_EOF
  | CC_EOS

let char_classify c =
  match c with
  | 'a'..'z' | 'A'..'Z' | '_' -> CC_LETTER
  | '0'..'9' -> CC_DIGIT
  | '.' -> CC_DOT
  | '"' -> CC_QUOTE
  | '+' -> CC_PLUS
  | '-' -> CC_MINUS
  | '*' -> CC_STAR
  | '/' -> CC_SLASH
  | '=' -> CC_EQ
  | '<' -> CC_LT
  | '>' -> CC_GT
  | '(' -> CC_LPAREN
  | ')' -> CC_RPAREN
  | '{' -> CC_LBRACE
  | '}' -> CC_RBRACE
  | '[' -> CC_LBRACKET
  | ']' -> CC_RBRACKET
  | ';' -> CC_SEMICOLON
  | ',' -> CC_COMMA
  | ':' -> CC_COLON
  | '!' -> CC_EXCLAM
  | '&' -> CC_AMPERSAND
  | '|' -> CC_PIPE
  | '\n' -> CC_NEWLINE
  | ' ' | '\t' | '\r' -> CC_WHITESPACE
  | _ -> CC_OTHER

module CharClassTbl = Hashtbl.Make(struct
  type t = lexer_state * char_class
  let equal (s1, c1) (s2, c2) = s1 = s2 && c1 == c2
  let hash (s, c) = Hashtbl.hash (Hashtbl.hash s, Hashtbl.hash c)
end)

let trans_table =
  let t = CharClassTbl.create 200 in

  let add s c next = CharClassTbl.add t (s, c) next in

  add S_START CC_LETTER S_ID;
  add S_START CC_DIGIT S_NUM;
  add S_START CC_DOT S_OP;
  add S_START CC_QUOTE S_STRING;
  add S_START CC_PLUS S_OP;
  add S_START CC_MINUS S_OP;
  add S_START CC_STAR S_OP;
  add S_START CC_SLASH S_OP;
  add S_START CC_EQ S_OP;
  add S_START CC_LT S_OP;
  add S_START CC_GT S_OP;
  add S_START CC_LPAREN S_OP;
  add S_START CC_RPAREN S_OP;
  add S_START CC_LBRACE S_OP;
  add S_START CC_RBRACE S_OP;
  add S_START CC_LBRACKET S_OP;
  add S_START CC_RBRACKET S_OP;
  add S_START CC_SEMICOLON S_OP;
  add S_START CC_COMMA S_OP;
  add S_START CC_COLON S_OP;
  add S_START CC_EXCLAM S_OP;
  add S_START CC_AMPERSAND S_OP;
  add S_START CC_PIPE S_OP;
  add S_START CC_NEWLINE S_START;
  add S_START CC_WHITESPACE S_START;
  add S_START CC_EOF S_START;
  add S_START CC_OTHER S_ERROR;

  add S_ID CC_LETTER S_ID;
  add S_ID CC_DIGIT S_ID;
  add S_ID CC_DOT S_START;
  add S_ID CC_OTHER S_START;
  add S_ID CC_EOF S_START;
  add S_ID CC_EOS S_START;

  add S_NUM CC_DIGIT S_NUM;
  add S_NUM CC_DOT S_NUM;
  add S_NUM CC_LETTER S_ERROR;
  add S_NUM CC_OTHER S_START;
  add S_NUM CC_EOF S_START;
  add S_NUM CC_EOS S_START;

  add S_REAL_FRAC CC_DIGIT S_REAL_FRAC;
  add S_REAL_FRAC CC_LETTER S_ERROR;
  add S_REAL_FRAC CC_OTHER S_START;
  add S_REAL_FRAC CC_EOF S_START;
  add S_REAL_FRAC CC_EOS S_START;

  add S_STRING CC_QUOTE S_STRING;
  add S_STRING CC_NEWLINE S_ERROR;

  add S_OP CC_EQ S_OP;
  add S_OP CC_LT S_OP;
  add S_OP CC_GT S_OP;
  add S_OP CC_EXCLAM S_OP;
  add S_OP CC_AMPERSAND S_OP;
  add S_OP CC_PIPE S_OP;
  add S_STRING CC_EOF S_ERROR;
  add S_STRING CC_OTHER S_STRING;
  add S_STRING CC_EOS S_STRING;

  add S_OP CC_OTHER S_START;
  add S_OP CC_EOF S_START;
  add S_OP CC_EOS S_START;

  add S_COMMENT_LINE CC_NEWLINE S_START;
  add S_COMMENT_LINE CC_EOF S_START;
  add S_COMMENT_LINE CC_OTHER S_COMMENT_LINE;
  add S_COMMENT_LINE CC_EOS S_COMMENT_LINE;

  add S_COMMENT_BLOCK CC_STAR S_COMMENT_BLOCK_END;
  add S_COMMENT_BLOCK CC_EOF S_ERROR;
  add S_COMMENT_BLOCK CC_OTHER S_COMMENT_BLOCK;
  add S_COMMENT_BLOCK CC_EOS S_COMMENT_BLOCK;

  add S_COMMENT_BLOCK_END CC_SLASH S_START;
  add S_COMMENT_BLOCK_END CC_STAR S_COMMENT_BLOCK_END;
  add S_COMMENT_BLOCK_END CC_EOF S_ERROR;
  add S_COMMENT_BLOCK_END CC_OTHER S_COMMENT_BLOCK;
  add S_COMMENT_BLOCK_END CC_EOS S_COMMENT_BLOCK;

  add S_ERROR CC_OTHER S_START;
  add S_ERROR CC_EOF S_START;
  add S_ERROR CC_EOS S_START;

  t

let next_state state cc =
  match CharClassTbl.find_opt trans_table (state, cc) with
  | Some s -> s
  | None ->
    match state with
    | S_ID | S_NUM | S_REAL_FRAC | S_OP -> S_START
    | S_STRING -> S_STRING
    | S_COMMENT_LINE -> S_COMMENT_LINE
    | S_COMMENT_BLOCK | S_COMMENT_BLOCK_END -> S_COMMENT_BLOCK
    | _ -> S_START

let keyword_map =
  let open TokenTbl in
  let t = create 20 in
  let add s kw = add t s kw in
  add T_KW_IF "if";
  add T_KW_ELSE "else";
  add T_KW_WHILE "while";
  add T_KW_FOR "for";
  add T_KW_INPUT "input";
  add T_KW_OUTPUT "output";
  add T_KW_SQRT "sqrt";
  add T_KW_EXP "exp";
  add T_KW_LOG "log";
  add T_KW_SIN "sin";
  add T_KW_COS "cos";
  add T_KW_ABS "abs";
  add T_KW_STRING "string";
  add T_KW_REALFN "real";
  add T_KW_INTEGER "integer";
  add T_KW_FUNC "func";
  add T_KW_RETURN "return";
  add T_KW_SCHEMA "schema";
  t

let resolve_keyword s =
  TokenTbl.fold (fun tt kw acc ->
    if kw = s then Some tt else acc
  ) keyword_map None

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

let token_type_of_str s =
  match s with
  | "+" -> T_PLUS
  | "-" -> T_MINUS
  | "*" -> T_STAR
  | "/" -> T_SLASH
  | "=" -> T_EQ
  | "<" -> T_LT
  | ">" -> T_GT
  | "<=" -> T_LE
  | ">=" -> T_GE
  | "==" -> T_EQEQ
  | "!=" -> T_NE
  | "&&" -> T_AND
  | "||" -> T_OR
  | "!" -> T_NOT
  | "(" -> T_LPAREN
  | ")" -> T_RPAREN
  | "{" -> T_LBRACE
  | "}" -> T_RBRACE
  | "[" -> T_LBRACKET
  | "]" -> T_RBRACKET
  | ";" -> T_SEMICOLON
  | "," -> T_COMMA
  | "." -> T_DOT
  | ":" -> T_COLON
  | _ -> T_IDENT

let is_op_char c =
  match c with
  | '+' | '-' | '*' | '/' | '=' | '<' | '>' | '!' | '&' | '|'
  | '(' | ')' | '{' | '}' | '[' | ']' | ';' | ',' -> true
  | _ -> false

let is_compound_op s =
  match s with
  | "<=" | ">=" | "==" | "!=" | "&&" | "||" -> true
  | _ -> false

let is_valid_op_prefix s =
  match s with
  | "<" | ">" | "=" | "!" | "&" | "|" -> true
  | _ -> false

let tokenize source =
  let len = String.length source in
  let tokens = ref [] in
  let pos = ref 0 in
  let line = ref 1 in
  let col = ref 1 in
  let line_start = ref 0 in
  let errors = ref [] in
  let is_digit_char c = c >= '0' && c <= '9' in

  let get_char i =
    if i < len then source.[i] else '\x00'
  in

  let make_token tt lex l c =
    { typ = tt; lexeme = lex; line = l; col = c }
  in

  let rec emit_token tt lex l c =
    tokens := (make_token tt lex l c) :: !tokens
  in

  let process_escapes s =
    let len = String.length s in
    let buf = Buffer.create len in
    let i = ref 0 in
    while !i < len do
      if s.[!i] = '\\' && !i + 1 < len then begin
        incr i;
        match s.[!i] with
        | 'n' -> Buffer.add_char buf '\n'
        | 't' -> Buffer.add_char buf '\t'
        | '\\' -> Buffer.add_char buf '\\'
        | '"' -> Buffer.add_char buf '"'
        | c -> Buffer.add_char buf '\\'; Buffer.add_char buf c
      end else begin
        Buffer.add_char buf s.[!i]
      end;
      incr i
    done;
    Buffer.contents buf
  in

  let flush_token lxbuf state st_line st_col =
    let lexeme = Buffer.contents lxbuf in
    if lexeme <> "" || state = S_STRING then begin
      let lexeme = if state = S_STRING then process_escapes lexeme else lexeme in
      match state with
      | S_ID | S_NUM | S_REAL_FRAC ->
        begin match resolve_keyword lexeme with
        | Some kt -> emit_token kt lexeme st_line st_col
        | None ->
          if state = S_NUM then
            if String.contains lexeme '.' then
              emit_token T_REAL lexeme st_line st_col
            else
              emit_token T_INT lexeme st_line st_col
          else if state = S_REAL_FRAC then
            emit_token T_REAL lexeme st_line st_col
          else
            emit_token T_IDENT lexeme st_line st_col
        end
      | S_STRING ->
        emit_token T_STRING lexeme st_line st_col
      | S_OP ->
        emit_token (token_type_of_str lexeme) lexeme st_line st_col
      | _ -> ()
    end
  in

  let advance () =
    pos := !pos + 1;
    col := !col + 1
  in

  let newline () =
    pos := !pos + 1;
    line := !line + 1;
    line_start := !pos;
    col := 1
  in

  let rec scan () =
    if !pos >= len then (
      emit_token T_EOF "" !line (!pos - !line_start + 1)
    ) else (
      let c = get_char !pos in

      if c = '/' then (
        let slash_line = !line in
        let slash_col = !col in
        advance ();
        let next_ch = if !pos < len then get_char !pos else '\x00' in
        if next_ch = '/' then (
          advance ();
          while !pos < len && get_char !pos <> '\n' do
            advance ()
          done;
          scan ()
        ) else if next_ch = '*' then (
          advance ();
          let rec skip_block () =
            if !pos >= len then (
              errors := (Printf.sprintf "Unterminated block comment at line %d, col %d" slash_line slash_col) :: !errors
            ) else (
              let ch = get_char !pos in
              if ch = '*' && !pos + 1 < len && get_char (!pos + 1) = '/' then (
                advance ();
                advance ();
                scan ()
              ) else if ch = '\n' then (
                newline ();
                skip_block ()
              ) else begin
                advance ();
                skip_block ()
              end
            )
          in
          skip_block ()
        ) else begin
          let lexbuf = Buffer.create 1 in
          Buffer.add_char lexbuf '/';
          emit_token T_SLASH "/" !line !col;
          scan ()
        end
      ) else begin

      let state = ref S_START in
      let lexbuf = Buffer.create 32 in
      let st_line = ref !line in
      let st_col = ref !col in

      let rec scan_from_state () =
        let lookahead = get_char !pos in
        let la_cc = char_classify lookahead in

        let next = next_state !state la_cc in

        match next with
        | S_START ->
          if !state = S_START && la_cc = CC_WHITESPACE then (
            if lookahead = '\n' then newline () else advance ();
            scan ()
          ) else if !state = S_START && la_cc = CC_NEWLINE then (
            newline ();
            scan ()
          ) else if !state = S_START && la_cc = CC_EOF then (
            emit_token T_EOF "" !line !col
          ) else if !state = S_START then begin
            st_line := !line;
            st_col := !col;
            state := next;
            if next = S_OP then begin
              let ch = lookahead in
              if ch = '/' then begin
                advance ();
                let next_ch = get_char !pos in
                if next_ch = '/' then begin
                  advance ();
                  state := S_COMMENT_LINE;
                  scan ()
                end else if next_ch = '*' then begin
                  advance ();
                  state := S_COMMENT_BLOCK;
                  scan ()
                end else begin
                  Buffer.add_char lexbuf '/';
                  flush_token lexbuf !state !st_line !st_col;
                  scan ()
                end
              end else begin
                Buffer.add_char lexbuf ch;
                advance ();
                scan_from_state ()
              end
            end else begin
              Buffer.add_char lexbuf lookahead;
              advance ();
              scan_from_state ()
            end
          end else if !state = S_ID || !state = S_NUM || !state = S_REAL_FRAC then begin
            flush_token lexbuf !state !st_line !st_col;
            scan ()
          end else begin
            flush_token lexbuf !state !st_line !st_col;
            scan ()
          end
        | S_ID ->
          state := S_ID;
          Buffer.add_char lexbuf lookahead;
          advance ();
          scan_from_state ()
        | S_NUM ->
          if !state = S_NUM && lookahead = '.' then begin
            state := S_REAL_FRAC;
            Buffer.add_char lexbuf lookahead;
            advance ();
            scan_from_state ()
          end else begin
            state := S_NUM;
            Buffer.add_char lexbuf lookahead;
            advance ();
            scan_from_state ()
          end
        | S_REAL_FRAC ->
          state := S_REAL_FRAC;
          Buffer.add_char lexbuf lookahead;
          advance ();
          scan_from_state ()
        | S_STRING ->
          if lookahead = '"' then begin
            if !state = S_STRING then begin
              advance ();
              flush_token lexbuf S_STRING !st_line !st_col;
              scan ()
            end else begin
              state := S_STRING;
              advance ();
              scan_from_state ()
            end
          end else if lookahead = '\n' then begin
            errors := (Printf.sprintf "Unterminated string at line %d" !st_line) :: !errors;
            newline ();
            flush_token lexbuf S_STRING !st_line !st_col;
            scan ()
          end else begin
            state := S_STRING;
            Buffer.add_char lexbuf lookahead;
            advance ();
            scan_from_state ()
          end
        | S_OP ->
          begin match !state, lookahead with
          | S_OP, c2 when is_compound_op (Buffer.contents lexbuf ^ String.make 1 c2) ->
            Buffer.add_char lexbuf lookahead;
            advance ();
            flush_token lexbuf S_OP !st_line !st_col;
            scan ()
          | S_OP, _ ->
            flush_token lexbuf S_OP !st_line !st_col;
            scan ()
          | _ ->
            state := S_OP;
            Buffer.add_char lexbuf lookahead;
            advance ();
            scan_from_state ()
          end
        | S_ERROR ->
          if (!state = S_NUM || !state = S_REAL_FRAC) && (lookahead = 'e' || lookahead = 'E') then begin
            let exp_line = !line in
            let exp_col = !col in
            Buffer.add_char lexbuf lookahead;
            advance ();
            if !pos < len && (get_char !pos = '+' || get_char !pos = '-') then begin
              Buffer.add_char lexbuf (get_char !pos);
              advance ()
            end;
            let digit_start = !pos in
            while !pos < len && is_digit_char (get_char !pos) do
              Buffer.add_char lexbuf (get_char !pos);
              advance ()
            done;
            if !pos = digit_start then begin
              errors := (Printf.sprintf "Invalid exponent in number at line %d, col %d" exp_line exp_col) :: !errors;
              scan ()
            end else begin
              state := S_REAL_FRAC;
              scan_from_state ()
            end
          end else if lookahead = '"' then begin
            errors := (Printf.sprintf "Unterminated string at line %d" !st_line) :: !errors;
            flush_token lexbuf S_STRING !st_line !st_col;
            scan ()
          end else begin
            errors := (Printf.sprintf "Unexpected character '%c' at line %d, col %d" lookahead !line !col) :: !errors;
            advance ();
            scan ()
          end
        | _ ->
          scan ()
      in
      scan_from_state ()
      end
    )
  in
  scan ();
  (List.rev !tokens, List.rev !errors)
