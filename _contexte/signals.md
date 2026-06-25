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
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B, sprint=JOY_BUTTON_LEFT_STICK (tous dans joymap.gd)
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
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-25 — validation v2.1)
# Session du 2026-06-25

## Décisions prises
- v2.1 validée utilisateur après playtest complet.
- Vie infinie ajoutée au mode dev pour faciliter les tests.

## Livrables produits ou modifiés
- roadmap.md / _contexte/* : v2.1 marquée validée, actions ouvertes nettoyées.
- game/scripts/player.gd : saut sprint conserve sa vitesse, vie infinie dev ignore les dégâts.
- game/scripts/title.gd / dev.gd : toggle dev VIE INF ajouté.
- game/scripts/level.gd / game/data/level.json : respawn flyers corrigé, quantité de flyers réduite.
- game/scenes/* : collisions physiques joueur/mobs activées.

## Hypothèses validées / invalidées
- VALIDE : gameplay v2.1 testé nickel par l'utilisateur.
- VALIDE : difficulté, potions multiples, progression équipement, course, respawn mobs, monnaie et boss validés utilisateur.
- VALIDE : lancement Godot headless OK sur projet, titre et biome1.

## Prochaine étape exacte
Définir la suite v3.

## Question bloquante pour la session suivante
Aucune
