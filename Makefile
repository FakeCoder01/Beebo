.PHONY: build clean run test

build:
	cd src && ocamlc -c types.ml && ocamlc -c lexer.ml && ocamlc -c grammar.ml && ocamlc -c interpreter.ml && ocamlc -c parser.ml && ocamlc -c main.ml && ocamlc -o beebo unix.cma types.cmo lexer.cmo grammar.cmo parser.cmo interpreter.cmo main.cmo

clean:
	rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o src/beebo

run: build
	./src/beebo examples/demo.bbo

test-formula: build
	echo '10' | ./src/beebo examples/formula.bbo

test-sort: build
	echo '5'$$'\n''3'$$'\n''1'$$'\n''4'$$'\n''2'$$'\n''5' | ./src/beebo examples/sort_array.bbo

test-strings: build
	./src/beebo examples/strings.bbo

test-math: build
	./src/beebo examples/math_lib.bbo

test-error: build
	./src/beebo examples/error1.bbo

test-all: test-formula test-sort test-strings test-math test-error
