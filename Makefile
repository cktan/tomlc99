CC = gcc 
CFILES = toml.c

CFLAGS = -std=c99 -Wall -Wextra 
CFLAGS += -O2 -DNDEBUG
#CFLAGS += -O0 -g

EXEC = toml_json toml_cat

LIB = libtoml.a

all: $(LIB) $(EXEC)


libtoml.a: toml.o
	ar -rcs $@ $^

toml_json: toml_json.c $(LIB)

toml_cat: toml_cat.c $(LIB)

prefix ?= /usr/local

install: all
	install -d ${prefix}/include ${prefix}/lib
	install toml.h ${prefix}/include
	install libtoml.a ${prefix}/lib

clean:
	rm -f *.o $(EXEC) $(LIB)
