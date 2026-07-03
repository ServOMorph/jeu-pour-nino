# Roadmap CoreDive Challenge — v3

Réf design : `docs/v3/CoreDive Challenge — Design Document v3.md`

## Principe directeur

v3 n'est pas un rewrite. Le noyau gameplay (combat, feel, ennemis, animation, input, audio, pattern data-driven JSON) est conservé. v3 construit une couche méta-structurelle autour : persistance, HUB, biomes, mort-résurrection, cicatrices, boss adaptatif.

**Ordre guidé par les jalons jouables** : la boucle identitaire (mort → Arène du Voile → résurrection → cicatrice) est implémentée avant le contenu des biomes 2/3/4, conformément aux priorités P0 du design doc. Nino dispose d'une version jouable stable à chaque jalon.

**Règle placeholders** : aucune phase jeu n'attend game_art. Chaque phase livre avec des placeholders (rects, sprites temporaires) et recense ses besoins d'assets dans `game_art/backlog_art.md`. game_art produit à son rythme et remplace au fil de l'eau via sync.py. Les tâches marquées **[game_art]** sont listées pour traçabilité mais ne conditionnent jamais le « fait quand » d'une phase jeu.

Règle absolue maintenue : aucune valeur numérique gameplay hardcodée. Tout dans `game/data/*.json`.

---

## Carte du code (référence d'implémentation)

À lire avant toute phase. Racine projet Godot : `game/` (`res://` = `game/`).

### Autoloads (`game/project.godot`)
| Nom | Script | Rôle |
| --- | --- | --- |
| `JoyMap` | `scripts/joymap.gd` | Mapping manette PowerA + `setup_input()` centralisé. Toute nouvelle action input passe par lui (pas de bindings clavier sur les nouvelles actions). |
| `AudioManager` | `scripts/audio.gd` | Sons placeholder générés en code. `AudioManager.play("id")`. |
| `Dev` | `scripts/dev.gd` | Flags dev : `spawn`, `dev_resources`, `infinite_hp`. |
| `RunState` | `scripts/run_state.gd` | État de run éphémère : `resources: int`, `coins`, `items`, `consumables` + signaux typés. `reset()` appelé par `level.gd._ready()`. |
| `MetaState` | `scripts/meta_state.gd` | Persistant : `skill_points`, `grimoire` (id → {discovered, mastered}). API : `discover_recipe`, `master_recipe`, `is_mastered`, `spend_skill_points`. |
| `SaveManager` | `scripts/save_manager.gd` | `user://meta_state.json`, `save_meta()`/`load_meta()` (load au `_ready`). |

### Scènes et scripts clés
- `scenes/ui/title.tscn` (main scene) + `title.gd` : menu + mode dev. `_start_game()` fait `change_scene_to_file("res://scenes/levels/biome1.tscn")` (title.gd:188).
- `scenes/levels/biome1.tscn` + `level.gd` (321 l.) : construit tout le niveau depuis `res://data/level.json` (const `LEVEL_CONFIG`, level.gd:12) — fond, plateformes (rects), ennemis, ores, workbench, boss, HUD, pause. Trigger boss : `player.x > dims["arena_x"]` (level.gd:74-76). Fin de partie : `_on_player_died` / `_on_boss_died` → `SaveManager.save_meta()` + `_show_end_screen` (level.gd:301-321). `_return_to_title()` = `get_tree().quit()` (level.gd:273-275).
- `player.gd` (361 l.) : configs chargées depuis `player.json`, `weapons.json`, `armor.json`, `consumables.json`. Signal `died`. `_apply_equipment()` (player.gd:307) recalcule stats depuis `RunState.items` — liste d'épées hardcodée `["epee_fer", "epee_cuivre", "epee_bois"]` (player.gd:315). `damage_reduction` = modèle d'insertion des modificateurs (pour les cicatrices).
- `boss.gd` (258 l.) : machine à états `enum State {SLEEP, IDLE, CHARGE, VOLLEY, SLAM_RISE, SLAM_FALL, PAUSE}`, config JSON par clé `"Boss"` dans `boss.json` (`_load_config()`), signaux `health_changed`/`died`, `activate()`. Modèle pour Gardiens (Phase 5) et base de la modularisation R3.
- `enemy_base.gd` + `enemy_ground.gd`/`enemy_flyer.gd` : config `enemies.json`, signal `died(enemy)`.
- `ore_node.gd` : constantes hardcodées `ORE_SIZE/ORE_HP/ORE_DROP` (ore_node.gd:3-5) — à data-driver en Phase 1. Texture chargée en runtime via `ORE_TEXTURE_PATH` (plus de `preload`, cf. dette bloquante).
- `craft_menu.gd` (187 l.) : lit `recipes.json`, monnaie unique (`recipe["cost"]` vs `RunState.resources`), `_is_recipe_obsolete()` hardcodé épées (craft_menu.gd:181-187). UI programmatique en coordonnées viewport 480×270.
- `hud.gd` : s'abonne à `RunState.resources_changed` / `coins_changed` (hud.gd:61-70).

### Données (`game/data/`)
`player.json`, `weapons.json`, `armor.json`, `consumables.json`, `enemies.json`, `boss.json`, `level.json` (niveau fixe actuel), `recipes.json` (format actuel minimal : `[{"id", "name", "cost", "consumable"?}]`), `animations.json` (généré par sync depuis game_art — ne pas éditer ici).

