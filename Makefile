HFILES = toml.h
CFILES = toml.c
OBJ = $(CFILES:.c=.o) 
EXEC = toml_json toml_cat

CFLAGS = -std=c99 -Wall -Wextra -fpic
LIB = libtoml.a
LIB_SHARED = libtoml.so

# to compile for debug: make DEBUG=1
# to compile for no debug: make
ifdef DEBUG
    CFLAGS += -O0 -g
else
    CFLAGS += -O2 -DNDEBUG
endif


all: $(LIB) $(LIB_SHARED) $(EXEC)

*.o: $(HFILES)

libtoml.a: toml.o
	ar -rcs $@ $^

libtoml.so: toml.o
	$(CC) -shared -o $@ $^

toml_json: toml_json.c $(LIB)

toml_cat: toml_cat.c $(LIB)

prefix ?= /usr/local

install: all
	install -d ${prefix}/include ${prefix}/lib
	install toml.h ${prefix}/include
	install $(LIB) ${prefix}/lib
	install $(LIB_SHARED) ${prefix}/lib

clean:
	rm -f *.o $(EXEC) $(LIB) $(LIB_SHARED)
