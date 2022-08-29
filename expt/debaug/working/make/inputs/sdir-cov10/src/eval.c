/* Evaluator for GNU Emacs Lisp interpreter.
   Copyright (C) 1985, 1986, 1987, 1993, 1994, 1995 Free Software Foundation, Inc.

This file is part of GNU Emacs.

GNU Emacs is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2, or (at your option)
any later version.

GNU Emacs is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU Emacs; see the file COPYING.  If not, write to
the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
Boston, MA 02111-1307, USA.  */


#include <config.h>

#ifdef STDC_HEADERS
#include <stdlib.h>
#endif

#include "lisp.h"
#include "blockinput.h"

#ifndef standalone
#include "commands.h"
#include "keyboard.h"
#else
#define INTERACTIVE 1
#endif

#include <setjmp.h>

/* This definition is duplicated in alloc.c and keyboard.c */
/* Putting it in lisp.h makes cc bomb out! */

struct backtrace
  {
    struct backtrace *next;
    Lisp_Object *function;
    Lisp_Object *args;	/* Points to vector of args. */
    int nargs;		/* Length of vector.
			   If nargs is UNEVALLED, args points to slot holding
			   list of unevalled args */
    char evalargs;
    /* Nonzero means call value of debugger when done with this operation. */
    char debug_on_exit;
  };

struct backtrace *backtrace_list;

/* This structure helps implement the `catch' and `throw' control
   structure.  A struct catchtag contains all the information needed
   to restore the state of the interpreter after a non-local jump.

   Handlers for error conditions (represented by `struct handler'
   structures) just point to a catch tag to do the cleanup required
   for their jumps.

   catchtag structures are chained together in the C calling stack;
   the `next' member points to the next outer catchtag.

   A call like (throw TAG VAL) searches for a catchtag whose `tag'
   member is TAG, and then unbinds to it.  The `val' member is used to
   hold VAL while the stack is unwound; `val' is returned as the value
   of the catch form.

   All the other members are concerned with restoring the interpreter
   state.  */
struct catchtag
  {
    Lisp_Object tag;
    Lisp_Object val;
    struct catchtag *next;
    struct gcpro *gcpro;
    jmp_buf jmp;
    struct backtrace *backlist;
    struct handler *handlerlist;
    int lisp_eval_depth;
    int pdlcount;
    int poll_suppress_count;
  };

struct catchtag *catchlist;

Lisp_Object Qautoload, Qmacro, Qexit, Qinteractive, Qcommandp, Qdefun;
Lisp_Object Qinhibit_quit, Vinhibit_quit, Vquit_flag;
Lisp_Object Qmocklisp_arguments, Vmocklisp_arguments, Qmocklisp;
Lisp_Object Qand_rest, Qand_optional;
Lisp_Object Qdebug_on_error;

/* This holds either the symbol `run-hooks' or nil.
   It is nil at an early stage of startup, and when Emacs
   is shutting down.  */
Lisp_Object Vrun_hooks;

/* Non-nil means record all fset's and provide's, to be undone
   if the file being autoloaded is not fully loaded.
   They are recorded by being consed onto the front of Vautoload_queue:
   (FUN . ODEF) for a defun, (OFEATURES . nil) for a provide.  */

Lisp_Object Vautoload_queue;

/* Current number of specbindings allocated in specpdl.  */
int specpdl_size;

/* Pointer to beginning of specpdl.  */
struct specbinding *specpdl;

/* Pointer to first unused element in specpdl.  */
struct specbinding *specpdl_ptr;

/* Maximum size allowed for specpdl allocation */
int max_specpdl_size;

/* Depth in Lisp evaluations and function calls.  */
int lisp_eval_depth;

/* Maximum allowed depth in Lisp evaluations and function calls.  */
int max_lisp_eval_depth;

/* Nonzero means enter debugger before next function call */
int debug_on_next_call;

/* List of conditions (non-nil atom means all) which cause a backtrace
   if an error is handled by the command loop's error handler.  */
Lisp_Object Vstack_trace_on_error;

/* List of conditions (non-nil atom means all) which enter the debugger
   if an error is handled by the command loop's error handler.  */
Lisp_Object Vdebug_on_error;

/* List of conditions and regexps specifying error messages which
   do not enter the debugger even if Vdebug_on_errors says they should.  */
Lisp_Object Vdebug_ignored_errors;

/* Non-nil means call the debugger even if the error will be handled.  */
Lisp_Object Vdebug_on_signal;

/* Hook for edebug to use.  */
Lisp_Object Vsignal_hook_function;

/* Nonzero means enter debugger if a quit signal
   is handled by the command loop's error handler. */
int debug_on_quit;

/* The value of num_nonmacro_input_events as of the last time we
   started to enter the debugger.  If we decide to enter the debugger
   again when this is still equal to num_nonmacro_input_events, then we
   know that the debugger itself has an error, and we should just
   signal the error instead of entering an infinite loop of debugger
   invocations.  */
int when_entered_debugger;

Lisp_Object Vdebugger;

void specbind (), record_unwind_protect ();

Lisp_Object run_hook_with_args ();

Lisp_Object funcall_lambda ();
extern Lisp_Object ml_apply (); /* Apply a mocklisp function to unevaluated argument list */

void
init_eval_once ()
{
  specpdl_size = 50;
  specpdl = (struct specbinding *) xmalloc (specpdl_size * sizeof (struct specbinding));
  specpdl_ptr = specpdl;
  max_specpdl_size = 600;
  max_lisp_eval_depth = 300;

  Vrun_hooks = Qnil;
}

void
init_eval ()
{
  specpdl_ptr = specpdl;
  catchlist = 0;
  handlerlist = 0;
  backtrace_list = 0;
  Vquit_flag = Qnil;
  debug_on_next_call = 0;
  lisp_eval_depth = 0;
  /* This is less than the initial value of num_nonmacro_input_events.  */
  when_entered_debugger = -1;
}

Lisp_Object
call_debugger (arg)
     Lisp_Object arg;
{
  if (lisp_eval_depth + 20 > max_lisp_eval_depth)
    max_lisp_eval_depth = lisp_eval_depth + 20;
  if (specpdl_size + 40 > max_specpdl_size)
    max_specpdl_size = specpdl_size + 40;
  debug_on_next_call = 0;
  when_entered_debugger = num_nonmacro_input_events;
  return apply1 (Vdebugger, arg);
}

void
do_debug_on_call (code)
     Lisp_Object code;
{
  debug_on_next_call = 0;
  backtrace_list->debug_on_exit = 1;
  call_debugger (Fcons (code, Qnil));
}

/* NOTE!!! Every function that can call EVAL must protect its args
   and temporaries from garbage collection while it needs them.
   The definition of `For' shows what you have to do.  */

DEFUN ("or", For, Sor, 0, UNEVALLED, 0,
  "Eval args until one of them yields non-nil, then return that value.\n\
The remaining args are not evalled at all.\n\
If all args return nil, return nil.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object val;
  Lisp_Object args_left;
  struct gcpro gcpro1;

  if (NILP(args))
    return Qnil;

  args_left = args;
  GCPRO1 (args_left);

  do
    {
      val = Feval (Fcar (args_left));
      if (!NILP (val))
	break;
      args_left = Fcdr (args_left);
    }
  while (!NILP(args_left));

  UNGCPRO;
  return val;
}

DEFUN ("and", Fand, Sand, 0, UNEVALLED, 0,
  "Eval args until one of them yields nil, then return nil.\n\
The remaining args are not evalled at all.\n\
If no arg yields nil, return the last arg's value.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object val;
  Lisp_Object args_left;
  struct gcpro gcpro1;

  if (NILP(args))
    return Qt;

  args_left = args;
  GCPRO1 (args_left);

  do
    {
      val = Feval (Fcar (args_left));
      if (NILP (val))
	break;
      args_left = Fcdr (args_left);
    }
  while (!NILP(args_left));

  UNGCPRO;
  return val;
}

DEFUN ("if", Fif, Sif, 2, UNEVALLED, 0,
  "(if COND THEN ELSE...): if COND yields non-nil, do THEN, else do ELSE...\n\
Returns the value of THEN or the value of the last of the ELSE's.\n\
THEN must be one expression, but ELSE... can be zero or more expressions.\n\
If COND yields nil, and there are no ELSE's, the value is nil.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object cond;
  struct gcpro gcpro1;

  GCPRO1 (args);
  cond = Feval (Fcar (args));
  UNGCPRO;

  if (!NILP (cond))
    return Feval (Fcar (Fcdr (args)));
  return Fprogn (Fcdr (Fcdr (args)));
}

DEFUN ("cond", Fcond, Scond, 0, UNEVALLED, 0,
  "(cond CLAUSES...): try each clause until one succeeds.\n\
Each clause looks like (CONDITION BODY...).  CONDITION is evaluated\n\
and, if the value is non-nil, this clause succeeds:\n\
then the expressions in BODY are evaluated and the last one's\n\
value is the value of the cond-form.\n\
If no clause succeeds, cond returns nil.\n\
If a clause has one element, as in (CONDITION),\n\
CONDITION's value if non-nil is returned from the cond-form.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object clause, val;
  struct gcpro gcpro1;

  val = Qnil;
  GCPRO1 (args);
  while (!NILP (args))
    {
      clause = Fcar (args);
      val = Feval (Fcar (clause));
      if (!NILP (val))
	{
	  if (!EQ (XCONS (clause)->cdr, Qnil))
	    val = Fprogn (XCONS (clause)->cdr);
	  break;
	}
      args = XCONS (args)->cdr;
    }
  UNGCPRO;

  return val;
}

DEFUN ("progn", Fprogn, Sprogn, 0, UNEVALLED, 0,
  "(progn BODY...): eval BODY forms sequentially and return value of last one.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object val, tem;
  Lisp_Object args_left;
  struct gcpro gcpro1;

  /* In Mocklisp code, symbols at the front of the progn arglist
   are to be bound to zero. */
  if (!EQ (Vmocklisp_arguments, Qt))
    {
      val = make_number (0);
      while (!NILP (args) && (tem = Fcar (args), SYMBOLP (tem)))
	{
	  QUIT;
	  specbind (tem, val), args = Fcdr (args);
	}
    }

  if (NILP(args))
    return Qnil;

  args_left = args;
  GCPRO1 (args_left);

  do
    {
      val = Feval (Fcar (args_left));
      args_left = Fcdr (args_left);
    }
  while (!NILP(args_left));

  UNGCPRO;
  return val;
}

DEFUN ("prog1", Fprog1, Sprog1, 1, UNEVALLED, 0,
  "(prog1 FIRST BODY...): eval FIRST and BODY sequentially; value from FIRST.\n\
The value of FIRST is saved during the evaluation of the remaining args,\n\
whose values are discarded.")
  (args)
     Lisp_Object args;
{
  Lisp_Object val;
  register Lisp_Object args_left;
  struct gcpro gcpro1, gcpro2;
  register int argnum = 0;

  if (NILP(args))
    return Qnil;

  args_left = args;
  val = Qnil;
  GCPRO2 (args, val);

  do
    {
      if (!(argnum++))
        val = Feval (Fcar (args_left));
      else
	Feval (Fcar (args_left));
      args_left = Fcdr (args_left);
    }
  while (!NILP(args_left));

  UNGCPRO;
  return val;
}

DEFUN ("prog2", Fprog2, Sprog2, 2, UNEVALLED, 0,
  "(prog2 X Y BODY...): eval X, Y and BODY sequentially; value from Y.\n\
The value of Y is saved during the evaluation of the remaining args,\n\
whose values are discarded.")
  (args)
     Lisp_Object args;
{
  Lisp_Object val;
  register Lisp_Object args_left;
  struct gcpro gcpro1, gcpro2;
  register int argnum = -1;

  val = Qnil;

  if (NILP (args))
    return Qnil;

  args_left = args;
  val = Qnil;
  GCPRO2 (args, val);

  do
    {
      if (!(argnum++))
        val = Feval (Fcar (args_left));
      else
	Feval (Fcar (args_left));
      args_left = Fcdr (args_left);
    }
  while (!NILP (args_left));

  UNGCPRO;
  return val;
}

