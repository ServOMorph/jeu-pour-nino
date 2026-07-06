# CoreDive Challenge — Système de Progression, Craft, Mort et Résurrection

## Précisions v3.1 (questions.md, 2026-07-06)

- **Le run est multi-biomes** : le HUB fait partie du run (pas une étape entre deux runs séparés). Le joueur garde matériaux, équipement et cicatrices en circulant entre HUB et biomes ; un « nouveau run » (reset complet) n'a lieu qu'au lancement depuis le titre.
- **Pas de plafond de résurrections.** L'escalade des Gardiens plafonne à ×2.5 à partir de la 5ᵉ mort. Des planchers durs par stat (`scars.json`) empêchent un cumul de cicatrices de rendre le personnage inerte.
- **Un seul Gardien du Voile implémenté au lancement** (Le Veilleur des Cendres) ; les 7 autres sont ajoutés progressivement.
- Sections « Biome 2 — Profondeurs Cristallines » et « Biome 3 — Approches du Noyau » ci-dessous utilisent d'anciens noms de biomes, conservés tels quels dans ce document historique mais **remplacés par Mines Obscures (B2) et Îles Célestes (B3)** dans toute implémentation — voir le Design Document v3 et `docs/v3/CoreDive Challenge — Refonte de la Structure des Biomes.md` pour les noms définitifs.
- Table de rareté réalignée : cristaux → Biome 3 (Îles Célestes), imagerie volcanique → Biome 4 (Descente vers le Noyau).

Référence complète : `questions.md` à la racine du projet.

## Vision Générale

CoreDive Challenge repose sur une boucle de progression où l'exploration, la découverte, la fabrication et la survie sont intimement liées.

Le joueur descend toujours plus profondément vers le Noyau afin de découvrir des technologies oubliées, récolter des ressources rares, fabriquer de nouveaux équipements et affronter des dangers de plus en plus importants.

La mort n'est pas simplement une sanction. Elle devient une mécanique centrale du gameplay, intégrée à la progression du personnage et à la narration du jeu.

Le système repose sur quatre piliers :

* Récolter des ressources durant les runs.
* Découvrir de nouvelles recettes en explorant le monde.
* Débloquer définitivement ces recettes grâce aux Points de Compétence.
* Surmonter la mort en affrontant les Gardiens du Voile au prix de Cicatrices permanentes pour le reste du run.

L'objectif est de créer une progression permanente sans empêcher le joueur de profiter immédiatement du craft dès sa première partie.

---

# Philosophie Générale

Dans la plupart des roguelites :

Monnaie → Achat d'améliorations

Mort → Fin du run

Dans CoreDive :

Exploration → Découverte → Maîtrise → Fabrication

Mort → Jugement → Résurrection potentielle

Le joueur ne progresse pas uniquement en augmentant artificiellement ses statistiques.

Il progresse en découvrant, maîtrisant et utilisant des technologies oubliées enfouies sous terre tout en survivant aux épreuves imposées par le Voile.

Chaque run raconte ainsi une histoire unique faite de découvertes, de fabrications, de combats et de sacrifices.

---

# Boucle de Progression Globale

Run

↓

Exploration

↓

Récolte de ressources

↓

Découverte de recettes

↓

Craft d'équipements

↓

Combats

↓

Mort éventuelle

↓

Arène du Voile

↓

Combat contre un Gardien

↓

Victoire

↓

Résurrection + Cicatrice

↓

Poursuite du run

OU

↓

Défaite

↓

Fin du run

↓

Gain de Points de Compétence

↓

Déblocage de nouvelles recettes

↓

Nouveau run

↓

Progression vers le Noyau

---

# Le Grimoire des Recettes

## Concept

Toutes les recettes découvertes sont enregistrées dans un Grimoire permanent.

Le Grimoire est conservé entre les runs.

Il représente les connaissances accumulées par le joueur au cours de ses tentatives d'atteindre le Noyau.