### Tests
GUT 9.7.0 dans `game/addons/gut/`. Tests dans `game/tests/` : `test_run_state.gd`, `test_meta_state.gd`, `test_save_manager.gd`. Lancement headless :
```
D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path game -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit
```
Lancement jeu : `python run_game.py` (sync game_art puis Godot).

### Conventions
- Indentation tabs, GDScript typé (`:=`, signaux typés), UI programmatique (pas de layout dans les .tscn au-delà du nœud racine).
- Textes UI en français, pas d'emojis, pas de commentaires décoratifs.
- Toute valeur gameplay dans `game/data/*.json`, chargée avec le pattern défensif de `boss.gd._load_config()` (défauts dans le script, override si clé présente).
- Nouveaux JSON : parse défensif (`JSON.parse_string` + vérif type), jamais de crash sur fichier absent.

---

## ⚠ Dette bloquante Phase 0 (partiellement corrigée le 2026-07-03)

La migration `Inventory` → `RunState` était incomplète : l'autoload `Inventory` avait été retiré de `project.godot` mais trois appels subsistaient et crashaient à l'exécution. **Corrigé** :
- `ore_node.gd:42` — `Inventory.add(ORE_DROP)` → `RunState.add(ORE_DROP)`.
- `enemy_base.gd:107` — `Inventory.add_coins(coin_reward)` → `RunState.add_coins(...)`.
- `boss.gd:255` — `Inventory.add_coins(coin_reward)` → `RunState.add_coins(...)`.
- Bonus (bloquait aussi le démarrage) : `ore_node.gd`/`workbench.gd` chargeaient leur texture via `const := preload(...)`, qui échoue sans `.import` généré. Remplacé par chargement runtime `Image.load_from_file` (même convention que `animation_driver.gd`).

`grep -rn "Inventory" game/scripts` = zéro résultat. Vérifié : le niveau se charge et un run s'affiche sans erreur console (screenshot manuel).

**Reste à faire** : `game/scripts/inventory.gd` toujours présent (pas supprimé) ; 20 tests GUT non relancés ; run manuel complet (miner, crafter, tuer des ennemis, battre le boss, relancer → `MetaState` conservé) non exécuté intégralement — seul le chargement initial du niveau a été vérifié visuellement.

---

## Jalons jouables

Chaque jalon est une version stable que Nino peut jouer, placeholders compris.

| Jalon | Après | Contenu jouable |
| ----- | ----- | --------------- |
| J1 | Phase 3 | HUB fonctionnel, biome actuel jouable depuis le HUB, Grimoire/PC actifs |
| J2 | Phase 4 | Biome 1 procédural : deux runs = deux agencements, tous deux complétables |
| J3 | Phase 6 | Boucle identitaire complète : mourir, affronter un Gardien, ressusciter avec cicatrice |
| J4 | Phase 7a | Biome 2 (Mines Obscures) jouable |
| J5 | Phase 7b | Biome 3 (Îles Célestes) jouable |
| J6 | Phase 7c | Biome 4 (Descente vers le Noyau) jouable |
| J7 | Phase 9 | Miroir du Noyau : run complet jusqu'au boss final adaptatif |

---

## Stratégie de tests

Infra en place depuis la Phase 0 (GUT). Cible : la logique data-driven et d'état, testable et critique (parsing JSON, save/load, RunState/MetaState, craft, génération, cicatrices, calcul du boss adaptatif). Le feel/physique reste validé manuellement en jeu.

Règle : chaque phase livre ses tests en même temps que son code. Une phase n'est « faite » que si ses tests passent. Les tests des phases précédentes doivent rester verts (non-régression).

Pratique : un fichier `tests/test_<module>.gd` par module (`extends GutTest`, méthodes `test_*`, `before_each` pour resetter les autoloads — voir `test_run_state.gd` existant comme modèle). La logique à tester doit être exposée en fonctions sans dépendance de scène (fonctions pures ou méthodes d'autoload) — si un calcul est enfoui dans un nœud de scène, l'extraire.

**Objectif de couverture : 85 % minimum** sur les modules de logique data-driven/état (RunState, MetaState, SaveManager, Grimoire, génération de biomes, craft, cicatrices, boss adaptatif) — hors scènes, rendu, feel/physique. Vérifié et complété à chaque jalon de refacto (R1, R1.5, R2, R3) et une dernière fois avant la Phase 10.

## Jalons de refacto

Quatre points de consolidation placés là où la dette s'accumule naturellement, avant que la phase suivante ne la fige. Chacun inclut un audit de couverture de tests (combler jusqu'à 85 % sur le périmètre consolidé) :
- **R1** après Phase 2 — consolider la couche d'état (RunState/MetaState/Grimoire) avant de bâtir le HUB et les biomes dessus.
- **R1.5** après Phase 4 — consolider génération + HUB avant d'y greffer la boucle mort/résurrection (Phase 5, point critique de persistance d'état) et avant l'explosion de contenu de la Phase 7.
- **R2** après Phase 7 — factoriser ce qui s'est dupliqué entre biomes, ennemis, boss ET Gardiens du Voile avant d'empiler porteurs et boss adaptatif.
- **R3** avant Phase 9 — préparer la modularité boss (extraire les modules réutilisables de `boss.gd`).

