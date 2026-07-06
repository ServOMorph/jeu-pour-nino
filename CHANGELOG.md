## v1.31 - 2026-07-06

### Corrige
- `game/data/materials.json` : `minerai_abyssal` rebranche sur son sprite dedie `ore_abyssal.png` ; `fer` corrige vers `ore_iron.png` (utilisait encore le placeholder cuivre).

### Modifie
- `roadmap.md`, `_contexte/signals.md`, `_contexte/contexte.md`, `README.md` : Phase 1 (Materiaux types) declaree close apres validation du run manuel complet (minage tiers 2/3, craft, HUD, menu dev).
- `game_art/backlog_art.md` : entree « Sprite manquant - minerai abyssal » passee au statut `integre`.

## v1.30 - 2026-07-06

### Modifie
- `.claude/commands/start.md`, `.claude/commands/close.md`, `.claude/zones.md` : protocole de communication jeu/game_art fiabilise, `game_art/backlog_art.md` devient l'unique canal de handoff (statuts `a_faire`/`en_cours`/`livre`/`integre`, champs `debloque:`/`livraison:`).
- `game_art/backlog_art.md`, `_contexte/signals.md` : entree `minerai_abyssal` corrigee en statut `livre` ; references art dupliquees retirees du signals.md racine.

## v1.29 - 2026-07-06

### Modifie
- `game/data/weapons.json`, `game/scripts/run_state.gd`, `game/tests/test_run_state.gd` : gating de minage Phase 1 branche en data-driven via `pickaxe_tier`, avec couverture GUT portee a `23/23`.
- `game/data/level.json` : minerais de test `fer` et `minerai_abyssal` ajoutes autour de l'atelier pour permettre la validation manuelle des tiers 2/3.
- `roadmap.md`, `_contexte/signals.md`, `_contexte/contexte.md`, `README.md` : etat Phase 1 aligne sur le gating ferme et la validation manuelle restante.

### Ajoute
- `game_art/backlog_art.md` : entree backlog pour le sprite manquant `minerai_abyssal`.

## v1.28 - 2026-07-06

### Modifie
- `game/data/materials.json`, `game/data/level.json` : table des 13 materiaux ajoutee et gisements passes au format type `{pos, material}`.
- `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`, `game/scripts/craft_menu.gd`, `game/scripts/level.gd` : migration vers `materials`, gisements types, HUD par materiau, craft transitoire mono-materiau et dev resources par materiau.
- `_contexte/signals.md`, `_contexte/contexte.md`, `README.md`, `roadmap.md` : etat courant aligne sur une Phase 1 entamee mais non close.

### Corrige
- `game/scripts/enemy_base.gd`, `game/scripts/boss.gd`, `game/data/enemies.json`, `game/data/boss.json` : suppression des `coins`/`coin_reward` du runtime jeu.
- `game/tests/test_run_state.gd` : contrat de tests migre vers `materials`, avec couverture du fallback legacy `resources`.

## v1.27 - 2026-07-06

### Modifie
- `roadmap.md` : dette bloquante Phase 0 marquee corrigee et validee ; taches Phase 0 cochees ; resume des dependances nettoye.
- `_contexte/signals.md`, `_contexte/contexte.md`, `README.md` : etat courant aligne sur la validation complete de la Phase 0 et sur la conservation de la taille actuelle des sprites player.
- `game_art/backlog_art.md`, `docs/process_generation_sprites.md` : convention de taille player realignee sur la taille actuelle validee en jeu.

### Corrige
- `game/scripts/inventory.gd` : retire du depot apres migration vers `RunState`.
- `game/tests/test_run_state.gd`, `game/tests/test_meta_state.gd`, `game/tests/test_save_manager.gd` : typage/robustesse ajustes pour execution GUT verte sous Godot 4.5.
- `game/addons/gut/godot_singletons.gd`, `game/addons/gut/stub_params.gd`, `game/addons/gut/warnings_manager.gd` : compatibilite/robustesse ajustee pour l'execution des tests sur l'environnement courant.

## v1.26 - 2026-07-06

