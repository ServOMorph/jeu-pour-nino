# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.40. Socle Phase 2 branché côté jeu : `recipes.json` au schéma cible 27 recettes, starters bootstrapés, Grimoire dev, équipement manuel via pause, craft filtré par maîtrise/tier.
GUT `25/25` vert et démarrage headless OK.
Validation manuelle complète du flux Phase 2 encore non faite et prioritaire avant toute extension supplémentaire.
Prochaine étape : valider manuellement Grimoire → craft → équipement → HUD, puis reprendre gain de PC / progression / armes à distance.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-06 : Phase 1 entamée — `RunState` migré vers `materials`, `coins` retirés du runtime, GUT vert (`21/21`) ; fermeture différée tant que le tier de pioche reste provisoire.
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-07 : Migration résolution retenue — viewport natif 1920×1080 (facteur ×4 monde) plutôt que 480×270 conservé avec sprite agrandi ; player idle ciblé à 150 px (~×6.25, upscale ×6=144px transitoire en attendant un sprite natif game_art).
- 2026-07-07 : Migration résolution exécutée (project.godot, JSON, scènes, scripts, sprites) — validation GUT/run manuel restant à faire.
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
- 2026-07-08 : Migration résolution 1920×1080 validée formellement côté jeu (GUT + headless + test manuel).
- 2026-07-08 : Documentation active réalignée sur la 2D standard ; Phase 2 peut démarrer côté jeu.
- 2026-07-08 : Socle Phase 2 branché côté jeu — schéma recettes cible, Grimoire dev, équipement via pause, craft filtré par maîtrise/tier.
- 2026-07-08 : Validation manuelle du flux Phase 2 priorisée avant la suite du développement de cette phase.
