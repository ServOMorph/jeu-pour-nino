# Process — génération de sprites 2D standard

## Décision active

Le projet n'est plus en pixel art.

Le pipeline retenu est :

`generation Codex HD -> fond détourable ou transparent -> nettoyage local -> resize exact à la taille runtime -> intégration`

Pour une animation :
- partir d'une frame maître ;
- dériver les autres frames ;
- contrôler le cadrage, l'échelle et l'ancrage avant intégration.

## Objectif

Produire des sprites raster 2D standard, lisibles à taille de jeu, cohérents entre eux, et directement exploitables dans Godot sans grille imposée ni palette réduite.

## Source artistique

Référence visuelle :

`docs/references/sprite_reference_dark_fantasy.png`

Charte active :

`docs/charte_graphique_pixel_art_dark_fantasy.md`

Cette charte conserve son nom de fichier pour compatibilité, mais son contenu fait foi : direction dark fantasy 2D standard, pas pixel art.

## Règle de production

Chaque asset est produit individuellement.

Ne pas demander :
- une planche complète destinée à être découpée ;
- plusieurs personnages dans la même image finale ;
- plusieurs poses dans le même livrable final ;
- une image concept seule sans contrainte de cadrage gameplay.

Demander :
- un seul sujet ;
- une seule pose ;
- une taille cible ;
- un cadrage stable ;
- un fond transparent ou chroma-key plat si nécessaire.

## Tailles cibles

| Asset | Taille cible |
|---|---:|
| Joueur idle/run/jump/fall/hurt/dead | 87x150 |
| Joueur attaque | 129x150 |
| Ennemi au sol | environ 64x64 |
| Ennemi volant | environ 56x40 à 64x48 |
| Boss gardien | à valider par rapport au gameplay |
| Établi | selon gabarit runtime |
| Minerai / gisement | 56x56 |
| UI en jeu | selon layout 1920x1080 |

Les tailles exactes de vérité sont celles branchées dans `game_art/data/animations.json`, les scènes `game/` et les JSON runtime.

## Prompt de base

Utiliser ce bloc comme base, en remplaçant les champs :

```text
Use case: stylized-concept
Asset type: single transparent 2D game sprite for a Godot platformer
Primary request: [un seul sprite précis]
Subject: [description courte du sujet]
Pose: [idle, run frame, jump, attack, flying, object, portrait, tile fragment]
Canvas: large enough for clean rendering, centered subject, stable framing
Style/medium: high-quality 2D raster illustration, dark fantasy, readable at gameplay size, clean silhouette, no pixelation
Lighting/mood: underground dark fantasy, worn stone, old metal, tarnished gold glow, melancholic and dangerous
Color palette: desaturated stone gray, moss brown, old bronze, muted leather, rare warm glow
Composition/framing: side-view gameplay sprite, centered, no labels
Constraints: one subject only, no text, no watermark, no UI frame, no background scenery, no cast shadow
Avoid: copying Elden Ring characters, symbols, armor designs, bosses, locations, or interface elements
```

## Fond et transparence

Chemin préféré :
1. Générer le sprite avec transparence native si possible.
2. Sinon utiliser un fond chroma-key plat.
3. Nettoyer localement le détourage.
4. Exporter en PNG avec alpha propre.
5. Vérifier l'absence de halo après resize.

Couleurs chroma-key par défaut :

- `#00ff00`
- `#ff00ff` si le sujet contient déjà du vert

## Étapes d'intégration

1. Générer un sprite HD.
2. Déposer la source dans `game_art/assets/generated_raw/` si elle sert de référence ou d'archive de travail.
3. Redimensionner à la taille runtime exacte.
4. Déposer le PNG final dans `game_art/assets/`.
5. Mettre à jour `game_art/data/animations.json` si l'asset est animé.
6. Lancer l'éditeur pour vérifier taille réelle, timings, offsets et lecture d'animation.
7. Lancer `python sync.py`.
8. Valider dans le jeu avec `python run_game.py` ou en headless si le contrôle visuel n'est pas requis.

## Validation minimale

Un asset est accepté si :
- il est lisible à taille réelle ;
- sa silhouette reste stable entre frames ;
- le détourage est propre ;
- il respecte la direction dark fantasy ;
- il n'introduit pas de dérive d'échelle ou d'ancrage ;
- il n'impose pas de changement de hitbox sans décision explicite ;
- Godot charge sans erreur.

## Règle active

À chaque nouvelle demande de sprite, appliquer ce process avant toute production.

Ne pas revenir au pipeline pixel art, à la réduction de palette, ni à `ref_to_sprite.py` pour les assets de production courants, sauf décision explicite contraire.
