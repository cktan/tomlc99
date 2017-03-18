# tomlc99
TOML in c99; v0.4.0 compliant.


# Usage

Please see the `toml.h` file for details. What follows is a simple example that
parses this config file:

```
[server]
    host = www.example.com
    port = 80
```

For each config param, the code first extracts a raw value and then
convert it to a string or integer depending on context.

```

    FILE* fp;
    toml_table_t* conf;
    toml_table_t* server;
    const char* raw;
    char* host;
    int64_t port;
    char errbuf[200];

    /* open file and parse */
    if (0 == (fp = fopen(FNAME, "r"))) {
        perror("fopen");
	exit(1);
    }
    conf = toml_parse_file(fp, errbuf, sizeof(errbuf));
    fclose(fp);
    if (0 == conf) {
        fprintf(stderr, "ERROR: %s\n", errbuf);
	exit(1);
    }

    /* locate the [server] table */
    if (0 == (server = toml_table_in(conf, "server"))) {
        fprintf(stderr, "ERROR: missing [server]\n");
	toml_free(conf);
	exit(1);
    }

    /* extract host config value */
    if (0 == (raw = toml_raw_in(server, "host"))) {
        fprintf(stderr, "ERROR: missing 'host' in [server]\n");
	toml_free(conf);
	exit(1);
    }
    if (toml_rtos(raw, &host)) {
        fprintf(stderr, "ERROR: bad value in 'host'\n");
	toml_free(conf);
	exit(1);
    }

    /* extract port config value */
    if (0 == (raw = toml_raw_in(server, "port"))) {
        fprintf(stderr, "ERROR: missing 'port' in [server]\n");
	free(host);
	toml_free(conf);
	exit(1);
    }
    if (toml_rtoi(raw, &port)) {
        fprintf(stderr, "ERROR: bad value in 'port'\n");
        free(host);			
	toml_free(conf);
	exit(1);
    }

    /* done with conf */
    toml_free(conf);

    /* use host and port */
    do_work(host, port);

    /* clean up */
    free(host);
```


# Building

A normal *make* suffices. Alternately, you can also simply include the
`toml.c` and `toml.h` files in your project.

# Testing

To test against the standard test set provided by BurntSushi/toml-test:

```
    % make
    % cd test
    % bash build.sh   # do this once
    % bash run.sh      # this will run the test suite
 ```


