# Roadmap v2.1 — Retours playtest & difficulté

*Roadmap active. L'ancienne roadmap v2 est archivée dans `archives/roadmap/roadmap_v2_core_dive_2026-06-25.md`.*

## Objectif de la v2.1

Corriger les retours de playtest avant de passer à la v3. Le jeu doit devenir plus difficile, plus tendu, et garder de la pression pendant tout le run, y compris autour de l'atelier.

La v2.1 ne doit pas lancer la génération procédurale, les nouveaux biomes ou le hub méta complet. Elle sert à solidifier le run actuel.

---

## Phase 1 — Difficulté générale

- [x] Augmenter la difficulté générale du run : ennemis, pression, dégâts, rythme ou coût des erreurs.
- [x] Vérifier que le jeu reste jouable sans devenir injuste.
- [ ] Tester un run complet après équilibrage.

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
- [ ] Vérifier qu'il reste battable avec une bonne préparation.
- [ ] Vérifier qu'il reste un vrai mur sans équipement correct.

**Jalon** : le boss redevient un test final crédible du run.

---

## Validation v2.1

- [ ] Run complet testé de bout en bout.
- [x] Difficulté validée.
- [x] Potions multiples validées.
- [x] Progression d'équipement validée.
- [x] Course validée.
- [x] Respawn mobs validé.
- [ ] Monnaie validée.
- [x] Boss validé.

**Jalon final** : v2.1 jouable avec une vraie tension de run, plusieurs soins possibles, une progression d'équipement propre, des ennemis qui maintiennent la pression, une monnaie fonctionnelle et un boss plus exigeant.

---

## Après la v2.1

- refacto complet de la codebase
- **v3 — Génération procédurale + hub méta** : génération du biome 1 et hub entre les runs avec monnaie persistante + déblocages.
- **v4 — Biomes 2 & 3 + Noyau** : contenu réplicable grâce au système de données par biome.
- **v5 — Polish** : art final, vrais sons/musique, équilibrage global.
