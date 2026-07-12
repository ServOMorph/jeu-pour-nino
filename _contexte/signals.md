# Signals — jeu   (MAJ 2026-07-12)

## Question bloquante
Aucune côté jeu.

## Actions ouvertes
- [P1] Compléter la Phase 2 restante côté jeu : barème/gain de PC, progression de run associée, armes à distance et tests craft dédiés.
  fait quand: `progression.json` branché, compteurs de run persistés jusqu'au calcul PC, mécanique distance jouable, `tests/test_craft.gd` vert.
  réf: `roadmap.md` Phase 2, `questions.md` Q016/Q043/Q044/Q055/Q056
- [P2] Triggers `Salle B1-B4` et `Porteur` (17 recettes non-starter restantes) non branchables : dépendent de systèmes absents (biomes multiples, ennemis porteurs — phases 4, 7a-c, 8). À traiter quand ces phases seront développées, pas avant.
  fait quand: n/a — dépend du développement des phases 4/7a-c/8.
  réf: `game/scripts/recipe_catalog.gd` (`discover_by_trigger`), `game/data/recipes.json`
- [P2] Traiter le pivot pixel art → 2D standard côté game_art : éditeur dépixélisé, `ref_to_sprite.py` remplacé par un script de rescale, premier asset produit via le pipeline actif.
  fait quand: plus aucune mention pixel art/grille/palette limitée dans la doc et l'outillage game_art ; premier asset produit via le pipeline Codex + rescale.
  réf: `plan_graphismes_standard_2d.md`, `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 »)
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Suivre l'avancement du pivot art via `game_art/backlog_art.md` (canal unique de handoff).
  fait quand: n/a — le statut et la priorité de ces items vivent uniquement dans `backlog_art.md`, pas ici.
  réf: `game_art/backlog_art.md`

## Questions ouvertes

## Échéances

## Blocages
*Aucun.*

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu.
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated.
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`.
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement.
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py ; exclut `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`.
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct.
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd) — nouveaux boutons à réserver pour arme à distance (Q016/Q019).
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom.
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée.
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé.
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run. Vérification headless : `Godot_v4.5-stable_win64.exe --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`.
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) — cible finale plein écran par défaut (Q072), à régler en Phase 10.
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée.
- Piège GDScript découvert 2026-07-11 : un `const` de tableau non typé (`const X := [...]`) rend `X[i]` de type `Variant` — `var v := X[i]` échoue alors à l'inférence de type sous Godot 4.5 et casse la compilation du script entier (et de tout ce qui le précharge). Toujours typer les const tableaux utilisés pour de l'indexation (`const X: Array[String] = [...]`).
- Slots `weapon`/`armor`/`accessory`/`tool`/`consumable` gérés par `equipment_menu.gd` ; les recettes de slot `utility` (`pioche_renforcee`, `corde`, `etabli_portable`) ne sont pas équipables via cet écran — `pioche_renforcee` agit automatiquement dès qu'elle est possédée (tier de minage), `corde`/`etabli_portable` n'ont aucun effet en jeu implémenté à ce stade.
- Aucune recette starter n'a le slot `accessory` — le slot ACCESSOIRE reste normalement vide (`Aucun` seul choix) hors des 3 recettes débloquées par victoire boss.
- `tests_manuels.md` (racine) : validation manuelle Phase 2 complète (2026-07-12), toutes sections 1-9 OK sans anomalie.
- `RecipeCatalog.discover_by_trigger()` (`game/scripts/recipe_catalog.gd`) : appelé depuis `level.gd._on_boss_died()` — seul trigger de découverte de recette branché à ce jour (victoire boss). Pattern réutilisable pour brancher les futurs triggers salle/porteur.

## Dernière session (2026-07-12 — diagnostic 8.6, discover_recipe branché, validation Phase 2 complète)

## Décisions prises
- 8.6 diagnostiqué comme faux bug : sélection de consommable fonctionne correctement, le comportement observé (pas de changement visible) est attendu quand un seul type de consommable est en stock.
- `discover_recipe()` branché sur la victoire du boss uniquement (3/20 recettes non-starter) — les 17 recettes restantes attendent des systèmes de jeu non développés (biomes multiples, porteurs).
- Validation manuelle du flux Phase 2 déclarée complète : sections 1-9 testées sans anomalie bloquante.

## Livrables produits ou modifiés
- `game/scripts/recipe_catalog.gd` : ajout de `discover_by_trigger()`.
- `game/scripts/level.gd` : appel de `discover_by_trigger()` dans `_on_boss_died()`.
- `tests_manuels.md` : sections 5, 8, 9 mises à jour et validées ; document réduit à un résumé de clôture.
- `_contexte/signals.md`, `_contexte/contexte.md` : mis à jour en conséquence.

## Hypothèses validées / invalidées
- VALIDE : sélection de consommable (8.6) — comportement correct, pas de bug.
- VALIDE : trigger `discover_recipe` sur victoire boss — testé manuellement en jeu, GUT 25/25 vert.
- VALIDE : validation manuelle Phase 2 complète, aucune anomalie bloquante restante.

## Prochaine étape exacte
Compléter la Phase 2 restante : barème/gain de PC, progression de run persistée, armes à distance, tests craft dédiés (`roadmap.md` Phase 2).

## Question bloquante pour la session suivante
Aucune côté jeu.
