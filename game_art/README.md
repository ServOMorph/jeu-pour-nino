# game_art

Projet Godot autonome pour visualiser, editer et auditer les sprites et animations du jeu.

## Lancer

- Editeur : `python run_editeur.py`
- Projet Godot : `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path game_art --editor`
- Sync seule : `python sync.py`
- Jeu avec sync : `python run_game.py`

## Flux de travail

1. Deposer les PNG produits dans `game_art/assets/`.
2. Ouvrir l'editeur.
3. Selectionner une entite puis un etat.
4. Verifier la preview `Produit` et la preview `Reference`.
5. Ajuster `fps`, `loop`, `offset`, `frame_size` et l'ordre des frames si necessaire.
6. Sauvegarder.
7. Lancer l'audit.
8. Exporter `audit_report.md` si besoin.
9. Exporter les fiches `specs/<entity>.md` si besoin.
10. Lancer `python sync.py`.
11. Valider dans le jeu avec `python run_game.py`.

## Edition

- Les metadonnees d'animation sont dans `data/animations.json`.
- Le bouton `Sauvegarder` ecrit dans `data/animations.json`.
- `Ctrl+S` sauvegarde aussi.
- Les etats legacy restent supportes via `frames` = liste de PNG.
- Les etats spritesheet utilisent `sheet`, `frame_size` et `frames` = indices.

## Audit

- Le bouton `Audit` ouvre la vue des anomalies.
- Les anomalies sont triees par severite.
- Un clic sur une anomalie repositionne la selection sur l'entite et l'etat concernes.
- `Exporter` genere `audit_report.md`.
- `Specs` genere `specs/<entity>.md`.

## Conventions

- `game_art/` est la source de verite.
- `animations.json` doit garder des chemins format jeu : `res://assets/sprites/...`
- L'editeur traduit ces chemins vers `res://assets/...`
- Ne jamais ecrire de chemins format editeur dans `animations.json`.
- Les references visuelles sont dans `assets/from_reference/`.
- Convention de nommage reference : `<nom>_ref.png` dans le sous-dossier miroir.
- `assets/from_reference/` et `assets/generated_raw/` ne partent pas dans le build du jeu.

## Nommage spritesheet

- Exemple sheet : `assets/player/player_run_sheet.png`
- Exemple reference associee : `assets/from_reference/player/player_run_ref.png`
- L'editeur sait aussi retomber sur un nom simplifie, par exemple `player_idle_v2.png` vers `player_idle_ref.png`.

## Tests utiles

- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit_ui.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_reference_preview.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_specs_export.gd`
