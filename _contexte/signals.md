# Signals — jeu   (MAJ 2026-07-11)

## Question bloquante
Aucune côté jeu.

## Actions ouvertes
- [P1] Validation manuelle du flux Phase 2 complète (sections 1-4, 6-9 testées sans anomalie). Débloquer maintenant la découverte de recettes non-starter (§5 tests_manuels.md) : brancher `MetaState.discover_recipe()` via trigger gameplay (salle, drop porteur, victoire boss).
  fait quand: `tests_manuels.md` intégralement coché sans anomalie bloquante restante.
  réf: `tests_manuels.md` (racine)
- [P1] Débloquer la découverte de recettes non-starter (voir Blocages) puis reprendre la validation de la maîtrise de recette (Grimoire).
  fait quand: un trigger gameplay (salle, drop de porteur, victoire boss) appelle `MetaState.discover_recipe()` et au moins une recette non-starter devient maîtrisable manuellement.
  réf: `game/scripts/meta_state.gd`, `game/data/recipes.json`
- [P1] Compléter la Phase 2 restante côté jeu : barème/gain de PC, progression de run associée, armes à distance et tests craft dédiés.
  fait quand: `progression.json` branché, compteurs de run persistés jusqu'au calcul PC, mécanique distance jouable, `tests/test_craft.gd` vert.
  réf: `roadmap.md` Phase 2, `questions.md` Q016/Q043/Q044/Q055/Q056
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
- **Découverte de recettes non-starter absente en jeu** (constat 2026-07-11) : `MetaState.discover_recipe()` (`game/scripts/meta_state.gd:26`) n'est appelé nulle part hors tests GUT (`test_meta_state.gd`, `test_save_manager.gd`). Aucune salle/porteur/victoire boss ne déclenche la découverte des 20 recettes non-starter de `recipes.json`. Le Grimoire n'affiche donc que les 7 recettes `starter`, déjà maîtrisées à `PC 0`. Bloque la validation manuelle complète du flux Phase 2 (étape « maîtriser une recette non-starter » impossible). À traiter avant de considérer la Phase 2 validable.

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
- Aucune recette starter n'a le slot `accessory` — le slot ACCESSOIRE reste normalement vide (`Aucun` seul choix) tant que le blocage `discover_recipe` n'est pas levé.
- `tests_manuels.md` (racine) : document de suivi de la validation manuelle Phase 2, créé le 2026-07-11 — à consulter/mettre à jour en priorité pour reprendre les tests là où ils se sont arrêtés.

## Dernière session (2026-07-12 — diagnostic 8.6 + clarification)

# Session du 2026-07-11

## Décisions prises
- Menu titre reformaté : suppression du hint manette obsolète, menu dev retravaillé pour tenir entièrement dans la fenêtre 1920×1080.
- Début de la validation manuelle du flux Phase 2 engagée avec l'utilisateur, suivie dans `tests_manuels.md` (racine).

## Livrables produits ou modifiés
- `game/scripts/title.gd` : suppression du hint manette, repositionnement/redimensionnement du menu dev (7 entrées) pour éviter le débordement bas d'écran.
- `game/scripts/equipment_menu.gd` : correctif d'un bug de compilation (`SLOT_ORDER` non typé cassait le chargement de `level.gd`) ; affichage retravaillé (nom lisible sur seconde ligne au lieu de l'id brut, ligne masquée sous `CONSOMMABLE`, marqueur `(actif)` + couleur sur la ligne active dans la liste).
- `tests_manuels.md` (racine, nouveau) : suivi détaillé et numéroté des tests manuels Phase 2, mis à jour au fil de la session (sections validées retirées au fur et à mesure).

## Hypothèses validées / invalidées
- VALIDE : sections 1 à 4, 6, 7 et 8.1-8.5 du flux Phase 2 validées manuellement sans anomalie.
- VALIDE : correctif de compilation `equipment_menu.gd` confirmé (GUT `25/25`, plus d'erreur de chargement de niveau).
- VALIDE : le comportement de sélection consommable est correct — premier consommable auto-actif dès le craft (`add_consumable()` ligne 107-108), réaffectation au même id produit aucun changement visible. Aucune correction requise sur `equipment_menu.gd` / `run_state.gd`.
- EN ATTENTE : découverte de recettes non-starter (`discover_recipe` jamais appelé en jeu) toujours bloquante pour valider le Grimoire au-delà des recettes starter.

---

# Session du 2026-07-12

## Diagnostic 8.6
Analyse du diagnostic "sélection de consommable sans effet visible" : confirmé comme faux bug. Le marqueur `(actif)` apparaît dès l'ouverture de l'écran Équipement sur `CONSOMMABLE` car le consommable est déjà actif (ligne 107-108 de `run_state.gd`). Avec un seul type en stock, la réaffectation ne produit aucun changement visible. Le code est correct. La vraie limitation : impossible d'avoir 2e consommable en stock tant que `discover_recipe()` n'est pas branché.

## Livrables produits ou modifiés
- `tests_manuels.md` : section 8.6 marquée comme validée (pas de bug) ; clarification que la limitation est l'absence `discover_recipe()`.
- `_contexte/signals.md` : suppression du blocage "8.6 sélection consommable" (faux bug) ; conservé seul bloc "découverte recettes non-starter" (vrai blocage).
- `_contexte/contexte.md` : mis à jour état actuel (8.1-8.6 validées OK, un bloc ouvert).

---

# Session du 2026-07-12 (suite)

## Validation Phase 2 — COMPLÈTE
Sections 8.7, 8.8 et §9 testées avec succès manuellement. Aucune anomalie détectée.

## Prochaine étape exacte
Brancher `MetaState.discover_recipe()` via trigger gameplay (salle, drop porteur, victoire boss) pour débloquer les recettes non-starter et terminer la validation du Grimoire.

## Question bloquante pour la session suivante
Aucune côté jeu.
