# Signals — jeu   (MAJ 2026-07-02)

## Actions ouvertes
- [P1] Corriger la dette bloquante Phase 0 : 3 appels résiduels à l'autoload supprimé `Inventory` font crasher le jeu (minerai cassé, mort d'ennemi, mort du boss), puis valider Phase 0 en jeu.
  fait quand: `ore_node.gd:42`, `enemy_base.gd:107`, `boss.gd:255` migrés vers `RunState` ; `inventory.gd` supprimé ; `grep -rn "Inventory" game/scripts` vide ; 20 tests GUT verts ; run complet (miner, crafter, tuer ennemis, battre boss, relancer) sans erreur console, `MetaState` conservé après relance.
  réf: `roadmap.md` section « Dette bloquante Phase 0 »
- [P2] Démarrer Phase 1 roadmap v3 : matériaux typés (materials: Dictionary dans RunState).
  fait quand: miner ajoute le bon matériau ; HUD reflète les quantités par type ; tests verts ; couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like. (zone game_art)
  fait quand: idle, run1, run2, jump et attack utilisent tous des sprites cohérents en 40x56/48x56 validés en jeu.
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`, `game_art/backlog_art.md`
- [P3] Aligner le design document v3 sur le scope réduit du Miroir du Noyau (2 paramètres au lieu de 4) — décision utilisateur du 2026-07-02, pas encore répercutée dans le doc.
  fait quand: `docs/v3/CoreDive Challenge — Design Document v3.md` ne mentionne plus « boss vaincus » et « style de jeu » comme paramètres actifs du Miroir (ou les marque explicitement backlog post-v3).
  réf: `roadmap.md` Phase 9 et section « Backlog post-v3 », `docs/v3/CoreDive Challenge — Le Noyau et le Boss Final Adaptatif.md`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run.py
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- inventory.gd toujours présent mais plus référencé — peut être supprimé
- Nouveau : `game_art/backlog_art.md` centralise les besoins d'assets par phase — à consulter en priorité lors des sessions game_art
- Roadmap réordonnée (2026-07-02) : mort/résurrection/cicatrices (Phases 5-6) désormais avant le contenu des biomes 2/3/4 (Phase 7, ex-Phase 5). Vérifier les numéros de phase avant de s'y référer dans du code ou des commentaires.
- `roadmap.md` détaillée (2026-07-02, session 2) : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : décision retenue = conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète).
- `Inventory` : NE PLUS écrire "peut être supprimé" — 3 appels résiduels crashent le jeu (voir action P1). `inventory.gd` reste présent tant que ces 3 appels n'ont pas été migrés.

## Dernière session (2026-07-02 — roadmaps jeu et game_art détaillées pour implémentation Sonnet)

# Session du 2026-07-02

## Décisions prises
- `roadmap.md` (v3) détaillée intégralement pour qu'un dev sans contexte préalable puisse implémenter : carte du code (autoloads, fichiers clés, lignes), schémas JSON cibles par phase, choix d'implémentation tranchés (ex. Phase 4 : générateur produit le même format que `level.json` actuel ; Phase 5 : scène biome conservée en mémoire plutôt que sérialisée).
- `game_art/roadmap_editeur.md` détaillée de la même façon : état réel des fichiers de l'éditeur (galerie/preview déjà codées dans `main.gd`), diagnostic priorisé du bug de rendu gris, plan de sauvegarde JSON sûre pour l'inspecteur (Phase 3), spécification de l'audit (Phase 4).

## Livrables produits ou modifiés
- `roadmap.md` : réécrite intégralement (détail d'implémentation, sans changement de scope/ordre des phases).
- `game_art/roadmap_editeur.md` : réécrite intégralement (détail d'implémentation zone game_art, ne pas confondre avec le contexte propre à cette zone).

## Hypothèses validées / invalidées
- INVALIDE : la Phase 0 était considérée « juste à valider en jeu » -> découverte en lisant le code que le jeu **crashe** actuellement (3 appels à l'autoload supprimé `Inventory` toujours présents dans `ore_node.gd`, `enemy_base.gd`, `boss.gd`). Pivot : nouvelle section « Dette bloquante » en tête de `roadmap.md`, à corriger avant toute validation.
- EN ATTENTE : validation de la Phase 0 en jeu — reste ouverte, désormais conditionnée à la correction de la dette Inventory.
- EN ATTENTE : alignement du design document v3 sur le scope réduit du Miroir (2 vs 4 paramètres) — toujours pas exécuté.

## Prochaine étape exacte
Corriger les 3 appels `Inventory` résiduels + supprimer `inventory.gd`, puis valider Phase 0 en jeu (GUT + run complet). Ensuite Phase 1 (matériaux typés).

## Question bloquante pour la session suivante
Aucune
