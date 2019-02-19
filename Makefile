CC = gcc 
CFILES = toml.c

CFLAGS = -std=c99 -Wall -Wextra 
# to compile for debug: make DEBUG=1
# to compile for no debug: make
ifdef DEBUG
    CFLAGS += -O0 -g
else
    CFLAGS += -O2 -DNDEBUG
endif

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
