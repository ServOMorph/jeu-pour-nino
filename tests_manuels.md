# Tests manuels — Flux Phase 2 + Menu titre/dev

Statut au 2026-07-12. Pré-requis : lancer via `run_game.py`, manette PowerA connectée.

Sections 1 à 4, 6, 7, 8 et 9 validées OK — retirées de ce fichier.

## 5. Maîtrise d'une recette non-starter

5.1. **VALIDÉ (2026-07-12).** `RecipeCatalog.discover_by_trigger()` branché sur `level.gd._on_boss_died()` : à la victoire du Veilleur des Cendres, les 3 recettes `discovery: "Victoire Gardien du Voile"` (`lame_spectrale`, `anneau_revenants`, `elixir_resurgence`) sont découvertes et le Grimoire affiche la maîtrise correctement, testé manuellement en jeu.
5.2. **Portée limitée, pas une erreur :** seul le trigger boss est branché. Les triggers `Salle B1-B4` et `Porteur (...)` (17 recettes restantes) nécessitent des systèmes absents du jeu actuel — biomes multiples (phases 4, 7a-c) et ennemis porteurs (phase 8). À traiter quand ces phases seront développées.

**Statut : validé — plus aucun blocage sur ce point.**

---

**Validation Phase 2 — COMPLÈTE (2026-07-12)**

Toutes les sections 1-9 testées manuellement sans crash ni anomalie bloquante. Aucun blocage restant.
