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
- Le preview de l'editeur rend desormais a la resolution affichee et reprend le filtrage lineaire du jeu.
- Les sprites orphelins, doublons et images de test sont retires du depot et de la synchronisation runtime.

## Livrables produits ou modifies
- game_art/editeur/main.gd, game_art/editeur/test_preview_center.gd, game_art/specs/player.md : rendu et cadrage du boss corriges, avec test du non-debordement et du ratio ; comptes de frames player exportes.
- game_art/assets/, game/assets/sprites/, sync.py : sprites non utilises supprimes et archives player exclus de la copie runtime.
- game_art/audit_report.md : rapport obsolete retire.

## Hypotheses validees / invalidees
- VALIDE : le test headless couvre le centrage du player et le boss entier, sans deformation ni debordement.
- VALIDE : le filtrage de preview est aligne sur celui du jeu.
- EN ATTENTE : validation manuelle de `player/attack`, puis verification du flux `Recharger`.

## Prochaine etape exacte
Lancer `python run_editeur.py`, cliquer `Recharger`, puis lire `player/attack` pour verifier
stabilite d'echelle, de cadrage, d'ancrage au sol et de longueur d'epee. En profite
pour confirmer qu'une modification d'asset ou de `animations.json` est bien rechargee
en session ouverte via le bouton `Recharger`.

## Question bloquante pour la session suivante
Aucune
