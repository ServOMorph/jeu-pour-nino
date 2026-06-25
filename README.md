# CoreDive Challenge

Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5.

## Lancer le jeu

```
python run.py
```

Nécessite Godot 4.5 disponible dans le PATH, ou via `D:\Godot\godot.exe`. Ou ouvrir `game/project.godot` dans l'éditeur et appuyer sur **F5**.

## Contrôles

### Clavier / Souris
| Action | Touche |
|--------|--------|
| Se déplacer | Q / D |
| Sauter | Espace |
| Attaquer | Clic gauche (visée vers la souris) |

### Manette (PowerA NSW Wired Controller)
| Action | Bouton |
|--------|--------|
| Se déplacer | Stick gauche / Croix |
| Sauter | A |
| Attaquer | RB (visée vers le stick droit) |
| Viser | Stick droit |
| Interagir (établi) | Y |
| Courir | Clic stick gauche |
| Utiliser potion | LB |
| Menu pause | Start / Menu |
| Crafter | A |
| Fermer menu | B |

## Structure du projet

```
.
├── run.py              # Lance le jeu directement
├── roadmap.md          # Roadmap active v2.1
├── docs/               # GDD, profil joueur et charte graphique
└── game/               # Projet Godot
    ├── assets/         # Sprites pixel art
    ├── project.godot
    ├── scenes/
    │   ├── player/
    │   ├── enemies/    # enemy_ground, enemy_flyer, boss
    │   ├── levels/     # biome1
    │   └── ui/         # title, calibration
    └── scripts/
        ├── player.gd
        ├── boss.gd
        ├── level.gd
        ├── hud.gd      # HUD (barres de vie joueur/boss)
        ├── audio.gd    # sons générés en runtime
        └── joymap.gd   # mapping manette PowerA NSW
```

## État actuel

**v2.1 validée.** Première passe design pixel art intégrée.

Sprites générés un par un selon `docs/process_generation_sprites.md`, branchés dans Godot, ramenés à la taille des anciens rectangles/carrés et alignés visuellement au sol.

Menu pause en jeu sur Start/Menu : reprendre, recommencer, quitter le programme, mode dev runtime et téléports atelier/boss. Le menu de défaite permet aussi de fermer le jeu.

Toutes les valeurs gameplay et données de niveau sont externalisées dans `game/data/` (player.json, weapons.json, armor.json, enemies.json, boss.json, level.json). Aucune constante numérique gameplay ne doit être hardcodée dans les scripts.

Godot 4.5 est disponible via `D:\Godot\godot.exe`. Validation headless OK.

Prochaine session : tester visuellement le menu pause, les téléports dev et les offsets sprites, puis définir la suite v3.

## Roadmap

Voir [roadmap.md](roadmap.md) pour le détail de la v2.1. Après la v2.1 : refacto complet, génération procédurale, hub méta, biomes 2 et 3, polish.
