# Signals — jeu   (MAJ 2026-06-25)

## Actions ouvertes
- [P1] Valider la monnaie après correction des mobs volants.
  fait quand: tuer au moins un mob volant augmente bien `OR` dans le HUD.
  réf: `game/scripts/enemy_flyer.gd`, `game/scripts/enemy_base.gd`, `game/data/enemies.json`
- [P1] Tester un run complet v2.1 de bout en bout.
  fait quand: un run complet explore → récolte → craft → boss est joué et validé ou corrigé.
  réf: `roadmap.md`, `game/scenes/levels/biome1.tscn`
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
- Sprint uniquement au sol ; impossible de passer en sprint pendant un saut
- Menu titre 2 niveaux : accueil (JOUER / MODE DEV) → sous-menu dev (toggle 100 MIN / JOUER / ATELIER / TEST BOSS / RETOUR)
- Spawn "atelier" : défini dans game/data/level.json, avec ennemis
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-25 — v2.1 retours playtest)
# Session du 2026-06-25

## Décisions prises
- v2.1 centrée sur difficulté, potions multiples, sprint, respawn, monnaie et boss.
- Monnaie en v2.1 = monnaie de run remise à zéro ; persistance méta reportée à v3.

## Livrables produits ou modifiés
- roadmap.md : roadmap active v2.1, ancienne v2 archivée.
- game/scripts/* + game/data/* : potions empilables, monnaie, sprint, respawn, difficulté ennemis/boss.
- game/data/level.json : densité mobs augmentée et spawn atelier avec ennemis.
- game/scripts/enemy_*.gd : config ennemis stabilisée par clé explicite, flyers corrigés pour l'or.

## Hypothèses validées / invalidées
- VALIDE : difficulté, potions multiples, progression équipement, course, respawn mobs et boss validés utilisateur.
- VALIDE : lancement Godot headless OK sur titre et biome1.
- EN ATTENTE : monnaie à revalider en jeu après correction des mobs volants.

## Prochaine étape exacte
Tester un run complet v2.1 et vérifier que les mobs volants donnent bien de l'or.

## Question bloquante pour la session suivante
Aucune
