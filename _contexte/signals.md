# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P2|ouvert] Refacto étape D (externaliser données de niveau) — différé post-v1
  fait quand: données de niveau dans un fichier JSON externe chargé par level.gd
  réf: game/scripts/level.gd

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Règle absolue : toute valeur numérique gameplay doit être dans game/data/*.json — aucune constante hardcodée dans les scripts
- Configs JSON : player.json (groupes movement/jump/combat/hurt/aim) / weapons.json / armor.json / enemies.json / boss.json (groupes Boss.physics/charge/slam/volley/flash + BossProjectile)
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 2 ; armure_bois damage_reduction = 1 → 1 dégât avec armure
- Menu titre 2 niveaux : accueil (JOUER / MODE DEV) → sous-menu dev (toggle 100 MIN / JOUER / ATELIER / TEST BOSS / RETOUR)
- Spawn "atelier" : x=1040, FLOOR_TOP-16, sans ennemis (level.gd _spawn_points)
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-21 — polish UI menu & layout)
# Session du 2026-06-21

## Décisions prises
- Menu titre restructuré en 2 niveaux : accueil (JOUER / MODE DEV) → sous-menu dev (toggle 100 MIN / JOUER / ATELIER / TEST BOSS / RETOUR)
- craft_menu.gd : hauteur du panel calculée dynamiquement (fix chevauchement "A: craft / B: fermer")
- Suppression des indications clavier sur l'écran d'accueil (manette uniquement)

## Livrables produits ou modifiés
- game/scripts/title.gd : refonte complète 2 niveaux + fix double-déclenchement toggle (_a_was mis à jour en tête de _process)
- game/scripts/craft_menu.gd : PH dynamique = 26 + recipes.size() × ROW_H + 20
- game/scripts/level.gd : spawn "atelier" ajouté (x=1040, sans ennemis)

## Hypothèses validées / invalidées
- INVALIDE : return anticipé dans _process avant mise à jour de _a_was → double-déclenchement manette → fix appliqué

## Prochaine étape exacte
Tester : menu 2 niveaux, toggle 100 MIN fonctionnel, spawn atelier. Si OK → définir axes v2.

## Question bloquante pour la session suivante
Aucune
