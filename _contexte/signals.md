# Signals — jeu   (MAJ 2026-07-02)

## Actions ouvertes
- [P1] Valider Phase 0 en jeu : lancer GUT + run complet dans Godot 4.5.
  fait quand: 20 tests GUT verts ; run de bout en bout sans erreur console.
  réf: `game/tests/`, `game/scripts/run_state.gd`, `game/scripts/save_manager.gd`
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

## Dernière session (2026-07-02 — refonte roadmap v3 + backlog art)

# Session du 2026-07-02

## Décisions prises
- Roadmap v3 réordonnée : boucle identitaire mort/résurrection/cicatrices (Phases 5-6) remontée avant le contenu des biomes 2/3/4 (Phase 7, étalée 7a/7b/7c), pour valider l'identité du jeu tôt et livrer des jalons jouables réguliers.
- Jalons jouables J1 à J7 définis, chacun rattaché à une phase et un critère observable.
- Règle placeholders systématique : aucune phase jeu n'attend game_art ; les besoins d'assets sont recensés dans un backlog dédié plutôt que de bloquer les critères « fait quand ».
- Scope du Miroir du Noyau réduit à 2 paramètres (biomes explorés + cicatrices) ; « boss vaincus » et « style de jeu » du design doc repoussés en backlog post-v3.
- Objectif de couverture de tests fixé à 85 % sur la logique data-driven/état, vérifié à chaque jalon de refacto.
- Nouveau jalon de refacto R1.5 (après Phase 4) ajouté pour combler l'écart de 5 phases entre R1 et R2.

## Livrables produits ou modifiés
- `roadmap.md` : réécrite intégralement (réordonnancement, jalons jouables, règle placeholders, scope Miroir documenté, section Backlog post-v3, jalon R1.5, objectif de couverture 85 % intégré aux refactos R1/R1.5/R2/R3).
- `game_art/backlog_art.md` : créé — backlog des assets à produire par phase, alimenté depuis la roadmap jeu, consommé par les sessions game_art.

## Hypothèses validées / invalidées
- VALIDE (décision utilisateur) : jalons jouables réguliers, remontée mort/résurrection avant contenu biomes, scope Miroir à 2 paramètres, placeholders systématiques.
- EN ATTENTE : alignement du design document v3 sur le scope réduit du Miroir (2 vs 4 paramètres) — proposé, pas encore exécuté, pas de réponse de l'utilisateur.
- EN ATTENTE : validation de la Phase 0 en jeu (GUT + run complet) — reportée, toujours ouverte depuis la session précédente.

## Prochaine étape exacte
Valider Phase 0 en jeu (P1, inchangé). Si l'utilisateur le demande, aligner le design doc v3 sur le scope 2 paramètres du Miroir du Noyau.

## Question bloquante pour la session suivante
Aucune
