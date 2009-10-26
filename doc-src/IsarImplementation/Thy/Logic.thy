theory Logic
imports Base
begin

chapter {* Primitive logic \label{ch:logic} *}

text {*
  The logical foundations of Isabelle/Isar are that of the Pure logic,
  which has been introduced as a Natural Deduction framework in
  \cite{paulson700}.  This is essentially the same logic as ``@{text
  "\<lambda>HOL"}'' in the more abstract setting of Pure Type Systems (PTS)
  \cite{Barendregt-Geuvers:2001}, although there are some key
  differences in the specific treatment of simple types in
  Isabelle/Pure.

  Following type-theoretic parlance, the Pure logic consists of three
  levels of @{text "\<lambda>"}-calculus with corresponding arrows, @{text
  "\<Rightarrow>"} for syntactic function space (terms depending on terms), @{text
  "\<And>"} for universal quantification (proofs depending on terms), and
  @{text "\<Longrightarrow>"} for implication (proofs depending on proofs).

  Derivations are relative to a logical theory, which declares type
  constructors, constants, and axioms.  Theory declarations support
  schematic polymorphism, which is strictly speaking outside the
  logic.\footnote{This is the deeper logical reason, why the theory
  context @{text "\<Theta>"} is separate from the proof context @{text "\<Gamma>"}
  of the core calculus.}
*}


section {* Types \label{sec:types} *}

