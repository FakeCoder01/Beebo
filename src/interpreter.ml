open Types

type memory_t = (string, var_value) Hashtbl.t

let type_name = function
  | V_INT _ -> "integer"
  | V_REAL _ -> "real"
  | V_STR _ -> "string"
  | V_ARR _ -> "array"
  | V_MAT _ -> "matrix"
  | _ -> "unknown"

let rec value_to_string = function
  | V_INT n -> string_of_int n
  | V_REAL r ->
    let s = Printf.sprintf "%.6g" r in
    if String.contains s '.' || String.contains s 'e' || String.contains s 'E'
    then s else s ^ ".0"
  | V_STR s -> s
  | V_ARR arr ->
    let elems = Array.to_list arr |> List.map value_to_string |> String.concat ", " in
    "[" ^ elems ^ "]"
  | V_MAT mat ->
    let rows = Array.to_list mat |> List.map (fun row ->
      let elems = Array.to_list row |> List.map value_to_string |> String.concat ", " in
      "[" ^ elems ^ "]"
    ) |> String.concat "\n " in
    "[\n " ^ rows ^ "\n]"
  | V_ADDR_SIMPLE s -> "<addr:" ^ s ^ ">"
  | V_ADDR_ARR (s, i) -> "<addr:" ^ s ^ "[" ^ string_of_int i ^ "]>"
  | V_ADDR_ARR2 (s, i, j) -> "<addr:" ^ s ^ "[" ^ string_of_int i ^ "][" ^ string_of_int j ^ "]>"
  | V_NONE -> "null"
  | V_SCHEMA (name, fields) ->
    let items = Hashtbl.fold (fun k v acc ->
      (k ^ ": " ^ value_to_string v) :: acc
    ) fields [] in
    name ^ "{" ^ String.concat ", " (List.rev items) ^ "}"
  | V_RET_ADDR _ -> "<return>"

let promote_to_real = function
  | V_INT n -> V_REAL (float_of_int n)
  | V_REAL _ as v -> v
  | v -> failwith ("Cannot promote " ^ type_name v ^ " to real")

let to_float = function
  | V_INT n -> float_of_int n
  | V_REAL r -> r
  | _ -> failwith "Expected numeric value"

let to_int = function
  | V_INT n -> n
  | V_REAL r -> int_of_float r
  | _ -> failwith "Expected numeric value"

let to_bool = function
  | V_INT 0 -> false
  | V_REAL 0.0 -> false
  | V_INT _ | V_REAL _ -> true
  | V_STR "" -> false
  | V_STR _ -> true
  | _ -> false

let bool_to_val b = V_INT (if b then 1 else 0)

let load_from_memory mem addr =
  match addr with
  | V_ADDR_SIMPLE name ->
    begin match Hashtbl.find_opt mem name with
    | Some v -> v
    | None -> V_INT 0
    end
  | V_ADDR_ARR (name, i) ->
    begin match Hashtbl.find_opt mem name with
    | Some (V_ARR arr) ->
      if i >= 0 && i < Array.length arr then arr.(i)
      else V_INT 0
    | Some _ -> failwith ("Variable '" ^ name ^ "' is not an array")
    | None -> V_INT 0
    end
  | V_ADDR_ARR2 (name, i, j) ->
    begin match Hashtbl.find_opt mem name with
    | Some (V_MAT mat) ->
      if i >= 0 && i < Array.length mat
         && j >= 0 && j < Array.length mat.(i)
      then mat.(i).(j)
      else V_INT 0
    | Some (V_ARR arr) ->
      if i >= 0 && i < Array.length arr then
        match arr.(i) with
        | V_ARR inner ->
          if j >= 0 && j < Array.length inner then inner.(j) else V_INT 0
        | v -> if j = 0 then v else V_INT 0
      else V_INT 0
    | Some _ -> V_INT 0
    | None -> V_INT 0
    end
  | V_ARR _ | V_MAT _ ->
    begin match addr with
    | V_ARR arr ->
      V_ARR arr
    | _ -> failwith "Invalid address type"
    end
  | v -> v

