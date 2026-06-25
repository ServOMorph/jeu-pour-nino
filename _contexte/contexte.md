# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v2.1 validée : gameplay testé nickel par l'utilisateur.
Difficulté, potions multiples, progression équipement, course, respawn mobs, monnaie et boss validés.
Correctifs post-playtest : saut sprint conserve sa vitesse, flyers respawn, collisions physiques joueur/mobs, vie infinie dev.
Toutes valeurs gameplay et données de niveau sont dans game/data/ ; validation Godot headless OK.
Prochaine étape : définir la suite v3.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Configs externalisées : player.json, weapons.json, armor.json, enemies.json.
- 2026-06-21 : contact_damage ennemis = 2 ; armure_bois damage_reduction = 1.
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
- 2026-06-21 : Toutes valeurs gameplay dans game/data/*.json — aucune constante numérique dans les scripts.
- 2026-06-21 : v1 complète — Phase 6 v1 validée, run complet de bout en bout fonctionnel.
- 2026-06-21 : Menu titre 2 niveaux — sous-menu dev avec toggle 100 MIN et spawn atelier (title.gd refonte complète).
- 2026-06-25 : Données de niveau externalisées dans game/data/level.json, chargé par level.gd.
- 2026-06-25 : Roadmap active v2.1 — retours playtest avant v3, ancienne v2 archivée.
- 2026-06-25 : v2.1 gameplay — potions empilables, monnaie de run, sprint au sol, respawn mobs, boss durci.
- 2026-06-25 : v2.1 validée utilisateur — gameplay testé nickel, correctifs finaux intégrés.
