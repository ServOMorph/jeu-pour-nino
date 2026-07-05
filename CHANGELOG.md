## v1.23 — 2026-07-05

### Ajouté
- `game_art/data/manifest.json` : référentiel d'audit structuré par état avec tailles cibles validées.
- `game_art/editeur/audit.gd` : moteur d'audit détectant états manquants, sprites manquants/orphelins, tailles incohérentes, indices hors grille et placeholders.
- `game_art/editeur/test_audit.gd` et `game_art/editeur/test_audit_ui.gd` : validations headless du moteur d'audit, de la sélection UI et de l'export.
- `game_art/audit_report.md` : premier rapport d'audit exporté depuis l'éditeur.

### Modifié
- `game_art/editeur/main.gd` : vue audit intégrée via dialogue, tri par sévérité, navigation cliquable vers entité/état et export Markdown.
- `game_art/roadmap_editeur.md`, `game_art/_contexte/`, `README.md` : état Phase 4 aligné sur l'implémentation réelle et prochaine étape recentrée sur l'enrichissement de l'export.

## v1.22 — 2026-07-05

### Modifié
- `game_art/roadmap_editeur.md` : Phase 3.3 validée après tests manuels de bout en bout.
- `game_art/data/animations.json` et `game/data/animations.json` : `player.run.fps` conservé à 8.1 après validation utilisateur.
- `README.md` et contexte `game_art` : état actuel mis à jour vers Phase 4.

### Corrigé
- `game_art/editeur/main.gd` : layout preview/inspecteur responsive en demi-écran et `_update_title()` robuste en test headless.
- `game_art/editeur/inspector.gd` : panneau droit compact, sans dépendance au scroll horizontal.

## v1.21 — 2026-07-05

### Ajouté
- `game_art/editeur/inspector.gd` : panneau d'édition des états d'animation (fps, loop, offset, frame_size, frames) avec rechargement live de la preview (Phase 3.1 de `game_art/roadmap_editeur.md`).
- Sauvegarde éditeur : bouton + Ctrl+S, écriture atomique (`.tmp` + rename), indicateur de modifications non sauvées dans le titre de fenêtre (Phase 3.2).
- `game_art/editeur/test_save_roundtrip.gd` : script de vérification headless (Godot `--headless --script`) pour tester la sauvegarde sans interaction souris/clavier.

### Corrigé
- `game_art/editeur/main.gd` : `JSON.stringify` appelé sans `sort_keys=false` réordonnait alphabétiquement tout `animations.json` à chaque sauvegarde, rendant les diffs Git illisibles — corrigé.

### Modifié
- `game_art/data/animations.json` : normalisation ponctuelle du format (arrays courts multi-lignes, nombres en float) suite au fix ci-dessus ; aucune valeur métier changée.

## v1.20 — 2026-07-05