let store_to_memory mem addr value =
  match addr with
  | V_ADDR_SIMPLE name ->
    Hashtbl.replace mem name value
  | V_ADDR_ARR (name, i) ->
    begin match Hashtbl.find_opt mem name with
    | Some (V_ARR arr) ->
      if i >= 0 && i < Array.length arr then
        arr.(i) <- value
      else if i >= 0 then begin
        let new_arr = Array.make (i + 1) (V_INT 0) in
        Array.blit arr 0 new_arr 0 (Array.length arr);
        new_arr.(i) <- value;
        Hashtbl.replace mem name (V_ARR new_arr)
      end
    | Some _ -> failwith ("Variable '" ^ name ^ "' is not an array")
    | None ->
      let arr = Array.make (i + 1) (V_INT 0) in
      arr.(i) <- value;
      Hashtbl.replace mem name (V_ARR arr)
    end
  | V_ADDR_ARR2 (name, i, j) ->
    begin match Hashtbl.find_opt mem name with
    | Some (V_MAT mat) ->
      if i >= 0 && i < Array.length mat
         && j >= 0 && j < Array.length mat.(i)
      then mat.(i).(j) <- value
      else begin
        let rows = max (i + 1) (Array.length mat) in
        let cols = ref (if Array.length mat > 0 then Array.length mat.(0) else 0) in
        cols := max (j + 1) !cols;
        let new_mat = Array.make_matrix rows !cols (V_INT 0) in
        for ri = 0 to Array.length mat - 1 do
          for rj = 0 to Array.length mat.(ri) - 1 do
            new_mat.(ri).(rj) <- mat.(ri).(rj)
          done
        done;
        new_mat.(i).(j) <- value;
        Hashtbl.replace mem name (V_MAT new_mat)
      end
    | Some (V_ARR arr) ->
      if i >= 0 && i < Array.length arr then
        match arr.(i) with
        | V_ARR inner ->
          if j >= 0 && j < Array.length inner then
            inner.(j) <- value
          else begin
            let new_inner = Array.make (j + 1) (V_INT 0) in
            Array.blit inner 0 new_inner 0 (Array.length inner);
            new_inner.(j) <- value;
            arr.(i) <- V_ARR new_inner
          end
        | _ ->
          let new_inner = Array.make (j + 1) (V_INT 0) in
          new_inner.(j) <- value;
          arr.(i) <- V_ARR new_inner
      else begin
        let new_arr = Array.make (i + 1) (V_INT 0) in
        Array.blit arr 0 new_arr 0 (Array.length arr);
        let new_inner = Array.make (j + 1) (V_INT 0) in
        new_inner.(j) <- value;
        new_arr.(i) <- V_ARR new_inner;
        Hashtbl.replace mem name (V_ARR new_arr)
      end
    | Some _ -> failwith ("Variable '" ^ name ^ "' is not a matrix")
    | None ->
      let inner = Array.make (j + 1) (V_INT 0) in
      inner.(j) <- value;
      let arr = Array.make (i + 1) (V_INT 0) in
      arr.(i) <- V_ARR inner;
      Hashtbl.replace mem name (V_ARR arr)
    end
  | _ -> failwith "Cannot store to non-address value"

let allocate_array mem name dims =
  if dims = 1 then (
    let arr = Array.make 0 (V_INT 0) in
    Hashtbl.replace mem name (V_ARR arr)
  ) else if dims = 2 then (
    let mat = Array.make_matrix 0 0 (V_INT 0) in
    Hashtbl.replace mem name (V_MAT mat)
  )

let math_call func arg =
  match func with
  | "string" -> V_STR (value_to_string arg)
  | "real" ->
    begin match arg with
    | V_INT n -> V_REAL (float_of_int n)
    | V_STR s -> (try V_REAL (float_of_string s) with _ -> V_REAL 0.0)
    | _ -> arg
    end
  | "integer" ->
    begin match arg with
    | V_REAL r -> V_INT (int_of_float r)
    | V_STR s -> (try V_INT (int_of_string s) with _ -> V_INT 0)
    | _ -> arg
    end
  | _ ->
    let x = to_float arg in
    let result = match func with
    | "sqrt" -> if x < 0.0 then failwith "sqrt of negative number" else sqrt x
    | "exp" -> exp x
    | "log" -> if x <= 0.0 then failwith "log of non-positive number" else log x
    | "sin" -> sin x
    | "cos" -> cos x
    | "abs" -> abs_float x
    | _ -> failwith ("Unknown function: " ^ func)
    in
    match arg with
    | V_INT _ -> V_REAL result
    | V_REAL _ -> V_REAL result
    | _ -> V_REAL result

let builtins = Hashtbl.create 10
let () =
  List.iter (fun (n, f) -> Hashtbl.add builtins n f) [
    "sqrt", sqrt;
    "exp", exp;
    "log", log;
    "sin", sin;
    "cos", cos;
    "abs", abs_float;
  ]

