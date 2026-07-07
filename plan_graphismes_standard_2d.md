# Plan — Abandon du pixel art, passage aux graphismes 2D standard

Objectif : remplacer la direction pixel art par des graphismes 2D "standard" (raster haute résolution lissé, dessin/peinture numérique ou vectoriel — pas de contrainte de grille ni de palette réduite), tout en gardant le jeu jouable et les tests GUT verts à chaque étape.

Ce plan s'articule avec `plan_resolution_1920x1080.md` : la migration vers un viewport natif 1920×1080 est **conservée** (elle est même plus adaptée à de la 2D lissée). Ce plan-ci ne remet en cause que la nature des assets et le pipeline de production, pas la résolution.

---

## 0. Impact assumé (à lire avant de lancer)

**Ce qui est jeté ou obsolète :**
- Zone game_art quasi entière : `charte_graphique_pixel_art_dark_fantasy.md`, `docs/workflow_image_gen_fable5.md`, `game_art/tools/ref_to_sprite.py` (réduction pixel), les specs pixel de `backlog_art.md` (14×14, grille 16×16, palettes limitées), l'audit de tailles sur grille (`manifest.json` / `audit_report.md`).
- Éditeur `game_art/editeur/` : conçu pour prévisualiser du pixel art (filtre nearest, preview x8, audit de frame_size sur grille). Une partie survit (preview d'animations, timing des frames), le reste devient sans objet.
- Les sprites pixel actuels (upscales ×6 du plan résolution) : placeholders jetables.

**Ce qui est conservé :**
- Résolution 1920×1080 native (project.godot déjà migré) et toute la mise à l'échelle ×4 des JSON/scènes/scripts.
- L'ambiance dark fantasy (Elden Ring-like) : c'est la *technique* qui change, pas l'intention artistique.
- Le pont `sync.py` game_art → game et le format `animations.json`.
- Architecture jeu (scripts, scènes, data-driven) : inchangée.

**Décision tranchée :** génération via le module image de Codex, puis rescale de l'image générée à la taille de rendu cible (cf. tailles §Phase B). Pas de dessin manuel, pas de vectoriel, pas d'asset packs.

Conséquences pipeline :
- `game_art/tools/ref_to_sprite.py` (réduction couleurs → grille pixel) supprimé : sans objet, remplacé par un rescale simple (resize vers la taille cible, filtrage linéaire, pas de réduction de palette).
- Nouveau script de rescale à écrire côté game_art (entrée : image générée par Codex à résolution libre ; sortie : PNG à la taille de rendu exacte attendue par `animations.json` / la scène concernée).
- `docs/workflow_image_gen_fable5.md` : remplacé par un workflow équivalent décrivant le prompt Codex → génération → rescale → intégration (au lieu de génération → détourage → réduction pixel).
- Pas de contrainte de palette ni de grille : le seul contrôle qualité est la taille finale et la cohérence visuelle entre assets.

---

## 1. Phase A — Rendu (`game/project.godot`)

Changements indépendants de l'option de production, faisables tout de suite :

- `rendering/textures/canvas_textures/default_texture_filter` : `0` (nearest) → **`1` (linéaire)**. C'est le changement central : le nearest est fait pour le pixel art ; la 2D lissée veut un filtrage linéaire (indispensable dès qu'un sprite est mis à l'échelle, tourné, ou affiché sur un écran non-natif).
- `window/stretch/mode` : `"viewport"` → **`"canvas_items"`** (recommandé pour de la 2D lissée : scaling propre sur résolutions non-natives, sub-pixel autorisé). `aspect="keep"` conservé. *À trancher : garder `"viewport"` reste acceptable si on assume un rendu à résolution fixe.*
- `config/description` : retirer "pixel art" ("Roguelite 2D pixel art..." → "Roguelite 2D...").

**Vérif :** le jeu se lance, les placeholders actuels apparaissent flous (nearest → linéaire sur des sprites pixel) — attendu et temporaire, ils seront remplacés en Phase B.

---

## 2. Phase B — Production et intégration des assets

Source de vérité inchangée : `game_art/assets/` → `sync.py` → `game/assets/sprites/`. **Ne jamais éditer `game/assets/sprites/` directement.**

Pipeline par asset : génération Codex (résolution libre, cadrage/fond cohérents avec l'usage) → rescale vers la taille de rendu cible → dépôt dans `game_art/assets/`.

Par entité, taille cible (référentiel 1920×1080, cf. plan résolution) :
- Player : idle / run / jump / attack / hurt / dead, ~150 px de haut (cible du plan résolution).
- Ennemis (ground, flyer), boss : tailles cohérentes avec le player agrandi (réévaluer visuellement).
- Objets : minerais, établi.
- À venir (hors périmètre immédiat) : tuiles/décors et icônes UI — ne plus raisonner en grille 16×16, mais en tuiles/éléments 2D à résolution native.

**Point de vigilance spécifique Codex** : chaque frame d'une même animation (idle, run 1/2, attack...) doit garder un cadrage, une échelle et un point d'ancrage cohérents entre générations successives — une génération IA image par image peut produire des tailles/proportions qui dérivent d'une frame à l'autre. Vérifier l'alignement après rescale (silhouette stable, pas de saut de taille entre frames) avant intégration.

Contraintes levées par rapport au pixel art : plus de grille imposée, plus de palette réduite, plus de preview x8, plus d'audit de frame_size sur grille.

**Sous-décision animation :** conserver le système actuel (sprite sheets par frames dans `animations.json`) ou passer à un autre mode (squelette/2D bones type Godot Skeleton2D, découpage). Le format sprite-sheet actuel reste le plus simple et n'oblige à rien — recommandé pour ne pas cumuler deux chantiers.

---

## 3. Phase C — Refonte de la zone game_art

Périmètre à cadrer selon l'option de production (§0). Ce que le plan implique quelle que soit l'option :

### Éditeur (`game_art/editeur/`)
- Retirer la logique pixel-spécifique : filtre `TEXTURE_FILTER_NEAREST` des previews → linéaire, preview "x8", audit de `frame_size` sur grille.
- Conserver ce qui reste utile : lecture `animations.json`, preview d'animation (timing, enchaînement des frames), comparaison avec référence.
- `manifest.json` / `audit.gd` / `audit_report.md` : l'audit de tailles sur grille n'a plus de sens. Soit supprimer l'audit, soit le redéfinir (ex. simple présence des fichiers attendus). **À trancher.**

### Outils
- `game_art/tools/ref_to_sprite.py` (réduction couleurs → grille pixel) : supprimer ou archiver. Sans objet en 2D standard.

### Documentation art
- `docs/charte_graphique_pixel_art_dark_fantasy.md` : réécrire l'intention (garder l'ambiance dark fantasy, retirer les règles pixel : tiles 16×16, objets 16/24 px, contraintes de palette) et **renommer** (`charte_graphique_dark_fantasy_2d.md`).
- `docs/workflow_image_gen_fable5.md` : obsolète (workflow pixel). Remplacer par le workflow de l'option retenue (§0) ou supprimer.
- `game_art/README.md` : réécrire la section "Workflow sprites pixel art" (récemment ajoutée) pour le nouveau pipeline.
- `game_art/backlog_art.md` : révision complète — retirer toutes les specs pixel (14×14, grille 16×16→64×64, palettes limitées) et ré-exprimer les besoins en 2D standard.

**Contrainte protocole :** la zone game_art se pilote par son propre canal (`backlog_art.md`, signaux). Ne pas écrire dans `game_art/_contexte/`. Les changements game_art ci-dessus sont à porter par la zone game_art, pas en direct depuis la zone jeu.

---

## 4. Phase D — `animations.json` et intégration

- Mettre à jour `frame_size` et `offset` de chaque état selon les nouveaux assets (Phase B), côté `game_art/data/animations.json`, propagé par `sync.py`.
- Vérifier que les scènes joueur/ennemis/boss référencent bien les nouveaux sprites (le chemin des fichiers ne change pas si on remplace en place ; sinon mettre à jour les `.tscn`).
- Collisions `.tscn` : déjà dimensionnées par le plan résolution (87×150 etc.). Réajuster seulement si la nouvelle silhouette 2D diffère nettement du gabarit.

**Vérif :** GUT vert (les tests d'état ne dépendent pas des graphismes), run headless OK, animations lues sans erreur.

---

## 5. Phase E — Documentation jeu (cohérence globale)

Mentions "pixel art" / grille / 480×270 à corriger (cumulé avec le reste du plan résolution §9) :
- `roadmap.md` : références pixel art / tiles 16×16 (L325, L430) et salles 480×270 (L303-321).
- `questions.md` : Q068 (grille 16×16), Q072 (rendu 480×270 upscalé), Q038 — noter que ces décisions pixel sont révisées.
- `game/README.md` (L31 "480x270 integer scale") et `README.md` racine : retirer pixel art / integer scale.
- `CHANGELOG.md` : consigner le pivot (abandon pixel art → 2D standard).
- `_contexte/` (zones jeu et game_art) : via le protocole /close, pas en édition directe.

---

## 6. Phase F — Validation finale

1. GUT vert : 23/23, aucune régression (les tests ne dépendent pas des assets).
2. Démarrage headless OK (title + biome1).
3. Run manuel complet manette : title → biome → miner → craft → combat → boss → end screen → menus, avec les nouveaux assets.
4. Contrôle visuel : lisibilité, cohérence d'échelle player/ennemis/décor, rendu du filtrage linéaire (pas de flou involontaire, pas d'aliasing gênant).
5. `sync.py` : nouveaux assets propagés, aucun `.import` sous `game/assets/sprites/`.
6. Éditeur (`run_editeur.py` / `run_edit_game.py`) : la vue comparative fonctionne avec les nouveaux assets et le filtrage linéaire.

---

## 7. Points de vigilance

- **Ne pas mélanger les deux chantiers** : finir/valider la migration résolution (plan `plan_resolution_1920x1080.md`, GUT + run manuel non encore confirmés) avant ou en parallèle contrôlé de ce pivot, pour ne pas cumuler deux sources de casse.
- **Ordre conseillé** : Phase A (rendu) immédiate et sûre → trancher la décision §0 → Phases B/C/D itératives → E/F.
- **Coût réel** : ce pivot est lourd côté game_art (éditeur, outils, docs, backlog à refondre) et côté production (tous les assets à refaire). Le chiffrer avant de lancer.
- **Licences** si option "asset packs" (§0-d) : vérifier droits d'usage et redistribution.
- **Dérive entre frames (pipeline Codex)** : surveiller particulièrement en Phase B, cf. point de vigilance dédié — c'est le principal risque qualité propre à ce pipeline.
- Rollback : la résolution et la structure restent sur `main` ; travailler sur une branche dédiée (`git checkout -b graphismes-2d-standard`).
