# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.29. La Phase 1 reste ouverte mais le gating de minage est désormais data-driven via `weapons.json` et `RunState`.
GUT est vert (`23/23`) et le projet démarre en headless, y compris `biome1`.
Un setup de test Phase 1 a été ajouté autour de l'atelier avec un minerai tier 2 (`fer`) et un tier 3 (`minerai_abyssal`).
La validation manuelle complète du flux minage/craft/HUD/menu dev reste à faire.
Le sprite dédié de `minerai_abyssal` manque encore et est suivi dans `game_art/backlog_art.md`.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-02 : Dette bloquante identifiée — 3 appels résiduels à `Inventory` (autoload supprimé) font crasher le jeu ; correction requise avant validation Phase 0.
- 2026-07-03 : Convention confirmée — aucun `.import` sous `game/assets/sprites/` ; toute texture PNG s'y charge en runtime (`Image.load_from_file`), jamais via `preload()` direct (sinon crash au lancement sans indexation éditeur préalable).
- 2026-07-05 : Phase 2 game_art (2.1 à 2.4) close — validation visuelle jeu/éditeur confirmée par l'utilisateur.
- 2026-07-06 : 77+1 questions de conception v3 tranchées (`questions.md`) — run multi-biomes, planchers durs de cicatrices, 4 slots d'équipement, armes à distance, 1 seul Gardien du Voile au lancement, rareté réalignée, solo strict, audio reporté en fin de projet.
- 2026-07-06 : `roadmap.md`, `docs/v3/*.md` et `game_art/backlog_art.md` mis à jour en cohérence avec `questions.md` ; développement prévu via 2 agents séparés (jeu et game_art).
- 2026-07-06 : Périmètre de `game_art/roadmap_editeur.md` clarifié — l'éditeur couvre sprites/animations d'entités uniquement, pas tilesets/parallax/shaders/icônes UI ; passe en maintenance après Phase 5.
- 2026-07-06 : Taille player conservée telle que validée en jeu pour la suite de la production.
- 2026-07-06 : Phase 0 validée — `inventory.gd` supprimé, 20 tests GUT verts, run complet manuel OK.
- 2026-07-06 : Phase 1 entamée — `RunState` migré vers `materials`, `coins` retirés du runtime, GUT vert (`21/21`) ; fermeture différée tant que le tier de pioche reste provisoire.
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
