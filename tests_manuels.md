# Tests manuels — Flux Phase 2 + Menu titre/dev

Statut au 2026-07-11. Pré-requis : lancer via `run_game.py`, manette PowerA connectée.

Sections 1 à 4, 6 et 7 validées OK — retirées de ce fichier.

## 5. Maîtrise d'une recette non-starter — BLOQUÉ

5.1. Constat : le Grimoire n'affiche que les 7 recettes `starter`, toutes déjà maîtrisées. Aucune recette `Salle B1/B2/B3/B4`, `Porteur` ou `Victoire Gardien` n'apparaît.
5.2. Cause : `MetaState.discover_recipe()` (`game/scripts/meta_state.gd:26`) n'est appelé nulle part en jeu — seulement dans les tests GUT (`test_meta_state.gd`, `test_save_manager.gd`). Aucun trigger gameplay (salle, drop de porteur, victoire boss) ne l'appelle.
5.3. Conséquence : impossible de tester manuellement la maîtrise d'une recette non-starter tant que ce mécanisme n'est pas branché.

**Statut : bloqué — voir `_contexte/signals.md`.**

## 8. Équipement via pause

8.1 à 8.4 validés OK (dont correctif `equipment_menu.gd` : bug de compilation `SLOT_ORDER` non typé, puis reformatage de l'affichage équipé — nom lisible sur une seconde ligne au lieu de l'id brut collé au nom du slot ; ligne masquée pour `CONSOMMABLE`, redondante avec la liste).

Avec les crafts de l'étape 7 (`Epee en Bois`, `Armure en Bois`, `Torche` si crafté, `Petite Potion de Soin` x2), l'écran Équipement doit afficher exactement :

| Slot | Choix attendus |
|---|---|
| ARME | Aucun, Epee en Bois |
| ARMURE | Aucun, Armure en Bois |
| ACCESSOIRE | Aucun (seul choix — aucune recette starter n'a le slot `accessory`, c'est normal, pas un bug) |
| OUTIL | Aucun, Torche (si crafté) |
| CONSOMMABLE | Petite Potion de Soin x2 (si crafté à 7.7) |

8.5. Sur `ARMURE`, sélectionner `Armure en Bois` (haut/bas puis A) → vérifier que la seconde ligne sous `ARMURE` affiche le nom lisible `Armure en Bois` (pas un id du type `armure_bois`). Faire de même sur `OUTIL` avec `Torche` si crafté.

8.6. **BLOQUÉ — bug non résolu (2026-07-11), à corriger en urgence prochaine session.** Sur `CONSOMMABLE`, sélectionner `Petite Potion de Soin x2` et valider (Entrée/Espace/A) : aucun changement visible à l'écran, même après le correctif du marqueur `(actif)` sur la ligne active. Hypothèse à vérifier en premier : `RunState.add_consumable()` fixe déjà `active_consumable` dès le premier craft si aucun consommable n'était actif — avec un seul type de consommable en stock, il est peut-être déjà actif par défaut avant tout appui (le marqueur serait alors visible dès l'ouverture de l'écran, avant toute sélection). À tester : (1) le marqueur `(actif)` est-il déjà présent en arrivant sur `CONSOMMABLE`, avant tout appui ? (2) reproduire avec 2 types de consommables différents (ex. crafter aussi `Elixir de Resurgence` si débloqué, ou toute autre recette consommable) pour confirmer si le changement de sélection entre les deux fonctionne. Ne pas continuer 9.1-9.6 tant que ce point n'est pas éclairci : le comportement du consommable actif en jeu en dépend directement.
  réf: `game/scripts/equipment_menu.gd`, `game/scripts/run_state.gd`, `_contexte/signals.md` (Blocages)

8.7. Sur `ARMURE` (ou `OUTIL`), remonter sur `Aucun` → valider (A) → vérifier que la seconde ligne repasse à `-` et que l'effet en jeu disparaît (ex. protection perdue si applicable).
8.8. Fermer (B) → vérifier retour au menu pause, puis reprendre la partie (`Reprendre` ou équivalent) → jeu non figé.

## 9. HUD et consommable en jeu

`Petite Potion de Soin` soigne 3 PV (`consumables.json : "potion_petite": {"heal": 3}`). Le joueur a 6 PV max par défaut (`player.gd:25`) et démarre à PV pleins : **pour voir l'effet du soin, il faut d'abord perdre des PV** (se faire toucher par un ennemi, ou activer `VIE INF` à OFF et prendre un coup) — sinon le soin ne change rien visuellement (HP déjà au max), ce qui est normal et ne doit pas être pris pour un bug.

9.1. Avec `Petite Potion de Soin` sélectionnée comme consommable actif (étape 8.6), vérifier le label HUD en bas à gauche : `LB: POTION_PETITE x2` (ou nom équivalent affiché), en vert.
9.2. Encaisser un coup d'un ennemi pour descendre sous les PV max (vérifier la barre/compteur de vie du HUD baisser en conséquence).
9.3. Appuyer sur `use_item` (gâchette LB) → vérifier : les PV remontent de 3 (dans la limite du max), le compteur du HUD passe de `x2` à `x1`.
9.4. Réutiliser `use_item` → vérifier : nouveau soin de 3 PV, compteur passe de `x1` à `x0`, puis le label HUD revient à `LB: -` en gris (stock épuisé).
9.5. Appuyer une nouvelle fois sur `use_item` avec stock à 0 → vérifier qu'il ne se passe rien (pas d'erreur, pas de crash, PV inchangés).
9.6. Vérifier qu'aucune régression n'apparaît sur les affichages HUD existants (vie, matériaux) pendant toute la séquence.

---

**Critères de clôture** : chaque étape validée sans crash ni état incohérent. Anomalie → noter le numéro d'étape exact + comportement observé.
