# Tests manuels — Flux Phase 2 + Menu titre/dev

Statut au 2026-07-12. Pré-requis : lancer via `run_game.py`, manette PowerA connectée.

Sections 1 à 4, 6, 7, 8 et 9 validées OK — retirées de ce fichier.

## 5. Maîtrise d'une recette non-starter — BLOQUÉ

5.1. Constat : le Grimoire n'affiche que les 7 recettes `starter`, toutes déjà maîtrisées. Aucune recette `Salle B1/B2/B3/B4`, `Porteur` ou `Victoire Gardien` n'apparaît.
5.2. Cause : `MetaState.discover_recipe()` (`game/scripts/meta_state.gd:26`) n'est appelé nulle part en jeu — seulement dans les tests GUT (`test_meta_state.gd`, `test_save_manager.gd`). Aucun trigger gameplay (salle, drop de porteur, victoire boss) ne l'appelle.
5.3. Conséquence : impossible de tester manuellement la maîtrise d'une recette non-starter tant que ce mécanisme n'est pas branché.

**Statut : bloqué — voir `_contexte/signals.md`.**

---

**Validation Phase 2 — COMPLÈTE (2026-07-12)**

Toutes les sections 1-4, 6-9 testées manuellement sans crash ni anomalie bloquante. Le seul blocage restant est la découverte de recettes non-starter (§5) — voir ci-dessus.
