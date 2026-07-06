# Signals — jeu   (MAJ 2026-07-06)

## Question bloquante

## Actions ouvertes
- [P2] Lancer le développement avec 2 agents séparés (jeu et game_art) en s'appuyant sur `questions.md` comme source d'arbitrage commune en cas de doute de conception.
  fait quand: les deux agents travaillent sans contradiction — `roadmap.md` (jeu) et `game_art/backlog_art.md` (game_art) sont cohérents entre eux et avec `questions.md`.
  réf: `questions.md` (racine), `roadmap.md`, `game_art/backlog_art.md`
- [P1] Clore proprement la Phase 1 roadmap v3 : le socle matériaux typés est branché et le gating de minage est désormais data-driven, mais il manque encore la validation manuelle complète du flux minage/craft/HUD/menu dev.
  fait quand: un run manuel complet valide minage/craft/HUD/menu dev ; les tests restent verts avec couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `questions.md` Q041/Q022/Q045, `game/data/materials.json`, `game/data/level.json`, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/craft_menu.gd`, `game/scripts/hud.gd`
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Suivre l'avancement des assets art via `game_art/backlog_art.md` (canal unique de handoff) : voir entrées « Sprite manquant — minerai abyssal » (statut `livre`, à intégrer) et « Sprites player — standard Terraria-like » (statut `en_cours`).
  fait quand: n/a — le statut et la priorité de ces items vivent uniquement dans `backlog_art.md`, pas ici.
  réf: `game_art/backlog_art.md`

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
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) — cible finale plein écran par défaut (Q072), à régler en Phase 10
- `roadmap.md` détaillée : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète) ; Phase 6 : planchers durs obligatoires dans `scars.json` (Q026b).
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée — toujours régler `stretch_shrink` en complément de `stretch=true` pour un zoom pixel-perfect.
- game_art Phase 2 (2.1 à 2.4) intégralement terminée et validée visuellement.
- Phase 1 entamée le 2026-07-06 : `materials.json` ajouté, `RunState` migré vers `materials`, HUD/craft/gisements branchés, `coins` supprimés du code de jeu.
- Vérifié le 2026-07-06 : GUT vert (`23/23`) et démarrage Godot headless OK ; la fermeture de Phase 1 reste bloquée par l'absence d'un run manuel complet de validation.
- Setup de test Phase 1 ajouté le 2026-07-06 : un minerai tier 2 (`fer`) et un tier 3 (`minerai_abyssal`) sont placés autour de l'atelier dans `level.json`.
- Visuel manquant identifié le 2026-07-06 : `minerai_abyssal` n'a pas encore de sprite dédié ; entrée ajoutée dans `game_art/backlog_art.md`.
- Protocole de communication jeu ↔ game_art revu le 2026-07-06 : `game_art/backlog_art.md` est désormais l'unique canal de handoff (statuts `a_faire`/`en_cours`/`livre`/`integre`, champs `debloque:`/`livraison:`) ; `/start jeu` charge le backlog et remonte les entrées `livre` ; plus aucune écriture croisée dans le `_contexte/` de l'autre zone (voir `.claude/zones.md` pour la matrice de propriété des fichiers).

## Dernière session (2026-07-06 — protocole de communication jeu/game_art fiabilisé)

# Session du 2026-07-06

## Décisions prises
- `game_art/backlog_art.md` devient l'unique canal de handoff entre les deux agents ; les deux `_contexte/signals.md` ne se référencent plus de statuts art dupliqués.
- `/start jeu` charge désormais systématiquement le backlog art et remonte les assets `livre` prêts à intégrer.
- README/CHANGELOG : README réservé à `/close jeu` ; garde-fou ajouté contre un bump CHANGELOG en parallèle des deux zones.

## Livrables produits ou modifiés
- `.claude/commands/start.md` : étape 4bis (zone `jeu` lit `backlog_art.md`, bloc `Assets à intégrer`).
- `.claude/commands/close.md` : étape 6bis simplifiée (game_art n'écrit plus dans le signals.md racine), étape 6ter ajoutée (zone jeu met à jour le backlog), étape 7 restreinte à la zone jeu.
- `.claude/zones.md` : matrice de propriété des fichiers partagés ajoutée.
- `game_art/backlog_art.md` : 4 statuts, champs `debloque:`/`livraison:` ; entrée `minerai_abyssal` corrigée en statut `livre`.
- `_contexte/signals.md` : entrées art dupliquées remplacées par une référence unique vers `backlog_art.md`.

## Hypothèses validées / invalidées
- VALIDE : le sprite `minerai_abyssal` (`game_art/assets/objects/ore_abyssal.png`) existe déjà côté disque mais n'est pas encore commité ni intégré côté jeu — signalé comme dette à part, hors périmètre de cette session.

## Prochaine étape exacte
Au prochain `/start jeu` : intégrer le sprite `ore_abyssal.png` (statut `livre` dans le backlog) pour débloquer la clôture de la Phase 1, puis passer son statut à `integre`.

## Question bloquante pour la session suivante
Aucune
