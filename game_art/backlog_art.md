# Backlog art — CoreDive Challenge

Backlog des assets à produire pour la zone jeu. Alimenté par les phases de `roadmap.md` (racine) : chaque phase jeu qui pose un placeholder ajoute une entrée ici. Les sessions game_art piochent dedans par priorité.

## Pivot 2026-07-07 — abandon du pixel art, graphismes 2D standard

Décision jeu : le style visuel passe du pixel art à de la 2D standard (raster haute résolution lissée, plus de grille ni de palette réduite). Plan complet : `plan_graphismes_standard_2d.md` (racine). S'articule avec `plan_resolution_1920x1080.md` (résolution native 1920×1080 conservée).

Pipeline de production retenu : génération d'image via le module Codex, puis rescale à la taille de rendu cible (pas de dessin manuel, pas de vectoriel, pas d'asset packs). Point de vigilance signalé au plan : dérive de cadrage/échelle entre frames d'une même animation générées séparément — à contrôler avant intégration.

Conséquences pour cette zone (à traiter côté game_art, hors périmètre jeu) :
- `docs/charte_graphique_pixel_art_dark_fantasy.md` et `docs/workflow_image_gen_fable5.md` : obsolètes, à réécrire pour le nouveau pipeline (voir plan §3).
- `game_art/tools/ref_to_sprite.py` : sans objet (réduction pixel), à remplacer par un script de rescale simple.
- Éditeur (`game_art/editeur/`) : filtre de preview nearest → linéaire, preview "x8" et audit de tailles sur grille à retirer/refondre.
- Toutes les entrées ci-dessous portant une spec en grille pixel (14×14, 16×16, palette limitée) sont à réviser vers des tailles 2D standard à résolution native — la colonne `specs:` reste la propriété de l'agent game_art.
- La précision « Grille de tiles : 16×16 » ci-dessous est révisée : plus de grille imposée.

## Précisions v3.1 (questions.md, 2026-07-06)

77 questions de conception (+ Q026b) ont été tranchées avant le développement — voir `questions.md` à la racine du projet. Les entrées ci-dessous intègrent déjà ces décisions. Points de cadrage transverses à connaître avant de produire :

