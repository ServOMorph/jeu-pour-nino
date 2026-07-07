# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.33. Migration résolution 1920×1080 exécutée dans le working tree (JSON/scènes/scripts/sprites), validation GUT + run manuel restant à faire. **Pivot acté : abandon du pixel art, graphismes 2D standard** (pipeline Codex + rescale, `plan_graphismes_standard_2d.md`). Phase A du pivot appliquée côté jeu (rendu linéaire). Refonte game_art (éditeur, charte, workflow) signalée via `backlog_art.md`, non commencée.
Prochaine étape : valider GUT + run manuel de la migration résolution, puis ouvrir une session game_art sur le pivot.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-06 : Périmètre de `game_art/roadmap_editeur.md` clarifié — l'éditeur couvre sprites/animations d'entités uniquement, pas tilesets/parallax/shaders/icônes UI ; passe en maintenance après Phase 5.
- 2026-07-06 : Taille player conservée telle que validée en jeu pour la suite de la production.
- 2026-07-06 : Phase 0 validée — `inventory.gd` supprimé, 20 tests GUT verts, run complet manuel OK.
- 2026-07-06 : Phase 1 entamée — `RunState` migré vers `materials`, `coins` retirés du runtime, GUT vert (`21/21`) ; fermeture différée tant que le tier de pioche reste provisoire.
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-07 : Migration résolution retenue — viewport natif 1920×1080 (facteur ×4 monde) plutôt que 480×270 conservé avec sprite agrandi ; player idle ciblé à 150 px (~×6.25, upscale ×6=144px transitoire en attendant un sprite natif game_art).
- 2026-07-07 : Migration résolution exécutée (project.godot, JSON, scènes, scripts, sprites) — validation GUT/run manuel restant à faire.
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