DEFUN ("setq", Fsetq, Ssetq, 0, UNEVALLED, 0,
  "(setq SYM VAL SYM VAL ...): set each SYM to the value of its VAL.\n\
The symbols SYM are variables; they are literal (not evaluated).\n\
The values VAL are expressions; they are evaluated.\n\
Thus, (setq x (1+ y)) sets `x' to the value of `(1+ y)'.\n\
The second VAL is not computed until after the first SYM is set, and so on;\n\
each VAL can use the new value of variables set earlier in the `setq'.\n\
The return value of the `setq' form is the value of the last VAL.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object args_left;
  register Lisp_Object val, sym;
  struct gcpro gcpro1;

  if (NILP(args))
    return Qnil;

  args_left = args;
  GCPRO1 (args);

  do
    {
      val = Feval (Fcar (Fcdr (args_left)));
      sym = Fcar (args_left);
      Fset (sym, val);
      args_left = Fcdr (Fcdr (args_left));
    }
  while (!NILP(args_left));

  UNGCPRO;
  return val;
}
     
DEFUN ("quote", Fquote, Squote, 1, UNEVALLED, 0,
  "Return the argument, without evaluating it.  `(quote x)' yields `x'.")
  (args)
     Lisp_Object args;
{
  return Fcar (args);
}
     
DEFUN ("function", Ffunction, Sfunction, 1, UNEVALLED, 0,
  "Like `quote', but preferred for objects which are functions.\n\
In byte compilation, `function' causes its argument to be compiled.\n\
`quote' cannot do that.")
  (args)
     Lisp_Object args;
{
  return Fcar (args);
}

DEFUN ("interactive-p", Finteractive_p, Sinteractive_p, 0, 0, 0,
  "Return t if function in which this appears was called interactively.\n\
This means that the function was called with call-interactively (which\n\
includes being called as the binding of a key)\n\
and input is currently coming from the keyboard (not in keyboard macro).")
  ()
{
  register struct backtrace *btp;
  register Lisp_Object fun;

  if (!INTERACTIVE)
    return Qnil;

  btp = backtrace_list;

  /* If this isn't a byte-compiled function, there may be a frame at
     the top for Finteractive_p itself.  If so, skip it.  */
  fun = Findirect_function (*btp->function);
  if (SUBRP (fun) && XSUBR (fun) == &Sinteractive_p)
    btp = btp->next;

  /* If we're running an Emacs 18-style byte-compiled function, there
     may be a frame for Fbytecode.  Now, given the strictest
     definition, this function isn't really being called
     interactively, but because that's the way Emacs 18 always builds
     byte-compiled functions, we'll accept it for now.  */
  if (EQ (*btp->function, Qbytecode))
    btp = btp->next;

  /* If this isn't a byte-compiled function, then we may now be
     looking at several frames for special forms.  Skip past them.  */
  while (btp && 
	 btp->nargs == UNEVALLED)
    btp = btp->next;

  /* btp now points at the frame of the innermost function that isn't
     a special form, ignoring frames for Finteractive_p and/or
     Fbytecode at the top.  If this frame is for a built-in function
     (such as load or eval-region) return nil.  */
  fun = Findirect_function (*btp->function);
  if (SUBRP (fun))
    return Qnil;
  /* btp points to the frame of a Lisp function that called interactive-p.
     Return t if that function was called interactively.  */
  if (btp && btp->next && EQ (*btp->next->function, Qcall_interactively))
    return Qt;
  return Qnil;
}

DEFUN ("defun", Fdefun, Sdefun, 2, UNEVALLED, 0,
  "(defun NAME ARGLIST [DOCSTRING] BODY...): define NAME as a function.\n\
The definition is (lambda ARGLIST [DOCSTRING] BODY...).\n\
See also the function `interactive'.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object fn_name;
  register Lisp_Object defn;

  fn_name = Fcar (args);
  defn = Fcons (Qlambda, Fcdr (args));
  if (!NILP (Vpurify_flag))
    defn = Fpurecopy (defn);
  Ffset (fn_name, defn);
  LOADHIST_ATTACH (fn_name);
  return fn_name;
}

DEFUN ("defmacro", Fdefmacro, Sdefmacro, 2, UNEVALLED, 0,
  "(defmacro NAME ARGLIST [DOCSTRING] BODY...): define NAME as a macro.\n\
The definition is (macro lambda ARGLIST [DOCSTRING] BODY...).\n\
When the macro is called, as in (NAME ARGS...),\n\
the function (lambda ARGLIST BODY...) is applied to\n\
the list ARGS... as it appears in the expression,\n\
and the result should be a form to be evaluated instead of the original.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object fn_name;
  register Lisp_Object defn;

  fn_name = Fcar (args);
  defn = Fcons (Qmacro, Fcons (Qlambda, Fcdr (args)));
  if (!NILP (Vpurify_flag))
    defn = Fpurecopy (defn);
  Ffset (fn_name, defn);
  LOADHIST_ATTACH (fn_name);
  return fn_name;
}

DEFUN ("defvar", Fdefvar, Sdefvar, 1, UNEVALLED, 0,
  "(defvar SYMBOL INITVALUE DOCSTRING): define SYMBOL as a variable.\n\
You are not required to define a variable in order to use it,\n\
but the definition can supply documentation and an initial value\n\
in a way that tags can recognize.\n\n\
INITVALUE is evaluated, and used to set SYMBOL, only if SYMBOL's value is void.\n\
If SYMBOL is buffer-local, its default value is what is set;\n\
 buffer-local values are not affected.\n\
INITVALUE and DOCSTRING are optional.\n\
If DOCSTRING starts with *, this variable is identified as a user option.\n\
 This means that M-x set-variable and M-x edit-options recognize it.\n\
If INITVALUE is missing, SYMBOL's value is not set.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object sym, tem, tail;

  sym = Fcar (args);
  tail = Fcdr (args);
  if (!NILP (Fcdr (Fcdr (tail))))
    error ("too many arguments");

  if (!NILP (tail))
    {
      tem = Fdefault_boundp (sym);
      if (NILP (tem))
	Fset_default (sym, Feval (Fcar (Fcdr (args))));
    }
  tail = Fcdr (Fcdr (args));
  if (!NILP (Fcar (tail)))
    {
      tem = Fcar (tail);
      if (!NILP (Vpurify_flag))
	tem = Fpurecopy (tem);
      Fput (sym, Qvariable_documentation, tem);
    }
  LOADHIST_ATTACH (sym);
  return sym;
}

DEFUN ("defconst", Fdefconst, Sdefconst, 2, UNEVALLED, 0,
  "(defconst SYMBOL INITVALUE DOCSTRING): define SYMBOL as a constant variable.\n\
The intent is that neither programs nor users should ever change this value.\n\
Always sets the value of SYMBOL to the result of evalling INITVALUE.\n\
If SYMBOL is buffer-local, its default value is what is set;\n\
 buffer-local values are not affected.\n\
DOCSTRING is optional.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object sym, tem;

  sym = Fcar (args);
  if (!NILP (Fcdr (Fcdr (Fcdr (args)))))
    error ("too many arguments");

  Fset_default (sym, Feval (Fcar (Fcdr (args))));
  tem = Fcar (Fcdr (Fcdr (args)));
  if (!NILP (tem))
    {
      if (!NILP (Vpurify_flag))
	tem = Fpurecopy (tem);
      Fput (sym, Qvariable_documentation, tem);
    }
  LOADHIST_ATTACH (sym);
  return sym;
}

DEFUN ("user-variable-p", Fuser_variable_p, Suser_variable_p, 1, 1, 0,
  "Returns t if VARIABLE is intended to be set and modified by users.\n\
\(The alternative is a variable used internally in a Lisp program.)\n\
Determined by whether the first character of the documentation\n\
for the variable is `*'.")
  (variable)
     Lisp_Object variable;
{
  Lisp_Object documentation;
  
  if (!SYMBOLP (variable))
      return Qnil;

  documentation = Fget (variable, Qvariable_documentation);
  if (INTEGERP (documentation) && XINT (documentation) < 0)
    return Qt;
  if (STRINGP (documentation)
      && ((unsigned char) XSTRING (documentation)->data[0] == '*'))
    return Qt;
  /* If it is (STRING . INTEGER), a negative integer means a user variable.  */
  if (CONSP (documentation)
      && STRINGP (XCONS (documentation)->car)
      && INTEGERP (XCONS (documentation)->cdr)
      && XINT (XCONS (documentation)->cdr) < 0)
    return Qt;
  return Qnil;
}  

DEFUN ("let*", FletX, SletX, 1, UNEVALLED, 0,
  "(let* VARLIST BODY...): bind variables according to VARLIST then eval BODY.\n\
The value of the last form in BODY is returned.\n\
Each element of VARLIST is a symbol (which is bound to nil)\n\
or a list (SYMBOL VALUEFORM) (which binds SYMBOL to the value of VALUEFORM).\n\
Each VALUEFORM can refer to the symbols already bound by this VARLIST.")
  (args)
     Lisp_Object args;
{
  Lisp_Object varlist, val, elt;
  int count = specpdl_ptr - specpdl;
  struct gcpro gcpro1, gcpro2, gcpro3;

  GCPRO3 (args, elt, varlist);

  varlist = Fcar (args);
  while (!NILP (varlist))
    {
      QUIT;
      elt = Fcar (varlist);
      if (SYMBOLP (elt))
	specbind (elt, Qnil);
      else if (! NILP (Fcdr (Fcdr (elt))))
	Fsignal (Qerror,
		 Fcons (build_string ("`let' bindings can have only one value-form"),
			elt));
      else
	{
	  val = Feval (Fcar (Fcdr (elt)));
	  specbind (Fcar (elt), val);
	}
      varlist = Fcdr (varlist);
    }
  UNGCPRO;
  val = Fprogn (Fcdr (args));
  return unbind_to (count, val);
}

DEFUN ("let", Flet, Slet, 1, UNEVALLED, 0,
  "(let VARLIST BODY...): bind variables according to VARLIST then eval BODY.\n\
The value of the last form in BODY is returned.\n\
Each element of VARLIST is a symbol (which is bound to nil)\n\
or a list (SYMBOL VALUEFORM) (which binds SYMBOL to the value of VALUEFORM).\n\
All the VALUEFORMs are evalled before any symbols are bound.")
  (args)
     Lisp_Object args;
{
  Lisp_Object *temps, tem;
  register Lisp_Object elt, varlist;
  int count = specpdl_ptr - specpdl;
  register int argnum;
  struct gcpro gcpro1, gcpro2;

  varlist = Fcar (args);

  /* Make space to hold the values to give the bound variables */
  elt = Flength (varlist);
  temps = (Lisp_Object *) alloca (XFASTINT (elt) * sizeof (Lisp_Object));

  /* Compute the values and store them in `temps' */

  GCPRO2 (args, *temps);
  gcpro2.nvars = 0;

  for (argnum = 0; !NILP (varlist); varlist = Fcdr (varlist))
    {
      QUIT;
      elt = Fcar (varlist);
      if (SYMBOLP (elt))
	temps [argnum++] = Qnil;
      else if (! NILP (Fcdr (Fcdr (elt))))
	Fsignal (Qerror,
		 Fcons (build_string ("`let' bindings can have only one value-form"),
			elt));
      else
	temps [argnum++] = Feval (Fcar (Fcdr (elt)));
      gcpro2.nvars = argnum;
    }
  UNGCPRO;

  varlist = Fcar (args);
  for (argnum = 0; !NILP (varlist); varlist = Fcdr (varlist))
    {
      elt = Fcar (varlist);
      tem = temps[argnum++];
      if (SYMBOLP (elt))
	specbind (elt, tem);
      else
	specbind (Fcar (elt), tem);
    }

  elt = Fprogn (Fcdr (args));
  return unbind_to (count, elt);
}