### Corrigé
- `game_art/editeur/main.gd` : bug de zoom de l'éditeur d'animations — `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé faisait que le `SubViewport` interne se redimensionnait à la taille du container au lieu de garder sa résolution native zoomée, rendant le sprite minuscule à l'écran. Fix : `stretch_shrink = int(z)` dans `_set_zoom`.

### Validé
- Phase 2.3 de `game_art/roadmap_editeur.md` (comparaison visuelle jeu/éditeur via `run_edit_game.py`) confirmée par l'utilisateur — Phase 2 game_art intégralement close.

## v1.19 — 2026-07-03

### Ajouté
- `run_edit_game.py` : lance jeu + éditeur côte à côte (gauche/droite, plein écran partagé) pour la comparaison visuelle Phase 2.3 de `game_art`.

### Modifié
- `run.py` renommé en `run_game.py` (clarifie le rôle face à `run_editeur.py`/`run_edit_game.py`). Toutes les références documentaires mises à jour.

### Corrigé
- Dette bloquante Phase 0 : 3 appels résiduels à l'autoload supprimé `Inventory` migrés vers `RunState` (`ore_node.gd`, `enemy_base.gd`, `boss.gd`). Validation complète (GUT, run manuel intégral) restant à faire.
- `ore_node.gd`/`workbench.gd` : `preload()` sur PNG sans `.import` généré (crash au démarrage d'une partie) remplacé par chargement runtime `Image.load_from_file`.
- `game_art` : sprite `player_idle_v2.png` redimensionné (40x56 → 14x24) pour cohérence d'échelle avec `run`/`jump` ; offsets associés corrigés.
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) au lieu de plein écran.
- `sync.py` : exclusion de `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json` de la copie vers `game/`.

### Modifié
- `game_art/editeur/main.gd`, `game_art/editeur/animation_driver.gd` : infos de frame, fond damier, état play/pause visible, placeholder magenta pour texture manquante (Phase 2.2 de `game_art/roadmap_editeur.md`).

## v1.18 — 2026-07-03

### Corrigé
- `game_art/editeur/main.gd` : rendu gris de l'éditeur résolu — `class_name AnimationDriverEditor`
  (non résolu sans cache `.godot/`) remplacé par `preload()` + typage sur le script préchargé.
- `game_art/editeur/main.gd` : chevauchement des panneaux galerie/inspecteur résolu —
  `HSplitContainer` unique à 3 enfants (non supporté) remplacé par deux `HSplitContainer` imbriqués.

## v1.17 — 2026-07-02

### Modifié
- `roadmap.md` : détaillée intégralement pour implémentation directe — carte du code (autoloads, fichiers/lignes clés, schéma JSON actuel), schémas JSON cibles par phase, choix d'implémentation tranchés (génération biome 1 réutilisant le format `level.json` ; persistance de biome à la résurrection via scène conservée en mémoire). Scope et ordre des phases inchangés.
- `game_art/roadmap_editeur.md` : détaillée de la même façon — état réel des fichiers de l'éditeur, diagnostic priorisé du bug de rendu gris, plan de sauvegarde JSON sûre et spécification de l'audit.

### Corrigé
- Dette bloquante Phase 0 identifiée (non corrigée) : 3 appels résiduels à l'autoload supprimé `Inventory` (`ore_node.gd`, `enemy_base.gd`, `boss.gd`) font crasher le jeu. Documentée en tête de `roadmap.md`.

## v1.16 — 2026-07-02

### Ajouté
- `game_art/backlog_art.md` : backlog des assets à produire par phase, alimenté depuis `roadmap.md`, consommé par les sessions game_art.
- `roadmap.md` : jalons jouables J1 à J7 (une version stable jouable par jalon). Section « Backlog post-v3 » (coupes assumées). Jalon de refacto R1.5 après Phase 4.

### Modifié
- `roadmap.md` : réordonnancement — mort/résurrection/cicatrices (Phases 5-6) remontées avant le contenu des biomes 2/3/4 (Phase 7, étalée 7a/7b/7c) ; R2 déplacé après Phase 7 et étendu aux Gardiens du Voile.
- `roadmap.md` : règle placeholders systématique — aucune phase jeu n'attend game_art, les tâches **[game_art]** alimentent le backlog dédié.
- `roadmap.md` : scope du Miroir du Noyau limité à 2 paramètres (biomes explorés + cicatrices), documenté comme coupe assumée par rapport au design doc (4 paramètres).
- `roadmap.md` : objectif de couverture de tests fixé à 85 % sur la logique data-driven/état, vérifié à chaque jalon de refacto (R1, R1.5, R2, R3).

## v1.15 — 2026-06-30

### Ajouté
- `game/scripts/run_state.gd` : autoload RunState (remplace Inventory, même API + serialize/deserialize).
- `game/scripts/meta_state.gd` : autoload MetaState (grimoire + Points de Compétence, persistant).
- `game/scripts/save_manager.gd` : autoload SaveManager (save/load MetaState vers user://meta_state.json).
- `game/addons/gut/` : GUT v9.7.0 installé.
- `game/tests/` : 20 tests GUT Phase 0 (RunState, MetaState, SaveManager).
- `game/.gut_editor_config.json` : config GUT pointant vers res://tests/.
- `roadmap.md` : coches de suivi ajoutées sur toutes les tâches.

### Modifié
- `game/project.godot` : autoloads Inventory → RunState + MetaState + SaveManager ; GUT activé.
- `game/scripts/player.gd`, `craft_menu.gd`, `hud.gd`, `level.gd` : Inventory → RunState.
- `game/scripts/level.gd` : SaveManager.save_meta() ajouté en fin de run (mort et victoire).
- `roadmap.md` : Phase 0 cochée.

## v1.14 — 2026-06-27

### Ajouté
- `docs/v3/CoreDive Challenge — Design Document v3.md` : design document complet de la v3 (4 biomes, Grimoire/PC, mort-résurrection, cicatrices shaders, boss adaptatif).
- `roadmap.md` : roadmap v3 — 11 phases (0→10), 3 jalons de refacto (R1/R2/R3), stratégie de tests GUT intégrée.

### Décision
- Génération de biomes : templates assemblés (PCG pur écarté).
- v3 = couche méta-structurelle par-dessus le noyau gameplay existant (pas de rewrite).

## v1.13 — 2026-06-27

### Ajouté
- `game_art/editeur/animation_driver.gd` : version éditeur avec remappage de chemin (`_editor_path`).
- `game_art/editeur/main.gd` : UI éditeur programmatique (galerie entités/états, preview SubViewport 200×200, toolbar zoom x1/x3/x6/x8 + playback).
- `game_art/editeur/main.tscn` : scène racine éditeur.
- `game_art/assets/player/player_run_sheet.png` : spritesheet run player 28×24.

### Modifié
- `game/scripts/animation_driver.gd` : support spritesheets via `sheet`+`frame_size`+`frames[]` (AtlasTexture), rétro-compatible PNG.
- `game_art/data/animations.json` : état `run` player migré vers format spritesheet.

## v1.12 — 2026-06-27

### Modifié
- Affichage jeu en plein écran 1920×1080 (`game/project.godot`).
- Contrôles clavier complets ajoutés : flèches (move), Z (attack), E (interact), R (use_item), Shift (sprint), Echap (pause_menu).
- `run.py` : appel automatique de `sync.py` avant lancement Godot.

## v1.11 — 2026-06-27

### Ajouté
- Zone `game_art/` créée : source de vérité des sprites et de `animations.json`.
- `game_art/project.godot` : projet Godot éditeur autonome (res:// = game_art/).
- `sync.py` : synchronise `game_art/assets/` → `game/assets/sprites/` et `animations.json` avant lancement.
- `run.py` : appel automatique de `sync()` avant Godot.
- Contrôles clavier complets ajoutés dans `game/project.godot` (flèches, Z, E, R, Shift, Echap).
- Affichage plein écran 1920×1080 (`game/project.godot`).

## v1.10 — 2026-06-25

### Ajouté
- Driver d'animation partagé `game/scripts/animation_driver.gd` piloté par `game/data/animations.json`.
- Nouvel idle player `player_idle_v2.png` intégré pour test qualité.

### Modifié
- Direction visuelle personnages recalée vers un standard type Terraria avec player cible `40x56`.
- `docs/process_generation_sprites.md`, `roadmap.md`, `README.md` et `_contexte/` mis à jour pour refléter le chantier animation.
- Flip gauche/droite du player corrigé et scènes player/mobs/boss branchées sur le nouveau pipeline d'animation.

## v1.9 — 2026-06-25

### Ajouté
- Charte graphique pixel art dark fantasy et process de génération de sprites un par un.
- Sprites pixel art intégrés pour joueur, ennemis, boss, établi, minerais, icônes et tiles.
- Menu pause en jeu sur Start/Menu avec reprendre, recommencer, quitter et mode dev runtime.
- Option `FERMER LE JEU` dans le menu de défaite.

### Modifié
- Sprites recalés à la taille des anciens rectangles/carrés et alignés visuellement au sol.
- L'option `QUITTER` du menu pause ferme maintenant le programme.
- `_contexte/` et README.md mis à jour pour la clôture.

---

## v1.8 — 2026-06-25

### Ajouté
- Mode dev : toggle `VIE INF` dans le menu, relié à `Dev.infinite_hp`.
- Collisions physiques entre joueur et mobs.

### Modifié
- v2.1 marquée validée après playtest complet.
- Respawn des mobs volants corrigé et quantité de flyers réduite.
- Sprint aérien : un saut lancé en sprint conserve la vitesse rapide.
- README.md, roadmap.md et `_contexte/` mis à jour pour la clôture.

---

## v1.7 — 2026-06-25

### Ajouté
- Potions de soin empilables, monnaie de run affichée dans le HUD, sprint au clic stick gauche, respawn des mobs.
- Roadmap active v2.1 et archive de l'ancienne roadmap v2.

### Modifié
- Difficulté générale augmentée : densité de mobs, stats ennemis, boss plus exigeant.
- Spawn atelier en mode dev avec ennemis.
- README.md, roadmap.md et _contexte/ mis à jour pour la clôture v2.1.

### Corrigé
- Mobs volants : clé de configuration explicite pour récupérer correctement la récompense d'or.

---

## v1.6 — 2026-06-25

### Ajouté
- `game/data/level.json` : dimensions, couleurs, plateformes, spawns, ennemis, minerais, établi, boss et porte d'arène externalisés.

### Modifié
- `game/scripts/level.gd` : chargement des données de niveau depuis `level.json`.
- `game/scripts/title.gd` : mise en page du menu dev corrigée et validée.
- `README.md` et `_contexte/` : état projet mis à jour.

### Validé
- `level.json` parsable et lancement Godot headless OK avec Godot 4.5.

---

## v1.5 — 2026-06-21

### Modifié
- `game/scripts/title.gd` : refonte menu 2 niveaux (accueil / sous-menu dev avec toggle 100 MIN et spawn atelier) + fix double-déclenchement manette
- `game/scripts/craft_menu.gd` : hauteur du panel dynamique (fix chevauchement hint A/B)
- `game/scripts/level.gd` : spawn "atelier" ajouté (x=1040, sans ennemis)

### Supprimé
- Indications clavier sur l'écran d'accueil

---

## v1.4 — 2026-06-21

### Validé
- Phase 6 v1 : run complet (explore → récolte → craft → boss) fonctionnel — v1 complète

---

## v1.3 — 2026-06-21

### Ajouté
- `game/data/boss.json` : toutes valeurs du boss externalisées (groupes Boss.physics/charge/slam/volley/flash + BossProjectile)

### Modifié
- `game/data/player.json` : restructuré en groupes (movement, jump, combat, hurt, aim) + 10 nouvelles clés
- `game/scripts/boss.gd` : toutes constantes → vars chargées depuis boss.json
- `game/scripts/boss_projectile.gd` : _load_config() depuis boss.json["BossProjectile"]
- `game/scripts/player.gd` : _load_configs() adapté aux groupes JSON, fallbacks sans valeurs hardcodées

---

## v1.2 — 2026-06-21

### Ajouté
- Phase 3 : stats joueur pilotées par équipement crafté (arme 3 paliers, armure 1 palier + damage_reduction)
- Configs externalisées : `game/data/player.json`, `weapons.json`, `armor.json`, `enemies.json`
- Menu dev : option "JOUER 100 MIN" (Dev.dev_resources)

### Modifié
- `enemy_base.gd` : HP et contact_damage chargés depuis enemies.json (contact_damage 1→2)
- `enemy_ground.tscn` : max_hp 4→5
- `player.gd` : constantes de mouvement converties en vars configurables via player.json

---

## v1.1 — 2026-06-21

### Modifié
- Mémoire persistante migrée du dossier auto vers `.claude/memory.md` (manette + règle contrôles)
- CLAUDE.md : commande `/memory` renommée `/create_memory`
- roadmap.md : cases Phase 1 (core) et Phase 2 (core) cochées

---

## v1.0 — 2026-06-21

### Ajouté
- Phase 1 complète : autoload `Inventory` + filons minables (`ore_node.gd`)
- Phase 2 implémentée : établi (`workbench.gd`) + menu craft (`craft_menu.gd`, PROCESS_MODE_ALWAYS) + recettes JSON externalisées
- Manette uniquement : interact=Y, ui_accept=A, ui_cancel=B (joymap.gd)
- Refacto v2 (A+B+C) : `take_damage` unifié, stats joueur pilotables, HUD extrait dans `hud.gd`
- Mode dev navigable (autoload Dev, menu sélection scène)
- Protocole vibecoding v2.2 initialisé (`_contexte/`, `zones.md`, `signals.md`)
