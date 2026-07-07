# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.32. **Phase 1 (Matériaux typés) close** (GUT `23/23`, run manuel validé). Phase 2 mise en pause : une migration transversale du viewport vers 1920×1080 natif (player 150 px) est planifiée et priorisée avant, pour éviter de produire l'UI Phase 2 à la mauvaise échelle.
Plan complet écrit à la racine (`plan_resolution_1920x1080.md`), pas encore exécuté.
Prochaine étape : exécuter les phases A+B du plan résolution (project.godot + JSON ×4).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-05 : Phase 2 game_art (2.1 à 2.4) close — validation visuelle jeu/éditeur confirmée par l'utilisateur.
- 2026-07-06 : 77+1 questions de conception v3 tranchées (`questions.md`) — run multi-biomes, planchers durs de cicatrices, 4 slots d'équipement, armes à distance, 1 seul Gardien du Voile au lancement, rareté réalignée, solo strict, audio reporté en fin de projet.
- 2026-07-06 : `roadmap.md`, `docs/v3/*.md` et `game_art/backlog_art.md` mis à jour en cohérence avec `questions.md` ; développement prévu via 2 agents séparés (jeu et game_art).
- 2026-07-06 : Périmètre de `game_art/roadmap_editeur.md` clarifié — l'éditeur couvre sprites/animations d'entités uniquement, pas tilesets/parallax/shaders/icônes UI ; passe en maintenance après Phase 5.
- 2026-07-06 : Taille player conservée telle que validée en jeu pour la suite de la production.
- 2026-07-06 : Phase 0 validée — `inventory.gd` supprimé, 20 tests GUT verts, run complet manuel OK.
- 2026-07-06 : Phase 1 entamée — `RunState` migré vers `materials`, `coins` retirés du runtime, GUT vert (`21/21`) ; fermeture différée tant que le tier de pioche reste provisoire.
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-07 : Migration résolution retenue — viewport natif 1920×1080 (facteur ×4 monde) plutôt que 480×270 conservé avec sprite agrandi ; player idle ciblé à 150 px (~×6.25, upscale ×6=144px transitoire en attendant un sprite natif game_art).
