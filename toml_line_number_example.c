#include "toml.h"
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void fatal(const char *msg, const char *msg1) {
  fprintf(stderr, "ERROR: %s%s\n", msg, msg1 ? msg1 : "");
  exit(1);
}


int main() {
  FILE *fp;
  char errbuf[200];

  // 1. Read and parse toml file
  fp = fopen("line_number_sample.toml", "r");
  if (!fp) {
    fatal("cannot open line_number_sample.toml - ", strerror(errno));
  }

  toml_table_t *conf = toml_parse_file(fp, errbuf, sizeof(errbuf));
  fclose(fp);

  if (!conf) {
    fatal("cannot parse - ", errbuf);
  }

  // 2. Traverse to an array of fruit.
  toml_array_t *fruits = toml_array_in(conf, "fruit");
  if (!fruits) {
    fatal("missing [fruit] table", "");
  }
  printf("Found fruit table starting at line: %d\n",toml_key_lineno(conf,"fruit"));

  toml_table_t * first_fruit = toml_table_at(fruits,1);
  
  toml_datum_t name = toml_string_in(first_fruit, "price");
  if (!name.ok) {
    fprintf(stderr, "Fruit at line: %d did not specify a price.\n",toml_table_lineno(first_fruit));
    
  }

  printf("Found fruit with name: %s\n",name.u.s);

  // This could be an example message to the user;
//   printf("Could not find : %d\n",toml_key_lineno(conf,"fruits"));


  // I do not free because it exist immediately 

  return 0;
}
