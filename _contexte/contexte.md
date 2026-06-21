# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1 complète (v0.2.1) — boucle jouable de bout en bout : titre → biome 1 → boss → victoire/défaite → relance.
Contrôles clavier et manette PowerA NSW opérationnels. Écran de fin centré, anti-rebond bouton A.
Phase 6 (playtest & ajustements) en cours. Prochaine étape : boucle de ressources & craft (roadmap v2).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
