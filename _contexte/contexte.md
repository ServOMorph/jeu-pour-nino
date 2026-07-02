# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.17. `roadmap.md` et `game_art/roadmap_editeur.md` détaillées pour implémentation directe (Sonnet) : carte du code, schémas JSON cibles, choix d'implémentation tranchés — scope et ordre des phases inchangés.
Découverte bloquante en analysant le code : le jeu crashe actuellement (3 appels résiduels à l'autoload supprimé `Inventory` dans `ore_node.gd`, `enemy_base.gd`, `boss.gd`). Nouvelle section « Dette bloquante » en tête de `roadmap.md`.
Prochaine étape jeu : corriger la dette Inventory, valider Phase 0 en jeu (GUT + run complet), puis Phase 1 (matériaux typés).
Zone game_art : bug de rendu gris de l'éditeur diagnostiqué (suspect n°1 : `class_name` non résolu en lancement `--path` sans indexation préalable) — correctif proposé dans `game_art/roadmap_editeur.md`, pas encore appliqué.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-27 : game_art/ = source de vérité sprites/animations ; sync.py → game/ ; zone jeu ne gère plus les sprites.
- 2026-06-27 : Design document v3 rédigé — 4 biomes libres, Grimoire/PC, mort-résurrection/Voile, cicatrices shaders, boss adaptatif modulaire.
- 2026-06-27 : Génération biomes = templates assemblés (PCG pur écarté).
- 2026-06-27 : Roadmap v3 créée — 11 phases, jalons refacto R1/R2/R3, stratégie tests GUT. Pas de rewrite : noyau gameplay conservé.
- 2026-06-30 : Phase 0 implémentée — RunState/MetaState/SaveManager autoloads, Inventory retiré, GUT v9.7.0 installé, 20 tests Phase 0 écrits.
- 2026-07-02 : Roadmap réordonnée — mort/résurrection/cicatrices avant contenu biomes 2/3/4 ; jalons jouables J1-J7 ; placeholders systématiques (aucune phase jeu n'attend game_art) ; Miroir du Noyau limité à 2 paramètres (backlog post-v3 pour boss vaincus/style de jeu).
- 2026-07-02 : Objectif de couverture de tests 85 % sur la logique data-driven/état ; jalon de refacto R1.5 ajouté après Phase 4.
- 2026-07-02 : Phase 5 — persistance de l'état du biome à la résurrection tranchée : scène biome conservée en mémoire (detach/reattach) plutôt que sérialisation complète, jugée plus simple et moins risquée.
- 2026-07-02 : Dette bloquante identifiée — 3 appels résiduels à `Inventory` (autoload supprimé) font crasher le jeu ; correction requise avant validation Phase 0.
