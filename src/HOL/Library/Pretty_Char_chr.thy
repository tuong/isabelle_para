(*  Title:      HOL/Library/Pretty_Char_chr.thy
    ID:         $Id$
    Author:     Florian Haftmann
*)

header {* Code generation of pretty characters with character codes *}

theory Pretty_Char_chr
imports Char_nat Pretty_Char Pretty_Int
begin

definition
  "int_of_char = int o nat_of_char"

lemma [code func]:
  "nat_of_char = nat o int_of_char"
  unfolding int_of_char_def by (simp add: expand_fun_eq)

definition
  "char_of_int = char_of_nat o nat"

lemma [code func]:
  "char_of_nat = char_of_int o int"
  unfolding char_of_int_def by (simp add: expand_fun_eq)

lemmas [code func del] = char.recs char.cases char.size

lemma [code func, code inline]:
  "char_rec f c = split f (nibble_pair_of_nat (nat_of_char c))"
  by (cases c) (auto simp add: nibble_pair_of_nat_char)

lemma [code func, code inline]:
  "char_case f c = split f (nibble_pair_of_nat (nat_of_char c))"
  by (cases c) (auto simp add: nibble_pair_of_nat_char)

lemma [code func]:
  "size (c\<Colon>char) = 0"
  by (cases c) auto

code_const int_of_char and char_of_int
  (SML "!Char.ord" and "!Char.chr")
  (OCaml "Big'_int.big'_int'_of'_int (Char.code _)" and "Char.chr (Big'_int.int'_of'_big'_int _)")
  (Haskell "toInteger (fromEnum (_ :: Char))" and "!(let chr k | k < 256 = toEnum k :: Char in chr . fromInteger)")

end