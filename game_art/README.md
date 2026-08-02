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
4. Verifier la preview `Produit`.
5. Ajuster `fps`, `loop`, `offset`, `frame_size` et l'ordre des frames si necessaire.
6. Sauvegarder.
7. Lancer l'audit.
8. Exporter `audit_report.md` si besoin.
9. Exporter les fiches `specs/<entity>.md` si besoin.
10. Lancer `python sync.py`.
11. Valider dans le jeu avec `python run_game.py`.

## Workflow sprites 2D standard

- Produire les sprites en source HD sur fond detourable, puis detourer et redimensionner exactement a la taille runtime.
- Pour une refonte d'animation, regenerer le lot complet depuis une reference maitre validee et un controle temporel fixe ; ne jamais corriger ou reutiliser une frame finale isolee.
- Valider en priorite la lisibilite a taille reelle dans la preview `Produit`, puis dans le jeu.
- `assets/generated_raw/` conserve les sources de generation et ne part pas dans le build du jeu.

## Etat actuel

La Phase 7 est en cours sur `player/run`. Wan2.2-Animate 14B quantifie fonctionne localement sur RTX 4060 8 Go avec offload RAM, mais aucun candidat n'a encore passe simultanement la validation visuelle et les seuils geometriques. La sheet runtime actuelle reste inchangee. Prochaine iteration : mode remplacement avec controle realiste pre-normalise, puis audit DWPose du lot complet.

## Edition

- Les metadonnees d'animation sont dans `data/animations.json`.
- Le bouton `Sauvegarder` ecrit dans `data/animations.json`.
- `Ctrl+S` sauvegarde aussi.
- Les etats legacy restent supportes via `frames` = liste de PNG.
- Les etats spritesheet utilisent `sheet`, `frame_size` et `frames` = indices.
- Le bouton `Editer sheet` (actif uniquement si l'etat a une `sheet`) ouvre un dialog de retouche
  geometrique des frames de l'etat selectionne : redimensionnement uniforme (poignee) et deplacement,
  contraints a rester dans la case `frame_size` d'origine. `Valider` reecrit le PNG source sur disque ;
  `Annuler` ou la fermeture du dialog n'ecrit rien. Complement manuel au workflow de normalisation
  automatique (`game_art/tools/normalize_animation_frames.py`), ne le remplace pas.

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
- `assets/from_reference/` et `assets/generated_raw/` ne partent pas dans le build du jeu.

## Tests utiles

- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit_ui.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_preview_center.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_specs_export.gd`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_sheet_editor.gd`