---

## Fonctionnement

Lorsqu'une recette est trouvée :

* elle est ajoutée au Grimoire ;
* elle apparaît comme « Découverte » ;
* elle ne peut pas encore être utilisée.

Le joueur devra ensuite investir des Points de Compétence afin de la maîtriser définitivement.

---

# Les Points de Compétence

## Concept

Les Points de Compétence (PC) remplacent l'or comme système principal de progression méta.

Ils représentent l'expérience acquise lors des expéditions.

Ils sont conservés définitivement.

---

## Obtention

Les Points de Compétence sont gagnés grâce à :

* la profondeur atteinte ;
* les ennemis élites vaincus ;
* les boss vaincus ;
* les événements spéciaux ;
* les salles secrètes découvertes ;
* la réussite d'un run.

Même une tentative ratée rapporte une partie des Points de Compétence gagnés.

Chaque run contribue donc à la progression globale.

---

# Déblocage des Recettes

Chaque recette possède un coût de maîtrise.

| Recette           | Coût  |
| ----------------- | ----- |
| Épée de Fer       | 2 PC  |
| Armure Renforcée  | 3 PC  |
| Bombe Instable    | 3 PC  |
| Lance Cristalline | 5 PC  |
| Armure du Noyau   | 10 PC |

Une fois le coût payé :

* la recette devient permanente ;
* elle peut être utilisée dans tous les futurs runs ;
* aucun autre coût de déblocage n'est nécessaire.

---

# Recettes de Départ

Le joueur débute avec quelques recettes basiques afin de profiter du système de craft dès son premier run.

## Équipement de base

* Épée en Bois
* Armure en Bois
* Pioche Renforcée

## Consommables de base

* Petite Potion de Soin

## Utilitaires de base

* Torche
* Corde
* Établi Portable

---

# Découverte des Recettes

## Principe

Les recettes sont découvertes directement dans les biomes.

Le joueur doit explorer et affronter certains ennemis pour enrichir son Grimoire.

Chaque découverte représente une récompense importante.

---

# Porteurs de Recettes

Certaines créatures rares possèdent des plans oubliés.

## Archiviste Perdu

Ancien érudit ayant sombré dans la folie.

Peut laisser tomber :

* recettes de potions ;
* recettes utilitaires ;
* recettes rares.

## Golem Artisan

Gardien de technologies anciennes.

Peut laisser tomber :

* armes ;
* armures ;
* outils spéciaux.

## Mineur Spectral

Explorateur mort dans les profondeurs.

Peut laisser tomber :

* recettes liées à l'exploration ;
* améliorations d'outils.

## Forgeron Maudit

Ancien maître artisan corrompu par le Noyau.

Peut laisser tomber :

* armes avancées ;
* équipements rares ;
* recettes uniques.

---

# Rareté des Recettes

**Table réalignée (questions.md Q042)** — corrige la version précédente qui plaçait la Lance Cristalline au second biome et l'imagerie volcanique au troisième.

## Commune

Objets du premier biome (Galeries Verdoyantes).

Exemples :

* Épée de Cuivre
* Armure de Cuivre

## Peu commune / Rare

Objets du second biome (Mines Obscures).

Exemples :

* Épée de Fer
* Armure Renforcée
* Bombe Instable

## Épique

Objets du troisième biome (Îles Célestes) — les cristaux restent liés à ce biome.

Exemples :

* Lance Cristalline
* Armure de Cristal

## Épique / Légendaire

Objets du quatrième biome (Descente vers le Noyau) — l'imagerie volcanique (« roche en fusion ») est réattribuée ici plutôt qu'aux Îles Célestes.

Exemples :

* Marteau Magmatique
* Armure Volcanique

## Légendaire

Objets liés au Noyau et au Voile.

Exemples :

* Lame du Noyau
* Couronne Spectrale
* Armure des Revenants

Grimoire complet : 27 recettes définitives, table exhaustive dans `questions.md` Q043.

