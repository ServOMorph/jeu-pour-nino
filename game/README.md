# CoreDive Challenge — v1 (Godot 4.5)

v1 jouable : biome 1 fait main, combat de base, un boss, boucle complète
(titre → run → victoire/défaite → relance). Scope arrêté à la fin de la
Phase 5 de la roadmap. Sprites = rectangles de couleur placeholder.

## Lancer

```
python run.py          # depuis la racine du dépôt
```
ou `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --path <dossier game>`

## Contrôles

### Clavier / Souris
- Q / D : se déplacer
- Espace : sauter (coyote time + buffer de saut)
- Clic gauche : attaquer (visée vers la souris)

### Manette (PowerA NSW Wired Controller — mappée via `joymap.gd`)
- Stick gauche / Croix : se déplacer
- A : sauter — aussi pour lancer le jeu depuis le titre
- RB : attaquer (visée vers le stick droit)
- Stick droit : viser

## Structure

```
game/
  project.godot          # config, input map, autoload audio, 1920x1080 natif
  icon.svg
  scenes/
    player/player.tscn
    enemies/enemy_ground.tscn, enemy_flyer.tscn, boss.tscn, boss_projectile.tscn
    levels/biome1.tscn   # racine minimale, géométrie construite par level.gd
    ui/title.tscn        # scène principale
  scripts/
    player.gd            # mouvement, saut, attaque, santé — visée souris/stick droit
    shake_camera.gd      # screen shake
    enemy_base.gd        # classe de base (PV, dégâts, flash, knockback)
    enemy_ground.gd      # patrouille au sol, dégâts au contact
    enemy_flyer.gd       # vol sinusoïdal + poursuite du joueur
    boss.gd              # FSM : idle/charge/volée/slam, barre de vie
    boss_projectile.gd
    level.gd             # géométrie, spawns, déclenchement boss, HUD, fins
    title.gd             # écran titre (lancement clavier ou bouton A manette)
    audio.gd             # autoload, sons placeholder générés en code (AudioStreamWAV)
    joymap.gd            # autoload : mapping SDL PowerA NSW + setup_input() centralisé
    calibration.gd       # outil de calibration manette (temporaire, réutilisable)
```

## Couleurs placeholder

- Joueur : blanc — Ennemi sol : rouge — Ennemi volant : orange
- Boss : violet — Tuiles/géométrie : gris foncé — Projectiles boss : magenta

## Écarts assumés par rapport à la roadmap

- **Niveau construit par code** (`level.gd`, StaticBody2D) plutôt qu'un TileSet/TileMap
  édité dans l'éditeur. But du jalon Phase 2 (« parcourir sans bug de collision »)
  atteint plus sûrement ainsi, et la génération procédurale (post-v1) remplacera
  ce niveau de toute façon. Migration vers TileSet possible plus tard si besoin.
- **Visuels = Polygon2D de couleur** plutôt qu'AnimatedSprite2D : conforme à la
  consigne de lancement (rectangles placeholder, art final plus tard).
- **Audio généré au runtime** (ondes carré/sinus/dent de scie via AudioStreamWAV),
  donc aucun fichier .wav/.import à gérer. À remplacer par de vrais sons au polish.
- **UI (HUD, titre, écrans de fin) construite par code** plutôt qu'en scènes `.tscn`
  pour limiter la fragilité d'édition manuelle hors éditeur.

## Statut de validation

**Validé en headless** avec Godot 4.5 (téléchargé dans `D:\tmp\godot45\`) :
import du projet OK, chargement de `biome1` (joueur + ennemis + spawn boss + HUD)
sans erreur, boss exercé en isolation (activation, FSM sous physique, volée de
projectiles, dégâts, mort + signal), écran titre OK. Zéro erreur de script.

**Reste à valider en playtest fenêtré (Phase 6)** : ressenti du mouvement et du
saut, lisibilité des combats, déclenchement du boss en marchant jusqu'à l'arène,
boutons des écrans de fin, lecture audio, équilibrage (dégâts/PV/vitesses).

Lancer le jeu réel : `python run.py` (depuis la racine) ou ouvrir `project.godot` dans l'éditeur et appuyer sur F5.

## Notes manette

Le mapping SDL pour la PowerA NSW Wired Controller (GUID `03002d7bd620000019a7000000000000`)
est codé dans `scripts/joymap.gd`. Si tu changes de manette, relancer `scenes/ui/calibration.tscn`
(mettre temporairement comme scène principale dans `project.godot`) pour obtenir les indices bruts,
puis mettre à jour `joymap.gd`.
