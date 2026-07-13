# Signals - game_art

## Actions ouvertes

## Blocages

## Derniere session
# Session du 2026-07-13

## Decisions prises
- `game/` est resynchronise sur l'etat courant de `game_art` pour `player/run` et `player/jump`.
- La verification runtime confirme `player/run` et `player/jump` sans regression visible.
- `player/attack` passe en cases `150x150` par elargissement lateral de la sheet, sans retouche des pixels source.
- `player/attack` est valide manuellement apres ce nouveau gabarit.

## Livrables produits ou modifies
- `game/data/animations.json` et `game/assets/sprites/player/player_{run,jump}_sheet.png` : runtime realigne sur l'etat valide de `game_art`.
- `game_art/assets/player/player_attack_sheet.png` : sheet `attack` elargie de `129x150` a `150x150`.
- `game_art/data/animations.json`, `game/data/animations.json` et `game_art/specs/player.md` : gabarit `attack` realigne en `150x150`.
- `game_art/backlog_art.md`, `game_art/_contexte/contexte.md`, `game_art/_contexte/signals.md` et `game_art/roadmap_editeur.md` : suivi de maintenance realigne sur l'etat valide.

## Hypotheses validees / invalidees
- VALIDE : la sync vers `game/` remet bien `player/run` et `player/jump` au niveau de `game_art`, puis le jeu les lit correctement.
- VALIDE : elargir `player/attack` a `150x150` sans retoucher les pixels suffit a redonner de la marge laterale utile.
- EN ATTENTE : la prochaine session doit repartir sur une nouvelle entree `a_faire` du backlog art, pas sur une maintenance player residuelle connue.

## Prochaine etape exacte
Ouvrir une nouvelle session de production sur la prochaine entree `a_faire` du
`backlog_art.md`, en priorite `Tileset et decors - Biome 1 Galeries Verdoyantes`
si la roadmap jeu n'a pas change d'ici la reprise.

## Question bloquante pour la session suivante
Aucune