---

## Phase 0 — Fondations : persistance et découplage état

### Tâches
- [x] `save_manager.gd` (autoload, `user://meta_state.json`).
- [x] Scission `inventory.gd` → `RunState` (éphémère) + `MetaState` (persistant).
- [x] Migration des usages `Inventory` → `RunState` dans `player.gd`, `craft_menu.gd`, `level.gd`, `hud.gd`.
- [x] Chargement/sauvegarde `MetaState` au démarrage et en fin de run.
- [x] GUT installé, 20 tests écrits (`tests/`).
- [ ] **Corriger la dette bloquante ci-dessus** (3 appels `Inventory` résiduels + suppression `inventory.gd`).
- [ ] **Validation en jeu** : GUT vert + run manuel complet + persistance `MetaState` après relance.

### Fait quand
Un run modifie `RunState` sans toucher `MetaState`. Fermer/relancer le jeu conserve `MetaState`. Le jeu actuel reste jouable de bout en bout après migration (miner, crafter, boss). Tests verts.

### Dépend de
Rien.

---

## Phase 1 — Matériaux typés

Le craft v3 consomme des matériaux distincts (bois, pierre, cuivre, fer, cristaux, fragments du Noyau...). Aujourd'hui `RunState.resources` est un seul entier.

### Tâches
- [ ] `game/data/materials.json` — nouveau fichier :
  ```json
  {
    "bois":   {"name": "Bois",   "biome": "biome1", "rarity": "common"},
    "cuivre": {"name": "Cuivre", "biome": "biome1", "rarity": "common"},
    "fer":    {"name": "Fer",    "biome": "biome2", "rarity": "uncommon"}
  }
  ```
- [ ] `RunState` : remplacer `resources: int` par `materials: Dictionary` (id → int). Nouvelle API :
  - `add_material(id: String, qty: int) -> void`
  - `get_material(id: String) -> int`
  - `spend_materials(costs: Dictionary) -> bool` — atomique : vérifie TOUT avant de débiter quoi que ce soit.
  - Signal `materials_changed(id: String, count: int)` remplace `resources_changed(current: int)`.
  - Adapter `serialize()`/`deserialize()` et `reset()`.
- [ ] Migrer les consommateurs de l'ancien champ (les repérer par `grep -n "resources" game/scripts/*.gd`) :
  - `hud.gd:61-82` : abonnement `resources_changed` → `materials_changed`, affichage par type (liste compacte `icône/id: qté`).
  - `craft_menu.gd:113` (`RunState.resources >= cost`) et `:154` (`RunState.spend`) : basculer sur `spend_materials` — transition minimale en Phase 1 (recette à coût mono-matériau), refonte complète en Phase 2.
  - `level.gd:34-35` et `:277-284` (`_toggle_dev_resources`) : voir risque « 100 MIN » ci-dessous.
- [ ] `ore_node.gd` : supprimer les constantes hardcodées (ore_node.gd:3-6). Le gisement reçoit un `material_id` et lit taille/HP/drop/texture depuis `materials.json` (section `ore` par matériau : `{"hp": 3, "drop": 1, "size": [14,14], "sprite": "res://assets/sprites/objects/ore_copper.png"}`). Drop → `RunState.add_material(material_id, drop)`.
- [ ] `level.json` : les entrées `ores` passent de `[x, y]` à `{"pos": [x, y], "material": "cuivre"}`. Adapter `level.gd._spawn_ores()` (level.gd:207-211).
- [ ] Tests (`test_run_state.gd` étendu) : add/get/spend atomique (échec si un seul matériau manque → aucun débit), serialize/deserialize, reset.
- [ ] Recenser dans `game_art/backlog_art.md` : sprites distincts par type de gisement/minerai. **[game_art]**

### Fait quand
Miner un gisement ajoute le bon matériau. Le HUD reflète les quantités par type. Tests verts.

### Dépend de
Phase 0.

### Risques
Le mode dev « 100 MIN » (`title.gd:176-177`, `Dev.dev_resources`, `level.gd:34-35`) suppose une monnaie unique. Réadaptation retenue : `Dev.dev_resources > 0` donne 100 de **chaque** matériau défini dans `materials.json` (une boucle sur les clés). Simple, couvre tous les besoins de test.

---

## Phase 2 — Grimoire, Points de Compétence, Craft v3

### Tâches
- [ ] Étendre `recipes.json` — schéma cible (remplace le format actuel `{id, name, cost}`) :
  ```json
  {
    "id": "epee_cuivre",
    "name": "Epee cuivre",
    "rarity": "common",
    "biome": "biome1",
    "skill_cost": 2,
    "materials": {"bois": 1, "cuivre": 3},
    "consumable": false,
    "workbench_tier": 1,
    "starter": false
  }
  ```
  `discovered`/`mastered` ne vivent PAS dans ce fichier (état méta → `MetaState.grimoire`). `starter: true` = maîtrisée d'office.
