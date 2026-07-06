# Roadmap CoreDive Challenge — v3

Réf design : `docs/v3/CoreDive Challenge — Design Document v3.md`

## Principe directeur

v3 n'est pas un rewrite. Le noyau gameplay (combat, feel, ennemis, animation, input, audio, pattern data-driven JSON) est conservé. v3 construit une couche méta-structurelle autour : persistance, HUB, biomes, mort-résurrection, cicatrices, boss adaptatif.

**Ordre guidé par les jalons jouables** : la boucle identitaire (mort → Arène du Voile → résurrection → cicatrice) est implémentée avant le contenu des biomes 2/3/4, conformément aux priorités P0 du design doc. Nino dispose d'une version jouable stable à chaque jalon.

**Règle placeholders** : aucune phase jeu n'attend game_art. Chaque phase livre avec des placeholders (rects, sprites temporaires) et recense ses besoins d'assets dans `game_art/backlog_art.md`. game_art produit à son rythme et remplace au fil de l'eau via sync.py. Les tâches marquées **[game_art]** sont listées pour traçabilité mais ne conditionnent jamais le « fait quand » d'une phase jeu.

Règle absolue maintenue : aucune valeur numérique gameplay hardcodée. Tout dans `game/data/*.json`.

---

## Décisions verrouillées (questions.md, 2026-07-06)

77 questions de conception ont été tranchées avant le lancement du développement (voir `questions.md` à la racine pour le détail complet et les justifications). Résumé des décisions qui modifient ou précisent cette roadmap, par thème :

