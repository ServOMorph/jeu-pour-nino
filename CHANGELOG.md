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