- [ ] Recettes de départ (`starter: true`) : épée bois, armure bois, pioche, petite potion, torche, corde, établi portable. Au premier lancement (grimoire vide), `MetaState` enregistre les starters comme découvertes+maîtrisées (méthode `ensure_starters(ids: Array)` appelée après `load_meta`).
- [ ] `MetaState` : la base existe (`discover_recipe`, `master_recipe`, `is_mastered`). Ajouter la dépense de PC à la maîtrise : `master_recipe(id, cost: int) -> bool` (échec si `skill_points < cost` ou non découverte). Le coût vient de `recipes.json` (`skill_cost`), passé par l'appelant — `MetaState` ne lit pas les fichiers de données.
- [ ] Refondre `craft_menu.gd` :
  - Charger `recipes.json` au nouveau schéma.
  - `_sync_visible_recipes()` : ne proposer QUE les recettes maîtrisées (`MetaState.is_mastered`). Affichage coût : liste des matériaux (`"2 bois, 3 cuivre"`) au lieu de `"%d MIN"`.
  - `_try_craft()` : `RunState.spend_materials(recipe["materials"])`.
  - Supprimer `_is_recipe_obsolete()` (craft_menu.gd:181-187, hardcodé épées) — remplacé par la maîtrise + paliers.
- [ ] Gain de PC en fin de run — métrique : salles explorées + biomes visités + élites/boss vaincus + salles secrètes + réussite du run. Compteurs dans `RunState` (incrémentés par `level.gd`), barème dans `game/data/progression.json`, calcul dans une fonction pure `compute_skill_points(counters: Dictionary, bareme: Dictionary) -> int` (testable). Appel aux deux points de fin de run existants : `level.gd._on_player_died` et `_on_boss_died` (level.gd:301-314), avant `SaveManager.save_meta()`. Tant que salles/biomes n'existent pas (Phases 3-4), les compteurs valent 0 ou 1 — le barème fonctionne quand même.
- [ ] Écran de déblocage des recettes (dépense de PC) : CanvasLayer programmatique sur le modèle de `craft_menu.gd` (liste, sélection, `ui_accept` pour maîtriser). Livré en Phase 2 accessible via le menu dev de `title.gd` ; branché au HUB en Phase 3. Recenser mise en page/icônes du Grimoire dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Test dédié synergie cross-biomes : une recette multi-matériaux (ex. fer + cristaux + fragment du Noyau) craftable si et seulement si tous les matériaux sont présents.
- [ ] `workbench_tier` stocké dès maintenant ; activation réelle des établis avancés en Phase 7.
- [ ] Nouveau `tests/test_craft.gd` : filtrage maîtrisées, craft débite les matériaux, découverte → maîtrise (coût PC), starters, gain de PC (barème).

### Fait quand
Découvrir une recette en run l'ajoute au Grimoire (persistant). La maîtriser coûte des PC. Une recette maîtrisée est craftable au prochain run si matériaux réunis. Tests verts.

### Dépend de
Phases 0, 1.

### Risques
`player.gd._apply_equipment()` (player.gd:315) hardcode la hiérarchie des épées `["epee_fer", "epee_cuivre", "epee_bois"]` et `_update_weapon_visual()` (player.gd:348) les couleurs par épée. À généraliser au passage : `weapons.json` porte un champ `tier`, l'équipement actif = l'arme possédée de tier max. Sinon chaque nouvelle arme de biome (Phase 7) exigera une retouche de `player.gd`.

---

## Refacto R1 — Consolidation de la couche d'état

### Tâches
- [ ] Revue de l'API RunState/MetaState : nommage cohérent, `grep -rn "Inventory" game/` = zéro (fichier `inventory.gd` supprimé en Phase 0 — vérifier).
- [ ] Centraliser les accès au Grimoire : seuls `MetaState` (état) et l'écran de déblocage/craft_menu (UI) le manipulent ; pas de logique grimoire dispersée dans level/player.
- [ ] Vérifier la disparition complète de la logique d'obsolescence héritée des épées (craft_menu + généralisation tiers dans player.gd).
- [ ] Auditer la couverture de tests de la couche d'état, compléter jusqu'à 85 %.

### Fait quand
Aucune référence à l'ancien `Inventory`. Tests d'état exhaustifs et verts. Couverture ≥ 85 % sur RunState/MetaState/SaveManager/Grimoire.

---

## Phase 3 — HUB et sélection de biome → **Jalon J1**

### Tâches
- [ ] Créer `scenes/levels/hub.tscn` + `scripts/hub.gd` : point central, 4 directions (placeholder « en construction » pour les non-implémentées), déplacement du player (réutiliser la scène player sans ennemis), zones d'interaction sur le modèle de `workbench.gd` (`interact_requested`). Config `game/data/hub.json` (positions, directions actives). Recenser décor du HUB dans `game_art/backlog_art.md`. **[game_art]**
- [ ] `title.gd._start_game()` (title.gd:181-188) : `change_scene_to_file` vers `hub.tscn` au lieu de `biome1.tscn`. Conserver les flags Dev (spawn/ressources/HP) — le mode dev peut garder un raccourci « biome direct ».
- [ ] Paramétrer le chargement de niveau : remplacer la const `LEVEL_CONFIG` (level.gd:12) par un `biome_id` fourni au chargement — pattern : autoload léger `GameFlow` (ou champ dans `Dev`) portant `next_biome_id`, lu par `level.gd._ready()` qui charge `res://data/biomes/<id>.json`. Déplacer `level.json` → `data/biomes/biome1.json`.
- [ ] Retour au HUB : remplacer `_show_end_screen`/`get_tree().quit()` (level.gd:273-275, 301-321) par un écran de fin bref puis `change_scene_to_file(hub.tscn)`. `RunState.reset()` se fait au lancement d'un run (déjà dans `level.gd._ready()`, level.gd:33) — vérifier qu'un aller-retour HUB↔biome ne double-reset pas.
- [ ] Accès depuis le HUB : Grimoire/écran de déblocage PC (livré Phase 2) et établi.
- [ ] Tests (`test_game_flow.gd`) : sélection de biome → bon fichier chargé, compteurs de fin de run alimentent bien les PC au retour HUB.

