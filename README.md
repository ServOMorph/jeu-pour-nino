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
| Se déplacer | A / D ou Flèches gauche / droite |
| Sauter | Espace |
| Attaquer | Clic gauche ou Z |
| Interagir (établi) | E |
| Utiliser potion | R |
| Courir | Shift |
| Menu pause | Echap |

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

**v1.11.** Zone `game_art/` créée comme source de vérité des sprites et animations.
`sync.py` synchronise vers `game/` avant chaque lancement. Affichage plein écran 1920×1080 et contrôles clavier complets ajoutés (zone jeu).
Prochaine étape art : support spritesheets dans `animation_driver.gd`.

## Roadmap

Voir [roadmap.md](roadmap.md) pour le détail de la v2.1. Après la v2.1 : refacto complet, génération procédurale, hub méta, biomes 2 et 3, polish.
