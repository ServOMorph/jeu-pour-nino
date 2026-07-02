# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.16. Roadmap v3 refondue : mort/résurrection/cicatrices remontées avant le contenu des biomes 2/3/4, jalons jouables J1-J7 définis, scope Miroir réduit à 2 paramètres, objectif de couverture 85 % et jalon de refacto R1.5 ajoutés.
`game_art/backlog_art.md` créé pour centraliser les besoins d'assets par phase.
Phase 0 (code) toujours non validée en jeu (GUT + run complet à confirmer dans Godot).
Prochaine étape jeu : valider Phase 0 en jeu, puis Phase 1 (matériaux typés).
Zone game_art en attente : sprites player 40x56 standard Terraria-like (voir backlog_art.md).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-27 : Affichage plein écran 1920×1080 (viewport pixel 480×270 ×4, nearest).
- 2026-06-27 : Contrôles clavier complets ajoutés (flèches, Z, E, R, Shift, Echap) — manette conservée.
- 2026-06-27 : game_art/ = source de vérité sprites/animations ; sync.py → game/ ; zone jeu ne gère plus les sprites.
- 2026-06-27 : Design document v3 rédigé — 4 biomes libres, Grimoire/PC, mort-résurrection/Voile, cicatrices shaders, boss adaptatif modulaire.
- 2026-06-27 : Génération biomes = templates assemblés (PCG pur écarté).
- 2026-06-27 : Roadmap v3 créée — 11 phases, jalons refacto R1/R2/R3, stratégie tests GUT. Pas de rewrite : noyau gameplay conservé.
- 2026-06-30 : Phase 0 implémentée — RunState/MetaState/SaveManager autoloads, Inventory retiré, GUT v9.7.0 installé, 20 tests Phase 0 écrits.
- 2026-07-02 : Roadmap réordonnée — mort/résurrection/cicatrices avant contenu biomes 2/3/4 ; jalons jouables J1-J7 ; placeholders systématiques (aucune phase jeu n'attend game_art) ; Miroir du Noyau limité à 2 paramètres (backlog post-v3 pour boss vaincus/style de jeu).
- 2026-07-02 : Objectif de couverture de tests 85 % sur la logique data-driven/état ; jalon de refacto R1.5 ajouté après Phase 4.
