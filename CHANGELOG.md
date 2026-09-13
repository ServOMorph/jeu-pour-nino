## v1.66 - 2026-09-13

### Ajoute
- `game_art/assets/concept/` : références techniques multi-vues et vue de face du personnage pour la reconstruction 3D.
- `game_art/models/run_sf3d_local.py` et `game_art/models/sf3d_player_v1/` : génération locale Stable Fast 3D et export GLB texturé validé dans Blender.

### Modifie
- `_contexte/` et `README.md` : état du workflow 3D aligné sur la base SF3D livrée et la passe de réalisme prévue.

## v1.65 - 2026-09-13

### Ajoute
- `game_art/models/` : prototypes 3D, base humaine MPFB2, rendus de controle et script reproductible de generation de personnage.
- `.claude/memory.md` : workflow 3D durable base sur references multi-vues puis generation image-vers-3D.

### Modifie
- `_contexte/` et `README.md` : prototypes 3D declares non integres et prochaine etape de production documentee.
- `.claude/commands/close.md` : verification et desactivation du MCP Blender pendant la cloture.

## v1.64 - 2026-09-13

### Ajoute
- `game_art/tools/stabilize_generated_animation.py` : detourage chroma/alpha, echelle uniforme, alignement au sol, assembly de sheet et rapport de controle pour les candidats `player/run`.

### Modifie
- `game_art/assets/generated_raw/player/run_generated_16_v1/` : premier lot ImageGen complet de 16 frames, normalise et audite ; rejete visuellement, non integre.
- `_contexte/` et `README.md` : etat de la refonte `player/run` et autorisation utilisateur de stabilisation geometrique limites aux candidats documentes.

## v1.63 - 2026-09-13

### Modifie
- `_contexte/` et `README.md` : reprise de la refonte complete de `player/run` confiee a Astra pour la prochaine session ; essais ImageGen et WanGP enregistres comme non integrables.

## v1.61 - 2026-08-02

### Ajoute
- Outils locaux de controle OpenPose/SD1.5, reconstruction TripoSR, rig UniRig, sondes Flux et generation Wan2.2-Animate pour la refonte complete de `player/run`.
- Reference maitre validee et sources/candidats d'audit conserves sous `game_art/assets/generated_raw/player/` sans remplacement de la sheet runtime.

### Modifie
- `game_art/_contexte/`, `game_art/roadmap_editeur.md` et `game_art/README.md` : Phase 7 passee `en_cours`, execution locale Wan2.2-Animate 14B INT8 validee materiellement, candidats actuels rejetes et pivot suivant fixe au mode remplacement avec controle pre-normalise.

## v1.59 - 2026-07-14

