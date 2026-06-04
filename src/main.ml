open Types
open Lexer
open Parser
open Interpreter

let print_usage () =
  Printf.eprintf "Beebo Compiler-Interpreter v1.0\n";
  Printf.eprintf "Usage: beebo [options] <file.bbo>\n";
  Printf.eprintf "  --tokens     Print token list after lexical analysis\n";
  Printf.eprintf "  --ops        Print generated OPS (Polish notation) code\n";
  Printf.eprintf "  --run        Execute the program (default)\n";
  Printf.eprintf "  --help       Show this help\n"

let print_tokens tokens =
  Printf.printf "=== LEXEMES (token list) ===\n";
  List.iteri (fun i t ->
    Printf.printf "%3d: %-12s  '%s'  (line %d, col %d)\n"
      i
      (string_of_token_type t.typ)
      t.lexeme
      t.line
      t.col
  ) tokens;
  Printf.printf "=== Total: %d tokens ===\n" (List.length tokens)

let opcode_name = function
  | OP_PUSH_INT n -> Printf.sprintf "PUSH_INT %d" n
  | OP_PUSH_REAL r -> Printf.sprintf "PUSH_REAL %g" r
  | OP_PUSH_STR s -> Printf.sprintf "PUSH_STR \"%s\"" s
  | OP_PUSH_ADDR s -> Printf.sprintf "PUSH_ADDR %s" s
  | OP_LOAD -> "LOAD"
  | OP_STORE -> "STORE"
  | OP_ADD -> "ADD"
  | OP_SUB -> "SUB"
  | OP_MUL -> "MUL"
  | OP_DIV -> "DIV"
  | OP_NEG -> "NEG"
  | OP_EQ -> "EQ"
  | OP_NE -> "NE"
  | OP_LT -> "LT"
  | OP_GT -> "GT"
  | OP_LE -> "LE"
  | OP_GE -> "GE"
  | OP_NOT -> "NOT"
  | OP_AND -> "AND"
  | OP_OR -> "OR"
  | OP_JMP n -> Printf.sprintf "JMP L%d" n
  | OP_JMPF n -> Printf.sprintf "JMPF L%d" n
  | OP_INPUT_INT -> "INPUT_INT"
  | OP_INPUT_REAL -> "INPUT_REAL"
  | OP_INPUT_STR -> "INPUT_STR"
  | OP_OUTPUT -> "OUTPUT"
  | OP_CALL s -> Printf.sprintf "CALL %s" s
  | OP_CALL_USER _ -> "CALL_USER"
  | OP_RET -> "RET"
  | OP_ARG s -> Printf.sprintf "ARG %s" s
  | OP_FUNC_ENTRY (s, l, c) -> Printf.sprintf "FUNC_ENTRY %s L%d(%d)" s l c
  | OP_GET_FIELD s -> Printf.sprintf "GET_FIELD %s" s
  | OP_SET_FIELD s -> Printf.sprintf "SET_FIELD %s" s
  | OP_MAKE_SCHEMA s -> Printf.sprintf "MAKE_SCHEMA %s" s
  | OP_ALLOC_ARR n -> Printf.sprintf "ALLOC_ARR %d" n
  | OP_INDEX -> "INDEX"
  | OP_INDEX2 -> "INDEX2"
  | OP_LABEL n -> Printf.sprintf "L%d:" n
  | OP_HALT -> "HALT"

let print_ops ops =
  Printf.printf "=== OPS (Polish notation) code ===\n";
  List.iteri (fun i op ->
    Printf.printf "%4d: %s\n" i (opcode_name op)
  ) ops;
  Printf.printf "=== Total: %d operations ===\n" (List.length ops)

let read_file filename =
  let ic = open_in filename in
  let buf = Buffer.create 4096 in
  let rec loop () =
    try
      Buffer.add_string buf (input_line ic);
      Buffer.add_char buf '\n';
      loop ()
    with End_of_file -> ()
  in
  (try loop () with End_of_file -> ());
  close_in ic;
  Buffer.contents buf

let () =
  let args = List.tl (Array.to_list Sys.argv) in
  let show_tokens = ref false in
  let show_ops = ref false in
  let do_run = ref true in
  let filename = ref "" in

  let rec process_args = function
    | [] -> ()
    | "--tokens" :: rest -> show_tokens := true; process_args rest
    | "--ops" :: rest -> show_ops := true; process_args rest
    | "--run" :: rest -> do_run := true; process_args rest
    | "--help" :: _ -> print_usage (); exit 0
    | f :: rest ->
      if String.length f > 0 && f.[0] = '-' then (
        Printf.eprintf "Unknown option: %s\n" f;
        print_usage ();
        exit 1
      ) else (
        filename := f;
        process_args rest
      )
  in

  process_args args;

  if !filename = "" then (
    Printf.eprintf "Error: no input file specified\n";
    print_usage ();
    exit 1
  );

  let source =
    try read_file !filename
    with Sys_error msg ->
      Printf.eprintf "Error reading file '%s': %s\n" !filename msg;
      exit 1
  in

  let tokens, lex_errors = tokenize source in

  if lex_errors <> [] then (
    Printf.eprintf "=== LEXICAL ERRORS ===\n";
    List.iter (fun e -> Printf.eprintf "%s\n" e) lex_errors;
    if List.length lex_errors > 0 && not !show_tokens then (
      Printf.eprintf "Lexical analysis failed. Fix errors and try again.\n";
      exit 1
    )
  );

  if !show_tokens then
    print_tokens tokens;

  let ops, parse_errors = parse tokens in

  if parse_errors <> [] then (
    Printf.eprintf "=== SYNTAX ERRORS ===\n";
    List.iter (fun e -> Printf.eprintf "%s\n" e) parse_errors;
    Printf.eprintf "Parsing failed. Fix errors and try again.\n";
    exit 1
  );

  if !show_ops then
    print_ops ops;

  if !do_run then (
    let runtime_errors = interpret ops [] in
    if runtime_errors <> [] then (
      Printf.eprintf "=== RUNTIME ERRORS ===\n";
      List.iter (fun e -> Printf.eprintf "%s\n" e) runtime_errors
    )
  )
