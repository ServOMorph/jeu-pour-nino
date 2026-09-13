# CoreDive Challenge

Jeu de plateforme/action fait pour Nino. Un run court dans le biome 1, des ennemis, un boss. Fait en Godot 4.5. Direction visuelle active : graphismes 2D standard en 1920×1080 natif (voir `plan_graphismes_standard_2d.md`).

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
| Attaquer | RB (melee ou tir a distance selon l'arme equipee, visee via stick droit) |
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
    |-- assets/         # Sprites 2D standard
    |-- project.godot
    |-- scenes/
    |   |-- player/
    |   |-- enemies/    # enemy_ground, enemy_flyer, boss
    |   |-- levels/     # hub, biome (generique, pilote par GameFlow)
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

**Phase 3 livree cote code, validation en jeu encore a faire.** Le run est desormais multi-biomes : autoload `GameFlow` (`next_biome_id`, `start_run`/`enter_biome`/`return_to_hub`/`end_run`), HUB jouable (`scenes/levels/hub.tscn`, 4 portails dont 3 verrouilles, stele Grimoire, etabli tier 1, soin complet a l'entree), portail de sortie volontaire dans le biome, boss vaincu memorise par biome dans `RunState`.
Le HUB utilise un fond plein ecran avec quatre portes integrees et accessibles sur la ligne de marche ; les portails n'affichent plus de noms ni de rectangles placeholder. L'etabli est isole a droite.
Un outil de stabilisation automatise le detourage chroma/alpha, l'echelle uniforme, l'alignement au sol et l'assemblage des candidats `player/run`. Le premier lot de 16 frames est techniquement conforme mais rejete visuellement ; la sheet runtime validee reste utilisee.
Les prototypes 3D sous `game_art/models/` ne sont pas integres au jeu. Le workflow 3D retenu exige des references techniques multi-vues et un generateur image-vers-3D pour le maillage initial, puis un nettoyage dans Blender.
La prochaine etape est de produire des poses de course plus coherentes, puis de verifier le HUB et valider J1 avant la Phase 4.

## Roadmap

Voir [roadmap.md](roadmap.md) - roadmap v3 complete, jalons jouables J1-J7, decisions de conception verrouillees via [`questions.md`](questions.md). Design document : [`docs/v3/CoreDive Challenge - Design Document v3.md`](docs/v3/CoreDive%20Challenge%20%E2%80%94%20Design%20Document%20v3.md). Besoins d'assets : [`game_art/backlog_art.md`](game_art/backlog_art.md).
