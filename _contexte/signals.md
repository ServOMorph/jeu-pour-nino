# Signals — jeu   (MAJ 2026-07-06)

## Question bloquante
- [P2] Contradiction de taille sprite player non tranchée : `roadmap_editeur.md`/`backlog_art.md` indiquent 40x56/48x56 (canvas de production), `_contexte/signals.md` (P3, ancien) indique idle réglé à 14x24 (taille rendue en jeu). Clarifier et écrire la convention avant de produire les frames run/jump/attack restantes.
  fait quand: convention documentée dans `backlog_art.md` (canvas vs taille jeu), marqueur ⚠ retiré de l'entrée « Sprites player ».
  réf: `game_art/backlog_art.md` entrée « Sprites player — standard Terraria-like »

## Actions ouvertes
- [P1] Finir la dette bloquante Phase 0 : les 3 appels `Inventory` sont corrigés (migrés vers `RunState`) et le niveau se charge sans crash, mais la validation complète n'est pas faite.
  fait quand: `inventory.gd` supprimé ; 20 tests GUT verts ; run manuel complet (miner, crafter, tuer ennemis, battre boss, relancer) sans erreur console, `MetaState` conservé après relance.
  réf: `roadmap.md` section « Dette bloquante Phase 0 »
- [P1] Lancer le développement avec 2 agents séparés (jeu et game_art) en s'appuyant sur `questions.md` comme source d'arbitrage commune en cas de doute de conception.
  fait quand: les deux agents travaillent sans contradiction — `roadmap.md` (jeu) et `game_art/backlog_art.md` (game_art) sont cohérents entre eux et avec `questions.md`.
  réf: `questions.md` (racine), `roadmap.md`, `game_art/backlog_art.md`
- [P2] Démarrer Phase 1 roadmap v3 : matériaux typés (materials: Dictionary dans RunState), avec la table définitive de 13 matériaux et le gating de minage par tier de pioche.
  fait quand: miner ajoute le bon matériau ; minage gaté par tier ; coins supprimés de `RunState` ; HUD reflète les quantités par type ; tests verts ; couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `questions.md` Q041/Q022/Q045, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like (hors `idle`, corrigé précédemment). (zone game_art)
  fait quand: run1, run2, jump et attack utilisent tous des sprites cohérents en taille validée en jeu (idle réglé à 14x24, cohérent avec run/jump).
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`, `game_art/backlog_art.md`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu. Consulter avant de trancher soi-même un point non couvert par `roadmap.md`.
- `roadmap.md` et les 4 docs `docs/v3/*.md` ont été mis à jour le 2026-07-06 pour intégrer ces décisions (section « Décisions verrouillées » en tête de roadmap, sections « Précisions v3.1 » en tête de chaque doc v3).
- `game_art/backlog_art.md` mis à jour en cohérence le 2026-07-06 — c'est le point de jonction entre l'agent jeu et l'agent game_art ; toute nouvelle décision de conception affectant le visuel doit y être répercutée.
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py ; exclut `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`
- `run_edit_game.py` (racine) : lance jeu (gauche) + éditeur (droite), plein écran partagé, pour comparaison visuelle
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd) — nouveaux boutons à réserver pour arme à distance et consommable (Q016/Q019)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- `inventory.gd` toujours présent, plus référencé — suppression restante dans l'action P1
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) — cible finale plein écran par défaut (Q072), à régler en Phase 10
- `roadmap.md` détaillée : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète) ; Phase 6 : planchers durs obligatoires dans `scars.json` (Q026b).
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée — toujours régler `stretch_shrink` en complément de `stretch=true` pour un zoom pixel-perfect.
- game_art Phase 2 (2.1 à 2.4) intégralement terminée et validée visuellement.

## Dernière session (2026-07-06 — cohérence roadmap.md / roadmap_editeur.md analysée et corrigée)

# Session du 2026-07-06

## Décisions prises
- Périmètre de l'éditeur game_art restreint explicitement aux sprites/animations d'entités ; tilesets, parallax, shaders de cicatrices, icônes UI validés directement en jeu, hors outillage éditeur.
- Règle de synchronisation manifest/backlog ajoutée : toute entité animée du backlog rejoint le manifest d'audit avant production.
- L'éditeur passe en maintenance après clôture de la Phase 5 (pas d'évolution d'outillage hors besoin concret du backlog).

## Livrables produits ou modifiés
- `game_art/roadmap_editeur.md` : sections « Articulation avec la zone jeu », « Perimetre », « Regle de synchronisation du manifest » et « Apres Phase 5 : maintenance » ajoutées ; « Fait quand » Phase 5 ancré sur l'entrée « Sprites player ».
- `game_art/backlog_art.md` : règle de synchronisation manifest ajoutée aux Règles ; entrée « Sprites player » enrichie (lien vers le Fait quand Phase 5 éditeur, marqueur de contradiction de taille à trancher).

## Hypothèses validées / invalidées
- EN ATTENTE : convention de taille des sprites player (canvas de production 40x56/48x56 vs taille rendue en jeu 14x24) — nécessite arbitrage utilisateur.

## Prochaine étape exacte
Trancher la convention de taille sprite player, puis reprendre la validation Phase 0 jeu (GUT, run manuel complet) avant Phase 1 (matériaux typés).

## Question bloquante pour la session suivante
Convention de taille sprite player (cf. section « Question bloquante » en tête de fichier).
