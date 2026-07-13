# Roadmap - Editeur de sprites & animations (game_art)

## Objectif
Outil Godot autonome permettant de visualiser tous les sprites du jeu en taille reelle
(echelle jeu), lire leurs animations a l'identique du jeu, editer les timings/offsets,
et detecter les sprites manquants ou orphelins. Pas de generation ni de retouche
artistique de sprite (les graphismes sont produits par Codex/ChatGPT) : l'editeur
permet uniquement un ajustement geometrique manuel du cadrage d'une frame deja
generee (redimensionnement uniforme + position, contraint a sa case dans la sheet),
en complement du workflow de normalisation automatique.

## Articulation avec la zone jeu
- `game_art/backlog_art.md` est l'entree de production : les assets a produire viennent
  des phases de `roadmap.md` (racine), jamais de cette roadmap-ci.
- `questions.md` (racine) est la source d'arbitrage commune en cas de doute de conception.
- L'editeur est l'outillage de la chaine `production -> reglage/audit -> sync.py -> validation en jeu`.
  Il ne conditionne aucune phase jeu (regle placeholders de `roadmap.md`).

## Perimetre
Couvert : sprites et animations d'entites (player, ennemis, boss, Gardiens, porteurs)
via `animations.json` + manifest d'audit.
Hors perimetre (valides directement en jeu, pas dans l'editeur) : tilesets et
parallax (phases jeu 4/7), shaders et overlays des cicatrices (phase 6), icones UI
(Grimoire, slots d'equipement, cicatrices), sprites de gisements, projectiles.
Si un besoin de previsualisation apparait pour ces types, ouvrir une phase 6
« Extensions v3 » tiree par la phase jeu concernee — ne pas l'anticiper.

## Regle de synchronisation du manifest
Toute entree de `backlog_art.md` impliquant une entite animee (nouveaux archetypes
ennemis, boss de biome, Gardiens, porteurs, modules du Miroir) ajoute son entite au
manifest d'audit AVANT production des sheets. L'audit « sprites manquants » ne detecte
que ce que le manifest connait : un manifest non tenu a jour rend l'audit vert menteur.

## Etat de progression

- Phase 0 : close
- Phase 1 : close
- Phase 2 : close
- Phase 3 : close
- Phase 4 : close
- Phase 5 : close
- Phase 6 : close

## Phase 5 - Finitions

- [x] Validation en jeu du set player synchronise : cycle `asset -> sync -> verification en jeu`
      execute une fois avec le set joueur HD retenu.
- [x] Fiche de specs par entite : export Markdown `game_art/specs/<entity>.md`
      avec tailles, etats, timings, sheets et anomalies ouvertes.
- [x] Migration spritesheet complete : tous les etats player utilisent maintenant
      `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
      Les etats mono-frame sont encapsules en sheets 1 frame ; cela clot la migration
      de format, pas une eventuelle refonte visuelle future.
- [x] Documentation d'usage : `game_art/README.md` pour lancer l'editeur, editer,
      sauver, auditer, synchroniser et suivre les conventions de nommage.

#### Fait quand
Un cycle complet `sheet produit -> depot assets -> visualisation/reglage dans l'editeur
-> audit vert -> sync -> validation en jeu` est execute une fois.
Support concret retenu : les sprites player standard Terraria-like (entree `livre`
de `backlog_art.md`, signal P3 de `_contexte/signals.md`) — premier remplacement de
placeholder reel, priorite 1 de la regle Q071 (joueur > ennemis > boss > tilesets > UI).

## Phase 6 - Extensions v3

Ouverte par necessite concrete (regle "ne pas anticiper" de la section Perimetre) :
session game_art 2026-07-06 en cours sur les sprites de gisements/minerais
(`Sprites gisements/minerais par type de materiau`, backlog_art.md), besoin de
validation visuelle immediate.

- [x] Previsualisation des sprites de gisements/minerais (objects/ore_*.png) dans
      le panneau preview de l'editeur, a l'echelle jeu.

Perimetre de cette phase : uniquement les gisements/minerais, tires par le besoin
ci-dessus. Tilesets 2D standard, parallax, shaders/overlays cicatrices et icones UI restent hors
perimetre tant qu'aucun besoin concret equivalent n'apparait (cf. Perimetre).

## Apres Phase 5 : maintenance

Une fois la Phase 5 close, l'editeur passe en maintenance : plus d'evolution d'outillage
sauf besoin concret tire par une entree de `backlog_art.md` (cf. Perimetre ci-dessus).
Le temps de la zone game_art va a la production d'assets, pas au polissage de l'outil.
La preview d'entite rend a la resolution affichee et utilise le filtrage lineaire du jeu ;
le test `test_preview_center.gd` couvre le centrage player et le cadrage du boss.

## Commandes de reference

| Action | Commande |
| --- | --- |
| Lancer l'editeur | `python run_editeur.py` |
| Ouvrir le projet editeur dans Godot | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path game_art --editor` |
| Lancer le jeu (sync incluse) | `python run_game.py` |
| Sync seule | `python sync.py` |
| Test audit moteur | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit.gd` |
| Test audit UI | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_audit_ui.gd` |
| Test centrage preview | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_preview_center.gd` |
| Test export specs | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_specs_export.gd` |
| Test edition sheet | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path "D:\ServOMorph\Jeu pour Nino\game_art" --script res://editeur/test_sheet_editor.gd` |

## Point d'attention

La migration de format est close pour le player et ses PNG legacy sont archives hors
audit. Les etats `player/idle`, `player/attack` et les 4 attaques directionnelles sont
valides en lecture editeur. `player/jump` est maintenant une sheet `3` frames et
`player/run` utilise des cases `104x150` pour faciliter l'edition manuelle.
Le bouton `Recharger` est aussi valide en session ouverte.
Point de vigilance runtime actuel : `game_art` et `game` ne sont pas encore realignes
sur `player/run` et `player/jump` ; le jeu lit encore un `run` en `87x150` et un
`jump` mono-frame tant qu'une nouvelle synchro n'a pas ete poussee.
L'editeur est maintenant pilote a la souris uniquement ; les evenements manette y sont bloques.
Le workflow de regeneration d'animation a maintenant ete confirme sur les mobs standards :
`enemy_ground/walk` et `enemy_flyer/fly` sont valides sur l'etat courant apres controle
dans l'editeur.
Le bouton `Editer sheet` permet desormais un ajustement manuel (scale uniforme + position,
contraint a la case) des frames de l'etat selectionne, pour corriger un cadrage sans
regeneration complete ; il ecrit directement le PNG source de la sheet.
