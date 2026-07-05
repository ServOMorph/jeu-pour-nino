# Roadmap — Éditeur de sprites & animations (game_art)

## Objectif
Outil Godot autonome permettant de visualiser tous les sprites du jeu en taille réelle
(échelle jeu), lire leurs animations à l'identique du jeu, éditer les timings/offsets,
et détecter les sprites manquants ou orphelins. Pas d'édition pixel par pixel
(les graphismes sont produits par Codex/ChatGPT).

## Décisions d'architecture (actées)

- **Moteur** : Godot 4.5 (même version que le jeu). Binaire : `D:\tmp\godot45\Godot_v4.5-stable_win64.exe` (voir `run_editeur.py`).
- **Source de vérité** : `game_art/` est la racine. Sprites dans `game_art/assets/`,
  `animations.json` dans `game_art/data/`. Le jeu consomme une copie synchronisée
  (`sync.py` → `game/assets/sprites/` + `game/data/animations.json`).
- **Projet éditeur** : `game_art/project.godot` → `res://` = `game_art/`.
- **Convention de chemins** : `animations.json` contient des chemins **au format jeu**
  (`res://assets/sprites/...`) car c'est le jeu qui est le consommateur final. L'éditeur
  traduit via `AnimationDriverEditor._editor_path()` : `res://assets/sprites/` → `res://assets/`.
  Ne jamais écrire de chemins format éditeur dans `animations.json`.
- **Chargement des textures dans l'éditeur** : direct depuis le disque
  (`Image.load_from_file` + `ImageTexture`, voir `_load_tex()`), volontairement hors
  système d'import Godot. Permet de voir un PNG ajouté/modifié sans réimport. Le filtre
  nearest est garanti par le SubViewport (`canvas_item_default_texture_filter = NEAREST`).
- **Format sprites** : spritesheets (grille de frames par PNG). L'existant un-PNG-par-frame
  reste supporté (rétro-compatibilité, voir schéma ci-dessous).
- **Échelle d'affichage** : viewport jeu = 480×270 nearest. Preview éditeur = SubViewport
  200×200 avec zoom x1 / x3 / x6 / x8 (x3 ≈ rendu écran réel du jeu en 1440p... valeur
  indicative ; le zoom agit sur `custom_minimum_size` du SubViewportContainer, stretch actif).
- **Périmètre** : visualisation + lecture animations + édition fps/loop/offset/ordre
  des frames (sauvegarde dans `animations.json`) + détection manquants/orphelins.
- **UI programmatique** : toute l'UI est construite en GDScript dans `main.gd`
  (`_build_ui()`). `main.tscn` ne contient que le nœud racine + script. Conserver
  ce principe (pas de layout dans le .tscn).

## État des lieux (2026-07-03)

### Fait
- **Phase 0** ✅ : `project.godot` créé, assets migrés dans `game_art/assets/`,
  `animations.json` dans `game_art/data/`, `sync.py` opérationnel et branché dans `run_game.py`,
  jeu validé identique après migration.
- **Phase 1** ✅ : `game/scripts/animation_driver.gd` (jeu) supporte `sheet`/`frame_size`/
  indices via AtlasTexture, rétro-compatible liste de PNG. État `run` du player migré
  (`player_run_sheet.png` 28×24, `frame_size` [14, 24], frames [0, 1]). Validé en jeu.
