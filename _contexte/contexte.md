# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v2.1 validée ; chantier animation lancé avec un driver partagé piloté par `game/data/animations.json`.
Direction visuelle personnages recalée vers un standard type Terraria, avec player cible `40x56`.
Un nouvel idle player `player_idle_v2.png` est intégré et branché pour test qualité en jeu.
Les autres frames player restent anciennes, donc le rendu complet n'est pas encore cohérent.
Prochaine étape : valider l'idle v2 en jeu réel puis refaire run, jump et attack dans le même standard.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : v1 complète — Phase 6 v1 validée, run complet de bout en bout fonctionnel.
- 2026-06-21 : Menu titre 2 niveaux — sous-menu dev avec toggle 100 MIN et spawn atelier (title.gd refonte complète).
- 2026-06-25 : Données de niveau externalisées dans game/data/level.json, chargé par level.gd.
- 2026-06-25 : Roadmap active v2.1 — retours playtest avant v3, ancienne v2 archivée.
- 2026-06-25 : v2.1 gameplay — potions empilables, monnaie de run, sprint au sol, respawn mobs, boss durci.
- 2026-06-25 : v2.1 validée utilisateur — gameplay testé nickel, correctifs finaux intégrés.
- 2026-06-25 : Sprites finaux générés un par un selon `docs/process_generation_sprites.md`, pas par découpe de planche.
- 2026-06-25 : Menu pause runtime sur Start — quitter ferme le programme, dev runtime sans redémarrage sauf téléports.
- 2026-06-25 : Animations branchées sur un driver partagé `game/scripts/animation_driver.gd` piloté par `game/data/animations.json`.
- 2026-06-25 : Nouvelle cible visuelle personnages type Terraria — player `40x56`, attaque `48x56`, idle v2 intégré pour test.