---

# Fabrication Pendant les Runs

Les recettes débloquées sont utilisables durant les runs.

Le joueur doit toujours trouver les matériaux nécessaires.

La connaissance est permanente.

Les ressources ne le sont pas.

## Exemple

Le joueur possède la recette de la Lance Cristalline.

Durant un run il doit encore trouver :

* 10 minerais de Fer ;
* 5 Cristaux.

Une fois les matériaux obtenus et un établi trouvé, il peut fabriquer l'objet.

---

# Les Établis

La fabrication nécessite généralement un établi.

Les établis peuvent être :

* trouvés dans les biomes ;
* construits grâce à certaines recettes ;
* placés dans des salles spéciales.

Les objets les plus puissants nécessitent parfois des établis avancés.

---

# Intégration aux Biomes

Chaque biome possède :

* ses ressources ;
* ses recettes ;
* ses ennemis porteurs de recettes.

## Biome 1 — Galeries de Surface

Découverte de recettes simples :

* cuivre ;
* cuir ;
* outils basiques.

## Biome 2 — Profondeurs Cristallines

Découverte de recettes intermédiaires :

* cristaux ;
* gadgets ;
* équipements spécialisés.

## Biome 3 — Approches du Noyau

Découverte de recettes avancées :

* équipements volcaniques ;
* armes rares ;
* artefacts puissants.

## Le Noyau

Source des recettes légendaires.

Les plans les plus puissants du jeu peuvent être trouvés ici.

---

# Le Voile et les Recettes du Voile

Certaines technologies dépassent les connaissances des vivants.

Elles sont liées au Voile, à la mort et aux Cicatrices.

Ces recettes ne peuvent être obtenues qu'après avoir affronté les Gardiens du Voile.

## Exemples

### Lame Spectrale

Inflige davantage de dégâts aux créatures du Voile (Gardiens du Voile, Miroir du Noyau).

### Anneau des Revenants

**Effet précisé (questions.md Q049)** : atténue l'impact des malus de Cicatrices actives (ex. -50 % sur les valeurs des modificateurs négatifs), appliqué avant clamp aux planchers durs.

### Élixir de Résurgence

**Effet précisé (questions.md Q049)** : soin complet + bref buff de dégâts après une résurrection réussie.

---

# Système de Mort et de Résurrection

## Vision

Dans CoreDive Challenge, la mort ne constitue pas immédiatement la fin d'un run.

Le joueur reçoit une ultime chance de poursuivre sa descente vers le Noyau.

Cette seconde chance n'est cependant jamais gratuite.

Chaque retour parmi les vivants exige de vaincre un Gardien du Voile et laisse une marque permanente sur le personnage.

L'objectif est de transformer la mort en une mécanique centrale du gameplay plutôt qu'en un simple écran de Game Over.

---

# Objectifs du Système de Mort

Le système doit :

* réduire la frustration liée à la perte d'un run avancé ;
* préserver l'importance du challenge ;
* créer des moments mémorables ;
* renforcer l'identité de CoreDive ;
* donner une signification narrative à la mort ;
* créer une progression émotionnelle au sein d'un run ;
* faire de chaque résurrection une décision et une victoire.

---

# Principe Général

Lorsque les points de vie du joueur atteignent zéro :

1. Le personnage meurt dans le monde réel.
2. Son âme est arrachée à son corps.
3. Il est convoqué dans l'Arène du Voile.
4. Un Gardien du Voile apparaît.
5. Le joueur doit le vaincre.
6. En cas de victoire, il ressuscite.
7. En cas de défaite, le run prend fin définitivement.

Le joueur conserve :

* son équipement ;
* ses ressources ;
* ses objets ;
* sa progression dans le run.

L'épreuve ne consiste pas à récupérer son équipement mais à récupérer son droit de vivre.

---

# L'Arène du Voile

## Concept

L'Arène du Voile est un lieu situé entre le monde des vivants et celui des morts.

