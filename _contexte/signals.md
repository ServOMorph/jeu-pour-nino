# Signals — jeu   (MAJ 2026-06-25)

## Actions ouvertes
- [P1] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like.
  fait quand: idle, run1, run2, jump et attack utilisent tous des sprites cohérents en 40x56/48x56 validés en jeu.
  réf: `docs/process_generation_sprites.md`, `game/data/animations.json`, `game/assets/sprites/player/`
- [P2] Étendre la logique d'équipement obsolète aux armures si plusieurs paliers sont ajoutés.
  fait quand: si plusieurs armures existent, les paliers dépassés disparaissent de l'établi.
  réf: `game/scripts/craft_menu.gd`, `game/data/recipes.json`, `game/data/armor.json`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\Godot\godot.exe` ; le PATH utilisateur expose `godot` dans les nouveaux terminaux
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Règle absolue : toute valeur numérique gameplay doit être dans game/data/*.json — aucune constante hardcodée dans les scripts
- Configs JSON : player.json / weapons.json / armor.json / enemies.json / boss.json / level.json
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 3 ; armure_bois damage_reduction = 1 → 2 dégâts avec armure
- Potions empilables dans Inventory.consumables ; HUD affiche `POTION xN`
- Monnaie de run : `Inventory.coins`, remise à zéro au nouveau run, HUD `OR`
- Sprint : activation uniquement au sol ; un saut lancé en sprint conserve la vitesse rapide
- Menu titre 2 niveaux : accueil (JOUER / MODE DEV) → sous-menu dev (toggle 100 MIN, toggle VIE INF, JOUER, ATELIER, TEST BOSS, RETOUR)
- Spawn "atelier" : défini dans game/data/level.json, avec ennemis
- Respawn flyers corrigé ; 5 flyers initiaux ; respawn.max_alive = 17
- Collisions physiques joueur/mobs activées via layers : joueur mask 5, ennemis mask 3
- Mode dev VIE INF : Dev.infinite_hp fait ignorer les dégâts dans player.gd
- Menu pause en jeu : bouton menu/Start, pause le jeu, permet reprendre, recommencer, retour menu et dev runtime ; atelier/boss téléportent le joueur
- Sprites : utiliser `docs/process_generation_sprites.md` ; générer les sprites un par un, ne pas découper une planche pour les assets finaux
- Nouvelle cible visuelle personnages : lisibilité type Terraria ; player `40x56`, attack `48x56`
- `game/scripts/animation_driver.gd` charge les frames d'animation depuis `game/data/animations.json`
- `player_idle_v2.png` est l'idle intégré en test ; les autres frames player sont encore anciennes
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-25 — animation partagée et idle v2)
# Session du 2026-06-25

## Décisions prises
- Direction visuelle personnages recalée vers un standard type Terraria, avec player cible `40x56`.
- Le système d'animation passe par un driver partagé piloté par `animations.json`.

## Livrables produits ou modifiés
- docs/process_generation_sprites.md : standard Terraria-like et règle de finesse visuelle ajoutés.
- game/scripts/animation_driver.gd / game/data/animations.json : couche d'animation partagée ajoutée.
- game/scenes/player/player.tscn / game/scripts/player.gd : player branché sur le driver et flip gauche/droite corrigé.
- game/scenes/enemies/* / game/scripts/enemy_*.gd / game/scripts/boss.gd : mobs et boss branchés sur le driver.
- game/assets/sprites/player/player_idle_v2.png : nouvel idle player intégré pour test qualité.

## Hypothèses validées / invalidées
- VALIDE : la cible `40x56` donne un idle nettement plus fin que l'ancien `14x24`.
- VALIDE : le driver d'animation partagé charge le projet et le niveau en headless.
- EN ATTENTE : validation visuelle en jeu réel de l'idle v2, de son ancrage au sol et de la rupture avec les anciennes frames.

## Prochaine étape exacte
Tester en jeu réel l'idle v2 du player, puis refaire run1, run2, jump et attack dans le même standard avant de juger le rendu global.

## Question bloquante pour la session suivante
Aucune
