# CoreDive Challenge — Design Document v3

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

| Rareté    | Biome source    | Exemples                          |
| --------- | --------------- | --------------------------------- |
| Commune   | Biome 1         | Épée de Cuivre, Armure de Cuivre  |
| Rare      | Biome 2         | Lance Cristalline, Armure Cristal |
| Épique    | Biome 3         | Marteau Magmatique, Armure Volcanique |
| Légendaire| Noyau / Voile   | Lame du Noyau, Armure des Revenants |

### Recettes du Voile

Obtenues uniquement après avoir affronté des Gardiens du Voile. Exploitent l'énergie des Cicatrices.

- **Lame Spectrale** — dégâts accrus contre créatures du Voile
- **Anneau des Revenants** — améliore certains effets de Cicatrices
- **Élixir de Résurgence** — bonus temporaire après résurrection

### Établis

La fabrication nécessite un établi trouvé dans les biomes, construit via recette, ou placé dans une salle spéciale. Les objets légendaires exigent des établis avancés.

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

Chaque mort pioche aléatoirement dans ce pool — la rencontre reste imprévisible.

### Difficulté Croissante

| Mort | Niveau du Gardien       |
| ---- | ----------------------- |
| 1    | Simple                  |
| 2    | Plus agressif           |
| 3    | Nouveaux patterns       |
| 4    | Difficile               |
| 5+   | Niveau boss principaux  |

Objectif : empêcher les résurrections infinies tout en laissant plusieurs chances.

---

## Les Cicatrices

### Concept

Chaque résurrection laisse une Cicatrice permanente pour la durée du run. Prix exigé par le Noyau pour autoriser le retour à la vie.

### Cicatrices de Gameplay

| Cicatrice          | Effet                                      |
| ------------------ | ------------------------------------------ |
| Cicatrice du Sang  | -10 % vie maximale                         |
| Cicatrice de l'Os  | Déplacement légèrement ralenti             |
| Cicatrice de l'Âme | Soins moins efficaces                      |
| Cicatrice de la Peur | Ennemis détectent plus rapidement        |
| Cicatrice du Noyau | +20 % dégâts / -20 % vie maximale          |

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
