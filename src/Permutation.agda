------------------------------------------------------------
-- Nominal Sets
--
-- Permutations on a setoid form the Symmetry Group.
------------------------------------------------------------
module Permutation where

open import Level
open import Data.Product hiding (map)
open import Algebra hiding (Inverse)
open import Function
open import Relation.Binary
open import Relation.Binary.PropositionalEquality using (_≡_;≢-sym)
open import Relation.Nullary
import Relation.Binary.Reasoning.Setoid as ≈-Reasoning
open import Function.Construct.Composition renaming (inverse to _∘ₚ_)
open import Function.Construct.Identity renaming (inverse to idₚ)
open import Function.Construct.Symmetry renaming (inverse to _⁻¹)

variable
  ℓ ℓ' : Level

module Symmetry-Group (A-setoid : Setoid ℓ ℓ') where
  open IsEquivalence
  open Inverse
  open Setoid hiding (_≈_)
  open ≈-Reasoning A-setoid

  _≈_ = Setoid._≈_ A-setoid
  isEq = isEquivalence A-setoid

  Perm : Set _
  Perm = Inverse A-setoid A-setoid

  _≈ₚ_ : Rel Perm _
  F ≈ₚ G = (x : Carrier A-setoid) → f F x ≈ f G x

  cong-⁻¹ : Congruent₁ _≈ₚ_ _⁻¹
  cong-⁻¹ {F} {G} F≈G x = begin
            f⁻¹ F x
              ≈⟨ cong₂ F (sym isEq (proj₁ (inverse G) x)) ⟩
            (f⁻¹ F ∘ (f G ∘ f⁻¹ G)) x
              ≈⟨ cong₂ F (sym isEq (F≈G (f⁻¹ G x))) ⟩
            (f⁻¹ F ∘ (f F ∘ f⁻¹ G)) x
              ≈⟨ proj₂ (inverse F) (f⁻¹ G x) ⟩
            f⁻¹ G x
              ∎

  cong₂-≈-∘ : Congruent₂ _≈ₚ_ _∘ₚ_
  cong₂-≈-∘ {F} {G} {H} {K} F≈G  H≈K x = begin
    f H (f F x)  ≈⟨ cong₁ H (F≈G x) ⟩
    f H (f G x)  ≈⟨ H≈K (f G x) ⟩
    f K (f G x) ∎

  Sym-A : Group (ℓ ⊔ ℓ') (ℓ ⊔ ℓ')
  Sym-A = record
            { Carrier = Perm
            ; _≈_ = _≈ₚ_
            ; _∙_ = _∘ₚ_
            ; ε = idₚ A-setoid
            ; _⁻¹ = _⁻¹
            ; isGroup = record {
                isMonoid = record {
                  isSemigroup = record {
                  isMagma = record {
                    isEquivalence = record {
                        refl = λ {F} x → cong₁ F (refl isEq)
                      ; sym = λ F≈G → sym isEq ∘ F≈G
                      ; trans = λ F≈G G≈H x → trans isEq (F≈G x) (G≈H x)
                    } ;
                    ∙-cong = λ {F} {G} {H} {K} → cong₂-≈-∘ {F} {G} {H} {K}
                  }
                  ; assoc = λ _ _ _ _ → refl isEq
                  }
                ; identity = (λ _ _ → refl isEq) , (λ _ _ → refl isEq)
                }
              ; inverse = proj₁ ∘ inverse , proj₂ ∘ inverse
              ; ⁻¹-cong = λ {F} {G} → cong-⁻¹ {F} {G}
              }
            }

module Perm (A-setoid : DecSetoid ℓ ℓ') where
  open DecSetoid A-setoid
  open module A-Sym = Symmetry-Group setoid hiding (_≈_)
  open import Data.Bool hiding (_≟_)
  open import Data.Empty

  open Inverse

  perm-injective : (π : Perm) → Injective _≈_ _≈_ (f π)
  perm-injective π {c} {d} eq = begin
    c
    ≈⟨ sym (Inverse.inverseʳ π c) ⟩
    f⁻¹ π (f π c)
    ≈⟨ cong₂ π eq ⟩
    f⁻¹ π (f π d)
    ≈⟨ Inverse.inverseʳ π d ⟩
    d ∎
    where open ≈-Reasoning setoid

  perm-injective' : (π : Perm) → Injective _≉_ _≉_ (f π)
  perm-injective' π {c} {d} neq c=d = ⊥-elim (neq (cong₁ π c=d))

  transp : (a b c : Carrier) → Carrier
  transp a b c with does (c ≟ a)
  ... | true = b
  ... | false with does (c ≟ b)
  ... | true = a
  ... | false = c

  transp-eq₁ : ∀ {a} b {c} → c ≈ a → transp a b c ≡ b
  transp-eq₁ {a} b {c} c=a with c ≟ a
  ... | yes p = _≡_.refl
  ... | no c≠a = ⊥-elim (c≠a c=a)

  transp-eq₂ : ∀ {a b c} → c ≉ a → c ≈ b → transp a b c ≡ a
  transp-eq₂ {a} {b} {c} c≠a c=b with c ≟ a
  ... | yes c=a = ⊥-elim (c≠a c=a)
  ... | no c≠a with c ≟ b
  ... | yes c=b = _≡_.refl
  ... | no c≠b = ⊥-elim (c≠b c=b)

  transp-eq₃ : ∀ {a b c} → c ≉ a → c ≉ b → transp a b c ≡ c
  transp-eq₃ {a} {b} {c} c≠a c≠b with c ≟ a
  ... | yes c=a = ⊥-elim (c≠a c=a)
  ... | no c≠a with c ≟ b
  ... | no _ = _≡_.refl
  ... | yes c=b = ⊥-elim (c≠b c=b)

  ≉-sym : ∀ {a b} → a ≉ b → b ≉ a
  ≉-sym a≠b b=a = ⊥-elim (a≠b (sym b=a))

  ≉-resp-≈₁ : ∀ {a b c} → a ≈ b → b ≉ c → a ≉ c
  ≉-resp-≈₁ a=b b≠c a=c = ⊥-elim (b≠c (trans (sym a=b) a=c))

  ≉-resp-≈₂ : ∀ {a b c} → b ≈ c → a ≉ b → a ≉ c
  ≉-resp-≈₂ b=c a≠b a=c = ⊥-elim (a≠b (trans a=c (sym b=c)))

  transp-induction : ∀ {ℓP} (P : Carrier → Set ℓP) →
                     ∀ a b c →
                     (c ≈ a → P b) →
                     (c ≉ a → c ≈ b → P a) →
                     (c ≉ a → c ≉ b → P c) →
                     P (transp a b c)
  transp-induction P a b c P-eq1 P-eq2 P-eq3 with a ≟ c
  ... | yes a=c rewrite transp-eq₁ b (sym a=c) = P-eq1 (sym a=c)
  ... | no a≠c with b ≟ c
  ... | yes b=c rewrite transp-eq₂ (≉-sym a≠c) (sym b=c) = P-eq2 (≉-sym a≠c) (sym b=c)
  ... | no b≠c rewrite transp-eq₃ (≉-sym a≠c) (≉-sym b≠c) = P-eq3 (≉-sym a≠c) (≉-sym b≠c)

  transp-id : ∀ a b c → a ≈ b → transp a b c ≈ c
  transp-id a b c a=b = transp-induction (_≈ c) a b c
    (λ c=a → trans (sym a=b) (sym c=a))
    (λ _ c=b → trans a=b (sym c=b))
    (λ _ _ → refl)

  transp-inv₁ : ∀ a b c → transp a b c ≈ a → b ≈ c
  transp-inv₁ a b c = transp-induction (λ x → x ≈ a → b ≈ c) a b c
     (λ c=a b=a → trans b=a (sym c=a))
     (λ _ b=c _ → sym b=c)
     (λ c≠a _ c=a → ⊥-elim (c≠a c=a))

  transp-inv₂ : ∀ a b c → transp a b c ≉ a → transp a b c ≈ b → a ≈ c
  transp-inv₂ a b c = transp-induction (λ x → x ≉ a → x ≈ b → a ≈ c) a b c
    (λ c=a _ _ → sym c=a)
    (λ _ _ a≠a _ → ⊥-elim (a≠a refl))
    (λ _ c≠b _ c=b → ⊥-elim (c≠b c=b))

  transp-inv₂' : ∀ a b c → transp a b c ≈ b → a ≈ c
  transp-inv₂' a b c = transp-induction (λ x → x ≈ b → a ≈ c) a b c
    (λ a=c _ → sym a=c)
    (λ c≠a c=b a=b → trans a=b (sym c=b))
    (λ c≠a c≠b c=b → ⊥-elim (c≠b c=b))

  transp-inv₃ : ∀ a b c → transp a b c ≉ a → transp a b c ≉ b → transp a b c ≈ c
  transp-inv₃ a b c = transp-induction (λ x → x ≉ a → x ≉ b → x ≈ c) a b c
    (λ _ _ b≠b → ⊥-elim (b≠b refl))
    (λ _ _ a≠a → ⊥-elim (a≠a refl))
    (λ _ _ _ _ → refl)

  transp-comm : ∀ a b c → transp a b c ≈ transp b a c
  transp-comm a b c with a ≟ b
  ... | yes a=b = trans (transp-id a b c a=b) (sym (transp-id b a c (sym a=b)))
  ... | no a≠b = transp-induction (transp a b c ≈_) b a c
      (λ c=b → reflexive (transp-eq₂ (≉-sym (≉-resp-≈₂ (sym c=b) a≠b)) c=b))
      (λ c≠b c=a → reflexive (transp-eq₁ b c=a))
      (λ c≠b c≠a → reflexive (transp-eq₃ c≠a c≠b))

  transp-eq₁' : ∀ a {b} {c} → c ≈ b → transp a b c ≈ a
  transp-eq₁' a {b} {c} c=b = trans (transp-comm a b c)
                                    (reflexive (transp-eq₁ a c=b))

  transp-involutive : ∀ a b → Involutive _≈_ (transp a b)
  transp-involutive a b c = transp-induction (_≈ c) a b (transp a b c)
    (transp-inv₁ a b c)
    (transp-inv₂ a b c)
    (transp-inv₃ a b c)

  transp-respects-≈ : ∀ a b → (transp a b) Preserves _≈_ ⟶ _≈_
  transp-respects-≈ a b {c} {d} c≈d = transp-induction (transp a b c ≈_) a b d
    (λ d=a → reflexive (transp-eq₁ b (trans c≈d d=a)))
    (λ d≠a d=b → reflexive (transp-eq₂ (≉-resp-≈₁ c≈d d≠a) (trans c≈d d=b)))
    (λ d≠a d≠b → trans (reflexive (transp-eq₃ ((≉-resp-≈₁ c≈d d≠a)) ((≉-resp-≈₁ c≈d d≠b)))) c≈d)


  data FinPerm : Set ℓ where
    Id : FinPerm
    Comp : (fp fq : FinPerm) → FinPerm
    Swap : (a b : Carrier) → FinPerm

  open import Data.List
  open import Data.List.Membership.DecSetoid A-setoid

  ⟦_⟧ : FinPerm → Perm
  ⟦ Id ⟧ = idₚ setoid
  ⟦ Comp p q ⟧ = ⟦ p ⟧ ∘ₚ ⟦ q ⟧
  ⟦ Swap a b ⟧ = record
    { f = transp a b
    ; f⁻¹ = transp a b
    ; cong₁ = transp-respects-≈ a b
    ; cong₂ = transp-respects-≈ a b
    ; inverse = transp-involutive a b , transp-involutive a b
    }

  transp-injective : ∀ a b → Injective _≈_ _≈_  (transp a b)
  transp-injective a b = perm-injective ⟦ Swap a b ⟧

  transp-distributive-perm : ∀ (π : Perm) a b c →
    transp (f π a) (f π b) (f π c) ≈ f π ((transp a b) c)
  transp-distributive-perm π a b c = transp-induction (λ x → x ≈ (f π ∘ transp a b) c) (f π a) (f π b) (f π c)
    (λ πc=πa → cong₁ π (sym (reflexive (transp-eq₁ b (perm-injective π πc=πa)))))
    (λ πc≠πa πc=πb → cong₁ π (sym (reflexive (transp-eq₂ (perm-injective' π πc≠πa) (perm-injective π πc=πb)))))
    (λ πc≠πa πc≠πb → cong₁ π (sym (reflexive (transp-eq₃ (perm-injective' π πc≠πa) (perm-injective' π πc≠πb)))))

  transp-distributive : ∀ a b c d e →
    transp a b (transp c d e) ≈ transp (transp a b c) (transp a b d) (transp a b e)
  transp-distributive a b c d e = sym (transp-distributive-perm ⟦ Swap a b ⟧ c d e)

  transp-cancel' : ∀ a b c d → d ≉ b → d ≉ c → transp c b (transp a c d) ≈ transp a b d
  transp-cancel' a b c d d≠b d≠c = transp-induction (λ x → transp c b (transp a c d) ≈ x) a b d
    (λ d=a → trans (transp-respects-≈ c b (reflexive (transp-eq₁ c d=a))) (reflexive (transp-eq₁ b refl)))
    (λ d≠a d=b → ⊥-elim (d≠b d=b))
    (λ d≠a d≠b → trans (transp-respects-≈ c b (reflexive (transp-eq₃ d≠a d≠c)))
                       (reflexive (transp-eq₃ d≠c d≠b)))

  transp-cancel : ∀ a b c e → a ≉ b → a ≉ c → b ≉ c →
    transp a b e ≈ ((transp a c) ∘ (transp b c) ∘ (transp a c)) e
  transp-cancel a b c e a≠b a≠c b≠c = transp-induction
        (λ x → x ≈ ((transp a c) ∘ (transp b c) ∘ (transp a c)) e) a b e
        (sym ∘ eq₁)
        (λ e≠a → sym ∘ (eq₂ e≠a))
        (λ e≠a → sym ∘ (eq₃ e≠a))
        where
        open ≈-Reasoning setoid
        eq-ctx : ∀ {x y} → x ≈ y → transp a c (transp b c x) ≈ transp a c (transp b c y)
        eq-ctx x=y = transp-respects-≈ a c (transp-respects-≈ b c x=y)
        eq₁ : e ≈ a → transp a c (transp b c (transp a c e)) ≈ b
        eq₁ e=a = begin
          transp a c (transp b c (transp a c e))
          ≈⟨ eq-ctx (reflexive (transp-eq₁ c e=a)) ⟩
          transp a c (transp b c c)
          ≈⟨ transp-respects-≈ a c (transp-eq₁' b refl) ⟩
          transp a c b
          ≈⟨ reflexive (transp-eq₃ (≉-sym a≠b) b≠c) ⟩
          b ∎
        eq₂ : e ≉ a → e ≈ b → transp a c (transp b c (transp a c e)) ≈ a
        eq₂ e≠a e=b = begin
          transp a c (transp b c (transp a c e))
          ≈⟨ eq-ctx (reflexive (transp-eq₃ e≠a (≉-resp-≈₁ e=b b≠c))) ⟩
          transp a c (transp b c e)
          ≈⟨ transp-respects-≈ a c (reflexive (transp-eq₁ c e=b)) ⟩
          transp a c c
          ≈⟨ transp-eq₁' a refl ⟩
          a ∎
        eq₃ : e ≉ a → e ≉ b → transp a c (transp b c (transp a c e)) ≈ e
        eq₃ e≠a e≠b with e ≟ c
        ... | yes e=c = begin
          transp a c (transp b c (transp a c e))
          ≈⟨ eq-ctx (transp-eq₁' a e=c) ⟩
          transp a c (transp b c a)
          ≈⟨ transp-respects-≈ a c (reflexive (transp-eq₃ a≠b a≠c)) ⟩
          transp a c a
          ≈⟨ reflexive (transp-eq₁ c refl) ⟩
          c
          ≈⟨ sym e=c ⟩
          e ∎

        ... | no e≠c = begin
          transp a c (transp b c (transp a c e))
          ≈⟨ eq-ctx (reflexive (transp-eq₃ e≠a e≠c)) ⟩
          transp a c (transp b c e)
          ≈⟨ transp-respects-≈ a c (reflexive (transp-eq₃ e≠b e≠c)) ⟩
          transp a c e
          ≈⟨ reflexive (transp-eq₃ e≠a e≠c) ⟩
          e ∎



  _⁻¹ᵖ : (p : FinPerm) → ∃ (λ q → (⟦ p ⟧ ⁻¹) ≈ₚ ⟦ q ⟧)
  Id ⁻¹ᵖ = Id , λ _ → refl
  Comp p q ⁻¹ᵖ with  p ⁻¹ᵖ | q ⁻¹ᵖ
  ... | p' , eqp | q' , eqq = Comp q' p' , λ x →
      begin
      f⁻¹ ⟦ p ⟧ (f⁻¹ ⟦ q ⟧ x)
      ≈⟨ cong₂ ⟦ p ⟧ (eqq x) ⟩
      f⁻¹ ⟦ p ⟧ (f ⟦ q' ⟧ x)
      ≈⟨ eqp (f ⟦ q' ⟧ x) ⟩
      (f ⟦ p' ⟧ (f ⟦ q' ⟧ x)) ∎
    where open ≈-Reasoning setoid
  Swap a b ⁻¹ᵖ = (Swap a b) , (λ x → refl)

  PERM : Set (ℓ ⊔ ℓ')
  PERM = Σ[ p ∈ Perm ] (Σ[ q ∈ FinPerm ] ( p ≈ₚ ⟦ q ⟧))

  ID : PERM
  ID = idₚ setoid , Id , λ _ → refl

  _⁻¹P : Op₁ PERM
  (p , code , eq) ⁻¹P = p ⁻¹
                    , proj₁ (code ⁻¹ᵖ)
                    , λ x → begin
      f⁻¹ p x
    ≈⟨ cong-⁻¹ {p} {⟦ code ⟧} eq x ⟩
      f⁻¹ ⟦ code ⟧ x
    ≈⟨ proj₂ (code ⁻¹ᵖ) x ⟩
      f ⟦ proj₁ (code ⁻¹ᵖ) ⟧ x ∎
    where open ≈-Reasoning setoid

  _∘P_ : Op₂ PERM
  (p , code , eq) ∘P (q , code' , eq') =
      p ∘ₚ q
    , Comp code code'
    , λ x → trans (cong₁ q (eq x)) (eq' (f ⟦ code ⟧ x))

  Perm-A : Group (ℓ ⊔ ℓ') (ℓ ⊔ ℓ')
  Perm-A = record
            { Carrier = PERM
            ; _≈_ = _≈ₚ_ on proj₁
            ; _∙_ = _∘P_
            ; ε = ID
            ; _⁻¹ = _⁻¹P
            ; isGroup = record {
                isMonoid = record {
                  isSemigroup = record {
                  isMagma = record {
                    isEquivalence = record {
                        refl = λ x → refl
                      ; sym = λ x x₁ → sym (x x₁)
                      ; trans = λ x x₁ x₂ → trans (x x₂) (x₁ x₂)
                    } ;
                    ∙-cong = λ {f} {g} {h} {k} f=g h=k x →
                      Group.∙-cong Sym-A {proj₁ f} {proj₁ g} {proj₁ h} {proj₁ k} f=g h=k x
                  }
                  ; assoc = λ x y z x₁ → refl
                  }
                ; identity = (λ x x₁ → refl) , λ x x₁ → refl
                }
              ; inverse = (λ f x → Inverse.inverseˡ (proj₁ f) x ) , λ f x → Inverse.inverseʳ (proj₁ f) x
              ; ⁻¹-cong = λ {f} {g} f=g x → Group.⁻¹-cong Sym-A {proj₁ f} {proj₁ g} f=g x
              }
            }