Tous les joueurs s'y rendent lorsqu'ils meurent.

Il n'existe qu'une seule Arène du Voile dans tout le jeu.

Cette décision permet :

* une forte identité visuelle ;
* une compréhension immédiate des règles ;
* un développement raisonnable ;
* un focus sur la qualité des combats.

## Direction Artistique

L'arène doit donner l'impression d'un tribunal cosmique.

Pistes visuelles :

* plateforme circulaire suspendue dans le vide ;
* ciel fracturé ;
* étoiles mortes ;
* fragments des différents biomes flottant autour ;
* silhouettes d'anciens aventuriers ;
* immense faille lumineuse menant vers le Noyau.

---

# Les Gardiens du Voile

## Rôle

Les Gardiens du Voile sont les arbitres de la frontière entre la vie et la mort.

Ils décident quelles âmes peuvent revenir parmi les vivants.

Ils ne sont pas forcément maléfiques.

Ils accomplissent simplement leur fonction.

## Philosophie des Combats

Les combats doivent être :

* rapides ;
* lisibles ;
* exigeants ;
* basés sur l'apprentissage.

Le joueur doit pouvoir :

* observer ;
* comprendre ;
* s'adapter ;
* progresser.

## Exemples de Gardiens

* Le Veilleur des Cendres
* Le Roi Sans Visage
* Le Collecteur d'Âmes
* La Veuve du Vide
* Le Dévoreur de Souvenirs
* Le Porte-Flamme
* Le Gardien des Os
* L'Écho du Noyau

Les rencontres sont choisies aléatoirement. **Implémentation progressive (questions.md Q029)** : seul Le Veilleur des Cendres est construit au lancement du développement ; les 7 autres sont ajoutés lors de la refacto R2 de la roadmap, sur la même base factorisée (`guardian.gd` paramétré, jamais de copier-coller de `boss.gd`).

Le joueur entre dans l'Arène avec ses **PV restaurés à plein** et son consommable équipé utilisable (questions.md Q030) — le combat n'est jamais entamé à PV critiques.

---

# Difficulté Croissante

Chaque résurrection augmente la puissance des futurs Gardiens.

