# Signals — jeu   (MAJ 2026-07-07)

## Question bloquante
Aucune côté jeu — le pivot 2D standard est signalé à game_art via `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 »), en attente de sa prise en charge.

## Actions ouvertes
- [P1] Valider la migration résolution 1920×1080 déjà exécutée (JSON/scènes/scripts/sprites transitoires en place, confirmé par relecture directe — pas encore par test).
  fait quand: GUT vert (23/23), lancement headless OK, run manuel complet validé (title → biome → craft → boss → menus).
  réf: `plan_resolution_1920x1080.md` phase G
- [P1] Traiter le pivot pixel art → 2D standard côté game_art : éditeur dépixélisé (filtre linéaire, retrait preview x8/audit grille), `ref_to_sprite.py` remplacé par un script de rescale, charte graphique et workflow réécrits, `backlog_art.md` révisé entrée par entrée.
  fait quand: plus aucune mention pixel art/grille/palette limitée dans la doc et l'outillage game_art ; premier asset produit via le pipeline Codex + rescale.
  réf: `plan_graphismes_standard_2d.md`, `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 »)
- [P2] Démarrer la Phase 2 — Grimoire, Points de Compétence, Craft v3 (roadmap.md Phase 2), maintenant que la Phase 1 est close. Reste en attente tant que la migration résolution n'est pas validée (GUT + run manuel).
  fait quand: `recipes.json` étendu au schéma cible, écran d'équipement manuel (4 slots), Grimoire accessible au HUB ; tests verts.
  réf: `roadmap.md` Phase 2, `questions.md` Q043/Q055/Q056
- [P2] Lancer le développement avec 2 agents séparés (jeu et game_art) en s'appuyant sur `questions.md` comme source d'arbitrage commune en cas de doute de conception.
  fait quand: les deux agents travaillent sans contradiction — `roadmap.md` (jeu) et `game_art/backlog_art.md` (game_art) sont cohérents entre eux et avec `questions.md`.
  réf: `questions.md` (racine), `roadmap.md`, `game_art/backlog_art.md`
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Suivre l'avancement du pivot art via `game_art/backlog_art.md` (canal unique de handoff).
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
- **Migration résolution 1920×1080 exécutée** (project.godot, JSON gameplay ×4, scènes, scripts UI, sprites upscalés ×6 transitoires) — confirmée par relecture directe des fichiers, mais GUT et run manuel restent à (re)lancer pour valider formellement (phase G du plan non cochée).
- **Pivot 2026-07-07 : abandon du pixel art, passage à des graphismes 2D standard.** Décision utilisateur. Plan écrit (`plan_graphismes_standard_2d.md`) avant exécution. Pipeline de production retenu : génération d'image via le module Codex, puis rescale à la taille de rendu cible — pas de dessin manuel, pas de vectoriel, pas d'asset packs. Point de vigilance : dérive de cadrage/échelle possible entre frames d'une même animation générées séparément par l'IA, à contrôler avant intégration. La résolution native 1920×1080 est conservée (plus pertinente pour du 2D lissé que pour du pixel art).
- Phase A du pivot 2D standard appliquée côté jeu : `game/project.godot` en filtre linéaire (`default_texture_filter=1`) et `stretch/mode="canvas_items"` (au lieu de nearest/viewport, adaptés au pixel art).
- Pivot signalé à game_art via `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 ») : éditeur, `ref_to_sprite.py`, charte graphique et workflow à refondre — propriété exclusive de l'agent game_art, non traité côté jeu.

## Dernière session (2026-07-07 — Pivot graphismes 2D standard)

# Session du 2026-07-07

## Décisions prises
- Abandon du pixel art, passage à des graphismes 2D standard (résolution native lissée, plus de grille/palette). Résolution 1920×1080 conservée.
- Pipeline de production des assets : génération Codex + rescale à la taille cible.

## Livrables produits ou modifiés
- `plan_graphismes_standard_2d.md` (racine) : plan complet (impact, rendu, production, refonte game_art, doc, validation).
- `game/project.godot` : rendu passé en filtre linéaire + `stretch/mode="canvas_items"`.
- `roadmap.md`, `questions.md`, `game/README.md` : mentions 480×270/pixel art/grille 16×16 corrigées vers 1920×1080/2D standard.
- `game_art/backlog_art.md` : entrée de handoff « Pivot 2026-07-07 » créée pour la zone game_art.
- Migration résolution 1920×1080 (`plan_resolution_1920x1080.md`, phases A-E transitoire) confirmée appliquée dans le working tree (project.godot, JSON, scènes, scripts, sprites upscalés).

## Hypothèses validées / invalidées
- VALIDE : la migration résolution est cohérente sur relecture directe (dimensions JSON, sprites upscalés, animations.json).
- INVALIDE : direction pixel art — pivot acté vers 2D standard.
- EN ATTENTE : GUT + run manuel non (re)lancés depuis la migration résolution ; refonte game_art (éditeur, charte, workflow, script de rescale) non commencée.

## Prochaine étape exacte
Lancer GUT + run manuel pour valider formellement la migration résolution, puis ouvrir une session game_art pour traiter le pivot signalé dans `backlog_art.md`.

## Question bloquante pour la session suivante
Aucune côté jeu.
