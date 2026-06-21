# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1 complète (v0.2.1) — boucle jouable de bout en bout : titre → biome 1 → boss → victoire/défaite → relance.
Refacto préparatoire v2 faite (A+B+C) : interface take_damage unifiée (Vector2), stats joueur pilotables, HUD extrait.
Jeu entier retesté manuellement OK. Prêt à attaquer la roadmap v2 Phase 1 (Inventory + filons).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
- 2026-06-21 : Mode dev intégré au menu (navigable, autoload Dev, registre _spawn_points() scalable).
- 2026-06-21 : JUMP_VELOCITY -250 → -320 pour permettre le saut par-dessus le boss.
- 2026-06-21 : Refacto v2 cadrée — A+B+C avant Phase 1, étape D (données niveau externalisées) reportée à la Phase 5.
- 2026-06-21 : `take_damage(int, Vector2)` = interface unique pour tous les receveurs de dégâts.
- 2026-06-21 : Stats joueur (max_hp, attack_damage, attack_range) en var, pilotables par le futur équipement.
- 2026-06-21 : HUD extrait dans hud.gd autonome (découplé de level.gd).
