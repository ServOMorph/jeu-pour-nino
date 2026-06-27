# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.12. Gameplay v2.1 validé et stable. Design document v3 rédigé (docs/v3/). Roadmap v3 créée : 11 phases, 3 jalons de refacto (R1/R2/R3), stratégie de tests GUT intégrée.
Prochaine étape jeu : Phase 0 — SaveManager + split Inventory → RunState/MetaState + GUT.
Zone game_art en attente : sprites player 40x56 standard Terraria-like (action [P2] non bloquante pour la zone jeu).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-27 : Affichage plein écran 1920×1080 (viewport pixel 480×270 ×4, nearest).
- 2026-06-27 : Contrôles clavier complets ajoutés (flèches, Z, E, R, Shift, Echap) — manette conservée.
- 2026-06-27 : game_art/ = source de vérité sprites/animations ; sync.py → game/ ; zone jeu ne gère plus les sprites.
- 2026-06-27 : Design document v3 rédigé — 4 biomes libres, Grimoire/PC, mort-résurrection/Voile, cicatrices shaders, boss adaptatif modulaire.
- 2026-06-27 : Génération biomes = templates assemblés (PCG pur écarté).
- 2026-06-27 : Roadmap v3 créée — 11 phases, jalons refacto R1/R2/R3, stratégie tests GUT. Pas de rewrite : noyau gameplay conservé.
