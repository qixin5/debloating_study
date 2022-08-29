;;; tibetan.el --- Support for Tibetan language -*- coding: iso-2022-7bit; -*-

;; Copyright (C) 1997 Electrotechnical Laboratory, JAPAN.
;; Licensed to the Free Software Foundation.

;; Keywords: multilingual, Tibetan

;; This file is part of GNU Emacs.

;; GNU Emacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; GNU Emacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;; Author: Toru TOMABECHI, <Toru.Tomabechi@orient.unil.ch>

;; Created: Feb. 17. 1997

;; History:
;; 1997.03.13 Modification for special signs and punctuations. 

;;; Code:

;;; Tibetan Character set.
;;; \x2130 -- \x234a is a subset of Unicode v.2 \x0f00 - \x0fb9
;;; with a slight modification. And there are some subjoined
;;; consonants which are not specified in Unicode.
;;; I hope I can add missing characters later.
;;;
;;;     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
;;;2120 // $(7!!(B $(7!"(B $(7!#(B $(7!$(B $(7!%(B $(7!&(B $(7!'(B $(7!((B $(7!)(B $(7!*(B $(7!+(B $(7!,(B $(7!-(B $(7!.(B $(7!/(B ;
;;;2130 $(7!0(B $(7!1(B $(7!2(B $(7!3(B $(7!4(B $(7!5(B $(7!6(B $(7!7(B $(7!8(B $(7!9(B $(7!:(B $(7!;(B $(7!<(B $(7!=(B $(7!>(B $(7!?(B ; Punctuations,
;;;2140 $(7!@(B $(7!A(B $(7!B(B $(7!C(B $(7!D(B $(7!E(B $(7!F(B $(7!G(B $(7!H(B $(7!I(B $(7!J(B $(7!K(B $(7!L(B $(7!M(B $(7!N(B $(7!O(B ; Digits and
;;;2150 $(7!P(B $(7!Q(B $(7!R(B $(7!S(B $(7!T(B $(7!U(B $(7!V(B $(7!W(B $(7!X(B $(7!Y(B $(7!Z(B $(7![(B $(7!\(B $(7!](B $(7!^(B $(7!_(B ; Special signs.
;;;2160 $(7!`(B $(7!a(B $(7!b(B $(7!c(B $(7!d(B $(7!e(B $(7!f(B $(7!g(B $(7!h(B $(7!i(B $(7!j(B $(7!k(B $(7!l(B $(7!m(B $(7!n(B $(7!o(B ;
;;;2170 $(7!p(B $(7!q(B $(7!r(B $(7!s(B $(7!t(B $(7!u(B $(7!v(B $(7!w(B $(7!x(B $(7!y(B $(7!z(B $(7!{(B $(7!|(B $(7!}(B $(7!~(B // ;
;;;
;;;     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
;;;2220 // $(7"!(B $(7""(B $(7"#(B $(7"$(B $(7"%(B $(7"&(B $(7"'(B $(7"((B $(7")(B $(7"*(B $(7"+(B $(7",(B $(7"-(B $(7".(B $(7"/(B ; Base consonants
;;;2230 $(7"0(B $(7"1(B $(7"2(B $(7"3(B $(7"4(B $(7"5(B $(7"6(B $(7"7(B $(7"8(B $(7"9(B $(7":(B $(7";(B $(7"<(B $(7"=(B $(7">(B $(7"?(B ; and
;;;2240 $(7"@(B $(7"A(B $(7"B(B $(7"C(B $(7"D(B $(7"E(B $(7"F(B $(7"G(B $(7"H(B $(7"I(B $(7"J(B $(7"K(B $(7"L(B $(7"M(B $(7"N(B $(7"O(B ; Vowel signs.
;;;2250 $(7"P(B $(7"Q(B $(7"R(B $(7"S(B $(7"T(B $(7"U(B $(7"V(B $(7"W(B $(7"X(B $(7"Y(B $(7"Z(B $(7"[(B $(7"\(B $(7"](B $(7"^(B $(7"_(B ; (\x2251 = vowel a)
;;;2260 $(7"`(B $(7"a(B $(7"b(B $(7"c(B $(7"d(B $(7"e(B $(7"f(B $(7"g(B $(7"h(B $(7"i(B $(7"j(B $(7"k(B $(7"l(B $(7"m(B $(7"n(B $(7"o(B ; Long vowels and
;;;2270 $(7"p(B $(7"q(B $(7"r(B $(7"s(B $(7"t(B $(7"u(B $(7"v(B $(7"w(B $(7"x(B $(7"y(B $(7"z(B $(7"{(B $(7"|(B $(7"}(B $(7"~(B // ; vocalic r, l are
;;;                                                     ; not atomically
;;;                                                     ; encoded. 
;;;     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
;;;2320 // $(7#!(B $(7#"(B $(7##(B $(7#$(B $(7#%(B $(7#&(B $(7#'(B $(7#((B $(7#)(B $(7#*(B $(7#+(B $(7#,(B $(7#-(B $(7#.(B $(7#/(B ; Subjoined consonants
;;;2330 $(7#0(B $(7#1(B $(7#2(B $(7#3(B $(7#4(B $(7#5(B $(7#6(B $(7#7(B $(7#8(B $(7#9(B $(7#:(B $(7#;(B $(7#<(B $(7#=(B $(7#>(B $(7#?(B ;
;;;2340 $(7#@(B $(7#A(B $(7#B(B $(7#C(B $(7#D(B $(7#E(B $(7#F(B $(7#G(B $(7#H(B $(7#I(B $(7#J(B $(7#K(B $(7#L(B $(7#M(B $(7#N(B $(7#O(B ; 'a chung (\x2341)is
;;;                                                     ; here,
;;;                                                     ; while in Unicode
;;;                                                     ; it is classified
;;;                                                     ; as a vowel sign
;;;                                                     ; (\x0f71).
;;;
;;;2350 $(7#P(B $(7#Q(B $(7#R(B $(7#S(B $(7#T(B $(7#U(B $(7#V(B $(7#W(B $(7#X(B $(7#Y(B $(7#Z(B $(7#[(B $(7#\(B $(7#](B $(7#^(B $(7#_(B ; Hereafter, the chars
;;;2360 $(7#`(B $(7#a(B $(7#b(B $(7#c(B $(7#d(B $(7#e(B $(7#f(B $(7#g(B $(7#h(B $(7#i(B $(7#j(B $(7#k(B $(7#l(B $(7#m(B $(7#n(B $(7#o(B ; are not specified
;;;2370 $(7#p(B $(7#q(B $(7#r(B $(7#s(B $(7#t(B $(7#u(B $(7#v(B $(7#w(B $(7#x(B $(7#y(B $(7#z(B $(7#{(B $(7#|(B $(7#}(B $(7#~(B // ; in Unicode.
;;;                                                     ; The character \x2351
;;;                                                     ; is not used in our
;;;                                                     ; implementation.
;;;     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
;;;2420 // $(7$!(B $(7$"(B $(7$#(B $(7$$(B $(7$%(B $(7$&(B $(7$'(B $(7$((B $(7$)(B $(7$*(B $(7$+(B $(7$,(B $(7$-(B $(7$.(B $(7$/(B ; Precomposed
;;;2430 $(7$0(B $(7$1(B $(7$2(B $(7$3(B $(7$4(B $(7$5(B $(7$6(B $(7$7(B $(7$8(B $(7$9(B $(7$:(B $(7$;(B $(7$<(B $(7$=(B $(7$>(B $(7$?(B ; consonants for
;;;2440 $(7$@(B $(7$A(B $(7$B(B $(7$C(B $(7$D(B $(7$E(B $(7$F(B $(7$G(B $(7$H(B $(7$I(B $(7$J(B $(7$K(B $(7$L(B $(7$M(B $(7$N(B $(7$O(B ; ordinary Tibetan.
;;;2450 $(7$P(B $(7$Q(B $(7$R(B $(7$S(B $(7$T(B $(7$U(B $(7$V(B $(7$W(B $(7$X(B $(7$Y(B $(7$Z(B $(7$[(B $(7$\(B $(7$](B $(7$^(B $(7$_(B ; They are decomposed
;;;2460 $(7$`(B $(7$a(B $(7$b(B $(7$c(B $(7$d(B $(7$e(B $(7$f(B $(7$g(B $(7$h(B $(7$i(B $(7$j(B $(7$k(B $(7$l(B $(7$m(B $(7$n(B $(7$o(B ; into base and 
;;;2470 $(7$p(B $(7$q(B $(7$r(B $(7$s(B $(7$t(B $(7$u(B $(7$v(B $(7$w(B $(7$x(B $(7$y(B $(7$z(B $(7${(B $(7$|(B $(7$}(B $(7$~(B // ; subjoined consonants
;;;                                                     ; when written on a
;;;     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F ; file in Tibetan
;;;2520 // $(7%!(B $(7%"(B $(7%#(B $(7%$(B $(7%%(B $(7%&(B $(7%'(B $(7%((B $(7%)(B $(7%*(B $(7%+(B $(7%,(B $(7%-(B $(7%.(B $(7%/(B ; coding system.
;;;2530 $(7%0(B $(7%1(B $(7%2(B $(7%3(B $(7%4(B $(7%5(B $(7%6(B $(7%7(B $(7%8(B $(7%9(B $(7%:(B $(7%;(B $(7%<(B $(7%=(B $(7%>(B $(7%?(B ;
;;;2540 $(7%@(B $(7%A(B $(7%B(B $(7%C(B $(7%D(B $(7%E(B $(7%F(B $(7%G(B $(7%H(B $(7%I(B $(7%J(B $(7%K(B $(7%L(B $(7%M(B $(7%N(B $(7%O(B ;
;;;2550 $(7%P(B $(7%Q(B $(7%R(B $(7%S(B $(7%T(B $(7%U(B $(7%V(B $(7%W(B $(7%X(B $(7%Y(B $(7%Z(B $(7%[(B $(7%\(B $(7%](B $(7%^(B $(7%_(B ;
;;;2560 $(7%`(B $(7%a(B $(7%b(B $(7%c(B $(7%d(B $(7%e(B $(7%f(B $(7%g(B $(7%h(B $(7%i(B $(7%j(B $(7%k(B $(7%l(B $(7%m(B $(7%n(B $(7%o(B ;
;;;2570 $(7%p(B $(7%q(B $(7%r(B $(7%s(B $(7%t(B $(7%u(B $(7%v(B $(7%w(B $(7%x(B $(7%y(B $(7%z(B $(7%{(B $(7%|(B $(7%}(B $(7%~(B // ;
;;;


(make-coding-system
 'tibetan-iso-8bit 2 ?Q
 "8-bit encoding for ASCII (MSB=0) and TIBETAN (MSB=1)"
 '(ascii tibetan nil nil
   nil nil)
 '((safe-charsets ascii tibetan)
   (post-read-conversion . tibetan-post-read-conversion)
   (pre-write-conversion . tibetan-pre-write-conversion)))

(define-coding-system-alias 'tibetan 'tibetan-iso-8bit)

(set-language-info-alist
 "Tibetan" '((charset tibetan tibetan-1-column)
	     (coding-system tibetan-iso-8bit)
	     (coding-priority iso-2022-7bit tibetan-iso-8bit)
	     (input-method . "tibetan-wylie")
	     (features tibet-util)
	     (documentation . t)
	     (sample-text .
"Tibetan (2$(7"70"](B1$(7"2$(8!;(B2$(7%P`"Q(B1$(7"2$(8!;(B) 2$(7#RP#SP#S(B1$(7!>"7(B2$(7$P`"Q(B1$(8!;(B2$(7"E0"S(B1$(7"G$(8!;$(7"7(B2$(7"20"[(B1$(8!;(B2$(7"D0"[(B1$(7"#"G!>(B2$(7"I0"]0"_(B1$(8!;(B2$(7"9`"Q(B1$(8!;(B2$(7"/0"S(B1$(8!;(B2$(7"5`"Q(B12$(7#2`#90"[(B1$(8!;(B2$(7"H`#A`"U0"c(B1$(7!>(B")))


;;;
;;; Definitions of conversion data.
;;;


;;; alists for tibetan char <-> transcription conversion
;;; longer transcription should come first
(defconst tibetan-consonant-transcription-alist
  '(("tsh" . "$(7";(B")
    ("dzh" . "$(7"=(B")
    ("kSH" . "$(7"J(B")
    ("kh" . "$(7""(B")
    ("gh" . "$(7"$(B")
    ("ng" . "$(7"%(B")
    ("ch" . "$(7"'(B")
    ("ny" . "$(7"*(B")
    ("TH" . "$(7",(B")
    ("DH" . "$(7".(B")
    ("th" . "$(7"1(B")
    ("dh" . "$(7"3(B")
    ("ph" . "$(7"6(B")
    ("bh" . "$(7"8(B")
    ("ts" . "$(7":(B")
    ("dz" . "$(7"<(B")
    ("zh" . "$(7"?(B")
    ("sh" . "$(7"E(B")
    ("SH" . "$(7"F(B")
    ("k" . "$(7"!(B")
    ("g" . "$(7"#(B")
    ("c" . "$(7"&(B")
    ("j" . "$(7"((B")
    ("T" . "$(7"+(B")
    ("D" . "$(7"-(B")
    ("N" . "$(7"/(B")
    ("t" . "$(7"0(B")
    ("d" . "$(7"2(B")
    ("n" . "$(7"4(B")
    ("p" . "$(7"5(B")
    ("b" . "$(7"7(B")
    ("m" . "$(7"9(B")
    ("w" . "$(7">(B")
    ("z" . "$(7"@(B")
    ("'" . "$(7"A(B")
    ("y" . "$(7"B(B")
    ("r" . "$(7"C(B")
    ("l" . "$(7"D(B")
    ("s" . "$(7"G(B")
    ("h" . "$(7"H(B")
    ("H" . "$(7"H(B")
    ("A" . "$(7"I(B")))


(defconst tibetan-vowel-transcription-alist
  '(("ai" . "$(7"\(B")
    ("au" . "$(7"^(B")
    ("ee" . "$(7"\(B")
    ("oo" . "$(7"^(B")
    ("a" . "$(7"Q(B")			; invisible vowel sign (\x2251)
    ("i" . "$(7"S(B")
    ("u" . "$(7"U(B")
    ("e" . "$(7"[(B")
    ("o" . "$(7"](B")
    ("E" . "$(7"\(B")
    ("O" . "$(7"^(B")
    ("I" . "$(7"a(B")
    ("M" . "$(7"_(B")
    ("~" . "$(7"c(B")			; not specified in Ext.wylie
    ("`" . "$(7"d(B")			; idem.
    ("," . "$(7"e(B")			; idem.
    ("v" . "$(7"g(B")			; idem.
    ("V" . "$(7"h(B")			; idem.
    ("x" . "$(7"i(B")			; idem.
    ("X" . "$(7"j(B")			; idem.
    ("q" . "$(7"k(B")			; idem.
    ("Q" . "$(7"l(B")			; idem.
    ("_o" . "$(7!g(B")			; idem.
    ("_O" . "$(7!e(B")			; idem.
    ("_/" . "$(7!I(B")                       ; idem.
    ))

(defconst tibetan-precomposed-transcription-alist
  '(("phyw" . "$(7$G(B")
    ("tshw" . "$(7$)(B")
    ("rtsw" . "$(7%.(B")
    ("khw" . "$(7$"(B")
    ("nyw" . "$(7$%(B")
    ("tsw" . "$(7$((B")
    ("zhw" . "$(7$*(B")
    ("shw" . "$(7$.(B")
    ("khy" . "$(7$A(B")
    ("phy" . "$(7$D(B")
    ("khr" . "$(7$Q(B")
    ("thr" . "$(7$T(B")
    ("phr" . "$(7$W(B")
    ("shr" . "$(7$Z(B")
    ("dzr" . "$(7$^(B")
    ("grw" . "$(7$_(B")
    ("rng" . "$(7%#(B")
    ("rny" . "$(7%%(B")
    ("rts" . "$(7%+(B")
    ("rdz" . "$(7%,(B")
    ("rgw" . "$(7%-(B")
    ("rky" . "$(7%0(B")
    ("rgy" . "$(7%1(B")
    ("rmy" . "$(7%2(B")
    ("lng" . "$(7%B(B")
    ("sng" . "$(7%R(B")
    ("sny" . "$(7%S(B")
    ("sts" . "$(7%Z(B")
    ("sky" . "$(7%`(B")
    ("sgy" . "$(7%a(B")
    ("spy" . "$(7%b(B")
    ("sby" . "$(7%c(B")
    ("smy" . "$(7%d(B")
    ("skr" . "$(7%p(B")
    ("sgr" . "$(7%q(B")
    ("snr" . "$(7%r(B")
    ("spr" . "$(7%s(B")
    ("sbr" . "$(7%t(B")
    ("smr" . "$(7%u(B")
    ("kw" . "$(7$!(B")
    ("gw" . "$(7$#(B")
    ("cw" . "$(7$$(B")
    ("tw" . "$(7$&(B")
    ("dw" . "$(7$'(B")
    ("zw" . "$(7$+(B")
    ("rw" . "$(7$,(B")
    ("lw" . "$(7$-(B")
    ("sw" . "$(7$/(B")
    ("hw" . "$(7$0(B")
    ("ky" . "$(7$@(B")
    ("gy" . "$(7$B(B")
    ("py" . "$(7$C(B")
    ("by" . "$(7$E(B")
    ("my" . "$(7$F(B")
    ("kr" . "$(7$P(B")
    ("gr" . "$(7$R(B")
    ("tr" . "$(7$S(B")
    ("dr" . "$(7$U(B")
    ("pr" . "$(7$V(B")
    ("brk" . "$(7"7%!(B")
    ("brg" . "$(7"7%"(B")
    ("brng" . "$(7"7%#(B")
    ("brj" . "$(7"7%$(B")
    ("brny" . "$(7"7%%(B")
    ("brt" . "$(7"7%&(B")
    ("brd" . "$(7"7%'(B")
    ("brn" . "$(7"7%((B")
    ("brts" . "$(7"7%+(B")
    ("brdz" . "$(7"7%,(B")
    ("brl" . "$(7"7$d(B")
    ("br" . "$(7$X(B")
    ("mr" . "$(7$Y(B")
    ("sr" . "$(7$[(B")
    ("hr" . "$(7$\(B")
    ("jr" . "$(7$](B")
    ("kl" . "$(7$`(B")
    ("gl" . "$(7$a(B")
    ("blt" . "$(7"7%E(B")
    ("bld" . "$(7"7%F(B")
    ("bl" . "$(7$b(B")
    ("zl" . "$(7$c(B")
    ("rl" . "$(7$d(B")
    ("sl" . "$(7$e(B")
    ("rk" . "$(7%!(B")
    ("rg" . "$(7%"(B")
    ("rj" . "$(7%$(B")
    ("rt" . "$(7%&(B")
    ("rd" . "$(7%'(B")
    ("rn" . "$(7%((B")
    ("rb" . "$(7%)(B")
    ("rm" . "$(7%*(B")
    ("lk" . "$(7%@(B")
    ("lg" . "$(7%A(B")
    ("lc" . "$(7%C(B")
    ("lj" . "$(7%D(B")
    ("lt" . "$(7%E(B")
    ("ld" . "$(7%F(B")
    ("ln" . "$(7!!(B")			; dummy \x2121
    ("lp" . "$(7%G(B")
    ("lb" . "$(7%H(B")
    ("lh" . "$(7%I(B")
    ("sk" . "$(7%P(B")
    ("sg" . "$(7%Q(B")
    ("st" . "$(7%T(B")
    ("sd" . "$(7%U(B")
    ("sn" . "$(7%V(B")
    ("sp" . "$(7%W(B")
    ("sb" . "$(7%X(B")
    ("sm" . "$(7%Y(B")))

(defconst tibetan-subjoined-transcription-alist
  '(("+k"  . "$(7#!(B")
    ("+kh" . "$(7#"(B")
    ("+g"  . "$(7##(B")
    ("+gh" . "$(7#$(B")
    ("+ng" . "$(7#%(B")
    ("+c"  . "$(7#&(B")
    ("+ch" . "$(7#'(B")
    ("+j"  . "$(7#((B")
    ("+ny"  . "$(7#*(B")
    ("+T"  . "$(7#+(B")
    ("+TH" . "$(7#,(B")
    ("+D"  . "$(7#-(B")
    ("+DH" . "$(7#.(B")
    ("+N"  . "$(7#/(B")
    ("+t"  . "$(7#0(B")
    ("+th" . "$(7#1(B")
    ("+d"  . "$(7#2(B")
    ("+dh" . "$(7#3(B")
    ("+n"  . "$(7#4(B")
    ("+p"  . "$(7#5(B")
    ("+ph" . "$(7#6(B")
    ("+b"  . "$(7#7(B")
    ("+bh" . "$(7#8(B")
    ("+m"  . "$(7#9(B")
    ("+ts" . "$(7#:(B")
    ("+tsh" . "$(7#;(B")
    ("+dz" . "$(7#<(B")
    ("+dzh" . "$(7#=(B")
    ("+w"  . "$(7#>(B")
    ("+zh" . "$(7#?(B")
    ("+z"  . "$(7#@(B")
    ("+'"  . "$(7#A(B")
    ("+y"  . "$(7#B(B")
    ("+r"  . "$(7#C(B")
    ("+l"  . "$(7#D(B")
    ("+sh" . "$(7#E(B")
    ("+SH" . "$(7#F(B")
    ("+s"  . "$(7#G(B")
    ("+h"  . "$(7#H(B")
    ("+A"  . "$(7#I(B")
    ("+kSH" . "$(7#J(B")
    ("R"   . "$(7#P(B")))

;;;
;;; alist for Tibetan base consonant <-> subjoined consonant conversion.
;;;
(defconst tibetan-base-to-subjoined-alist
  '(("$(7"!(B" . "$(7#!(B")
    ("$(7""(B" . "$(7#"(B")
    ("$(7"#(B" . "$(7##(B")
    ("$(7"$(B" . "$(7#$(B")
    ("$(7"%(B" . "$(7#%(B")
    ("$(7"&(B" . "$(7#&(B")
    ("$(7"'(B" . "$(7#'(B")
    ("$(7"((B" . "$(7#((B")
    ("$(7"*(B" . "$(7#*(B")
    ("$(7"+(B" . "$(7#+(B")
    ("$(7",(B" . "$(7#,(B")
    ("$(7"-(B" . "$(7#-(B")
    ("$(7".(B" . "$(7#.(B")
    ("$(7"/(B" . "$(7#/(B")
    ("$(7"0(B" . "$(7#0(B")
    ("$(7"1(B" . "$(7#1(B")
    ("$(7"2(B" . "$(7#2(B")
    ("$(7"3(B" . "$(7#3(B")
    ("$(7"4(B" . "$(7#4(B")
    ("$(7"5(B" . "$(7#5(B")
    ("$(7"6(B" . "$(7#6(B")
    ("$(7"7(B" . "$(7#7(B")
    ("$(7"8(B" . "$(7#8(B")
    ("$(7"9(B" . "$(7#9(B")
    ("$(7":(B" . "$(7#:(B")
    ("$(7";(B" . "$(7#;(B")
    ("$(7"<(B" . "$(7#<(B")
    ("$(7"=(B" . "$(7#=(B")
    ("$(7">(B" . "$(7#>(B")
    ("$(7"?(B" . "$(7#?(B")
    ("$(7"@(B" . "$(7#@(B")
    ("$(7"A(B" . "$(7#A(B")
    ("$(7"B(B" . "$(7#B(B")
    ("$(7"C(B" . "$(7#C(B")
    ("$(7"D(B" . "$(7#D(B")
    ("$(7"E(B" . "$(7#E(B")
    ("$(7"F(B" . "$(7#F(B")
    ("$(7"G(B" . "$(7#G(B")
    ("$(7"H(B" . "$(7#H(B")
    ("$(7"I(B" . "$(7#I(B")
    ("$(7"J(B" . "$(7#J(B")))

;;;
;;; alist for Tibetan consonantic components <-> precomposed glyph conversion.
;;; (includes some punctuation conversion rules)
;;;
(defconst tibetan-precomposition-rule-alist
  '(("$(7"6#B#>(B" . "$(7$G(B")
    ("$(7"##C#>(B" . "$(7$_(B")
    ("$(7";#>(B" . "$(7$)(B")
    ("$(7"C#:#>(B" . "$(7%.(B")
    ("$(7"C###>(B" . "$(7%-(B")
    ("$(7"C#!#B(B" . "$(7%0(B")
    ("$(7"C###B(B" . "$(7%1(B")
    ("$(7"C#9#B(B" . "$(7%2(B")
    ("$(7"G#!#B(B" . "$(7%`(B")
    ("$(7"G###B(B" . "$(7%a(B")
    ("$(7"G#5#B(B" . "$(7%b(B")
    ("$(7"G#7#B(B" . "$(7%c(B")
    ("$(7"G#9#B(B" . "$(7%d(B")
    ("$(7"G#!#C(B" . "$(7%p(B")
    ("$(7"G###C(B" . "$(7%q(B")
    ("$(7"G#4#C(B" . "$(7%r(B")
    ("$(7"G#5#C(B" . "$(7%s(B")
    ("$(7"G#7#C(B" . "$(7%t(B")
    ("$(7"G#9#C(B" . "$(7%u(B")
    ("$(7""#>(B" . "$(7$"(B")
    ("$(7"*#>(B" . "$(7$%(B")
    ("$(7":#>(B" . "$(7$((B")
    ("$(7"?#>(B" . "$(7$*(B")
    ("$(7"E#>(B" . "$(7$.(B")
    ("$(7""#B(B" . "$(7$A(B")
    ("$(7"6#B(B" . "$(7$D(B")
    ("$(7""#C(B" . "$(7$Q(B")
    ("$(7"1#C(B" . "$(7$T(B")
    ("$(7"6#C(B" . "$(7$W(B")
    ("$(7"E#C(B" . "$(7$Z(B")
    ("$(7"<#C(B" . "$(7$^(B")
    ("$(7"C#%(B" . "$(7%#(B")
    ("$(7"C#*(B" . "$(7%%(B")
    ("$(7"C#:(B" . "$(7%+(B")
    ("$(7"C#<(B" . "$(7%,(B")
    ("$(7"D#%(B" . "$(7%B(B")
    ("$(7"G#%(B" . "$(7%R(B")
    ("$(7"G#*(B" . "$(7%S(B")
    ("$(7"G#:(B" . "$(7%Z(B")
    ("$(7"!#>(B" . "$(7$!(B")
    ("$(7"##>(B" . "$(7$#(B")
    ("$(7"&#>(B" . "$(7$$(B")
    ("$(7"0#>(B" . "$(7$&(B")
    ("$(7"2#>(B" . "$(7$'(B")
    ("$(7"@#>(B" . "$(7$+(B")
    ("$(7"C#>(B" . "$(7$,(B")
    ("$(7"D#>(B" . "$(7$-(B")
    ("$(7"G#>(B" . "$(7$/(B")
    ("$(7"H#>(B" . "$(7$0(B")
    ("$(7"!#B(B" . "$(7$@(B")
    ("$(7"##B(B" . "$(7$B(B")
    ("$(7"5#B(B" . "$(7$C(B")
    ("$(7"7#B(B" . "$(7$E(B")
    ("$(7"9#B(B" . "$(7$F(B")
    ("$(7"!#C(B" . "$(7$P(B")
    ("$(7"##C(B" . "$(7$R(B")
    ("$(7"0#C(B" . "$(7$S(B")
    ("$(7"2#C(B" . "$(7$U(B")
    ("$(7"5#C(B" . "$(7$V(B")
    ("$(7"7#C(B" . "$(7$X(B")
    ("$(7"9#C(B" . "$(7$Y(B")
    ("$(7"G#C(B" . "$(7$[(B")
    ("$(7"H#C(B" . "$(7$\(B")
    ("$(7"(#C(B" . "$(7$](B")
    ("$(7"!#D(B" . "$(7$`(B")
    ("$(7"##D(B" . "$(7$a(B")
    ("$(7"7#D(B" . "$(7$b(B")
    ("$(7"@#D(B" . "$(7$c(B")
    ("$(7"C#D(B" . "$(7$d(B")
    ("$(7"G#D(B" . "$(7$e(B")
    ("$(7"C#!(B" . "$(7%!(B")
    ("$(7"C##(B" . "$(7%"(B")
    ("$(7"C#((B" . "$(7%$(B")
    ("$(7"C#0(B" . "$(7%&(B")
    ("$(7"C#2(B" . "$(7%'(B")
    ("$(7"C#4(B" . "$(7%((B")
    ("$(7"C#7(B" . "$(7%)(B")
    ("$(7"C#9(B" . "$(7%*(B")
    ("$(7"D#!(B" . "$(7%@(B")
    ("$(7"D##(B" . "$(7%A(B")
    ("$(7"D#&(B" . "$(7%C(B")
    ("$(7"D#((B" . "$(7%D(B")
    ("$(7"D#0(B" . "$(7%E(B")
    ("$(7"D#2(B" . "$(7%F(B")
    ("$(7"D#5(B" . "$(7%G(B")
    ("$(7"D#7(B" . "$(7%H(B")
    ("$(7"D#H(B" . "$(7%I(B")
    ("$(7"G#!(B" . "$(7%P(B")
    ("$(7"G##(B" . "$(7%Q(B")
    ("$(7"G#0(B" . "$(7%T(B")
    ("$(7"G#2(B" . "$(7%U(B")
    ("$(7"G#4(B" . "$(7%V(B")
    ("$(7"G#5(B" . "$(7%W(B")
    ("$(7"G#7(B" . "$(7%X(B")
    ("$(7"G#9(B" . "$(7%Y(B")
    ("$(7!=(B" . "$(8!=(B")			; 2 col <-> 1 col
    ("$(7!?(B" . "$(8!?(B")
    ("$(7!@(B" . "$(8!@(B")
    ("$(7!A(B" . "$(8!A(B")
    ("$(7"`(B" . "$(8"`(B")
    ("$(7!;(B" . "$(8!;(B")
    ("$(7!D(B" . "$(8!D(B")
    ("$(7!>(B $(7!>(B" . "2$(7!>P(B P$(7!>(B1")			; Yes this is dirty. But ...
    ("$(7!4!5!5(B" . "2$(7#RP#SP#SP#S(B1")
    ("$(7!4!5(B" . "2$(7#RP#SP#S(B1")
    ("$(7!6(B" . "2$(7#RP#S_!I(B1")
    ("$(7!4(B"   . "2$(7#RP#S(B1")))

(defvar tibetan-regexp
  (let ((l (append tibetan-consonant-transcription-alist
		   tibetan-vowel-transcription-alist
		   tibetan-subjoined-transcription-alist))
	temp)
    (setq temp "\\(")
    (setq temp (concat temp (car (car l))))
    (setq l (cdr l))
    (while l
      (setq temp (concat temp "\\|" (car (car l))))
      (setq l (cdr l)))
    (concat temp "\\)$"))
  "Regexp string to match a romanized Tibetan character component, i.e.,
base and subjoined consonant, vowel and vowel modifier. The result of matching
is to be used for indexing alists at conversion from a roman transcription to
the corresponding Tibetan character.")

(defvar tibetan-precomposed-regexp
  (let ((l tibetan-precomposed-transcription-alist)
	temp)
    (setq temp "^\\(")
    (setq temp
	  (concat temp (car (car l))))
    (setq l (cdr l))
    (while l
      (setq temp
	    (concat temp "\\|" (car (car l))))
      (setq l (cdr l)))
    (concat temp "\\)"))
  "Regexp string to match a romanized Tibetan complex consonant.
The result of matching is to be used for indexing alists when the input key
from an input method is converted to the corresponding precomposed glyph.")

(defvar tibetan-precomposition-rule-regexp
  (let ((l tibetan-precomposition-rule-alist)
	temp)
    (setq temp "\\(")
    (setq temp (concat temp (car (car l))))
    (setq l (cdr l))
    (while l
      (setq temp (concat temp "\\|" (car (car l))))
      (setq l (cdr l)))
    (concat temp "\\)"))
  "Regexp string to match a sequence of Tibetan consonantic components, i.e.,
one base consonant and one or more subjoined consonants.
The result of matching is to be used for indexing alist when the component
sequence is converted to the corresponding precomposed glyph.
This also matches some punctuation characters which need conversion.")

(defvar tibetan-decomposed nil)
(defvar tibetan-decomposed-temp nil)

;;; language/tibetan.el ends here