### Fait quand
Depuis le HUB, choisir une direction lance le biome correspondant. Mourir/finir ramène au HUB. Le mode dev reste fonctionnel. **J1 : Nino peut jouer un run complet HUB → biome → retour HUB.**

### Dépend de
Phases 0, 2.

### Risques
`level.gd` suppose des dimensions fixes et un boss déclenché par `arena_x` (level.gd:74-76). Le paramétrage par biome doit abstraire ça proprement (préparer la Phase 4 : le trigger boss devient une donnée du JSON de biome, pas une position hardcodée dans le code).

---

## Phase 4 — Génération des biomes → **Jalon J2**

Le point le plus risqué. **Décision arrêtée : assemblage de salles pré-authorées (templates).** Pas de PCG algorithmique pur. **Validée sur le biome 1 uniquement** — les biomes 2/3/4 réutiliseront le générateur en Phase 7.

### Approche d'implémentation (clé)
Le générateur ne remplace pas `level.gd` : il **produit la même structure de données que l'actuel `level.json`** (dimensions, platforms.rects, enemies, ores, boss, workbench, spawns). `level.gd` continue de consommer ce format — la refonte de `level.gd` se limite à « recevoir un Dictionary au lieu de lire un fichier fixe ». Toute la logique d'assemblage vit dans `biome_generator.gd`, en fonctions pures testables sans scène.

### Tâches
- [ ] Format de salle — `game/data/rooms/biome1/*.json` :
  ```json
  {
    "id": "salle_puits_01",
    "size": [480, 270],
    "platforms": [[0, 250, 480, 20], [120, 180, 80, 12]],
    "spawn_points": {"enemies": [{"pos": [200, 230], "type": "ground"}],
                     "ores": [{"pos": [300, 235], "material": "cuivre"}],
                     "workbench": [90, 235]},
    "connections": {"left": [0, 230], "right": [480, 230]},
    "tags": ["standard"]
  }
  ```
  Coordonnées locales à la salle ; le générateur translate lors de l'assemblage.
- [ ] `game/scripts/biome_generator.gd` : `static func generate(biome_cfg: Dictionary, rooms: Array, rng_seed: int) -> Dictionary` — enchaîne N salles (longueur depuis la config biome), aligne les connexions, translate plateformes/spawns en coordonnées monde, retourne le Dictionary format `level.json`. Déterministe à seed égal (utiliser `RandomNumberGenerator` seedé, jamais `randi()` global).
- [ ] Config biome (`data/biomes/biome1.json` étendu) : `{"rooms_pool": [...], "length": [5, 7], "guaranteed_materials": {"cuivre": 4, "bois": 3}, "boss": {...}}`.
- [ ] Garantie de ressources : après assemblage, si un matériau clé est sous le minimum, injecter des gisements sur les spawn points d'ore inutilisés (ou rejeter/regénérer — au choix, mais borné et testé).
- [ ] Placement boss en fin de parcours (dernière salle taggée `boss` ou arène ajoutée en bout) ; le trigger `arena_x` devient une sortie du générateur.
- [ ] `level.gd` : consommer le Dictionary généré (seed tirée au lancement du run, conservée dans `RunState` — nécessaire à la Phase 5).
- [ ] `tests/test_biome_generator.gd` : sur 100 générations seedées — chemin start→boss connexe (parcours des connexions), minima de matériaux respectés, aucune salle disjointe, déterminisme (même seed → même sortie).
- [ ] Recenser tileset/décors biome 1 dans `game_art/backlog_art.md`. **[game_art]**

### Fait quand
Lancer le biome 1 deux fois produit deux agencements différents, tous deux complétables, avec les ressources clés présentes. Tests de complétabilité et de garantie ressources verts sur N générations. **J2.**

### Dépend de
Phase 3.

### Risques
Garantie de complétabilité (le joueur ne doit jamais être bloqué). Couverte par tests automatisés sur la connectivité. Attention au respawn d'ennemis existant (`level.gd:178-199`, positions issues de la config) : les positions de respawn doivent venir des données générées, pas de l'ancien fichier.

---

## Refacto R1.5 — Consolidation génération + HUB

### Tâches
- [ ] Revue de l'API `biome_generator.gd` / `level.gd` : séparation stricte génération (fonctions pures) vs consommation (scène).
- [ ] Vérifier qu'aucune donnée gameplay du biome 1 n'est restée hardcodée hors JSON (audit `grep` sur les littéraux numériques ajoutés).
- [ ] Auditer la couverture de tests génération + HUB, compléter jusqu'à 85 %.

