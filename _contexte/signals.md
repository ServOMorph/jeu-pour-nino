# Signals — jeu   (MAJ 2026-06-27)

## Actions ouvertes
- [P1] Démarrer Phase 0 roadmap v3 : SaveManager + split Inventory → RunState/MetaState + GUT.
  fait quand: un run modifie RunState sans toucher MetaState ; fermer/relancer conserve MetaState ; jeu actuel jouable de bout en bout ; tests save/load et état verts.
  réf: `roadmap.md` Phase 0, `game/scripts/inventory.gd`, `game/scripts/level.gd`
- [P2] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like. (zone game_art)
  fait quand: idle, run1, run2, jump et attack utilisent tous des sprites cohérents en 40x56/48x56 validés en jeu.
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`

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
- Roadmap v3 créée (11 phases, R1/R2/R3, tests GUT) — design doc dans docs/v3/

## Dernière session (2026-06-27 — design doc v3 + roadmap v3)

# Session du 2026-06-27

## Décisions prises
- Design document v3 rédigé : 4 biomes libres, craft/Grimoire/PC, mort-résurrection/Voile, cicatrices (shaders), boss adaptatif modulaire (2 paramètres).
- Templates assemblés retenus pour la génération de biomes (PCG pur écarté).
- Roadmap v3 créée : 11 phases (0→10) + 3 jalons de refacto (R1/R2/R3) + stratégie de tests GUT intégrée.

## Livrables produits ou modifiés
- docs/v3/CoreDive Challenge — Design Document v3.md : créé
- roadmap.md : recréée pour v3 (phases 0→10, R1/R2/R3, tests, risques)

## Hypothèses validées / invalidées
- VALIDE : pas besoin de rewrite — noyau gameplay conservé, v3 = couche méta-structurelle par-dessus
- VALIDE : cicatrices visuelles = shaders/overlays uniquement, pas de refonte spritesheets
- EN ATTENTE : équilibrage de la boucle méta (Phase 10, ne peut être validé qu'en jeu)

## Prochaine étape exacte
Démarrer Phase 0 (zone jeu) : créer SaveManager, scinder Inventory → RunState/MetaState,
installer GUT et premiers tests. Réf : roadmap.md Phase 0.

## Question bloquante pour la session suivante
Aucune
