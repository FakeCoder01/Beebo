FROM ubuntu:22.04

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ocaml \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . /app

RUN cd src && ocamlc -c types.ml && \
    ocamlc -c lexer.ml && \
    ocamlc -c grammar.ml && \
    ocamlc -c interpreter.ml && \
    ocamlc -c parser.ml && \
    ocamlc -c main.ml && \
    ocamlc -o beebo types.cmo lexer.cmo grammar.cmo parser.cmo interpreter.cmo main.cmo

ENTRYPOINT ["./src/beebo"]
