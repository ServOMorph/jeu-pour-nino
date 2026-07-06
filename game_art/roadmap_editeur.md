# Roadmap - Editeur de sprites & animations (game_art)

## Objectif
Outil Godot autonome permettant de visualiser tous les sprites du jeu en taille reelle
(echelle jeu), lire leurs animations a l'identique du jeu, editer les timings/offsets,
et detecter les sprites manquants ou orphelins. Pas d'edition pixel par pixel
(les graphismes sont produits par Codex/ChatGPT).

## Etat de progression

- Phase 0 : close
- Phase 1 : close
- Phase 2 : close
- Phase 3 : close
- Phase 4 : close
- Phase 5 : en cours

## Phase 5 - Finitions

- [x] Comparaison cote a cote : second SubViewport dans le panneau preview affichant
      le PNG de `assets/from_reference/` correspondant. Meme zoom applique aux deux.
- [x] Fiche de specs par entite : export Markdown `game_art/specs/<entity>.md`
      avec tailles, etats, timings, sheets et anomalies ouvertes.
- [ ] Migration spritesheet complete : convertir les etats legacy restants
      quand de vrais nouveaux sheets multi-frames seront disponibles.
- [x] Documentation d'usage : `game_art/README.md` pour lancer l'editeur, editer,
      sauver, auditer, synchroniser et suivre les conventions de nommage.

#### Fait quand
Un cycle complet `sheet produit -> depot assets -> visualisation/reglage dans l'editeur
-> audit vert -> sync -> validation en jeu` est execute une fois.

## Commandes de reference

| Action | Commande |
| --- | --- |
| Lancer l'editeur | `python run_editeur.py` |
| Ouvrir le projet editeur dans Godot | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path game_art --editor` |
| Lancer le jeu (sync incluse) | `python run_game.py` |
| Sync seule | `python sync.py` |
| Test audit moteur | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit.gd` |
| Test audit UI | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit_ui.gd` |
| Test preview reference | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_reference_preview.gd` |
| Test export specs | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_specs_export.gd` |

## Point d'attention

La migration spritesheet complete ne doit pas etre simulee avec des placeholders existants.
Elle depend de la production de nouveaux assets reels.
