# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Refacto étape D (externaliser données de niveau) — à faire AU MOMENT de la Phase 5, pas avant
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
- Règle absolue : toute valeur numérique gameplay doit être dans game/data/*.json — aucune constante hardcodée dans les scripts
- Configs JSON : player.json (groupes movement/jump/combat/hurt/aim) / weapons.json / armor.json / enemies.json / boss.json (groupes Boss.physics/charge/slam/volley/flash + BossProjectile)
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 2 ; armure_bois damage_reduction = 1 → 1 dégât avec armure
- Menu dev : JOUER / JOUER 100 MIN / TEST BOSS (Dev.dev_resources injecté dans Inventory après reset)

## Dernière session (2026-06-21 — Phase 6 v1 validée)
# Session du 2026-06-21

## Décisions prises
- Phase 6 v1 validée : run complet (explore → récolte → craft → boss) fonctionnel et fluide — v1 complète

## Livrables produits ou modifiés
(aucun fichier modifié cette session — validation uniquement)

## Hypothèses validées / invalidées
- VALIDE : run de bout en bout jouable, boss équilibré avec les valeurs actuelles de boss.json

## Prochaine étape exacte
v1 complète. Prochaine session : définir les axes v2 (polish, contenu, nouvelles features).

## Question bloquante pour la session suivante
Aucune
