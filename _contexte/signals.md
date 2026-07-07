# Signals — jeu   (MAJ 2026-07-07)

## Question bloquante
Confirmer le facteur d'échelle du sprite player avant la phase E du plan résolution : upscale ×6 transitoire (144 px, pixels propres) ou attente d'un sprite natif ~150 px produit par game_art ? Conditionne le déclenchement de la phase sprites.

## Actions ouvertes
- [P1] Exécuter le plan de migration résolution 1920×1080 (`plan_resolution_1920x1080.md`, racine) — phases A+B (project.godot + JSON ×4) à livrer ensemble en premier.
  fait quand: viewport natif 1920×1080, toutes les valeurs px des JSON/scènes/scripts ×4 appliquées, sprites transitoires upscalés, GUT vert, run manuel complet validé (voir phase G du plan).
  réf: `plan_resolution_1920x1080.md`
- [P2] Démarrer la Phase 2 — Grimoire, Points de Compétence, Craft v3 (roadmap.md Phase 2), maintenant que la Phase 1 est close. Reste en attente tant que la migration résolution n'est pas close (évite de produire des UI/écrans à la mauvaise échelle).
  fait quand: `recipes.json` étendu au schéma cible, écran d'équipement manuel (4 slots), Grimoire accessible au HUB ; tests verts.
  réf: `roadmap.md` Phase 2, `questions.md` Q043/Q055/Q056
- [P2] Lancer le développement avec 2 agents séparés (jeu et game_art) en s'appuyant sur `questions.md` comme source d'arbitrage commune en cas de doute de conception.
  fait quand: les deux agents travaillent sans contradiction — `roadmap.md` (jeu) et `game_art/backlog_art.md` (game_art) sont cohérents entre eux et avec `questions.md`.
  réf: `questions.md` (racine), `roadmap.md`, `game_art/backlog_art.md`
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Suivre l'avancement des assets art via `game_art/backlog_art.md` (canal unique de handoff) : voir entrée « Sprites player — standard Terraria-like » (statut `en_cours`).
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
- Protocole de communication jeu ↔ game_art revu le 2026-07-06 : `game_art/backlog_art.md` est désormais l'unique canal de handoff (statuts `a_faire`/`en_cours`/`livre`/`integre`, champs `debloque:`/`livraison:`) ; `/start jeu` charge le backlog et remonte les entrées `livre` ; plus aucune écriture croisée dans le `_contexte/` de l'autre zone (voir `.claude/zones.md` pour la matrice de propriété des fichiers).
- **Phase 1 close le 2026-07-06** : run manuel complet validé (minage tiers 2/3, craft, HUD, menu dev), GUT vert (`23/23`). `minerai_abyssal` utilise son sprite dédié `ore_abyssal.png`, `fer` rebranché sur `ore_iron.png` (utilisait encore le placeholder cuivre par erreur).
- **Demande utilisateur 2026-07-07** : passer le viewport de jeu en 1920×1080 natif (au lieu de 480×270 upscalé ×4), player idle ciblé à 150 px de haut. Plan complet écrit avant toute exécution (`plan_resolution_1920x1080.md`) pour ne rien casser — migration transversale (project.godot, tous les JSON gameplay, scènes, scripts UI, sprites), avec alternative moins coûteuse documentée (rester en 480×270, sprite ~38 px) si la migration s'avère trop lourde en cours de route.
- Fichiers `game/data/materials.json` et `game/scripts/ore_node.gd` modifiés en working tree (sprites `ore_copper_handmade_v2`) sans lien avec cette session — probablement issus d'un `sync.py` ou d'une session game_art en parallèle, non commités. À vérifier/clarifier avant prochain commit large.

## Dernière session (2026-07-07 — Plan de migration résolution 1920×1080)

# Session du 2026-07-07

## Décisions prises
- Migration vers un viewport natif 1920×1080 retenue (plutôt que garder 480×270 avec un sprite player agrandi) : facteur d'échelle monde ×4, player à 150 px visé (~×6.25).

## Livrables produits ou modifiés
- `plan_resolution_1920x1080.md` (racine) : plan complet en 10 sections (constat, phases A à G projet/JSON/scènes/scripts/sprites/calibration/validation, points de vigilance, ordre d'exécution).

## Hypothèses validées / invalidées
- EN ATTENTE : choix définitif entre upscale ×6 transitoire (144 px, pixels propres) et sprite natif 150 px produit par game_art — à trancher avant la phase E du plan.

## Prochaine étape exacte
Exécuter les phases A (project.godot) et B (JSON ×4) du plan ensemble, sur une branche dédiée, puis valider GUT + lancement headless avant de poursuivre.

## Question bloquante pour la session suivante
Confirmer le facteur d'échelle du sprite player (×6 transitoire vs attente sprite natif game_art) avant la phase E.