**Structure du run** — Un run = toute la descente (HUB inclus), pas un seul biome. `RunState.reset()` a lieu au lancement d'un **nouveau run** depuis le titre, jamais à l'entrée d'un biome depuis le HUB. Un biome quitté puis revisité est **régénéré** (nouvel agencement) ; un seul biome vivant en mémoire à la fois (l'Arène du Voile reste l'unique exception, détachée pendant une résurrection). Le joueur peut quitter un biome volontairement via un objet/portail de retour, en conservant sa récolte. Un boss de biome vaincu ne réapparaît pas dans le run mais le biome reste explorable. Le Gardien du Noyau (B4) seul suffit à ouvrir le Miroir, sans prérequis d'autres biomes. Victoire du run = vaincre le **Miroir du Noyau** (pas seulement le Gardien du Noyau) ; après victoire, écran de fin puis retour HUB (pas de New Game+). Pas de plafond dur de résurrections (l'escalade des Gardiens borne naturellement). Durée cible d'un run : ~30-45 min ; pas de sauvegarde mi-run (seul `MetaState` persiste).

**Fondations techniques** — Solo strict (pas d'anticipation coop). Windows uniquement, PC de Nino. Pas de versioning des sauvegardes (reset accepté en dev). Un seul profil de sauvegarde. `calibration.tscn` accessible depuis le menu options du jeu final. Réglages (volumes, plein écran/fenêtré, calibration) dans `user://settings.json`, séparé de `meta_state.json`. `SaveManager.save_meta()` appelé à **chaque événement méta** (découverte, maîtrise, PC gagnés), pas seulement en fin de run. Cible 60 FPS, plein écran par défaut, écran de transition accepté entre HUB et biome.

**Joueur et combat** — Mobilité : déplacement, saut, **double saut**, **corde/grappin** (pas de dash, pas de wall jump). Combat mêlée à attaque simple (pas de combo/charge). **Armes à distance ajoutées** (nouveau bouton manette à réserver dans `joymap.gd`), usage illimité sans munitions. **4 slots d'équipement** : Arme (mêlée ou distance, un seul slot), Armure, Accessoire, Outil. Écran d'équipement manuel accessible depuis la pause (l'auto-équipement « meilleure arme » est abandonné). 1 slot consommable actif, bouton dédié. Inventaire de matériaux illimité. Minage gaté par tier de pioche (`tier` dans `materials.json`/pioche). Pas d'arbre de stats : progression uniquement via équipement crafté. Soins : potions + régénération complète au HUB uniquement (pas de soin post-boss, pas de régénération passive). Torche : équipable (slot Outil), effet gameplay réel — sans elle, le Biome 2 est trop sombre pour bien jouer (overlay pénalisant la visibilité, pas de vrai Light2D dynamique). Corde fusionnée avec le grappin (pas un objet distinct). Établi Portable repositionnable à volonté, limité au tier 1.

**Cicatrices et Arène du Voile** — Liste définitive des 5 cicatrices (Sang, Os, Âme, Peur, Noyau) avec clés de modificateurs `max_hp_mult`, `speed_mult`, `heal_mult` (nouvelle), `detection_mult` (nouvelle, nécessite `detection_radius` dans `enemies.json`/`enemy_base.gd`), `attack_damage_mult`. **Planchers durs par stat obligatoires** dans `scars.json` (ex. `speed_mult` ≥ 0.5, `max_hp` ≥ 2, `heal_mult` ≥ 0.3) pour éviter un état dégénéré en cas de cumul de cicatrices sur de nombreuses résurrections (pas de plafond de résurrections, cf. ci-dessus). Tirage de cicatrice aléatoire imposé (pas de choix), annoncé via un écran dédié. Un seul Gardien du Voile implémenté en Phase 5 (Le Veilleur des Cendres — charge, projectile de cendres, zone d'explosion retardée, pause vulnérable ; réutilise directement la machine à états de `boss.gd`) ; les 7 autres du pool sont ajoutés en R2/Phase 7. PV restaurés à l'entrée de l'Arène, consommables utilisables. Table d'escalade provisoire : ×1.0/×1.3/×1.6/×2.0/×2.5+ (paliers 1 à 5+).

**Génération des biomes** — Format de salle et `biome_generator.gd` supportent les **4 directions de connexion** (left/right/top/bottom) dès la Phase 4, même si seul le biome 1 (horizontal) est généré à ce stade — nécessaire pour B3 (vers le haut) et B4 (vers le bas) en Phase 7. Structure interne : chemin principal + **embranchements légers** menant à des culs-de-sac (trésor, salle secrète, gisement bonus). Salles secrètes signalées par un indice visuel discret (fissure, luminosité différente), pas un mur à traverser en aveugle. Tailles cibles : B1 5-7 salles, B2 6-8, B3 7-9, B4 8-10. **8-10 templates par biome**. Écran fixe par salle (480×270, pas de scroll interne). Élite = variante boostée d'un ennemi normal sur spawn normal (pas de salle dédiée) ; porteur de recette = salle spécifiquement taggée. Pas d'environnement destructible/interactif (pas de plateformes cassables, pièges, leviers). Une salle nettoyée ne respawn pas ses ennemis tant que le biome n'est pas régénéré. HUB reste minimal (4 sorties, Grimoire, établi) — pas d'extension en v3.

**Craft et économie** — Table définitive des matériaux, recettes (27), barème PC et tiers d'établis : voir `questions.md` Q041-Q049 pour le détail exhaustif (ids, coûts, matériaux, tiers, sources de découverte). Points clés : les **coins sont supprimés** de `RunState` (les PC remplacent totalement l'or) ; 3 tiers d'établi (1 = starter/B1, 2 = B2/B3, 3 = B4/Voile) ; découverte de recette uniquement via porteurs + Gardiens du Voile + starters (pas de coffres/salles secrètes) ; un drop de recette déjà connue ne donne rien ; rareté réalignée sur les biomes réels (cristaux → B3, imagerie volcanique → B4, corrigeant la contradiction du design doc v3).

**Ennemis et boss** — 4 nouveaux archétypes ennemis à coder en plus de `ground`/`flyer` : `rooted` (stationnaire, zone périodique), `jumper` (bondit), `turret` (stationnaire, tir), `teleporter` (téléportation courte). Le boss actuel (charge/volley/slam) devient **Le Gardien des Racines (B1)**, simplement re-thématisé. Fiches d'attaques pour les 3 autres boss de biome (Foreur Maudit, Orage Éternel, Gardien du Noyau) et première version de `mirror.json` (biome → modules, cicatrice → mutations) : voir `questions.md` Q050-Q052. Les ennemis dropent des matériaux thématiques en plus des recettes des porteurs.

**Interface, narration, audio, art** — Écran d'équipement manuel (pause), barres de vie au-dessus des ennemis (pas de chiffres de dégâts flottants, pas de minimap), Grimoire accessible au HUB uniquement. Narration par textes courts aux moments clés (pas de dialogues), personnage anonyme (pas nommé Nino), textes scénarisés en fondu simple. **Audio définitif reporté à la toute fin du développement** (Phase 10) — garder les placeholders sonores actifs via `AudioManager` pendant tout le développement, ne reporter que le remplacement par des assets soignés. Liste fermée de bruitages indispensables, aucune voix. Grille de tiles 16×16, 2-3 couches de parallax, 5 paliers de shaders de cicatrices, priorité de remplacement des placeholders : joueur > ennemis > boss > tilesets > UI.

**Processus** — Les retours de playtest de Nino aux jalons J1-J7 peuvent amender l'équilibrage (valeurs JSON) mais jamais l'architecture ou les formats de données tranchés ci-dessus. Le jeu est considéré terminé à J7 + Phase 10 close, sans critère de qualité formel supplémentaire.

---

## Carte du code (référence d'implémentation)

À lire avant toute phase. Racine projet Godot : `game/` (`res://` = `game/`).

### Autoloads (`game/project.godot`)
| Nom | Script | Rôle |
| --- | --- | --- |
| `JoyMap` | `scripts/joymap.gd` | Mapping manette PowerA + `setup_input()` centralisé. Toute nouvelle action input passe par lui (pas de bindings clavier sur les nouvelles actions). |
| `AudioManager` | `scripts/audio.gd` | Sons placeholder générés en code. `AudioManager.play("id")`. |
| `Dev` | `scripts/dev.gd` | Flags dev : `spawn`, `dev_resources`, `infinite_hp`. |
| `RunState` | `scripts/run_state.gd` | État de run éphémère : `materials: Dictionary`, `items`, `consumables` + signaux typés. `reset()` est encore appelé par `level.gd._ready()` (à déplacer en Phase 3). |
| `MetaState` | `scripts/meta_state.gd` | Persistant : `skill_points`, `grimoire` (id → {discovered, mastered}). API : `discover_recipe`, `master_recipe`, `is_mastered`, `spend_skill_points`. |
| `SaveManager` | `scripts/save_manager.gd` | `user://meta_state.json`, `save_meta()`/`load_meta()` (load au `_ready`). |

### Scènes et scripts clés
- `scenes/ui/title.tscn` (main scene) + `title.gd` : menu + mode dev. `_start_game()` fait `change_scene_to_file("res://scenes/levels/biome1.tscn")` (title.gd:188).
- `scenes/levels/biome1.tscn` + `level.gd` (321 l.) : construit tout le niveau depuis `res://data/level.json` (const `LEVEL_CONFIG`, level.gd:12) — fond, plateformes (rects), ennemis, ores, workbench, boss, HUD, pause. Trigger boss : `player.x > dims["arena_x"]` (level.gd:74-76). Fin de partie : `_on_player_died` / `_on_boss_died` → `SaveManager.save_meta()` + `_show_end_screen` (level.gd:301-321). `_return_to_title()` = `get_tree().quit()` (level.gd:273-275).
- `player.gd` (361 l.) : configs chargées depuis `player.json`, `weapons.json`, `armor.json`, `consumables.json`. Signal `died`. `_apply_equipment()` (player.gd:307) recalcule stats depuis `RunState.items` — liste d'épées hardcodée `["epee_fer", "epee_cuivre", "epee_bois"]` (player.gd:315). `damage_reduction` = modèle d'insertion des modificateurs (pour les cicatrices).
- `boss.gd` (258 l.) : machine à états `enum State {SLEEP, IDLE, CHARGE, VOLLEY, SLAM_RISE, SLAM_FALL, PAUSE}`, config JSON par clé `"Boss"` dans `boss.json` (`_load_config()`), signaux `health_changed`/`died`, `activate()`. Modèle pour Gardiens (Phase 5) et base de la modularisation R3.
- `enemy_base.gd` + `enemy_ground.gd`/`enemy_flyer.gd` : config `enemies.json`, signal `died(enemy)`.
- `ore_node.gd` : gisement data-driven par `material_id`, lit taille/HP/drop/texture dans `materials.json`, compare le tier du matériau au tier de pioche courant issu de `RunState.get_pickaxe_tier()` et de `weapons.json`.
- `craft_menu.gd` : lit `recipes.json`, convertit encore les anciennes recettes `{cost}` en coût mono-matériau (`cuivre`) via `spend_materials` — transition minimale Phase 1 avant la refonte complète Phase 2.
- `hud.gd` : s'abonne à `RunState.materials_changed` et affiche une liste compacte des matériaux non nuls.

### Données (`game/data/`)
`player.json`, `weapons.json`, `armor.json`, `consumables.json`, `materials.json`, `enemies.json`, `boss.json`, `level.json` (niveau fixe actuel, gisements typés), `recipes.json` (format actuel minimal : `[{"id", "name", "cost", "consumable"?}]`), `animations.json` (généré par sync depuis game_art — ne pas éditer ici).

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

## ⚠ Dette bloquante Phase 0 (corrigée et validée le 2026-07-06)

La migration `Inventory` → `RunState` était incomplète : l'autoload `Inventory` avait été retiré de `project.godot` mais trois appels subsistaient et crashaient à l'exécution. **Corrigé** :
- `ore_node.gd:42` — `Inventory.add(ORE_DROP)` → `RunState.add(ORE_DROP)`.
- `enemy_base.gd:107` — `Inventory.add_coins(coin_reward)` → `RunState.add_coins(...)`.
- `boss.gd:255` — `Inventory.add_coins(coin_reward)` → `RunState.add_coins(...)`.
- Bonus (bloquait aussi le démarrage) : `ore_node.gd`/`workbench.gd` chargeaient leur texture via `const := preload(...)`, qui échoue sans `.import` généré. Remplacé par chargement runtime `Image.load_from_file` (même convention que `animation_driver.gd`).

`grep -rn "Inventory" game/scripts` = zéro résultat. Vérifié : `game/scripts/inventory.gd` est supprimé ; 20 tests GUT passent ; un run manuel complet (miner, crafter, tuer des ennemis, battre le boss, relancer) est validé.

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
- [x] **Corriger la dette bloquante ci-dessus** (3 appels `Inventory` résiduels + suppression `inventory.gd`).
- [x] **Validation en jeu** : GUT vert + run manuel complet + persistance `MetaState` après relance.

### Fait quand
Un run modifie `RunState` sans toucher `MetaState`. Fermer/relancer le jeu conserve `MetaState`. Le jeu actuel reste jouable de bout en bout après migration (miner, crafter, boss). Tests verts.

### Dépend de
Rien.

---

## Phase 1 — Matériaux typés

Le craft v3 consomme des matériaux distincts (bois, pierre, cuivre, fer, cristaux, fragments du Noyau...). Aujourd'hui `RunState.resources` est un seul entier.

### Tâches
- [x] `game/data/materials.json` — table définitive des 13 matériaux en place, avec champs `tier` et sections `ore`.
  ```json
  {
    "bois":            {"name": "Bois",             "biome": "biome1", "rarity": "common",   "tier": 1},
    "pierre":          {"name": "Pierre",            "biome": "biome1", "rarity": "common",   "tier": 1},
    "cuivre":          {"name": "Cuivre",            "biome": "biome1", "rarity": "common",   "tier": 1},
    "cuir":            {"name": "Cuir",              "biome": "biome1", "rarity": "common",   "tier": 1, "source": "drop_ennemi"},
    "fer":             {"name": "Fer",               "biome": "biome2", "rarity": "uncommon", "tier": 2},
    "charbon":         {"name": "Charbon",           "biome": "biome2", "rarity": "uncommon", "tier": 2},
    "minerai_sombre":  {"name": "Minerai sombre",    "biome": "biome2", "rarity": "rare",      "tier": 2},
    "cristal":         {"name": "Cristal",           "biome": "biome3", "rarity": "rare",      "tier": 2},
    "minerai_celeste": {"name": "Minerai céleste",   "biome": "biome3", "rarity": "rare",      "tier": 2},
    "essence_vent":    {"name": "Essence de vent",   "biome": "biome3", "rarity": "rare",      "tier": 2, "source": "drop_ennemi"},
    "fragment_noyau":  {"name": "Fragment du Noyau", "biome": "biome4", "rarity": "epic",      "tier": 3, "source": "drop_boss"},
    "minerai_abyssal": {"name": "Minerai abyssal",   "biome": "biome4", "rarity": "epic",      "tier": 3},
    "essence_voile":   {"name": "Essence du Voile",  "biome": "voile",  "rarity": "legendary", "tier": 3, "source": "drop_gardien"}
  }
  ```
  Le minage est **gaté par tier** (Q022) : une pioche de tier insuffisant ne peut pas miner un gisement de tier supérieur. Le champ `tier` de la pioche équipée (`weapons.json` ou config dédiée) est comparé au `tier` du matériau avant d'autoriser le minage dans `ore_node.gd`.
- [x] `RunState` : `resources: int` remplacé par `materials: Dictionary` (id → int). Nouvelle API :
  - `add_material(id: String, qty: int) -> void`
  - `get_material(id: String) -> int`
  - `spend_materials(costs: Dictionary) -> bool` — atomique : vérifie TOUT avant de débiter quoi que ce soit.
  - Signal `materials_changed(id: String, count: int)` remplace `resources_changed(current: int)`.
  - Adapter `serialize()`/`deserialize()` et `reset()`.
- [x] Migrer les consommateurs de l'ancien champ (les repérer par `grep -n "resources" game/scripts/*.gd`) :
  - `hud.gd:61-82` : abonnement `resources_changed` → `materials_changed`, affichage par type (liste compacte `icône/id: qté`).
  - `craft_menu.gd:113` (`RunState.resources >= cost`) et `:154` (`RunState.spend`) : basculer sur `spend_materials` — transition minimale en Phase 1 (recette à coût mono-matériau), refonte complète en Phase 2.
  - `level.gd:34-35` et `:277-284` (`_toggle_dev_resources`) : voir risque « 100 MIN » ci-dessous.
- [x] `ore_node.gd` : constantes hardcodées supprimées. Le gisement reçoit un `material_id` et lit taille/HP/drop/texture depuis `materials.json`. Drop → `RunState.add_material(material_id, drop)`.
- [x] `level.json` : les entrées `ores` passent de `[x, y]` à `{"pos": [x, y], "material": "cuivre"}`. `level.gd._spawn_ores()` adapté.
- [x] Tests (`test_run_state.gd` étendu) : add/get/spend atomique, serialize/deserialize, reset, fallback legacy `resources`.
- [ ] Recenser dans `game_art/backlog_art.md` : sprites distincts par type de gisement/minerai. **[game_art]**
- [x] **Suppression des coins (Q045)** : les PC remplacent totalement l'or. `coins`/`add_coins`/`coins_changed` retirés de `RunState`, `hud.gd`, `enemy_base.gd`, `boss.gd`.

**Statut session 2026-07-06** : le socle technique de la Phase 1 est livré et testé (`23/23` GUT verts, démarrage headless OK), avec tier de pioche désormais fourni par les données gameplay. La phase reste **ouverte** tant qu'un run manuel complet n'a pas validé minage/craft/HUD/menu dev en conditions réelles.

### Fait quand
Miner un gisement ajoute le bon matériau, gaté par tier de pioche. Le HUD reflète les quantités par type. Aucune référence aux coins ne subsiste. Tests verts.

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
    "slot": "weapon",
    "consumable": false,
    "workbench_tier": 1,
    "starter": false
  }
  ```
  `discovered`/`mastered` ne vivent PAS dans ce fichier (état méta → `MetaState.grimoire`). `starter: true` = maîtrisée d'office. Champ `slot` ∈ `{weapon, armor, accessory, tool, consumable, utility}` — voir 4 slots d'équipement ci-dessous.
- [ ] **Grimoire complet — 27 recettes définitives (questions.md Q043)**, table exhaustive id/nom/rareté/tier/coût PC/matériaux/découverte à reprendre telle quelle depuis `questions.md` section 6. Ne pas réinventer de recettes supplémentaires sans repasser par une décision explicite.
- [ ] Recettes de départ (`starter: true`, tier 1, coût PC 0) : `epee_bois`, `armure_bois`, `pioche_renforcee`, `potion_petite`, `torche`, `corde` (= grappin, cf. Phase joueur ci-dessous), `etabli_portable`. Au premier lancement (grimoire vide), `MetaState` enregistre les starters comme découvertes+maîtrisées (méthode `ensure_starters(ids: Array)` appelée après `load_meta`).
- [ ] **4 slots d'équipement (Q017)** : `weapon` (mêlée OU distance, un seul slot actif), `armor`, `accessory`, `tool`. `RunState`/`MetaState` équipement et `_apply_equipment()` étendus pour gérer 4 emplacements au lieu de 2. Pas d'auto-équipement « meilleure arme possédée » — le choix est manuel (écran dédié, Phase 3/10, cf. Q055).
- [ ] **Armes à distance (Q016)** : nouveau type dans `weapons.json` (portée, vitesse de projectile), scène de projectile, nouveau bouton manette dans `joymap.gd`. Usage illimité, pas de munitions — fonctionne comme le mêlée (cooldown/dégâts/portée différencient les armes).
- [ ] **Barème PC (Q044)**, `game/data/progression.json` : biome visité 1 PC, salle secrète 1 PC, élite vaincu 1 PC, boss de biome vaincu 2 PC, résurrection réussie 1 PC, victoire finale (Miroir) +3 PC bonus, run raté ×0.5 sur le total. Pas de PC par salle normale explorée.
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

**Rappel critique (questions.md Q001)** : un run est **multi-biomes**. Le HUB est une étape *à l'intérieur* du run, pas une gare entre deux runs séparés. `RunState.reset()` ne doit **plus** avoir lieu à chaque `level.gd._ready()` (comportement actuel, level.gd:33) — il doit avoir lieu une seule fois, au lancement d'un **nouveau run** depuis le titre (`title.gd._start_game()`). Un aller-retour HUB↔biome en cours de run conserve matériaux, équipement et cicatrices.

### Tâches
- [ ] Créer `scenes/levels/hub.tscn` + `scripts/hub.gd` : point central, 4 directions (placeholder « en construction » pour les non-implémentées), déplacement du player (réutiliser la scène player sans ennemis), zones d'interaction sur le modèle de `workbench.gd` (`interact_requested`). Config `game/data/hub.json` (positions, directions actives). Le HUB reste minimal (4 sorties, Grimoire, établi) — pas de contenu additionnel en v3 (Q039). Recenser décor du HUB dans `game_art/backlog_art.md`. **[game_art]**
- [ ] `title.gd._start_game()` (title.gd:181-188) : `change_scene_to_file` vers `hub.tscn` au lieu de `biome1.tscn`. **`RunState.reset()` déplacé ici** (nouveau run = un seul reset), retiré de `level.gd._ready()`. Conserver les flags Dev (spawn/ressources/HP) — le mode dev peut garder un raccourci « biome direct ».
- [ ] Paramétrer le chargement de niveau : remplacer la const `LEVEL_CONFIG` (level.gd:12) par un `biome_id` fourni au chargement — pattern : autoload léger `GameFlow` (ou champ dans `Dev`) portant `next_biome_id`, lu par `level.gd._ready()` qui charge `res://data/biomes/<id>.json`. Déplacer `level.json` → `data/biomes/biome1.json`.
- [ ] Retour au HUB : remplacer `_show_end_screen`/`get_tree().quit()` (level.gd:273-275, 301-321) par un écran de fin bref puis `change_scene_to_file(hub.tscn)`. Le biome quitté est détruit (`queue_free`), pas conservé — une nouvelle entrée régénère un agencement différent (Q002). Un seul biome vivant en mémoire à la fois (Q073), sauf exception Arène du Voile en Phase 5.
- [ ] **Sortie volontaire (Q006)** : objet/portail de retour au HUB accessible en cours d'exploration (sans mourir ni battre le boss), conservant la récolte du joueur.
- [ ] **Soin au HUB (Q024)** : entrer dans le HUB restaure intégralement les PV du joueur.
- [ ] Boss de biome vaincu : le biome reste explorable/re-générable dans le run, mais ce boss précis ne redéclenche pas avant un nouveau run (Q007) — un flag par biome dans `RunState` (`bosses_vaincus: Array`).
- [ ] Accès depuis le HUB : Grimoire/écran de déblocage PC (livré Phase 2, accessible **HUB uniquement**, Q056) et établi (tier 1, cf. Phase 2).
- [ ] Tests (`test_game_flow.gd`) : sélection de biome → bon fichier chargé, `RunState.reset()` appelé une seule fois par run (pas à chaque entrée en biome), compteurs de fin de run alimentent bien les PC au retour HUB.

### Fait quand
Depuis le HUB, choisir une direction lance le biome correspondant (régénéré). Un aller-retour HUB↔biome conserve matériaux/équipement/cicatrices. Mourir définitivement ou battre le Miroir ramène à un nouveau run. Le mode dev reste fonctionnel. **J1 : Nino peut jouer un run complet HUB → biome → retour HUB → autre biome, sans perte de progression de run.**

### Dépend de
Phases 0, 2.

### Risques
`level.gd` suppose des dimensions fixes et un boss déclenché par `arena_x` (level.gd:74-76). Le paramétrage par biome doit abstraire ça proprement (préparer la Phase 4 : le trigger boss devient une donnée du JSON de biome, pas une position hardcodée dans le code). Vigilance particulière sur le déplacement du `RunState.reset()` : un test de non-régression doit vérifier qu'aucun autre point du code n'appelle `reset()` implicitement à l'entrée d'un biome.

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
    "connections": {"left": [0, 230], "right": [480, 230], "top": null, "bottom": null},
    "tags": ["standard"]
  }
  ```
  Coordonnées locales à la salle ; le générateur translate lors de l'assemblage. **Format étendu aux 4 directions (Q032)** : `connections` porte `left/right/top/bottom` dès cette phase, même si seul le biome 1 (horizontal) est peuplé maintenant — nécessaire pour éviter de casser le format quand B3 (vers le haut) et B4 (vers le bas) seront développés en Phase 7. Une connexion `null` = pas de sortie dans cette direction pour cette salle.
- [ ] **Salles secrètes (Q033)** : tag `"secret"` sur certaines salles, connectées par un embranchement optionnel (voir structure ci-dessous), signalées visuellement par un détail discret (fissure, luminosité différente) — pas un mur à traverser en aveugle.
- [ ] **Structure en embranchements légers (Q036)** : chemin principal linéaire + quelques embranchements courts menant à des culs-de-sac (trésor, salle secrète, gisement bonus). Une salle du chemin principal peut exposer une connexion supplémentaire vers une salle annexe non traversante.
- [ ] `game/scripts/biome_generator.gd` : `static func generate(biome_cfg: Dictionary, rooms: Array, rng_seed: int) -> Dictionary` — enchaîne N salles (longueur depuis la config biome), aligne les connexions (4 directions), translate plateformes/spawns en coordonnées monde, retourne le Dictionary format `level.json`. Déterministe à seed égal (utiliser `RandomNumberGenerator` seedé, jamais `randi()` global).
- [ ] Config biome (`data/biomes/biome1.json` étendu) : `{"rooms_pool": [...], "length": [5, 7], "guaranteed_materials": {"cuivre": 4, "bois": 3}, "boss": {...}}`. Tailles cibles par biome (Q034, à répercuter en Phase 7) : B1 5-7 salles, B2 6-8, B3 7-9, B4 8-10.
- [ ] **8-10 templates de salles pour le biome 1** (Q035 — volume cible par biome, à reproduire en Phase 7 pour B2/B3/B4).
- [ ] Garantie de ressources : après assemblage, si un matériau clé est sous le minimum, injecter des gisements sur les spawn points d'ore inutilisés (ou rejeter/regénérer — au choix, mais borné et testé).
- [ ] Placement boss en fin de parcours (dernière salle taggée `boss` ou arène ajoutée en bout) ; le trigger `arena_x` devient une sortie du générateur.
- [ ] Élites (Q037) : variante boostée (HP/dégâts majorés + teinte distinctive) d'un ennemi normal, tirée aléatoirement sur un spawn point normal — pas de salle dédiée. Porteurs de recettes (Phase 8) : salles spécifiquement taggées.
- [ ] `level.gd` : consommer le Dictionary généré (seed tirée au lancement du run, conservée dans `RunState` — nécessaire à la Phase 5). Écran fixe par salle (480×270, pas de scroll interne, Q038) — confirmé, pas de caméra dynamique à gérer.
- [ ] **Régénération à chaque entrée (Q002)** : quitter puis revenir dans ce biome (via le HUB) déclenche une nouvelle génération complète, pas une reprise de l'état précédent.
- [ ] Pas de plateformes cassables, pièges ni leviers en v3 (Q040) — décor statique hors gisements/ennemis/porteurs.
- [ ] `tests/test_biome_generator.gd` : sur 100 générations seedées — chemin start→boss connexe (parcours des connexions dans les 4 directions), minima de matériaux respectés, aucune salle disjointe, déterminisme (même seed → même sortie).
- [ ] Recenser tileset/décors biome 1 dans `game_art/backlog_art.md` — grille de tiles **16×16** (Q068), 2-3 couches de parallax (Q069). **[game_art]**

### Fait quand
Lancer le biome 1 deux fois produit deux agencements différents, tous deux complétables, avec les ressources clés présentes. Tests de complétabilité et de garantie ressources verts sur N générations. **J2.**

### Dépend de
Phase 3.

### Risques
Garantie de complétabilité (le joueur ne doit jamais être bloqué). Couverte par tests automatisés sur la connectivité. Aucun respawn d'ennemi dans une salle nettoyée tant que le biome n'est pas régénéré (Q053) — supprimer le respawn existant (`level.gd:178-199`) ou le conditionner explicitement à une régénération complète du biome.

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
- [ ] Interception de la mort : `level.gd._on_player_died` (level.gd:301) — transition systématique vers l'Arène (**pas de plafond de résurrections, Q005** : l'escalade de difficulté des Gardiens borne naturellement les tentatives, ne jamais bloquer une résurrection par un compteur artificiel). Compteur `RunState.resurrection_count` conservé pour l'escalade et le tirage de cicatrice.
- [ ] `player.gd._die()` (player.gd:288) : prévoir la réanimation (`revive(hp)` qui remet `_dead = false`, restaure PV, réémet `health_changed`) — actuellement `_dead` est définitif.
- [ ] Scène Arène du Voile (unique) `scenes/levels/veil_arena.tscn`, décor placeholder. Le joueur entre avec **PV pleins** et son **consommable équipé utilisable** (Q030) — pas de PV à zéro à l'entrée. Recenser décor « tribunal cosmique » dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Gardiens du Voile : **un seul Gardien en Phase 5 — Le Veilleur des Cendres** (Q029), construit sur le modèle `boss.gd` (machine à états + `_load_config` défensif, réutilise directement les états charge/volley/slam existants), config dans `game/data/guardians.json`. Fiche de gameplay : charge au sol, projectile de cendres, zone d'explosion retardée, phase de pause vulnérable entre les attaques. Un seul tirage possible tant que R2/Phase 7 n'ajoutent pas les 7 autres du pool (Roi Sans Visage, Collecteur d'Âmes, Veuve du Vide, Dévoreur de Souvenirs, Porte-Flamme, Gardien des Os, Écho du Noyau).
- [ ] Difficulté croissante : multiplicateurs (HP, dégâts) par `resurrection_count`, table provisoire (Q031) dans `guardians.json` : `"escalation": [{"mult": 1.0}, {"mult": 1.3}, {"mult": 1.6, "new_pattern": true}, {"mult": 2.0}, {"mult": 2.5}]` (palier 5+ reste à 2.5, pas d'escalade infinie au-delà). Fonction pure `apply_escalation(base_cfg, count) -> Dictionary`, testée.
- [ ] Victoire → retour au biome **dans l'état exact quitté** (option (a) ci-dessus), résurrection à l'endroit de la mort, PV restaurés, cicatrice appliquée (stub tant que Phase 6 non faite). Défaite → fin de run définitive (PC de fin de run quand même), retour HUB.
- [ ] Recenser sprites/patterns visuels du Veilleur des Cendres dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Tests (`test_veil.gd`) : escalade des Gardiens (fonction pure, y compris le plafond à ×2.5 au-delà du palier 5), état biome conservé autour de l'aller-retour (au minimum : seed inchangée, ores minés absents, ennemis morts non ressuscités — test d'intégration léger sur les structures de données si la scène n'est pas testable directement), PV pleins + consommable utilisable à l'entrée de l'Arène.

### Fait quand
Mourir envoie à l'Arène, sans jamais bloquer la tentative par un compteur. Vaincre le Gardien ressuscite le joueur dans le biome, **dans l'état exact où il l'avait quitté**. Perdre termine le run. Tests d'état biome verts.

### Dépend de
Phase 4, R1.5.

### Risques (À SURVEILLER — point critique)
- **Le biome ne doit surtout pas être régénéré au retour de l'Arène.** Avec l'option (a), le risque se déplace vers les timers/références pendantes de la scène détachée — vérifier respawn, tweens, `get_tree()` null. Couvrir par test + validation manuelle systématique.
- Le Gardien unique est construit sur le modèle `boss.gd` non consolidé (R2 pas encore passé). Coût assumé : R2 ajoutera les 7 autres Gardiens du pool sur cette même base, factorisée. Ne PAS copier-coller `boss.gd` : un seul `guardian.gd` paramétré par sa config JSON, réutilisable pour les futurs Gardiens.
- Sans plafond de résurrections, le cumul de cicatrices (Phase 6) peut devenir dégénéré sur de nombreuses morts — voir planchers durs obligatoires en Phase 6 (Q026b).

---

## Phase 6 — Cicatrices → **Jalon J3**

### Tâches
- [ ] `game/data/scars.json` — **liste définitive des 5 cicatrices (Q026)**, remplace les exemples précédents `membre_raidi`/`vision_voilee` :
  ```json
  {
    "sang":  {"name": "Cicatrice du Sang",  "modifiers": {"max_hp_mult": 0.9}},
    "os":    {"name": "Cicatrice de l'Os",  "modifiers": {"speed_mult": 0.85}},
    "ame":   {"name": "Cicatrice de l'Ame", "modifiers": {"heal_mult": 0.7}},
    "peur":  {"name": "Cicatrice de la Peur", "modifiers": {"detection_mult": 1.5}},
    "noyau": {"name": "Cicatrice du Noyau", "modifiers": {"attack_damage_mult": 1.2, "max_hp_mult": 0.8}},
    "_floors": {"speed_mult": 0.5, "max_hp": 2, "heal_mult": 0.3, "attack_damage_mult": 0.1}
  }
  ```
  Clés de modificateurs : `max_hp_mult`, `speed_mult`, `heal_mult` (**nouvelle**), `detection_mult` (**nouvelle**), `attack_damage_mult`. **`_floors` est obligatoire (Q026b)** : planchers durs par stat, appliqués en clamp après cumul de tous les modificateurs actifs. Sans ce plancher, un cumul de cicatrices identiques sur de nombreuses résurrections (pas de plafond, Q005) ferait tendre une stat vers zéro et rendrait le personnage injouable.
- [ ] **`detection_mult` (Q027)** : ajouter un champ `detection_radius` dans `enemies.json` et `enemy_base.gd` (rayon de détection paramétrable, actuellement absent) — multiplié par `detection_mult` quand la Cicatrice de la Peur est active.
- [ ] Application dans `player.gd` : étendre `_apply_equipment()` (player.gd:307, déjà le point unique de recalcul des stats) — après équipement, appliquer les modificateurs cumulés des cicatrices actives, **puis clamp aux planchers `_floors`**. Renommer en `_recompute_stats()` à cette occasion.
- [ ] `RunState.scars: Array[String]` + `add_scar(id)` + signal `scars_changed` + serialize/reset.
- [ ] Tirage de la cicatrice à chaque résurrection (dans le flux de retour d'Arène, Phase 5) : **aléatoire imposé** (pas de choix, Q028), affiché via un écran dédié à la résurrection ; uniforme parmi les non-possédées ; si les 5 possédées, doublon autorisé (cumul, plafonné par les planchers).
- [ ] Recettes du Voile : `biome: "voile"` dans `recipes.json` (Lame Spectrale, Anneau des Revenants, Élixir de Résurgence — voir table complète questions.md Q043) — découverte droppée à la victoire en Arène (`MetaState.discover_recipe`). Effets (Q049) : Anneau des Revenants atténue l'impact des malus de cicatrices actives (ex. -50 % sur les modificateurs négatifs, appliqué avant clamp aux planchers) ; Lame Spectrale = dégâts accrus contre créatures du Voile (Gardiens, Miroir) ; Élixir de Résurgence = soin complet + bref buff de dégâts après résurrection.
- [ ] Affichage HUD : rangée d'icônes placeholder des cicatrices actives.
- [ ] Recenser les **5 paliers d'effets visuels réalisables (Q070)** via shaders + overlays de particules dans `game_art/backlog_art.md` — PAS de refonte de spritesheet : palier 1 overlay lumineux + particules discrètes, palier 2 shader veines lumineuses + halo, palier 3 shader transparence partielle, palier 4 overlay fragments flottants + teinte cristalline, palier 5+ combinaison à intensité maximale + particules denses. **[game_art]**
- [ ] Tests (`test_scars.gd`) : application des modificateurs (stats recalculées correctes), cumul (deux cicatrices = effets combinés), **planchers respectés sur un stack extrême (ex. 50 cicatrices du même type, Q026b)**, drop des recettes du Voile, effet Anneau des Revenants, serialize.

### Fait quand
Chaque résurrection applique une cicatrice (parmi les 5 définitives) qui modifie réellement le gameplay, persistante jusqu'à la fin du run, jamais en dessous des planchers définis. Vaincre un Gardien peut faire découvrir une recette du Voile. **J3 : la boucle identitaire complète est jouable.**

### Dépend de
Phase 5.

### Risques
Cumul de cicatrices sans plafond de résurrections (Q005) : les **planchers durs (`_floors`) sont une exigence de conception, pas une option** — sans eux, un joueur mourant plusieurs dizaines de fois rendrait son personnage totalement inerte (PV/vitesse/soin tendant vers zéro) bien avant que la difficulté des Gardiens (plafonnée à ×2.5, Phase 5) ne devienne le facteur limitant. Équilibrage fin des valeurs provisoire jusqu'à la Phase 10.

---

## Phase 7 — Contenu des biomes 2, 3, 4 → **Jalons J4, J5, J6**

Étalée strictement biome par biome : 7a = Mines Obscures (J4), 7b = Îles Célestes (J5), 7c = Descente vers le Noyau (J6). Un biome est terminé avant d'attaquer le suivant.

### Tâches (répétées par biome)
- [ ] `data/biomes/<id>.json` + salles `data/rooms/<id>/` (réutilise le générateur Phase 4 tel quel, connexions 4 directions déjà supportées — B3 vers le haut, B4 vers le bas). Tailles cibles (Q034) : B2 6-8 salles, B3 7-9, B4 8-10 ; 8-10 templates par biome (Q035).
- [ ] **4 nouveaux archétypes ennemis (Q050)**, en plus de `ground`/`flyer` existants : `rooted` (stationnaire, attaque de zone périodique), `jumper` (bondit vers le joueur), `turret` (stationnaire, tir de projectile), `teleporter` (téléportation courte). Table complète ennemi → archétype par biome dans questions.md Q050 (ex. Araignée géante B2 = `jumper`, Machine abandonnée B2 = `turret`, Manifestation du Voile B4 = `teleporter`). Étendre `enemies.json` + sous-classes de `enemy_base.gd` uniquement si le comportement l'exige.
- [ ] Ressources spécifiques : entrées `materials.json` (déjà typées Phase 1), gisements dans les salles, gatées par tier de pioche (Q022).
- [ ] **Drop de matériaux par ennemi (Q054)** : table de loot simple dans `enemies.json` en plus des recettes des porteurs (ex. créatures B1 → cuir, élémentaires du vent B3 → essence de vent).
- [ ] Boss de biome — **fiches d'attaques définitives (Q051)** :
  - **Foreur Maudit (7a)** : arène « atelier de forage ». Attaques : charge frontale, tir de boulons, mine posée (explosion différée). Phase : rage à bas HP (vitesse accrue).
  - **Orage Éternel (7b)** : arène « plateforme aérienne ». Attaques : éclair ciblé (zone télégraphiée), déplacement rapide/téléportation courte, tempête de cristaux (projectiles multiples).
  - **Gardien du Noyau (7c)** : arène « sanctuaire du Noyau ». Attaques : charge lourde, onde de corruption (zone), invocation de revenants. Phase : phase 2 à mi-HP (nouvelle attaque de zone majeure).
  Nouvelles clés dans `boss.json` sur le modèle existant ; nouveaux états/attaques ajoutés à la machine de `boss.gd` si nécessaire (en notant la duplication pour R2/R3).
- [ ] Établis avancés : activation du `workbench_tier` (Phase 2, 3 tiers définitifs Q046 : 1=starter/B1, 2=B2/B3, 3=B4/Voile) — `workbench.gd` porte un tier, `craft_menu` filtre les recettes au tier de l'établi utilisé.
- [ ] Recenser par biome dans `game_art/backlog_art.md` : sprites ennemis, boss, décors, tileset (grille 16×16, Q068). **[game_art]**

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
- [ ] Étendre le pool de Gardiens sur la base unifiée : 7 Gardiens supplémentaires en plus du Veilleur des Cendres (Phase 5) — Roi Sans Visage, Collecteur d'Âmes, Veuve du Vide, Dévoreur de Souvenirs, Porte-Flamme, Gardien des Os, Écho du Noyau (cible : 8 au total — sinon reliquat au backlog post-v3).
- [ ] Audit anti-hardcode : toute donnée gameplay externalisée.
- [ ] Auditer la couverture de tests biomes/ennemis/boss/Gardiens, compléter jusqu'à 85 %.

### Fait quand
Aucune duplication structurelle majeure entre biomes/boss/Gardiens. Tests de non-régression verts sur les 4 biomes et l'Arène. Couverture ≥ 85 % sur le périmètre consolidé.

---

## Phase 8 — Porteurs de recettes

### Tâches
- [ ] Ennemis rares (Archiviste, Golem Artisan, Mineur Spectral, Forgeron Maudit) — apparition conditionnelle sur des **salles spécifiquement taggées** (Q037), probabilité dans la config biome, tirage à la génération.
- [ ] Drop = découverte de recette : `MetaState.discover_recipe(id)` à la mort du porteur. Sources par recette légendaire définies dans la table Q043 (ex. Armure du Noyau et Lame du Noyau → Forgeron Maudit ; Couronne Spectrale → Archiviste Perdu).
- [ ] **Doublon (Q048)** : si le porteur droppe une recette déjà découverte/maîtrisée, rien ne se passe (pas de compensation) — la récompense principale reste d'avoir vaincu le porteur.
- [ ] Découverte de recette limitée aux porteurs + Gardiens du Voile + starters (Q047) — pas de coffres, pas de bonus de première extraction de matériau.
- [ ] Feedback visuel/sonore de découverte (toast HUD « Recette découverte »).
- [ ] Recenser sprites des 4 porteurs dans `game_art/backlog_art.md`. **[game_art]**

### Fait quand
Vaincre un porteur ajoute une recette « Découverte » au Grimoire (sauf doublon, sans effet).

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

**Accès (Q009)** : vaincre le Gardien du Noyau (B4) seul suffit à ouvrir l'accès au Miroir, sans prérequis d'avoir visité les biomes 1-3 ni d'un nombre minimal de cicatrices — cohérent avec la liberté totale du run. **Victoire du run (Q003/Q004)** : le bonus PC « réussite d'un run » n'est accordé qu'à la victoire contre le **Miroir**, pas seulement contre le Gardien du Noyau. Après la victoire, écran de récapitulatif puis retour au HUB (pas de New Game+, pas de fin définitive) — le joueur peut enchaîner un nouveau run.

### Tâches
- [ ] Fonction pure `build_mirror_description(biomes_visited: Array, scars: Array, cfg: Dictionary) -> Dictionary` : produit une description de boss (format R3) à partir des 2 paramètres (tracés dans `RunState`) et d'une table de correspondance `game/data/mirror.json` (biome → modules, cicatrice → mutations). Déterministe.
- [ ] **Première version de `mirror.json` (Q052)** :
  ```json
  {
    "biome_modules": {
      "biome1": ["racines", "immobilisation", "invocation_vegetale"],
      "biome2": ["armure_renforcee", "charge", "explosion"],
      "biome3": ["deplacement_aerien", "eclairs", "cristaux"],
      "biome4": ["energie_noyau", "corruption", "zone_majeure"]
    },
    "scar_mutations": {
      "sang":  ["attaque_saignement", "vitesse_attaque_accrue"],
      "os":    ["resistance_accrue"],
      "ame":   ["attaques_drainantes"],
      "peur":  ["poursuite_renforcee"],
      "noyau": ["degats_tres_eleves", "corruption"]
    }
  }
  ```
- [ ] Instanciation via l'assemblage R3, déclenchement après le Gardien du Noyau (Biome 4).
- [ ] Écran de victoire + retour HUB à la défaite du Miroir (pas de New Game+).
- [ ] Recenser modules visuels combinables dans `game_art/backlog_art.md`. **[game_art]**
- [ ] `tests/test_mirror.gd` : déterminisme (mêmes paramètres → même description), cas extrêmes (tous biomes + toutes cicatrices ; aucun biome, aucune cicatrice — un Miroir généré avec 1 seul biome exploré doit rester un combat valide), chaque entrée de `mirror.json` référence des modules existants.

### Fait quand
Atteindre le Noyau génère un boss reflétant le parcours du run, accessible dès le Gardien du Noyau battu quel que soit le nombre de biomes visités auparavant. Deux runs différents produisent deux boss différents. Le vaincre déclenche le bonus PC de réussite et ramène au HUB. Tests verts. **J7.**

### Dépend de
Phases 6, 7, R3.

### Risques
Combinatoire de modules = risque de bugs/équilibrage. Limiter le nombre de modules au départ, étendre ensuite. Tester les combinaisons extrêmes, notamment le cas minimal (1 biome, 0 cicatrice) qui doit rester un combat cohérent et pas juste un boss vide.

---

## Phase 10 — Intégration, équilibrage, polish

### Tâches
- [ ] Équilibrage global (PC, coûts de maîtrise, difficulté biomes, escalade Gardiens, cicatrices) — passe définitive, uniquement dans les JSON. Les retours de playtest de Nino aux jalons J1-J7 peuvent amender ces valeurs, jamais l'architecture (Q076).
- [ ] Boucle méta complète testée sur plusieurs runs.
- [ ] **Audio définitif (Q064/Q065/Q066/Q067)** : remplacement des placeholders sonores `AudioManager` par des assets définitifs (banque libre de droits ou équivalent), dernière étape avant mise en production. Liste fermée de bruitages (saut, attaque mêlée/distance, coup reçu, minage, craft, découverte/maîtrise de recette, mort, résurrection, victoire boss/Gardien, ouverture menu/Grimoire). Ambition musicale (nombre de pistes, dynamique ou boucle simple) tranchée à ce stade, avec une vision complète du jeu terminé. Aucune voix.
- [ ] **UI/UX finales** : écran d'équipement manuel par slot (Q055), barres de vie ennemis (Q057), menu options (volumes, plein écran/fenêtré, recalibration manette — persistés dans `user://settings.json`, Q058), écran de rappel des contrôles (Q059), confirmation d'effacement à « Nouvelle partie » (Q060).
- [ ] Remplacement des placeholders visuels restants, priorité : joueur > ennemis > boss > tilesets > UI (Q071), piloté par `game_art/backlog_art.md`, cohérence visuelle globale. **[game_art]**
- [ ] Vérification cible perf 60 FPS / plein écran par défaut (Q072).
- [ ] Audit final de couverture (≥ 85 %).

### Fait quand
Un joueur peut enchaîner plusieurs runs, progresser via le Grimoire/PC, mourir et ressusciter, et atteindre le Miroir du Noyau dans une expérience cohérente. **Terminé = J7 + cette phase close (Q077)**, sans critère de qualité formel supplémentaire.

### Dépend de
Toutes.

---

## Ordre de dépendances (résumé)

```
0 Fondations
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

1. **Fermeture prématurée de la Phase 1** — le socle `materials` et le gating de minage data-driven sont en place, mais la phase ne doit pas être close sans run manuel complet validant minage/craft/HUD/menu dev en conditions réelles.
2. **Persistance de l'état de biome à la résurrection (Phase 5)** — ne pas régénérer le biome au retour de l'Arène ; scène conservée en mémoire (option retenue), timers/références pendantes à surveiller, test dédié obligatoire.
3. **Gardien du Voile unique construit avant R2** — dette assumée (Le Veilleur des Cendres seul sur un `guardian.gd` paramétré, jamais de copier-coller de `boss.gd`) ; R2 ajoute les 7 autres du pool sur cette même base factorisée.
4. **Volume d'art** — neutralisé par la règle placeholders + `game_art/backlog_art.md`.
5. **Équilibrage de la boucle méta (Phase 10)** — nécessite des runs complets répétés ; équilibrage des cicatrices provisoire jusque-là.
6. **Dette inter-phases** — neutralisée par R1/R1.5/R2/R3 ; ne pas les sauter sous pression de contenu.
7. **Couverture de tests** — vérifiée à chaque jalon de refacto ; ne pas la laisser dériver.
8. **Pas de plafond de résurrections + cumul de cicatrices (Phase 6)** — sans les planchers durs (`_floors` dans `scars.json`, Q026b), un joueur mourant de nombreuses fois rendrait son personnage totalement inerte. Les planchers sont une exigence de conception, pas une option d'équilibrage.
9. **Déplacement de `RunState.reset()` (Phase 3)** — le passage d'un reset par entrée de biome à un reset unique par nouveau run (Q001) est un changement de comportement sur du code existant ; vérifier qu'aucun autre point n'appelle `reset()` implicitement.

## Backlog post-v3

Coupes assumées, à ne pas perdre :

- Miroir du Noyau — paramètre « boss vaincus » (héritage des pouvoirs des boss battus).
- Miroir du Noyau — paramètre « style de jeu » (tracking d'usage des armes → adaptation du boss).
- Pool complet de 8 Gardiens du Voile si non atteint en R2 (reliquat) — 1 seul en Phase 5, cible 8 en R2.
- Alignement du design doc sur le scope 2 paramètres du Miroir.
- Coop (écartée explicitement pour v3, Q010).
- HUB évolutif (décorations débloquables, PNJ, coffre persistant, Q039).
- Retrait de cicatrice en cours de run au-delà des effets de l'Anneau des Revenants (non tranché explicitement, cf. questions.md Q028).

Référence complète des décisions : voir `questions.md` à la racine du projet (77 questions + Q026b, toutes tranchées le 2026-07-06).