DEFUN ("while", Fwhile, Swhile, 1, UNEVALLED, 0,
  "(while TEST BODY...): if TEST yields non-nil, eval BODY... and repeat.\n\
The order of execution is thus TEST, BODY, TEST, BODY and so on\n\
until TEST returns nil.")
  (args)
     Lisp_Object args;
{
  Lisp_Object test, body, tem;
  struct gcpro gcpro1, gcpro2;

  GCPRO2 (test, body);

  test = Fcar (args);
  body = Fcdr (args);
  while (tem = Feval (test),
	 (!EQ (Vmocklisp_arguments, Qt) ? XINT (tem) : !NILP (tem)))
    {
      QUIT;
      Fprogn (body);
    }

  UNGCPRO;
  return Qnil;
}

DEFUN ("macroexpand", Fmacroexpand, Smacroexpand, 1, 2, 0,
  "Return result of expanding macros at top level of FORM.\n\
If FORM is not a macro call, it is returned unchanged.\n\
Otherwise, the macro is expanded and the expansion is considered\n\
in place of FORM.  When a non-macro-call results, it is returned.\n\n\
The second optional arg ENVIRONMENT species an environment of macro\n\
definitions to shadow the loaded ones for use in file byte-compilation.")
  (form, environment)
     Lisp_Object form;
     Lisp_Object environment;
{
  /* With cleanups from Hallvard Furuseth.  */
  register Lisp_Object expander, sym, def, tem;

  while (1)
    {
      /* Come back here each time we expand a macro call,
	 in case it expands into another macro call.  */
      if (!CONSP (form))
	break;
      /* Set SYM, give DEF and TEM right values in case SYM is not a symbol. */
      def = sym = XCONS (form)->car;
      tem = Qnil;
      /* Trace symbols aliases to other symbols
	 until we get a symbol that is not an alias.  */
      while (SYMBOLP (def))
	{
	  QUIT;
	  sym = def;
	  tem = Fassq (sym, environment);
	  if (NILP (tem))
	    {
	      def = XSYMBOL (sym)->function;
	      if (!EQ (def, Qunbound))
		continue;
	    }
	  break;
	}
      /* Right now TEM is the result from SYM in ENVIRONMENT,
	 and if TEM is nil then DEF is SYM's function definition.  */
      if (NILP (tem))
	{
	  /* SYM is not mentioned in ENVIRONMENT.
	     Look at its function definition.  */
	  if (EQ (def, Qunbound) || !CONSP (def))
	    /* Not defined or definition not suitable */
	    break;
	  if (EQ (XCONS (def)->car, Qautoload))
	    {
	      /* Autoloading function: will it be a macro when loaded?  */
	      tem = Fnth (make_number (4), def);
	      if (EQ (tem, Qt) || EQ (tem, Qmacro))
		/* Yes, load it and try again.  */
		{
		  struct gcpro gcpro1;
		  GCPRO1 (form);
		  do_autoload (def, sym);
		  UNGCPRO;
		  continue;
		}
	      else
		break;
	    }
	  else if (!EQ (XCONS (def)->car, Qmacro))
	    break;
	  else expander = XCONS (def)->cdr;
	}
      else
	{
	  expander = XCONS (tem)->cdr;
	  if (NILP (expander))
	    break;
	}
      form = apply1 (expander, XCONS (form)->cdr);
    }
  return form;
}

DEFUN ("catch", Fcatch, Scatch, 1, UNEVALLED, 0,
  "(catch TAG BODY...): eval BODY allowing nonlocal exits using `throw'.\n\
TAG is evalled to get the tag to use; it must not be nil.\n\
\n\
Then the BODY is executed.\n\
Within BODY, (throw TAG) with same tag exits BODY and exits this `catch'.\n\
If no throw happens, `catch' returns the value of the last BODY form.\n\
If a throw happens, it specifies the value to return from `catch'.")
  (args)
     Lisp_Object args;
{
  register Lisp_Object tag;
  struct gcpro gcpro1;

  GCPRO1 (args);
  tag = Feval (Fcar (args));
  UNGCPRO;
  return internal_catch (tag, Fprogn, Fcdr (args));
}

/* Set up a catch, then call C function FUNC on argument ARG.
   FUNC should return a Lisp_Object.
   This is how catches are done from within C code. */

Lisp_Object
internal_catch (tag, func, arg)
     Lisp_Object tag;
     Lisp_Object (*func) ();
     Lisp_Object arg;
{
  /* This structure is made part of the chain `catchlist'.  */
  struct catchtag c;

  /* Fill in the components of c, and put it on the list.  */
  c.next = catchlist;
  c.tag = tag;
  c.val = Qnil;
  c.backlist = backtrace_list;
  c.handlerlist = handlerlist;
  c.lisp_eval_depth = lisp_eval_depth;
  c.pdlcount = specpdl_ptr - specpdl;
  c.poll_suppress_count = poll_suppress_count;
  c.gcpro = gcprolist;
  catchlist = &c;

  /* Call FUNC.  */
  if (! _setjmp (c.jmp))
    c.val = (*func) (arg);

  /* Throw works by a longjmp that comes right here.  */
  catchlist = c.next;
  return c.val;
}

/* Unwind the specbind, catch, and handler stacks back to CATCH, and
   jump to that CATCH, returning VALUE as the value of that catch.

   This is the guts Fthrow and Fsignal; they differ only in the way
   they choose the catch tag to throw to.  A catch tag for a
   condition-case form has a TAG of Qnil.

   Before each catch is discarded, unbind all special bindings and
   execute all unwind-protect clauses made above that catch.  Unwind
   the handler stack as we go, so that the proper handlers are in
   effect for each unwind-protect clause we run.  At the end, restore
   some static info saved in CATCH, and longjmp to the location
   specified in the

   This is used for correct unwinding in Fthrow and Fsignal.  */

static void
unwind_to_catch (catch, value)
     struct catchtag *catch;
     Lisp_Object value;
{
  register int last_time;

  /* Save the value in the tag.  */
  catch->val = value;

  /* Restore the polling-suppression count.  */
  set_poll_suppress_count (catch->poll_suppress_count);

  do
    {
      last_time = catchlist == catch;

      /* Unwind the specpdl stack, and then restore the proper set of
         handlers.  */
      unbind_to (catchlist->pdlcount, Qnil);
      handlerlist = catchlist->handlerlist;
      catchlist = catchlist->next;
    }
  while (! last_time);

  gcprolist = catch->gcpro;
  backtrace_list = catch->backlist;
  lisp_eval_depth = catch->lisp_eval_depth;
  
  _longjmp (catch->jmp, 1);
}

DEFUN ("throw", Fthrow, Sthrow, 2, 2, 0,
  "(throw TAG VALUE): throw to the catch for TAG and return VALUE from it.\n\
Both TAG and VALUE are evalled.")
  (tag, value)
     register Lisp_Object tag, value;
{
  register struct catchtag *c;

  while (1)
    {
      if (!NILP (tag))
	for (c = catchlist; c; c = c->next)
	  {
	    if (EQ (c->tag, tag))
	      unwind_to_catch (c, value);
	  }
      tag = Fsignal (Qno_catch, Fcons (tag, Fcons (value, Qnil)));
    }
}


DEFUN ("unwind-protect", Funwind_protect, Sunwind_protect, 1, UNEVALLED, 0,
  "Do BODYFORM, protecting with UNWINDFORMS.\n\
Usage looks like (unwind-protect BODYFORM UNWINDFORMS...).\n\
If BODYFORM completes normally, its value is returned\n\
after executing the UNWINDFORMS.\n\
If BODYFORM exits nonlocally, the UNWINDFORMS are executed anyway.")
  (args)
     Lisp_Object args;
{
  Lisp_Object val;
  int count = specpdl_ptr - specpdl;

  record_unwind_protect (0, Fcdr (args));
  val = Feval (Fcar (args));
  return unbind_to (count, val);  
}

/* Chain of condition handlers currently in effect.
   The elements of this chain are contained in the stack frames
   of Fcondition_case and internal_condition_case.
   When an error is signaled (by calling Fsignal, below),
   this chain is searched for an element that applies.  */

struct handler *handlerlist;

DEFUN ("condition-case", Fcondition_case, Scondition_case, 2, UNEVALLED, 0,
  "Regain control when an error is signaled.\n\
Usage looks like (condition-case VAR BODYFORM HANDLERS...).\n\
executes BODYFORM and returns its value if no error happens.\n\
Each element of HANDLERS looks like (CONDITION-NAME BODY...)\n\
where the BODY is made of Lisp expressions.\n\n\
A handler is applicable to an error\n\
if CONDITION-NAME is one of the error's condition names.\n\
If an error happens, the first applicable handler is run.\n\
\n\
The car of a handler may be a list of condition names\n\
instead of a single condition name.\n\
\n\
When a handler handles an error,\n\
control returns to the condition-case and the handler BODY... is executed\n\
with VAR bound to (SIGNALED-CONDITIONS . SIGNAL-DATA).\n\
VAR may be nil; then you do not get access to the signal information.\n\
\n\
The value of the last BODY form is returned from the condition-case.\n\
See also the function `signal' for more info.")
  (args)
     Lisp_Object args;
{
  Lisp_Object val;
  struct catchtag c;
  struct handler h;
  register Lisp_Object var, bodyform, handlers;

  var      = Fcar (args);
  bodyform = Fcar (Fcdr (args));
  handlers = Fcdr (Fcdr (args));
  CHECK_SYMBOL (var, 0);

  for (val = handlers; ! NILP (val); val = Fcdr (val))
    {
      Lisp_Object tem;
      tem = Fcar (val);
      if (! (NILP (tem)
	     || (CONSP (tem)
		 && (SYMBOLP (XCONS (tem)->car)
		     || CONSP (XCONS (tem)->car)))))
	error ("Invalid condition handler", tem);
    }

  c.tag = Qnil;
  c.val = Qnil;
  c.backlist = backtrace_list;
  c.handlerlist = handlerlist;
  c.lisp_eval_depth = lisp_eval_depth;
  c.pdlcount = specpdl_ptr - specpdl;
  c.poll_suppress_count = poll_suppress_count;
  c.gcpro = gcprolist;
  if (_setjmp (c.jmp))
    {
      if (!NILP (h.var))
        specbind (h.var, c.val);
      val = Fprogn (Fcdr (h.chosen_clause));

      /* Note that this just undoes the binding of h.var; whoever
	 longjumped to us unwound the stack to c.pdlcount before
	 throwing. */
      unbind_to (c.pdlcount, Qnil);
      return val;
    }
  c.next = catchlist;
  catchlist = &c;
  
  h.var = var;
  h.handler = handlers;
  h.next = handlerlist;
  h.tag = &c;
  handlerlist = &h;

  val = Feval (bodyform);
  catchlist = c.next;
  handlerlist = h.next;
  return val;
}

/* Call the function BFUN with no arguments, catching errors within it
   according to HANDLERS.  If there is an error, call HFUN with
   one argument which is the data that describes the error:
   (SIGNALNAME . DATA)

   HANDLERS can be a list of conditions to catch.
   If HANDLERS is Qt, catch all errors.
   If HANDLERS is Qerror, catch all errors
   but allow the debugger to run if that is enabled.  */

Lisp_Object
internal_condition_case (bfun, handlers, hfun)
     Lisp_Object (*bfun) ();
     Lisp_Object handlers;
     Lisp_Object (*hfun) ();
{
  Lisp_Object val;
  struct catchtag c;
  struct handler h;

  /* Since Fsignal resets this to 0, it had better be 0 now
     or else we have a potential bug.  */
  if (interrupt_input_blocked != 0)
    abort ();

  c.tag = Qnil;
  c.val = Qnil;
  c.backlist = backtrace_list;
  c.handlerlist = handlerlist;
  c.lisp_eval_depth = lisp_eval_depth;
  c.pdlcount = specpdl_ptr - specpdl;
  c.poll_suppress_count = poll_suppress_count;
  c.gcpro = gcprolist;
  if (_setjmp (c.jmp))
    {
      return (*hfun) (c.val);
    }
  c.next = catchlist;
  catchlist = &c;
  h.handler = handlers;
  h.var = Qnil;
  h.next = handlerlist;
  h.tag = &c;
  handlerlist = &h;

  val = (*bfun) ();
  catchlist = c.next;
  handlerlist = h.next;
  return val;
}