### Fait quand
`level.gd` et `biome_generator.gd` exposent une API stable. Tests exhaustifs et verts. Couverture ≥ 85 % sur le périmètre génération/HUB.

---

## Phase 5 — Mort, Résurrection, Arène du Voile

Boucle identitaire du jeu (P0) — implémentée tôt, avec le seul biome 1, pour valider la mécanique phare et dérisquer la persistance d'état de biome.

### Approche retenue pour la persistance du biome
Deux options existent : (a) **conserver la scène biome en mémoire** — `remove_child(biome)` sans `queue_free`, garder la référence, charger l'Arène, puis ré-attacher le biome au retour ; (b) sérialiser/désérialiser tout l'état du biome. **Recommandation : (a)**, ordres de grandeur plus simple et moins bugogène ; aucune exigence de sauvegarde mi-run ne justifie (b). Points de vigilance de (a) : mettre en pause les timers du biome retirés de l'arbre (les `create_timer` de respawn sont liés à `get_tree()` — les désactiver pendant l'Arène via un flag), et restaurer position/vitesse/PV du player explicitement. Le test dédié reste requis quel que soit le choix.

### Tâches
- [ ] Interception de la mort : `level.gd._on_player_died` (level.gd:301) — si des tentatives de résurrection restent, transition vers l'Arène au lieu de la fin de run. Compteur `RunState.resurrection_count`.
- [ ] `player.gd._die()` (player.gd:288) : prévoir la réanimation (`revive(hp)` qui remet `_dead = false`, restaure PV, réémet `health_changed`) — actuellement `_dead` est définitif.
- [ ] Scène Arène du Voile (unique) `scenes/levels/veil_arena.tscn`, décor placeholder. Recenser décor « tribunal cosmique » dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Gardiens du Voile : **2-3 Gardiens simples**, construits sur le modèle `boss.gd` (machine à états + `_load_config` défensif), configs dans `game/data/guardians.json` (une clé par Gardien, structure calquée sur `boss.json`). Tirage aléatoire à chaque passage.
- [ ] Difficulté croissante : multiplicateurs (HP, dégâts, vitesse) par `resurrection_count`, table dans `guardians.json` (`"escalation": [{"hp_mult": 1.0}, {"hp_mult": 1.3}, ...]`). Fonction pure `apply_escalation(base_cfg, count) -> Dictionary`, testée.
- [ ] Victoire → retour au biome **dans l'état exact quitté** (option (a) ci-dessus), résurrection à l'endroit de la mort, PV restaurés, cicatrice appliquée (stub tant que Phase 6 non faite). Défaite → fin de run définitive (PC de fin de run quand même), retour HUB.
- [ ] Recenser sprites/patterns visuels des Gardiens dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Tests (`test_veil.gd`) : escalade des Gardiens (fonction pure), état biome conservé autour de l'aller-retour (au minimum : seed inchangée, ores minés absents, ennemis morts non ressuscités — test d'intégration léger sur les structures de données si la scène n'est pas testable directement).

### Fait quand
Mourir envoie à l'Arène. Vaincre le Gardien ressuscite le joueur dans le biome, **dans l'état exact où il l'avait quitté**. Perdre termine le run. Tests d'état biome verts.

### Dépend de
Phase 4, R1.5.

### Risques (À SURVEILLER — point critique)
- **Le biome ne doit surtout pas être régénéré au retour de l'Arène.** Avec l'option (a), le risque se déplace vers les timers/références pendantes de la scène détachée — vérifier respawn, tweens, `get_tree()` null. Couvrir par test + validation manuelle systématique.
- Les Gardiens sont construits sur le modèle `boss.gd` non consolidé (R2 pas encore passé). Coût assumé : R2 inclura les Gardiens dans la factorisation. Limiter à 2-3 Gardiens simples. Ne PAS copier-coller `boss.gd` trois fois : un seul `guardian.gd` paramétré par sa config JSON.

---

## Phase 6 — Cicatrices → **Jalon J3**

### Tâches
- [ ] `game/data/scars.json` :
  ```json
  {
    "membre_raidi": {"name": "Membre raidi", "modifiers": {"speed_mult": 0.9}},
    "vision_voilee": {"name": "Vision voilee", "modifiers": {"max_hp_add": -1}}
  }
  ```
  Clés de modificateurs supportées au départ : `speed_mult`, `jump_mult`, `max_hp_add`, `attack_damage_add`, `damage_reduction_add`. Extension = nouvelle clé + son application, rien d'autre.
