#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include "toml.h"

toml_table_t* load()
{
	FILE* fp;
	char errbuf[200];
	fp = fopen("sample.toml", "r");
	if (!fp) {
		fprintf(stderr, "ERROR: cannot open sample.toml - %s\n", strerror(errno));
		exit(1);
	}

	toml_table_t* conf = toml_parse_file(fp, errbuf, sizeof(errbuf));
	fclose(fp);

	if (!conf) {
		fprintf(stderr, "ERROR: cannot parse - %s\n", errbuf);
		exit(1);
	}
	
	return conf;
}

int main()
{
	toml_table_t* conf = load();
	toml_table_t* server = toml_table_in(conf, "server");
	if (!server) {
		fprintf(stderr, "ERROR: missing [server]\n");
		exit(1);
	}
	
	toml_datum_t host = toml_string_in(server, "host");
	if (!host.ok) {
		fprintf(stderr, "ERROR: cannot read server.host.\n");
		exit(1);
	}
	
	toml_datum_t port = toml_int_in(server, "port");
	if (!port.ok) {
		fprintf(stderr, "ERROR: cannot read server.port.\n");
		exit(1);
	}

	printf("host: %s, port %d\n", host.u.s, (int)port.u.i);
	free(host.u.s);
	toml_free(conf);
	return 0;
}
