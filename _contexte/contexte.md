# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v2.1 validée, puis première passe design pixel art intégrée : sprites générés un par un et branchés dans Godot.
Sprites recalés à la taille des anciens rectangles/carrés et ancrés visuellement au sol.
Menu pause en jeu ajouté sur Start : reprendre, recommencer, quitter, mode dev runtime et téléport atelier/boss.
Menu de défaite : option fermer le jeu ajoutée.
Prochaine étape : tester visuellement menu pause, offsets sprites et décider la suite v3.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
- 2026-06-21 : Toutes valeurs gameplay dans game/data/*.json — aucune constante numérique dans les scripts.
- 2026-06-21 : v1 complète — Phase 6 v1 validée, run complet de bout en bout fonctionnel.
- 2026-06-21 : Menu titre 2 niveaux — sous-menu dev avec toggle 100 MIN et spawn atelier (title.gd refonte complète).
- 2026-06-25 : Données de niveau externalisées dans game/data/level.json, chargé par level.gd.
- 2026-06-25 : Roadmap active v2.1 — retours playtest avant v3, ancienne v2 archivée.
- 2026-06-25 : v2.1 gameplay — potions empilables, monnaie de run, sprint au sol, respawn mobs, boss durci.
- 2026-06-25 : v2.1 validée utilisateur — gameplay testé nickel, correctifs finaux intégrés.
- 2026-06-25 : Sprites finaux générés un par un selon `docs/process_generation_sprites.md`, pas par découpe de planche.
- 2026-06-25 : Menu pause runtime sur Start — quitter ferme le programme, dev runtime sans redémarrage sauf téléports.
