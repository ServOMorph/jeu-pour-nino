# Process — génération de sprites pixel art

## Décision

Pour les sprites du jeu, ne pas découper une planche globale générée.

La méthode retenue est de générer les sprites **un par un**, avec une specification stable par asset, puis de les intégrer individuellement dans Godot.

## Pourquoi

Le découpage d'une planche pose trop de problèmes :
- fond difficile à retirer proprement ;
- tailles hétérogènes ;
- poses incohérentes ;
- parasites visuels autour des sprites ;
- animations difficiles à homogénéiser.

La génération unitaire donne un meilleur contrôle sur :
- la taille ;
- la pose ;
- le cadrage ;
- la lisibilité ;
- la cohérence entre assets ;
- l'intégration Godot.

## Source artistique

Utiliser comme référence visuelle :

`docs/references/sprite_reference_dark_fantasy.png`

Utiliser comme charte :

`docs/charte_graphique_pixel_art_dark_fantasy.md`

Référence d'ambiance : dark fantasy majestueuse, proche du ton Elden Ring, sans copier de personnage, symbole, boss, lieu ou interface.

## Règle de production

Chaque sprite doit être demandé séparément.

Ne pas demander :
- une planche complète ;
- plusieurs personnages dans la même image ;
- plusieurs poses dans le même fichier final ;
- un sprite à détourer depuis une image de concept.

Demander :
- un seul sujet ;
- une seule pose ;
- une taille cible ;
- un cadrage gameplay ;
- un fond chroma-key plat si la génération ne fournit pas directement une transparence exploitable.

## Tailles cibles

| Asset | Taille cible |
|---|---:|
| Joueur idle | 48x58 |
| Joueur course 1 | 48x58 |
| Joueur course 2 | 48x58 |
| Joueur saut | 48x60 |
| Joueur attaque | 58x46 |
| Mob au sol | 58x34 |
| Mob volant | 62x46 |
| Boss gardien | 112x128 |
| Établi | 58x40 |
| Minerai cuivre | 34x34 |
| Minerai fer | 34x34 |
| Potion HUD | 24x32 |
| Pièce HUD | 28x28 |
| Tile sol biome 1 | 32x32 |
| Tile mur biome 1 | 32x32 |

Ces tailles peuvent être ajustées si le gameplay l'exige, mais elles doivent rester stables pendant une série d'assets.

## Prompt de base

Utiliser ce bloc comme base, en remplaçant les champs entre crochets :

```text
Use case: stylized-concept
Asset type: single transparent pixel art sprite for a 2D Godot platformer
Primary request: [un seul sprite précis]
Subject: [description courte du sujet]
Pose: [idle, run frame, jump, attack, flying, crouched, object, tile]
Canvas: [largeur]x[hauteur] pixels target sprite, centered with 2-4 pixels of padding
Style/medium: crisp high-quality pixel art, dark fantasy, readable at gameplay size, no painterly blur
Lighting/mood: underground dark fantasy, worn stone, old metal, tarnished gold glow, melancholic and dangerous
Color palette: desaturated stone gray, moss brown, old bronze, muted leather, tarnished gold accents, rare warm glow
Composition/framing: side-view gameplay sprite, clean silhouette, centered, no labels
Constraints: one subject only, no text, no watermark, no UI frame, no background scenery, no cast shadow
Avoid: copying Elden Ring characters, symbols, armor designs, bosses, locations, or interface elements
```

## Fond et transparence

Chemin préféré :
1. Générer le sprite avec fond chroma-key plat.
2. Retirer localement le fond.
3. Exporter en PNG avec alpha.
4. Vérifier les coins transparents et l'absence de halo.

Couleur chroma-key par défaut :

`#00ff00`

Si le sujet contient du vert, utiliser :

`#ff00ff`

Le prompt doit alors ajouter :

```text
Create the sprite on a perfectly flat solid #00ff00 chroma-key background for background removal.
The background must be one uniform color with no shadows, gradients, texture, floor plane, or lighting variation.
Do not use #00ff00 anywhere in the subject.
```

## Étapes d'intégration

1. Générer un sprite à la fois.
2. Copier le PNG final dans `game/assets/sprites/`.
3. Garder un nom stable :
   - `player_idle.png`
   - `player_run1.png`
   - `enemy_ground.png`
   - etc.
4. Importer via Godot si nécessaire.
5. Vérifier que la scène charge en headless.
6. Vérifier visuellement dans une scène ou une planche de contrôle.
7. Ajuster les offsets ou collisions si le sprite dépasse la hitbox.

## Validation minimale

Un sprite est accepté si :
- il est lisible à taille réelle ;
- il a un fond transparent propre ;
- il n'a pas de pixels parasites visibles ;
- il respecte la charte dark fantasy ;
- il ne modifie pas la hitbox gameplay sans décision explicite ;
- Godot charge le projet sans erreur.

Commandes de validation :

```powershell
& 'D:\Godot\godot.exe' --headless --path game --quit
& 'D:\Godot\godot.exe' --headless --path game res://scenes/levels/biome1.tscn --quit-after 2
```

## Règle mémoire projet

À chaque nouvelle demande de sprites, appliquer ce process avant toute génération.

Ne pas repartir sur une planche complète, sauf demande explicite pour une image de référence non intégrée au jeu.