/* Like internal_condition_case but call HFUN with ARG as its argument.  */

Lisp_Object
internal_condition_case_1 (bfun, arg, handlers, hfun)
     Lisp_Object (*bfun) ();
     Lisp_Object arg;
     Lisp_Object handlers;
     Lisp_Object (*hfun) ();
{
  Lisp_Object val;
  struct catchtag c;
  struct handler h;

  c.tag = Qnil;
  c.val = Qnil;
  c.backlist = backtrace_list;
  c.handlerlist = handlerlist;
  c.lisp_eval_depth = lisp_eval_depth;
  c.pdlcount = specpdl_ptr - specpdl;
  c.poll_suppress_count = poll_suppress_count;
  c.gcpro = gcprolist;
  if (_setjmp (c.jmp))
    {
      return (*hfun) (c.val);
    }
  c.next = catchlist;
  catchlist = &c;
  h.handler = handlers;
  h.var = Qnil;
  h.next = handlerlist;
  h.tag = &c;
  handlerlist = &h;

  val = (*bfun) (arg);
  catchlist = c.next;
  handlerlist = h.next;
  return val;
}

static Lisp_Object find_handler_clause ();

DEFUN ("signal", Fsignal, Ssignal, 2, 2, 0,
  "Signal an error.  Args are ERROR-SYMBOL and associated DATA.\n\
This function does not return.\n\n\
An error symbol is a symbol with an `error-conditions' property\n\
that is a list of condition names.\n\
A handler for any of those names will get to handle this signal.\n\
The symbol `error' should normally be one of them.\n\
\n\
DATA should be a list.  Its elements are printed as part of the error message.\n\
If the signal is handled, DATA is made available to the handler.\n\
See also the function `condition-case'.")
  (error_symbol, data)
     Lisp_Object error_symbol, data;
{
  /* When memory is full, ERROR-SYMBOL is nil,
     and DATA is (REAL-ERROR-SYMBOL . REAL-DATA).  */
  register struct handler *allhandlers = handlerlist;
  Lisp_Object conditions;
  extern int gc_in_progress;
  extern int waiting_for_input;
  Lisp_Object debugger_value;
  Lisp_Object string;
  Lisp_Object real_error_symbol;
  Lisp_Object combined_data;

  quit_error_check ();
  immediate_quit = 0;
  if (gc_in_progress || waiting_for_input)
    abort ();

  TOTALLY_UNBLOCK_INPUT;

  if (NILP (error_symbol))
    real_error_symbol = Fcar (data);
  else
    real_error_symbol = error_symbol;

  /* This hook is used by edebug.  */
  if (! NILP (Vsignal_hook_function))
    call2 (Vsignal_hook_function, error_symbol, data);

  conditions = Fget (real_error_symbol, Qerror_conditions);

  for (; handlerlist; handlerlist = handlerlist->next)
    {
      register Lisp_Object clause;
      
      if (lisp_eval_depth + 20 > max_lisp_eval_depth)
	max_lisp_eval_depth = lisp_eval_depth + 20;
  
      if (specpdl_size + 40 > max_specpdl_size)
	max_specpdl_size = specpdl_size + 40;
  
      clause = find_handler_clause (handlerlist->handler, conditions,
				    error_symbol, data, &debugger_value);

#if 0 /* Most callers are not prepared to handle gc if this returns.
	 So, since this feature is not very useful, take it out.  */
      /* If have called debugger and user wants to continue,
	 just return nil.  */
      if (EQ (clause, Qlambda))
	return debugger_value;
#else
      if (EQ (clause, Qlambda))
	{
	  /* We can't return values to code which signaled an error, but we
	     can continue code which has signaled a quit.  */
	  if (EQ (real_error_symbol, Qquit))
	    return Qnil;
	  else
	    error ("Cannot return from the debugger in an error");
	}
#endif

      if (!NILP (clause))
	{
	  Lisp_Object unwind_data;
	  struct handler *h = handlerlist;

	  handlerlist = allhandlers;

	  if (NILP (error_symbol))
	    unwind_data = data;
	  else
	    unwind_data = Fcons (error_symbol, data);
	  h->chosen_clause = clause;
	  unwind_to_catch (h->tag, unwind_data);
	}
    }

  handlerlist = allhandlers;
  /* If no handler is present now, try to run the debugger,
     and if that fails, throw to top level.  */
  find_handler_clause (Qerror, conditions, error_symbol, data, &debugger_value);
  if (catchlist != 0)
    Fthrow (Qtop_level, Qt);

  if (! NILP (error_symbol))
    data = Fcons (error_symbol, data);

  string = Ferror_message_string (data);
  fatal ("%s", XSTRING (string)->data, 0);
}

/* Return nonzero iff LIST is a non-nil atom or
   a list containing one of CONDITIONS.  */

static int
wants_debugger (list, conditions)
     Lisp_Object list, conditions;
{
  if (NILP (list))
    return 0;
  if (! CONSP (list))
    return 1;

  while (CONSP (conditions))
    {
      Lisp_Object this, tail;
      this = XCONS (conditions)->car;
      for (tail = list; CONSP (tail); tail = XCONS (tail)->cdr)
	if (EQ (XCONS (tail)->car, this))
	  return 1;
      conditions = XCONS (conditions)->cdr;
    }
  return 0;
}

/* Return 1 if an error with condition-symbols CONDITIONS,
   and described by SIGNAL-DATA, should skip the debugger
   according to debugger-ignore-errors.  */

static int
skip_debugger (conditions, data)
     Lisp_Object conditions, data;
{
  Lisp_Object tail;
  int first_string = 1;
  Lisp_Object error_message;

  for (tail = Vdebug_ignored_errors; CONSP (tail);
       tail = XCONS (tail)->cdr)
    {
      if (STRINGP (XCONS (tail)->car))
	{
	  if (first_string)
	    {
	      error_message = Ferror_message_string (data);
	      first_string = 0;
	    }
	  if (fast_string_match (XCONS (tail)->car, error_message) >= 0)
	    return 1;
	}
      else
	{
	  Lisp_Object contail;

	  for (contail = conditions; CONSP (contail);
	       contail = XCONS (contail)->cdr)
	    if (EQ (XCONS (tail)->car, XCONS (contail)->car))
	      return 1;
	}
    }

  return 0;
}

/* Value of Qlambda means we have called debugger and user has continued.
   There are two ways to pass SIG and DATA:
    = SIG is the error symbol, and DATA is the rest of the data.
    = SIG is nil, and DATA is (SYMBOL . REST-OF-DATA).
       This is for memory-full errors only.

   Store value returned from debugger into *DEBUGGER_VALUE_PTR.  */

static Lisp_Object
find_handler_clause (handlers, conditions, sig, data, debugger_value_ptr)
     Lisp_Object handlers, conditions, sig, data;
     Lisp_Object *debugger_value_ptr;
{
  register Lisp_Object h;
  register Lisp_Object tem;

  if (EQ (handlers, Qt))  /* t is used by handlers for all conditions, set up by C code.  */
    return Qt;
  /* error is used similarly, but means print an error message
     and run the debugger if that is enabled.  */
  if (EQ (handlers, Qerror)
      || !NILP (Vdebug_on_signal)) /* This says call debugger even if
				      there is a handler.  */
    {
      int count = specpdl_ptr - specpdl;
      int debugger_called = 0;
      Lisp_Object sig_symbol, combined_data;
      /* This is set to 1 if we are handling a memory-full error,
	 because these must not run the debugger.
	 (There is no room in memory to do that!)  */
      int no_debugger = 0;

      if (NILP (sig))
	{
	  combined_data = data;
	  sig_symbol = Fcar (data);
	  no_debugger = 1;
	}
      else
	{
	  combined_data = Fcons (sig, data);
	  sig_symbol = sig;
	}

      if (wants_debugger (Vstack_trace_on_error, conditions))
	{
#ifdef __STDC__
	  internal_with_output_to_temp_buffer ("*Backtrace*",
					       (Lisp_Object (*) (Lisp_Object)) Fbacktrace,
					       Qnil);
#else
	  internal_with_output_to_temp_buffer ("*Backtrace*",
					       Fbacktrace, Qnil);
#endif
	}
      if (! no_debugger
	  && (EQ (sig_symbol, Qquit)
	      ? debug_on_quit
	      : wants_debugger (Vdebug_on_error, conditions))
	  && ! skip_debugger (conditions, combined_data)
	  && when_entered_debugger < num_nonmacro_input_events)
	{
	  specbind (Qdebug_on_error, Qnil);
	  *debugger_value_ptr
	    = call_debugger (Fcons (Qerror,
				    Fcons (combined_data, Qnil)));
	  debugger_called = 1;
	}
      /* If there is no handler, return saying whether we ran the debugger.  */
      if (EQ (handlers, Qerror))
	{
	  if (debugger_called)
	    return unbind_to (count, Qlambda);
	  return Qt;
	}
    }
  for (h = handlers; CONSP (h); h = Fcdr (h))
    {
      Lisp_Object handler, condit;

      handler = Fcar (h);
      if (!CONSP (handler))
	continue;
      condit = Fcar (handler);
      /* Handle a single condition name in handler HANDLER.  */
      if (SYMBOLP (condit))
	{
	  tem = Fmemq (Fcar (handler), conditions);
	  if (!NILP (tem))
	    return handler;
	}
      /* Handle a list of condition names in handler HANDLER.  */
      else if (CONSP (condit))
	{
	  while (CONSP (condit))
	    {
	      tem = Fmemq (Fcar (condit), conditions);
	      if (!NILP (tem))
		return handler;
	      condit = XCONS (condit)->cdr;
	    }
	}
    }
  return Qnil;
}

/* dump an error message; called like printf */

/* VARARGS 1 */
void
error (m, a1, a2, a3)
     char *m;
     char *a1, *a2, *a3;
{
  char buf[200];
  int size = 200;
  int mlen;
  char *buffer = buf;
  char *args[3];
  int allocated = 0;
  Lisp_Object string;

  args[0] = a1;
  args[1] = a2;
  args[2] = a3;

  mlen = strlen (m);

  while (1)
    {
      int used = doprnt (buffer, size, m, m + mlen, 3, args);
      if (used < size)
	break;
      size *= 2;
      if (allocated)
	buffer = (char *) xrealloc (buffer, size);
      else
	{
	  buffer = (char *) xmalloc (size);
	  allocated = 1;
	}
    }

  string = build_string (buffer);
  if (allocated)
    free (buffer);

  Fsignal (Qerror, Fcons (string, Qnil));
}

DEFUN ("commandp", Fcommandp, Scommandp, 1, 1, 0,
  "T if FUNCTION makes provisions for interactive calling.\n\
This means it contains a description for how to read arguments to give it.\n\
The value is nil for an invalid function or a symbol with no function\n\
definition.\n\
\n\
Interactively callable functions include strings and vectors (treated\n\
as keyboard macros), lambda-expressions that contain a top-level call\n\
to `interactive', autoload definitions made by `autoload' with non-nil\n\
fourth argument, and some of the built-in functions of Lisp.\n\
\n\
Also, a symbol satisfies `commandp' if its function definition does so.")
  (function)
     Lisp_Object function;
{
  register Lisp_Object fun;
  register Lisp_Object funcar;
  register Lisp_Object tem;
  register int i = 0;

  fun = function;

  fun = indirect_function (fun);
  if (EQ (fun, Qunbound))
    return Qnil;

  /* Emacs primitives are interactive if their DEFUN specifies an
     interactive spec.  */
  if (SUBRP (fun))
    {
      if (XSUBR (fun)->prompt)
	return Qt;
      else
	return Qnil;
    }

  /* Bytecode objects are interactive if they are long enough to
     have an element whose index is COMPILED_INTERACTIVE, which is
     where the interactive spec is stored.  */
  else if (COMPILEDP (fun))
    return ((XVECTOR (fun)->size & PSEUDOVECTOR_SIZE_MASK) > COMPILED_INTERACTIVE
	    ? Qt : Qnil);

  /* Strings and vectors are keyboard macros.  */
  if (STRINGP (fun) || VECTORP (fun))
    return Qt;

  /* Lists may represent commands.  */
  if (!CONSP (fun))
    return Qnil;
  funcar = Fcar (fun);
  if (!SYMBOLP (funcar))
    return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
  if (EQ (funcar, Qlambda))
    return Fassq (Qinteractive, Fcdr (Fcdr (fun)));
  if (EQ (funcar, Qmocklisp))
    return Qt;  /* All mocklisp functions can be called interactively */
  if (EQ (funcar, Qautoload))
    return Fcar (Fcdr (Fcdr (Fcdr (fun))));
  else
    return Qnil;
}

