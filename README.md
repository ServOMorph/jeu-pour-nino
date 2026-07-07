# CoreDive Challenge

Jeu de plateforme/action fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5. Direction visuelle en transition : abandon du pixel art vers des graphismes 2D standard (voir `plan_graphismes_standard_2d.md`).

## Lancer le jeu

```text
python run_game.py
```

Necessite Godot 4.5 disponible dans le PATH, ou via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`. Ou ouvrir `game/project.godot` dans l'editeur et appuyer sur **F5**.

## Controles

### Clavier / Souris
| Action | Touche |
|--------|--------|
| Se deplacer | A / D ou Fleches gauche / droite |
| Sauter | Espace |
| Attaquer | Clic gauche ou Z |
| Interagir (etabli) | E |
| Utiliser potion | R |
| Courir | Shift |
| Menu pause | Echap |

### Manette (PowerA NSW Wired Controller)
| Action | Bouton |
|--------|--------|
| Se deplacer | Stick gauche / Croix |
| Sauter | A |
| Attaquer | RB (visee vers le stick droit) |
| Viser | Stick droit |
| Interagir (etabli) | Y |
| Courir | Clic stick gauche |
| Utiliser potion | LB |
| Menu pause | Start / Menu |
| Crafter | A |
| Fermer menu | B |

## Structure du projet

```text
.
|-- run_game.py         # Lance le jeu directement
|-- run_editeur.py      # Lance l'editeur game_art
|-- run_edit_game.py    # Lance jeu + editeur cote a cote
|-- roadmap.md          # Roadmap active v3
|-- docs/               # GDD, profil joueur et charte graphique
`-- game/               # Projet Godot
    |-- assets/         # Sprites (transition pixel art -> 2D standard)
    |-- project.godot
    |-- scenes/
    |   |-- player/
    |   |-- enemies/    # enemy_ground, enemy_flyer, boss
    |   |-- levels/     # biome1
    |   `-- ui/         # title, calibration
    `-- scripts/
        |-- player.gd
        |-- boss.gd
        |-- level.gd
        |-- hud.gd      # HUD (barres de vie joueur/boss)
        |-- audio.gd    # sons generes en runtime
        `-- joymap.gd   # mapping manette PowerA NSW
```

## Etat actuel

**v1.33.** Migration resolution 1920x1080 executee (project.godot, JSON, scenes, scripts, sprites) ; validation GUT/run manuel a refaire.
Pivot acte : abandon du pixel art, graphismes 2D standard (pipeline Codex + rescale, `plan_graphismes_standard_2d.md`). Refonte game_art signalee, non commencee.
Prochaine etape : valider GUT + run manuel de la migration resolution, puis session game_art sur le pivot.

## Roadmap

Voir [roadmap.md](roadmap.md) - roadmap v3 complete, jalons jouables J1-J7, decisions de conception verrouillees via [`questions.md`](questions.md). Design document : [`docs/v3/CoreDive Challenge - Design Document v3.md`](docs/v3/CoreDive%20Challenge%20%E2%80%94%20Design%20Document%20v3.md). Besoins d'assets : [`game_art/backlog_art.md`](game_art/backlog_art.md).
