def Nat : Type ≔ data [ zero. | suc. (n : Nat) ]

def plus : Nat → Nat → Nat ≔ m n ↦ match m [
| zero. ↦ n
| suc. m ↦ suc. (plus m n)]

def one : Nat ≔ suc. zero.

def two : Nat ≔ plus one one

def three : Nat ≔ plus one two

def Lambda : Type ≔ data [
| app. (f x : Lambda)
| lam. (abs : Lambda → Lambda) ]

def I : Lambda ≔ lam. (x ↦ x)

def K : Lambda ≔ lam. (x ↦ lam. (y ↦ x))

def S : Lambda
  ≔ lam. (x ↦ lam. (y ↦ lam. (z ↦ app. (app. x y) (app. x z))))

def ω : Lambda ≔ lam. (x ↦ app. x x)

def Ω : Lambda ≔ app. ω ω

def reduce (x : Lambda) : Lambda ≔ match x [
| app. f y ↦ match f [ app. _ _ ↦ x | lam. f' ↦ f' y ]
| lam. f ↦ x]

def norm (x : Lambda) : Lambda ≔ match x [
| app. f x′ ↦ ¿ʔ
| lam. abs ↦ ¿ʔ]
