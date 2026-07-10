# Signals - game_art

## Actions ouvertes

- [P1] Valider manuellement la nouvelle animation `idle`.
  fait quand: dans `python run_editeur.py`, l'etat `player/idle` est juge fluide sans saut visible d'echelle, de cadrage ni d'ancrage sur la sequence `0,1,2,3,5`.
  ref: game_art/assets/player/player_idle_sheet.png, game_art/data/animations.json.
- [P2] Valider manuellement l'animation `attack` regeneree.
  fait quand: dans `python run_editeur.py`, l'etat `player/attack` est juge fluide sans saut visible d'echelle, de cadrage, d'ancrage au sol ou de longueur d'epee sur la sequence `0,1,2,3,3,3,2,1,0`.
  ref: game_art/assets/player/player_attack_sheet.png, game_art/data/animations.json.
- [P3] Verifier le flux `Recharger` en session ouverte.
  fait quand: une modification d'asset ou de `animations.json` devient visible dans l'editeur via le bouton `Recharger`, sans fermer Godot.
  ref: game_art/editeur/main.gd, game_art/editeur/inspector.gd.

## Blocages

## Derniere session
# Session du 2026-07-10

## Decisions prises
- L'animation `player/idle` est refaite en 6 frames dans une pose de guerrier en attente concentre.
- La frame `4.0` du nouvel `idle` est exclue de la lecture a cause d'un decalage lateral visible.
- La sequence runtime retenue pour `player/idle` est desormais `0,1,2,3,5` a `5 fps`.

## Livrables produits ou modifies
- game_art/assets/player/player_idle_sheet.png, game_art/data/animations.json, game/data/animations.json : etat `player/idle` remplace par une nouvelle sheet 6 frames ; lecture finale `0,1,2,3,5` a `5 fps`.
- game_art/assets/generated_raw/player/player_idle_6f_raw.png : source brute conservee pour la regeneration de `idle`.
- game_art/specs/player.md et game_art/specs/boss.md : exports de specs realignes sur l'etat courant des animations et offsets.

## Hypotheses validees / invalidees
- VALIDE : le nouveau set `idle` tient le gabarit `87x150` et s'integre au pipeline sheet du player.
- INVALIDE : la frame `4.0` du nouveau `idle` est exploitable telle quelle -> pivot vers une lecture qui l'ignore.
- EN ATTENTE : validation manuelle du ressenti exact de `player/idle` et `player/attack` dans l'editeur.

## Prochaine etape exacte
Lancer `python run_editeur.py`, cliquer `Recharger`, puis lire `player/idle` pour valider
la fluidite de la sequence `0,1,2,3,5`. Enchaine ensuite avec `player/attack` pour confirmer
que les deux etats du player sont visuellement stables en maintenance.

## Question bloquante pour la session suivante
Aucune
