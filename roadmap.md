# Roadmap CoreDive Challenge — v3

Réf design : `docs/v3/CoreDive Challenge — Design Document v3.md`

## Principe directeur

v3 n'est pas un rewrite. Le noyau gameplay (combat, feel, ennemis, animation, input, audio, pattern data-driven JSON) est conservé. v3 construit une couche méta-structurelle autour : persistance, HUB, biomes, mort-résurrection, cicatrices, boss adaptatif.

Convention : toute tâche marquée **[game_art]** relève de la zone game_art (sprites, shaders, effets visuels). Le reste relève de la zone jeu.

Règle absolue maintenue : aucune valeur numérique gameplay hardcodée. Tout dans `game/data/*.json`.

---

## Stratégie de tests

Infra mise en place dès la Phase 0 (GUT — Godot Unit Test). Cible : la logique data-driven et d'état, testable et critique (parsing JSON, save/load, RunState/MetaState, craft, génération, cicatrices, calcul du boss adaptatif). Le feel/physique reste validé manuellement en jeu.

Règle : chaque phase livre ses tests en même temps que son code. Une phase n'est « faite » que si ses tests passent. Les tests des phases précédentes doivent rester verts (non-régression) — c'est le filet qui sécurise une refonte incrémentale.

## Jalons de refacto

Trois points de consolidation placés là où la dette s'accumule naturellement, avant que la phase suivante ne la fige :
- **R1** après Phase 2 — consolider la couche d'état (RunState/MetaState/Grimoire) avant de bâtir le HUB et les biomes dessus.
- **R2** après Phase 5 — factoriser ce qui s'est dupliqué entre biomes, ennemis et boss avant d'empiler mort/cicatrices/adaptatif.
- **R3** avant Phase 9 — préparer la modularité boss (extraire les modules réutilisables de `boss.gd`).

---

## Phase 0 — Fondations : persistance et découplage état

Casser le couplage mono-run / mono-niveau avant tout le reste. Sans ça, chaque phase suivante se bat contre l'architecture.

### Tâches
- [x] Créer un système de sauvegarde `user://` (JSON) : `game/scripts/save_manager.gd` (autoload).
- [x] Scinder `inventory.gd` en deux autoloads :
  - `RunState` — éphémère, remis à zéro à chaque run : matériaux, équipement, consommables, monnaie, cicatrices.
  - `MetaState` — persistant entre runs : Grimoire (recettes découvertes/maîtrisées), Points de Compétence.
- [x] Migrer les usages actuels de `Inventory` (`player.gd`, `craft_menu.gd`, `level.gd`, `hud.gd`) vers `RunState`.
- [x] Charger/sauver `MetaState` au démarrage et à la fin de run.
- [x] Installer GUT et créer `tests/` : premiers tests sur save/load (`SaveManager`), reset de `RunState`, persistance de `MetaState`.

### Fait quand
Un run modifie `RunState` sans toucher `MetaState`. Fermer/relancer le jeu conserve `MetaState`. Le jeu actuel reste jouable de bout en bout après migration. Tests save/load et état verts.

### Dépend de
Rien.

### Risques
`Inventory` est référencé dans plusieurs scripts. Migration mécanique mais à faire d'un bloc pour éviter un état hybride. Tester un run complet après migration.

---

## Phase 1 — Matériaux typés

Le craft v3 consomme des matériaux distincts (bois, pierre, cuivre, fer, cristaux, fragments du Noyau...). Aujourd'hui `RunState.resources` est un seul entier.

### Tâches
- [ ] Remplacer `resources: int` par `materials: Dictionary` (id → quantité) dans `RunState`.
- [ ] Créer `game/data/materials.json` (id, nom, biome source, rareté).
- [ ] Adapter `ore_node.gd` : chaque gisement a un `material_id`.
- [ ] Adapter `hud.gd` pour afficher les matériaux possédés.
- [ ] Adapter `level.json` : les `ores` portent un type de matériau.
- [ ] **[game_art]** sprites distincts par type de gisement/minerai.

### Fait quand
Miner un gisement ajoute le bon matériau. Le HUD reflète les quantités par type.

### Dépend de
Phase 0.

### Risques
Le mode dev « 100 MIN » suppose une monnaie unique. À réadapter (donner un stock de chaque matériau, ou garder une ressource debug).

---

## Phase 2 — Grimoire, Points de Compétence, Craft v3

