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
| Interagir (établi) | Y |
| Crafter | A |
| Fermer menu | B |

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
        ├── hud.gd      # HUD (barres de vie joueur/boss)
        ├── audio.gd    # sons générés en runtime
        └── joymap.gd   # mapping manette PowerA NSW
```

## État actuel

**v1 complète.** Run complet (explore → récolte → craft → boss) validé, nickel.

Toutes les valeurs gameplay externalisées dans `game/data/` (player.json, weapons.json, armor.json, enemies.json, boss.json). Aucune constante numérique hardcodée dans les scripts.

Prochaine session : définir les axes v2.

## Roadmap

Voir [roadmap.md](roadmap.md) pour le détail des phases. Après la v1 : craft, génération procédurale, biomes 2 et 3, méta-progression.
