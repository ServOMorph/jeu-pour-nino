# CoreDive Challenge — Le Noyau et le Boss Final Adaptatif

## Vision

Dans la majorité des roguelites et jeux d'action, le boss final est toujours le même.

Après plusieurs parties, le joueur apprend ses attaques, mémorise ses patterns et finit par répéter une stratégie optimisée.

CoreDive Challenge adopte une philosophie différente.

Le Noyau ne possède pas de forme propre.

Il observe le joueur tout au long du run.

Lorsque celui-ci atteint enfin les profondeurs ultimes, le Noyau crée une épreuve unique façonnée à partir des choix réalisés pendant l'expédition.

Ainsi, le boss final n'est jamais exactement le même d'un run à l'autre.

Le joueur affronte la synthèse de son aventure.

---

# Concept Narratif

Le Noyau est une intelligence ancienne enfouie au cœur du monde.

Depuis les profondeurs, il observe :

* les lieux explorés ;
* les ennemis vaincus ;
* les équipements fabriqués ;
* les résurrections obtenues ;
* les Cicatrices accumulées.

Lorsque l'aventurier atteint enfin le Noyau, celui-ci juge son parcours.

Il façonne alors une incarnation destinée à tester sa valeur.

Le boss final n'existe donc pas avant l'arrivée du joueur.

Il est créé au moment même de la rencontre.

---

# Philosophie du Système

Le boss final doit représenter :

* les choix du joueur ;
* son style de jeu ;
* les risques qu'il a pris ;
* les sacrifices qu'il a acceptés.

Le combat final devient ainsi le résumé du run.

Chaque victoire raconte une histoire différente.

---

# Le Miroir du Noyau

Nom de travail du boss final.

Lorsque le joueur pénètre dans l'arène finale, le Noyau analyse son parcours.

Le boss est alors généré à partir de plusieurs paramètres.

---

# Paramètre 1 — Les Biomes Explorés

Chaque biome influence les pouvoirs du boss.

## Galeries Verdoyantes

Le boss peut obtenir :

* attaques de racines ;
* invocations végétales ;
* capacités d'immobilisation.

## Mines Obscures

Le boss peut obtenir :

* armure renforcée ;
* attaques explosives ;
* charges brutales.

## Îles Célestes

Le boss peut obtenir :

* déplacement aérien ;
* éclairs ;
* projectiles cristallins.

## Descente vers le Noyau

Le boss peut obtenir :

* énergie du Noyau ;
* corruption ;
* attaques de zone majeures.

Plus le joueur a exploré un biome, plus son influence est importante.

---

# Paramètre 2 — Les Boss Vaincus

Chaque boss battu transmet une partie de son pouvoir au Miroir du Noyau.

## Gardien des Racines

* lianes ;
* pièges végétaux ;
* attaques de contrôle.

## Foreur Maudit

* foreuses ;
* charges ;
* explosions.

## Orage Éternel

* tempêtes ;
* éclairs ;
* mobilité élevée.

## Boss du Noyau

Influence maximale sur la phase finale du combat.

Le résultat peut être une combinaison de plusieurs héritages.

---

# Paramètre 3 — Les Cicatrices

Les résurrections modifient directement l'épreuve finale.

Le Noyau considère les Cicatrices comme des marques de transformation.

Chaque Cicatrice peut ajouter une mutation au boss.

## Cicatrice du Sang

* dégâts de saignement ;
* attaques agressives.

## Cicatrice de l'Os

* résistance accrue ;
* réduction des effets de contrôle.

## Cicatrice de l'Âme

* réduction des soins ;
* attaques spirituelles.

## Cicatrice de la Peur

* comportement plus agressif ;
* poursuite renforcée.

## Cicatrice du Noyau

* attaques corrompues ;
* puissance offensive très élevée.

Plus le joueur est revenu d'entre les morts, plus l'épreuve devient difficile.

---

# Paramètre 4 — Le Style de Jeu

Le Noyau analyse également les habitudes du joueur.

## Utilisation fréquente d'armes lourdes

Le boss devient :

* plus robuste ;
* plus lent ;
* plus destructeur.

## Utilisation fréquente d'armes rapides

Le boss devient :

* plus mobile ;
* plus agressif ;
* plus imprévisible.

## Utilisation fréquente d'armes à distance

Le boss développe :

* des projectiles ;
* des attaques de zone ;
* des capacités de harcèlement.

## Utilisation importante des explosifs

Le boss obtient :

* explosions ;
* zones dangereuses ;
* attaques environnementales.

Le combat final reflète alors la manière dont le joueur a choisi de progresser.

---

# Architecture Modulaire

Afin de rester compatible avec un développement solo, le boss est construit à partir de modules réutilisables.

## Type de Corps

Exemples :

* Humanoïde
* Golem
* Spectre
* Créature du Noyau

---

## Mode de Déplacement

Exemples :

* Marche
* Vol
* Téléportation
* Sauts améliorés

---

## Pouvoir Principal

Exemples :

* Racines
* Foreuse
* Tempête
* Cristaux
* Corruption du Noyau

---

## Mutations

Exemples :

* Rage
* Drain de vie
* Régénération
* Bouclier spectral
* Explosion de corruption

---

Cette structure permet de générer un très grand nombre de variantes sans créer des dizaines de boss uniques.

---

# Objectifs de Design

Le système doit :

* empêcher la routine des boss finaux classiques ;
* renforcer la rejouabilité ;
* valoriser les choix du joueur ;
* donner du sens aux Cicatrices ;
* créer une forte identité pour CoreDive ;
* générer des histoires différentes à chaque run.

---

# Signature Narrative

Le boss final n'est pas un simple gardien.

Il est l'incarnation du parcours du joueur.

Le Noyau ne cherche pas à savoir si le joueur est puissant.

Il cherche à savoir ce qu'il est devenu.

Le combat final devient alors une confrontation avec la synthèse de toutes les décisions prises pendant l'expédition.

Lorsque le boss apparaît, le jeu peut afficher :

> Le Noyau t'a compris.

ou

> L'épreuve a pris ta forme.

Ces phrases résument la philosophie du système :

Le joueur n'affronte pas un ennemi prédéfini.

Il affronte le reflet de son propre voyage.