let build_label_map ops =
  let labels = Hashtbl.create 50 in
  List.iteri (fun i op ->
    match op with
    | OP_LABEL n -> Hashtbl.replace labels n i
    | _ -> ()
  ) ops;
  labels

let build_func_table ops labels =
  let ft = Hashtbl.create 20 in
  List.iter (fun op ->
    match op with
    | OP_FUNC_ENTRY (name, entry_lbl, param_count) ->
      begin match Hashtbl.find_opt labels entry_lbl with
      | Some entry_pc -> Hashtbl.replace ft name (entry_pc, param_count)
      | None -> ()
      end
    | _ -> ()
  ) ops;
  ft

let interpret ops input_lines =
  let labels = build_label_map ops in
  let func_table = build_func_table ops labels in
  let ops_arr = Array.of_list ops in
  let mem : memory_t = Hashtbl.create 100 in
  let stack = Stack.create () in
  let pc = ref 0 in
  let input_idx = ref 0 in
  let errors = ref [] in

  let push v = Stack.push v stack in
  let pop () =
    if Stack.is_empty stack then
      failwith "Stack underflow"
    else
      Stack.pop stack
  in

  let read_input () =
    if !input_idx < List.length input_lines then (
      let line = List.nth input_lines !input_idx in
      input_idx := !input_idx + 1;
      line
    ) else (
      try
        let line = read_line () in
        line
      with End_of_file -> ""
    )
  in

  let step () =
    if !pc >= Array.length ops_arr then false
    else
      let op = ops_arr.(!pc) in
      pc := !pc + 1;
      match op with
      | OP_HALT -> false

      | OP_PUSH_INT n ->
        push (V_INT n);
        true

      | OP_PUSH_REAL r ->
        push (V_REAL r);
        true

      | OP_PUSH_STR s ->
        push (V_STR s);
        true

      | OP_PUSH_ADDR name ->
        push (V_ADDR_SIMPLE name);
        true

      | OP_INDEX ->
        let idx_val = pop () in
        let base = pop () in
        begin match base, idx_val with
        | V_ADDR_SIMPLE name, V_INT i ->
          push (V_ADDR_ARR (name, i))
        | V_ADDR_SIMPLE name, V_REAL r ->
          push (V_ADDR_ARR (name, int_of_float r))
        | _ ->
          errors := ("INDEX: expected address and integer index") :: !errors;
          push V_NONE
        end;
        true

      | OP_INDEX2 ->
        let idx2_val = pop () in
        let addr1 = pop () in
        begin match addr1, idx2_val with
        | V_ADDR_ARR (name, i), V_INT j ->
          push (V_ADDR_ARR2 (name, i, j))
        | V_ADDR_ARR (name, i), V_REAL r ->
          push (V_ADDR_ARR2 (name, i, int_of_float r))
        | _ ->
          errors := ("INDEX2: expected array address and integer index") :: !errors;
          push V_NONE
        end;
        true

      | OP_LOAD ->
        let addr = pop () in
        begin match addr with
        | V_ADDR_SIMPLE _ | V_ADDR_ARR _ | V_ADDR_ARR2 _ ->
          push (load_from_memory mem addr)
        | _ ->
          push addr
        end;
        true

      | OP_STORE ->
        let value = pop () in
        let addr = pop () in
        store_to_memory mem addr value;
        true

      | OP_ADD ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (V_INT (a' + b'))
        | V_REAL a', V_INT b' -> push (V_REAL (a' +. float_of_int b'))
        | V_INT a', V_REAL b' -> push (V_REAL (float_of_int a' +. b'))
        | V_REAL a', V_REAL b' -> push (V_REAL (a' +. b'))
        | V_STR a', V_STR b' -> push (V_STR (a' ^ b'))
        | V_STR a', _ ->
          push (V_STR (a' ^ value_to_string b))
        | _, V_STR b' ->
          push (V_STR (value_to_string a ^ b'))
        | _ -> push (V_INT 0)
        end;
        true

      | OP_SUB ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (V_INT (a' - b'))
        | V_REAL a', V_INT b' -> push (V_REAL (a' -. float_of_int b'))
        | V_INT a', V_REAL b' -> push (V_REAL (float_of_int a' -. b'))
        | V_REAL a', V_REAL b' -> push (V_REAL (a' -. b'))
        | _ -> push (V_INT 0)
        end;
        true

      | OP_MUL ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (V_INT (a' * b'))
        | V_REAL a', V_INT b' -> push (V_REAL (a' *. float_of_int b'))
        | V_INT a', V_REAL b' -> push (V_REAL (float_of_int a' *. b'))
        | V_REAL a', V_REAL b' -> push (V_REAL (a' *. b'))
        | _ -> push (V_INT 0)
        end;
        true

      | OP_DIV ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | _, V_INT 0 | _, V_REAL 0.0 ->
          errors := ("Division by zero") :: !errors;
          push (V_INT 0)
        | V_INT a', V_INT b' -> push (V_REAL (float_of_int a' /. float_of_int b'))
        | V_REAL a', V_INT b' -> push (V_REAL (a' /. float_of_int b'))
        | V_INT a', V_REAL b' -> push (V_REAL (float_of_int a' /. b'))
        | V_REAL a', V_REAL b' -> push (V_REAL (a' /. b'))
        | _ -> push (V_INT 0)
        end;
        true

      | OP_NEG ->
        let a = pop () in
        begin match a with
        | V_INT a' -> push (V_INT (-a'))
        | V_REAL a' -> push (V_REAL (-. a'))
        | _ -> push (V_INT 0)
        end;
        true

      | OP_EQ ->
        let b = pop () in
        let a = pop () in
        push (bool_to_val (a = b));
        true

      | OP_NE ->
        let b = pop () in
        let a = pop () in
        push (bool_to_val (a <> b));
        true

      | OP_LT ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (bool_to_val (a' < b'))
        | V_INT a', V_REAL b' -> push (bool_to_val (float_of_int a' < b'))
        | V_REAL a', V_INT b' -> push (bool_to_val (a' < float_of_int b'))
        | V_REAL a', V_REAL b' -> push (bool_to_val (a' < b'))
        | _ -> push (bool_to_val false)
        end;
        true

      | OP_GT ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (bool_to_val (a' > b'))
        | V_INT a', V_REAL b' -> push (bool_to_val (float_of_int a' > b'))
        | V_REAL a', V_INT b' -> push (bool_to_val (a' > float_of_int b'))
        | V_REAL a', V_REAL b' -> push (bool_to_val (a' > b'))
        | _ -> push (bool_to_val false)
        end;
        true

      | OP_LE ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (bool_to_val (a' <= b'))
        | V_INT a', V_REAL b' -> push (bool_to_val (float_of_int a' <= b'))
        | V_REAL a', V_INT b' -> push (bool_to_val (a' <= float_of_int b'))
        | V_REAL a', V_REAL b' -> push (bool_to_val (a' <= b'))
        | _ -> push (bool_to_val false)
        end;
        true

      | OP_GE ->
        let b = pop () in
        let a = pop () in
        begin match a, b with
        | V_INT a', V_INT b' -> push (bool_to_val (a' >= b'))
        | V_INT a', V_REAL b' -> push (bool_to_val (float_of_int a' >= b'))
        | V_REAL a', V_INT b' -> push (bool_to_val (a' >= float_of_int b'))
        | V_REAL a', V_REAL b' -> push (bool_to_val (a' >= b'))
        | _ -> push (bool_to_val false)
        end;
        true

      | OP_NOT ->
        let a = pop () in
        push (bool_to_val (not (to_bool a)));
        true

      | OP_AND ->
        let b = pop () in
        let a = pop () in
        push (bool_to_val (to_bool a && to_bool b));
        true

      | OP_OR ->
        let b = pop () in
        let a = pop () in
        push (bool_to_val (to_bool a || to_bool b));
        true

      | OP_JMP target ->
        begin match Hashtbl.find_opt labels target with
        | Some addr -> pc := addr; true
        | None ->
          errors := ("JMP: label " ^ string_of_int target ^ " not found") :: !errors;
          false
        end

      | OP_JMPF target ->
        let cond = pop () in
        if not (to_bool cond) then
          match Hashtbl.find_opt labels target with
          | Some addr -> pc := addr; true
          | None ->
            errors := ("JMPF: label " ^ string_of_int target ^ " not found") :: !errors;
            false
        else
          true

      | OP_INPUT_INT ->
        let line = read_input () in
        begin try
          let n = int_of_string (String.trim line) in
          push (V_INT n);
          true
        with _ ->
          try
            let f = float_of_string (String.trim line) in
            push (V_REAL f);
            true
          with _ ->
            push (V_INT 0);
            true
        end

      | OP_INPUT_REAL ->
        let line = read_input () in
        begin try
          let f = float_of_string (String.trim line) in
          push (V_REAL f);
          true
        with _ ->
          push (V_REAL 0.0);
          true
        end

      | OP_CALL_USER _ ->
        let rec collect_args acc =
          let v = pop () in
          match v with
          | V_ADDR_SIMPLE name ->
            begin match Hashtbl.find_opt func_table name with
            | Some (entry_pc, param_count) ->
              let args = List.rev acc in
              push (V_RET_ADDR (!pc));
              List.iter (fun a -> push a) args;
              pc := entry_pc;
              true
            | None ->
              errors := ("CALL_USER: undefined function '" ^ name ^ "'") :: !errors;
              push V_NONE;
              true
            end
          | _ -> collect_args (v :: acc)
        in
        collect_args []

      | OP_RET ->
        let ret_val = pop () in
        let rec pop_to_ret () =
          let v = pop () in
          match v with
          | V_RET_ADDR addr ->
            push ret_val;
            pc := addr;
            true
          | _ -> pop_to_ret ()
        in
        pop_to_ret ()

      | OP_ARG name ->
        let val_ = pop () in
        Hashtbl.replace mem name val_;
        true

      | OP_GET_FIELD name ->
        let obj = pop () in
        begin match obj with
        | V_SCHEMA (_, fields) ->
          begin match Hashtbl.find_opt fields name with
          | Some v -> push v
          | None -> push V_NONE
          end
        | _ -> push V_NONE
        end;
        true

      | OP_SET_FIELD name ->
        let value = pop () in
        let obj = pop () in
        begin match obj with
        | V_SCHEMA (type_name, fields) ->
          Hashtbl.replace fields name value;
          push (V_SCHEMA (type_name, fields))
        | _ -> push obj
        end;
        true

      | OP_MAKE_SCHEMA type_name ->
        let rec collect acc =
          let top = pop () in
          match top with
          | V_ADDR_SIMPLE _ ->
            let ht = Hashtbl.create (List.length acc) in
            List.iter (fun (k, v) -> Hashtbl.replace ht k v) acc;
            push (V_SCHEMA (type_name, ht))
          | _ ->
            let name_val = pop () in
            let name = match name_val with V_STR s -> s | v -> value_to_string v in
            collect ((name, top) :: acc)
        in
        collect [];
        true

      | OP_FUNC_ENTRY _ ->
        true

      | OP_INPUT_STR ->
        let line = read_input () in
        let trimmed = String.trim line in
        begin try
          let n = int_of_string trimmed in
          push (V_INT n)
        with _ ->
          try
            let f = float_of_string trimmed in
            push (V_REAL f)
          with _ ->
            push (V_STR line)
        end;
        true

      | OP_OUTPUT ->
        let v = pop () in
        Printf.printf "%s" (value_to_string v);
        flush stdout;
        true

      | OP_CALL func ->
        let arg = pop () in
        begin try
          let result = math_call func arg in
          push result;
          true
        with Failure msg ->
          errors := ("CALL " ^ func ^ ": " ^ msg) :: !errors;
          push (V_REAL 0.0);
          true
        end

      | OP_ALLOC_ARR dims ->
        if dims = 2 then begin
          let cols_val = pop () in
          let rows_val = pop () in
          let addr = pop () in
          match addr with
          | V_ADDR_SIMPLE name ->
            let rows = to_int rows_val in
            let cols = to_int cols_val in
            if rows < 0 || cols < 0 then
              Hashtbl.replace mem name (V_MAT (Array.make_matrix 0 0 (V_INT 0)))
            else
              Hashtbl.replace mem name (V_MAT (Array.make_matrix rows cols (V_INT 0)));
            true
          | _ ->
            errors := ("ALLOC_ARR2: expected simple address") :: !errors;
            true
        end else begin
          let size_val = pop () in
          let addr = pop () in
          match addr with
          | V_ADDR_SIMPLE name ->
            let size = to_int size_val in
            if size < 0 then
              Hashtbl.replace mem name (V_ARR (Array.make 0 (V_INT 0)))
            else
              Hashtbl.replace mem name (V_ARR (Array.make size (V_INT 0)));
            true
          | _ ->
            errors := ("ALLOC_ARR: expected simple address") :: !errors;
            true
        end

      | OP_LABEL _ ->
        true
  in

  let run () =
    let continue = ref true in
    while !continue do
      try
        continue := step ()
      with
      | Failure msg ->
        errors := ("Runtime error at PC=" ^ string_of_int (!pc - 1) ^ ": " ^ msg) :: !errors;
        continue := false
      | e ->
        errors := ("Runtime error at PC=" ^ string_of_int (!pc - 1) ^ ": " ^ Printexc.to_string e) :: !errors;
        continue := false
    done
  in

  run ();
  List.rev !errors
