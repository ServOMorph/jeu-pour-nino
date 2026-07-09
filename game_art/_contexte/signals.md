# Signals - game_art

## Actions ouvertes

- [P1] Valider manuellement l'animation `attack` regeneree.
  fait quand: dans `python run_editeur.py`, l'etat `player/attack` est juge fluide sans saut visible d'echelle, de cadrage, d'ancrage au sol ou de longueur d'epee sur la sequence `0,1,2,3,3,3,2,1,0`.
  ref: game_art/assets/player/player_attack_sheet.png, game_art/data/animations.json.
- [P2] Verifier le flux `Recharger` en session ouverte.
  fait quand: une modification d'asset ou de `animations.json` devient visible dans l'editeur via le bouton `Recharger`, sans fermer Godot.
  ref: game_art/editeur/main.gd, game_art/editeur/inspector.gd.

## Blocages

## Derniere session
# Session du 2026-07-09

## Decisions prises
- Le bouton `Recharger` devient le flux standard pour voir les modifs d'assets et de `animations.json` sans redemarrer l'editeur.
- L'animation `player/attack` est regeneree depuis une frame de reference plutot que corrigee frame par frame.
- L'ordre de lecture vise pour `player/attack` est desormais `0,1,2,3,3,3,2,1,0`.

## Livrables produits ou modifies
- game_art/editeur/main.gd, game_art/editeur/inspector.gd : selection de frame branchee sur la preview et bouton `Recharger` ajoute.
- game_art/assets/player/player_attack_sheet.png, game_art/data/animations.json, game/data/animations.json : etat `player/attack` regenere a partir d'une frame de reference, sequence `0,1,2,3,3,3,2,1,0`.
- game_art/assets/generated_raw/player/player_attack_regen_f0_raw.png, player_attack_regen_f1_raw.png, player_attack_regen_f2_raw.png : sources HD conservees pour la regeneration de `attack`.

## Hypotheses validees / invalidees
- VALIDE : un bouton `Recharger` suffit pour les modifs d'assets et de `animations.json` sans relance Godot.
- INVALIDE : corriger des frames isolees de `attack` conserve un gabarit coherent -> pivot vers regeneration complete depuis une frame de reference.
- EN ATTENTE : validation manuelle de la fluidite de `player/attack` apres regeneration complete.

## Prochaine etape exacte
Lancer `python run_editeur.py`, cliquer `Recharger`, puis lire `player/attack` pour valider
la fluidite de la sequence `0,1,2,3,3,3,2,1,0`. Si l'anim est validee, passer a la prochaine
entree art prioritaire du backlog.

## Question bloquante pour la session suivante
Aucune
