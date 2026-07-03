# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.18. Dette bloquante Phase 0 (3 appels `Inventory` résiduels) corrigée, plus un bug additionnel découvert au passage (`preload()` sur PNG sans `.import` dans `ore_node.gd`/`workbench.gd`). Le niveau se charge et un run s'affiche sans crash, mais la validation complète (GUT, run manuel intégral, suppression `inventory.gd`) reste à faire.
Zone game_art : Phase 2.1 (rendu gris) et 2.2 (infos frame, damier, play/pause, placeholder manquant) et 2.4 (sync.py assaini) terminées et validées visuellement. Reste 2.3 (comparaison jeu/éditeur côte à côte) — outillé via `run_edit_game.py` (racine), pas encore exécutée.
Sprite `player_idle` recalibré (40x56 → 14x24) pour cohérence d'échelle avec `run`/`jump`.
Prochaine étape jeu : Phase 2.3 game_art, puis finir la validation Phase 0, puis Phase 1 (matériaux typés).

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
- 2026-07-03 : Convention confirmée — aucun `.import` sous `game/assets/sprites/` ; toute texture PNG s'y charge en runtime (`Image.load_from_file`), jamais via `preload()` direct (sinon crash au lancement sans indexation éditeur préalable).