/* ARGSUSED */
DEFUN ("autoload", Fautoload, Sautoload, 2, 5, 0,
  "Define FUNCTION to autoload from FILE.\n\
FUNCTION is a symbol; FILE is a file name string to pass to `load'.\n\
Third arg DOCSTRING is documentation for the function.\n\
Fourth arg INTERACTIVE if non-nil says function can be called interactively.\n\
Fifth arg TYPE indicates the type of the object:\n\
   nil or omitted says FUNCTION is a function,\n\
   `keymap' says FUNCTION is really a keymap, and\n\
   `macro' or t says FUNCTION is really a macro.\n\
Third through fifth args give info about the real definition.\n\
They default to nil.\n\
If FUNCTION is already defined other than as an autoload,\n\
this does nothing and returns nil.")
  (function, file, docstring, interactive, type)
     Lisp_Object function, file, docstring, interactive, type;
{
#ifdef NO_ARG_ARRAY
  Lisp_Object args[4];
#endif

  CHECK_SYMBOL (function, 0);
  CHECK_STRING (file, 1);

  /* If function is defined and not as an autoload, don't override */
  if (!EQ (XSYMBOL (function)->function, Qunbound)
      && !(CONSP (XSYMBOL (function)->function)
	   && EQ (XCONS (XSYMBOL (function)->function)->car, Qautoload)))
    return Qnil;

#ifdef NO_ARG_ARRAY
  args[0] = file;
  args[1] = docstring;
  args[2] = interactive;
  args[3] = type;

  return Ffset (function, Fcons (Qautoload, Flist (4, &args[0])));
#else /* NO_ARG_ARRAY */
  return Ffset (function, Fcons (Qautoload, Flist (4, &file)));
#endif /* not NO_ARG_ARRAY */
}

Lisp_Object
un_autoload (oldqueue)
     Lisp_Object oldqueue;
{
  register Lisp_Object queue, first, second;

  /* Queue to unwind is current value of Vautoload_queue.
     oldqueue is the shadowed value to leave in Vautoload_queue.  */
  queue = Vautoload_queue;
  Vautoload_queue = oldqueue;
  while (CONSP (queue))
    {
      first = Fcar (queue);
      second = Fcdr (first);
      first = Fcar (first);
      if (EQ (second, Qnil))
	Vfeatures = first;
      else
	Ffset (first, second);
      queue = Fcdr (queue);
    }
  return Qnil;
}

/* Load an autoloaded function.
   FUNNAME is the symbol which is the function's name.
   FUNDEF is the autoload definition (a list).  */

void
do_autoload (fundef, funname)
     Lisp_Object fundef, funname;
{
  int count = specpdl_ptr - specpdl;
  Lisp_Object fun, val, queue, first, second;
  struct gcpro gcpro1, gcpro2, gcpro3;

  fun = funname;
  CHECK_SYMBOL (funname, 0);
  GCPRO3 (fun, funname, fundef);

  /* Preserve the match data.  */
  record_unwind_protect (Fset_match_data, Fmatch_data (Qnil, Qnil));
  
  /* Value saved here is to be restored into Vautoload_queue.  */
  record_unwind_protect (un_autoload, Vautoload_queue);
  Vautoload_queue = Qt;
  Fload (Fcar (Fcdr (fundef)), Qnil, noninteractive ? Qt : Qnil, Qnil, Qt);

  /* Save the old autoloads, in case we ever do an unload.  */
  queue = Vautoload_queue;
  while (CONSP (queue))
    {
      first = Fcar (queue);
      second = Fcdr (first);
      first = Fcar (first);

      /* Note: This test is subtle.  The cdr of an autoload-queue entry
	 may be an atom if the autoload entry was generated by a defalias
	 or fset.  */
      if (CONSP (second))
	Fput (first, Qautoload, (Fcdr (second)));

      queue = Fcdr (queue);
    }

  /* Once loading finishes, don't undo it.  */
  Vautoload_queue = Qt;
  unbind_to (count, Qnil);

  fun = Findirect_function (fun);

  if (!NILP (Fequal (fun, fundef)))
    error ("Autoloading failed to define function %s",
	   XSYMBOL (funname)->name->data);
  UNGCPRO;
}

DEFUN ("eval", Feval, Seval, 1, 1, 0,
  "Evaluate FORM and return its value.")
  (form)
     Lisp_Object form;
{
  Lisp_Object fun, val, original_fun, original_args;
  Lisp_Object funcar;
  struct backtrace backtrace;
  struct gcpro gcpro1, gcpro2, gcpro3;

  if (SYMBOLP (form))
    {
      if (EQ (Vmocklisp_arguments, Qt))
        return Fsymbol_value (form);
      val = Fsymbol_value (form);
      if (NILP (val))
	XSETFASTINT (val, 0);
      else if (EQ (val, Qt))
	XSETFASTINT (val, 1);
      return val;
    }
  if (!CONSP (form))
    return form;

  QUIT;
  if (consing_since_gc > gc_cons_threshold)
    {
      GCPRO1 (form);
      Fgarbage_collect ();
      UNGCPRO;
    }

  if (++lisp_eval_depth > max_lisp_eval_depth)
    {
      if (max_lisp_eval_depth < 100)
	max_lisp_eval_depth = 100;
      if (lisp_eval_depth > max_lisp_eval_depth)
	error ("Lisp nesting exceeds max-lisp-eval-depth");
    }

  original_fun = Fcar (form);
  original_args = Fcdr (form);

  backtrace.next = backtrace_list;
  backtrace_list = &backtrace;
  backtrace.function = &original_fun; /* This also protects them from gc */
  backtrace.args = &original_args;
  backtrace.nargs = UNEVALLED;
  backtrace.evalargs = 1;
  backtrace.debug_on_exit = 0;

  if (debug_on_next_call)
    do_debug_on_call (Qt);

  /* At this point, only original_fun and original_args
     have values that will be used below */
 retry:
  fun = Findirect_function (original_fun);

  if (SUBRP (fun))
    {
      Lisp_Object numargs;
      Lisp_Object argvals[8];
      Lisp_Object args_left;
      register int i, maxargs;

      args_left = original_args;
      numargs = Flength (args_left);

      if (XINT (numargs) < XSUBR (fun)->min_args ||
	  (XSUBR (fun)->max_args >= 0 && XSUBR (fun)->max_args < XINT (numargs)))
	return Fsignal (Qwrong_number_of_arguments, Fcons (fun, Fcons (numargs, Qnil)));

      if (XSUBR (fun)->max_args == UNEVALLED)
	{
	  backtrace.evalargs = 0;
	  val = (*XSUBR (fun)->function) (args_left);
	  goto done;
	}

      if (XSUBR (fun)->max_args == MANY)
	{
	  /* Pass a vector of evaluated arguments */
	  Lisp_Object *vals;
	  register int argnum = 0;

	  vals = (Lisp_Object *) alloca (XINT (numargs) * sizeof (Lisp_Object));

	  GCPRO3 (args_left, fun, fun);
	  gcpro3.var = vals;
	  gcpro3.nvars = 0;

	  while (!NILP (args_left))
	    {
	      vals[argnum++] = Feval (Fcar (args_left));
	      args_left = Fcdr (args_left);
	      gcpro3.nvars = argnum;
	    }

	  backtrace.args = vals;
	  backtrace.nargs = XINT (numargs);

	  val = (*XSUBR (fun)->function) (XINT (numargs), vals);
	  UNGCPRO;
	  goto done;
	}

      GCPRO3 (args_left, fun, fun);
      gcpro3.var = argvals;
      gcpro3.nvars = 0;

      maxargs = XSUBR (fun)->max_args;
      for (i = 0; i < maxargs; args_left = Fcdr (args_left))
	{
	  argvals[i] = Feval (Fcar (args_left));
	  gcpro3.nvars = ++i;
	}

      UNGCPRO;

      backtrace.args = argvals;
      backtrace.nargs = XINT (numargs);

      switch (i)
	{
	case 0:
	  val = (*XSUBR (fun)->function) ();
	  goto done;
	case 1:
	  val = (*XSUBR (fun)->function) (argvals[0]);
	  goto done;
	case 2:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1]);
	  goto done;
	case 3:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1],
					  argvals[2]);
	  goto done;
	case 4:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1],
					  argvals[2], argvals[3]);
	  goto done;
	case 5:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1], argvals[2],
					  argvals[3], argvals[4]);
	  goto done;
	case 6:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1], argvals[2],
					  argvals[3], argvals[4], argvals[5]);
	  goto done;
	case 7:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1], argvals[2],
					  argvals[3], argvals[4], argvals[5],
					  argvals[6]);
	  goto done;

	case 8:
	  val = (*XSUBR (fun)->function) (argvals[0], argvals[1], argvals[2],
					  argvals[3], argvals[4], argvals[5],
					  argvals[6], argvals[7]);
	  goto done;

	default:
	  /* Someone has created a subr that takes more arguments than
	     is supported by this code.  We need to either rewrite the
	     subr to use a different argument protocol, or add more
	     cases to this switch.  */
	  abort ();
	}
    }
  if (COMPILEDP (fun))
    val = apply_lambda (fun, original_args, 1);
  else
    {
      if (!CONSP (fun))
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      funcar = Fcar (fun);
      if (!SYMBOLP (funcar))
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      if (EQ (funcar, Qautoload))
	{
	  do_autoload (fun, original_fun);
	  goto retry;
	}
      if (EQ (funcar, Qmacro))
	val = Feval (apply1 (Fcdr (fun), original_args));
      else if (EQ (funcar, Qlambda))
	val = apply_lambda (fun, original_args, 1);
      else if (EQ (funcar, Qmocklisp))
	val = ml_apply (fun, original_args);
      else
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
    }
 done:
  if (!EQ (Vmocklisp_arguments, Qt))
    {
      if (NILP (val))
	XSETFASTINT (val, 0);
      else if (EQ (val, Qt))
	XSETFASTINT (val, 1);
    }
  lisp_eval_depth--;
  if (backtrace.debug_on_exit)
    val = call_debugger (Fcons (Qexit, Fcons (val, Qnil)));
  backtrace_list = backtrace.next;
  return val;
}

