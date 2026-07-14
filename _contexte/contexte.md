# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
**Phase 3 livrée côté code (2026-07-14) — validation en jeu non faite.** Le run est multi-biomes : autoload `GameFlow` (`next_biome_id`, `start_run`/`enter_biome`/`return_to_hub`/`end_run`), HUB jouable (4 portails dont 3 `locked`, stèle Grimoire, établi tier 1, soin complet à l'entrée), portail de sortie volontaire dans le biome, boss vaincu mémorisé par biome dans `RunState`.
`RunState.reset()` n'a plus lieu qu'au lancement d'un nouveau run. `data/level.json` → `data/biomes/biome1.json` ; `biome1.tscn` → `biome.tscn` (scène générique pilotée par `GameFlow`).
GUT 49/49 vert, boot headless propre sur `hub.tscn` et `biome.tscn`.
Phase 2 reste techniquement ouverte : 2 tâches mineures non bloquantes (`_is_recipe_obsolete()` hardcodé, test de synergie cross-biome).
Prochaine étape : jouer et valider le jalon J1 (HUB → biome → retour HUB), puis Phase 4 (génération procédurale).

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
- 2026-07-14 : Phase 3 livrée côté code — autoload `GameFlow` (unique point de `RunState.reset()`), HUB (`hub.tscn`/`hub.gd`/`hub.json`), scène de biome générique paramétrée par `next_biome_id`, portail de sortie volontaire, soin complet au HUB, boss vaincu mémorisé par biome. Battre un boss de biome ne termine plus le run (retour HUB). Abandon de run via la pause traité comme un run raté (PC ×0.5) — décision à confirmer. Validation en jeu du jalon J1 reportée à la session suivante.
- 2026-07-12 : P1 restant de Phase 2 complété — barème PC, armes à distance (bouton `attack` partagé avec le mêlée, sans bouton dédié, décision explicite utilisateur), outils dev unifiés menu titre/pause via l'autoload `Dev`, défilement ajouté à `craft_menu.gd`/`grimoire_menu.gd`. GUT 40/40 vert, validation manuelle complète (12 sections). 2 tâches mineures de Phase 2 restent ouvertes dans `roadmap.md` (hors périmètre demandé).
