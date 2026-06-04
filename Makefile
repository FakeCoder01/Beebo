.PHONY: build clean run test-formula test-sort test-strings test-math test-schema test-block-comment test-exponent test-error test-all

build:
	cd src && ocamlc -c types.ml && ocamlc -c lexer.ml && ocamlc -c grammar.ml && ocamlc -c interpreter.ml && ocamlc -c parser.ml && ocamlc -c main.ml && ocamlc -o beebo unix.cma types.cmo lexer.cmo grammar.cmo parser.cmo interpreter.cmo main.cmo

clean:
	rm -f src/*.cmi src/*.cmo src/*.cmx src/*.o src/beebo

run: build
	./src/beebo examples/demo.bbo

test-formula: build
	echo '10' | ./src/beebo examples/formula.bbo

test-sort: build
	printf '5\n3\n1\n4\n2\n5\n' | ./src/beebo examples/sort_array.bbo

test-strings: build
	./src/beebo examples/strings.bbo

test-math: build
	./src/beebo examples/math_lib.bbo

test-schema: build
	printf '2\nAlice\n20\n95\nBob\n21\n88\n' | ./src/beebo examples/schema_test.bbo

test-block-comment: build
	./src/beebo examples/block_comment.bbo

test-exponent: build
	./src/beebo examples/exponent_real.bbo

test-error: build
	! ./src/beebo examples/error.bbo

test-all: test-formula test-sort test-strings test-math test-schema test-block-comment test-exponent test-error