DEFUN ("apply", Fapply, Sapply, 2, MANY, 0,
  "Call FUNCTION with our remaining args, using our last arg as list of args.\n\
Then return the value FUNCTION returns.\n\
Thus, (apply '+ 1 2 '(3 4)) returns 10.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  register int i, numargs;
  register Lisp_Object spread_arg;
  register Lisp_Object *funcall_args;
  Lisp_Object fun;
  struct gcpro gcpro1;

  fun = args [0];
  funcall_args = 0;
  spread_arg = args [nargs - 1];
  CHECK_LIST (spread_arg, nargs);
  
  numargs = XINT (Flength (spread_arg));

  if (numargs == 0)
    return Ffuncall (nargs - 1, args);
  else if (numargs == 1)
    {
      args [nargs - 1] = XCONS (spread_arg)->car;
      return Ffuncall (nargs, args);
    }

  numargs += nargs - 2;

  fun = indirect_function (fun);
  if (EQ (fun, Qunbound))
    {
      /* Let funcall get the error */
      fun = args[0];
      goto funcall;
    }

  if (SUBRP (fun))
    {
      if (numargs < XSUBR (fun)->min_args
	  || (XSUBR (fun)->max_args >= 0 && XSUBR (fun)->max_args < numargs))
	goto funcall;		/* Let funcall get the error */
      else if (XSUBR (fun)->max_args > numargs)
	{
	  /* Avoid making funcall cons up a yet another new vector of arguments
	     by explicitly supplying nil's for optional values */
	  funcall_args = (Lisp_Object *) alloca ((1 + XSUBR (fun)->max_args)
						 * sizeof (Lisp_Object));
	  for (i = numargs; i < XSUBR (fun)->max_args;)
	    funcall_args[++i] = Qnil;
	  GCPRO1 (*funcall_args);
	  gcpro1.nvars = 1 + XSUBR (fun)->max_args;
	}
    }
 funcall:
  /* We add 1 to numargs because funcall_args includes the
     function itself as well as its arguments.  */
  if (!funcall_args)
    {
      funcall_args = (Lisp_Object *) alloca ((1 + numargs)
					     * sizeof (Lisp_Object));
      GCPRO1 (*funcall_args);
      gcpro1.nvars = 1 + numargs;
    }

  bcopy (args, funcall_args, nargs * sizeof (Lisp_Object));
  /* Spread the last arg we got.  Its first element goes in
     the slot that it used to occupy, hence this value of I.  */
  i = nargs - 1;
  while (!NILP (spread_arg))
    {
      funcall_args [i++] = XCONS (spread_arg)->car;
      spread_arg = XCONS (spread_arg)->cdr;
    }

  RETURN_UNGCPRO (Ffuncall (gcpro1.nvars, funcall_args));
}

/* Run hook variables in various ways.  */

enum run_hooks_condition {to_completion, until_success, until_failure};

DEFUN ("run-hooks", Frun_hooks, Srun_hooks, 1, MANY, 0,
  "Run each hook in HOOKS.  Major mode functions use this.\n\
Each argument should be a symbol, a hook variable.\n\
These symbols are processed in the order specified.\n\
If a hook symbol has a non-nil value, that value may be a function\n\
or a list of functions to be called to run the hook.\n\
If the value is a function, it is called with no arguments.\n\
If it is a list, the elements are called, in order, with no arguments.\n\
\n\
To make a hook variable buffer-local, use `make-local-hook',\n\
not `make-local-variable'.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  Lisp_Object hook[1];
  register int i;

  for (i = 0; i < nargs; i++)
    {
      hook[0] = args[i];
      run_hook_with_args (1, hook, to_completion);
    }

  return Qnil;
}
      
DEFUN ("run-hook-with-args", Frun_hook_with_args,
  Srun_hook_with_args, 1, MANY, 0,
  "Run HOOK with the specified arguments ARGS.\n\
HOOK should be a symbol, a hook variable.  If HOOK has a non-nil\n\
value, that value may be a function or a list of functions to be\n\
called to run the hook.  If the value is a function, it is called with\n\
the given arguments and its return value is returned.  If it is a list\n\
of functions, those functions are called, in order,\n\
with the given arguments ARGS.\n\
It is best not to depend on the value return by `run-hook-with-args',\n\
as that may change.\n\
\n\
To make a hook variable buffer-local, use `make-local-hook',\n\
not `make-local-variable'.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  return run_hook_with_args (nargs, args, to_completion);
}

DEFUN ("run-hook-with-args-until-success", Frun_hook_with_args_until_success,
  Srun_hook_with_args_until_success, 1, MANY, 0,
  "Run HOOK with the specified arguments ARGS.\n\
HOOK should be a symbol, a hook variable.  Its value should\n\
be a list of functions.  We call those functions, one by one,\n\
passing arguments ARGS to each of them, until one of them\n\
returns a non-nil value.  Then we return that value.\n\
If all the functions return nil, we return nil.\n\
\n\
To make a hook variable buffer-local, use `make-local-hook',\n\
not `make-local-variable'.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  return run_hook_with_args (nargs, args, until_success);
}

DEFUN ("run-hook-with-args-until-failure", Frun_hook_with_args_until_failure,
  Srun_hook_with_args_until_failure, 1, MANY, 0,
  "Run HOOK with the specified arguments ARGS.\n\
HOOK should be a symbol, a hook variable.  Its value should\n\
be a list of functions.  We call those functions, one by one,\n\
passing arguments ARGS to each of them, until one of them\n\
returns nil.  Then we return nil.\n\
If all the functions return non-nil, we return non-nil.\n\
\n\
To make a hook variable buffer-local, use `make-local-hook',\n\
not `make-local-variable'.")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  return run_hook_with_args (nargs, args, until_failure);
}

/* ARGS[0] should be a hook symbol.
   Call each of the functions in the hook value, passing each of them
   as arguments all the rest of ARGS (all NARGS - 1 elements).
   COND specifies a condition to test after each call
   to decide whether to stop.
   The caller (or its caller, etc) must gcpro all of ARGS,
   except that it isn't necessary to gcpro ARGS[0].  */

Lisp_Object
run_hook_with_args (nargs, args, cond)
     int nargs;
     Lisp_Object *args;
     enum run_hooks_condition cond;
{
  Lisp_Object sym, val, ret;
  Lisp_Object globals;
  struct gcpro gcpro1, gcpro2, gcpro3;

  /* If we are dying or still initializing,
     don't do anything--it would probably crash if we tried.  */
  if (NILP (Vrun_hooks))
    return;

  sym = args[0];
  val = find_symbol_value (sym);
  ret = (cond == until_failure ? Qt : Qnil);

  if (EQ (val, Qunbound) || NILP (val))
    return ret;
  else if (!CONSP (val) || EQ (XCONS (val)->car, Qlambda))
    {
      args[0] = val;
      return Ffuncall (nargs, args);
    }
  else
    {
      globals = Qnil;
      GCPRO3 (sym, val, globals);

      for (;
	   CONSP (val) && ((cond == to_completion)
			   || (cond == until_success ? NILP (ret)
			       : !NILP (ret)));
	   val = XCONS (val)->cdr)
	{
	  if (EQ (XCONS (val)->car, Qt))
	    {
	      /* t indicates this hook has a local binding;
		 it means to run the global binding too.  */

	      for (globals = Fdefault_value (sym);
		   CONSP (globals) && ((cond == to_completion)
				       || (cond == until_success ? NILP (ret)
					   : !NILP (ret)));
		   globals = XCONS (globals)->cdr)
		{
		  args[0] = XCONS (globals)->car;
		  /* In a global value, t should not occur.  If it does, we
		     must ignore it to avoid an endless loop.  */
		  if (!EQ (args[0], Qt))
		    ret = Ffuncall (nargs, args);
		}
	    }
	  else
	    {
	      args[0] = XCONS (val)->car;
	      ret = Ffuncall (nargs, args);
	    }
	}

      UNGCPRO;
      return ret;
    }
}

/* Run a hook symbol ARGS[0], but use FUNLIST instead of the actual
   present value of that symbol.
   Call each element of FUNLIST,
   passing each of them the rest of ARGS.
   The caller (or its caller, etc) must gcpro all of ARGS,
   except that it isn't necessary to gcpro ARGS[0].  */

Lisp_Object
run_hook_list_with_args (funlist, nargs, args)
     Lisp_Object funlist;
     int nargs;
     Lisp_Object *args;
{
  Lisp_Object sym;
  Lisp_Object val;
  Lisp_Object globals;
  struct gcpro gcpro1, gcpro2, gcpro3;

  sym = args[0];
  globals = Qnil;
  GCPRO3 (sym, val, globals);

  for (val = funlist; CONSP (val); val = XCONS (val)->cdr)
    {
      if (EQ (XCONS (val)->car, Qt))
	{
	  /* t indicates this hook has a local binding;
	     it means to run the global binding too.  */

	  for (globals = Fdefault_value (sym);
	       CONSP (globals);
	       globals = XCONS (globals)->cdr)
	    {
	      args[0] = XCONS (globals)->car;
	      /* In a global value, t should not occur.  If it does, we
		 must ignore it to avoid an endless loop.  */
	      if (!EQ (args[0], Qt))
		Ffuncall (nargs, args);
	    }
	}
      else
	{
	  args[0] = XCONS (val)->car;
	  Ffuncall (nargs, args);
	}
    }
  UNGCPRO;
  return Qnil;
}

/* Run the hook HOOK, giving each function the two args ARG1 and ARG2.  */

void
run_hook_with_args_2 (hook, arg1, arg2)
     Lisp_Object hook, arg1, arg2;
{
  Lisp_Object temp[3];
  temp[0] = hook;
  temp[1] = arg1;
  temp[2] = arg2;

  Frun_hook_with_args (3, temp);
}

