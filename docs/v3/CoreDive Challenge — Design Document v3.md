# CoreDive Challenge — Design Document v3

---

## Précisions v3.1 (questions.md, 2026-07-06)

77 questions de conception (+ Q026b) ont été tranchées avant le lancement du développement. Ce document reste la référence de vision, mais les précisions suivantes corrigent ou complètent son contenu — voir `questions.md` à la racine du projet pour le détail exhaustif et les justifications.

- **Le run est multi-biomes** : le HUB fait partie du run (pas une gare entre deux runs séparés). Le joueur garde matériaux, équipement et cicatrices en circulant entre le HUB et les biomes. Un biome quitté est régénéré à la prochaine entrée.
- **Victoire du run = vaincre le Miroir du Noyau**, pas seulement le Gardien du Noyau. Le Gardien du Noyau (B4) seul suffit néanmoins à *ouvrir l'accès* au Miroir, sans prérequis d'avoir visité les autres biomes.
- **Pas de plafond de résurrections** ; l'escalade des Gardiens du Voile plafonne à ×2.5 à partir de la 5ᵉ mort. Des **planchers durs par stat** sont obligatoires dans `scars.json` pour éviter qu'un cumul de cicatrices sur de nombreuses résurrections ne rende le personnage inerte.
- **Mobilité du joueur** : déplacement, saut, double saut, corde/grappin (pas de dash). **Armes à distance ajoutées** en plus du mêlée, usage illimité sans munitions. **4 slots d'équipement** : arme (mêlée ou distance), armure, accessoire, outil.
- **Un seul Gardien du Voile implémenté au lancement** (Le Veilleur des Cendres) ; les 7 autres du pool de 8 sont ajoutés progressivement (refacto R2 de la roadmap).
- **Solo strict**, pas d'anticipation d'une coop future.
- Table de rareté des recettes réalignée : les cristaux restent liés au Biome 3, l'imagerie volcanique (Marteau Magmatique, Armure Volcanique) est réattribuée au Biome 4 (cohérent avec « roche en fusion »).

---

## Vision Générale

CoreDive Challenge est un jeu de plateforme/action roguelite en pixel art.

Le joueur descend vers le Noyau, une intelligence ancienne enfouie au cœur du monde. Il explore, récolte, fabrique et survit dans des biomes procéduraux. La mort n'est pas une fin — c'est une épreuve. Chaque run raconte une histoire unique faite de découvertes, de sacrifices et de transformations.

Liberté totale dès le début. Aucune progression forcée.

---

## Boucle de Jeu

```
Run
↓
Exploration libre (4 biomes accessibles dès le départ)
↓
Récolte de ressources + Découverte de recettes
↓
Craft d'équipements
↓
Combats et boss de biomes
↓
Mort éventuelle → Arène du Voile → Gardien du Voile
↓
Victoire : Résurrection + Cicatrice → Poursuite du run
Défaite : Fin du run → Gain de Points de Compétence → Déblocage recettes
↓
Atteindre le Noyau → Affronter le Miroir du Noyau
```

---

## Structure du Monde

Le monde s'organise autour d'un HUB central. Quatre biomes sont accessibles immédiatement depuis le départ. Le joueur choisit librement son ordre d'exploration.

```
             ↑
      Biome 3 : Îles Célestes (★★★)

Biome 2 ← HUB → Biome 1 : Galeries Verdoyantes (★)
Mines Obscures
(★★)
             ↓
      Biome 4 : Descente vers le Noyau (★★★★)
```

Chaque biome est généré procéduralement à chaque run. Les ressources principales sont garanties dans chaque biome — la procéduration ne peut pas priver le joueur des matériaux clés de sa région.

---

## Les Biomes

### Biome 1 — Galeries Verdoyantes (★)

**Direction :** droite  
**Ambiance :** cavernes peu profondes, végétation souterraine, racines géantes, lumière naturelle filtrante  
**Ressources :** bois, pierre, cuivre, cuir  
**Ennemis :** limaces, scarabées, chauves-souris, créatures végétales  
**Récompenses :** recettes de base, outils améliorés, premières armures  
**Boss : Le Gardien des Racines** — créature végétale ancestrale

---

### Biome 2 — Mines Obscures (★★)

**Direction :** gauche  
**Ambiance :** anciennes galeries abandonnées, tunnels effondrés, obscurité omniprésente, vestiges d'expéditions  
**Ressources :** fer, charbon, minerais renforcés  
**Ennemis :** mineurs spectraux, golems de pierre, araignées géantes, machines abandonnées  
**Récompenses :** armes intermédiaires, explosifs, armures lourdes  
**Boss : Le Foreur Maudit** — ancienne machine d'excavation devenue incontrôlable

---

### Biome 3 — Îles Célestes (★★★)

