# Plan — Passage du viewport en 1920×1080 natif

Objectif : viewport de rendu en 1920×1080 (au lieu de 480×270 upscalé ×4), joueur idle à **150 px de haut**, tous les sprites, menus et éléments HUD adaptés. Sans rien casser : chaque phase livre un jeu jouable et les tests GUT restent verts.

---

## 0. Constat initial et alternative (à lire avant de lancer)

**État actuel** : `game/project.godot` définit `viewport_width=480`, `viewport_height=270`, `window_width_override=1920`, `window_height_override=1080`, `stretch/mode="viewport"`. Le jeu s'affiche donc **déjà** dans une fenêtre 1920×1080 — chaque pixel de jeu est rendu en 4×4 pixels écran.

**Alternative moins coûteuse (rejetée mais documentée)** : conserver le viewport 480×270 et produire un sprite player de ~38 px de haut (38×4 = 152 px à l'écran). Une seule entrée backlog_art, zéro migration de coordonnées. À reconsidérer si la migration ci-dessous s'avère trop lourde en cours de route.

**Décision retenue** : viewport natif 1920×1080. Conséquences assumées :
- Facteur d'échelle monde : **×4** (480→1920, 270→1080). Toute coordonnée, taille, vitesse, gravité, portée exprimée en pixels est multipliée par 4.
- Le joueur passe de 24 px (96 px écran) à **150 px** (au lieu de 96×... = 96 px monde ×4). Le joueur devient donc **~1,56× plus grand relativement au monde** qu'aujourd'hui. C'est un changement de proportions gameplay (hauteur de saut en "corps", passages sous plateformes) — voir phase F (calibration).
- La grille de tiles 16×16 (Q068) devient de facto 64×64 px monde. À répercuter dans `game_art/backlog_art.md` (note transverse).

**Facteurs d'échelle** :
| Élément | Facteur | Résultat |
| --- | --- | --- |
| Monde, niveaux, UI, physique | ×4 | 480×270 → 1920×1080 |
| Player (visuel + collision) | ×6.25 | 14×24 → 87×150 |
| Autres entités (ennemis, boss, minerais, établi) | ×4 minimum | à réévaluer visuellement face au player agrandi |

**Risque pixel art** : ×6.25 n'est pas entier — un upscale nearest du sprite actuel donnera des pixels irréguliers. Deux options en phase E : (a) upscale ×6 = 144 px (propre, proche des 150 px demandés — **recommandé** en attendant), (b) nouveau sprite dessiné nativement à ~150 px via backlog_art. Trancher avant la phase E.

---

## 1. Préparation (aucun risque)

1. Créer une branche git dédiée : `git checkout -b resolution-1080p`. Rollback = revenir sur `main`.
2. Lancer GUT avant toute modification pour confirmer l'état vert de référence (23/23) :
   `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path game -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`
3. Capture d'écran de référence du jeu actuel (title, biome, craft, pause, boss) pour comparaison visuelle finale.

---

## 2. Phase A — project.godot

Fichier : `game/project.godot` (section `[display]`)
- `window/size/viewport_width` : 480 → **1920**
- `window/size/viewport_height` : 270 → **1080**
- Supprimer `window_width_override` / `window_height_override` (devenus inutiles, viewport = fenêtre).
- Conserver `stretch/mode="viewport"` et `aspect="keep"` (gère les écrans non-16:9).
- Conserver `default_texture_filter=0` (nearest — indispensable pour l'upscale des sprites).

**Vérif** : le jeu se lance, tout paraît minuscule dans le coin — attendu à ce stade, ne rien "corriger" ici.

---

## 3. Phase B — Données JSON (`game/data/`) — tout ×4

Règle absolue respectée : toutes les valeurs restent dans les JSON, aucun hardcode introduit.

| Fichier | Champs à ×4 |
| --- | --- |
| `level.json` | `dimensions` (width 3200→12800, height 270→1080, floor_top 240→960, arena_x 2600→10400), tous les rects de `platforms`, toutes les `pos` de `spawns`/`enemies`/`ores`, position `workbench` |
| `player.json` | `movement` (speed, sprint_speed, accel, friction, air_accel, max_fall), `jump` (velocity, gravity, fall_gravity), `combat` (attack_range, attack_knockback, screen_shake), `hurt` (knockback, bounce_y). **Ne PAS toucher** : durées (coyote_time, buffer, stun, invuln_time, cooldowns), HP, dégâts, deadzone |
| `enemies.json` | speed, patrol_range, detect_range (hover_amplitude si présent). Pas hover_speed (fréquence, pas des px) |
| `boss.json` | speed (×2 occurrences), hit_range, et toute autre valeur en px (vérifier le fichier entier : positions de projectiles, amplitudes) |
| `weapons.json` | `range` des 3 épées (16/18/20 → 64/72/80) |
| `materials.json` | `ore.size` [14,14] → [56,56] (toutes les entrées) |
| `consumables.json`, `armor.json` | vérifier : a priori aucune valeur en px, ne toucher que si portée/distance trouvée |

**Piège** : ne multiplier que les valeurs homogènes à des pixels ou px/s ou px/s². Les temps, HP, multiplicateurs, fps d'animation ne bougent pas. La gravité est en px/s² → ×4 conserve exactement le même feel de saut (mêmes durées, hauteur ×4).

**Vérif** : GUT vert (les tests d'état ne dépendent pas des px), lancement headless OK.

---

## 4. Phase C — Scènes .tscn (collisions et caméra)

| Fichier | Modification |
| --- | --- |
| `scenes/player/player.tscn` | collision 14×24 → **87×150** (ratio conservé ×6.25, arrondi entier impair évité : 88×150 acceptable), hitbox attack 22×20 → proportionnelle (~137×125 si le sprite attack suit le même facteur), position hitbox (16,0) → (100,0), vérifier `position_smoothing_speed` (8.0 — en px/s ? si oui ×4) |
| `scenes/enemies/enemy_ground.tscn` | 16×16 → 64×64, hurtbox 18×18 → 72×72 |
| `scenes/enemies/enemy_flyer.tscn` | 14×10 → 56×40, hurtbox 16×12 → 64×48 |
| `scenes/enemies/boss.tscn` | 28×36 → 112×144, hurtbox 30×38 → 120×152 |

Caméra (`player.tscn` / `shake_camera.gd`) : vérifier qu'aucun `zoom` n'est réglé (sinon l'ajuster), `MAX_OFFSET Vector2(6,4)` → `(24,16)` dans `shake_camera.gd:4`.

**Vérif** : run manuel court — le player tient sur les plateformes, ne passe pas à travers, les hitbox touchent.

---

## 5. Phase D — Scripts : constantes en px et UI programmatique

### Constantes gameplay (px) :
- `workbench.gd:5-6` : `SIZE (20,18)` → `(80,72)`, `ZONE_SIZE (60,50)` → `(240,200)` ; `_prompt.position (-18,-22)` → `(-72,-88)` ; font_size 8 → 32
- `ore_node.gd:3` : `DEFAULT_SIZE (14,14)` → `(56,56)` ; particules ligne 87-89 : gravité 300 → 1200, vérifier vélocités initiales
- `enemy_flyer.gd:54` : `hover_amplitude` vient du JSON (déjà traité phase B) — vérifier qu'aucun littéral px ne reste

### UI programmatique (positions, tailles, font_size — tout ×4) :
| Fichier | Éléments |
| --- | --- |
| `hud.gd` | barre HP (8,8 / 84×12 → 32,32 / 336×48), label HP, barre boss (90,244 / 304×14 → 360,976 / 1216×56), labels matériaux/consommable, font_size 9-10 → 36-40 |
| `title.gd` | toutes positions/tailles Vector2 480 → 1920, font_size 9-24 → 36-96 |
| `pause_menu.gd` | panel (130,48 / 220×176 → 520,192 / 880×704), labels, font_size 10-18 → 40-72 |
| `craft_menu.gd` | dim 480×270 → 1920×1080, panel PX/PY/PW/PH/ROW_H (constantes en tête de fichier) ×4, font_size 7-10 → 28-40 |
| `calibration.gd` | positions/tailles 480 → 1920, font_size 8-18 → 32-72 |
| `end_screen.gd` | custom_minimum_size (200×34 → 800×136, spacer 14 → 56), font_size 20 → 80 |

**Amélioration au passage (optionnelle mais recommandée)** : extraire un facteur ou des dimensions de référence dans un seul endroit (ex. constante `UI_SCALE := 4` ou lecture du viewport) plutôt que ×4 en dur partout — à trancher au moment de l'implémentation, sans en faire une refonte.

**Vérif** : chaque écran (title, HUD, pause, craft, calibration, end screen) s'affiche correctement, navigation manette OK.

---

## 6. Phase E — Sprites (côté game_art, canal backlog_art.md)

Source de vérité : `game_art/assets/` + `game_art/data/animations.json`, propagé par `sync.py`. **Ne jamais éditer `game/assets/sprites/` directement.**

### Solution transitoire immédiate (agent jeu, aucune attente game_art)
Upscale nearest des sprites actuels, pour que le jeu reste jouable dès cette phase :
- Player ×6 (14×24 → 84×144 ; attack 22×20 → 132×120) — 144 px ≈ cible 150 px, upscale entier propre. Ou script d'upscale ×6.25 si les 150 px exacts priment sur la propreté des pixels (à trancher, cf. section 0).
- Ennemis, boss, minerais, établi : ×4.
- `animations.json` : `frame_size` du run sheet [14,24] → nouvelle taille, `offset` de attack [0,2] → ×facteur.
- L'upscale se fait dans `game_art/assets/` (fichiers `*_x6.png` ou remplacement), puis `sync.py`.

### Production définitive (entrées à créer/mettre à jour dans `game_art/backlog_art.md`)
- Mettre à jour l'entrée « Sprites player — standard Terraria-like » (statut `en_cours`) : **nouvelles specs** — idle/run/jump ~87×150, attack proportionnel. Remplace la spec actuelle 14×24.
- Nouvelle entrée : sprites ennemis/boss aux nouvelles tailles natives (ou décision explicite de rester sur l'upscale nearest — cohérent avec un rendu pixel art chunky).
- Nouvelle entrée : minerais 56×56 (remplace la spec 14×14 de l'entrée « Sprites gisements/minerais »).
- Note transverse dans la section « Précisions » du backlog : grille de tiles 16×16 → **64×64 px monde** pour tous les futurs tilesets (Phase 4+).

**Vigilance manifest éditeur** : les tailles de sprites sont probablement référencées dans l'éditeur game_art (`roadmap_editeur.md`, manifest) — la zone game_art doit répercuter le changement de standard. À signaler via backlog_art, ne pas écrire dans `game_art/_contexte/`.

---

## 7. Phase F — Calibration gameplay (conséquence du player ×1.56 relatif)

Le monde est ×4 mais le player est ×6.25 : ses proportions face au niveau changent. À vérifier en run manuel et corriger **dans level.json uniquement** :
- Hauteur libre au-dessus de chaque plateforme (le player de 150 px passe-t-il sous [560,180,16,60] ×4 ?).
- Écarts horizontaux entre plateformes : le saut ×4 couvre la même distance relative au monde, mais le player plus grand change la perception — ajuster si un saut devient impossible ou trivial.
- `spawns` : les `pos` y sont au sol pour un player de 24 px (ex. y=224 pour floor_top=240) ; après ×4, vérifier que le player de 150 px spawn au-dessus du sol (y_spawn = floor_top×4 − 75 environ).
- `attack_range` (64 après ×4) face à un player de 87 px de large : probablement trop court — ajuster dans `weapons.json`/`player.json` jusqu'à ce que le feel soit bon.
- Positions des ennemis volants (135-145 → 540-580) face à la nouvelle hauteur de saut apparente.

Cette phase est du réglage JSON pur, itératif, validé manette en main.

---

## 8. Phase G — Validation finale

1. GUT vert : 23/23, aucune régression.
2. Démarrage headless OK (title + biome1).
3. Run manuel complet : title → biome → miner (tiers 1/2/3) → craft → tuer ennemis → boss → end screen → menus pause/craft/calibration à la manette.
4. `run_edit_game.py` : comparaison jeu/éditeur — signaler à game_art si l'éditeur affiche les nouveaux sprites incorrectement.
5. Vérifier `sync.py` : les nouveaux assets se propagent, aucun `.import` créé sous `game/assets/sprites/`.
6. Comparaison avec les captures de référence (phase 1).

---

## 9. Points de vigilance récapitulés

- **Ne pas multiplier les durées, HP, dégâts, multiplicateurs, fps** — uniquement px, px/s, px/s².
- `stretch/mode="viewport"` conservé : sur un écran non 16:9 ou une fenêtre redimensionnée, le rendu reste correct.
- Le piège `SubViewportContainer.stretch_shrink` (signals) concerne l'éditeur game_art — le changement de résolution du jeu peut casser sa vue comparative : à répercuter côté game_art via backlog_art.
- `docs/` et `roadmap.md` mentionnent partout « 480×270 » et « écran fixe par salle 480×270 » (Phase 4, Q038) : après validation, mettre à jour roadmap.md (propriété zone jeu) — les salles deviennent 1920×1080. Les templates de salles Phase 4 devront être authorés dans le nouveau référentiel.
- Coût récurrent assumé : tous les futurs contenus (salles, biomes 2-4, HUB, Arène) seront authorés en coordonnées ×4 — plus verbeux, et les specs art existantes du backlog (14×14, 16×16…) sont toutes à réviser.
- Rollback à tout moment : `git checkout main`, la branche reste intacte.

## 10. Ordre d'exécution et jouabilité continue

A (project.godot) et B (JSON) doivent être livrés **ensemble** (sinon le jeu est incohérent). C, D, E-transitoire suivent dans la même session. F et G sont itératifs. Commit à chaque phase validée sur la branche.