### Modifie
- `game_art/roadmap_editeur.md` : sections "Articulation avec la zone jeu", "Perimetre" (hors perimetre explicite : tilesets, parallax, shaders cicatrices, icones UI), "Regle de synchronisation du manifest" et "Apres Phase 5 : maintenance" ajoutees ; "Fait quand" de la Phase 5 ancre sur l'entree "Sprites player".
- `game_art/backlog_art.md` : regle de synchronisation manifest/backlog ajoutee aux Regles ; entree "Sprites player" enrichie (lien avec la Phase 5 editeur, contradiction de taille 40x56/48x56 vs 14x24 signalee comme a trancher).

## v1.25 - 2026-07-06

### Ajoute
- `questions.md` (racine) : 77+1 questions de conception v3 tranchees — structure du run (multi-biomes, HUB inclus), mecaniques joueur (4 slots equipement, armes a distance, mobilite), cicatrices (5 definitives + planchers durs), generation de biomes, craft/economie (27 recettes definitives, bareme PC, tiers etablis), ennemis/boss (archetypes, fiches d'attaques, mirror.json), UI/UX, narration, audio, technique et processus. Nouvelle source de verite pour tout arbitrage de conception.

### Modifie
- `roadmap.md` : section "Decisions verrouillees" ajoutee, mise a jour ciblee des phases 0 a 10 et des risques transverses pour refleter les decisions de `questions.md` (notamment : timing de `RunState.reset()` corrige, planchers de cicatrices obligatoires, un seul Gardien du Voile au lancement).
- `docs/v3/CoreDive Challenge — Design Document v3.md`, `docs/v3/CoreDive Challenge — Système de Progression, Craft, Mort et Résurrection.md`, `docs/v3/CoreDive Challenge — Refonte de la Structure des Biomes.md`, `docs/v3/CoreDive Challenge — Le Noyau et le Boss Final Adaptatif.md` : sections "Precisions v3.1" ajoutees, contradictions historiques corrigees (rarete/biomes, scope du Miroir, escalade des Gardiens).
- `game_art/backlog_art.md` : aligne sur `questions.md` — correction critique (2-3 Gardiens du Voile -> 1 seul au lancement), entrees enrichies et nouvelles entrees ajoutees (equipement, armes a distance, mobilite, overlay d'obscurite, UI de fin de projet).

## v1.24 - 2026-07-06

### Ajoute
- `game_art/editeur/test_reference_preview.gd` : validation headless de la preview de reference et du zoom synchronise.
- `game_art/editeur/test_specs_export.gd` : validation headless de l'export `specs/<entity>.md`.
- `game_art/README.md` : documentation d'usage du flux editeur, audit, specs et sync.

### Modifie
- `game_art/editeur/main.gd` : export `audit_report.md` structure, preview produit/reference cote a cote et export de fiches `specs/<entity>.md`.
- `game_art/editeur/test_audit_ui.gd` : controle du nouveau format de rapport d'audit.
- `game_art/audit_report.md`, `game_art/roadmap_editeur.md`, `game_art/_contexte/`, `README.md` : etat phase 5, documentation et contexte alignes sur l'implementation reelle.

## v1.23 â€” 2026-07-05

### AjoutÃ©
- `game_art/data/manifest.json` : rÃ©fÃ©rentiel d'audit structurÃ© par Ã©tat avec tailles cibles validÃ©es.
- `game_art/editeur/audit.gd` : moteur d'audit dÃ©tectant Ã©tats manquants, sprites manquants/orphelins, tailles incohÃ©rentes, indices hors grille et placeholders.
- `game_art/editeur/test_audit.gd` et `game_art/editeur/test_audit_ui.gd` : validations headless du moteur d'audit, de la sÃ©lection UI et de l'export.
- `game_art/audit_report.md` : premier rapport d'audit exportÃ© depuis l'Ã©diteur.

### ModifiÃ©
- `game_art/editeur/main.gd` : vue audit intÃ©grÃ©e via dialogue, tri par sÃ©vÃ©ritÃ©, navigation cliquable vers entitÃ©/Ã©tat et export Markdown.
- `game_art/roadmap_editeur.md`, `game_art/_contexte/`, `README.md` : Ã©tat Phase 4 alignÃ© sur l'implÃ©mentation rÃ©elle et prochaine Ã©tape recentrÃ©e sur l'enrichissement de l'export.

## v1.22 â€” 2026-07-05

### ModifiÃ©
- `game_art/roadmap_editeur.md` : Phase 3.3 validÃ©e aprÃ¨s tests manuels de bout en bout.
- `game_art/data/animations.json` et `game/data/animations.json` : `player.run.fps` conservÃ© Ã  8.1 aprÃ¨s validation utilisateur.
- `README.md` et contexte `game_art` : Ã©tat actuel mis Ã  jour vers Phase 4.

### CorrigÃ©
- `game_art/editeur/main.gd` : layout preview/inspecteur responsive en demi-Ã©cran et `_update_title()` robuste en test headless.
- `game_art/editeur/inspector.gd` : panneau droit compact, sans dÃ©pendance au scroll horizontal.

## v1.21 â€” 2026-07-05

### AjoutÃ©
- `game_art/editeur/inspector.gd` : panneau d'Ã©dition des Ã©tats d'animation (fps, loop, offset, frame_size, frames) avec rechargement live de la preview (Phase 3.1 de `game_art/roadmap_editeur.md`).
- Sauvegarde Ã©diteur : bouton + Ctrl+S, Ã©criture atomique (`.tmp` + rename), indicateur de modifications non sauvÃ©es dans le titre de fenÃªtre (Phase 3.2).
- `game_art/editeur/test_save_roundtrip.gd` : script de vÃ©rification headless (Godot `--headless --script`) pour tester la sauvegarde sans interaction souris/clavier.

### CorrigÃ©
- `game_art/editeur/main.gd` : `JSON.stringify` appelÃ© sans `sort_keys=false` rÃ©ordonnait alphabÃ©tiquement tout `animations.json` Ã  chaque sauvegarde, rendant les diffs Git illisibles â€” corrigÃ©.

### ModifiÃ©
- `game_art/data/animations.json` : normalisation ponctuelle du format (arrays courts multi-lignes, nombres en float) suite au fix ci-dessus ; aucune valeur mÃ©tier changÃ©e.

## v1.20 â€” 2026-07-05

### CorrigÃ©
- `game_art/editeur/main.gd` : bug de zoom de l'Ã©diteur d'animations â€” `SubViewportContainer.stretch = true` sans `stretch_shrink` rÃ©glÃ© faisait que le `SubViewport` interne se redimensionnait Ã  la taille du container au lieu de garder sa rÃ©solution native zoomÃ©e, rendant le sprite minuscule Ã  l'Ã©cran. Fix : `stretch_shrink = int(z)` dans `_set_zoom`.

### ValidÃ©
- Phase 2.3 de `game_art/roadmap_editeur.md` (comparaison visuelle jeu/Ã©diteur via `run_edit_game.py`) confirmÃ©e par l'utilisateur â€” Phase 2 game_art intÃ©gralement close.

## v1.19 â€” 2026-07-03

### AjoutÃ©
- `run_edit_game.py` : lance jeu + Ã©diteur cÃ´te Ã  cÃ´te (gauche/droite, plein Ã©cran partagÃ©) pour la comparaison visuelle Phase 2.3 de `game_art`.

### ModifiÃ©
- `run.py` renommÃ© en `run_game.py` (clarifie le rÃ´le face Ã  `run_editeur.py`/`run_edit_game.py`). Toutes les rÃ©fÃ©rences documentaires mises Ã  jour.

### CorrigÃ©
- Dette bloquante Phase 0 : 3 appels rÃ©siduels Ã  l'autoload supprimÃ© `Inventory` migrÃ©s vers `RunState` (`ore_node.gd`, `enemy_base.gd`, `boss.gd`). Validation complÃ¨te (GUT, run manuel intÃ©gral) restant Ã  faire.
- `ore_node.gd`/`workbench.gd` : `preload()` sur PNG sans `.import` gÃ©nÃ©rÃ© (crash au dÃ©marrage d'une partie) remplacÃ© par chargement runtime `Image.load_from_file`.
- `game_art` : sprite `player_idle_v2.png` redimensionnÃ© (40x56 â†’ 14x24) pour cohÃ©rence d'Ã©chelle avec `run`/`jump` ; offsets associÃ©s corrigÃ©s.
- `game/project.godot` : fenÃªtre en mode fenÃªtrÃ© (`window/size/mode=0`) au lieu de plein Ã©cran.
- `sync.py` : exclusion de `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json` de la copie vers `game/`.
