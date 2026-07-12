# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
v1.47. **Validation manuelle du flux Phase 2 complète** (voir `tests_manuels.md` à la racine) : sections 1-4, 6-9 testées manuellement sans anomalie bloquante.
`discover_recipe()` branché (2026-07-12) sur victoire boss (`level.gd._on_boss_died()` → `RecipeCatalog.discover_by_trigger()`) : 3 recettes (`lame_spectrale`, `anneau_revenants`, `elixir_resurgence`) découvrables, testé manuellement en jeu OK. GUT 25/25 vert.
Triggers `Salle B1-B4`/`Porteur` (17 recettes) non branchables : dépendent de systèmes absents (biomes multiples, porteurs — phases futures).
Diagnostic 8.6 confirmé : sélection consommable fonctionne correctement (premier consommable auto-actif dès craft). Aucune correction requise.
Menu titre/dev reformaté (2026-07-11) ; bug de compilation `equipment_menu.gd` corrigé ; affichage équipement retravaillé.
Aucun blocage restant. Prochaine étape : terminer Phase 2 (barème PC, progression run, armes distance, tests craft).

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
- 2026-07-08 : Migration résolution 1920×1080 validée formellement côté jeu (GUT + headless + test manuel).
- 2026-07-08 : Socle Phase 2 branché côté jeu — schéma recettes cible, Grimoire dev, équipement via pause, craft filtré par maîtrise/tier.
- 2026-07-11 : Menu titre/dev reformaté (suppression hint manette, menu dev tenant dans la fenêtre).
- 2026-07-11 : Bug de compilation `equipment_menu.gd` (`SLOT_ORDER` non typé) corrigé ; affichage équipement retravaillé.
- 2026-07-11 : Validation manuelle Phase 2 engagée — deux blocages identifiés (découverte de recettes absente, sélection consommable sans effet visible) à traiter en priorité avant de clore la Phase 2.
- 2026-07-12 : Validation manuelle Phase 2 complétée (sections 1-9, sans anomalie bloquante). Diagnostic 8.6 : faux bug, comportement correct.
- 2026-07-12 : `discover_recipe()` branché sur victoire boss uniquement (3/20 recettes non-starter) — triggers salle/porteur attendent des systèmes non développés (biomes multiples, porteurs).
