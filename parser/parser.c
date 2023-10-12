#include <parser-lam-reader.h>
#define YYDEBUG 1
int main (int argc, char* argv[]) {
    if (argc == 1) {
        printf("> ");
        parser_set_repl_fn();
        yyin = stdin;
        yyparse();
    } else {
        for (int i = 1; i < argc; ++i) {
	    FILE* file = fopen(argv[i], "r");
	    if (file) {
		    yyin = file;
		    do {
		        yyparse();
		    } while (!feof(yyin));
	    } else {
		    fprintf(stderr, "error reading %s\n", argv[i]);
	    }
	}
    }
}
