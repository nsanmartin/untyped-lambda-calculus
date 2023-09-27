#include <parser-lam-reader.h>
#include <eval.h>

void yyerror(const char* s) {
    fprintf(stderr, "error: " RED "%s" RESET "\n", s);
}

Lterm* _last_lterm = 0x0;

int set_last_lam_term(Lterm t[static 1]) {
    lam_print_term(t);
    puts("");
    _last_lterm = t;
    return 0;
}

Lterm* get_last_lam_term(void) {
    //todo: if null panic
    return _last_lterm;
}

Lstr parse_string(const char* in, Lstr (*to_str)(const Lterm[static 1])) {
  set_input_string(in);
  yyparse();
  end_lexical_scan();
  Lstr rv = to_str(get_last_lam_term());
  return rv;
}


Lstr eval_string(const char* in, Lstr (*to_str)(const Lterm[static 1])) {
  set_input_string(in);
  yyparse();
  end_lexical_scan();
  Lstr rv = to_str(lam_eval(get_last_lam_term()));
  return rv;
}

void eval_print(const Lterm t[static 1]) {
    Lterm* v = lam_eval(t);
     lam_print_term_less_paren(v);
}

//todo: choose the funtion wit a cli param
void (*_lam_print_term_fn)(const Lterm t[static 1]) = eval_print;
//void (*_lam_print_term_fn)(const Lterm t[static 1]) = lam_print_term_less_paren;

/* This is he function used by the parser each time an expresion is read. See parser.y */
int parser_read_expression(Lterm t[static 1]) {
    _lam_print_term_fn(t);
    _last_lterm = t;
    printf("\n> ");
    return 0;
}

