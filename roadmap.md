# Roadmap CoreDive Challenge — v3

Réf design : `docs/v3/CoreDive Challenge — Design Document v3.md`

## Principe directeur

v3 n'est pas un rewrite. Le noyau gameplay (combat, feel, ennemis, animation, input, audio, pattern data-driven JSON) est conservé. v3 construit une couche méta-structurelle autour : persistance, HUB, biomes, mort-résurrection, cicatrices, boss adaptatif.

**Ordre guidé par les jalons jouables** : la boucle identitaire (mort → Arène du Voile → résurrection → cicatrice) est implémentée avant le contenu des biomes 2/3/4, conformément aux priorités P0 du design doc. Nino dispose d'une version jouable stable à chaque jalon.

**Règle placeholders** : aucune phase jeu n'attend game_art. Chaque phase livre avec des placeholders (rects, sprites temporaires) et recense ses besoins d'assets dans `game_art/backlog_art.md`. game_art produit à son rythme et remplace au fil de l'eau via sync.py. Les tâches marquées **[game_art]** sont listées pour traçabilité mais ne conditionnent jamais le « fait quand » d'une phase jeu.

Règle absolue maintenue : aucune valeur numérique gameplay hardcodée. Tout dans `game/data/*.json`.

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

Infra mise en place dès la Phase 0 (GUT — Godot Unit Test). Cible : la logique data-driven et d'état, testable et critique (parsing JSON, save/load, RunState/MetaState, craft, génération, cicatrices, calcul du boss adaptatif). Le feel/physique reste validé manuellement en jeu.

Règle : chaque phase livre ses tests en même temps que son code. Une phase n'est « faite » que si ses tests passent. Les tests des phases précédentes doivent rester verts (non-régression) — c'est le filet qui sécurise une refonte incrémentale.

**Objectif de couverture : 85 % minimum** sur les modules de logique data-driven/état (RunState, MetaState, SaveManager, Grimoire, génération de biomes, craft, cicatrices, boss adaptatif) — hors scènes, rendu, feel/physique. Vérifié et complété à chaque jalon de refacto (R1, R1.5, R2, R3) et une dernière fois avant la Phase 10.

## Jalons de refacto

Quatre points de consolidation placés là où la dette s'accumule naturellement, avant que la phase suivante ne la fige. Chacun inclut un audit de couverture de tests (combler jusqu'à 85 % sur le périmètre consolidé) :
- **R1** après Phase 2 — consolider la couche d'état (RunState/MetaState/Grimoire) avant de bâtir le HUB et les biomes dessus.
- **R1.5** après Phase 4 — consolider génération + HUB avant d'y greffer la boucle mort/résurrection (Phase 5, point critique de persistance d'état) et avant l'explosion de contenu de la Phase 7. Comble le grand écart R1→R2 (5 phases).
- **R2** après Phase 7 — factoriser ce qui s'est dupliqué entre biomes, ennemis, boss ET Gardiens du Voile avant d'empiler porteurs et boss adaptatif.
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
- [ ] Recenser dans `game_art/backlog_art.md` : sprites distincts par type de gisement/minerai. **[game_art]**

### Fait quand
Miner un gisement ajoute le bon matériau. Le HUD reflète les quantités par type. Tests verts.

### Dépend de
Phase 0.

### Risques
Le mode dev « 100 MIN » suppose une monnaie unique. À réadapter (donner un stock de chaque matériau, ou garder une ressource debug).

---

## Phase 2 — Grimoire, Points de Compétence, Craft v3

