# Roadmap v2.1 — Retours playtest & difficulté

*Roadmap active. L'ancienne roadmap v2 est archivée dans `archives/roadmap/roadmap_v2_core_dive_2026-06-25.md`.*

## Objectif de la v2.1

Corriger les retours de playtest avant de passer à la v3. Le jeu doit devenir plus difficile, plus tendu, et garder de la pression pendant tout le run, y compris autour de l'atelier.

La v2.1 ne doit pas lancer la génération procédurale, les nouveaux biomes ou le hub méta complet. Elle sert à solidifier le run actuel.

---

## Phase 1 — Difficulté générale

- [x] Augmenter la difficulté générale du run : ennemis, pression, dégâts, rythme ou coût des erreurs.
- [x] Vérifier que le jeu reste jouable sans devenir injuste.
- [x] Tester un run complet après équilibrage.

**Jalon** : le run demande plus d'attention et d'exécution, sans casser la boucle explore → récolte → craft → boss.

---

## Phase 2 — Potions multiples

- [x] Permettre d'avoir plusieurs potions de soin en stock.
- [x] Afficher clairement le nombre de potions disponibles dans le HUD.
- [x] Consommer une seule potion à chaque utilisation.
- [x] Réinitialiser le stock de potions à chaque nouveau run ou mort.

**Jalon** : le joueur peut préparer plusieurs soins avant le boss et les utiliser un par un.

---

## Phase 3 — Progression propre de l'équipement

- [x] Retirer de l'établi les armes déjà dépassées.
- [x] Après achat de l'épée cuivre, masquer ou désactiver l'épée bois.
- [x] Appliquer la même règle à toutes les futures améliorations d'arme.
- [ ] Étendre la logique aux armures si plusieurs paliers deviennent disponibles.

**Jalon** : l'établi ne propose plus d'améliorations obsolètes une fois un meilleur palier obtenu.

---

## Phase 4 — Course

- [x] Ajouter une action manette pour courir plus vite.
- [x] Ajouter le binding dans `game/scripts/joymap.gd`, pas dans `project.godot`.
- [x] Externaliser les valeurs de vitesse/endurance/timing dans `game/data/*.json`.
- [x] Vérifier que la course ne casse pas les sauts, collisions, combats ou limites caméra.

**Jalon** : le joueur peut accélérer ses déplacements avec un bouton dédié, de façon fiable à la manette.

---

## Phase 5 — Respawn des mobs

- [x] Faire respawn les ennemis pour éviter que le retour à l'atelier soit vide.
- [x] Définir les règles de respawn : délai, distance minimale du joueur, limite par zone.
- [x] Externaliser les valeurs de respawn dans `game/data/*.json`.
- [x] Éviter les respawns injustes directement sur le joueur.

**Jalon** : revenir vers l'atelier garde une pression ennemie sans spawn injuste.

---

## Phase 6 — Monnaie

- [x] Implémenter la monnaie du jeu.
- [x] Définir comment elle est gagnée pendant le run.
- [x] Afficher la monnaie dans le HUD.
- [x] Définir si elle est perdue à la mort en v2.1 ou conservée pour préparer la v3.

**Jalon** : la monnaie existe, elle est visible, gagnable et son comportement à la mort est explicite.

---

## Phase 7 — Boss plus difficile

- [x] Augmenter la difficulté du boss.
- [x] Ajuster ses PV, dégâts, rythme ou patterns.
- [x] Vérifier qu'il reste battable avec une bonne préparation.
- [x] Vérifier qu'il reste un vrai mur sans équipement correct.

**Jalon** : le boss redevient un test final crédible du run.

---

## Validation v2.1

- [x] Run complet testé de bout en bout.
- [x] Difficulté validée.
- [x] Potions multiples validées.
- [x] Progression d'équipement validée.
- [x] Course validée.
- [x] Respawn mobs validé.
- [x] Monnaie validée.
- [x] Boss validé.

**Jalon final** : v2.1 jouable avec une vraie tension de run, plusieurs soins possibles, une progression d'équipement propre, des ennemis qui maintiennent la pression, une monnaie fonctionnelle et un boss plus exigeant.

---

## Après la v2.1

- refacto complet de la codebase
- **v3 — Génération procédurale + hub méta** : génération du biome 1 et hub entre les runs avec monnaie persistante + déblocages.
- **v4 — Biomes 2 & 3 + Noyau** : contenu réplicable grâce au système de données par biome.
- **v5 — Polish** : art final, vrais sons/musique, équilibrage global.

---

## Chantier animation — Player puis mobs

### Diagnostic existant

- Le rendu des personnages repose actuellement sur des `Sprite2D` statiques.
- Le player possède déjà cinq images séparées :
  - `game/assets/sprites/player/player_idle.png` : 14x24
  - `game/assets/sprites/player/player_run1.png` : 14x24
  - `game/assets/sprites/player/player_run2.png` : 14x24
  - `game/assets/sprites/player/player_jump.png` : 14x24
  - `game/assets/sprites/player/player_attack.png` : 22x20
