# CoreDive Challenge

Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5 avec des visuels placeholder (rectangles de couleur).

## Lancer le jeu

```
python run.py
```

Nécessite Godot 4.5 installé dans `D:\tmp\godot45\`. Ou ouvrir `game/project.godot` dans l'éditeur et appuyer sur **F5**.

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

## Structure du projet

```
.
├── run.py              # Lance le jeu directement
├── roadmap.md          # Phases de développement v1
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
        ├── audio.gd    # sons générés en runtime
        └── joymap.gd   # mapping manette PowerA NSW
```

## État actuel

**v1 complète (v0.2.1)** — boucle jouable de bout en bout : écran titre → run biome 1 → boss → victoire/défaite → relance.

Écran de fin centré, navigation manette (stick/croix + bouton A) et gestion anti-rebond du bouton A au retour sur le titre.

Phase 6 (playtest & ajustements) en cours.

## Roadmap

Voir [roadmap.md](roadmap.md) pour le détail des phases. Après la v1 : craft, génération procédurale, biomes 2 et 3, méta-progression.