* Première mort : combat simple (×1.0).
* Deuxième mort : plus agressif (×1.3).
* Troisième mort : nouveaux patterns (×1.6).
* Quatrième mort : combat difficile (×2.0).
* Cinquième mort et plus : niveau proche des boss principaux (×2.5, plafond — n'augmente plus au-delà).

Multiplicateurs provisoires, questions.md Q031 — équilibrage définitif en Phase 10.

**Précision (questions.md Q005) : pas de plafond de résurrections.** Le joueur peut mourir et ressusciter indéfiniment tant qu'il bat le Gardien. L'escalade ci-dessus ne « empêche » jamais une résurrection — elle la rend seulement de plus en plus difficile jusqu'à son plafond (×2.5), combinée aux planchers durs de cicatrices qui évitent qu'un personnage cumulant de nombreuses résurrections ne devienne totalement inerte.

---

# Les Cicatrices

## Concept

Chaque résurrection laisse une marque sur le personnage.

Cette marque est appelée Cicatrice.

Les Cicatrices représentent le prix exigé par le Noyau pour autoriser un retour à la vie.

Elles persistent jusqu'à la fin du run.

## Objectifs

Les Cicatrices doivent :

* donner un coût à la résurrection ;
* modifier le gameplay ;
* raconter l'histoire du run ;
* personnaliser chaque partie.

---

# Cicatrices de Gameplay

Liste définitive (questions.md Q026), avec clé de modificateur associée dans `scars.json` :

## Cicatrice du Sang

-10 % de vie maximale. (`max_hp_mult: 0.9`)

## Cicatrice de l'Os

Déplacement légèrement ralenti. (`speed_mult`)

## Cicatrice de l'Âme

Les soins sont moins efficaces. (`heal_mult` — nouvelle clé)

## Cicatrice de la Peur

Les ennemis détectent plus rapidement le joueur. (`detection_mult` — nouvelle clé, nécessite un rayon de détection paramétrable sur les ennemis, `enemies.json`/`enemy_base.gd`)

## Cicatrice du Noyau

+20 % dégâts. (`attack_damage_mult: 1.2`)

-20 % vie maximale. (`max_hp_mult: 0.8`)

## Planchers durs (questions.md Q026b)

Aucune résurrection n'étant plafonnée, un cumul de cicatrices identiques (doublons autorisés une fois les 5 types possédés) doit être borné par des planchers par stat, définis dans `scars.json` : ex. `speed_mult` jamais sous 0.5, `max_hp` jamais sous 2, `heal_mult` jamais sous 0.3. Sans ce garde-fou, un joueur mourant de nombreuses fois se retrouverait avec un personnage totalement inerte bien avant que l'escalade des Gardiens (plafonnée à ×2.5) ne devienne le facteur limitant.

---

# Cicatrices Visuelles

## Première résurrection

* yeux lumineux ;
* particules spectrales ;
* fissures discrètes.

## Deuxième résurrection

* veines lumineuses ;
* aura légère ;
* regard moins humain.

## Troisième résurrection

* transparence partielle ;
* énergie du Noyau visible ;
* effets spectraux permanents.

## Quatrième résurrection

* cristallisation partielle ;
* fragments flottants ;
* silhouette altérée.

## Cinquième résurrection et plus

Le personnage semble appartenir autant au monde des morts qu'à celui des vivants.

* fissures lumineuses omniprésentes ;
* présence spectrale permanente ;
* apparence quasi mythologique.

---

# Narration

Le Noyau refuse normalement toute résurrection.

Chaque retour à la vie exige un sacrifice.

Les Gardiens du Voile ne sont pas les véritables ennemis du joueur.

Ils sont les juges chargés de déterminer si son âme mérite une nouvelle chance.

Chaque victoire dans l'Arène du Voile coûte une partie de son humanité.

Le personnage revient plus fort, mais aussi plus proche du Noyau.

Les recettes du Voile et certains objets légendaires exploitent directement cette énergie, créant un lien entre la progression de craft et la progression narrative du personnage.

---

# Impact Émotionnel

Au début du run, le personnage est un simple aventurier.

Après plusieurs résurrections, il devient progressivement quelque chose d'autre.

Lorsqu'il atteint finalement le Noyau, le joueur doit pouvoir regarder son personnage et comprendre immédiatement le prix payé pour arriver jusque-là.

Les Cicatrices deviennent alors le journal visuel et mécanique de son parcours.

---

# Objectifs du Système Global

Le système doit :

* permettre le craft dès la première partie ;
* récompenser l'exploration ;
* encourager la chasse aux ennemis rares ;
* créer une collection de recettes ;
* offrir une progression permanente ;
* augmenter la rejouabilité ;
* rester simple à comprendre ;
* rester simple à développer ;
* réduire la frustration liée à la mort ;
* conserver un haut niveau de challenge ;
* créer une forte identité de jeu ;
* générer des histoires uniques à chaque run.

---

# Bénéfices pour CoreDive

* Progression méta claire et intuitive.
* Aucun blocage du craft lors du premier run.
* Motivation constante à explorer.
* Forte satisfaction lors de la découverte d'une recette rare.
* Compatibilité parfaite avec les runs courts.
* Développement plus simple qu'un système de métiers ou d'arbres de compétences.
* Synergie forte avec les biomes, le Noyau et le Voile.
* Mort moins frustrante.
* Boss secondaires récurrents.
* Progression narrative intégrée au gameplay.
* Histoire unique à chaque run.
* Attachement plus fort au personnage.
* Meilleure compatibilité avec les combats difficiles du jeu principal.
* Forte cohérence entre progression, craft, exploration, narration et résurrection.