### Tâches
- [ ] Étendre `recipes.json` : `id`, `name`, `rarity`, `biome`, `skill_cost`, `materials` (dict), `discovered` (méta), `mastered` (méta), `consumable`, `workbench_tier`.
- [ ] Recettes de départ marquées maîtrisées par défaut (épée bois, armure bois, pioche, petite potion, torche, corde, établi portable).
- [ ] Logique Grimoire dans `MetaState` : découverte (run) → maîtrise (dépense de PC entre runs).
- [ ] Refondre `craft_menu.gd` : ne propose QUE les recettes maîtrisées dont les matériaux sont présents.
- [ ] Gain de PC en fin de run — métrique définie : salles explorées + biomes visités + élites/boss vaincus + salles secrètes + réussite du run (remplace la « profondeur atteinte » du design doc, ambiguë dans un monde à 4 directions). Même un run raté en rapporte. Barème dans `game/data/*.json`.
- [ ] Écran de déblocage des recettes (dépense de PC) — accessible au HUB. Recenser mise en page/icônes du Grimoire dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Test dédié synergie cross-biomes : une recette multi-matériaux (ex. Épée Tempête du Noyau : fer + cristaux + fragment du Noyau) est craftable si et seulement si tous les matériaux sont présents.
- [ ] `workbench_tier` stocké dès maintenant dans les données ; l'activation réelle des établis avancés se fait en Phase 7 (biomes avancés).

### Fait quand
Découvrir une recette en run l'ajoute au Grimoire (persistant). La maîtriser coûte des PC. Une recette maîtrisée est craftable au prochain run si matériaux réunis. Tests verts : découverte, maîtrise (dépense PC), filtrage des recettes craftables, gain de PC en fin de run, recette cross-biomes.

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
- [ ] Auditer la couverture de tests de la couche d'état, compléter jusqu'à 85 %.

### Fait quand
Aucune référence à l'ancien `Inventory` ne subsiste. Tests d'état exhaustifs et verts. Couverture ≥ 85 % sur RunState/MetaState/SaveManager/Grimoire.

---

## Phase 3 — HUB et sélection de biome → **Jalon J1**

### Tâches
- [ ] Créer la scène HUB : point central, 4 directions accessibles (placeholder pour les directions non encore implémentées : panneau « en construction »). Recenser décor du HUB dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Transformer `title.gd` : le menu lance le HUB (pas directement biome1).
- [ ] Paramétrer le chargement de niveau : `level.gd` reçoit un `biome_id` et charge `game/data/biomes/<id>.json` au lieu de `level.json` fixe.
- [ ] Retour au HUB après mort définitive ou fin de biome (au lieu de `get_tree().quit()`).
- [ ] Accès au Grimoire/déblocage PC et à l'établi depuis le HUB.

### Fait quand
Depuis le HUB, choisir une direction lance le biome correspondant. Mourir/finir ramène au HUB. Le mode dev reste fonctionnel. **J1 : Nino peut jouer un run complet HUB → biome → retour HUB.**

### Dépend de
Phases 0, 2.

### Risques
`level.gd` suppose des dimensions fixes et un boss à `arena_x`. Le paramétrage par biome doit abstraire ça proprement (préparer la Phase 4).

---

## Phase 4 — Génération des biomes → **Jalon J2**

Le point le plus risqué. **Décision arrêtée : assemblage de salles pré-authorées (templates).** Pas de PCG algorithmique pur. Plus contrôlable, garantit les ressources, compatible solo. **Validée sur le biome 1 uniquement** — les biomes 2/3/4 réutiliseront le générateur en Phase 7.

### Tâches
- [ ] Définir un format de salle (template JSON : géométrie, points de spawn ennemis/ores/établi, connexions).
- [ ] Générateur `game/scripts/biome_generator.gd` : assemble des salles selon une config de biome (longueur, pool de salles, garanties).
- [ ] Garantie de ressources : la config impose un minimum de chaque matériau clé du biome.
- [ ] Placement boss en fin de parcours généré.
- [ ] Refondre `level.gd` pour consommer la sortie du générateur au lieu des rects fixes.
- [ ] Tests de génération : complétabilité (chemin start→boss toujours existant), présence garantie des ressources clés, validité des connexions entre salles.
- [ ] Recenser tileset/décors biome 1 dans `game_art/backlog_art.md`. **[game_art]**

### Fait quand
Lancer le biome 1 deux fois produit deux agencements différents, tous deux complétables, avec les ressources clés présentes. Tests de complétabilité et de garantie ressources verts sur N générations. **J2.**

### Dépend de
Phase 3.

### Risques
Garantie de complétabilité (le joueur ne doit jamais être bloqué). Couverte par tests automatisés sur la connectivité.

---

