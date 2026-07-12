# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.47. **Validation manuelle du flux Phase 2 complète** (voir `tests_manuels.md` à la racine) : sections 1-4, 6-9 testées manuellement sans anomalie bloquante.
Un blocage ouvert : découverte de recettes non-starter jamais déclenchée en jeu (`MetaState.discover_recipe()` non appelée).
Diagnostic 8.6 confirmé : sélection consommable fonctionne correctement (premier consommable auto-actif dès craft, réaffectation identique = pas de changement visible). Aucune correction requise.
Menu titre/dev reformaté (2026-07-11) ; bug de compilation `equipment_menu.gd` corrigé ; affichage équipement retravaillé.
Prochaine étape : brancher `discover_recipe()` via trigger gameplay (salle, drop porteur, victoire boss) pour débloquer Grimoire, puis terminer Phase 2 (barème PC, progression run, armes distance).

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
