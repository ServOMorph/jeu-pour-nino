# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.47. Validation manuelle du flux Phase 2 en cours (voir `tests_manuels.md` à la racine) : sections 1-4, 6, 7 et 8.1-8.5 validées OK.
Deux blocages ouverts : découverte de recettes non-starter jamais déclenchée en jeu (`discover_recipe` non appelé) ; sélection de consommable dans l'écran Équipement sans effet visible confirmé (hypothèse à vérifier : déjà actif par défaut dès le craft).
Menu titre/dev reformaté (hint manette supprimé, 7 entrées dev tiennent dans la fenêtre) ; bug de compilation `equipment_menu.gd` corrigé (`SLOT_ORDER` non typé) ; affichage équipement retravaillé (nom lisible, marqueur actif).
Prochaine étape : débugger la sélection de consommable, terminer 8.7-8.8 et §9 de `tests_manuels.md`, puis débloquer `discover_recipe`.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-06 : Phase 1 entamée — `RunState` migré vers `materials`, `coins` retirés du runtime, GUT vert (`21/21`) ; fermeture différée tant que le tier de pioche reste provisoire.
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
- 2026-07-08 : Migration résolution 1920×1080 validée formellement côté jeu (GUT + headless + test manuel).
- 2026-07-08 : Socle Phase 2 branché côté jeu — schéma recettes cible, Grimoire dev, équipement via pause, craft filtré par maîtrise/tier.
- 2026-07-11 : Menu titre/dev reformaté (suppression hint manette, menu dev tenant dans la fenêtre).
- 2026-07-11 : Bug de compilation `equipment_menu.gd` (`SLOT_ORDER` non typé) corrigé ; affichage équipement retravaillé.
- 2026-07-11 : Validation manuelle Phase 2 engagée — deux blocages identifiés (découverte de recettes absente, sélection consommable sans effet visible) à traiter en priorité avant de clore la Phase 2.