### Tâches
- [ ] Étendre `recipes.json` : `id`, `name`, `rarity`, `biome`, `skill_cost`, `materials` (dict), `discovered` (méta), `mastered` (méta), `consumable`.
- [ ] Recettes de départ marquées maîtrisées par défaut (épée bois, armure bois, pioche, petite potion, torche, corde, établi portable).
- [ ] Logique Grimoire dans `MetaState` : découverte (run) → maîtrise (dépense de PC entre runs).
- [ ] Refondre `craft_menu.gd` : ne propose QUE les recettes maîtrisées dont les matériaux sont présents.
- [ ] Gain de PC en fin de run (profondeur, élites, boss, salles secrètes, réussite) — même un run raté en rapporte.
- [ ] Écran de déblocage des recettes (dépense de PC) — accessible au HUB. **[game_art]** mise en page/icônes du Grimoire.

### Fait quand
Découvrir une recette en run l'ajoute au Grimoire (persistant). La maîtriser coûte des PC. Une recette maîtrisée est craftable au prochain run si matériaux réunis. Tests verts : découverte, maîtrise (dépense PC), filtrage des recettes craftables, gain de PC en fin de run.

### Dépend de
Phases 0, 1.

### Risques
La logique d'obsolescence actuelle (`_is_recipe_obsolete`) est hardcodée pour les épées. À généraliser ou retirer au profit du système de paliers.

---

## Refacto R1 — Consolidation de la couche d'état

Avant de bâtir le HUB et les biomes sur RunState/MetaState/Grimoire, stabiliser ces fondations.

### Tâches
- [ ] Revue de l'API RunState/MetaState : nommage cohérent, suppression des accès directs résiduels à l'ancien `Inventory`.
- [ ] Centraliser les accès au Grimoire (un seul point d'entrée, pas de logique dispersée).
- [ ] Nettoyer la logique d'obsolescence héritée des épées.
- [ ] Compléter la couverture de tests de la couche d'état avant gel.

### Fait quand
Aucune référence à l'ancien `Inventory` ne subsiste. Tests d'état exhaustifs et verts.

---

## Phase 3 — HUB et sélection de biome

### Tâches
- [ ] Créer la scène HUB : point central, 4 directions accessibles. **[game_art]** décor du HUB.
- [ ] Transformer `title.gd` : le menu lance le HUB (pas directement biome1).
- [ ] Paramétrer le chargement de niveau : `level.gd` reçoit un `biome_id` et charge `game/data/biomes/<id>.json` au lieu de `level.json` fixe.
- [ ] Retour au HUB après mort définitive ou fin de biome (au lieu de `get_tree().quit()`).
- [ ] Accès au Grimoire/déblocage PC et à l'établi depuis le HUB.

### Fait quand
Depuis le HUB, choisir une des 4 directions lance le biome correspondant. Mourir/finir ramène au HUB. Le mode dev reste fonctionnel.

### Dépend de
Phases 0, 2.

### Risques
`level.gd` suppose des dimensions fixes et un boss à `arena_x`. Le paramétrage par biome doit abstraire ça proprement (préparer la Phase 4).

---

## Phase 4 — Génération des biomes

Le point le plus risqué. **Décision arrêtée : assemblage de salles pré-authorées (templates).** Pas de PCG algorithmique pur. Plus contrôlable, garantit les ressources, compatible solo.

### Tâches
- [ ] Définir un format de salle (template JSON : géométrie, points de spawn ennemis/ores/établi, connexions).
- [ ] Générateur `game/scripts/biome_generator.gd` : assemble des salles selon une config de biome (longueur, pool de salles, garanties).
- [ ] Garantie de ressources : la config impose un minimum de chaque matériau clé du biome.
- [ ] Placement boss en fin de parcours généré.
- [ ] Refondre `level.gd` pour consommer la sortie du générateur au lieu des rects fixes.
- [ ] Tests de génération : complétabilité (chemin start→boss toujours existant), présence garantie des ressources clés, validité des connexions entre salles.

### Fait quand
Lancer un biome deux fois produit deux agencements différents, tous deux complétables, avec les ressources clés présentes. Tests de complétabilité et de garantie ressources verts sur N générations.

### Dépend de
Phase 3.

### Risques
- Garantie de complétabilité (le joueur ne doit jamais être bloqué). Couverte par tests automatisés sur la connectivité.
- **[game_art]** : tilesets/décors par biome conditionnent le rendu — dépendance forte sur game_art.

---

## Phase 5 — Contenu des biomes 2, 3, 4

### Tâches
- [ ] Config + génération pour Mines Obscures, Îles Célestes, Descente vers le Noyau.
- [ ] Ennemis spécifiques par biome (étendre `enemy_base.gd`, `enemies.json`).
- [ ] Ressources spécifiques (déjà typées en Phase 1).
- [ ] Boss de biome : Foreur Maudit, Orage Éternel, Gardien du Noyau (réutiliser/étendre `boss.gd`, `boss.json`).
- [ ] **[game_art]** : sprites ennemis, sprites/animations des 3 boss, décors et tilesets des 3 biomes.

### Fait quand
Les 4 biomes sont jouables de bout en bout avec leurs ennemis, ressources et boss.

### Dépend de
Phase 4.

### Risques
Gros volume de contenu et d'art. Étaler par biome (Biome 2 complet avant d'attaquer Biome 3). Difficulté croissante à équilibrer.

