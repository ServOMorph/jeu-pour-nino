# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
**P1 restant de Phase 2 complété (2026-07-12).** Barème/gain de PC (`progression.gd`/`progression.json`), armes à distance (bouton `attack` partagé avec le mêlée, bascule selon l'arme équipée), et `tests/test_craft.gd` livrés. Phase 2 reste techniquement ouverte dans `roadmap.md` : 2 tâches mineures non demandées cette session (retrait de `_is_recipe_obsolete()` hardcodé, test de synergie cross-biome) restent à faire, non bloquantes.
Outils dev étendus et unifiés entre menu titre et menu pause (`Dev` autoload) : `100 MAT`, `VIE INF`, `PC INFINI`, `SANS MOBS`, `ONE SHOT`, accès `GRIMOIRE`. `craft_menu.gd`/`grimoire_menu.gd` défilent désormais correctement (fenêtre glissante) au lieu de déborder de l'écran.
GUT 40/40 vert. Validation manuelle complète : `tests_manuels.md` sections 1-12 toutes OK, aucune anomalie bloquante.
Bump `CHANGELOG.md` de cette session différé (édition concurrente game_art non commitée au moment du close) — à reprendre au prochain close.
Prochaine étape : démarrer la Phase 3 (HUB et sélection de biome), incluant le déplacement de `RunState.reset()` vers `title.gd._start_game()`.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
- 2026-07-08 : Migration résolution 1920×1080 validée formellement côté jeu (GUT + headless + test manuel).
- 2026-07-08 : Socle Phase 2 branché côté jeu — schéma recettes cible, Grimoire dev, équipement via pause, craft filtré par maîtrise/tier.
- 2026-07-11 : Menu titre/dev reformaté (suppression hint manette, menu dev tenant dans la fenêtre).
- 2026-07-11 : Bug de compilation `equipment_menu.gd` (`SLOT_ORDER` non typé) corrigé ; affichage équipement retravaillé.
- 2026-07-11 : Validation manuelle Phase 2 engagée — deux blocages identifiés (découverte de recettes absente, sélection consommable sans effet visible) à traiter en priorité avant de clore la Phase 2.
- 2026-07-12 : Validation manuelle Phase 2 complétée (sections 1-9, sans anomalie bloquante). Diagnostic 8.6 : faux bug, comportement correct.
- 2026-07-12 : `discover_recipe()` branché sur victoire boss uniquement (3/20 recettes non-starter) — triggers salle/porteur attendent des systèmes non développés (biomes multiples, porteurs).
- 2026-07-12 : Audit mémoire projet + pivot pixel art — `.claude/memory.md` corrigé (bindings manette, dimensions player) ; confirmé qu'aucune trace active de l'ancien pixel art ne subsiste côté jeu, hors `ref_to_sprite.py` (dette game_art, tracée dans `backlog_art.md`).
- 2026-07-12 : P1 restant de Phase 2 complété — barème PC, armes à distance (bouton `attack` partagé avec le mêlée, sans bouton dédié, décision explicite utilisateur), outils dev unifiés menu titre/pause via l'autoload `Dev`, défilement ajouté à `craft_menu.gd`/`grimoire_menu.gd`. GUT 40/40 vert, validation manuelle complète (12 sections). 2 tâches mineures de Phase 2 restent ouvertes dans `roadmap.md` (hors périmètre demandé).
