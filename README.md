# CoreDive Challenge

Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5 avec des visuels placeholder (rectangles de couleur).

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
| Crafter | A |
| Fermer menu | B |

## Structure du projet

```
.
├── run.py              # Lance le jeu directement
├── roadmap.md          # Roadmap active v2.1
├── docs/               # GDD et profil joueur
└── game/               # Projet Godot
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

**v2.1 validée.** Gameplay testé nickel par l'utilisateur.

Difficulté, potions multiples, progression équipement, course, respawn mobs, monnaie et boss validés. Correctifs finaux intégrés : saut sprint conserve sa vitesse, flyers respawn, collisions physiques joueur/mobs, vie infinie en mode dev.

Toutes les valeurs gameplay et données de niveau sont externalisées dans `game/data/` (player.json, weapons.json, armor.json, enemies.json, boss.json, level.json). Aucune constante numérique gameplay ne doit être hardcodée dans les scripts.

Godot 4.5 est disponible via `D:\Godot\godot.exe`. Validation headless OK.

Prochaine session : définir la suite v3.

## Roadmap

Voir [roadmap.md](roadmap.md) pour le détail de la v2.1. Après la v2.1 : refacto complet, génération procédurale, hub méta, biomes 2 et 3, polish.
