# Roadmap — Éditeur de sprites & animations (game_art)

## Objectif
Outil Godot autonome permettant de visualiser tous les sprites du jeu en taille réelle
(échelle jeu), lire leurs animations à l'identique du jeu, éditer les timings/offsets,
et détecter les sprites manquants ou orphelins. Pas d'édition pixel par pixel
(les graphismes sont produits par Codex/ChatGPT).

## Décisions d'architecture (actées)

- **Moteur** : Godot 4.5 (même version que le jeu).
- **Source de vérité** : `game_art/` est la racine. Les sprites et `animations.json`
  vivent dans `game_art/assets/` et `game_art/data/`. Le jeu consomme une copie
  synchronisée dans `game/assets/` et `game/data/`.
- **Projet éditeur** : `project.godot` à la racine `game_art/` → `res://` = `game_art`.
  L'éditeur voit nativement tous les sprits via `res://assets/...`.
- **Format sprites** : spritesheets (grille de frames par PNG). Remplace le système
  actuel un-PNG-par-frame. Nécessite migration + évolution du schéma et du driver.
- **Échelle d'affichage** : viewport jeu = 480x270, filtre nearest. L'éditeur affiche
  les sprites à l'échelle pixel jeu (1:1) avec zoom commutable (x1 / x3 = écran réel /
  x6 / x8). Lecture de la taille native en pixels jeu.
- **Périmètre** : visualisation + lecture animations + édition fps/loop/offset/ordre
  des frames (sauvegarde dans `animations.json`) + détection sprites manquants/orphelins.

## Cible de structure `game_art/`

```
game_art/
  project.godot                 # racine éditeur (res:// = game_art)
  icon.svg
  assets/
    sprites/
      player/
      enemies/
      objects/
      tiles/
      ui/
      _reference/               # refs Terraria / from_reference, hors build
  data/
    animations.json             # schéma central (source de vérité)
    manifest.json               # liste des entités/états attendus (pilote la détection)
  editeur/
    main.tscn                   # scène racine de l'outil
    main.gd
    gallery.gd                  # galerie de tous les sprites
    preview.gd                  # rendu animé taille réelle (réutilise AnimationDriver)
    inspector.gd                # édition fps/loop/offset/frames
    audit.gd                    # détection manquants/orphelins
    sheet_slicer.gd             # découpe spritesheet -> AtlasTexture
  sync.py                       # game_art -> game (assets + data)
  _contexte/
  screen shot terraria.png      # référence cible
```

## Schéma spritesheet (évolution de `animations.json`)

Nouveau format par état, rétro-compatible (si `sheet` absent, on lit `frames` = liste de chemins) :

```json
"run": {
  "fps": 8.0,
  "loop": true,
  "offset": [0.0, 0.0],
  "sheet": "res://assets/sprites/player/player_run.png",
  "frame_size": [40, 56],
  "frames": [0, 1, 2, 3]
}
```

- `frame_size` : dimensions d'une frame en pixels jeu. La grille (colonnes/lignes) est
  déduite des dimensions du PNG.
- `frames` : indices (row-major) des cases à jouer, dans l'ordre.
- Découpe via `AtlasTexture` (region rect calculée depuis l'indice et `frame_size`).

## Phases

### Phase 0 — Cadrage & migration stockage ✅
- [x] Créer `game_art/project.godot` (Godot 4.5, filtre nearest, viewport 480x270).
- [x] Déplacer `game/assets/sprites/` → `game_art/assets/` (player/enemies/objects/tiles/ui).
- [x] Déplacer `game/data/animations.json` → `game_art/data/animations.json`.
- [x] Écrire `sync.py` : copie `assets/` + `data/` vers `game/`.
- [x] Brancher la synchro dans `run.py` (sync avant lancement Godot).
- [x] Marquer `game/assets/sprites/` et `game/data/animations.json` comme générés (`.gitignore`).
- [x] Vérifier que le jeu tourne identique après migration.

### Phase 1 — Support spritesheets dans le jeu ✅
- [x] Étendre `animation_driver.gd` : si `sheet` présent, construire les frames via
      `AtlasTexture` (région calculée depuis `frame_size` + indices).
- [x] Conserver le chemin rétro-compatible (liste de PNG) le temps de la migration.
- [x] Migrer état `run` player vers spritesheet (`player_run_sheet.png` 28×24, 2 frames).
- [x] Valider rendu en jeu (taille, offset, filtre).

### Phase 2 — Éditeur : visualisation
- [ ] `main.tscn` + layout (galerie à gauche, preview au centre, inspecteur à droite).
- [~] `main.tscn` + layout 3 panneaux : créé, UI programmatique dans `main.gd`. Fenêtre s'ouvre, rendu gris — bug à corriger.
- [ ] Débugger rendu gris (piste : Control anchor dans tscn ou ordre add_child/set_anchors_preset).
- [ ] `gallery.gd` : lister entités/états depuis `animations.json`.
- [ ] `preview.gd` : AnimationDriverEditor instancié, SubViewport 200×200, zoom x1/x3/x6/x8.
- [ ] Contrôles lecture : play/pause, frame précédente/suivante.

### Phase 3 — Éditeur : édition métadonnées
- [ ] `inspector.gd` : éditer fps, loop, offset, ordre/sélection des frames.
- [ ] Sauvegarde dans `game_art/data/animations.json` (écriture sûre, format préservé).
- [ ] Rechargement live de la preview après édition.

### Phase 4 — Éditeur : détection
- [ ] `data/manifest.json` : entités + états attendus (référentiel cible).
- [ ] `audit.gd` : signaler états déclarés sans sprite, sprites orphelins non référencés,
      tailles de frame incohérentes.
- [ ] Vue dédiée listant les manques pour piloter le travail de Codex.

### Phase 5 — Finitions
- [ ] Comparaison côte à côte sprite jeu / référence (`_reference/`).
- [ ] Export d'une fiche de specs par entité (taille frame, états, fps) pour briefer Codex.
- [ ] Documentation d'usage dans `game_art/README.md`.

## Risques / angles morts

- **Drift `game/assets`** : édition manuelle de la copie générée. Traiter comme build.
- **Migration spritesheets** : tous les sprites actuels sont des PNG individuels ;
  la conversion doit être faite ou re-générée par Codex au nouveau format.
- **Deux projets Godot** : `game_art/` (éditeur) et `game/` (jeu) ont des dossiers
  `.godot/` d'import séparés. Normal, mais les `.import` ne se synchronisent pas — la
  synchro copie les PNG/JSON, chaque projet réimporte de son côté.
- **`frame_size` vs offset** : bien distinguer la taille de frame (découpe) de l'offset
  d'ancrage (placement à l'écran) pour éviter les décalages visuels.

## Hors périmètre
- Édition pixel par pixel (assurée par Codex/ChatGPT).
- Génération automatique de sprites.
