# CoreDive Challenge

Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5.

## Lancer le jeu

```
python run_game.py
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
├── run_game.py         # Lance le jeu directement
├── run_editeur.py      # Lance l'éditeur game_art
├── run_edit_game.py    # Lance jeu + éditeur côte à côte
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

**v1.23.** `game_art` : Phases 0 à 4 implémentées. L'éditeur couvre maintenant visualisation, édition, sauvegarde et audit des sprites/animations : `manifest.json`, moteur d'audit, vue audit cliquable et export `audit_report.md`, validés en headless. Reste côté `game_art` : enrichir la structure du rapport exporté, puis attaquer les finitions de phase 5.
Jeu : dette bloquante Phase 0 corrigée ; validation complète (GUT, run manuel intégral) encore à faire côté zone jeu.

## Roadmap

Voir [roadmap.md](roadmap.md) — roadmap v3 complète, jalons jouables J1-J7. Design document : [`docs/v3/CoreDive Challenge — Design Document v3.md`](docs/v3/CoreDive%20Challenge%20%E2%80%94%20Design%20Document%20v3.md). Besoins d'assets : [`game_art/backlog_art.md`](game_art/backlog_art.md).
