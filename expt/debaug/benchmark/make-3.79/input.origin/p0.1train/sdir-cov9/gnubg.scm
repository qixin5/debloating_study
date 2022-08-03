;;; 
;;; gnubg.scm
;;; 
;;; by Gary Wong <gtw@gnu.org>, 2000
;;; 
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of version 2 of the GNU General Public License as
;;; published by the Free Software Foundation.
;;; 
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;; 
;;; You should have received a copy of the GNU General Public License
;;; along with this program; if not, write to the Free Software
;;; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;;; 
;;; $Id: gnubg.scm,v 1.2 2000/10/31 15:29:19 gtw Exp $
;;; 

;;;
;;; GNU Backgammon Scheme definitions
;;;

;;; A _board_ is a pair of vectors each containing 25 integers; the cdr
;;; represents the number of chequers for the player on roll (moving from
;;; 24 -> 0, where 24 is the bar and 23 to 0 are the 24 to 1 points).
;;; The car represents the same for the opponent.

;; It's not worth defining a Guile interface to the C SwapSides() when
;; we can do the same thing more easily in Scheme.
(define (swap-sides b)
  (cons (cdr b) (car b)))
