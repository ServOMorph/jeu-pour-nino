# Signals — game_art

## Actions ouvertes

- [P1] Phase 4.1 : créer/valider le manifest d'audit.
  fait quand: `game_art/data/manifest.json` existe avec entités/états attendus et tailles de frames validées.
  réf: game_art/roadmap_editeur.md (section 4.1), game_art/data/animations.json, game_art/backlog_art.md.

## Blocages

## Dernière session

# Session du 2026-07-05

## Décisions prises
- Phase 3.3 validée : persistance éditeur, sync + jeu, legacy intact.
- `player.run.fps` conservé à 8.1 après validation utilisateur.

## Livrables produits ou modifiés
- game_art/roadmap_editeur.md : Phase 3.3 cochée, Phase 4 prochaine.
- game_art/editeur/main.gd : layout responsive, `_update_title()` headless-safe.
- game_art/editeur/inspector.gd : panneau droit compact en demi-écran.
- game_art/data/animations.json : `player.run.fps` à 8.1.
- game/data/animations.json : copie synchronisée.

## Hypothèses validées / invalidées
- VALIDÉ : `player.idle` reste legacy après sauvegarde (`frames` chemins texte, pas de `sheet`).

## Prochaine étape exacte
Phase 4.1 : créer/valider le manifest d'audit (`game_art/data/manifest.json`).

## Question bloquante pour la session suivante
Valider les tailles cibles du manifest, notamment `player` 40x56 et les tailles
attendues des ennemis/boss.