- **Phase 2.1** ✅ : rendu gris corrigé. Cause : `class_name AnimationDriverEditor` non
  résolu (cache `.godot/` absent) → erreur de parse GDScript → `main.gd` ne s'exécutait
  jamais. Correctif : `preload()` du script + typage dessus. Chevauchement visuel
  labels galerie/inspecteur corrigé : `HSplitContainer` unique à 3 enfants (non
  supporté) remplacé par deux `HSplitContainer` imbriqués. Validé par capture d'écran :
  toolbar, galerie (4 entités, jusqu'à 7 états), preview animée, 3 panneaux distincts.

### Fichiers de l'éditeur existants
| Fichier | Contenu actuel |
| --- | --- |
| `editeur/main.tscn` | Nœud racine `VBoxContainer` plein écran + script `main.gd`. Rien d'autre. |
| `editeur/main.gd` | UI complète programmatique : toolbar (zoom x1/x3/x6/x8, boutons \|< II/> >\|), HSplit 3 panneaux (galerie entité+état / preview SubViewport 200×200 / inspecteur placeholder), chargement `animations.json`, sélection entité/état → `_driver.play_state()`, pause, frame par frame. |
| `editeur/animation_driver.gd` | `AnimationDriverEditor` (extends AnimatedSprite2D, `class_name`) : reconstruit un `SpriteFrames` depuis `animations.json` (sheet AtlasTexture + fallback PNG), applique offset, traduit les chemins jeu→éditeur, charge les textures hors import. |

### Bug bloquant connu : fenêtre grise au lancement — RÉSOLU (2026-07-03)
Voir Phase 2.1 ci-dessus.

### Assets réels (à date)
- `assets/player/` : idle, idle_v2, jump, attack, run1, run2 (PNG unitaires) + `player_run_sheet.png`.
- `assets/enemies/` : enemy_ground, enemy_flyer, boss_guardian (1 PNG chacun).
- `assets/objects/` : ore_copper, ore_iron, workbench. `assets/tiles/` : biome1_ground, biome1_wall. `assets/ui/` : icon_coin, icon_potion.
- `assets/from_reference/` et `assets/generated_raw/` : références et bruts de génération —
  **ne doivent pas partir dans le build du jeu** (voir tâche sync, Phase 2.4).
- `animations.json` : 4 entités (player, enemy_ground, enemy_flyer, boss), la plupart des
  états pointent vers le même PNG unique (placeholders). Seul `player.run` est en spritesheet.

---

## Schéma `animations.json` (référence)

Structure racine : `{ "<entity>": { "default_state": "<state>", "states": { ... } } }`.

État format spritesheet :
```json
"run": {
  "fps": 8.0,
  "loop": true,
  "offset": [0.0, 0.0],
  "sheet": "res://assets/sprites/player/player_run_sheet.png",
  "frame_size": [14, 24],
  "frames": [0, 1]
}
```
État format legacy (rétro-compatible, tant que la migration n'est pas finie) :
```json
"idle": {
  "fps": 1.0,
  "loop": true,
  "offset": [0.0, -16.0],
  "frames": ["res://assets/sprites/player/player_idle_v2.png"]
}
```
Règles :
- Si `sheet` présent : `frames` = liste d'indices row-major dans la grille. Colonnes =
  `largeur_png / frame_size[0]` (division entière). Région frame i =
  `Rect2((i % cols) * fw, (i / cols) * fh, fw, fh)`.
- Si `sheet` absent : `frames` = liste de chemins `res://assets/sprites/...`.
- `frame_size` = taille d'une frame en pixels jeu (découpe). `offset` = ancrage à l'écran
  (placement) — ne pas confondre.
- Tous les nombres flottants (`fps`, `offset`) restent des floats dans le JSON.

---

## Phases

### Phase 0 — Cadrage & migration stockage ✅
(Détail archivé — voir git `95d4ad4` et antérieurs.)

### Phase 1 — Support spritesheets dans le jeu ✅
(Détail archivé — driver jeu étendu, état `run` migré, validé en jeu.)

---

### Phase 2 — Éditeur : visualisation (EN COURS)

#### 2.1 Débugger le rendu gris (bloquant, à faire en premier) ✅

Diagnostic — lancer Godot avec sortie console visible et lire les erreurs :
```
D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path "d:\ServOMorph\Jeu pour Nino\game_art" --verbose
```
(ou `python run_editeur.py` depuis un terminal — les erreurs GDScript s'affichent sur stderr).

Suspects, par ordre de probabilité :

1. **`class_name AnimationDriverEditor` non résolu au lancement `--path`.**
   `main.gd:9` déclare `var _driver: AnimationDriverEditor`. Ce type global n'est connu
   que via le cache `.godot/global_script_class_cache.cfg`, construit par l'import de
   l'éditeur Godot. Si le projet est lancé directement sans que l'éditeur Godot ait
   jamais indexé le projet (ou après suppression de `.godot/`), `main.gd` échoue à
   compiler → le script racine ne tourne pas → fenêtre grise, avec une erreur de parse
   dans la console.
   **Correctif (à appliquer même si un autre suspect est confirmé, pour robustesse)** :
   supprimer la dépendance au nom global dans `main.gd` :
   ```gdscript
   const AnimationDriverEditorScript := preload("res://editeur/animation_driver.gd")
   var _driver: AnimatedSprite2D
   ...
   _driver = AnimationDriverEditorScript.new()
   ```
   (typer `_driver` en `AnimatedSprite2D` ; les appels `load_entity`/`play_state`
   fonctionnent en duck typing, ou caster localement.)

2. **uid fabriqué à la main dans `main.tscn`** : `uid="uid://editeur_main_v1"` n'est pas
   un uid généré par Godot. Si la console montre une erreur de chargement de la scène
   principale : supprimer l'attribut `uid` de la ligne 1 (Godot le régénérera) ou laisser
   l'éditeur Godot réécrire le fichier.

3. **Cache d'import absent** : si la console montre des erreurs d'import en cascade,
   ouvrir une fois le projet dans l'éditeur Godot (`Godot_v4.5...exe --path game_art --editor`)
   pour générer `.godot/`, puis relancer.

Validation 2.1 : `python run_editeur.py` affiche la toolbar, les deux listes (entités,
états) peuplées depuis `animations.json`, et le sprite de l'entité sélectionnée animé
au centre. Aucune erreur dans la console.

#### 2.2 Compléter la visualisation

Le gros de la galerie/preview existe déjà dans `main.gd`. Reste :

- [x] **Affichage des infos de frame** : Label sous la preview :
      `frame courante / total — taille frame (px jeu) — fps — loop`.
      Taille : si `sheet`, lire `frame_size` du JSON ; sinon `texture.get_size()` de la
      frame courante. Mettre à jour via le signal `frame_changed` d'AnimatedSprite2D.
- [x] **Fond de preview** : ajouter derrière le sprite un damier de contraste
      (TextureRect avec petite texture damier générée en code 2×2 px répétée, ou
      ColorRect sombre) pour juger les contours — le fond transparent actuel rend
      sur le gris fenêtre.
- [x] **État play/pause visible** : le bouton `II / >` doit refléter l'état (texte `II`
      quand ça joue, `>` quand pausé). Reprendre la lecture après frame-par-frame remet
      `speed_scale = 1.0`.
- [x] **Gestion des textures manquantes** : si `_load_tex()` retourne null (PNG absent),
      afficher la frame en damier magenta (texture placeholder générée) au lieu de
      l'ignorer silencieusement, et logger `push_warning("sprite manquant: " + path)`.
      C'est la première brique de l'audit (Phase 4).
- [ ] **Découpage en fichiers** : quand `main.gd` dépasse ~250 lignes, extraire
      `gallery.gd` (les deux ItemList + signaux `entity_selected(key)` /
      `state_selected(key)`) et `preview.gd` (SubViewport + driver + zoom + contrôles
      lecture). `main.gd` ne garde que l'assemblage et le câblage des signaux.
      Ne pas extraire tant que le bug 2.1 n'est pas réglé (une seule variable à la fois).

#### 2.3 Vérification visuelle contre le jeu

- [x] Lancer le jeu (`python run_game.py`) et l'éditeur côte à côte : `player.run` doit avoir
      le même timing (8 fps, 2 frames) et le même rendu pixel (nearest, pas de flou).
      Le zoom x1 éditeur = taille pixel jeu 1:1.
      Validé le 2026-07-05, après correctif du zoom éditeur (voir ci-dessous).

Bug corrigé au passage : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé
faisait que Godot redimensionnait le `SubViewport` interne à la taille du container au lieu
de garder un rendu 200x200 zoomé — le sprite paraissait minuscule dans un grand canvas.
Fix : `_preview_container.stretch_shrink = int(z)` dans `_set_zoom` (`main.gd`).

#### 2.4 Assainir la synchro (dette Phase 0 découverte)

`sync.py` copie actuellement **tout** `game_art/assets/` vers `game/assets/sprites/`,
y compris `from_reference/`, `generated_raw/`, `sprite_contact_sheet.png` et les
fichiers `.import` du projet éditeur (qui polluent le projet jeu).

- [x] Dans `sync.py`, exclure de la copie : dossiers `from_reference`, `generated_raw`,
      tout fichier `*.import`, `sprite_contact_sheet.png` et
      `sprite_generation_manifest.json`. Utiliser `shutil.copytree(..., ignore=shutil.ignore_patterns(...))`.
- [x] Vérifier après sync que le jeu tourne toujours (`python run_game.py`) et que
      `game/assets/sprites/` ne contient plus les dossiers de référence.

#### Fait quand (Phase 2)
L'éditeur se lance sans erreur via `run_editeur.py`, liste toutes les entités/états de
`animations.json`, joue chaque animation à l'identique du jeu (fps, loop, offset, nearest),
zoom x1/x3/x6/x8 et frame-par-frame opérationnels, sprites manquants signalés visuellement,
sync.py ne copie plus les fichiers hors build.

#### Dépend de
Phases 0, 1.

---

### Phase 3 — Éditeur : édition métadonnées

#### 3.1 `inspector.gd` — panneau d'édition

Remplacer le placeholder du panneau droit. Pour l'état sélectionné, éditer :

- [ ] `fps` : SpinBox (min 0.1, max 60, step 0.5, arrow keys OK).
- [ ] `loop` : CheckBox.
- [ ] `offset` : deux SpinBox X / Y (min -128, max 128, step 1.0).
- [ ] `frames` (ordre et sélection) : ItemList listant les frames de l'état
      (indice + miniature si sheet), boutons Monter / Descendre / Retirer / Ajouter.
      « Ajouter » : pour un sheet, choisir un indice de la grille (SpinBox borné par
      `cols * rows - 1`) ; pour le format legacy, hors périmètre (lecture seule de
      la liste de chemins — la migration spritesheet rendra ce cas obsolète).
- [ ] Pour un état spritesheet : `frame_size` éditable (deux SpinBox) avec re-découpe
      immédiate de la preview.
- [ ] Signal `state_edited(entity, state, cfg)` émis à chaque modification.

Architecture des données : `main.gd` reste propriétaire du Dictionary `_entities`
(parse unique de `animations.json`). L'inspecteur reçoit une référence au sous-dict de
l'état et le modifie en place ; `main.gd` déclenche preview + sauvegarde. Le driver
(`AnimationDriverEditor`) doit gagner une méthode `load_from_dict(entity_cfg: Dictionary)`
pour recharger depuis la donnée en mémoire au lieu de relire le fichier (sinon la preview
ne reflète pas les éditions non sauvées).

#### 3.2 Sauvegarde sûre

- [ ] Bouton « Sauvegarder » (+ raccourci Ctrl+S via `_unhandled_key_input`) et indicateur
      de modifications non sauvées (astérisque dans le titre de fenêtre :
      `get_window().title`).
- [ ] Écriture dans `res://data/animations.json` :
      `JSON.stringify(_entities, "  ")` + newline final. Écrire d'abord dans
      `animations.json.tmp`, puis remplacer le fichier (via `DirAccess.rename_absolute`)
      — jamais d'écriture directe tronquante.
- [ ] Contrainte de format : les Dictionary GDScript préservent l'ordre d'insertion,
      donc relire-modifier-réécrire conserve l'ordre des clés. Vérifier au premier
      aller-retour qu'un `git diff` sur une sauvegarde sans modification est vide
      (ou limité à des différences de représentation float — si c'est le cas, le
      constater et l'accepter en une fois : commit de normalisation).
- [ ] Rechargement live : après sauvegarde ou édition, la preview repart sur l'état
      courant à la frame 0.

#### 3.3 Tests manuels de bout en bout

- [ ] Modifier `player.run` fps 8→4, sauver, relancer l'éditeur : la valeur persiste.
- [ ] `python sync.py` puis `python run_game.py` : le jeu reflète le nouveau timing.
- [ ] Vérifier que le format legacy (états à liste de chemins) survit intact à une
      sauvegarde (pas de conversion accidentelle).

#### Fait quand
Éditer fps/loop/offset/frames dans l'inspecteur se voit immédiatement dans la preview,
se sauvegarde proprement dans `game_art/data/animations.json` (diff minimal), et se
propage au jeu via sync.

#### Dépend de
Phase 2.

---

### Phase 4 — Éditeur : détection (audit)

#### 4.1 `data/manifest.json` — référentiel des attendus

- [ ] Créer le fichier : pour chaque entité, la liste des états attendus et la taille
      de frame cible. Format :
      ```json
      {
        "player": {
          "frame_size": [40, 56],
          "states": ["idle", "run", "jump", "fall", "attack", "hurt", "dead"]
        },
        "enemy_ground": { "frame_size": [24, 24], "states": ["idle", "walk", "hurt", "dead"] }
      }
      ```
      Contenu initial : reprendre les entités/états actuels de `animations.json` +
      les besoins listés dans `backlog_art.md` (player 40×56 cible Terraria-like).
      Les `frame_size` cibles sont à valider avec l'utilisateur avant remplissage.

#### 4.2 `audit.gd` — moteur de vérification

Fonction pure `run_audit(manifest: Dictionary, animations: Dictionary, assets_root: String) -> Array[Dictionary]`
retournant une liste d'anomalies `{severity, entity, state, message}` :

- [ ] **État manquant** : présent dans manifest, absent de `animations.json`.
- [ ] **Sprite manquant** : état déclaré dont le PNG (`sheet` ou chemin de frame)
      n'existe pas sur disque (réutiliser `_editor_path()` pour la traduction).
- [ ] **Sprite orphelin** : PNG sous `assets/` (hors `from_reference/`, `generated_raw/`)
      référencé par aucun état. Parcours disque : `DirAccess` récursif.
- [ ] **Taille incohérente** : frame réelle ≠ `frame_size` du manifest ; grille sheet
      non entière (`largeur_png % frame_size[0] != 0`, idem hauteur) ; indices de
      `frames` hors grille.
- [ ] **Placeholder détecté** (info) : plusieurs états d'une entité pointant vers le
      même PNG unique (signe d'un sprite pas encore produit).

#### 4.3 Vue audit

- [ ] Onglet ou panneau dédié (TabContainer englobant preview/audit, ou bouton toolbar
      ouvrant une AcceptDialog avec Tree) listant les anomalies triées par sévérité,
      cliquables → sélectionne l'entité/état correspondant dans la galerie.
- [ ] Bouton « Exporter » : écrit `game_art/audit_report.md` (liste à cocher par entité)
      pour piloter le travail de Codex. Fichier ignoré par git ou pas — à trancher au
      moment venu (proposer : versionné, il sert de TODO art).

#### Fait quand
L'audit repère un état retiré à la main du JSON, un PNG supprimé, un PNG ajouté non
référencé et un `frame_size` faux — vérifié en provoquant chaque cas une fois.

#### Dépend de
Phases 2, 3 (l'audit sans navigation cliquable est acceptable si 3 prend du retard —
seule la sélection galerie est requise, donc dépendance stricte : Phase 2).

---

### Phase 5 — Finitions

- [ ] **Comparaison côte à côte** : second SubViewport dans le panneau preview affichant
      le PNG de `assets/from_reference/` correspondant (convention de nommage :
      `<nom>_ref.png` dans le sous-dossier miroir). Même zoom appliqué aux deux.
- [ ] **Fiche de specs par entité** : export Markdown (`game_art/specs/<entity>.md`) —
      taille frame, liste des états avec fps/loop/nb frames, chemins des sheets,
      anomalies d'audit ouvertes. Sert de brief Codex.
- [ ] **Migration spritesheet complète** : convertir les états legacy restants
      (player idle/jump/attack..., ennemis, boss) au format sheet au fil de la production
      des nouveaux sprites par Codex — pas de conversion mécanique des placeholders
      actuels (sans valeur). Quand plus aucun état legacy ne subsiste, retirer le
      chemin rétro-compatible des deux drivers (jeu + éditeur) dans le même commit.
- [ ] **Documentation d'usage** : `game_art/README.md` — lancer l'éditeur, éditer,
      sauver, auditer, synchroniser, conventions de chemins et de nommage.

#### Fait quand
Un cycle complet « Codex produit un sheet → dépôt dans `assets/` → visualisation/réglage
dans l'éditeur → audit vert → sync → validation en jeu » est documenté et exécuté une fois.

---

## Commandes de référence

| Action | Commande |
| --- | --- |
| Lancer l'éditeur | `python run_editeur.py` (console visible pour les erreurs GDScript) |
| Ouvrir le projet éditeur dans Godot | `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path game_art --editor` |
| Lancer le jeu (sync incluse) | `python run_game.py` |
| Sync seule | `python sync.py` |

## Risques / angles morts

- **Drift `game/assets`** : édition manuelle de la copie générée. Traiter comme build
  (gitignore en place depuis Phase 0).
- **`_editor_path()` fragile** : la traduction `res://assets/sprites/` → `res://assets/`
  repose sur un `replace()`. Si l'arborescence change d'un côté sans l'autre, les
  textures ne chargent plus silencieusement. Le correctif « texture manquante = damier
  magenta + warning » (Phase 2.2) rend la casse visible.
- **Deux projets Godot** : `game_art/.godot/` et `game/.godot/` sont des caches d'import
  séparés — normal. Les `.import` ne doivent pas être synchronisés (Phase 2.4).
- **`frame_size` vs `offset`** : taille de découpe ≠ ancrage écran. L'affichage des deux
  dans l'inspecteur (Phase 3) évite la confusion.
- **Divergence des drivers** : `game/scripts/animation_driver.gd` (jeu) et
  `game_art/editeur/animation_driver.gd` (éditeur) implémentent deux fois la même découpe.
  Toute évolution du schéma (`sheet`, `frame_size`...) doit être portée dans les deux.
  Fusion en un module partagé volontairement écartée (deux projets Godot distincts) ;
  discipline : modifier les deux dans le même commit.
- **Sauvegarde JSON** : `JSON.stringify` peut reformater les floats. Premier aller-retour
  à contrôler par `git diff` (Phase 3.2).

## Hors périmètre
- Édition pixel par pixel (assurée par Codex/ChatGPT).
- Génération automatique de sprites.
- Tests GUT sur l'éditeur (outil interne ; la logique testable — audit — reste en
  fonctions pures, testables plus tard si besoin).
