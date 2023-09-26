#include <eval.h>

Lterm* lam_eval_app(const Lapp app[static 1]) {
    Lstr x = app->fun->abs.vname;
    Lterm* body = app->fun->abs.body;
    Lterm* s = app->param;

    Lterm* r = lam_substitute(body, x, s);
    return r;
}

Lterm* lam_eval(const Lterm t[static 1]) {
    switch(t->tag) {
        case Lvartag: return lam_clone(t);
        case Labstag: return lam_clone(t);
        case Lapptag: {
            return lam_eval_app(&t->app);
        }
        default: LOG_INVALID_LTERM_AND_EXIT ;
    }
}
