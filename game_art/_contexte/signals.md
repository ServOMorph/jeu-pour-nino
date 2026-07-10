# Signals - game_art

## Actions ouvertes

- [P1] Valider manuellement les 4 attaques directionnelles regenerees.
  fait quand: dans `python run_editeur.py`, les etats `player/attack_up`, `player/attack_down`, `player/attack_up_diag` et `player/attack_down_diag` sont juges fluides, sans derive visible de silhouette, de cadrage, d'echelle ou d'ancrage sur la sequence `0,1,2,3,3,3,2,1,0`.
  ref: game_art/assets/player/player_attack_up_sheet.png, game_art/assets/player/player_attack_down_sheet.png, game_art/assets/player/player_attack_up_diag_sheet.png, game_art/assets/player/player_attack_down_diag_sheet.png, game_art/data/animations.json.
- [P2] Valider manuellement la nouvelle animation `idle`.
  fait quand: dans `python run_editeur.py`, l'etat `player/idle` est juge fluide sans saut visible d'echelle, de cadrage ni d'ancrage sur la sequence `0,1,2,3,5`.
  ref: game_art/assets/player/player_idle_sheet.png, game_art/data/animations.json.
- [P3] Valider manuellement l'animation `attack` regeneree.
  fait quand: dans `python run_editeur.py`, l'etat `player/attack` est juge fluide sans saut visible d'echelle, de cadrage, d'ancrage au sol ou de longueur d'epee sur la sequence `0,1,2,3,3,3,2,1,0`.
  ref: game_art/assets/player/player_attack_sheet.png, game_art/data/animations.json.
- [P4] Verifier le flux `Recharger` en session ouverte.
  fait quand: une modification d'asset ou de `animations.json` devient visible dans l'editeur via le bouton `Recharger`, sans fermer Godot.
  ref: game_art/editeur/main.gd, game_art/editeur/inspector.gd.

## Blocages

## Derniere session
# Session du 2026-07-10

## Decisions prises
- Les 4 attaques directionnelles du player sont regenerees integralement depuis de nouvelles frames sources, au lieu d'un simple reassemblage des anciennes.
- Les 4 attaques directionnelles adoptent maintenant la meme organisation runtime que `player/attack` : `0,1,2,3,3,3,2,1,0`.
- Les nouvelles sheets directionnelles sont synchronisees dans `game/` pour insertion runtime immediate, meme si leur validation visuelle reste ouverte.

## Livrables produits ou modifies
- game_art/assets/player/player_attack_up_sheet.png, player_attack_down_sheet.png, player_attack_up_diag_sheet.png, player_attack_down_diag_sheet.png : 4 sheets directionnelles regenerees integralement et remplacees.
- game_art/assets/generated_raw/player/attack_*_regen_f*_raw.png : 16 frames sources brutes conservees pour les 4 attaques directionnelles.
- game_art/data/animations.json, game/data/animations.json : lectures runtime des 4 attaques directionnelles alignees sur `0,1,2,3,3,3,2,1,0`.

## Hypotheses validees / invalidees
- VALIDE : les 4 attaques directionnelles peuvent etre reintegrees en runtime avec le meme schema de lecture que `player/attack`.
- INVALIDE : reassembler les anciennes frames directionnelles suffisait -> pivot vers une regeneration complete depuis de nouvelles sources.
- EN ATTENTE : validation manuelle de la coherence visuelle exacte des 4 attaques directionnelles, puis de `idle` et `attack` dans l'editeur.

## Prochaine etape exacte
Lancer `python run_editeur.py`, cliquer `Recharger`, puis lire `player/attack_up`,
`player/attack_down`, `player/attack_up_diag` et `player/attack_down_diag` pour verifier
stabilite de silhouette et d'ancrage. Enchaine ensuite avec `player/idle`, puis `player/attack`.

## Question bloquante pour la session suivante
Aucune
