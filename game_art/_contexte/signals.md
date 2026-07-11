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
# Session du 2026-07-11

## Decisions prises
- Les 4 attaques directionnelles du player et `player/idle` sont validees manuellement dans l'editeur.
- Le decor du HUB est livre comme fond fixe `1920x1080`.
- L'atelier runtime est regenere en plus grand format et realigne cote jeu.

## Livrables produits ou modifies
- game_art/assets/player/player_attack_up_sheet.png, game_art/assets/generated_raw/player/attack_up_regen_strip_raw.png, attack_up_regen_f0_raw.png, attack_up_regen_f1_raw.png, attack_up_regen_f2_raw.png, attack_up_regen_f3_raw.png : `player/attack_up` regenere completement pour corriger la frame `0.0`.
- game_art/assets/tiles/hub_decor.png, game_art/assets/generated_raw/hub_decor_raw.png : decor du HUB produit en `1920x1080`.
- game_art/assets/objects/workbench.png, game_art/assets/generated_raw/workbench_raw.png, game/scripts/workbench.gd, game/data/level.json : atelier regenere en `160x144`, collision/zone et ancrage runtime realignes.

## Hypotheses validees / invalidees
- VALIDE : les 4 attaques directionnelles sont jugees fluides et coherentes en lecture editeur.
- VALIDE : `player/idle` est juge fluide sur `0,1,2,3,5`.
- VALIDE : l'atelier peut etre agrandi a `160x144` si le runtime suit avec collision et position reajustees.
- EN ATTENTE : validation manuelle de `player/attack`, puis verification du flux `Recharger`.

## Prochaine etape exacte
Lancer `python run_editeur.py`, cliquer `Recharger`, puis lire `player/attack` pour verifier
stabilite d'echelle, de cadrage, d'ancrage au sol et de longueur d'epee. En profite
pour confirmer qu'une modification d'asset ou de `animations.json` est bien rechargee
en session ouverte via le bouton `Recharger`.

## Question bloquante pour la session suivante
Aucune