**Direction :** haut  
**Ambiance :** îles flottantes, ruines suspendues, vents violents, cristaux lumineux  
**Ressources :** cristaux, minerai céleste, essences de vent  
**Ennemis :** sentinelles volantes, élémentaires du vent, créatures célestes, gardiens cristallins  
**Récompenses :** équipements rares, outils de mobilité, recettes avancées  
**Boss : L'Orage Éternel** — entité vivant au cœur des tempêtes célestes

---

### Biome 4 — Descente vers le Noyau (★★★★)

**Direction :** bas  
**Ambiance :** roche en fusion, structures cyclopéennes, énergie du Noyau, anomalies du Voile  
**Ressources :** fragments du Noyau, minerais légendaires, essence du Voile  
**Ennemis :** revenants, gardiens du Noyau, créatures corrompues, manifestations du Voile  
**Récompenses :** équipement légendaire, recettes du Voile, matériaux ultimes  
**Boss : Le Gardien du Noyau** — protecteur ultime du cœur du monde

Vaincre le Gardien du Noyau ouvre l'accès au Miroir du Noyau — confrontation finale.

---

## Système de Craft

### Philosophie

```
Exploration → Découverte → Maîtrise → Fabrication
```

La connaissance est permanente. Les ressources ne le sont pas.

### Grimoire des Recettes

Toutes les recettes découvertes sont enregistrées dans un Grimoire conservé entre les runs. Une recette découverte apparaît comme « Découverte » — elle ne peut pas encore être utilisée. Le joueur investit des Points de Compétence pour la maîtriser définitivement.

### Points de Compétence (PC)

Monnaie méta persistante. Gagnés via :
- profondeur atteinte
- ennemis élites vaincus
- boss vaincus
- salles secrètes découvertes
- réussite d'un run

Même un run raté rapporte une partie des PC gagnés.

### Coûts de Maîtrise (exemples)

| Recette           | Coût  |
| ----------------- | ----- |
| Épée de Fer       | 2 PC  |
| Armure Renforcée  | 3 PC  |
| Bombe Instable    | 3 PC  |
| Lance Cristalline | 5 PC  |
| Armure du Noyau   | 10 PC |

### Recettes de Départ

Le joueur commence avec des recettes utilisables dès le premier run :

**Équipement :** Épée en Bois, Armure en Bois, Pioche Renforcée  
**Consommables :** Petite Potion de Soin  
**Utilitaires :** Torche, Corde, Établi Portable

### Porteurs de Recettes

Ennemis rares présents dans les biomes. Chaque type drop des catégories de recettes cohérentes avec son identité :

- **Archiviste Perdu** — recettes de potions, utilitaires, rares
- **Golem Artisan** — armes, armures, outils spéciaux
- **Mineur Spectral** — exploration, améliorations d'outils
- **Forgeron Maudit** — armes avancées, équipements rares, recettes uniques

Ces quatre ennemis rares ne sont pas présents dans tous les biomes — leur apparition est liée à la thématique du biome.

### Rareté des Recettes

**Table réalignée (questions.md Q042)** — les cristaux restent liés au Biome 3, l'imagerie volcanique est réattribuée au Biome 4 :

| Rareté    | Biome source    | Exemples                          |
| --------- | --------------- | --------------------------------- |
| Commune   | Biome 1         | Épée de Cuivre, Armure de Cuivre  |
| Peu commune / Rare | Biome 2 | Épée de Fer, Armure Renforcée, Bombe Instable |
| Épique    | Biome 3         | Lance Cristalline, Armure de Cristal |
| Épique/Légendaire | Biome 4 | Marteau Magmatique, Armure Volcanique |
| Légendaire| Noyau / Voile   | Lame du Noyau, Couronne Spectrale, Armure des Revenants |

