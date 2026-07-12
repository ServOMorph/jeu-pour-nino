# Tests manuels — Flux Phase 2 + Menu titre/dev

Statut au 2026-07-12. Pré-requis : lancer via `run_game.py`, manette PowerA connectée.

Sections 1 à 4, 6, 7, 8 et 9 validées OK — retirées de ce fichier.

## 5. Maîtrise d'une recette non-starter

5.1. **VALIDÉ (2026-07-12).** `RecipeCatalog.discover_by_trigger()` branché sur `level.gd._on_boss_died()` : à la victoire du Veilleur des Cendres, les 3 recettes `discovery: "Victoire Gardien du Voile"` (`lame_spectrale`, `anneau_revenants`, `elixir_resurgence`) sont découvertes et le Grimoire affiche la maîtrise correctement, testé manuellement en jeu.
5.2. **Portée limitée, pas une erreur :** seul le trigger boss est branché. Les triggers `Salle B1-B4` et `Porteur (...)` (17 recettes restantes) nécessitent des systèmes absents du jeu actuel — biomes multiples (phases 4, 7a-c) et ennemis porteurs (phase 8). À traiter quand ces phases seront développées.

**Statut : validé — plus aucun blocage sur ce point.**

---

**Validation Phase 2 (socle Grimoire/PC/Craft) — COMPLÈTE (2026-07-12)**

Toutes les sections 1-9 testées manuellement sans crash ni anomalie bloquante. Aucun blocage restant.

---

## 10. Armes à distance (Q016)

**VALIDÉ (2026-07-12).** Tir à l'arc opérationnel : débloqué via TOUT DECOUVRIR (DEV) + maîtrise Grimoire, crafté et équipé à l'établi, tir au bouton **attack** (même bouton que le mêlée, bascule selon le type d'arme équipée), cooldown respecté, retour au mêlée OK après rééquipement d'une épée.

## 11. Gain de PC en fin de run (Q044)

**VALIDÉ (2026-07-12).** Écran de fin affiche le gain correct (« +3 PC » sur victoire boss, gain réduit ×0.5 sur mort), total Grimoire cohérent.

## 12. Outils dev (menu titre + menu pause)

**VALIDÉ (2026-07-12).** Les 5 bascules (100 MAT, VIE INF, PC INFINI, SANS MOBS, ONE SHOT) fonctionnent à l'identique dans les deux menus (état partagé via `Dev.*`), avec effet immédiat en jeu depuis la pause. GRIMOIRE accessible depuis les deux menus. Établi et Grimoire défilent correctement (fenêtre glissante) sans recette invisible.

---

**Statut global : toutes les sections (1-12) validées manuellement, aucun blocage restant.**
