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

  data FinPerm : Set ℓ where
    Id : FinPerm
    Comp : (fp fq : FinPerm) → FinPerm
    Swap : (a b : Carrier) → FinPerm

  open module A-Sym = Symmetry-Group setoid hiding (_≈_)
  open Dec
  open import Data.Bool hiding (_≟_)
  open import Data.Empty

  transp : (a b c : Carrier) → Carrier
  transp a b c with c ≟ a
  ... | yes _ = b
  ... | no _ with c ≟ b
  ... | yes _ = a
  ... | no _ = c

  transp-eq₁ : ∀ a b c → c ≈ a → transp a b c ≡ b
  transp-eq₁ a b c c=a with c ≟ a
  ... | yes p = _≡_.refl
  ... | no c≠a = ⊥-elim (c≠a c=a)

  transp-eq₂ : ∀ a b c → ¬ c ≈ a → c ≈ b → transp a b c ≡ a
  transp-eq₂ a b c c≠a c=b with c ≟ a
  ... | yes c=a = ⊥-elim (c≠a c=a)
  ... | no c≠a with c ≟ b
  ... | yes c=b = _≡_.refl
  ... | no c≠b = ⊥-elim (c≠b c=b)

  transp-eq₃ : ∀ a b c → ¬ c ≈ a → ¬ c ≈ b → transp a b c ≡ c
  transp-eq₃ a b c c≠a c≠b with c ≟ a
  ... | yes c=a = ⊥-elim (c≠a c=a)
  ... | no c≠a with c ≟ b
  ... | no _ = _≡_.refl
  ... | yes c=b = ⊥-elim (c≠b c=b)

  ≉-sym : ∀ {a b} → ¬ a ≈ b → ¬ b ≈ a
  ≉-sym a≠b b=a = ⊥-elim (a≠b (sym b=a))

  ≉-resp-≈₁ : ∀ {a b c} → a ≈ b → ¬ b ≈ c → ¬ a ≈ c
  ≉-resp-≈₁ a=b b≠c a=c = ⊥-elim (b≠c (trans (sym a=b) a=c))

  ≉-resp-≈₂ : ∀ {a b c} → b ≈ c → ¬ a ≈ b → ¬ a ≈ c
  ≉-resp-≈₂ b=c a≠b a=c = ⊥-elim (a≠b (trans a=c (sym b=c)))

  transp-induction : ∀ {ℓP} (P : Carrier → Set ℓP) →
                     ∀ a b c →
                     (c ≈ a → P b) →
                     (¬ c ≈ a → c ≈ b → P a) →
                     (¬ c ≈ a → ¬ c ≈ b → P c) →
                     P (transp a b c)
  transp-induction P a b c P-eq1 P-eq2 P-eq3 with a ≟ c
  ... | yes a=c rewrite transp-eq₁ a b c (sym a=c) = P-eq1 (sym a=c)
  ... | no a≠c with b ≟ c
  ... | yes b=c rewrite transp-eq₂ a b c (≉-sym a≠c) (sym b=c) = P-eq2 (≉-sym a≠c) (sym b=c)
  ... | no b≠c rewrite transp-eq₃ a b c (≉-sym a≠c) (≉-sym b≠c) = P-eq3 (≉-sym a≠c) (≉-sym b≠c)

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

  transp-inv₂ : ∀ a b c → ¬ transp a b c ≈ a → transp a b c ≈ b → a ≈ c
  transp-inv₂ a b c = transp-induction (λ x → ¬ (x ≈ a) → x ≈ b → a ≈ c) a b c
    (λ c=a _ _ → sym c=a)
    (λ _ _ a≠a _ → ⊥-elim (a≠a refl))
    (λ _ c≠b _ c=b → ⊥-elim (c≠b c=b))

  transp-inv₂' : ∀ a b c → transp a b c ≈ b → a ≈ c
  transp-inv₂' a b c = transp-induction (λ x → x ≈ b → a ≈ c) a b c
    (λ a=c _ → sym a=c)
    (λ c≠a c=b a=b → trans a=b (sym c=b))
    (λ c≠a c≠b c=b → ⊥-elim (c≠b c=b))

  transp-inv₃ : ∀ a b c → ¬ transp a b c ≈ a → ¬ transp a b c ≈ b → transp a b c ≈ c
  transp-inv₃ a b c = transp-induction (λ x → ¬ (x ≈ a) → ¬ x ≈ b → x ≈ c) a b c
    (λ _ _ b≠b → ⊥-elim (b≠b refl))
    (λ _ _ a≠a → ⊥-elim (a≠a refl))
    (λ _ _ _ _ → refl)

  transp-comm : ∀ a b c → transp a b c ≈ transp b a c
  transp-comm a b c with a ≟ b
  ... | yes a=b = trans (transp-id a b c a=b) (sym (transp-id b a c (sym a=b)))
  ... | no a≠b = transp-induction (transp a b c ≈_) b a c
      (λ c=b → reflexive (transp-eq₂ a b c (≉-sym (≉-resp-≈₂ (sym c=b) a≠b)) c=b))
      (λ c≠b c=a → reflexive (transp-eq₁ a b c c=a))
      (λ c≠b c≠a → reflexive (transp-eq₃ a b c c≠a c≠b))

  transp-involutive : ∀ a b → Involutive _≈_ (transp a b)
  transp-involutive a b c = transp-induction (_≈ c) a b (transp a b c)
    (transp-inv₁ a b c)
    (transp-inv₂ a b c)
    (transp-inv₃ a b c)

  transp-respects-≈ : ∀ a b {c} {d} → c ≈ d → transp a b c ≈ transp a b d
  transp-respects-≈ a b {c} {d} c≈d = transp-induction (transp a b c ≈_) a b d
    (λ d=a → reflexive (transp-eq₁ a b c (trans c≈d d=a)))
    (λ d≠a d=b → reflexive (transp-eq₂ a b c (≉-resp-≈₁ c≈d d≠a) (trans c≈d d=b)))
    (λ d≠a d≠b → trans (reflexive (transp-eq₃ a b c ((≉-resp-≈₁ c≈d d≠a)) ((≉-resp-≈₁ c≈d d≠b)))) c≈d)

  transp-injective : ∀ a b → Injective _≈_ _≈_  (transp a b)
  transp-injective a b {c} {d} eq = begin
    c
    ≈⟨ sym (transp-involutive a b c) ⟩
    transp a b (transp a b c)
    ≈⟨ transp-respects-≈ a b eq ⟩
    transp a b (transp a b d)
    ≈⟨ transp-involutive a b d ⟩
    d ∎
    where open ≈-Reasoning setoid

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