- **Grille de tiles : 16×16** (résolution de référence 480×270 = 30×17 tiles à l'écran).
- **2-3 couches de parallax** par biome (fond lointain + intermédiaire + premier plan).
- **Style dark fantasy** (voir `docs/charte_graphique_pixel_art_dark_fantasy.md`) — pas l'imagerie « lumineuse arcade » suggérée par endroits dans les docs v3 historiques.
- **Un seul Gardien du Voile au lancement** (Le Veilleur des Cendres) — ne pas produire les 7 autres avant que la roadmap jeu (refacto R2) ne les active.
- **Rareté/biomes réalignés** : cristaux → Biome 3 (Îles Célestes), imagerie volcanique → Biome 4 (Descente vers le Noyau). Ne pas suivre d'anciennes versions des docs qui inversaient ces deux biomes.
- **Cicatrices visuelles = 5 paliers fixes**, shaders + overlays uniquement, jamais de retouche de spritesheet (détail des paliers dans l'entrée dédiée ci-dessous).

## Règles

- Une phase jeu n'est « faite » que si ses placeholders sont recensés ici.
- Priorité héritée des jalons jouables : ce qui est visible dans le jalon courant passe devant.
- Livraison : produire dans `game_art/assets/` + `game_art/data/animations.json`, puis sync.py → `game/`. Ne jamais éditer `game/assets/sprites/` directement.
- Manifest d'audit : toute entrée impliquant une entité animée (nouvel archétype ennemi, boss, Gardien, porteur, module du Miroir) ajoute son entité au manifest de l'éditeur AVANT production des sheets — sinon l'audit « sprites manquants » ne la verra jamais (cf. `roadmap_editeur.md`, règle de synchronisation du manifest).
- Standard visuel : Terraria-like, réf `docs/process_generation_sprites.md`.
- Statuts et propriété des transitions :
  - `a_faire` → `en_cours` → `livre` : possédé par l'agent game_art.
  - `livre` → `integre` : possédé par l'agent jeu, une fois l'asset branché côté `game/`.
  - Ce fichier est l'unique canal de handoff entre les deux agents. Aucun autre fichier (`_contexte/signals.md` d'une zone ou de l'autre) ne doit porter le statut ou la priorité d'un item art — au besoin, y référencer l'entrée par son nom.
- Champs de handoff (voir format d'entrée) :
  - `debloque:` — rempli par l'agent jeu à la création de l'entrée : quelle tâche/phase dev ce visuel débloque.
  - `livraison:` — rempli par l'agent game_art au passage à `livre` : chemin exact des fichiers produits (assets + entrée `animations.json` le cas échéant).

## Format d'entrée

```
### <nom de l'asset>
- phase: <phase jeu d'origine>
- placeholder: <ce qui est en jeu actuellement>
- specs: <dimensions, format, contraintes>
- priorite: <haute | moyenne | basse>
- statut: a_faire
- debloque: <tâche/phase dev bloquée tant que cet asset n'est pas integre>
- livraison: <chemin des fichiers produits — rempli au passage a "livre">
```

---

## Entrées

### Sprites player — standard Terraria-like
- phase: antérieure (P3 signals)
- placeholder: sprites actuels hors standard
- specs: nouvelle cible definitive joueur = 150 px de haut ; idle/run1/run2/jump/fall/hurt/dead en 87x150, attack en 129x150
- priorite: haute
- statut: livre
- livraison: `game_art/assets/player/player_idle_v2.png`, `game_art/assets/player/player_run1.png`, `game_art/assets/player/player_run2.png`, `game_art/assets/player/player_jump.png`, `game_art/assets/player/player_attack.png`, `game_art/assets/player/player_attack_transition.png`, `game_art/assets/player/player_attack_up.png`, `game_art/assets/player/player_attack_up_transition.png`, `game_art/assets/player/player_attack_up_diag.png`, `game_art/assets/player/player_attack_up_diag_transition.png`, `game_art/assets/player/player_attack_down.png`, `game_art/assets/player/player_attack_down_transition.png`, `game_art/assets/player/player_attack_down_diag.png`, `game_art/assets/player/player_attack_down_diag_transition.png`, `game_art/assets/player/player_run_sheet.png`, `game_art/assets/player/player_idle_sheet.png`, `game_art/assets/player/player_jump_sheet.png`, `game_art/assets/player/player_fall_sheet.png`, `game_art/assets/player/player_hurt_sheet.png`, `game_art/assets/player/player_dead_sheet.png`, `game_art/assets/player/player_attack_sheet.png`, `game_art/assets/player/player_attack_up_sheet.png`, `game_art/assets/player/player_attack_down_sheet.png`, `game_art/assets/player/player_attack_up_diag_sheet.png`, `game_art/assets/player/player_attack_down_diag_sheet.png`, `game_art/data/animations.json`
- note: cette entrée est aussi le support du « Fait quand » de la Phase 5 de `roadmap_editeur.md` (premier cycle complet sheet → éditeur → audit → sync → validation en jeu)

### Animations mobilité — double saut, corde/grappin
- phase: 2 — Grimoire/PC/Craft (mobilité définie questions.md Q015)
- placeholder: aucune animation dédiée (saut simple uniquement actuellement)
- specs: frame(s) additionnelle(s) pour le double saut (variation de la pose de saut existante), animation d'utilisation de la corde/grappin (lancer + traction). Pas de dash, pas de wall jump à prévoir.
- priorite: moyenne
- statut: a_faire

### Sprites gisements/minerais par type de matériau
- phase: 1 — Matériaux typés
- placeholder: `ore_copper.png` unique pour tous les gisements
- specs: 14x14, un sprite par matériau — 13 définitifs (questions.md Q041) : `bois`, `pierre`, `cuivre`, `cuir` (B1), `fer`, `charbon`, `minerai_sombre` (B2), `cristal`, `minerai_celeste`, `essence_vent` (B3), `fragment_noyau`, `minerai_abyssal` (B4), `essence_voile` (Voile, drop uniquement, pas de gisement). Lisibilité de rareté croissante (charte graphique).
- priorite: moyenne
- statut: en_cours

### Sprite manquant — minerai abyssal
- phase: 1 — Matériaux typés
- placeholder: le jeu utilise encore le sprite générique cuivre pour `minerai_abyssal`
- specs: sprite dédié pour `minerai_abyssal`, cohérent avec un matériau tier 3 / biome 4, clairement distinct visuellement de `ore_copper.png` et `ore_iron.png`
- priorite: haute
- statut: integre
- debloque: clôture Phase 1 roadmap.md — lisibilité du test manuel tier 3
- livraison: `game_art/assets/objects/ore_abyssal.png`

### Icônes d'équipement — 4 slots
- phase: 2 — Grimoire/PC/Craft
- placeholder: aucun (auto-équipement sans UI dédiée)
- specs: écran d'équipement manuel (questions.md Q055) — icônes pour 4 slots : Arme (mêlée ou distance), Armure, Accessoire, Outil. Une icône par objet équipable de la table de 27 recettes (Q043).
- priorite: moyenne
- statut: a_faire

### Sprites armes à distance + projectiles
- phase: 2 — Grimoire/PC/Craft
- placeholder: aucun (arme à distance non existante actuellement)
- specs: Arc en Bois, Arbalète de Fer, Arc Céleste, Bombe Instable (questions.md Q043) — sprite arme + sprite/anim de projectile en vol + impact. Cohérent avec le mêlée existant (pas de refonte de style).
- priorite: moyenne
- statut: a_faire

### Grimoire — mise en page et icônes
- phase: 2 — Grimoire/PC/Craft
- placeholder: UI Godot brute (labels/rects)
- specs: écran de déblocage des recettes, **accessible au HUB uniquement** (questions.md Q056), icônes pour les 27 recettes définitives (Q043) par rareté (commune/peu commune/rare/épique/légendaire/Voile)
- priorite: moyenne
- statut: a_faire

### Décor du HUB
- phase: 3 — HUB (jalon J1)
- placeholder: rects colorés
- specs: point central + 4 directions visibles, viewport 480x270. Le HUB reste minimal (4 sorties, Grimoire, établi) — pas de décor évolutif en v3 (questions.md Q039).
- priorite: haute
- statut: a_faire

### Objet/portail de sortie volontaire de biome
- phase: 3 — HUB (jalon J1)
- placeholder: aucun
- specs: objet ou portail visible dans chaque biome, permettant un retour au HUB en cours d'exploration sans mourir ni battre le boss (questions.md Q006)
- priorite: basse
- statut: a_faire

### Tileset et décors — Biome 1 Galeries Verdoyantes
- phase: 4 — Génération biomes (jalon J2)
- placeholder: rects/polygones colorés
- specs: **grille de tiles 16×16** (questions.md Q068), compatibles avec 8-10 templates de salles (5-7 salles par run, connexions 4 directions), 2-3 couches de parallax (Q069), ambiance cavernes végétales, lumière filtrante
- priorite: haute
- statut: a_faire

### Overlay d'obscurité — Biome 2 (Mines Obscures)
- phase: 4/7a — Génération biomes / Mines Obscures
- placeholder: aucun
- specs: overlay/vignette sombre plein écran, activé quand la Torche n'est pas équipée (slot Outil) — pas de Light2D dynamique à rayon suivant le joueur (questions.md Q018/Q021). Doit rendre le biome réellement difficile à lire sans la Torche, sans bloquer totalement la visibilité.
- priorite: moyenne
- statut: a_faire

### Décor Arène du Voile — tribunal cosmique
- phase: 5 — Mort/Résurrection
- placeholder: rects colorés
- specs: plateforme suspendue, ciel fracturé, fragments de biomes flottants
- priorite: moyenne
- statut: a_faire

### Sprites et patterns visuels — Le Veilleur des Cendres (Gardien unique de lancement)
- phase: 5 — Mort/Résurrection
- placeholder: sprite boss actuel recoloré
- specs: **un seul Gardien à produire au lancement** (questions.md Q029) — thème cendres/braises, cohérent avec ses 3 attaques (charge au sol, projectile de cendres, zone d'explosion retardée) + pose de pause vulnérable. Les 7 autres Gardiens du pool (Roi Sans Visage, Collecteur d'Âmes, Veuve du Vide, Dévoreur de Souvenirs, Porte-Flamme, Gardien des Os, Écho du Noyau) ne sont à produire qu'après activation de R2 côté jeu — ne pas anticiper.
- priorite: moyenne
- statut: en_cours

### Effets visuels cicatrices — 5 paliers fixes
- phase: 6 — Cicatrices (jalon J3)
- placeholder: aucun effet visuel
- specs: shaders + overlays de particules UNIQUEMENT, zéro modification des spritesheets (questions.md Q070). Paliers définitifs : **1** overlay lumineux (yeux) + particules discrètes ; **2** shader teinte veines lumineuses + halo ; **3** shader transparence partielle ; **4** overlay fragments flottants + teinte cristalline ; **5+** combinaison de tous les shaders précédents à intensité maximale + particules denses. Outils Godot standards (shaders 2D, CPUParticles2D).
- priorite: moyenne
- statut: a_faire

### Icônes des 5 cicatrices — HUD
- phase: 6 — Cicatrices (jalon J3)
- placeholder: aucun
- specs: une icône par cicatrice définitive (questions.md Q026) — Cicatrice du Sang, de l'Os, de l'Âme, de la Peur, du Noyau — affichées en rangée dans le HUD
- priorite: basse
- statut: a_faire

### Biome 2 Mines Obscures — ennemis, boss, tileset
- phase: 7a (jalon J4)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis (questions.md Q050) — Mineur spectral (`ground`), Golem de pierre (`ground` tanky), Araignée géante (`jumper` — nouvel archétype bondissant), Machine abandonnée (`turret` — nouvel archétype stationnaire tirant). Boss **Foreur Maudit** : arène « atelier de forage », attaques charge frontale / tir de boulons / mine posée (explosion différée), phase rage à bas HP (Q051). Tileset galeries sombres, grille 16×16, overlay d'obscurité (entrée dédiée ci-dessus) requiert un fond lisible même assombri.
- priorite: basse (monte en haute à l'ouverture de 7a)
- statut: a_faire

### Biome 3 Îles Célestes — ennemis, boss, tileset
- phase: 7b (jalon J5)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis (Q050) — Sentinelle volante (`flyer` distance), Élémentaire du vent (`flyer`), Créature céleste (`flyer`), Gardien cristallin (`turret`, bouclier + zone). Boss **Orage Éternel** : arène « plateforme aérienne », attaques éclair ciblé (zone télégraphiée) / téléportation courte / tempête de cristaux (Q051). Tileset îles flottantes/cristaux, grille 16×16 — biome parcouru **vers le haut**, prévoir des salles empilables verticalement (connexions top/bottom, questions.md Q032).
- priorite: basse (monte en haute à l'ouverture de 7b)
- statut: a_faire

### Biome 4 Descente vers le Noyau — ennemis, boss, tileset
- phase: 7c (jalon J6)
- placeholder: assets biome 1 recolorés
- specs: sprites ennemis (Q050) — Revenant (`ground` drain de vie), Créature corrompue (`ground`/`flyer` hybride), Manifestation du Voile (`teleporter` — nouvel archétype). Boss **Gardien du Noyau** : arène « sanctuaire du Noyau », attaques charge lourde / onde de corruption / invocation de revenants, phase 2 à mi-HP (Q051). Tileset roche en fusion — **imagerie volcanique confirmée sur ce biome** (Marteau Magmatique, Armure Volcanique, questions.md Q042), grille 16×16, biome parcouru **vers le bas** (connexions top/bottom).
- priorite: basse (monte en haute à l'ouverture de 7c)
- statut: a_faire

### Sprites des 4 porteurs de recettes
- phase: 8 — Porteurs
- placeholder: sprites ennemis standards
- specs: Archiviste Perdu (drop Couronne Spectrale), Golem Artisan, Mineur Spectral, Forgeron Maudit (drop Armure du Noyau, Lame du Noyau) — silhouettes distinctives (rareté lisible), sources précises dans questions.md Q043
- priorite: basse
- statut: a_faire

### Modules visuels du Miroir du Noyau
- phase: 9 — Boss final (jalon J7)
- placeholder: assemblage de sprites boss existants
- specs: modules combinables selon `mirror.json` (questions.md Q052) — 4 modules biome (racines/immobilisation/invocation végétale ; armure renforcée/charge/explosion ; déplacement aérien/éclairs/cristaux ; énergie du Noyau/corruption/zone majeure) + 5 mutations cicatrice (saignement, résistance, drain, poursuite, dégâts élevés) ; compatibles assemblage runtime. Un Miroir généré avec un seul biome/aucune cicatrice doit rester visuellement cohérent (pas de module manquant).
- priorite: basse
- statut: a_faire

### UI complémentaires — barres de vie, menu options, écran contrôles
- phase: 10 — Polish
- placeholder: aucun
- specs: barres de vie fines au-dessus des ennemis (questions.md Q057) ; menu options (volumes, plein écran/fenêtré, recalibration manette, Q058) ; écran de rappel des contrôles manette (Q059) ; confirmation d'effacement à « Nouvelle partie » (Q060). Priorité basse — UI passe après joueur/ennemis/boss/tilesets (Q071).
- priorite: basse
- statut: a_faire
