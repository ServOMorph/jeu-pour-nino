# Signals — jeu   (MAJ 2026-06-25)

## Actions ouvertes
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
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-25 — sprites et menu pause)
# Session du 2026-06-25

## Décisions prises
- Sprites finaux générés un par un, pas depuis une planche découpée.
- Menu pause runtime ajouté sur Start ; quitter ferme le programme.

## Livrables produits ou modifiés
- docs/charte_graphique_pixel_art_dark_fantasy.md : charte graphique ajoutée.
- docs/process_generation_sprites.md : process de génération sprite ajouté.
- game/assets/sprites/* : sprites pixel art générés, réduits et alignés au sol.
- game/scripts/pause_menu.gd / level.gd / joymap.gd : menu pause runtime ajouté.
- game/scripts/end_screen.gd : option fermer le jeu ajoutée en défaite.

## Hypothèses validées / invalidées
- VALIDE : les sprites intégrés chargent dans Godot et le niveau démarre en headless.
- VALIDE : la génération unitaire donne de meilleurs assets que le découpage de planche.
- EN ATTENTE : test réel manette du menu pause et validation visuelle finale des offsets sprites.

## Prochaine étape exacte
Tester en jeu réel le menu pause Start, les téléports dev et l'alignement visuel des sprites.

## Question bloquante pour la session suivante
Aucune
