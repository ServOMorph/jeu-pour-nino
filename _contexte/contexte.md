# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.26. Cohérence `roadmap.md` (jeu) / `game_art/roadmap_editeur.md` analysée : périmètre de l'éditeur clarifié (hors périmètre = tilesets, parallax, shaders cicatrices, icônes UI), règle de synchronisation manifest/backlog ajoutée, articulation explicite avec `backlog_art.md`/`questions.md`, statut « maintenance » de l'éditeur après Phase 5. Une contradiction de taille sprite player (40x56/48x56 vs 14x24) reste à trancher par l'utilisateur.
Dette bloquante Phase 0 (3 appels `Inventory` résiduels + `preload()` PNG sans `.import`) toujours corrigée mais non validée intégralement (GUT, run manuel complet, suppression `inventory.gd` restants).
Prochaine étape jeu : finir la validation Phase 0, puis Phase 1 (matériaux typés, table définitive de 13 matériaux). Développement prévu avec 2 agents séparés (jeu / game_art), `questions.md` en arbitrage commun.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-06-30 : Phase 0 implémentée — RunState/MetaState/SaveManager autoloads, Inventory retiré, GUT v9.7.0 installé, 20 tests Phase 0 écrits.
- 2026-07-02 : Roadmap réordonnée — mort/résurrection/cicatrices avant contenu biomes 2/3/4 ; jalons jouables J1-J7 ; placeholders systématiques (aucune phase jeu n'attend game_art) ; Miroir du Noyau limité à 2 paramètres (backlog post-v3 pour boss vaincus/style de jeu).
- 2026-07-02 : Objectif de couverture de tests 85 % sur la logique data-driven/état ; jalon de refacto R1.5 ajouté après Phase 4.
- 2026-07-02 : Phase 5 — persistance de l'état du biome à la résurrection tranchée : scène biome conservée en mémoire (detach/reattach) plutôt que sérialisation complète, jugée plus simple et moins risquée.
- 2026-07-02 : Dette bloquante identifiée — 3 appels résiduels à `Inventory` (autoload supprimé) font crasher le jeu ; correction requise avant validation Phase 0.
- 2026-07-03 : Convention confirmée — aucun `.import` sous `game/assets/sprites/` ; toute texture PNG s'y charge en runtime (`Image.load_from_file`), jamais via `preload()` direct (sinon crash au lancement sans indexation éditeur préalable).
- 2026-07-05 : Phase 2 game_art (2.1 à 2.4) close — validation visuelle jeu/éditeur confirmée par l'utilisateur.
- 2026-07-06 : 77+1 questions de conception v3 tranchées (`questions.md`) — run multi-biomes, planchers durs de cicatrices, 4 slots d'équipement, armes à distance, 1 seul Gardien du Voile au lancement, rareté réalignée, solo strict, audio reporté en fin de projet.
- 2026-07-06 : `roadmap.md`, `docs/v3/*.md` et `game_art/backlog_art.md` mis à jour en cohérence avec `questions.md` ; développement prévu via 2 agents séparés (jeu et game_art).
- 2026-07-06 : Périmètre de `game_art/roadmap_editeur.md` clarifié — l'éditeur couvre sprites/animations d'entités uniquement, pas tilesets/parallax/shaders/icônes UI ; passe en maintenance après Phase 5.