### Ajoute
- `game/scripts/game_flow.gd` (autoload `GameFlow`) : flux de run centralise - `next_biome_id`, `start_run()` (seul point de `RunState.reset()`), `enter_biome()`, `return_to_hub()`, `end_run()`.
- `game/scenes/levels/hub.tscn`, `game/scripts/hub.gd`, `game/data/hub.json` : HUB jouable (4 portails dont 3 verrouilles, stele Grimoire, etabli tier 1, soin complet a l'entree, decor `hub_decor.png` integre).
- `game/scripts/hub_portal.gd` : interaction generique (portails du HUB, stele Grimoire, portail de sortie volontaire de biome).
- `game/scripts/biome_cleared.gd` : ecran bref de retour au HUB apres victoire sur un boss de biome.
- `game/tests/test_game_flow.gd` : 9 tests (chargement du biome, reset unique par run, revisite comptee une fois, conservation de l'etat sur aller-retour HUB/biome, PC de fin de run).

### Modifie
- `game/scripts/level.gd` : biome parametre par `GameFlow` au lieu d'une config fixe, boss non respawne s'il est deja vaincu dans le run, transitions vers le HUB.
- `game/scripts/run_state.gd` : `visited_biomes` / `defeated_bosses` et leur API ; `player.gd` : `heal_full()` ; `hud.gd` : boss optionnel ; `title.gd` / `end_screen.gd` : transitions via `GameFlow` (plus de `quit()` ni de `reload_current_scene()`).
- `game/data/level.json` -> `game/data/biomes/biome1.json` ; `game/scenes/levels/biome1.tscn` -> `biome.tscn` (scene generique pilotee par `GameFlow`).
- `roadmap.md`, `README.md`, `_contexte/` : Phase 3 livree cote code, validation en jeu du jalon J1 reportee a la prochaine session.

## v1.58 - 2026-07-14

### Modifie
- `game_art/assets/tiles/biome1_parallax_far.png`, `biome1_parallax_mid.png` et `biome1_parallax_fore.png` : passe decor/parallax biome 1 precomposee en grandes bandes `12800x1080` pour attenuer les jonctions visibles en runtime.
- `game_art/assets/generated_raw/biome1/` : sources brutes et versions detourees conservees pour la reprise du biome 1.
- `game_art/_contexte/contexte.md`, `game_art/_contexte/signals.md`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : validation visuelle de la passe biome 1 notee, avec entree backlog maintenue `en_cours` tant que la geometrie coloree reste visible.

## v1.57 - 2026-07-13

### Modifie
- `game_art/assets/player/player_attack_sheet.png`, `game_art/data/animations.json` et `game/data/animations.json` : `player/attack` elargi en cases `150x150` sans retouche des pixels source, puis realigne cote runtime.
- `game_art/_contexte/contexte.md`, `game_art/_contexte/signals.md`, `game_art/roadmap_editeur.md` et `game_art/backlog_art.md` : maintenance player closee sur l'etat reel, avec `player/run` et `player/jump` resynchronises puis valides en jeu.

## v1.56 - 2026-07-13

### Modifie
- `game_art/_contexte/contexte.md`, `game_art/_contexte/signals.md` et `game_art/roadmap_editeur.md` : suivi de maintenance realigne sur l'etat reel, avec validations editeur acquises pour `player/jump`, `player/run`, `enemy_ground/walk` et `enemy_flyer/fly`, et ecart runtime `game/` explicite sur `player/run` et `player/jump`.
- `game_art/backlog_art.md` : notes de maintenance player et mobs standard mises a jour pour refleter les validations editeur actuelles et la resynchronisation encore attendue cote `game/`.

## v1.55 - 2026-07-12

### Modifie
- `game_art/assets/player/player_jump_sheet.png`, `game_art/data/animations.json` et `game_art/specs/player.md` : `player/jump` regenere en sheet `3` frames et integre au runtime de l'editeur.
- `game_art/assets/player/player_run_sheet.png`, `game_art/data/manifest.json` et `game_art/editeur/test_specs_export.gd` : `player/run` reconditionne en cases `104x150` pour redonner de la marge a `Editer sheet`, sans changer les poses.
- `game_art/_contexte/`, `game_art/roadmap_editeur.md` et `game_art/backlog_art.md` : protocole de maintenance aligne sur ce nouveau state player.

## v1.54 - 2026-07-12

### Ajoute
- `game_art/editeur/sheet_editor.gd`, `sheet_editor_canvas.gd`, `path_utils.gd` : bouton `Editer sheet` dans l'editeur, ajustement manuel (redimensionnement uniforme + deplacement, apercu temps reel) d'une frame contrainte a sa case, avec reecriture atomique du PNG source a la validation.
- `game_art/editeur/test_sheet_editor.gd` : test headless de roundtrip PNG reel pour cette fonctionnalite.

### Modifie
- `game_art/editeur/main.gd`, `animation_driver.gd` : branchement du bouton et de son etat actif/inactif, delegation de la traduction de chemin vers `path_utils.gd`.
- `game_art/README.md`, `game_art/roadmap_editeur.md` : documentation de la fonctionnalite, du nouveau test, et nuance de l'objectif de l'editeur (ajustement geometrique manuel autorise, refonte artistique pixel par pixel toujours exclue).

## v1.53 - 2026-07-12

### Modifie
- `game_art/_contexte/signals.md`, `game_art/_contexte/contexte.md`, `game_art/roadmap_editeur.md` et `game_art/backlog_art.md` : fermeture de session alignee sur les nouveaux cycles mobs et sur la validation metrique encore ouverte.
- `game_art/assets/enemies/enemy_ground.png`, `enemy_flyer.png`, `enemy_ground_walk_sheet.png`, `enemy_flyer_fly_sheet.png` et copies `game/assets/sprites/enemies/` : ids mobs regeneres et nouvelles sheets de deplacement branchees en runtime.
- `game_art/data/animations.json`, `game/data/animations.json`, `game_art/specs/enemy_ground.md` et `game_art/specs/enemy_flyer.md` : etats `walk`/`fly` des mobs standard branches en sheets candidates, avec fiches regenerees.

## v1.52 - 2026-07-12

### Modifie
- `game_art/assets/enemies/enemy_ground.png`, `enemy_flyer.png` et copies `game/assets/sprites/enemies/` : sprites des mobs standards regeneres en x2 ; boss inchange.
- `game_art/data/animations.json`, `game_art/data/manifest.json`, `game_art/specs/enemy_ground.md` et `game_art/specs/enemy_flyer.md` : gabarits runtime des mobs portes a `128x128` et `112x80`.
- `game/scenes/enemies/enemy_ground.tscn` et `enemy_flyer.tscn` : collisions et hurtboxes doublees pour suivre les nouveaux visuels.
- `docs/process_generation_sprites.md` : tailles cibles des mobs mises a jour.

### Ajoute
- `game_art/assets/enemies/enemy_ground_walk_sheet.png` et `game_art/assets/generated_raw/enemy_ground_walk_*` : premiere animation multi-frames de deplacement du mob au sol regeneree via frames separees, detourage, normalisation automatique et sheet candidate.

### Corrige
- `game_art/assets/enemies/enemy_ground.png` et `game_art/assets/generated_raw/enemy_ground_idle_regen_*` : sprite `idle` du mob au sol regenere pour suivre le style, les proportions et le gabarit des nouvelles frames de marche.
- `game_art/assets/enemies/enemy_flyer.png` et `game_art/assets/generated_raw/enemy_flyer_idle_regen_*` : sprite `idle` du flyer regenere et realigne sur son gabarit runtime `112x80`.

### Ajoute
- `game_art/assets/enemies/enemy_flyer_fly_sheet.png` et `game_art/assets/generated_raw/enemy_flyer_fly_*` : premiere animation multi-frames de deplacement du mob volant regeneree via frames separees, detourage, normalisation automatique et sheet candidate.

## v1.51 - 2026-07-12

### Ajoute
- `game_art/commands/generation_animation.md` et `game_art/tools/normalize_animation_frames.py` : workflow retenu pour les animations multi-frames, avec generation par frames separees, detourage, normalisation automatique controlee et production d'une sheet candidate.

### Modifie
- `game_art/assets/player/player_run_sheet.png`, `game_art/data/animations.json` et `game_art/specs/player.md` : animation `player/run` regeneree en 8 frames, branchee dans l'editeur puis synchronisee vers le jeu.
- `game_art/_contexte/`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : contexte de maintenance realigne sur le nouveau workflow de regeneration d'animation retenu.

## v1.50 - 2026-07-12

### Modifie
- `.claude/memory.md` : bindings manette completes (`use_item`, `sprint`, `pause_menu`) ; entree "Risques animation v2.1" purgee des dimensions pixel art obsoletes (14x24/40x56/48x56).
- `game_art/backlog_art.md` : nouvelle entree "Script de rescale ref_to_sprite.py" - dernier residu pixel art identifie hors perimetre jeu.

### Verifie
- Audit du pivot pixel art -> 2D standard : aucune trace active du design/tailles pixel art restante cote jeu (docs, editeur, sprites), hors outillage `ref_to_sprite.py` deja trace comme dette game_art.

## v1.49 - 2026-07-12

### Ajoute
- `game/scripts/recipe_catalog.gd` : `discover_by_trigger()`, branche depuis `level.gd._on_boss_died()` — decouverte automatique des recettes non-starter a la victoire du boss.

### Corrige
- `tests_manuels.md` : diagnostic du point 8.6 (selection de consommable) - comportement correct, pas un bug ; validation manuelle complete de la Phase 2 (sections 1-9, aucune anomalie).

## v1.48 - 2026-07-12

### Modifie
- `game_art/editeur/main.gd` : evenements joypad bloques dans l'editeur pour imposer un pilotage souris uniquement.
- `game_art/_contexte/` et `game_art/roadmap_editeur.md` : contexte de maintenance realigne sur un editeur sans controles manette.

## v1.47 - 2026-07-11

### Corrige
- `game/scripts/equipment_menu.gd` : bug de compilation (`SLOT_ORDER` non typé cassait `level.gd`) ; affichage retravaille (nom lisible au lieu de l'id brut, marqueur consommable actif).
- `game/scripts/title.gd` : hint manette obsolete supprime, menu dev reformate pour tenir dans la fenetre 1920x1080.

### Ajoute
- `tests_manuels.md` (racine) : suivi detaille et numerote de la validation manuelle du flux Phase 2.

## v1.46 - 2026-07-11

### Corrige
- `game_art/editeur/main.gd` et `game_art/editeur/test_preview_center.gd` : preview du boss rendue a la resolution affichee, avec cadrage proportionnel et filtrage lineaire aligne sur le jeu.
- `game_art/assets/`, `game/assets/sprites/` et `sync.py` : sprites orphelins, doublons et images de test retires ; les archives player sont exclues de la synchronisation runtime.

## v1.45 - 2026-07-11

### Modifie
- `game_art/assets/player/player_attack_up_sheet.png` et `game_art/assets/generated_raw/player/attack_up_regen_*` : `player/attack_up` regenere completement pour corriger la frame `0.0` incoherente.
- `game_art/assets/tiles/hub_decor.png`, `game_art/assets/generated_raw/hub_decor_raw.png`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : decor du HUB produit en `1920x1080` et backlog game_art aligne sur sa livraison.
- `game_art/assets/objects/workbench.png`, `game_art/assets/generated_raw/workbench_raw.png`, `game/scripts/workbench.gd` et `game/data/level.json` : atelier regenere en plus grand format (`160x144`) avec runtime realigne.
- `game_art/_contexte/` : contexte de maintenance realigne sur la validation acquise des attaques directionnelles et de `idle`, avec `player/attack` et `Recharger` encore ouverts.

## v1.44 - 2026-07-10

### Modifie
- `game_art/assets/player/player_attack_up_sheet.png`, `player_attack_down_sheet.png`, `player_attack_up_diag_sheet.png` et `player_attack_down_diag_sheet.png` : 4 attaques directionnelles du player regenerees integralement depuis de nouvelles frames sources.
- `game_art/assets/generated_raw/player/attack_*_regen_f*_raw.png`, `game_art/data/animations.json` et `game/data/animations.json` : sources brutes conservees et lectures runtime des 4 attaques directionnelles alignees sur `0,1,2,3,3,3,2,1,0`.
- `game_art/_contexte/`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : contexte de maintenance realigne sur la validation visuelle restante des attaques directionnelles, puis de `idle` et `attack`.

## v1.43 - 2026-07-10

### Modifie
- `game_art/assets/player/player_idle_sheet.png`, `game_art/data/animations.json` et `game/data/animations.json` : etat `player/idle` refait en 6 frames, cadence a `5 fps`, avec lecture runtime `0,1,2,3,5` pour exclure la frame `4.0` decalee.
- `game_art/assets/generated_raw/player/player_idle_6f_raw.png`, `game_art/specs/player.md` et `game_art/specs/boss.md` : source brute idle et exports de specs realignes sur l'etat courant.
- `game_art/_contexte/`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : contexte de maintenance realigne sur la validation restante de `player/idle` puis `player/attack`.

## v1.42 - 2026-07-09

### Modifie
- `game_art/editeur/main.gd` et `game_art/editeur/inspector.gd` : clic sur frame branche sur la preview et bouton `Recharger` ajoute pour relire assets et `animations.json` sans relance Godot.
- `game_art/assets/player/player_attack_sheet.png`, `game_art/data/animations.json` et `game/data/animations.json` : etat `player/attack` regenere depuis une frame de reference et sequence de lecture changee en `0,1,2,3,3,3,2,1,0`.
- `game_art/_contexte/`, `game_art/roadmap_editeur.md` et `game_art/backlog_art.md` : contexte de maintenance aligne sur la regeneration complete de `attack` et sur le flux `Recharger`.

## v1.41 - 2026-07-09

### Modifie
- `game_art/assets/player/legacy_archive/`, `game_art/editeur/audit.gd`, `game_art/editeur/test_audit.gd` et `game_art/audit_report.md` : anciens PNG player archives et exclus de l'audit.
- `game_art/assets/objects/ore_*.png`, `game/data/materials.json` et copies `game/assets/sprites/objects/` : set dedie des gisements complete et branche sans fallback cuivre.
- `game_art/assets/enemies/boss_guardian_ashes.png`, `boss_guardian_ashes_pause.png`, `boss_projectile_ash.png`, `game_art/data/animations.json` et branchements runtime cote `game/` : Veilleur des Cendres livre avec pose vulnerable et projectile dedie.
- `game_art/_contexte/`, `game_art/backlog_art.md` et `game_art/roadmap_editeur.md` : contexte et phase de maintenance realignes sur les livrables reels de la session.

## v1.40 - 2026-07-08

### Ajoute
- `game/scripts/recipe_catalog.gd`, `game/scripts/grimoire_menu.gd`, `game/scripts/equipment_menu.gd` : helper recettes et ecrans Phase 2 branches (Grimoire via menu dev, equipement via pause).

### Modifie
- `game/data/recipes.json`, `game/data/weapons.json`, `game/data/armor.json`, `game/data/consumables.json` : socle donnees Phase 2 aligne sur le schema cible et la table de 27 recettes.
- `game/scripts/meta_state.gd`, `game/scripts/run_state.gd`, `game/scripts/craft_menu.gd`, `game/scripts/player.gd`, `game/scripts/pause_menu.gd`, `game/scripts/level.gd`, `game/scripts/title.gd`, `game/scripts/hud.gd`, `game/scripts/workbench.gd` : Grimoire, maitrise avec cout PC, equipement manuel, consommable actif et filtrage craft branches.
- `game/tests/test_meta_state.gd`, `game/tests/test_run_state.gd`, `game/tests/test_save_manager.gd`, `_contexte/signals.md`, `_contexte/contexte.md`, `roadmap.md`, `README.md` : tests et contexte realignes sur un socle Phase 2 branche mais encore en attente de validation manuelle urgente.

## v1.39 - 2026-07-08

### Modifie
- `_contexte/signals.md`, `_contexte/contexte.md` et `README.md` : etat projet aligne sur la validation effective de la migration resolution 1920x1080 et sur l'ouverture de la Phase 2.
- `docs/process_generation_sprites.md`, `docs/workflow_image_gen_fable5.md`, `docs/charte_graphique_pixel_art_dark_fantasy.md` : documentation active reorientee vers la 2D standard et le pipeline `Codex + rescale`.
- `docs/Document de conception — Jeu pixel art run court & challenge.md`, `docs/v3/CoreDive Challenge — Design Document v3.md`, `docs/profi joueur nino.md`, `docs/prompt_lancememnt_opus.txt`, `game_art/backlog_art.md`, `game_art/roadmap_editeur.md` : mentions historiques clarifiees et specs/portee alignees sur la direction visuelle actuelle.

## v1.38 - 2026-07-08

### Ajoute
- `game_art/assets/player/player_*_sheet.png` : sheets runtime ajoutes pour tous les etats player, y compris les 5 directions d'attaque.

### Modifie
- `game_art/data/animations.json` et `game/data/animations.json` : player migre a 100% vers `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
- `game_art/editeur/test_specs_export.gd`, `game_art/editeur/test_audit_ui.gd`, `game_art/specs/player.md`, `game_art/audit_report.md`, `game_art/_contexte/`, `game_art/roadmap_editeur.md` et `game_art/backlog_art.md` : tests, exports et contexte alignes sur la migration complete du format player.

## v1.37 - 2026-07-07

### Corrige
- `game_art/editeur/main.gd` : panneau `Reference` retire et centrage de la preview `Produit` corrige par positionnement explicite de la texture de frame.
- `game_art/editeur/test_preview_center.gd` : test headless ajoute pour couvrir le centrage de la preview.
- `game_art/data/manifest.json` : etats d'attaque player directionnels ajoutes avec taille cible `129x150`.

### Modifie
- `game_art/README.md`, `game_art/roadmap_editeur.md`, `game_art/_contexte/` : documentation alignee sur le workflow sans panneau `Reference`.

## v1.36 - 2026-07-07

### Modifie
- `game_art/assets/player/` et `game/assets/sprites/player/` : set d'attaque player etendu en 5 directions (`droite`, `haut-droite`, `bas-droite`, `haut`, `bas`) avec frames de transition et impacts prolonges.
- `game_art/data/animations.json`, `game/data/animations.json` et `game/scripts/player.gd` : selection d'etat d'attaque selon le stick droit, rotation de hitbox associee, et ordre des frames ajuste pour tenir l'impact final plus longtemps.
- `game_art/_contexte/`, `game_art/backlog_art.md`, `game_art/roadmap_editeur.md`, `game_art/specs/player.md` : contexte de phase 5 aligne sur un set d'attaque multi-direction encore legacy mais deja reglable dans l'editeur.

## v1.35 - 2026-07-07

### Modifie
- `game_art/assets/enemies/boss_guardian.png`, `enemy_ground.png`, `enemy_flyer.png` et copies `game/assets/sprites/enemies/` : sprites boss et mobs refaits en HD puis redimensionnes aux tailles runtime.
- `game_art/assets/objects/ore_copper_handmade_v2.png`, `ore_copper.png`, `ore_iron.png`, `ore_abyssal.png`, `workbench.png` et copies `game/assets/sprites/objects/` : sprites minerais et atelier refaits puis synchronises.
- `game_art/data/manifest.json` et `game/scenes/enemies/boss.tscn` : tailles ennemies runtime realignees ; boss porte a `389x500` avec collisions associees.
- `game_art/_contexte/`, `game_art/backlog_art.md`, `game_art/roadmap_editeur.md` : contexte de session aligne sur la validation en jeu du set joueur et la reprise de production boss/mobs/objets.

## v1.34 - 2026-07-07

### Modifie
- `game_art/assets/player/` et `game/assets/sprites/player/` : set joueur remplace par de nouveaux sprites HD redimensionnes (`idle`, `run`, `jump`, `attack`), orientes vers la droite et synchronises vers le jeu.
- `game_art/data/animations.json` et `game/data/animations.json` : `player.run.frame_size` passe a `87x150` et `player.attack.offset` revient a `0`.
- `docs/workflow_image_gen_fable5.md`, `docs/process_generation_sprites.md`, `game_art/_contexte/`, `game_art/backlog_art.md`, `game_art/roadmap_editeur.md` : workflow actif de generation/rescale et etat reel de la phase 5 alignes sur la production du set joueur.
- `game_art/editeur/test_audit_ui.gd` et `game_art/editeur/test_specs_export.gd` : attentes mises a jour pour le nouvel etat du player.

### Corrige
- Sprites player : orientation source uniformisee vers la droite, echelle `run`/`jump` rapprochee de `idle`, et attaque reancree avec un sprite compact sans offset vertical artificiel.

## v1.33 - 2026-07-07

### Ajoute
- `plan_graphismes_standard_2d.md` (racine) : plan de pivot pixel art -> graphismes 2D standard. Pipeline retenu : generation d'image via le module Codex puis rescale a la taille de rendu cible. Couvre rendu (project.godot), production/integration des assets, refonte de la zone game_art (editeur, outils, charte, workflow), doc jeu, validation.

### Modifie
- `game/project.godot` : rendu passe en filtre lineaire (`default_texture_filter=1`) et `stretch/mode="canvas_items"` (au lieu de nearest/viewport, adaptes au pixel art) ; description sans "pixel art".
- `roadmap.md`, `questions.md`, `game/README.md`, `README.md` : mentions 480x270/pixel art/grille 16x16 corrigees vers 1920x1080 natif / 2D standard.
- `game_art/backlog_art.md` : entree de handoff "Pivot 2026-07-07" creee pour signaler le pivot a l'agent game_art (specs individuelles a reviser cote game_art).
- Migration resolution 1920x1080 (`plan_resolution_1920x1080.md`, phases A a E transitoire) confirmee appliquee dans le repo (project.godot, JSON gameplay x4, scenes, scripts UI, sprites upscales) ; validation GUT/run manuel restant a faire.

## v1.32 - 2026-07-07

### Ajoute
- `plan_resolution_1920x1080.md` (racine) : plan de migration du viewport de jeu vers 1920x1080 natif (facteur d'echelle monde x4), player idle cible a 150 px (~x6.25). Couvre project.godot, tous les JSON gameplay (px, vitesses, gravite), scenes (collisions), scripts UI programmatiques, sprites (upscale transitoire x6 + production native cote game_art), calibration gameplay post-migration, et validation. Non execute a ce stade.

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
## v1.60 - 2026-08-01

### Ajoute
- `game_art/assets/tiles/biome1_terrain.png` et sa source `game_art/assets/generated_raw/biome1/biome1_terrain_raw.png` : texture rocheuse et vegetale repeteable pour les plateformes des Galeries Verdoyantes.

### Modifie
- `game/scripts/level.gd`, `game/data/biomes/biome1.json` : affichage texture des plateformes configure par biome, sans modification de collision.
- `game_art/backlog_art.md` et `game_art/_contexte/` : livraison du decor runtime du biome 1 enregistree.
## v1.62 - 2026-09-13

### Modifie
- `game_art/assets/tiles/hub_decor_portals_v2.png` : nouveau fond plein ecran du HUB, avec quatre portes accessibles alignees sur la ligne de marche.
- `game/data/hub.json`, `game/scripts/hub.gd`, `game/scripts/hub_portal.gd` : positions du HUB alignees sur ce decor, sol de collision invisible, etabli a droite et suppression des noms/rectangles placeholder des portails.
