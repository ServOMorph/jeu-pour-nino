# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Phase 6 v1 : playtest & ajustements de difficulté boss
  fait quand: run complet jouable de bout en bout, boss équilibré
  réf: game/scripts/boss.gd, game/data/enemies.json
- [P2|ouvert] Refacto étape D (externaliser données de niveau) — à faire AU MOMENT de la Phase 5, pas avant
  fait quand: données de niveau dans un fichier JSON externe chargé par level.gd
  réf: game/scripts/level.gd

## Questions ouvertes
(aucune)

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Configs JSON : player.json / weapons.json / armor.json / enemies.json dans game/data/
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 2 ; armure_bois damage_reduction = 1 → 1 dégât avec armure
- Menu dev : JOUER / JOUER 100 MIN / TEST BOSS (Dev.dev_resources injecté dans Inventory après reset)

## Dernière session (2026-06-21 — Phase 3 + configs)
# Session du 2026-06-21

## Décisions prises
- Phase 2 validée en jeu (A craft + B fermer fonctionnels, établi maintenu à x=150)
- Phase 3 implémentée : stats joueur pilotées par équipement crafté (arme 3 paliers, armure 1 palier)
- Configs externalisées dans game/data/ : player.json, weapons.json, armor.json, enemies.json
- contact_damage ennemis 1→2 pour que armure_bois (damage_reduction=1) soit visible
- Menu dev enrichi : option "JOUER 100 MIN" via Dev.dev_resources

## Livrables produits ou modifiés
- game/scripts/player.gd : _load_configs(), _apply_equipment() refactorisé, vars de mouvement configurables
- game/scripts/enemy_base.gd : _load_config() depuis enemies.json
- game/scripts/dev.gd : var dev_resources ajoutée
- game/scripts/title.gd : option "JOUER 100 MIN" dans DEV_SPAWNS
- game/scripts/level.gd : injection Dev.dev_resources après Inventory.reset()
- game/scenes/enemies/enemy_ground.tscn : max_hp 4→5
- game/data/player.json : créé
- game/data/weapons.json : créé
- game/data/armor.json : créé (damage_reduction=1)
- game/data/enemies.json : créé (contact_damage=2)

## Hypothèses validées / invalidées
- VALIDE : max_hp dans enemy_base.gd était overridé par les .tscn — corrigé via JSON
- VALIDE : armor damage_reduction sans effet si contact_damage=1 (max(1, 0)=1) — corrigé contact_damage→2

## Prochaine étape exacte
Phase 6 v1 : faire un run complet et ajuster la difficulté du boss (HP, dégâts, vitesse projectiles).

## Question bloquante pour la session suivante
Aucune