Grimoire complet : 27 recettes définitives — table exhaustive (id, matériaux, coût PC, tier d'établi, source de découverte) dans `questions.md` Q043.

### Recettes du Voile

Obtenues uniquement après avoir affronté des Gardiens du Voile. Exploitent l'énergie des Cicatrices.

- **Lame Spectrale** — dégâts accrus contre créatures du Voile (Gardiens du Voile, Miroir du Noyau)
- **Anneau des Revenants** — atténue l'impact des malus de Cicatrices actives (ex. -50 % sur les modificateurs négatifs)
- **Élixir de Résurgence** — soin complet + bref buff de dégâts après une résurrection réussie

Effets précisés dans questions.md Q049.

### Établis

**3 tiers définitifs (questions.md Q046)** : tier 1 = Établi Portable (starter, repositionnable à volonté), recettes starters + Biome 1. Tier 2 = établi trouvé en Biome 2/3, débloque les recettes peu communes/rares de ces biomes. Tier 3 = établi trouvé en Biome 4/Voile, débloque les recettes épiques/légendaires et toutes les recettes du Voile/Noyau.

### Synergies Cross-Biomes

Certaines recettes puissantes requièrent des matériaux de plusieurs biomes, incitant le joueur à explorer des régions variées au cours d'un même run.

*Exemple — Épée Tempête du Noyau :* Fer (B2) + Cristaux (B3) + Fragment du Noyau (B4)

---

## Système de Mort et Résurrection

### Principe

Quand les PV atteignent zéro :

1. Le personnage meurt.
2. Il est convoqué dans l'Arène du Voile.
3. Un Gardien du Voile apparaît (tirage aléatoire).
4. Victoire → résurrection à l'endroit de la mort, PV restaurés, équipement conservé, une Cicatrice appliquée.
5. Défaite → run terminé définitivement.

Le joueur ne récupère pas son équipement. Il récupère son droit de vivre.

### L'Arène du Voile

Lieu unique dans tout le jeu. Plateforme suspendue dans le vide — ciel fracturé, étoiles mortes, fragments de biomes flottants, silhouettes d'anciens aventuriers. Identité visuelle forte, compréhension immédiate des règles.

### Les Gardiens du Voile

Arbitres de la frontière entre vie et mort. Ni maléfiques ni bienveillants — ils exercent leur fonction.

Les combats sont rapides, lisibles, exigeants, basés sur l'apprentissage.

**Pool de Gardiens :** Le Veilleur des Cendres, Le Roi Sans Visage, Le Collecteur d'Âmes, La Veuve du Vide, Le Dévoreur de Souvenirs, Le Porte-Flamme, Le Gardien des Os, L'Écho du Noyau

**Implémentation progressive (questions.md Q029)** : seul **Le Veilleur des Cendres** est construit au lancement du développement (charge, projectile de cendres, zone d'explosion retardée, pause vulnérable) ; les 7 autres sont ajoutés lors de la refacto R2, sur la même base factorisée. Tant que R2 n'est pas passé, chaque mort pioche donc le même Gardien — la variabilité du pool est un objectif de moyen terme, pas un prérequis du premier jalon jouable.

### Difficulté Croissante

| Mort | Niveau du Gardien       | Multiplicateur provisoire (Q031) |
| ---- | ----------------------- | --- |
| 1    | Simple                  | ×1.0 |
| 2    | Plus agressif           | ×1.3 |
| 3    | Nouveaux patterns       | ×1.6 |
| 4    | Difficile               | ×2.0 |
| 5+   | Niveau boss principaux  | ×2.5 (plafond, n'augmente plus au-delà) |

**Pas de plafond de résurrections (questions.md Q005)** : le joueur peut mourir et ressusciter indéfiniment tant qu'il bat le Gardien. L'escalade ci-dessus rend chaque résurrection supplémentaire plus difficile jusqu'au palier 5+, où elle plafonne — c'est la difficulté croissante, combinée aux planchers de cicatrices (ci-dessus), qui borne naturellement le nombre de résurrections viables, pas une règle d'interdiction.

---

## Les Cicatrices

### Concept

Chaque résurrection laisse une Cicatrice permanente pour la durée du run. Prix exigé par le Noyau pour autoriser le retour à la vie.

### Cicatrices de Gameplay

Liste définitive (questions.md Q026), avec clé de modificateur associée :

| Cicatrice          | Effet                                      | Clé de modificateur |
| ------------------ | ------------------------------------------ | --- |
| Cicatrice du Sang  | -10 % vie maximale                         | `max_hp_mult` |
| Cicatrice de l'Os  | Déplacement légèrement ralenti             | `speed_mult` |
| Cicatrice de l'Âme | Soins moins efficaces                      | `heal_mult` |
| Cicatrice de la Peur | Ennemis détectent plus rapidement        | `detection_mult` (nécessite un rayon de détection paramétrable sur les ennemis) |
| Cicatrice du Noyau | +20 % dégâts / -20 % vie maximale          | `attack_damage_mult` + `max_hp_mult` |

**Planchers durs obligatoires (questions.md Q026b)** : aucune résurrection n'étant plafonnée, un cumul de cicatrices identiques (au-delà des 5 types, doublons autorisés) doit être borné par des planchers par stat (ex. vitesse jamais sous 50 % de la base, PV max jamais sous 2, soin jamais sous 30 %), définis dans `scars.json`. Sans ce garde-fou, un joueur mourant de nombreuses fois se retrouverait avec un personnage totalement inerte bien avant que l'escalade des Gardiens (plafonnée à ×2.5) ne devienne le facteur limitant.

### Cicatrices Visuelles

Les effets visuels sont implémentés via **shaders et overlays de particules** — pas de refonte des spritesheets.

| Résurrection | Effets visuels                                        |
| ------------ | ----------------------------------------------------- |
| 1ère         | Yeux lumineux, particules spectrales discrètes        |
| 2ème         | Veines lumineuses, aura légère                        |
| 3ème         | Transparence partielle, effets spectraux permanents   |
| 4ème         | Cristallisation partielle, fragments flottants        |
| 5ème+        | Fissures lumineuses omniprésentes, silhouette altérée |

---

## Le Miroir du Noyau — Boss Final Adaptatif

### Concept

Le boss final n'est pas prédéfini. Le Noyau observe le joueur tout au long du run et génère une épreuve unique au moment de la confrontation.

**Condition de victoire du run (questions.md Q003/Q004/Q009)** : le bonus PC « réussite d'un run » n'est accordé qu'à la victoire contre le **Miroir**, pas seulement contre le Gardien du Noyau. Vaincre le Gardien du Noyau (B4) seul suffit à ouvrir l'accès au Miroir, sans prérequis d'avoir visité les biomes 1-3 — un Miroir généré avec un seul biome exploré et aucune cicatrice reste un combat valide. Après la victoire, écran de récapitulatif puis retour au HUB pour enchaîner un nouveau run (pas de New Game+, pas de fin définitive).

Le Miroir du Noyau est construit à partir de **2 paramètres principaux** :

### Paramètre 1 — Biomes Explorés

Chaque biome exploré influence les capacités du boss :

| Biome              | Capacités héritées                          |
| ------------------ | ------------------------------------------- |
| Galeries Verdoyantes | Racines, immobilisation, invocations végétales |
| Mines Obscures     | Armure renforcée, charges, explosions       |
| Îles Célestes      | Déplacement aérien, éclairs, cristaux       |
| Descente Noyau     | Énergie du Noyau, corruption, attaques de zone |

Plus un biome est exploré, plus son influence est importante.

### Paramètre 2 — Cicatrices Accumulées

Chaque Cicatrice ajoute une mutation au boss :

| Cicatrice          | Mutation boss                              |
| ------------------ | ------------------------------------------ |
| Cicatrice du Sang  | Attaques de saignement, agressivité accrue |
| Cicatrice de l'Os  | Résistance renforcée                       |
| Cicatrice de l'Âme | Réduction des soins du joueur, attaques spirituelles |
| Cicatrice de la Peur | Comportement plus agressif, poursuite renforcée |
| Cicatrice du Noyau | Puissance offensive très élevée, corruption |

### Architecture Modulaire

Le boss est assemblé depuis des modules réutilisables :

- **Corps :** Humanoïde / Golem / Spectre / Créature du Noyau
- **Déplacement :** Marche / Vol / Téléportation / Sauts améliorés
- **Pouvoir principal :** Racines / Foreuse / Tempête / Cristaux / Corruption
- **Mutations :** Rage / Drain de vie / Régénération / Bouclier spectral / Explosion

Cette architecture permet un grand nombre de variantes sans multiplier les boss uniques.

### Signature Narrative

> *Le Noyau t'a compris.*

Le joueur n'affronte pas un gardien. Il affronte le reflet de son propre run.

---

## Considérations de Production

### Scope Technique (priorités)

| Système               | Complexité | Priorité |
| --------------------- | ---------- | -------- |
| 4 biomes procéduraux  | Haute      | P0       |
| Craft + Grimoire      | Moyenne    | P0       |
| Arène du Voile        | Moyenne    | P0       |
| Gardiens du Voile (pool) | Haute   | P1       |
| Cicatrices gameplay   | Faible     | P0       |
| Cicatrices visuelles (shaders) | Faible | P1  |
| Boss biomes (4)       | Haute      | P1       |
| Miroir du Noyau       | Haute      | P2       |

### Règles de Développement

- Toutes les valeurs numériques (stats, timing, coûts PC) dans `game/data/*.json` — aucune constante hardcodée.
- Cicatrices visuelles = shaders + overlays uniquement. Zéro modification des spritesheets.
- Boss adaptatif (Miroir du Noyau) : architecture modulaire validée avant production des assets.
- Ressources garanties par biome : la génération procédurale ne peut pas bloquer l'accès aux matériaux clés.
- Porteurs de recettes (Archiviste, Golem, Mineur, Forgeron) : présence conditionnelle par biome, pas systématique.
- **Planchers durs par stat obligatoires dans `scars.json`** (questions.md Q026b) : le cumul de cicatrices sur des résurrections illimitées ne doit jamais rendre le personnage inerte.
- **4 slots d'équipement** (arme mêlée/distance, armure, accessoire, outil) — pas d'auto-équipement automatique, choix manuel du joueur.
- **Armes à distance à usage illimité**, pas de système de munitions.
- **Solo strict** : aucune architecture ne doit anticiper une coop future.
- Développement solo : voir `questions.md` à la racine du projet pour l'ensemble des décisions de cadrage (77 questions + Q026b, tranchées le 2026-07-06) avant tout arbitrage de contenu supplémentaire.
