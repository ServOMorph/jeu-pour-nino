# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1 complète (v0.2.1) — boucle jouable de bout en bout : titre → biome 1 → boss → victoire/défaite → relance.
Contrôles clavier et manette PowerA NSW opérationnels. Menu titre navigable avec mode dev (spawn direct boss).
Saut augmenté (-320), autoload Dev pour spawn inter-scènes. Phase 6 en cours, tests manuels OK.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
- 2026-06-21 : Mode dev intégré au menu (navigable, autoload Dev, registre _spawn_points() scalable).
- 2026-06-21 : JUMP_VELOCITY -250 → -320 pour permettre le saut par-dessus le boss.
