(* $Id$ *)

theory ZF_Specific
imports ZF
begin

chapter {* Isabelle/ZF \label{ch:zf} *}

section {* Type checking *}

text {*
  The ZF logic is essentially untyped, so the concept of ``type
  checking'' is performed as logical reasoning about set-membership
  statements.  A special method assists users in this task; a version
  of this is already declared as a ``solver'' in the standard
  Simplifier setup.

  \begin{matharray}{rcl}
    @{command_def (ZF) "print_tcset"}@{text "\<^sup>*"} & : & \isarkeep{theory~|~proof} \\
    @{method_def (ZF) typecheck} & : & \isarmeth \\
    @{attribute_def (ZF) TC} & : & \isaratt \\
  \end{matharray}

  \begin{rail}
    'TC' (() | 'add' | 'del')
    ;
  \end{rail}

  \begin{descr}
  
  \item [@{command (ZF) "print_tcset"}] prints the collection of
  typechecking rules of the current context.
  
  \item [@{method (ZF) typecheck}] attempts to solve any pending
  type-checking problems in subgoals.
  
  \item [@{attribute (ZF) TC}] adds or deletes type-checking rules
  from the context.

  \end{descr}
*}


section {* (Co)Inductive sets and datatypes *}

subsection {* Set definitions *}

text {*
  In ZF everything is a set.  The generic inductive package also
  provides a specific view for ``datatype'' specifications.
  Coinductive definitions are available in both cases, too.

  \begin{matharray}{rcl}
    @{command_def (ZF) "inductive"} & : & \isartrans{theory}{theory} \\
    @{command_def (ZF) "coinductive"} & : & \isartrans{theory}{theory} \\
    @{command_def (ZF) "datatype"} & : & \isartrans{theory}{theory} \\
    @{command_def (ZF) "codatatype"} & : & \isartrans{theory}{theory} \\
  \end{matharray}

  \begin{rail}
    ('inductive' | 'coinductive') domains intros hints
    ;

    domains: 'domains' (term + '+') ('<=' | subseteq) term
    ;
    intros: 'intros' (thmdecl? prop +)
    ;
    hints: monos? condefs? typeintros? typeelims?
    ;
    monos: ('monos' thmrefs)?
    ;
    condefs: ('con\_defs' thmrefs)?
    ;
    typeintros: ('type\_intros' thmrefs)?
    ;
    typeelims: ('type\_elims' thmrefs)?
    ;
  \end{rail}

  In the following syntax specification @{text "monos"}, @{text
  typeintros}, and @{text typeelims} are the same as above.

  \begin{rail}
    ('datatype' | 'codatatype') domain? (dtspec + 'and') hints
    ;

    domain: ('<=' | subseteq) term
    ;
    dtspec: term '=' (con + '|')
    ;
    con: name ('(' (term ',' +) ')')?  
    ;
    hints: monos? typeintros? typeelims?
    ;
  \end{rail}

  See \cite{isabelle-ZF} for further information on inductive
  definitions in ZF, but note that this covers the old-style theory
  format.
*}


subsection {* Primitive recursive functions *}

text {*
  \begin{matharray}{rcl}
    @{command_def (ZF) "primrec"} & : & \isartrans{theory}{theory} \\
  \end{matharray}

  \begin{rail}
    'primrec' (thmdecl? prop +)
    ;
  \end{rail}
*}


subsection {* Cases and induction: emulating tactic scripts *}

text {*
  The following important tactical tools of Isabelle/ZF have been
  ported to Isar.  These should not be used in proper proof texts.

  \begin{matharray}{rcl}
    @{method_def (ZF) case_tac}@{text "\<^sup>*"} & : & \isarmeth \\
    @{method_def (ZF) induct_tac}@{text "\<^sup>*"} & : & \isarmeth \\
    @{method_def (ZF) ind_cases}@{text "\<^sup>*"} & : & \isarmeth \\
    @{command_def (ZF) "inductive_cases"} & : & \isartrans{theory}{theory} \\
  \end{matharray}

  \begin{rail}
    ('case\_tac' | 'induct\_tac') goalspec? name
    ;
    indcases (prop +)
    ;
    inductivecases (thmdecl? (prop +) + 'and')
    ;
  \end{rail}
*}

end
