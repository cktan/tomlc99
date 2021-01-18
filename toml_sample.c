#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "toml.h"

static void fatal(const char* msg, const char* msg1)
{
	fprintf(stderr, "ERROR: %s%s\n", msg, msg1?msg1:"");
	exit(1);
}


int main()
{
	FILE* fp;
	char errbuf[200];
	int i;

	/* 1. Read and parse toml file */
	fp = fopen("sample.toml", "r");
	if (!fp) {
		fatal("cannot open sample.toml - ", strerror(errno));
	}

	toml_table_t* conf = toml_parse_file(fp, errbuf, sizeof(errbuf));
	fclose(fp);

	if (!conf) {
		fatal("cannot parse - ", errbuf);
	}

	/* 2. Traverse to a table. */
	toml_table_t* server = toml_table_in(conf, "server");
	if (!server) {
		fatal("missing [server]", "");
	}

	/* 3. Extract values */
	toml_datum_t host = toml_string_in(server, "host");
	if (!host.ok) {
		fatal("cannot read server.host", "");
	}

	toml_array_t* portarray = toml_array_in(server, "port");
	if (!portarray) {
		fatal("cannot read server.port", "");
	}

	printf("host: %s\n", host.u.s);
	printf("port: ");
	for (i = 0; ; i++) {
		toml_datum_t port = toml_int_at(portarray, i);
		if (!port.ok) break;
		printf("%d ", (int)port.u.i);
	}
	printf("\n");

	/* 4. Free memory */
	free(host.u.s);
	toml_free(conf);
	return 0;
}
