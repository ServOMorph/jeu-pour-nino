# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
Phases 1-3 complètes. Inventory + filons + établi + craft menu + stats joueur pilotées par équipement.
Configs externalisées : player.json, weapons.json, armor.json, enemies.json dans game/data/.
Menu dev : JOUER / JOUER 100 MIN / TEST BOSS.
Prochaine phase : Phase 6 v1 — run complet + ajustements difficulté boss.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : `take_damage(int, Vector2)` = interface unique pour tous les receveurs de dégâts.
- 2026-06-21 : Stats joueur (max_hp, attack_damage, attack_range) en var, pilotables par le futur équipement.
- 2026-06-21 : HUD extrait dans hud.gd autonome (découplé de level.gd).
- 2026-06-21 : Phase 1 complète — autoload Inventory + filons minables.
- 2026-06-21 : Phase 2 complète — établi + craft_menu (CanvasLayer, PROCESS_MODE_ALWAYS) + recettes JSON externalisées.
- 2026-06-21 : Manette uniquement pour nouvelles actions — ui_accept=A, ui_cancel=B, interact=Y (joymap.gd).
- 2026-06-21 : Phase 3 complète — stats joueur pilotées par équipement via weapons.json / armor.json.
- 2026-06-21 : Configs externalisées : player.json, weapons.json, armor.json, enemies.json.
- 2026-06-21 : contact_damage ennemis = 2 ; armure_bois damage_reduction = 1.
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