text {*
  The language of types is an uninterpreted order-sorted first-order
  algebra; types are qualified by ordered type classes.

  \medskip A \emph{type class} is an abstract syntactic entity
  declared in the theory context.  The \emph{subclass relation} @{text
  "c\<^isub>1 \<subseteq> c\<^isub>2"} is specified by stating an acyclic
  generating relation; the transitive closure is maintained
  internally.  The resulting relation is an ordering: reflexive,
  transitive, and antisymmetric.

  A \emph{sort} is a list of type classes written as @{text "s =
  {c\<^isub>1, \<dots>, c\<^isub>m}"}, which represents symbolic
  intersection.  Notationally, the curly braces are omitted for
  singleton intersections, i.e.\ any class @{text "c"} may be read as
  a sort @{text "{c}"}.  The ordering on type classes is extended to
  sorts according to the meaning of intersections: @{text
  "{c\<^isub>1, \<dots> c\<^isub>m} \<subseteq> {d\<^isub>1, \<dots>, d\<^isub>n}"} iff
  @{text "\<forall>j. \<exists>i. c\<^isub>i \<subseteq> d\<^isub>j"}.  The empty intersection
  @{text "{}"} refers to the universal sort, which is the largest
  element wrt.\ the sort order.  The intersections of all (finitely
  many) classes declared in the current theory are the minimal
  elements wrt.\ the sort order.

  \medskip A \emph{fixed type variable} is a pair of a basic name
  (starting with a @{text "'"} character) and a sort constraint, e.g.\
  @{text "('a, s)"} which is usually printed as @{text "\<alpha>\<^isub>s"}.
  A \emph{schematic type variable} is a pair of an indexname and a
  sort constraint, e.g.\ @{text "(('a, 0), s)"} which is usually
  printed as @{text "?\<alpha>\<^isub>s"}.

  Note that \emph{all} syntactic components contribute to the identity
  of type variables, including the sort constraint.  The core logic
  handles type variables with the same name but different sorts as
  different, although some outer layers of the system make it hard to
  produce anything like this.

  A \emph{type constructor} @{text "\<kappa>"} is a @{text "k"}-ary operator
  on types declared in the theory.  Type constructor application is
  written postfix as @{text "(\<alpha>\<^isub>1, \<dots>, \<alpha>\<^isub>k)\<kappa>"}.  For
  @{text "k = 0"} the argument tuple is omitted, e.g.\ @{text "prop"}
  instead of @{text "()prop"}.  For @{text "k = 1"} the parentheses
  are omitted, e.g.\ @{text "\<alpha> list"} instead of @{text "(\<alpha>)list"}.
  Further notation is provided for specific constructors, notably the
  right-associative infix @{text "\<alpha> \<Rightarrow> \<beta>"} instead of @{text "(\<alpha>,
  \<beta>)fun"}.
  
  A \emph{type} is defined inductively over type variables and type
  constructors as follows: @{text "\<tau> = \<alpha>\<^isub>s | ?\<alpha>\<^isub>s |
  (\<tau>\<^sub>1, \<dots>, \<tau>\<^sub>k)\<kappa>"}.

  A \emph{type abbreviation} is a syntactic definition @{text
  "(\<^vec>\<alpha>)\<kappa> = \<tau>"} of an arbitrary type expression @{text "\<tau>"} over
  variables @{text "\<^vec>\<alpha>"}.  Type abbreviations appear as type
  constructors in the syntax, but are expanded before entering the
  logical core.

  A \emph{type arity} declares the image behavior of a type
  constructor wrt.\ the algebra of sorts: @{text "\<kappa> :: (s\<^isub>1, \<dots>,
  s\<^isub>k)s"} means that @{text "(\<tau>\<^isub>1, \<dots>, \<tau>\<^isub>k)\<kappa>"} is
  of sort @{text "s"} if every argument type @{text "\<tau>\<^isub>i"} is
  of sort @{text "s\<^isub>i"}.  Arity declarations are implicitly
  completed, i.e.\ @{text "\<kappa> :: (\<^vec>s)c"} entails @{text "\<kappa> ::
  (\<^vec>s)c'"} for any @{text "c' \<supseteq> c"}.

  \medskip The sort algebra is always maintained as \emph{coregular},
  which means that type arities are consistent with the subclass
  relation: for any type constructor @{text "\<kappa>"}, and classes @{text
  "c\<^isub>1 \<subseteq> c\<^isub>2"}, and arities @{text "\<kappa> ::
  (\<^vec>s\<^isub>1)c\<^isub>1"} and @{text "\<kappa> ::
  (\<^vec>s\<^isub>2)c\<^isub>2"} holds @{text "\<^vec>s\<^isub>1 \<subseteq>
  \<^vec>s\<^isub>2"} component-wise.

  The key property of a coregular order-sorted algebra is that sort
  constraints can be solved in a most general fashion: for each type
  constructor @{text "\<kappa>"} and sort @{text "s"} there is a most general
  vector of argument sorts @{text "(s\<^isub>1, \<dots>, s\<^isub>k)"} such
  that a type scheme @{text "(\<alpha>\<^bsub>s\<^isub>1\<^esub>, \<dots>,
  \<alpha>\<^bsub>s\<^isub>k\<^esub>)\<kappa>"} is of sort @{text "s"}.
  Consequently, type unification has most general solutions (modulo
  equivalence of sorts), so type-inference produces primary types as
  expected \cite{nipkow-prehofer}.
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML_type class} \\
  @{index_ML_type sort} \\
  @{index_ML_type arity} \\
  @{index_ML_type typ} \\
  @{index_ML map_atyps: "(typ -> typ) -> typ -> typ"} \\
  @{index_ML fold_atyps: "(typ -> 'a -> 'a) -> typ -> 'a -> 'a"} \\
  \end{mldecls}
  \begin{mldecls}
  @{index_ML Sign.subsort: "theory -> sort * sort -> bool"} \\
  @{index_ML Sign.of_sort: "theory -> typ * sort -> bool"} \\
  @{index_ML Sign.add_types: "(binding * int * mixfix) list -> theory -> theory"} \\
  @{index_ML Sign.add_tyabbrs_i: "
  (binding * string list * typ * mixfix) list -> theory -> theory"} \\
  @{index_ML Sign.primitive_class: "binding * class list -> theory -> theory"} \\
  @{index_ML Sign.primitive_classrel: "class * class -> theory -> theory"} \\
  @{index_ML Sign.primitive_arity: "arity -> theory -> theory"} \\
  \end{mldecls}

  \begin{description}

  \item @{ML_type class} represents type classes; this is an alias for
  @{ML_type string}.

  \item @{ML_type sort} represents sorts; this is an alias for
  @{ML_type "class list"}.

  \item @{ML_type arity} represents type arities; this is an alias for
  triples of the form @{text "(\<kappa>, \<^vec>s, s)"} for @{text "\<kappa> ::
  (\<^vec>s)s"} described above.

  \item @{ML_type typ} represents types; this is a datatype with
  constructors @{ML TFree}, @{ML TVar}, @{ML Type}.

  \item @{ML map_atyps}~@{text "f \<tau>"} applies the mapping @{text "f"}
  to all atomic types (@{ML TFree}, @{ML TVar}) occurring in @{text
  "\<tau>"}.

  \item @{ML fold_atyps}~@{text "f \<tau>"} iterates the operation @{text
  "f"} over all occurrences of atomic types (@{ML TFree}, @{ML TVar})
  in @{text "\<tau>"}; the type structure is traversed from left to right.

  \item @{ML Sign.subsort}~@{text "thy (s\<^isub>1, s\<^isub>2)"}
  tests the subsort relation @{text "s\<^isub>1 \<subseteq> s\<^isub>2"}.

  \item @{ML Sign.of_sort}~@{text "thy (\<tau>, s)"} tests whether type
  @{text "\<tau>"} is of sort @{text "s"}.

  \item @{ML Sign.add_types}~@{text "[(\<kappa>, k, mx), \<dots>]"} declares a new
  type constructors @{text "\<kappa>"} with @{text "k"} arguments and
  optional mixfix syntax.

  \item @{ML Sign.add_tyabbrs_i}~@{text "[(\<kappa>, \<^vec>\<alpha>, \<tau>, mx), \<dots>]"}
  defines a new type abbreviation @{text "(\<^vec>\<alpha>)\<kappa> = \<tau>"} with
  optional mixfix syntax.

  \item @{ML Sign.primitive_class}~@{text "(c, [c\<^isub>1, \<dots>,
  c\<^isub>n])"} declares a new class @{text "c"}, together with class
  relations @{text "c \<subseteq> c\<^isub>i"}, for @{text "i = 1, \<dots>, n"}.

  \item @{ML Sign.primitive_classrel}~@{text "(c\<^isub>1,
  c\<^isub>2)"} declares the class relation @{text "c\<^isub>1 \<subseteq>
  c\<^isub>2"}.

  \item @{ML Sign.primitive_arity}~@{text "(\<kappa>, \<^vec>s, s)"} declares
  the arity @{text "\<kappa> :: (\<^vec>s)s"}.

  \end{description}
*}


section {* Terms \label{sec:terms} *}

text {*
  The language of terms is that of simply-typed @{text "\<lambda>"}-calculus
  with de-Bruijn indices for bound variables (cf.\ \cite{debruijn72}
  or \cite{paulson-ml2}), with the types being determined by the
  corresponding binders.  In contrast, free variables and constants
  are have an explicit name and type in each occurrence.

  \medskip A \emph{bound variable} is a natural number @{text "b"},
  which accounts for the number of intermediate binders between the
  variable occurrence in the body and its binding position.  For
  example, the de-Bruijn term @{text
  "\<lambda>\<^bsub>nat\<^esub>. \<lambda>\<^bsub>nat\<^esub>. 1 + 0"} would
  correspond to @{text
  "\<lambda>x\<^bsub>nat\<^esub>. \<lambda>y\<^bsub>nat\<^esub>. x + y"} in a named
  representation.  Note that a bound variable may be represented by
  different de-Bruijn indices at different occurrences, depending on
  the nesting of abstractions.

  A \emph{loose variable} is a bound variable that is outside the
  scope of local binders.  The types (and names) for loose variables
  can be managed as a separate context, that is maintained as a stack
  of hypothetical binders.  The core logic operates on closed terms,
  without any loose variables.

  A \emph{fixed variable} is a pair of a basic name and a type, e.g.\
  @{text "(x, \<tau>)"} which is usually printed @{text "x\<^isub>\<tau>"}.  A
  \emph{schematic variable} is a pair of an indexname and a type,
  e.g.\ @{text "((x, 0), \<tau>)"} which is usually printed as @{text
  "?x\<^isub>\<tau>"}.

  \medskip A \emph{constant} is a pair of a basic name and a type,
  e.g.\ @{text "(c, \<tau>)"} which is usually printed as @{text
  "c\<^isub>\<tau>"}.  Constants are declared in the context as polymorphic
  families @{text "c :: \<sigma>"}, meaning that all substitution instances
  @{text "c\<^isub>\<tau>"} for @{text "\<tau> = \<sigma>\<vartheta>"} are valid.

  The vector of \emph{type arguments} of constant @{text "c\<^isub>\<tau>"}
  wrt.\ the declaration @{text "c :: \<sigma>"} is defined as the codomain of
  the matcher @{text "\<vartheta> = {?\<alpha>\<^isub>1 \<mapsto> \<tau>\<^isub>1, \<dots>,
  ?\<alpha>\<^isub>n \<mapsto> \<tau>\<^isub>n}"} presented in canonical order @{text
  "(\<tau>\<^isub>1, \<dots>, \<tau>\<^isub>n)"}.  Within a given theory context,
  there is a one-to-one correspondence between any constant @{text
  "c\<^isub>\<tau>"} and the application @{text "c(\<tau>\<^isub>1, \<dots>,
  \<tau>\<^isub>n)"} of its type arguments.  For example, with @{text "plus
  :: \<alpha> \<Rightarrow> \<alpha> \<Rightarrow> \<alpha>"}, the instance @{text "plus\<^bsub>nat \<Rightarrow> nat \<Rightarrow>
  nat\<^esub>"} corresponds to @{text "plus(nat)"}.

  Constant declarations @{text "c :: \<sigma>"} may contain sort constraints
  for type variables in @{text "\<sigma>"}.  These are observed by
  type-inference as expected, but \emph{ignored} by the core logic.
  This means the primitive logic is able to reason with instances of
  polymorphic constants that the user-level type-checker would reject
  due to violation of type class restrictions.

  \medskip An \emph{atomic} term is either a variable or constant.  A
  \emph{term} is defined inductively over atomic terms, with
  abstraction and application as follows: @{text "t = b | x\<^isub>\<tau> |
  ?x\<^isub>\<tau> | c\<^isub>\<tau> | \<lambda>\<^isub>\<tau>. t | t\<^isub>1 t\<^isub>2"}.
  Parsing and printing takes care of converting between an external
  representation with named bound variables.  Subsequently, we shall
  use the latter notation instead of internal de-Bruijn
  representation.

  The inductive relation @{text "t :: \<tau>"} assigns a (unique) type to a
  term according to the structure of atomic terms, abstractions, and
  applicatins:
  \[
  \infer{@{text "a\<^isub>\<tau> :: \<tau>"}}{}
  \qquad
  \infer{@{text "(\<lambda>x\<^sub>\<tau>. t) :: \<tau> \<Rightarrow> \<sigma>"}}{@{text "t :: \<sigma>"}}
  \qquad
  \infer{@{text "t u :: \<sigma>"}}{@{text "t :: \<tau> \<Rightarrow> \<sigma>"} & @{text "u :: \<tau>"}}
  \]
  A \emph{well-typed term} is a term that can be typed according to these rules.

  Typing information can be omitted: type-inference is able to
  reconstruct the most general type of a raw term, while assigning
  most general types to all of its variables and constants.
  Type-inference depends on a context of type constraints for fixed
  variables, and declarations for polymorphic constants.

  The identity of atomic terms consists both of the name and the type
  component.  This means that different variables @{text
  "x\<^bsub>\<tau>\<^isub>1\<^esub>"} and @{text
  "x\<^bsub>\<tau>\<^isub>2\<^esub>"} may become the same after type
  instantiation.  Some outer layers of the system make it hard to
  produce variables of the same name, but different types.  In
  contrast, mixed instances of polymorphic constants occur frequently.

  \medskip The \emph{hidden polymorphism} of a term @{text "t :: \<sigma>"}
  is the set of type variables occurring in @{text "t"}, but not in
  @{text "\<sigma>"}.  This means that the term implicitly depends on type
  arguments that are not accounted in the result type, i.e.\ there are
  different type instances @{text "t\<vartheta> :: \<sigma>"} and @{text
  "t\<vartheta>' :: \<sigma>"} with the same type.  This slightly
  pathological situation notoriously demands additional care.

  \medskip A \emph{term abbreviation} is a syntactic definition @{text
  "c\<^isub>\<sigma> \<equiv> t"} of a closed term @{text "t"} of type @{text "\<sigma>"},
  without any hidden polymorphism.  A term abbreviation looks like a
  constant in the syntax, but is expanded before entering the logical
  core.  Abbreviations are usually reverted when printing terms, using
  @{text "t \<rightarrow> c\<^isub>\<sigma>"} as rules for higher-order rewriting.

  \medskip Canonical operations on @{text "\<lambda>"}-terms include @{text
  "\<alpha>\<beta>\<eta>"}-conversion: @{text "\<alpha>"}-conversion refers to capture-free
  renaming of bound variables; @{text "\<beta>"}-conversion contracts an
  abstraction applied to an argument term, substituting the argument
  in the body: @{text "(\<lambda>x. b)a"} becomes @{text "b[a/x]"}; @{text
  "\<eta>"}-conversion contracts vacuous application-abstraction: @{text
  "\<lambda>x. f x"} becomes @{text "f"}, provided that the bound variable
  does not occur in @{text "f"}.

  Terms are normally treated modulo @{text "\<alpha>"}-conversion, which is
  implicit in the de-Bruijn representation.  Names for bound variables
  in abstractions are maintained separately as (meaningless) comments,
  mostly for parsing and printing.  Full @{text "\<alpha>\<beta>\<eta>"}-conversion is
  commonplace in various standard operations (\secref{sec:obj-rules})
  that are based on higher-order unification and matching.
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML_type term} \\
  @{index_ML "op aconv": "term * term -> bool"} \\
  @{index_ML map_types: "(typ -> typ) -> term -> term"} \\
  @{index_ML fold_types: "(typ -> 'a -> 'a) -> term -> 'a -> 'a"} \\
  @{index_ML map_aterms: "(term -> term) -> term -> term"} \\
  @{index_ML fold_aterms: "(term -> 'a -> 'a) -> term -> 'a -> 'a"} \\
  \end{mldecls}
  \begin{mldecls}
  @{index_ML fastype_of: "term -> typ"} \\
  @{index_ML lambda: "term -> term -> term"} \\
  @{index_ML betapply: "term * term -> term"} \\
  @{index_ML Sign.declare_const: "(binding * typ) * mixfix ->
  theory -> term * theory"} \\
  @{index_ML Sign.add_abbrev: "string -> binding * term ->
  theory -> (term * term) * theory"} \\
  @{index_ML Sign.const_typargs: "theory -> string * typ -> typ list"} \\
  @{index_ML Sign.const_instance: "theory -> string * typ list -> typ"} \\
  \end{mldecls}

  \begin{description}

  \item @{ML_type term} represents de-Bruijn terms, with comments in
  abstractions, and explicitly named free variables and constants;
  this is a datatype with constructors @{ML Bound}, @{ML Free}, @{ML
  Var}, @{ML Const}, @{ML Abs}, @{ML "op $"}.

  \item @{text "t"}~@{ML aconv}~@{text "u"} checks @{text
  "\<alpha>"}-equivalence of two terms.  This is the basic equality relation
  on type @{ML_type term}; raw datatype equality should only be used
  for operations related to parsing or printing!

  \item @{ML map_types}~@{text "f t"} applies the mapping @{text
  "f"} to all types occurring in @{text "t"}.

  \item @{ML fold_types}~@{text "f t"} iterates the operation @{text
  "f"} over all occurrences of types in @{text "t"}; the term
  structure is traversed from left to right.

  \item @{ML map_aterms}~@{text "f t"} applies the mapping @{text "f"}
  to all atomic terms (@{ML Bound}, @{ML Free}, @{ML Var}, @{ML
  Const}) occurring in @{text "t"}.

  \item @{ML fold_aterms}~@{text "f t"} iterates the operation @{text
  "f"} over all occurrences of atomic terms (@{ML Bound}, @{ML Free},
  @{ML Var}, @{ML Const}) in @{text "t"}; the term structure is
  traversed from left to right.

  \item @{ML fastype_of}~@{text "t"} determines the type of a
  well-typed term.  This operation is relatively slow, despite the
  omission of any sanity checks.

  \item @{ML lambda}~@{text "a b"} produces an abstraction @{text
  "\<lambda>a. b"}, where occurrences of the atomic term @{text "a"} in the
  body @{text "b"} are replaced by bound variables.

  \item @{ML betapply}~@{text "(t, u)"} produces an application @{text
  "t u"}, with topmost @{text "\<beta>"}-conversion if @{text "t"} is an
  abstraction.

  \item @{ML Sign.declare_const}~@{text "((c, \<sigma>), mx)"}
  declares a new constant @{text "c :: \<sigma>"} with optional mixfix
  syntax.

  \item @{ML Sign.add_abbrev}~@{text "print_mode (c, t)"}
  introduces a new term abbreviation @{text "c \<equiv> t"}.

  \item @{ML Sign.const_typargs}~@{text "thy (c, \<tau>)"} and @{ML
  Sign.const_instance}~@{text "thy (c, [\<tau>\<^isub>1, \<dots>, \<tau>\<^isub>n])"}
  convert between two representations of polymorphic constants: full
  type instance vs.\ compact type arguments form.

  \end{description}
*}


section {* Theorems \label{sec:thms} *}

text {*
  A \emph{proposition} is a well-typed term of type @{text "prop"}, a
  \emph{theorem} is a proven proposition (depending on a context of
  hypotheses and the background theory).  Primitive inferences include
  plain Natural Deduction rules for the primary connectives @{text
  "\<And>"} and @{text "\<Longrightarrow>"} of the framework.  There is also a builtin
  notion of equality/equivalence @{text "\<equiv>"}.
*}


subsection {* Primitive connectives and rules \label{sec:prim-rules} *}

text {*
  The theory @{text "Pure"} contains constant declarations for the
  primitive connectives @{text "\<And>"}, @{text "\<Longrightarrow>"}, and @{text "\<equiv>"} of
  the logical framework, see \figref{fig:pure-connectives}.  The
  derivability judgment @{text "A\<^isub>1, \<dots>, A\<^isub>n \<turnstile> B"} is
  defined inductively by the primitive inferences given in
  \figref{fig:prim-rules}, with the global restriction that the
  hypotheses must \emph{not} contain any schematic variables.  The
  builtin equality is conceptually axiomatized as shown in
  \figref{fig:pure-equality}, although the implementation works
  directly with derived inferences.

  \begin{figure}[htb]
  \begin{center}
  \begin{tabular}{ll}
  @{text "all :: (\<alpha> \<Rightarrow> prop) \<Rightarrow> prop"} & universal quantification (binder @{text "\<And>"}) \\
  @{text "\<Longrightarrow> :: prop \<Rightarrow> prop \<Rightarrow> prop"} & implication (right associative infix) \\
  @{text "\<equiv> :: \<alpha> \<Rightarrow> \<alpha> \<Rightarrow> prop"} & equality relation (infix) \\
  \end{tabular}
  \caption{Primitive connectives of Pure}\label{fig:pure-connectives}
  \end{center}
  \end{figure}

  \begin{figure}[htb]
  \begin{center}
  \[
  \infer[@{text "(axiom)"}]{@{text "\<turnstile> A"}}{@{text "A \<in> \<Theta>"}}
  \qquad
  \infer[@{text "(assume)"}]{@{text "A \<turnstile> A"}}{}
  \]
  \[
  \infer[@{text "(\<And>_intro)"}]{@{text "\<Gamma> \<turnstile> \<And>x. b[x]"}}{@{text "\<Gamma> \<turnstile> b[x]"} & @{text "x \<notin> \<Gamma>"}}
  \qquad
  \infer[@{text "(\<And>_elim)"}]{@{text "\<Gamma> \<turnstile> b[a]"}}{@{text "\<Gamma> \<turnstile> \<And>x. b[x]"}}
  \]
  \[
  \infer[@{text "(\<Longrightarrow>_intro)"}]{@{text "\<Gamma> - A \<turnstile> A \<Longrightarrow> B"}}{@{text "\<Gamma> \<turnstile> B"}}
  \qquad
  \infer[@{text "(\<Longrightarrow>_elim)"}]{@{text "\<Gamma>\<^sub>1 \<union> \<Gamma>\<^sub>2 \<turnstile> B"}}{@{text "\<Gamma>\<^sub>1 \<turnstile> A \<Longrightarrow> B"} & @{text "\<Gamma>\<^sub>2 \<turnstile> A"}}
  \]
  \caption{Primitive inferences of Pure}\label{fig:prim-rules}
  \end{center}
  \end{figure}

  \begin{figure}[htb]
  \begin{center}
  \begin{tabular}{ll}
  @{text "\<turnstile> (\<lambda>x. b[x]) a \<equiv> b[a]"} & @{text "\<beta>"}-conversion \\
  @{text "\<turnstile> x \<equiv> x"} & reflexivity \\
  @{text "\<turnstile> x \<equiv> y \<Longrightarrow> P x \<Longrightarrow> P y"} & substitution \\
  @{text "\<turnstile> (\<And>x. f x \<equiv> g x) \<Longrightarrow> f \<equiv> g"} & extensionality \\
  @{text "\<turnstile> (A \<Longrightarrow> B) \<Longrightarrow> (B \<Longrightarrow> A) \<Longrightarrow> A \<equiv> B"} & logical equivalence \\
  \end{tabular}
  \caption{Conceptual axiomatization of Pure equality}\label{fig:pure-equality}
  \end{center}
  \end{figure}

  The introduction and elimination rules for @{text "\<And>"} and @{text
  "\<Longrightarrow>"} are analogous to formation of dependently typed @{text
  "\<lambda>"}-terms representing the underlying proof objects.  Proof terms
  are irrelevant in the Pure logic, though; they cannot occur within
  propositions.  The system provides a runtime option to record
  explicit proof terms for primitive inferences.  Thus all three
  levels of @{text "\<lambda>"}-calculus become explicit: @{text "\<Rightarrow>"} for
  terms, and @{text "\<And>/\<Longrightarrow>"} for proofs (cf.\
  \cite{Berghofer-Nipkow:2000:TPHOL}).

  Observe that locally fixed parameters (as in @{text "\<And>_intro"}) need
  not be recorded in the hypotheses, because the simple syntactic
  types of Pure are always inhabitable.  ``Assumptions'' @{text "x ::
  \<tau>"} for type-membership are only present as long as some @{text
  "x\<^isub>\<tau>"} occurs in the statement body.\footnote{This is the key
  difference to ``@{text "\<lambda>HOL"}'' in the PTS framework
  \cite{Barendregt-Geuvers:2001}, where hypotheses @{text "x : A"} are
  treated uniformly for propositions and types.}

  \medskip The axiomatization of a theory is implicitly closed by
  forming all instances of type and term variables: @{text "\<turnstile>
  A\<vartheta>"} holds for any substitution instance of an axiom
  @{text "\<turnstile> A"}.  By pushing substitutions through derivations
  inductively, we also get admissible @{text "generalize"} and @{text
  "instance"} rules as shown in \figref{fig:subst-rules}.

  \begin{figure}[htb]
  \begin{center}
  \[
  \infer{@{text "\<Gamma> \<turnstile> B[?\<alpha>]"}}{@{text "\<Gamma> \<turnstile> B[\<alpha>]"} & @{text "\<alpha> \<notin> \<Gamma>"}}
  \quad
  \infer[\quad@{text "(generalize)"}]{@{text "\<Gamma> \<turnstile> B[?x]"}}{@{text "\<Gamma> \<turnstile> B[x]"} & @{text "x \<notin> \<Gamma>"}}
  \]
  \[
  \infer{@{text "\<Gamma> \<turnstile> B[\<tau>]"}}{@{text "\<Gamma> \<turnstile> B[?\<alpha>]"}}
  \quad
  \infer[\quad@{text "(instantiate)"}]{@{text "\<Gamma> \<turnstile> B[t]"}}{@{text "\<Gamma> \<turnstile> B[?x]"}}
  \]
  \caption{Admissible substitution rules}\label{fig:subst-rules}
  \end{center}
  \end{figure}

  Note that @{text "instantiate"} does not require an explicit
  side-condition, because @{text "\<Gamma>"} may never contain schematic
  variables.

  In principle, variables could be substituted in hypotheses as well,
  but this would disrupt the monotonicity of reasoning: deriving
  @{text "\<Gamma>\<vartheta> \<turnstile> B\<vartheta>"} from @{text "\<Gamma> \<turnstile> B"} is
  correct, but @{text "\<Gamma>\<vartheta> \<supseteq> \<Gamma>"} does not necessarily hold:
  the result belongs to a different proof context.

  \medskip An \emph{oracle} is a function that produces axioms on the
  fly.  Logically, this is an instance of the @{text "axiom"} rule
  (\figref{fig:prim-rules}), but there is an operational difference.
  The system always records oracle invocations within derivations of
  theorems by a unique tag.

  Axiomatizations should be limited to the bare minimum, typically as
  part of the initial logical basis of an object-logic formalization.
  Later on, theories are usually developed in a strictly definitional
  fashion, by stating only certain equalities over new constants.

  A \emph{simple definition} consists of a constant declaration @{text
  "c :: \<sigma>"} together with an axiom @{text "\<turnstile> c \<equiv> t"}, where @{text "t
  :: \<sigma>"} is a closed term without any hidden polymorphism.  The RHS
  may depend on further defined constants, but not @{text "c"} itself.
  Definitions of functions may be presented as @{text "c \<^vec>x \<equiv>
  t"} instead of the puristic @{text "c \<equiv> \<lambda>\<^vec>x. t"}.

  An \emph{overloaded definition} consists of a collection of axioms
  for the same constant, with zero or one equations @{text
  "c((\<^vec>\<alpha>)\<kappa>) \<equiv> t"} for each type constructor @{text "\<kappa>"} (for
  distinct variables @{text "\<^vec>\<alpha>"}).  The RHS may mention
  previously defined constants as above, or arbitrary constants @{text
  "d(\<alpha>\<^isub>i)"} for some @{text "\<alpha>\<^isub>i"} projected from @{text
  "\<^vec>\<alpha>"}.  Thus overloaded definitions essentially work by
  primitive recursion over the syntactic structure of a single type
  argument.
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML_type ctyp} \\
  @{index_ML_type cterm} \\
  @{index_ML Thm.ctyp_of: "theory -> typ -> ctyp"} \\
  @{index_ML Thm.cterm_of: "theory -> term -> cterm"} \\
  \end{mldecls}
  \begin{mldecls}
  @{index_ML_type thm} \\
  @{index_ML proofs: "int Unsynchronized.ref"} \\
  @{index_ML Thm.assume: "cterm -> thm"} \\
  @{index_ML Thm.forall_intr: "cterm -> thm -> thm"} \\
  @{index_ML Thm.forall_elim: "cterm -> thm -> thm"} \\
  @{index_ML Thm.implies_intr: "cterm -> thm -> thm"} \\
  @{index_ML Thm.implies_elim: "thm -> thm -> thm"} \\
  @{index_ML Thm.generalize: "string list * string list -> int -> thm -> thm"} \\
  @{index_ML Thm.instantiate: "(ctyp * ctyp) list * (cterm * cterm) list -> thm -> thm"} \\
  @{index_ML Thm.axiom: "theory -> string -> thm"} \\
  @{index_ML Thm.add_oracle: "binding * ('a -> cterm) -> theory
  -> (string * ('a -> thm)) * theory"} \\
  \end{mldecls}
  \begin{mldecls}
  @{index_ML Theory.add_axioms_i: "(binding * term) list -> theory -> theory"} \\
  @{index_ML Theory.add_deps: "string -> string * typ -> (string * typ) list -> theory -> theory"} \\
  @{index_ML Theory.add_defs_i: "bool -> bool -> (binding * term) list -> theory -> theory"} \\
  \end{mldecls}

  \begin{description}

  \item @{ML_type ctyp} and @{ML_type cterm} represent certified types
  and terms, respectively.  These are abstract datatypes that
  guarantee that its values have passed the full well-formedness (and
  well-typedness) checks, relative to the declarations of type
  constructors, constants etc. in the theory.

  \item @{ML Thm.ctyp_of}~@{text "thy \<tau>"} and @{ML
  Thm.cterm_of}~@{text "thy t"} explicitly checks types and terms,
  respectively.  This also involves some basic normalizations, such
  expansion of type and term abbreviations from the theory context.

  Re-certification is relatively slow and should be avoided in tight
  reasoning loops.  There are separate operations to decompose
  certified entities (including actual theorems).

  \item @{ML_type thm} represents proven propositions.  This is an
  abstract datatype that guarantees that its values have been
  constructed by basic principles of the @{ML_struct Thm} module.
  Every @{ML thm} value contains a sliding back-reference to the
  enclosing theory, cf.\ \secref{sec:context-theory}.

  \item @{ML proofs} determines the detail of proof recording within
  @{ML_type thm} values: @{ML 0} records only the names of oracles,
  @{ML 1} records oracle names and propositions, @{ML 2} additionally
  records full proof terms.  Officially named theorems that contribute
  to a result are always recorded.

  \item @{ML Thm.assume}, @{ML Thm.forall_intr}, @{ML
  Thm.forall_elim}, @{ML Thm.implies_intr}, and @{ML Thm.implies_elim}
  correspond to the primitive inferences of \figref{fig:prim-rules}.

  \item @{ML Thm.generalize}~@{text "(\<^vec>\<alpha>, \<^vec>x)"}
  corresponds to the @{text "generalize"} rules of
  \figref{fig:subst-rules}.  Here collections of type and term
  variables are generalized simultaneously, specified by the given
  basic names.

  \item @{ML Thm.instantiate}~@{text "(\<^vec>\<alpha>\<^isub>s,
  \<^vec>x\<^isub>\<tau>)"} corresponds to the @{text "instantiate"} rules
  of \figref{fig:subst-rules}.  Type variables are substituted before
  term variables.  Note that the types in @{text "\<^vec>x\<^isub>\<tau>"}
  refer to the instantiated versions.

  \item @{ML Thm.axiom}~@{text "thy name"} retrieves a named
  axiom, cf.\ @{text "axiom"} in \figref{fig:prim-rules}.

  \item @{ML Thm.add_oracle}~@{text "(binding, oracle)"} produces a named
  oracle rule, essentially generating arbitrary axioms on the fly,
  cf.\ @{text "axiom"} in \figref{fig:prim-rules}.

  \item @{ML Theory.add_axioms_i}~@{text "[(name, A), \<dots>]"} declares
  arbitrary propositions as axioms.

  \item @{ML Theory.add_deps}~@{text "name c\<^isub>\<tau>
  \<^vec>d\<^isub>\<sigma>"} declares dependencies of a named specification
  for constant @{text "c\<^isub>\<tau>"}, relative to existing
  specifications for constants @{text "\<^vec>d\<^isub>\<sigma>"}.

  \item @{ML Theory.add_defs_i}~@{text "unchecked overloaded [(name, c
  \<^vec>x \<equiv> t), \<dots>]"} states a definitional axiom for an existing
  constant @{text "c"}.  Dependencies are recorded (cf.\ @{ML
  Theory.add_deps}), unless the @{text "unchecked"} option is set.

  \end{description}
*}


subsection {* Auxiliary definitions *}

text {*
  Theory @{text "Pure"} provides a few auxiliary definitions, see
  \figref{fig:pure-aux}.  These special constants are normally not
  exposed to the user, but appear in internal encodings.

  \begin{figure}[htb]
  \begin{center}
  \begin{tabular}{ll}
  @{text "conjunction :: prop \<Rightarrow> prop \<Rightarrow> prop"} & (infix @{text "&"}) \\
  @{text "\<turnstile> A & B \<equiv> (\<And>C. (A \<Longrightarrow> B \<Longrightarrow> C) \<Longrightarrow> C)"} \\[1ex]
  @{text "prop :: prop \<Rightarrow> prop"} & (prefix @{text "#"}, suppressed) \\
  @{text "#A \<equiv> A"} \\[1ex]
  @{text "term :: \<alpha> \<Rightarrow> prop"} & (prefix @{text "TERM"}) \\
  @{text "term x \<equiv> (\<And>A. A \<Longrightarrow> A)"} \\[1ex]
  @{text "TYPE :: \<alpha> itself"} & (prefix @{text "TYPE"}) \\
  @{text "(unspecified)"} \\
  \end{tabular}
  \caption{Definitions of auxiliary connectives}\label{fig:pure-aux}
  \end{center}
  \end{figure}

  Derived conjunction rules include introduction @{text "A \<Longrightarrow> B \<Longrightarrow> A &
  B"}, and destructions @{text "A & B \<Longrightarrow> A"} and @{text "A & B \<Longrightarrow> B"}.
  Conjunction allows to treat simultaneous assumptions and conclusions
  uniformly.  For example, multiple claims are intermediately
  represented as explicit conjunction, but this is refined into
  separate sub-goals before the user continues the proof; the final
  result is projected into a list of theorems (cf.\
  \secref{sec:tactical-goals}).

  The @{text "prop"} marker (@{text "#"}) makes arbitrarily complex
  propositions appear as atomic, without changing the meaning: @{text
  "\<Gamma> \<turnstile> A"} and @{text "\<Gamma> \<turnstile> #A"} are interchangeable.  See
  \secref{sec:tactical-goals} for specific operations.

  The @{text "term"} marker turns any well-typed term into a derivable
  proposition: @{text "\<turnstile> TERM t"} holds unconditionally.  Although
  this is logically vacuous, it allows to treat terms and proofs
  uniformly, similar to a type-theoretic framework.

  The @{text "TYPE"} constructor is the canonical representative of
  the unspecified type @{text "\<alpha> itself"}; it essentially injects the
  language of types into that of terms.  There is specific notation
  @{text "TYPE(\<tau>)"} for @{text "TYPE\<^bsub>\<tau>
 itself\<^esub>"}.
  Although being devoid of any particular meaning, the @{text
  "TYPE(\<tau>)"} accounts for the type @{text "\<tau>"} within the term
  language.  In particular, @{text "TYPE(\<alpha>)"} may be used as formal
  argument in primitive definitions, in order to circumvent hidden
  polymorphism (cf.\ \secref{sec:terms}).  For example, @{text "c
  TYPE(\<alpha>) \<equiv> A[\<alpha>]"} defines @{text "c :: \<alpha> itself \<Rightarrow> prop"} in terms of
  a proposition @{text "A"} that depends on an additional type
  argument, which is essentially a predicate on types.
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML Conjunction.intr: "thm -> thm -> thm"} \\
  @{index_ML Conjunction.elim: "thm -> thm * thm"} \\
  @{index_ML Drule.mk_term: "cterm -> thm"} \\
  @{index_ML Drule.dest_term: "thm -> cterm"} \\
  @{index_ML Logic.mk_type: "typ -> term"} \\
  @{index_ML Logic.dest_type: "term -> typ"} \\
  \end{mldecls}

  \begin{description}

  \item @{ML Conjunction.intr} derives @{text "A & B"} from @{text
  "A"} and @{text "B"}.

  \item @{ML Conjunction.elim} derives @{text "A"} and @{text "B"}
  from @{text "A & B"}.

  \item @{ML Drule.mk_term} derives @{text "TERM t"}.

  \item @{ML Drule.dest_term} recovers term @{text "t"} from @{text
  "TERM t"}.

  \item @{ML Logic.mk_type}~@{text "\<tau>"} produces the term @{text
  "TYPE(\<tau>)"}.

  \item @{ML Logic.dest_type}~@{text "TYPE(\<tau>)"} recovers the type
  @{text "\<tau>"}.

  \end{description}
*}


section {* Object-level rules \label{sec:obj-rules} *}

text {*
  The primitive inferences covered so far mostly serve foundational
  purposes.  User-level reasoning usually works via object-level rules
  that are represented as theorems of Pure.  Composition of rules
  involves \emph{backchaining}, \emph{higher-order unification} modulo
  @{text "\<alpha>\<beta>\<eta>"}-conversion of @{text "\<lambda>"}-terms, and so-called
  \emph{lifting} of rules into a context of @{text "\<And>"} and @{text
  "\<Longrightarrow>"} connectives.  Thus the full power of higher-order Natural
  Deduction in Isabelle/Pure becomes readily available.
*}


subsection {* Hereditary Harrop Formulae *}

text {*
  The idea of object-level rules is to model Natural Deduction
  inferences in the style of Gentzen \cite{Gentzen:1935}, but we allow
  arbitrary nesting similar to \cite{extensions91}.  The most basic
  rule format is that of a \emph{Horn Clause}:
  \[
  \infer{@{text "A"}}{@{text "A\<^sub>1"} & @{text "\<dots>"} & @{text "A\<^sub>n"}}
  \]
  where @{text "A, A\<^sub>1, \<dots>, A\<^sub>n"} are atomic propositions
  of the framework, usually of the form @{text "Trueprop B"}, where
  @{text "B"} is a (compound) object-level statement.  This
  object-level inference corresponds to an iterated implication in
  Pure like this:
  \[
  @{text "A\<^sub>1 \<Longrightarrow> \<dots> A\<^sub>n \<Longrightarrow> A"}
  \]
  As an example consider conjunction introduction: @{text "A \<Longrightarrow> B \<Longrightarrow> A \<and>
  B"}.  Any parameters occurring in such rule statements are
  conceptionally treated as arbitrary:
  \[
  @{text "\<And>x\<^sub>1 \<dots> x\<^sub>m. A\<^sub>1 x\<^sub>1 \<dots> x\<^sub>m \<Longrightarrow> \<dots> A\<^sub>n x\<^sub>1 \<dots> x\<^sub>m \<Longrightarrow> A x\<^sub>1 \<dots> x\<^sub>m"}
  \]

  Nesting of rules means that the positions of @{text "A\<^sub>i"} may
  again hold compound rules, not just atomic propositions.
  Propositions of this format are called \emph{Hereditary Harrop
  Formulae} in the literature \cite{Miller:1991}.  Here we give an
  inductive characterization as follows:

  \medskip
  \begin{tabular}{ll}
  @{text "\<^bold>x"} & set of variables \\
  @{text "\<^bold>A"} & set of atomic propositions \\
  @{text "\<^bold>H  =  \<And>\<^bold>x\<^sup>*. \<^bold>H\<^sup>* \<Longrightarrow> \<^bold>A"} & set of Hereditary Harrop Formulas \\
  \end{tabular}
  \medskip

  \noindent Thus we essentially impose nesting levels on propositions
  formed from @{text "\<And>"} and @{text "\<Longrightarrow>"}.  At each level there is a
  prefix of parameters and compound premises, concluding an atomic
  proposition.  Typical examples are @{text "\<longrightarrow>"}-introduction @{text
  "(A \<Longrightarrow> B) \<Longrightarrow> A \<longrightarrow> B"} or mathematical induction @{text "P 0 \<Longrightarrow> (\<And>n. P n
  \<Longrightarrow> P (Suc n)) \<Longrightarrow> P n"}.  Even deeper nesting occurs in well-founded
  induction @{text "(\<And>x. (\<And>y. y \<prec> x \<Longrightarrow> P y) \<Longrightarrow> P x) \<Longrightarrow> P x"}, but this
  already marks the limit of rule complexity seen in practice.

  \medskip Regular user-level inferences in Isabelle/Pure always
  maintain the following canonical form of results:

  \begin{itemize}

  \item Normalization by @{text "(A \<Longrightarrow> (\<And>x. B x)) \<equiv> (\<And>x. A \<Longrightarrow> B x)"},
  which is a theorem of Pure, means that quantifiers are pushed in
  front of implication at each level of nesting.  The normal form is a
  Hereditary Harrop Formula.

  \item The outermost prefix of parameters is represented via
  schematic variables: instead of @{text "\<And>\<^vec>x. \<^vec>H \<^vec>x
  \<Longrightarrow> A \<^vec>x"} we have @{text "\<^vec>H ?\<^vec>x \<Longrightarrow> A ?\<^vec>x"}.
  Note that this representation looses information about the order of
  parameters, and vacuous quantifiers vanish automatically.

  \end{itemize}
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML Simplifier.norm_hhf: "thm -> thm"} \\
  \end{mldecls}

  \begin{description}

  \item @{ML Simplifier.norm_hhf}~@{text thm} normalizes the given
  theorem according to the canonical form specified above.  This is
  occasionally helpful to repair some low-level tools that do not
  handle Hereditary Harrop Formulae properly.

  \end{description}
*}


subsection {* Rule composition *}

text {*
  The rule calculus of Isabelle/Pure provides two main inferences:
  @{inference resolution} (i.e.\ back-chaining of rules) and
  @{inference assumption} (i.e.\ closing a branch), both modulo
  higher-order unification.  There are also combined variants, notably
  @{inference elim_resolution} and @{inference dest_resolution}.

  To understand the all-important @{inference resolution} principle,
  we first consider raw @{inference_def composition} (modulo
  higher-order unification with substitution @{text "\<vartheta>"}):
  \[
  \infer[(@{inference_def composition})]{@{text "\<^vec>A\<vartheta> \<Longrightarrow> C\<vartheta>"}}
  {@{text "\<^vec>A \<Longrightarrow> B"} & @{text "B' \<Longrightarrow> C"} & @{text "B\<vartheta> = B'\<vartheta>"}}
  \]
  Here the conclusion of the first rule is unified with the premise of
  the second; the resulting rule instance inherits the premises of the
  first and conclusion of the second.  Note that @{text "C"} can again
  consist of iterated implications.  We can also permute the premises
  of the second rule back-and-forth in order to compose with @{text
  "B'"} in any position (subsequently we shall always refer to
  position 1 w.l.o.g.).

  In @{inference composition} the internal structure of the common
  part @{text "B"} and @{text "B'"} is not taken into account.  For
  proper @{inference resolution} we require @{text "B"} to be atomic,
  and explicitly observe the structure @{text "\<And>\<^vec>x. \<^vec>H
  \<^vec>x \<Longrightarrow> B' \<^vec>x"} of the premise of the second rule.  The
  idea is to adapt the first rule by ``lifting'' it into this context,
  by means of iterated application of the following inferences:
  \[
  \infer[(@{inference_def imp_lift})]{@{text "(\<^vec>H \<Longrightarrow> \<^vec>A) \<Longrightarrow> (\<^vec>H \<Longrightarrow> B)"}}{@{text "\<^vec>A \<Longrightarrow> B"}}
  \]
  \[
  \infer[(@{inference_def all_lift})]{@{text "(\<And>\<^vec>x. \<^vec>A (?\<^vec>a \<^vec>x)) \<Longrightarrow> (\<And>\<^vec>x. B (?\<^vec>a \<^vec>x))"}}{@{text "\<^vec>A ?\<^vec>a \<Longrightarrow> B ?\<^vec>a"}}
  \]
  By combining raw composition with lifting, we get full @{inference
  resolution} as follows:
  \[
  \infer[(@{inference_def resolution})]
  {@{text "(\<And>\<^vec>x. \<^vec>H \<^vec>x \<Longrightarrow> \<^vec>A (?\<^vec>a \<^vec>x))\<vartheta> \<Longrightarrow> C\<vartheta>"}}
  {\begin{tabular}{l}
    @{text "\<^vec>A ?\<^vec>a \<Longrightarrow> B ?\<^vec>a"} \\
    @{text "(\<And>\<^vec>x. \<^vec>H \<^vec>x \<Longrightarrow> B' \<^vec>x) \<Longrightarrow> C"} \\
    @{text "(\<lambda>\<^vec>x. B (?\<^vec>a \<^vec>x))\<vartheta> = B'\<vartheta>"} \\
   \end{tabular}}
  \]

  Continued resolution of rules allows to back-chain a problem towards
  more and sub-problems.  Branches are closed either by resolving with
  a rule of 0 premises, or by producing a ``short-circuit'' within a
  solved situation (again modulo unification):
  \[
  \infer[(@{inference_def assumption})]{@{text "C\<vartheta>"}}
  {@{text "(\<And>\<^vec>x. \<^vec>H \<^vec>x \<Longrightarrow> A \<^vec>x) \<Longrightarrow> C"} & @{text "A\<vartheta> = H\<^sub>i\<vartheta>"}~~\text{(for some~@{text i})}}
  \]

  FIXME @{inference_def elim_resolution}, @{inference_def dest_resolution}
*}

text %mlref {*
  \begin{mldecls}
  @{index_ML "op RS": "thm * thm -> thm"} \\
  @{index_ML "op OF": "thm * thm list -> thm"} \\
  \end{mldecls}

  \begin{description}

  \item @{text "rule\<^sub>1 RS rule\<^sub>2"} resolves @{text
  "rule\<^sub>1"} with @{text "rule\<^sub>2"} according to the
  @{inference resolution} principle explained above.  Note that the
  corresponding attribute in the Isar language is called @{attribute
  THEN}.

  \item @{text "rule OF rules"} resolves a list of rules with the
  first rule, addressing its premises @{text "1, \<dots>, length rules"}
  (operating from last to first).  This means the newly emerging
  premises are all concatenated, without interfering.  Also note that
  compared to @{text "RS"}, the rule argument order is swapped: @{text
  "rule\<^sub>1 RS rule\<^sub>2 = rule\<^sub>2 OF [rule\<^sub>1]"}.

  \end{description}
*}

end
