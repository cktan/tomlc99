/* t2.c - run me under valgrind/asan */

#include <stdio.h>
#include "../toml.h"


/* content of BurntSushi duplicate-keys.toml */
char *input = "\
dupe = false\n\
dupe = true\n";

int main (int argc, char *argv[])
{
	toml_table_t *conf;
	char errbuf[256];

	if (!(conf = toml_parse (input, errbuf, sizeof (errbuf)))) {
		fprintf (stderr, "toml_parse: %s (expected)\n", errbuf);
	}
	else {
		fprintf (stderr, "toml_parse unexpectedly succeeded\n");
		toml_free (conf);
		return 1;
	}
	return 0;
}
