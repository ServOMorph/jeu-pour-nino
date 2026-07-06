# CoreDive Challenge

Jeu de plateforme/action pixel art fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5.

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
    |-- assets/         # Sprites pixel art
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

**v1.31.** Phase 1 (Materiaux types) close : gating de minage data-driven via `weapons.json`/`RunState`, run manuel complet valide (minage, craft, HUD, menu dev).
GUT est vert (`23/23`) et le projet demarre en headless, y compris `biome1`.
Sprites `minerai_abyssal` et `fer` integres avec leur visuel dedie.
Prochaine etape : Phase 2 - Grimoire, Points de Competence, Craft v3.

## Roadmap

Voir [roadmap.md](roadmap.md) - roadmap v3 complete, jalons jouables J1-J7, decisions de conception verrouillees via [`questions.md`](questions.md). Design document : [`docs/v3/CoreDive Challenge - Design Document v3.md`](docs/v3/CoreDive%20Challenge%20%E2%80%94%20Design%20Document%20v3.md). Besoins d'assets : [`game_art/backlog_art.md`](game_art/backlog_art.md).