- [ ] Application dans `player.gd` : étendre `_apply_equipment()` (player.gd:307, déjà le point unique de recalcul des stats) — après équipement, appliquer les modificateurs des cicatrices actives. Renommer en `_recompute_stats()` à cette occasion.
- [ ] `RunState.scars: Array[String]` + `add_scar(id)` + signal `scars_changed` + serialize/reset.
- [ ] Tirage de la cicatrice à chaque résurrection (dans le flux de retour d'Arène, Phase 5) : aléatoire uniforme parmi les non-possédées ; si toutes possédées, doublon autorisé (cumul).
- [ ] Recettes du Voile : `biome: "voile"` dans `recipes.json` (Lame Spectrale, Anneau des Revenants, Élixir de Résurgence) — découverte droppée à la victoire en Arène (`MetaState.discover_recipe`).
- [ ] Affichage HUD : rangée d'icônes placeholder des cicatrices actives.
- [ ] Recenser effets visuels par palier (1 à 5+) via shaders + overlays de particules dans `game_art/backlog_art.md` — PAS de refonte de spritesheet. **[game_art]**
- [ ] Tests (`test_scars.gd`) : application des modificateurs (stats recalculées correctes), cumul (deux cicatrices = effets combinés), drop des recettes du Voile, serialize.

### Fait quand
Chaque résurrection applique une cicatrice qui modifie réellement le gameplay, persistante jusqu'à la fin du run. Vaincre un Gardien peut faire découvrir une recette du Voile. **J3 : la boucle identitaire complète est jouable.**

### Dépend de
Phase 5.

### Risques
Cumul de cicatrices : éviter les combinaisons injouables (borne plancher sur les stats finales : `speed >= 0.5 * base`, `max_hp >= 2` — bornes dans `scars.json`, pas dans le code). Équilibrage provisoire jusqu'à la Phase 10.

---

## Phase 7 — Contenu des biomes 2, 3, 4 → **Jalons J4, J5, J6**

Étalée strictement biome par biome : 7a = Mines Obscures (J4), 7b = Îles Célestes (J5), 7c = Descente vers le Noyau (J6). Un biome est terminé avant d'attaquer le suivant.

### Tâches (répétées par biome)
- [ ] `data/biomes/<id>.json` + salles `data/rooms/<id>/` (réutilise le générateur Phase 4 tel quel).
- [ ] Ennemis spécifiques : étendre `enemies.json` + sous-classes de `enemy_base.gd` uniquement si le comportement l'exige (préférer le paramétrage JSON à la sous-classe).
- [ ] Ressources spécifiques : entrées `materials.json` (déjà typées Phase 1), gisements dans les salles.
- [ ] Boss de biome : Foreur Maudit (7a), Orage Éternel (7b), Gardien du Noyau (7c) — nouvelles clés dans `boss.json` sur le modèle existant ; nouveaux états/attaques ajoutés à la machine de `boss.gd` si nécessaire (en notant la duplication pour R2/R3).
- [ ] Établis avancés : activation du `workbench_tier` (Phase 2) — `workbench.gd` porte un tier, `craft_menu` filtre les recettes au tier de l'établi utilisé.
- [ ] Recenser par biome dans `game_art/backlog_art.md` : sprites ennemis, boss, décors, tileset. **[game_art]**

### Fait quand
Chaque biome livré est jouable de bout en bout avec ses ennemis, ressources et boss (placeholders acceptés). Les 4 biomes jouables = fin de phase.

### Dépend de
Phases 4, 6.

### Risques
Gros volume de contenu. Ne jamais paralléliser deux biomes. Difficulté croissante à équilibrer.

---

## Refacto R2 — Factorisation biomes / ennemis / boss / Gardiens

### Tâches
- [ ] Extraire les patterns communs des biomes (chargement config, génération, spawn) dans une base partagée.
- [ ] Factoriser les comportements d'ennemis récurrents dans `enemy_base.gd`.
- [ ] Unifier la structure boss de biome / Gardiens du Voile (même base de machine à états, prépare R3).
- [ ] Étendre le pool de Gardiens sur la base unifiée (cible : 8 — sinon reliquat au backlog post-v3).
- [ ] Audit anti-hardcode : toute donnée gameplay externalisée.
- [ ] Auditer la couverture de tests biomes/ennemis/boss/Gardiens, compléter jusqu'à 85 %.

### Fait quand
Aucune duplication structurelle majeure entre biomes/boss/Gardiens. Tests de non-régression verts sur les 4 biomes et l'Arène. Couverture ≥ 85 % sur le périmètre consolidé.

---

## Phase 8 — Porteurs de recettes

### Tâches
- [ ] Ennemis rares (Archiviste, Golem Artisan, Mineur Spectral, Forgeron Maudit) — apparition conditionnelle par biome (probabilité dans la config biome, tirage à la génération).
- [ ] Drop = découverte de recette : `MetaState.discover_recipe(id)` à la mort du porteur, catégories de drop cohérentes par porteur (table dans `enemies.json` ou `recipes.json`).
- [ ] Feedback visuel/sonore de découverte (toast HUD « Recette découverte »).
- [ ] Recenser sprites des 4 porteurs dans `game_art/backlog_art.md`. **[game_art]**

### Fait quand
Vaincre un porteur ajoute une recette « Découverte » au Grimoire.

### Dépend de
Phases 2, 7.

### Risques
Taux d'apparition/drop à équilibrer pour que la collection soit gratifiante sans être frustrante.

---

## Refacto R3 — Modularité boss

### Tâches
- [ ] Découper la base boss (issue de R2) en modules : corps (HP/hitbox/visuel), déplacement, pouvoir principal, mutations. Un module = un script + sa section de config JSON.
- [ ] Interface d'assemblage : un boss = liste de modules instanciés depuis une description `{"body": "...", "movement": "...", "powers": [...], "mutations": [...]}`.
- [ ] Valider en ré-exprimant les boss de biome et Gardiens existants comme combinaisons de modules — comportement identique constaté en jeu.
- [ ] `tests/test_boss_assembly.gd` : assemblage depuis description, modules reçoivent leur config, descriptions invalides rejetées proprement.
- [ ] Auditer la couverture de tests des modules boss, compléter jusqu'à 85 %.

### Fait quand
Les boss existants fonctionnent via l'architecture modulaire. L'assemblage est testé et prêt pour la génération adaptative. Couverture ≥ 85 % sur les modules boss.

---

## Phase 9 — Miroir du Noyau (boss final adaptatif) → **Jalon J7**

**Scope arrêté : 2 paramètres** — biomes explorés + cicatrices accumulées. Le design doc en décrit 4 ; « boss vaincus » et « style de jeu » sont coupés de v3 → backlog post-v3.

### Tâches
- [ ] Fonction pure `build_mirror_description(biomes_visited: Array, scars: Array, cfg: Dictionary) -> Dictionary` : produit une description de boss (format R3) à partir des 2 paramètres (tracés dans `RunState`) et d'une table de correspondance `game/data/mirror.json` (biome → modules, cicatrice → mutations). Déterministe.
- [ ] Instanciation via l'assemblage R3, déclenchement après le Gardien du Noyau (Biome 4).
- [ ] Recenser modules visuels combinables dans `game_art/backlog_art.md`. **[game_art]**
- [ ] `tests/test_mirror.gd` : déterminisme (mêmes paramètres → même description), cas extrêmes (tous biomes + toutes cicatrices ; aucun biome, aucune cicatrice), chaque entrée de `mirror.json` référence des modules existants.

### Fait quand
Atteindre le Noyau génère un boss reflétant le parcours du run. Deux runs différents produisent deux boss différents. Tests verts. **J7.**

### Dépend de
Phases 6, 7, R3.

### Risques
Combinatoire de modules = risque de bugs/équilibrage. Limiter le nombre de modules au départ, étendre ensuite. Tester les combinaisons extrêmes.

---

## Phase 10 — Intégration, équilibrage, polish

### Tâches
- [ ] Équilibrage global (PC, coûts de maîtrise, difficulté biomes, escalade Gardiens, cicatrices) — passe définitive, uniquement dans les JSON.
- [ ] Boucle méta complète testée sur plusieurs runs.
- [ ] Passes audio/feedback.
- [ ] Remplacement des placeholders restants (piloté par `game_art/backlog_art.md`), cohérence visuelle globale. **[game_art]**
- [ ] Audit final de couverture (≥ 85 %).

### Fait quand
Un joueur peut enchaîner plusieurs runs, progresser via le Grimoire/PC, mourir et ressusciter, et atteindre le Miroir du Noyau dans une expérience cohérente.

### Dépend de
Toutes.

---

## Ordre de dépendances (résumé)

```
0 Fondations (+ dette Inventory à purger, validation en jeu)
└─ 1 Matériaux typés
   └─ 2 Grimoire/PC/Craft
      └─ R1 Consolidation état
         └─ 3 HUB + sélection biome                    [J1]
            └─ 4 Génération biome 1 (templates)        [J2]
               └─ R1.5 Consolidation génération/HUB
                  └─ 5 Mort/Résurrection/Voile
                     └─ 6 Cicatrices + recettes du Voile  [J3]
                        └─ 7 Contenu biomes 2/3/4         [J4 J5 J6]
                           └─ R2 Factorisation (incl. Gardiens)
                              ├─ 8 Porteurs de recettes (dépend de 2 et 7)
                              └─ R3 Modularité boss
                                 └─ 9 Miroir du Noyau     [J7]
0..9 ─ 10 Intégration/polish
```

Tests : livrés à chaque phase, maintenus verts (non-régression), cible 85 % sur la logique data-driven/état. Refacto : R1 (après 2), R1.5 (après 4), R2 (après 7), R3 (avant 9).

## Risques transverses majeurs

1. **Dette Phase 0 non purgée** — les 3 appels `Inventory` résiduels crashent le jeu au premier minerai/ennemi. À corriger avant tout.
2. **Persistance de l'état de biome à la résurrection (Phase 5)** — ne pas régénérer le biome au retour de l'Arène ; scène conservée en mémoire (option retenue), timers/références pendantes à surveiller, test dédié obligatoire.
3. **Gardiens du Voile construits avant R2** — dette assumée (2-3 Gardiens sur un seul `guardian.gd` paramétré, jamais de copier-coller de `boss.gd`) ; R2 inclut leur factorisation.
4. **Volume d'art** — neutralisé par la règle placeholders + `game_art/backlog_art.md`.
5. **Équilibrage de la boucle méta (Phase 10)** — nécessite des runs complets répétés ; équilibrage des cicatrices provisoire jusque-là.
6. **Dette inter-phases** — neutralisée par R1/R1.5/R2/R3 ; ne pas les sauter sous pression de contenu.
7. **Couverture de tests** — vérifiée à chaque jalon de refacto ; ne pas la laisser dériver.

## Backlog post-v3

Coupes assumées, à ne pas perdre :

- Miroir du Noyau — paramètre « boss vaincus » (héritage des pouvoirs des boss battus).
- Miroir du Noyau — paramètre « style de jeu » (tracking d'usage des armes → adaptation du boss).
- Pool complet de 8 Gardiens du Voile si non atteint en R2 (reliquat).
- Alignement du design doc sur le scope 2 paramètres du Miroir.