---

## Refacto R2 — Factorisation biomes / ennemis / boss

Les 4 biomes et leurs boss ont été produits incrémentalement : du code s'est dupliqué. Consolider avant d'empiler mort, cicatrices et boss adaptatif.

### Tâches
- [ ] Extraire les patterns communs des biomes (chargement config, génération, spawn) dans une base partagée.
- [ ] Factoriser les comportements d'ennemis récurrents dans `enemy_base.gd`.
- [ ] Unifier la structure des boss de biome (prépare R3 et la Phase 9).
- [ ] Vérifier que toute la donnée gameplay est bien externalisée (audit anti-hardcode).

### Fait quand
Aucune duplication structurelle majeure entre biomes/boss. Tests de non-régression verts sur les 4 biomes.

---

## Phase 6 — Mort, Résurrection, Arène du Voile

### Tâches
- [ ] Intercepter la mort du joueur (`player.gd` `_die()` / `level.gd` `_on_player_died`) : au lieu de l'écran de fin, transition vers l'Arène du Voile.
- [ ] Scène Arène du Voile (unique). **[game_art]** décor « tribunal cosmique ».
- [ ] Gardiens du Voile : pool de combats (réutiliser l'archi boss), tirage aléatoire.
- [ ] Difficulté croissante par nombre de résurrections dans le run (data-driven).
- [ ] Victoire → résurrection à l'endroit de la mort, PV restaurés, cicatrice appliquée. Défaite → fin de run définitive.
- [ ] **[game_art]** : sprites/patterns visuels des Gardiens.
- [ ] Tests : sauvegarde/restauration de l'état de biome autour de l'aller-retour Arène, escalade de difficulté des Gardiens selon le compteur de résurrections.

### Fait quand
Mourir envoie à l'Arène. Vaincre le Gardien ressuscite le joueur dans le biome avec une cicatrice, **dans l'état exact où il l'avait quitté**. Perdre termine le run. Tests d'état biome verts.

### Dépend de
Phases 3, 5 (boss réutilisable). Cicatrices = Phase 7 (peut être stubbé d'abord).

### Risques (À SURVEILLER — point critique)
La résurrection doit restaurer l'état exact du biome (position joueur, ennemis vivants/morts, ressources minées, agencement généré). **Le biome ne doit surtout pas être régénéré au retour de l'Arène.** Concrètement : sérialiser l'état de run du biome avant la transition vers l'Arène, le restaurer au retour. Couvrir par un test dédié, ne pas se fier au seul test manuel.

---

## Phase 7 — Cicatrices

### Tâches
- [ ] `game/data/scars.json` : effets gameplay (modificateurs de stats).
- [ ] Application comme modificateurs sur `player.gd` (le système `damage_reduction`/équipement actuel sert de modèle d'insertion).
- [ ] Stockage des cicatrices actives dans `RunState`.
- [ ] Tirage de la cicatrice à chaque résurrection.
- [ ] **[game_art]** : effets visuels par palier (1 à 5+) via shaders + overlays de particules, PAS de refonte de spritesheet.

### Fait quand
Chaque résurrection applique une cicatrice qui modifie réellement le gameplay et l'apparence, persistante jusqu'à la fin du run.

### Dépend de
Phase 6.

### Risques
Cumul de cicatrices : éviter les combinaisons qui rendent le run injouable ou trivial. Équilibrage.

---

## Phase 8 — Porteurs de recettes

### Tâches
- [ ] Ennemis rares (Archiviste, Golem Artisan, Mineur Spectral, Forgeron Maudit) — apparition conditionnelle par biome.
- [ ] Drop = découverte de recette (ajout au Grimoire via `MetaState`).
- [ ] Catégories de drop cohérentes par porteur.
- [ ] **[game_art]** : sprites des 4 porteurs.

### Fait quand
Vaincre un porteur ajoute une recette « Découverte » au Grimoire.

### Dépend de
Phases 2, 5.

### Risques
Taux d'apparition/drop à équilibrer pour que la collection soit gratifiante sans être frustrante.

---

## Refacto R3 — Modularité boss

Préparer le boss adaptatif en extrayant les briques réutilisables des boss existants.

### Tâches
- [ ] Découper `boss.gd` en modules : corps, déplacement, pouvoir principal, mutations.
- [ ] Définir l'interface d'assemblage de ces modules.
- [ ] Valider l'architecture sur les boss de biome existants (ils doivent être ré-exprimables comme combinaisons de modules) avant de produire le Miroir.
- [ ] Tests unitaires sur l'assemblage des modules.

### Fait quand
Les boss de biome fonctionnent via l'architecture modulaire. L'assemblage est testé et prêt pour la génération adaptative.

---

## Phase 9 — Miroir du Noyau (boss final adaptatif)

### Tâches
- [ ] Architecture modulaire : corps / déplacement / pouvoir principal / mutations (modules réutilisables sur base `boss.gd`).
- [ ] Génération du boss à partir de 2 paramètres : biomes explorés + cicatrices accumulées (tracés dans `RunState`).
- [ ] Déclenchement après le Gardien du Noyau (Biome 4).
- [ ] **[game_art]** : modules visuels combinables (corps, effets de pouvoir, mutations).
- [ ] Tests : génération du boss à partir de paramètres de run donnés (déterminisme), combinaisons extrêmes (tous biomes/toutes cicatrices, aucun).

### Fait quand
Atteindre le Noyau génère un boss reflétant le parcours du run. Deux runs différents produisent deux boss différents. Tests de génération (déterminisme + cas extrêmes) verts.

### Dépend de
Phases 5, 7.

### Risques
Combinatoire de modules = risque de bugs/équilibrage. Limiter le nombre de modules au départ, étendre ensuite. Tester les combinaisons extrêmes.

---

## Phase 10 — Intégration, équilibrage, polish

### Tâches
- [ ] Équilibrage global (PC, coûts de maîtrise, difficulté biomes, escalade Gardiens, cicatrices).
- [ ] Boucle méta complète testée sur plusieurs runs.
- [ ] Passes audio/feedback.
- [ ] **[game_art]** : cohérence visuelle globale, passes finales.

### Fait quand
Un joueur peut enchaîner plusieurs runs, progresser via le Grimoire/PC, mourir et ressusciter, et atteindre le Miroir du Noyau dans une expérience cohérente.

### Dépend de
Toutes.

---

## Ordre de dépendances (résumé)

```
0 Fondations (+ infra tests GUT)
└─ 1 Matériaux typés
   └─ 2 Grimoire/PC/Craft
      └─ R1 Consolidation état
         └─ 3 HUB + sélection biome
            └─ 4 Génération biomes (templates assemblés)
               └─ 5 Contenu biomes 2/3/4
                  └─ R2 Factorisation biomes/ennemis/boss
                     ├─ 6 Mort/Résurrection/Voile
                     │   └─ 7 Cicatrices
                     │       └─ R3 Modularité boss
                     │           └─ 9 Boss adaptatif (+ dépend de 5)
                     └─ 8 Porteurs de recettes (dépend de 2 et 5)
0..9 ─ 10 Intégration/polish
```

Tests : livrés à chaque phase, maintenus verts (non-régression) tout du long. Refacto : R1 (après 2), R2 (après 5), R3 (avant 9).

## Risques transverses majeurs

1. **Volume d'art (Phases 5/6/8/9)** — dépendance lourde sur game_art ; cadencer biome par biome.
2. **Persistance de l'état de biome à la résurrection (Phase 6)** — À SURVEILLER : ne pas régénérer le biome au retour de l'Arène ; sérialiser/restaurer, couvrir par test dédié.
3. **Équilibrage de la boucle méta (Phase 10)** — nécessite des runs complets répétés.
4. **Dette inter-phases** — neutralisée par les jalons R1/R2/R3 ; ne pas les sauter sous pression de contenu.
