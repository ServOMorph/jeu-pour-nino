# Signals - game_art

## Actions ouvertes
- P2 - Generaliser le workflow `generation_animation.md` a d'autres animations du player et aux mobs.
  fait quand: au moins une seconde animation multi-frames hors `player/run` est produite avec generation separee, normalisation automatique et validation editeur.
  ref: `game_art/commands/generation_animation.md`, `game_art/tools/normalize_animation_frames.py`, `game_art/assets/generated_raw/player/player_run_sheet_candidate_v4.json`

## Blocages

## Derniere session
# Session du 2026-07-12

## Decisions prises
- Le workflow de regeneration d'animation retenu repose sur frames separees, detourage, normalisation automatique controlee et sheet candidate avant validation manuelle.
- La nouvelle animation `player/run` est conservee avec ce workflow puis synchronisee dans le jeu.

## Livrables produits ou modifies
- game_art/commands/generation_animation.md : workflow de generation durci puis etendu avec une phase de normalisation automatique controlee.
- game_art/tools/normalize_animation_frames.py : nouveau script generique de normalisation de frames et d'assemblage de sheet candidate.
- game_art/assets/player/player_run_sheet.png : nouvelle sheet `run` branchee dans l'editeur puis synchronisee vers le jeu.
- game_art/assets/generated_raw/player/ : lots sources, alpha, frames normalisees, sheet candidate et rapport JSON de `player/run`.

## Hypotheses validees / invalidees
- VALIDE : une normalisation automatique legere de taille et de position permet de produire une sheet candidate exploitable pour validation manuelle.
- INVALIDE : exiger une coherence metrique stricte sortie generation suffit a obtenir un lot utilisable pour `player/run` -> pivot vers une normalisation automatique controlee avant validation humaine.

## Prochaine etape exacte
Reutiliser exactement le workflow `generation_animation.md` et le script de normalisation sur une autre animation multi-frames afin de confirmer que la methode est generique.

## Question bloquante pour la session suivante
Aucune
