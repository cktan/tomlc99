CFILES = src/toml.c

CFLAGS = -std=c99 -Wall -Wextra -fpic
# to compile for debug: make DEBUG=1
# to compile for no debug: make
ifdef DEBUG
    CFLAGS += -O0 -g
else
    CFLAGS += -O2 -DNDEBUG
endif

EXEC = toml_json toml_cat

LIB = libtoml.a
LIB_SHARED = libtoml.so

all: $(LIB) $(LIB_SHARED) $(EXEC)


libtoml.a: toml.o
	ar -rcs $@ $^

libtoml.so: toml.o
	$(CC) -shared -o $@ $^

toml_json: src/toml_json.c $(LIB)

toml_cat: src/toml_cat.c $(LIB)

prefix ?= /usr/local

install: all
	install -d ${prefix}/include/tomlc99 ${prefix}/lib/tomlc99
	install include/tomlc99/toml.h ${prefix}/include/tomlc99
	install $(LIB) ${prefix}/lib/tomlc99
	install $(LIB_SHARED) ${prefix}/lib/tomlc99

clean:
	rm -f *.o $(EXEC) $(LIB) $(LIB_SHARED)
