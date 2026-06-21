# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
Phase 1 complète : Inventory autoload (resources, items) + filons minables dans le niveau.
Phase 2 implémentée : établi interactif (x=150 debug) + menu craft avec pause + 3 recettes JSON externalisées.
Controls manette : interact=Y, ui_accept=A, ui_cancel=B dans joymap.gd.
EN ATTENTE : validation A (craft) + B (fermer) en jeu, position définitive établi.
Phase 3 suivante une fois Phase 2 validée (stats joueur → équipement crafté).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
- 2026-06-21 : Mode dev intégré au menu (navigable, autoload Dev, registre _spawn_points() scalable).
- 2026-06-21 : JUMP_VELOCITY -250 → -320 pour permettre le saut par-dessus le boss.
- 2026-06-21 : Refacto v2 cadrée — A+B+C avant Phase 1, étape D (données niveau externalisées) reportée à la Phase 5.
- 2026-06-21 : `take_damage(int, Vector2)` = interface unique pour tous les receveurs de dégâts.
- 2026-06-21 : Stats joueur (max_hp, attack_damage, attack_range) en var, pilotables par le futur équipement.
- 2026-06-21 : HUD extrait dans hud.gd autonome (découplé de level.gd).
- 2026-06-21 : Phase 1 complète — autoload Inventory + filons minables.
- 2026-06-21 : Phase 2 implémentée — établi + craft_menu (CanvasLayer, PROCESS_MODE_ALWAYS) + recettes JSON externalisées.
- 2026-06-21 : Manette uniquement pour nouvelles actions — ui_accept=A, ui_cancel=B, interact=Y (joymap.gd).
