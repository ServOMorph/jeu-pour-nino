# Backlog art — CoreDive Challenge

Backlog des assets à produire pour la zone jeu. Alimenté par les phases de `roadmap.md` (racine) : chaque phase jeu qui pose un placeholder ajoute une entrée ici. Les sessions game_art piochent dedans par priorité.

## Règles

- Une phase jeu n'est « faite » que si ses placeholders sont recensés ici.
- Priorité héritée des jalons jouables : ce qui est visible dans le jalon courant passe devant.
- Livraison : produire dans `game_art/assets/` + `game_art/data/animations.json`, puis sync.py → `game/`. Ne jamais éditer `game/assets/sprites/` directement.
- Standard visuel : Terraria-like, réf `docs/process_generation_sprites.md`.
- Statuts : `a_faire` / `en_cours` / `livre`.

## Format d'entrée

```
### <nom de l'asset>
- phase: <phase jeu d'origine>
- placeholder: <ce qui est en jeu actuellement>
- specs: <dimensions, format, contraintes>
- priorite: <haute | moyenne | basse>
- statut: a_faire
```

---

## Entrées

### Sprites player — standard Terraria-like
- phase: antérieure (P3 signals)
- placeholder: sprites actuels hors standard
- specs: idle, run1, run2, jump, attack en 40x56 / 48x56, réf `docs/process_generation_sprites.md`
- priorite: haute
- statut: en_cours

### Sprites gisements/minerais par type de matériau
- phase: 1 — Matériaux typés
- placeholder: `ore_copper.png` unique pour tous les gisements
- specs: 14x14, un sprite par `material_id` de `game/data/materials.json`
- priorite: moyenne
- statut: a_faire

### Grimoire — mise en page et icônes
- phase: 2 — Grimoire/PC/Craft
- placeholder: UI Godot brute (labels/rects)
- specs: écran de déblocage des recettes au HUB, icônes par recette/rareté
- priorite: moyenne
- statut: a_faire

### Décor du HUB
- phase: 3 — HUB (jalon J1)
- placeholder: rects colorés
- specs: point central + 4 directions visibles, viewport 480x270
- priorite: haute
- statut: a_faire

### Tileset et décors — Biome 1 Galeries Verdoyantes
- phase: 4 — Génération biomes (jalon J2)
- placeholder: rects/polygones colorés
- specs: tiles compatibles templates de salles, ambiance cavernes végétales, lumière filtrante
- priorite: haute
- statut: a_faire

### Décor Arène du Voile — tribunal cosmique
- phase: 5 — Mort/Résurrection
- placeholder: rects colorés
- specs: plateforme suspendue, ciel fracturé, fragments de biomes flottants
- priorite: moyenne
- statut: a_faire

### Sprites et patterns visuels — Gardiens du Voile (2-3 premiers)
- phase: 5 — Mort/Résurrection
- placeholder: sprite boss actuel recoloré
- specs: pool initial de 2-3 Gardiens, extension à 8 après R2
- priorite: moyenne
- statut: a_faire

### Effets visuels cicatrices — paliers 1 à 5+
- phase: 6 — Cicatrices (jalon J3)
- placeholder: aucun effet visuel
- specs: shaders + overlays de particules UNIQUEMENT, zéro modification des spritesheets ; 5 paliers (yeux lumineux → silhouette altérée)
- priorite: moyenne
- statut: a_faire

### Biome 2 Mines Obscures — ennemis, boss, tileset
- phase: 7a (jalon J4)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis (mineurs spectraux, golems, araignées, machines), Foreur Maudit, tileset galeries sombres
- priorite: basse (monte en haute à l'ouverture de 7a)
- statut: a_faire

### Biome 3 Îles Célestes — ennemis, boss, tileset
- phase: 7b (jalon J5)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis volants, Orage Éternel, tileset îles flottantes/cristaux
- priorite: basse (monte en haute à l'ouverture de 7b)
- statut: a_faire

### Biome 4 Descente vers le Noyau — ennemis, boss, tileset
- phase: 7c (jalon J6)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis (revenants, corrompus), Gardien du Noyau, tileset roche en fusion
- priorite: basse (monte en haute à l'ouverture de 7c)
- statut: a_faire

### Sprites des 4 porteurs de recettes
- phase: 8 — Porteurs
- placeholder: sprites ennemis standards
- specs: Archiviste Perdu, Golem Artisan, Mineur Spectral, Forgeron Maudit — silhouettes distinctives (rareté lisible)
- priorite: basse
- statut: a_faire

### Modules visuels du Miroir du Noyau
- phase: 9 — Boss final (jalon J7)
- placeholder: assemblage de sprites boss existants
- specs: modules combinables — corps (4), effets de pouvoir (5), mutations (5) ; compatibles assemblage runtime
- priorite: basse
- statut: a_faire
