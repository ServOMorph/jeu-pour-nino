# Signals - game_art

## Actions ouvertes
- [P1] Completer l'habillage runtime de `Tileset et decors - Biome 1 Galeries Verdoyantes`.
  fait quand: les plateformes et masses de decor du biome 1 ne reposent plus sur des rects/polygones colores visibles en jeu.
  ref: `game_art/backlog_art.md`, `game_art/assets/tiles/biome1_parallax_*.png`, `game_art/assets/generated_raw/biome1/`.

## Blocages

## Derniere session
# Session du 2026-07-14

## Decisions prises
- Une passe decor/parallax biome 1 est produite en `3` couches separees puis precomposees en grandes bandes pour limiter les jonctions visibles.
- La passe actuelle du biome 1 est notee comme validee visuellement.
- L'entree backlog `Tileset et decors - Biome 1 Galeries Verdoyantes` reste toutefois ouverte, car le placeholder de geometrie coloree n'est pas encore remplace.

## Livrables produits ou modifies
- `game_art/assets/tiles/biome1_parallax_{far,mid,fore}.png` : couches decor/parallax finales du biome 1, precomposees en bandes `12800x1080`.
- `game_art/assets/generated_raw/biome1/biome1_parallax_{far,mid,fore}_{raw,alpha}.png` : sources brutes et detourees conservees pour le biome 1.
- `game_art/backlog_art.md`, `game_art/_contexte/contexte.md`, `game_art/_contexte/signals.md`, `game_art/roadmap_editeur.md` et `CHANGELOG.md` : protocole de reprise realigne sur l'etat reel de la passe biome 1.

## Hypotheses validees / invalidees
- VALIDE : precomposer les couches parallax du biome 1 en grandes bandes attenue les raccords visuels les plus visibles.
- VALIDE : la passe actuelle du biome 1 est jugee visuellement exploitable.
- EN ATTENTE : remplacement complet des placeholders de geometrie du biome 1.

## Prochaine etape exacte
Completer l'habillage runtime du biome 1 pour sortir du placeholder de geometrie
coloree, puis seulement reevaluer si l'entree `Tileset et decors - Biome 1 Galeries
Verdoyantes` peut passer a `livre`.

## Question bloquante pour la session suivante
Aucune
