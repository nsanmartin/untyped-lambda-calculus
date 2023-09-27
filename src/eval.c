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
            switch (t->app.fun->tag) {
                case Lvartag: return lam_clone(t);
                case Labstag: return lam_eval_app(&t->app);
                case Lapptag: {
                    Lterm* r = lam_new_app(lam_eval(t->app.fun), lam_eval(t->app.param));
                    if (r->app.fun->tag == Labstag) {
                        return lam_eval(r);
                    } else {
                        return r;
                    }
                }
                default: LOG_INVALID_LTERM_AND_EXIT ;
            }
        }
        default: LOG_INVALID_LTERM_AND_EXIT ;
    }
}
