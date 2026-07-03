# Signals — jeu   (MAJ 2026-07-03)

## Actions ouvertes
- [P1] Finir la dette bloquante Phase 0 : les 3 appels `Inventory` sont corrigés (migrés vers `RunState`) et le niveau se charge sans crash, mais la validation complète n'est pas faite.
  fait quand: `inventory.gd` supprimé ; 20 tests GUT verts ; run manuel complet (miner, crafter, tuer ennemis, battre boss, relancer) sans erreur console, `MetaState` conservé après relance.
  réf: `roadmap.md` section « Dette bloquante Phase 0 »
- [P2] Démarrer Phase 1 roadmap v3 : matériaux typés (materials: Dictionary dans RunState).
  fait quand: miner ajoute le bon matériau ; HUD reflète les quantités par type ; tests verts ; couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like (hors `idle`, corrigé cette session). (zone game_art)
  fait quand: run1, run2, jump et attack utilisent tous des sprites cohérents en taille validée en jeu (idle réglé à 14x24, cohérent avec run/jump).
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`, `game_art/backlog_art.md`
- [P3] Aligner le design document v3 sur le scope réduit du Miroir du Noyau (2 paramètres au lieu de 4) — décision utilisateur du 2026-07-02, pas encore répercutée dans le doc.
  fait quand: `docs/v3/CoreDive Challenge — Design Document v3.md` ne mentionne plus « boss vaincus » et « style de jeu » comme paramètres actifs du Miroir (ou les marque explicitement backlog post-v3).
  réf: `roadmap.md` Phase 9 et section « Backlog post-v3 », `docs/v3/CoreDive Challenge — Le Noyau et le Boss Final Adaptatif.md`
- [P3] Vérification visuelle Phase 2.3 game_art (jeu vs éditeur côte à côte) pas encore faite — outillage prêt (`run_edit_game.py`).
  fait quand: `player.run` confirmé identique en fps/rendu/taille entre jeu et éditeur à zoom x1 ; case cochée dans `game_art/roadmap_editeur.md`.
  réf: `run_edit_game.py`, `game_art/roadmap_editeur.md` section 2.3

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py (renommé depuis run.py) ; exclut désormais `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`
- `run_edit_game.py` (racine) : lance jeu (gauche) + éditeur (droite), plein écran partagé, pour comparaison visuelle
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct (piège découvert cette session avec `ore_node.gd`/`workbench.gd`)
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- `inventory.gd` toujours présent, plus référencé (3 appels résiduels migrés vers `RunState` cette session) — suppression restante dans l'action P1
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`), plus plein écran
- Nouveau : `game_art/backlog_art.md` centralise les besoins d'assets par phase — à consulter en priorité lors des sessions game_art
- Roadmap réordonnée (2026-07-02) : mort/résurrection/cicatrices (Phases 5-6) désormais avant le contenu des biomes 2/3/4 (Phase 7, ex-Phase 5). Vérifier les numéros de phase avant de s'y référer dans du code ou des commentaires.
- `roadmap.md` détaillée (2026-07-02, session 2) : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : décision retenue = conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète).
- game_art Phase 2.2 (infos frame, damier, play/pause, placeholder manquant) et 2.4 (sync.py assaini) terminées et validées visuellement — reste 2.3 (comparaison jeu/éditeur).

## Dernière session (2026-07-03 — dette Inventory corrigée, sprite idle redimensionné, outillage comparaison jeu/éditeur)

# Session du 2026-07-03

## Décisions prises
- `game_art` Phase 2.2 (infos frame, fond damier, état play/pause, placeholder magenta) implémentée et validée visuellement en direct dans l'éditeur.
- `sync.py` assaini (Phase 2.4) : exclusion de `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`.
- Sprite `player_idle_v2.png` redimensionné de 40x56 à 14x24 (cohérent avec `run`/`jump`) ; offsets `[0,-16]` associés remis à `[0,0]`.
- `game/project.godot` : fenêtre passée en mode fenêtré (`window/size/mode=0`).
- Dette bloquante Phase 0 : les 3 appels `Inventory` résiduels migrés vers `RunState`. Bug additionnel découvert et corrigé au passage : `ore_node.gd`/`workbench.gd` utilisaient `const := preload(png)` sur des sprites sans `.import` généré, ce qui crashait aussi au démarrage d'une partie — remplacé par chargement runtime (`Image.load_from_file`), cohérent avec `animation_driver.gd`.
- `run_edit_game.py` créé : lance jeu + éditeur côte à côte (gauche/droite, plein écran partagé) pour faciliter la comparaison Phase 2.3.

## Livrables produits ou modifiés
- `game_art/editeur/main.gd`, `game_art/editeur/animation_driver.gd` : 4 composants Phase 2.2 ajoutés.
- `sync.py` : exclusions ajoutées.
- `game_art/assets/player/player_idle_v2.png`, `game_art/data/animations.json` : sprite et offsets idle corrigés.
- `game/project.godot` : mode fenêtré.
- `game/scripts/ore_node.gd`, `game/scripts/enemy_base.gd`, `game/scripts/boss.gd`, `game/scripts/workbench.gd` : dette Inventory + preload PNG corrigées.
- `run_edit_game.py` : nouveau script racine.
- `game_art/roadmap_editeur.md` : Phase 2.2 et 2.4 cochées.
- `roadmap.md` : section « Dette bloquante Phase 0 » mise à jour (partiellement corrigée, reste à faire listé).

## Hypothèses validées / invalidées
- VALIDE : le rendu « trop gros » du sprite idle du player venait d'une incohérence d'échelle avec les autres états (40x56 vs 14-24px), pas d'un bug de code.
- VALIDE : les 3 appels `Inventory` étaient bien la cause du crash au démarrage d'une partie, mais pas la seule — les `preload()` de PNG non importés crashaient aussi (découverte non anticipée).
- EN ATTENTE : validation complète Phase 0 (GUT, run manuel intégral, suppression `inventory.gd`) — non faite, seul le chargement initial du niveau a été vérifié.
- EN ATTENTE : Phase 2.3 game_art (comparaison visuelle jeu/éditeur) — outillage prêt, test non exécuté.

## Prochaine étape exacte
Exécuter la comparaison Phase 2.3 (`run_edit_game.py`) pour `player.run` (fps, rendu, taille). Puis finir la validation Phase 0 (GUT + run complet + suppression `inventory.gd`) avant d'attaquer Phase 1.

## Question bloquante pour la session suivante
Aucune
