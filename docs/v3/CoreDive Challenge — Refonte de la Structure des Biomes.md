# CoreDive Challenge — Refonte de la Structure des Biomes

## Vision

Afin d'augmenter la liberté d'exploration, la rejouabilité et l'aspect découverte, CoreDive Challenge abandonne une progression strictement linéaire des biomes.

Le joueur débute au sein d'une zone centrale et peut accéder immédiatement aux quatre grandes régions du monde.

Chaque biome possède sa propre identité visuelle, ses ressources exclusives, ses recettes uniques, ses ennemis et son boss.

Le joueur choisit librement son ordre d'exploration, mais la difficulté augmente naturellement selon les régions.

L'objectif reste inchangé :

> Explorer, se préparer, fabriquer son équipement et atteindre le Noyau.

---

# Structure Générale du Monde

Le monde est organisé autour d'un point de départ central.

Depuis cette zone, quatre directions sont accessibles :

```text
             ↑
      Biome 3 : Ciel

Biome 2 ← HUB → Biome 1

             ↓
      Biome 4 : Noyau
```

Chaque biome est généré procéduralement à chaque run.

Les biomes sont indépendants et peuvent être explorés dans n'importe quel ordre.

---

# Philosophie de Conception

Le jeu ne force jamais le joueur à suivre un chemin précis.

La progression repose sur :

* la curiosité ;
* la prise de risque ;
* l'acquisition de ressources ;
* la maîtrise du craft ;
* l'amélioration progressive du personnage.

Comme dans Terraria ou Elden Ring, certaines zones sont accessibles immédiatement mais deviennent beaucoup plus faciles après avoir obtenu un meilleur équipement.

---

# Ordre Naturel de Difficulté

Même si tous les biomes sont accessibles dès le départ, leur difficulté est conçue selon l'ordre suivant :

| Difficulté | Biome                            |
| ---------- | -------------------------------- |
| ★          | Biome 1 — Galeries Verdoyantes   |
| ★★         | Biome 2 — Mines Obscures         |
| ★★★        | Biome 3 — Îles Célestes          |
| ★★★★       | Biome 4 — Descente vers le Noyau |

Le joueur est libre de briser cette progression.

Un joueur expérimenté pourra tenter des stratégies risquées afin d'obtenir rapidement des ressources rares.

---

# Biome 1 — Galeries Verdoyantes

## Direction

Vers la droite.

## Rôle

Biome d'introduction.

Permet d'obtenir les premières améliorations d'équipement.

## Ambiance

* cavernes peu profondes ;
* végétation souterraine ;
* racines géantes ;
* lumière naturelle filtrante.

## Ressources principales

* bois ;
* pierre ;
* cuivre ;
* cuir.

## Types d'ennemis

* limaces ;
* scarabées ;
* chauves-souris ;
* créatures végétales.

## Récompenses

* recettes de base ;
* outils améliorés ;
* premières armures.

## Boss

### Le Gardien des Racines

Créature végétale ancestrale protégeant l'accès aux ressources du biome.

---

# Biome 2 — Mines Obscures

## Direction

Vers la gauche.

## Rôle

Premier véritable palier de difficulté.

Accent mis sur le combat et l'exploration dangereuse.

## Ambiance

* anciennes galeries abandonnées ;
* tunnels effondrés ;
* obscurité omniprésente ;
* vestiges d'anciennes expéditions.

## Ressources principales

* fer ;
* charbon ;
* minerais renforcés.

## Types d'ennemis

* mineurs spectraux ;
* golems de pierre ;
* araignées géantes ;
* machines abandonnées.

## Récompenses

* armes intermédiaires ;
* explosifs ;
* armures lourdes.

## Boss

### Le Foreur Maudit

Ancienne machine d'excavation devenue incontrôlable.

---

# Biome 3 — Îles Célestes

## Direction

Vers le haut.

## Rôle

Biome avancé orienté mobilité et exploration.

## Ambiance

* îles flottantes ;
* ruines suspendues ;
* vents violents ;
* cristaux lumineux.

## Ressources principales

* cristaux ;
* minerai céleste ;
* essences de vent.

## Types d'ennemis

* sentinelles volantes ;
* élémentaires du vent ;
* créatures célestes ;
* gardiens cristallins.

## Récompenses

* équipements rares ;
* outils de mobilité ;
* recettes avancées.

## Boss

### L'Orage Éternel

Entité vivant au cœur des tempêtes célestes.

---

# Biome 4 — Descente vers le Noyau

## Direction

Vers le bas.

## Rôle

Zone finale du jeu.

Point culminant de chaque run.

## Ambiance

* roche en fusion ;
* structures cyclopéennes ;
* énergie du Noyau ;
* anomalies du Voile.

## Ressources principales

* fragments du Noyau ;
* minerais légendaires ;
* essence du Voile.

## Types d'ennemis

* revenants ;
* gardiens du Noyau ;
* créatures corrompues ;
* manifestations du Voile.

## Récompenses

* équipement légendaire ;
* recettes du Voile ;
* matériaux ultimes.

## Boss

### Le Gardien du Noyau

Protecteur ultime du cœur du monde.

Le vaincre marque la réussite du run.

---

# Conséquences sur le Craft

Chaque biome possède des ressources exclusives.

Certaines recettes nécessitent des matériaux provenant de plusieurs biomes.

Exemple :

Épée Tempête du Noyau :

* Fer (Biome 2)
* Cristaux (Biome 3)
* Fragment du Noyau (Biome 4)

Le joueur est donc encouragé à explorer plusieurs régions durant un même run.

---

# Conséquences sur la Rejouabilité

Cette structure permet :

* des routes d'exploration variées ;
* des stratégies différentes selon les runs ;
* des prises de risque calculées ;
* une meilleure sensation de liberté ;
* davantage de découvertes.

Deux runs successifs peuvent être totalement différents malgré un objectif final identique.

---

# Avantages de cette Structure

* Plus proche de l'esprit Terraria et Hollow Knight.
* Liberté totale dès le début du run.
* Rejouabilité accrue.
* Forte cohérence avec le système de recettes.
* Favorise l'exploration et la curiosité.
* Compatible avec la génération procédurale.
* Encourage les joueurs expérimentés à tenter des routes optimisées.
* Maintient un objectif final clair : atteindre et vaincre le Gardien du Noyau.
