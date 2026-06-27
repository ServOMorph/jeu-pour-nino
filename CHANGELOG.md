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
