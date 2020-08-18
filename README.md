# tomlc99

TOML in c99; v1.0 compliant.

## Usage

Please see the `toml.h` file for details. What follows is a simple example that
parses this config file:

```toml
[server]
	host = "www.example.com"
	port = 80
```

The steps for getting values from our file is usually :

1. Parse the whole TOML file.
2. Get a single table from the file.
3. Find a value from the table.
4. Convert that value to the appropriate type, i.e., string, int, etc.
5. Then, free up that memory if needed.

Below is an example of parsing the values from the example table.

1. Parse the whole TOML file.

```c
FILE* fp;
toml_table_t* conf;
char errbuf[200];

/* Open the file. */
if (0 == (fp = fopen("path/to/file.toml", "r"))) {
	return handle_error();
}

/* Run the file through the parser. */
conf = toml_parse_file(fp, errbuf, sizeof(errbuf));
if (0 == conf) {
	return handle_error();
}

fclose(fp);

/* Alternatively, use `toml_parse` which takes a string rather than a file. */
conf = toml_parse("A null terminated string that is TOML\0", errbuf, sizeof(errbuf);
```

2. Get a single table from the file.

```c
toml_table_t* server;

/* Locate the [server] table. */
if (0 == (server = toml_table_in(conf, "server"))) {
	return handle_error();
}
```

3. Find a value from the table.
4. Convert that value to the appropriate type (I.E. string, int).

```c
toml_raw_t raw;
char* host;
int64_t port;

/* Extract 'host' config value. */
if (0 == (raw = toml_raw_in(server, "host"))) {
	return handle_error();
}

/* Convert the raw value into a string. */
if (toml_rtos(raw, &host)) {
	return handle_error();
}

/* Extract 'port' config value. */
if (0 == (raw = toml_raw_in(server, "port"))) {
	return handle_error();
}

/* Convert the raw value into an int. */
if (toml_rtoi(raw, &port)) {
	return handle_error();
}
```

5. Then, free up that memory if needed.

```c
/* Use `toml_free` on the table returned from `toml_parse[_file]`. */
toml_free(conf);

/* Free any values returned from `toml_rto*`. */
free(host);
```

## Building

A normal *make* suffices. Alternately, you can also simply include the
`toml.c` and `toml.h` files in your project.

## Testing

To test against the standard test set provided by BurntSushi/toml-test:

```sh
% make
% cd test1
% bash build.sh   # do this once
% bash run.sh     # this will run the test suite
```


To test against the standard test set provided by iarna/toml:

```sh
% make
% cd test2
% bash build.sh   # do this once
% bash run.sh     # this will run the test suite
```