## Refacto R1.5 — Consolidation génération + HUB

Point médian judicieux dans le grand écart entre R1 (après Phase 2) et R2 (après Phase 7). Stabiliser la couche génération/HUB avant d'y greffer la persistance d'état critique (Phase 5) et avant l'explosion de contenu des 3 biomes restants (Phase 7).

### Tâches
- [ ] Revue de l'API `biome_generator.gd` / `level.gd` : nommage cohérent, séparation claire génération vs. consommation par `level.gd`.
- [ ] Vérifier qu'aucune donnée gameplay du biome 1 n'est restée hardcodée hors JSON.
- [ ] Auditer la couverture de tests de la génération et du HUB, compléter jusqu'à 85 %.

### Fait quand
`level.gd` et `biome_generator.gd` exposent une API stable et documentée par l'usage (pas de doc à part). Tests de génération et HUB exhaustifs et verts. Couverture ≥ 85 % sur le périmètre génération/HUB.

---

## Phase 5 — Mort, Résurrection, Arène du Voile

Boucle identitaire du jeu (P0 du design doc) — implémentée tôt, avec le seul biome 1, pour valider la mécanique phare et dérisquer la persistance d'état de biome.

### Tâches
- [ ] Intercepter la mort du joueur (`player.gd` `_die()` / `level.gd` `_on_player_died`) : au lieu de l'écran de fin, transition vers l'Arène du Voile.
- [ ] Scène Arène du Voile (unique), décor placeholder. Recenser décor « tribunal cosmique » dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Gardiens du Voile : **2-3 Gardiens simples** au départ (réutiliser l'archi boss actuelle), tirage aléatoire. Le pool complet (8 Gardiens du design doc) est étendu après R2 — voir backlog post-v3 si non atteint.
- [ ] Difficulté croissante par nombre de résurrections dans le run (data-driven).
- [ ] Victoire → résurrection à l'endroit de la mort, PV restaurés, cicatrice appliquée (stub tant que Phase 6 non faite). Défaite → fin de run définitive, retour HUB.
- [ ] Recenser sprites/patterns visuels des Gardiens dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Tests : sauvegarde/restauration de l'état de biome autour de l'aller-retour Arène, escalade de difficulté des Gardiens selon le compteur de résurrections.

### Fait quand
Mourir envoie à l'Arène. Vaincre le Gardien ressuscite le joueur dans le biome, **dans l'état exact où il l'avait quitté**. Perdre termine le run. Tests d'état biome verts.

### Dépend de
Phase 4, R1.5.

### Risques (À SURVEILLER — point critique)
- La résurrection doit restaurer l'état exact du biome (position joueur, ennemis vivants/morts, ressources minées, agencement généré). **Le biome ne doit surtout pas être régénéré au retour de l'Arène.** Sérialiser l'état de run du biome avant la transition, le restaurer au retour. Couvrir par un test dédié, ne pas se fier au seul test manuel.
- Les Gardiens sont construits sur `boss.gd` non consolidé (R2 n'a pas encore eu lieu). Coût assumé pour valider l'identité tôt : R2 inclura les Gardiens dans la factorisation. Limiter à 2-3 Gardiens simples réduit la dette.

---

## Phase 6 — Cicatrices → **Jalon J3**

### Tâches
- [ ] `game/data/scars.json` : effets gameplay (modificateurs de stats).
- [ ] Application comme modificateurs sur `player.gd` (le système `damage_reduction`/équipement actuel sert de modèle d'insertion).
- [ ] Stockage des cicatrices actives dans `RunState`.
- [ ] Tirage de la cicatrice à chaque résurrection.
- [ ] Recettes du Voile : catégorie de recettes découvertes uniquement via les Gardiens du Voile (Lame Spectrale, Anneau des Revenants, Élixir de Résurgence) — champ `biome: "voile"` dans `recipes.json`, drop à la victoire en Arène.
- [ ] Recenser effets visuels par palier (1 à 5+) via shaders + overlays de particules dans `game_art/backlog_art.md` — PAS de refonte de spritesheet. **[game_art]**
- [ ] Tests : application des modificateurs, cumul de cicatrices, drop des recettes du Voile.

### Fait quand
Chaque résurrection applique une cicatrice qui modifie réellement le gameplay, persistante jusqu'à la fin du run. Vaincre un Gardien peut faire découvrir une recette du Voile. **J3 : la boucle identitaire complète est jouable.**

### Dépend de
Phase 5.

### Risques
Cumul de cicatrices : éviter les combinaisons qui rendent le run injouable ou trivial. L'équilibrage restera provisoire tant que les biomes 2/3/4 n'existent pas — passe d'équilibrage définitive en Phase 10.

---

## Phase 7 — Contenu des biomes 2, 3, 4 → **Jalons J4, J5, J6**

Étalée strictement biome par biome : 7a = Mines Obscures (J4), 7b = Îles Célestes (J5), 7c = Descente vers le Noyau (J6). Un biome est terminé avant d'attaquer le suivant.

### Tâches (répétées par biome)
- [ ] Config + génération (réutilise le générateur de la Phase 4).
- [ ] Ennemis spécifiques (étendre `enemy_base.gd`, `enemies.json`).
- [ ] Ressources spécifiques (déjà typées en Phase 1).
- [ ] Boss de biome : Foreur Maudit (7a), Orage Éternel (7b), Gardien du Noyau (7c) — réutiliser/étendre `boss.gd`, `boss.json`.
- [ ] Établis avancés : activation du `workbench_tier` (défini en Phase 2) — les recettes rares/épiques/légendaires exigent l'établi du bon palier.
- [ ] Recenser par biome dans `game_art/backlog_art.md` : sprites ennemis, sprite/animations du boss, décors et tileset. **[game_art]**

### Fait quand
Chaque biome livré est jouable de bout en bout avec ses ennemis, ressources et boss (placeholders acceptés). Les 4 biomes jouables = fin de phase.

### Dépend de
Phases 4, 6.

### Risques
Gros volume de contenu. Ne jamais paralléliser deux biomes. Difficulté croissante à équilibrer.

---

## Refacto R2 — Factorisation biomes / ennemis / boss / Gardiens

Les 4 biomes, leurs boss et les premiers Gardiens du Voile ont été produits incrémentalement : du code s'est dupliqué. Consolider avant d'empiler porteurs et boss adaptatif.

### Tâches
- [ ] Extraire les patterns communs des biomes (chargement config, génération, spawn) dans une base partagée.
- [ ] Factoriser les comportements d'ennemis récurrents dans `enemy_base.gd`.
- [ ] Unifier la structure des boss de biome ET des Gardiens du Voile (prépare R3 et la Phase 9).
- [ ] Étendre le pool de Gardiens du Voile sur la base unifiée (cible : 8 — sinon reporter le reliquat au backlog post-v3).
- [ ] Vérifier que toute la donnée gameplay est bien externalisée (audit anti-hardcode).
- [ ] Auditer la couverture de tests biomes/ennemis/boss/Gardiens, compléter jusqu'à 85 %.

### Fait quand
Aucune duplication structurelle majeure entre biomes/boss/Gardiens. Tests de non-régression verts sur les 4 biomes et l'Arène. Couverture ≥ 85 % sur le périmètre consolidé.

---

## Phase 8 — Porteurs de recettes

### Tâches
- [ ] Ennemis rares (Archiviste, Golem Artisan, Mineur Spectral, Forgeron Maudit) — apparition conditionnelle par biome.
- [ ] Drop = découverte de recette (ajout au Grimoire via `MetaState`).
- [ ] Catégories de drop cohérentes par porteur.
- [ ] Recenser sprites des 4 porteurs dans `game_art/backlog_art.md`. **[game_art]**

### Fait quand
Vaincre un porteur ajoute une recette « Découverte » au Grimoire.

### Dépend de
Phases 2, 7.

### Risques
Taux d'apparition/drop à équilibrer pour que la collection soit gratifiante sans être frustrante.

---

## Refacto R3 — Modularité boss

Préparer le boss adaptatif en extrayant les briques réutilisables des boss existants.

### Tâches
- [ ] Découper `boss.gd` en modules : corps, déplacement, pouvoir principal, mutations.
- [ ] Définir l'interface d'assemblage de ces modules.
- [ ] Valider l'architecture sur les boss de biome et Gardiens existants (ils doivent être ré-exprimables comme combinaisons de modules) avant de produire le Miroir.
- [ ] Tests unitaires sur l'assemblage des modules.
- [ ] Auditer la couverture de tests des modules boss, compléter jusqu'à 85 %.

### Fait quand
Les boss existants fonctionnent via l'architecture modulaire. L'assemblage est testé et prêt pour la génération adaptative. Couverture ≥ 85 % sur les modules boss.

---

## Phase 9 — Miroir du Noyau (boss final adaptatif) → **Jalon J7**

**Scope arrêté : 2 paramètres** — biomes explorés + cicatrices accumulées. Le design doc en décrit 4 ; « boss vaincus » et « style de jeu » sont coupés de v3 → backlog post-v3. Le design doc est à aligner sur cette coupe.

### Tâches
- [ ] Génération du boss à partir des 2 paramètres (tracés dans `RunState`), sur l'architecture modulaire de R3.
- [ ] Déclenchement après le Gardien du Noyau (Biome 4).
- [ ] Recenser modules visuels combinables (corps, effets de pouvoir, mutations) dans `game_art/backlog_art.md`. **[game_art]**
- [ ] Tests : génération du boss à partir de paramètres de run donnés (déterminisme), combinaisons extrêmes (tous biomes/toutes cicatrices, aucun).

### Fait quand
Atteindre le Noyau génère un boss reflétant le parcours du run. Deux runs différents produisent deux boss différents. Tests de génération (déterminisme + cas extrêmes) verts. **J7.**

### Dépend de
Phases 6, 7, R3.

### Risques
Combinatoire de modules = risque de bugs/équilibrage. Limiter le nombre de modules au départ, étendre ensuite. Tester les combinaisons extrêmes.

---

## Phase 10 — Intégration, équilibrage, polish

### Tâches
- [ ] Équilibrage global (PC, coûts de maîtrise, difficulté biomes, escalade Gardiens, cicatrices — passe définitive, l'équilibrage des Phases 5/6 était provisoire).
- [ ] Boucle méta complète testée sur plusieurs runs.
- [ ] Passes audio/feedback.
- [ ] Remplacement des placeholders restants (piloté par `game_art/backlog_art.md`), cohérence visuelle globale. **[game_art]**

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

Tests : livrés à chaque phase, maintenus verts (non-régression) tout du long, cible 85 % de couverture sur la logique data-driven/état. Refacto : R1 (après 2), R1.5 (après 4), R2 (après 7), R3 (avant 9).

## Risques transverses majeurs

1. **Persistance de l'état de biome à la résurrection (Phase 5)** — À SURVEILLER : ne pas régénérer le biome au retour de l'Arène ; sérialiser/restaurer, couvrir par test dédié.
2. **Gardiens du Voile construits avant R2** — dette assumée (2-3 Gardiens simples max avant consolidation) ; R2 inclut leur factorisation.
3. **Volume d'art** — neutralisé par la règle placeholders + `game_art/backlog_art.md` ; game_art priorise selon le jalon jouable courant.
4. **Équilibrage de la boucle méta (Phase 10)** — nécessite des runs complets répétés ; l'équilibrage des cicatrices reste provisoire jusque-là.
5. **Dette inter-phases** — neutralisée par les jalons R1/R1.5/R2/R3 ; ne pas les sauter sous pression de contenu.
6. **Couverture de tests** — cible 85 % sur la logique data-driven/état, vérifiée à chaque jalon de refacto ; ne pas la laisser dériver sous pression de contenu.

## Backlog post-v3

Coupes assumées, à ne pas perdre :

- Miroir du Noyau — paramètre « boss vaincus » (héritage des pouvoirs des boss battus).
- Miroir du Noyau — paramètre « style de jeu » (tracking d'usage des armes → adaptation du boss).
- Pool complet de 8 Gardiens du Voile si non atteint en R2 (reliquat).
- Alignement du design doc sur le scope 2 paramètres du Miroir.
