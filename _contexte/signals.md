# Signals — jeu   (MAJ 2026-07-08)

## Question bloquante
Aucune côté jeu — le pivot 2D standard est signalé à game_art via `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 »), en attente de sa prise en charge.

## Actions ouvertes
- [P1] Traiter le pivot pixel art → 2D standard côté game_art : éditeur dépixélisé, `ref_to_sprite.py` remplacé par un script de rescale, premier asset produit via le pipeline actif.
  fait quand: plus aucune mention pixel art/grille/palette limitée dans la doc et l'outillage game_art ; premier asset produit via le pipeline Codex + rescale.
  réf: `plan_graphismes_standard_2d.md`, `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 »)
- [P1] Démarrer la Phase 2 — Grimoire, Points de Compétence, Craft v3 (roadmap.md Phase 2), maintenant que la migration résolution 1920×1080 est validée.
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
- **Migration résolution 1920×1080 validée le 2026-07-08** : GUT vert, lancement headless OK et run manuel confirmé par l'utilisateur. Le socle jeu est considéré stable côté résolution.
- **Pivot 2026-07-07 : abandon du pixel art, passage à des graphismes 2D standard.** Décision utilisateur. Plan écrit (`plan_graphismes_standard_2d.md`) avant exécution. Pipeline de production retenu : génération d'image via le module Codex, puis rescale à la taille de rendu cible — pas de dessin manuel, pas de vectoriel, pas d'asset packs. Point de vigilance : dérive de cadrage/échelle possible entre frames d'une même animation générées séparément par l'IA, à contrôler avant intégration. La résolution native 1920×1080 est conservée (plus pertinente pour du 2D lissé que pour du pixel art).
- Phase A du pivot 2D standard appliquée côté jeu : `game/project.godot` en filtre linéaire (`default_texture_filter=1`) et `stretch/mode="canvas_items"` (au lieu de nearest/viewport, adaptés au pixel art).
- Pivot signalé à game_art via `game_art/backlog_art.md` (entrée « Pivot 2026-07-07 ») : éditeur, `ref_to_sprite.py`, charte graphique et workflow à refondre — propriété exclusive de l'agent game_art, non traité côté jeu.
- Documentation active réalignée le 2026-07-08 sur la direction 2D standard : `README.md`, docs pipeline/charte, backlog art et roadmap éditeur.

## Dernière session (2026-07-08 — validation migration 1920×1080 et doc)

# Session du 2026-07-08

## Décisions prises
- Migration résolution 1920×1080 validée côté jeu : GUT, headless et test manuel concordants.
- Documentation active réalignée sur la direction 2D standard et le pipeline Codex + rescale.

## Livrables produits ou modifiés
- `README.md` : état projet et direction visuelle active mis à jour.
- `docs/process_generation_sprites.md`, `docs/workflow_image_gen_fable5.md`, `docs/charte_graphique_pixel_art_dark_fantasy.md` : réécrits pour la 2D standard.
- `docs/Document de conception — Jeu pixel art run court & challenge.md`, `docs/v3/CoreDive Challenge — Design Document v3.md`, `docs/profi joueur nino.md`, `docs/prompt_lancememnt_opus.txt` : mentions historiques clarifiées.
- `game_art/backlog_art.md`, `game_art/roadmap_editeur.md` : specs et périmètre alignés sur la 2D standard.

## Hypothèses validées / invalidées
- VALIDE : la migration résolution 1920×1080 est stable côté jeu.
- VALIDE : la doc active peut être réalignée sans changement de code additionnel.
- EN ATTENTE : refonte outillage/production game_art complète (script de rescale et premier asset pipeline 2D standard).

## Prochaine étape exacte
Démarrer la Phase 2 côté jeu, puis ouvrir une session game_art pour finaliser le pivot outillage/production côté art.

## Question bloquante pour la session suivante
Aucune côté jeu.
