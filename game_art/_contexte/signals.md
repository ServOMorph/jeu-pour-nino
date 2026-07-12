# Signals - game_art

## Actions ouvertes

## Blocages

## Derniere session
# Session du 2026-07-12

## Decisions prises
- Les controles manette de l'editeur sont desactives a la source.
- L'editeur se pilote desormais uniquement a la souris.

## Livrables produits ou modifies
- game_art/editeur/main.gd : evenements joypad bloques, sans impact sur le pilotage souris.
- game_art/_contexte/, game_art/roadmap_editeur.md et CHANGELOG.md : contexte de maintenance realigne sur un editeur souris uniquement.

## Hypotheses validees / invalidees
- VALIDE : bloquer `InputEventJoypadButton` et `InputEventJoypadMotion` suffit pour desactiver la manette dans l'editeur.
- VALIDE : le pilotage souris reste le mode de controle retenu pour l'outil.

## Prochaine etape exacte
Aucune action ouverte de maintenance player dans l'editeur.

## Question bloquante pour la session suivante
Aucune