/* Apply fn to arg */
Lisp_Object
apply1 (fn, arg)
     Lisp_Object fn, arg;
{
  struct gcpro gcpro1;

  GCPRO1 (fn);
  if (NILP (arg))
    RETURN_UNGCPRO (Ffuncall (1, &fn));
  gcpro1.nvars = 2;
#ifdef NO_ARG_ARRAY
  {
    Lisp_Object args[2];
    args[0] = fn;
    args[1] = arg;
    gcpro1.var = args;
    RETURN_UNGCPRO (Fapply (2, args));
  }
#else /* not NO_ARG_ARRAY */
  RETURN_UNGCPRO (Fapply (2, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn on no arguments */
Lisp_Object
call0 (fn)
     Lisp_Object fn;
{
  struct gcpro gcpro1;

  GCPRO1 (fn);
  RETURN_UNGCPRO (Ffuncall (1, &fn));
}

/* Call function fn with 1 argument arg1 */
/* ARGSUSED */
Lisp_Object
call1 (fn, arg1)
     Lisp_Object fn, arg1;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[2];  

  args[0] = fn;
  args[1] = arg1;
  GCPRO1 (args[0]);
  gcpro1.nvars = 2;
  RETURN_UNGCPRO (Ffuncall (2, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 2;
  RETURN_UNGCPRO (Ffuncall (2, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn with 2 arguments arg1, arg2 */
/* ARGSUSED */
Lisp_Object
call2 (fn, arg1, arg2)
     Lisp_Object fn, arg1, arg2;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[3];
  args[0] = fn;
  args[1] = arg1;
  args[2] = arg2;
  GCPRO1 (args[0]);
  gcpro1.nvars = 3;
  RETURN_UNGCPRO (Ffuncall (3, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 3;
  RETURN_UNGCPRO (Ffuncall (3, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn with 3 arguments arg1, arg2, arg3 */
/* ARGSUSED */
Lisp_Object
call3 (fn, arg1, arg2, arg3)
     Lisp_Object fn, arg1, arg2, arg3;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[4];
  args[0] = fn;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  GCPRO1 (args[0]);
  gcpro1.nvars = 4;
  RETURN_UNGCPRO (Ffuncall (4, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 4;
  RETURN_UNGCPRO (Ffuncall (4, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn with 4 arguments arg1, arg2, arg3, arg4 */
/* ARGSUSED */
Lisp_Object
call4 (fn, arg1, arg2, arg3, arg4)
     Lisp_Object fn, arg1, arg2, arg3, arg4;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[5];
  args[0] = fn;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  GCPRO1 (args[0]);
  gcpro1.nvars = 5;
  RETURN_UNGCPRO (Ffuncall (5, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 5;
  RETURN_UNGCPRO (Ffuncall (5, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn with 5 arguments arg1, arg2, arg3, arg4, arg5 */
/* ARGSUSED */
Lisp_Object
call5 (fn, arg1, arg2, arg3, arg4, arg5)
     Lisp_Object fn, arg1, arg2, arg3, arg4, arg5;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[6];
  args[0] = fn;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  GCPRO1 (args[0]);
  gcpro1.nvars = 6;
  RETURN_UNGCPRO (Ffuncall (6, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 6;
  RETURN_UNGCPRO (Ffuncall (6, &fn));
#endif /* not NO_ARG_ARRAY */
}

/* Call function fn with 6 arguments arg1, arg2, arg3, arg4, arg5, arg6 */
/* ARGSUSED */
Lisp_Object
call6 (fn, arg1, arg2, arg3, arg4, arg5, arg6)
     Lisp_Object fn, arg1, arg2, arg3, arg4, arg5, arg6;
{
  struct gcpro gcpro1;
#ifdef NO_ARG_ARRAY
  Lisp_Object args[7];
  args[0] = fn;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = arg4;
  args[5] = arg5;
  args[6] = arg6;
  GCPRO1 (args[0]);
  gcpro1.nvars = 7;
  RETURN_UNGCPRO (Ffuncall (7, args));
#else /* not NO_ARG_ARRAY */
  GCPRO1 (fn);
  gcpro1.nvars = 7;
  RETURN_UNGCPRO (Ffuncall (7, &fn));
#endif /* not NO_ARG_ARRAY */
}

DEFUN ("funcall", Ffuncall, Sfuncall, 1, MANY, 0,
  "Call first argument as a function, passing remaining arguments to it.\n\
Return the value that function returns.\n\
Thus, (funcall 'cons 'x 'y) returns (x . y).")
  (nargs, args)
     int nargs;
     Lisp_Object *args;
{
  Lisp_Object fun;
  Lisp_Object funcar;
  int numargs = nargs - 1;
  Lisp_Object lisp_numargs;
  Lisp_Object val;
  struct backtrace backtrace;
  register Lisp_Object *internal_args;
  register int i;

  QUIT;
  if (consing_since_gc > gc_cons_threshold)
    Fgarbage_collect ();

  if (++lisp_eval_depth > max_lisp_eval_depth)
    {
      if (max_lisp_eval_depth < 100)
	max_lisp_eval_depth = 100;
      if (lisp_eval_depth > max_lisp_eval_depth)
	error ("Lisp nesting exceeds max-lisp-eval-depth");
    }

  backtrace.next = backtrace_list;
  backtrace_list = &backtrace;
  backtrace.function = &args[0];
  backtrace.args = &args[1];
  backtrace.nargs = nargs - 1;
  backtrace.evalargs = 0;
  backtrace.debug_on_exit = 0;

  if (debug_on_next_call)
    do_debug_on_call (Qlambda);

 retry:

  fun = args[0];

  fun = Findirect_function (fun);

  if (SUBRP (fun))
    {
      if (numargs < XSUBR (fun)->min_args
	  || (XSUBR (fun)->max_args >= 0 && XSUBR (fun)->max_args < numargs))
	{
	  XSETFASTINT (lisp_numargs, numargs);
	  return Fsignal (Qwrong_number_of_arguments, Fcons (fun, Fcons (lisp_numargs, Qnil)));
	}

      if (XSUBR (fun)->max_args == UNEVALLED)
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));

      if (XSUBR (fun)->max_args == MANY)
	{
	  val = (*XSUBR (fun)->function) (numargs, args + 1);
	  goto done;
	}

      if (XSUBR (fun)->max_args > numargs)
	{
	  internal_args = (Lisp_Object *) alloca (XSUBR (fun)->max_args * sizeof (Lisp_Object));
	  bcopy (args + 1, internal_args, numargs * sizeof (Lisp_Object));
	  for (i = numargs; i < XSUBR (fun)->max_args; i++)
	    internal_args[i] = Qnil;
	}
      else
	internal_args = args + 1;
      switch (XSUBR (fun)->max_args)
	{
	case 0:
	  val = (*XSUBR (fun)->function) ();
	  goto done;
	case 1:
	  val = (*XSUBR (fun)->function) (internal_args[0]);
	  goto done;
	case 2:
	  val = (*XSUBR (fun)->function) (internal_args[0],
					  internal_args[1]);
	  goto done;
	case 3:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2]);
	  goto done;
	case 4:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2],
					  internal_args[3]);
	  goto done;
	case 5:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2], internal_args[3],
					  internal_args[4]);
	  goto done;
	case 6:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2], internal_args[3],
					  internal_args[4], internal_args[5]);
	  goto done;
	case 7:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2], internal_args[3],
					  internal_args[4], internal_args[5],
					  internal_args[6]);
	  goto done;

	case 8:
	  val = (*XSUBR (fun)->function) (internal_args[0], internal_args[1],
					  internal_args[2], internal_args[3],
					  internal_args[4], internal_args[5],
					  internal_args[6], internal_args[7]);
	  goto done;

	default:

	  /* If a subr takes more than 8 arguments without using MANY
	     or UNEVALLED, we need to extend this function to support it. 
	     Until this is done, there is no way to call the function.  */
	  abort ();
	}
    }
  if (COMPILEDP (fun))
    val = funcall_lambda (fun, numargs, args + 1);
  else
    {
      if (!CONSP (fun))
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      funcar = Fcar (fun);
      if (!SYMBOLP (funcar))
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      if (EQ (funcar, Qlambda))
	val = funcall_lambda (fun, numargs, args + 1);
      else if (EQ (funcar, Qmocklisp))
	val = ml_apply (fun, Flist (numargs, args + 1));
      else if (EQ (funcar, Qautoload))
	{
	  do_autoload (fun, args[0]);
	  goto retry;
	}
      else
	return Fsignal (Qinvalid_function, Fcons (fun, Qnil));
    }
 done:
  lisp_eval_depth--;
  if (backtrace.debug_on_exit)
    val = call_debugger (Fcons (Qexit, Fcons (val, Qnil)));
  backtrace_list = backtrace.next;
  return val;
}

Lisp_Object
apply_lambda (fun, args, eval_flag)
     Lisp_Object fun, args;
     int eval_flag;
{
  Lisp_Object args_left;
  Lisp_Object numargs;
  register Lisp_Object *arg_vector;
  struct gcpro gcpro1, gcpro2, gcpro3;
  register int i;
  register Lisp_Object tem;

  numargs = Flength (args);
  arg_vector = (Lisp_Object *) alloca (XINT (numargs) * sizeof (Lisp_Object));
  args_left = args;

  GCPRO3 (*arg_vector, args_left, fun);
  gcpro1.nvars = 0;

  for (i = 0; i < XINT (numargs);)
    {
      tem = Fcar (args_left), args_left = Fcdr (args_left);
      if (eval_flag) tem = Feval (tem);
      arg_vector[i++] = tem;
      gcpro1.nvars = i;
    }

  UNGCPRO;

  if (eval_flag)
    {
      backtrace_list->args = arg_vector;
      backtrace_list->nargs = i;
    }
  backtrace_list->evalargs = 0;
  tem = funcall_lambda (fun, XINT (numargs), arg_vector);

  /* Do the debug-on-exit now, while arg_vector still exists.  */
  if (backtrace_list->debug_on_exit)
    tem = call_debugger (Fcons (Qexit, Fcons (tem, Qnil)));
  /* Don't do it again when we return to eval.  */
  backtrace_list->debug_on_exit = 0;
  return tem;
}

/* Apply a Lisp function FUN to the NARGS evaluated arguments in ARG_VECTOR
   and return the result of evaluation.
   FUN must be either a lambda-expression or a compiled-code object.  */

Lisp_Object
funcall_lambda (fun, nargs, arg_vector)
     Lisp_Object fun;
     int nargs;
     register Lisp_Object *arg_vector;
{
  Lisp_Object val, tem;
  register Lisp_Object syms_left;
  Lisp_Object numargs;
  register Lisp_Object next;
  int count = specpdl_ptr - specpdl;
  register int i;
  int optional = 0, rest = 0;

  specbind (Qmocklisp_arguments, Qt);   /* t means NOT mocklisp! */

  XSETFASTINT (numargs, nargs);

  if (CONSP (fun))
    syms_left = Fcar (Fcdr (fun));
  else if (COMPILEDP (fun))
    syms_left = XVECTOR (fun)->contents[COMPILED_ARGLIST];
  else abort ();

  i = 0;
  for (; !NILP (syms_left); syms_left = Fcdr (syms_left))
    {
      QUIT;
      next = Fcar (syms_left);
      while (!SYMBOLP (next))
	next = Fsignal (Qinvalid_function, Fcons (fun, Qnil));
      if (EQ (next, Qand_rest))
	rest = 1;
      else if (EQ (next, Qand_optional))
	optional = 1;
      else if (rest)
	{
	  specbind (next, Flist (nargs - i, &arg_vector[i]));
	  i = nargs;
	}
      else if (i < nargs)
	{
	  tem = arg_vector[i++];
	  specbind (next, tem);
	}
      else if (!optional)
	return Fsignal (Qwrong_number_of_arguments, Fcons (fun, Fcons (numargs, Qnil)));
      else
	specbind (next, Qnil);
    }

  if (i < nargs)
    return Fsignal (Qwrong_number_of_arguments, Fcons (fun, Fcons (numargs, Qnil)));

  if (CONSP (fun))
    val = Fprogn (Fcdr (Fcdr (fun)));
  else
    {
      /* If we have not actually read the bytecode string
	 and constants vector yet, fetch them from the file.  */
      if (CONSP (XVECTOR (fun)->contents[COMPILED_BYTECODE]))
	Ffetch_bytecode (fun);
      val = Fbyte_code (XVECTOR (fun)->contents[COMPILED_BYTECODE],
			XVECTOR (fun)->contents[COMPILED_CONSTANTS],
			XVECTOR (fun)->contents[COMPILED_STACK_DEPTH]);
    }
  return unbind_to (count, val);
}

DEFUN ("fetch-bytecode", Ffetch_bytecode, Sfetch_bytecode,
  1, 1, 0,
  "If byte-compiled OBJECT is lazy-loaded, fetch it now.")
  (object)
     Lisp_Object object;
{
  Lisp_Object tem;

  if (COMPILEDP (object)
      && CONSP (XVECTOR (object)->contents[COMPILED_BYTECODE]))
    {
      tem = read_doc_string (XVECTOR (object)->contents[COMPILED_BYTECODE]);
      if (!CONSP (tem))
	error ("invalid byte code");
      XVECTOR (object)->contents[COMPILED_BYTECODE] = XCONS (tem)->car;
      XVECTOR (object)->contents[COMPILED_CONSTANTS] = XCONS (tem)->cdr;
    }
  return object;
}

void
grow_specpdl ()
{
  register int count = specpdl_ptr - specpdl;
  if (specpdl_size >= max_specpdl_size)
    {
      if (max_specpdl_size < 400)
	max_specpdl_size = 400;
      if (specpdl_size >= max_specpdl_size)
	{
	  if (!NILP (Vdebug_on_error))
	    /* Leave room for some specpdl in the debugger.  */
	    max_specpdl_size = specpdl_size + 100;
	  Fsignal (Qerror,
		   Fcons (build_string ("Variable binding depth exceeds max-specpdl-size"), Qnil));
	}
    }
  specpdl_size *= 2;
  if (specpdl_size > max_specpdl_size)
    specpdl_size = max_specpdl_size;
  specpdl = (struct specbinding *) xrealloc (specpdl, specpdl_size * sizeof (struct specbinding));
  specpdl_ptr = specpdl + count;
}

void
specbind (symbol, value)
     Lisp_Object symbol, value;
{
  Lisp_Object ovalue;

  CHECK_SYMBOL (symbol, 0);

  if (specpdl_ptr == specpdl + specpdl_size)
    grow_specpdl ();
  specpdl_ptr->symbol = symbol;
  specpdl_ptr->func = 0;
  specpdl_ptr->old_value = ovalue = find_symbol_value (symbol);
  specpdl_ptr++;
  if (BUFFER_OBJFWDP (ovalue) || KBOARD_OBJFWDP (ovalue))
    store_symval_forwarding (symbol, ovalue, value);
  else
    set_internal (symbol, value, 1);
}

void
record_unwind_protect (function, arg)
     Lisp_Object (*function) P_ ((Lisp_Object));
     Lisp_Object arg;
{
  if (specpdl_ptr == specpdl + specpdl_size)
    grow_specpdl ();
  specpdl_ptr->func = function;
  specpdl_ptr->symbol = Qnil;
  specpdl_ptr->old_value = arg;
  specpdl_ptr++;
}

Lisp_Object
unbind_to (count, value)
     int count;
     Lisp_Object value;
{
  int quitf = !NILP (Vquit_flag);
  struct gcpro gcpro1;

  GCPRO1 (value);

  Vquit_flag = Qnil;

  while (specpdl_ptr != specpdl + count)
    {
      --specpdl_ptr;
      if (specpdl_ptr->func != 0)
	(*specpdl_ptr->func) (specpdl_ptr->old_value);
      /* Note that a "binding" of nil is really an unwind protect,
	so in that case the "old value" is a list of forms to evaluate.  */
      else if (NILP (specpdl_ptr->symbol))
	Fprogn (specpdl_ptr->old_value);
      else
        set_internal (specpdl_ptr->symbol, specpdl_ptr->old_value, 1);
    }
  if (NILP (Vquit_flag) && quitf) Vquit_flag = Qt;

  UNGCPRO;

  return value;
}

#if 0

/* Get the value of symbol's global binding, even if that binding
 is not now dynamically visible.  */

Lisp_Object
top_level_value (symbol)
     Lisp_Object symbol;
{
  register struct specbinding *ptr = specpdl;

  CHECK_SYMBOL (symbol, 0);
  for (; ptr != specpdl_ptr; ptr++)
    {
      if (EQ (ptr->symbol, symbol))
	return ptr->old_value;
    }
  return Fsymbol_value (symbol);
}

Lisp_Object
top_level_set (symbol, newval)
     Lisp_Object symbol, newval;
{
  register struct specbinding *ptr = specpdl;

  CHECK_SYMBOL (symbol, 0);
  for (; ptr != specpdl_ptr; ptr++)
    {
      if (EQ (ptr->symbol, symbol))
	{
	  ptr->old_value = newval;
	  return newval;
	}
    }
  return Fset (symbol, newval);
}  

#endif /* 0 */

DEFUN ("backtrace-debug", Fbacktrace_debug, Sbacktrace_debug, 2, 2, 0,
  "Set the debug-on-exit flag of eval frame LEVEL levels down to FLAG.\n\
The debugger is entered when that frame exits, if the flag is non-nil.")
  (level, flag)
     Lisp_Object level, flag;
{
  register struct backtrace *backlist = backtrace_list;
  register int i;

  CHECK_NUMBER (level, 0);

  for (i = 0; backlist && i < XINT (level); i++)
    {
      backlist = backlist->next;
    }

  if (backlist)
    backlist->debug_on_exit = !NILP (flag);

  return flag;
}

DEFUN ("backtrace", Fbacktrace, Sbacktrace, 0, 0, "",
  "Print a trace of Lisp function calls currently active.\n\
Output stream used is value of `standard-output'.")
  ()
{
  register struct backtrace *backlist = backtrace_list;
  register int i;
  Lisp_Object tail;
  Lisp_Object tem;
  extern Lisp_Object Vprint_level;
  struct gcpro gcpro1;

  XSETFASTINT (Vprint_level, 3);

  tail = Qnil;
  GCPRO1 (tail);

  while (backlist)
    {
      write_string (backlist->debug_on_exit ? "* " : "  ", 2);
      if (backlist->nargs == UNEVALLED)
	{
	  Fprin1 (Fcons (*backlist->function, *backlist->args), Qnil);
	  write_string ("\n", -1);
	}
      else
	{
	  tem = *backlist->function;
	  Fprin1 (tem, Qnil);	/* This can QUIT */
	  write_string ("(", -1);
	  if (backlist->nargs == MANY)
	    {
	      for (tail = *backlist->args, i = 0;
		   !NILP (tail);
		   tail = Fcdr (tail), i++)
		{
		  if (i) write_string (" ", -1);
		  Fprin1 (Fcar (tail), Qnil);
		}
	    }
	  else
	    {
	      for (i = 0; i < backlist->nargs; i++)
		{
		  if (i) write_string (" ", -1);
		  Fprin1 (backlist->args[i], Qnil);
		}
	    }
	  write_string (")\n", -1);
	}
      backlist = backlist->next;
    }

  Vprint_level = Qnil;
  UNGCPRO;
  return Qnil;
}

DEFUN ("backtrace-frame", Fbacktrace_frame, Sbacktrace_frame, 1, 1, "",
  "Return the function and arguments NFRAMES up from current execution point.\n\
If that frame has not evaluated the arguments yet (or is a special form),\n\
the value is (nil FUNCTION ARG-FORMS...).\n\
If that frame has evaluated its arguments and called its function already,\n\
the value is (t FUNCTION ARG-VALUES...).\n\
A &rest arg is represented as the tail of the list ARG-VALUES.\n\
FUNCTION is whatever was supplied as car of evaluated list,\n\
or a lambda expression for macro calls.\n\
If NFRAMES is more than the number of frames, the value is nil.")
  (nframes)
     Lisp_Object nframes;
{
  register struct backtrace *backlist = backtrace_list;
  register int i;
  Lisp_Object tem;

  CHECK_NATNUM (nframes, 0);

  /* Find the frame requested.  */
  for (i = 0; backlist && i < XFASTINT (nframes); i++)
    backlist = backlist->next;

  if (!backlist)
    return Qnil;
  if (backlist->nargs == UNEVALLED)
    return Fcons (Qnil, Fcons (*backlist->function, *backlist->args));
  else
    {
      if (backlist->nargs == MANY)
	tem = *backlist->args;
      else
	tem = Flist (backlist->nargs, backlist->args);

      return Fcons (Qt, Fcons (*backlist->function, tem));
    }
}

void
syms_of_eval ()
{
  DEFVAR_INT ("max-specpdl-size", &max_specpdl_size,
    "*Limit on number of Lisp variable bindings & unwind-protects.\n\
If Lisp code tries to make more than this many at once,\n\
an error is signaled.");

  DEFVAR_INT ("max-lisp-eval-depth", &max_lisp_eval_depth,
    "*Limit on depth in `eval', `apply' and `funcall' before error.\n\
This limit is to catch infinite recursions for you before they cause\n\
actual stack overflow in C, which would be fatal for Emacs.\n\
You can safely make it considerably larger than its default value,\n\
if that proves inconveniently small.");

  DEFVAR_LISP ("quit-flag", &Vquit_flag,
    "Non-nil causes `eval' to abort, unless `inhibit-quit' is non-nil.\n\
Typing C-g sets `quit-flag' non-nil, regardless of `inhibit-quit'.");
  Vquit_flag = Qnil;

  DEFVAR_LISP ("inhibit-quit", &Vinhibit_quit,
    "Non-nil inhibits C-g quitting from happening immediately.\n\
Note that `quit-flag' will still be set by typing C-g,\n\
so a quit will be signaled as soon as `inhibit-quit' is nil.\n\
To prevent this happening, set `quit-flag' to nil\n\
before making `inhibit-quit' nil.");
  Vinhibit_quit = Qnil;

  Qinhibit_quit = intern ("inhibit-quit");
  staticpro (&Qinhibit_quit);

  Qautoload = intern ("autoload");
  staticpro (&Qautoload);

  Qdebug_on_error = intern ("debug-on-error");
  staticpro (&Qdebug_on_error);

  Qmacro = intern ("macro");
  staticpro (&Qmacro);

  /* Note that the process handling also uses Qexit, but we don't want
     to staticpro it twice, so we just do it here.  */
  Qexit = intern ("exit");
  staticpro (&Qexit);

  Qinteractive = intern ("interactive");
  staticpro (&Qinteractive);

  Qcommandp = intern ("commandp");
  staticpro (&Qcommandp);

  Qdefun = intern ("defun");
  staticpro (&Qdefun);

  Qand_rest = intern ("&rest");
  staticpro (&Qand_rest);

  Qand_optional = intern ("&optional");
  staticpro (&Qand_optional);

  DEFVAR_LISP ("stack-trace-on-error", &Vstack_trace_on_error,
    "*Non-nil means automatically display a backtrace buffer\n\
after any error that is handled by the editor command loop.\n\
If the value is a list, an error only means to display a backtrace\n\
if one of its condition symbols appears in the list.");
  Vstack_trace_on_error = Qnil;

  DEFVAR_LISP ("debug-on-error", &Vdebug_on_error,
    "*Non-nil means enter debugger if an error is signaled.\n\
Does not apply to errors handled by `condition-case'.\n\
If the value is a list, an error only means to enter the debugger\n\
if one of its condition symbols appears in the list.\n\
See also variable `debug-on-quit'.");
  Vdebug_on_error = Qnil;

  DEFVAR_LISP ("debug-ignored-errors", &Vdebug_ignored_errors,
    "*List of errors for which the debugger should not be called.\n\
Each element may be a condition-name or a regexp that matches error messages.\n\
If any element applies to a given error, that error skips the debugger\n\
and just returns to top level.\n\
This overrides the variable `debug-on-error'.\n\
It does not apply to errors handled by `condition-case'.");
  Vdebug_ignored_errors = Qnil;

  DEFVAR_BOOL ("debug-on-quit", &debug_on_quit,
    "*Non-nil means enter debugger if quit is signaled (C-g, for example).\n\
Does not apply if quit is handled by a `condition-case'.");
  debug_on_quit = 0;

  DEFVAR_BOOL ("debug-on-next-call", &debug_on_next_call,
    "Non-nil means enter debugger before next `eval', `apply' or `funcall'.");

  DEFVAR_LISP ("debugger", &Vdebugger,
    "Function to call to invoke debugger.\n\
If due to frame exit, args are `exit' and the value being returned;\n\
 this function's value will be returned instead of that.\n\
If due to error, args are `error' and a list of the args to `signal'.\n\
If due to `apply' or `funcall' entry, one arg, `lambda'.\n\
If due to `eval' entry, one arg, t.");
  Vdebugger = Qnil;

  DEFVAR_LISP ("signal-hook-function", &Vsignal_hook_function,
    "If non-nil, this is a function for `signal' to call.\n\
It receives the same arguments that `signal' was given.\n\
The Edebug package uses this to regain control.");
  Vsignal_hook_function = Qnil;

  Qmocklisp_arguments = intern ("mocklisp-arguments");
  staticpro (&Qmocklisp_arguments);
  DEFVAR_LISP ("mocklisp-arguments", &Vmocklisp_arguments,
    "While in a mocklisp function, the list of its unevaluated args.");
  Vmocklisp_arguments = Qt;

  DEFVAR_LISP ("debug-on-signal", &Vdebug_on_signal,
    "*Non-nil means call the debugger regardless of condition handlers.\n\
Note that `debug-on-error', `debug-on-quit' and friends\n\
still determine whether to handle the particular condition.");
  Vdebug_on_signal = Qnil;

  Vrun_hooks = intern ("run-hooks");
  staticpro (&Vrun_hooks);

  staticpro (&Vautoload_queue);
  Vautoload_queue = Qnil;

  defsubr (&Sor);
  defsubr (&Sand);
  defsubr (&Sif);
  defsubr (&Scond);
  defsubr (&Sprogn);
  defsubr (&Sprog1);
  defsubr (&Sprog2);
  defsubr (&Ssetq);
  defsubr (&Squote);
  defsubr (&Sfunction);
  defsubr (&Sdefun);
  defsubr (&Sdefmacro);
  defsubr (&Sdefvar);
  defsubr (&Sdefconst);
  defsubr (&Suser_variable_p);
  defsubr (&Slet);
  defsubr (&SletX);
  defsubr (&Swhile);
  defsubr (&Smacroexpand);
  defsubr (&Scatch);
  defsubr (&Sthrow);
  defsubr (&Sunwind_protect);
  defsubr (&Scondition_case);
  defsubr (&Ssignal);
  defsubr (&Sinteractive_p);
  defsubr (&Scommandp);
  defsubr (&Sautoload);
  defsubr (&Seval);
  defsubr (&Sapply);
  defsubr (&Sfuncall);
  defsubr (&Srun_hooks);
  defsubr (&Srun_hook_with_args);
  defsubr (&Srun_hook_with_args_until_success);
  defsubr (&Srun_hook_with_args_until_failure);
  defsubr (&Sfetch_bytecode);
  defsubr (&Sbacktrace_debug);
  defsubr (&Sbacktrace);
  defsubr (&Sbacktrace_frame);
}