- Les mobs ont chacun une seule image statique :
  - `enemy_ground.png` : 16x16
  - `enemy_flyer.png` : 14x10
  - `boss_guardian.png` : 28x36
- Les scripts contiennent déjà les états gameplay exploitables pour l'animation :
  - player : idle, run, sprint, jump/fall, attack, hurt, dead
  - enemy ground : patrol, turn, hit_stun, dead
  - enemy flyer : hover, chase, hit_stun, dead
  - boss : sleep, idle, charge, volley, slam_rise, slam_fall, pause, hurt, dead
- Les hitboxes sont indépendantes des sprites. Les animations ne doivent pas modifier les collisions sans décision explicite.

### Process d'animation

1. Produire les frames une par une, comme pour le process sprite actuel. Ne pas générer de planche finale à découper.
2. Garder une taille stable par entité et par famille d'animation.
3. Nommer les fichiers avec un schéma déterministe :
   - `player_idle_01.png`
   - `player_run_01.png`
   - `player_run_02.png`
   - `enemy_ground_walk_01.png`
   - `boss_charge_01.png`
4. Stocker les frames finales dans :
   - `game/assets/sprites/player/`
   - `game/assets/sprites/enemies/`
5. Garder les images source ou références hors runtime dans `generated_raw/` et `from_reference/`.
6. Valider chaque frame avant intégration :
   - fond transparent propre ;
   - silhouette lisible à taille réelle ;
   - pieds ou point d'ancrage cohérents ;
   - pas de changement de hitbox induit ;
   - style cohérent avec la charte dark fantasy.
7. Intégrer les animations dans Godot via `AnimatedSprite2D` ou `SpriteFrames`, avec une couche script commune pour piloter l'état visuel.
8. Définir les vitesses d'animation dans JSON, pas en dur dans les scripts.
9. Tester en headless puis en jeu réel à la manette.

### Architecture cible

- Créer une couche commune `game/scripts/animation_driver.gd`.
- Rôle du driver :
  - recevoir un état logique simple (`idle`, `run`, `jump`, `attack`, `hurt`, etc.) ;
  - jouer l'animation correspondante si elle existe ;
  - conserver la dernière animation si aucun changement n'est nécessaire ;
  - gérer le flip horizontal sans toucher aux collisions ;
  - lire les vitesses depuis une configuration JSON.
- Le player, les mobs et le boss doivent seulement exposer leur état courant au driver.
- Les scripts gameplay ne doivent pas contenir de logique de frame ou de timer visuel spécifique.

### Plan d'action précis

- [x] Créer `game/data/animations.json` avec les vitesses et noms d'animations du player, des mobs et du boss.
- [x] Créer `game/scripts/animation_driver.gd`.
- [x] Remplacer le `Sprite2D` du player par une structure compatible animation, sans modifier les collisions.
- [x] Brancher les frames existantes du player :
  - idle : `player_idle`
  - run : alternance `player_run1` / `player_run2`
  - jump/fall : `player_jump`
  - attack : `player_attack`
- [x] Ajouter dans `player.gd` une fonction unique qui calcule l'état visuel à partir du gameplay actuel.
- [ ] Vérifier le player en jeu réel :
  - idle ;
  - course ;
  - sprint ;
  - saut ;
  - attaque ;
  - dégâts ;
  - mort ;
  - flip gauche/droite.
- [x] Étendre le même driver à `EnemyBase`.
- [ ] Ajouter les animations minimales du mob au sol :
  - walk ;
  - hurt ;
  - dead si la mort n'est plus instantanée.
- [ ] Ajouter les animations minimales du mob volant :
  - fly/hover ;
  - chase si visuellement distinct ;
  - hurt ;
  - dead si la mort n'est plus instantanée.
- [x] Étendre le driver au boss.
- [x] Mapper les états boss vers animations :
  - sleep ;
  - idle ;
  - charge ;
  - volley ;
  - slam_rise ;
  - slam_fall ;
  - pause ;
  - hurt ;
  - dead.
- [ ] Ajouter une scène ou commande de contrôle visuel pour afficher toutes les animations disponibles sans lancer un run complet.
- [ ] Valider :
  - `D:\Godot\godot.exe --headless --path game --quit`
  - `D:\Godot\godot.exe --headless --path game res://scenes/levels/biome1.tscn --quit-after 2`
  - test manuel manette en jeu réel.

### Risques à surveiller

- Le player a une frame d'attaque plus large que les autres images : il faudra préserver l'ancrage visuel pour éviter un déplacement apparent.
- Les mobs n'ont pas encore assez de frames pour de vraies animations : le driver doit accepter des animations à une seule frame.
- Le boss a des états riches mais une seule image : l'architecture doit être prête avant de produire toutes les frames boss.
- Ne pas mélanger timing gameplay et timing animation. Les durées d'attaque, invulnérabilité, stun et dégâts restent pilotées par les JSON gameplay existants.
