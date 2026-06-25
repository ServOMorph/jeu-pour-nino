# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1 complète. Run complet (explore → récolte → craft → boss) validé, nickel.
Toutes valeurs gameplay et données de niveau externalisées dans game/data/, dont level.json.
Menu titre 2 niveaux validé : accueil → sous-menu dev avec toggle 100 MIN, atelier, test boss.
Godot 4.5 disponible via D:\Godot\godot.exe ; validation headless OK.
Prochaine session : définir axes v2.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Phase 2 complète — établi + craft_menu (CanvasLayer, PROCESS_MODE_ALWAYS) + recettes JSON externalisées.
- 2026-06-21 : Manette uniquement pour nouvelles actions — ui_accept=A, ui_cancel=B, interact=Y (joymap.gd).
- 2026-06-21 : Phase 3 complète — stats joueur pilotées par équipement via weapons.json / armor.json.
- 2026-06-21 : Configs externalisées : player.json, weapons.json, armor.json, enemies.json.
- 2026-06-21 : contact_damage ennemis = 2 ; armure_bois damage_reduction = 1.
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
- 2026-06-21 : Toutes valeurs gameplay dans game/data/*.json — aucune constante numérique dans les scripts.
- 2026-06-21 : v1 complète — Phase 6 v1 validée, run complet de bout en bout fonctionnel.
- 2026-06-21 : Menu titre 2 niveaux — sous-menu dev avec toggle 100 MIN et spawn atelier (title.gd refonte complète).
- 2026-06-25 : Données de niveau externalisées dans game/data/level.json, chargé par level.gd.
