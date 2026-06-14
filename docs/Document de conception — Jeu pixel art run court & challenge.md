# CoreDive Challenge — Document de conception

*Basé sur le profil joueur établi précédemment. Décisions validées : solo, runs courts, pixel art type Terraria, thème de la descente, 3 biomes, moteur Godot, défi "sauras-tu arriver au bout ?".*

## 1. Pitch

**CoreDive Challenge** est un roguelite 2D en pixel art où chaque partie ("run") consiste à **plonger toujours plus profond vers le Noyau** d'un monde souterrain généré procéduralement, en récoltant des ressources, en améliorant son équipement en cours de route, et en affrontant des ennemis et boss de plus en plus durs. L'objectif est clair et visible dès le départ : **atteindre le Noyau, au fond du troisième biome**. Mourir en chemin met fin au run, mais certains éléments persistent pour la prochaine tentative.

C'est l'ADN Terraria (exploration, ressources, craft, palier d'équipement, boss) condensé dans une structure de run courte façon Hades/Noita, avec l'exigence d'un Hollow Knight côté difficulté. Le titre "CoreDive" résume la promesse : à chaque run, on plonge un peu plus loin vers le cœur du monde — et la question posée au joueur est simple : *sauras-tu atteindre le Noyau ?*

## 2. Boucle de jeu principale (un run)

1. Le joueur démarre en haut d'une zone, avec un équipement minimal (pioche/épée basique).
2. Il progresse vers le bas (ou vers la sortie), case par case / écran par écran.
3. En chemin : minerais, plantes, matériaux à récolter ; ennemis à combattre ou éviter ; pièges environnementaux.
4. Des établis/forges sont disposés dans le niveau (ou portables) → permettent de crafter des armes/armures/outils meilleurs avec les ressources trouvées.
5. Chaque zone se termine par un mini-boss ou un passage difficile qui filtre les joueurs pas assez préparés.
6. Run réussi = atteindre la sortie finale / le boss final. Run perdu = mort (retour au hub).

**Durée cible d'un run** : 10 à 20 minutes pour un joueur compétent, ce qui permet beaucoup de tentatives et un apprentissage par itération — exactement ce qu'il aime dans Noita/Hades.

## 3. Génération procédurale (pensée pour rester simple à coder)

Plutôt qu'un monde ouvert façon Terraria (très complexe à générer et simuler), opter pour une **structure en niveaux/sections générées séparément** :

- Le monde est découpé en **3 biomes successifs**, chacun composé d'une ou plusieurs sections générées, suivis du Noyau (zone finale + boss final).
- Chaque zone est une grille de tuiles générée par un algorithme simple (bruit de Perlin pour les murs/cavités, ou génération par "rooms" connectées).
- Une fois une zone terminée, le joueur passe à la suivante (pas de retour en arrière nécessaire) → évite de devoir gérer un immense monde persistant en mémoire.
- Chaque zone a son propre **biome** : palette de couleurs, tileset, type de ressources, type d'ennemis. Ça donne une sensation de progression/variété sans complexifier le moteur de génération (même algo, paramètres différents).

C'est nettement plus simple qu'un sandbox Terraria-like tout en gardant la sensation "monde à découvrir" qu'il aime.

## 4. Combat

- Combat simple et lisible : une arme de mêlée (portée courte, frappe directionnelle) + une arme à distance (limitée en munitions/énergie pour éviter le spam).
- Les ennemis sont propres à chaque biome, avec 2-3 patterns d'attaque maximum chacun (facile à designer et équilibrer).
- Chaque zone se termine par un **boss** avec un pattern d'attaque plus complexe (3-4 phases ou attaques) — moment de tension/récompense, comme les boss de Terraria ou Hollow Knight.
- Le boss final (fin du dernier biome) est **le but ultime du jeu** : le battre = "tu es arrivé au bout".

## 5. Équipement & craft (à l'échelle du run)

- Système de craft simplifié : ressource(s) + établi = objet. Pas besoin de centaines de recettes — viser 3-4 paliers d'équipement (bois → pierre/cuivre → fer → matériau "rare" du dernier biome), comme la progression de minerais de Terraria.
- Chaque palier débloque une arme et/ou une armure meilleure → sensation tangible de progression *pendant* le run.
- Quelques objets consommables simples : potion de soin, bombe, grappin/déplacement spécial (le grappin de Terraria est un excellent modèle, très appréciable en plateforme).
- Tout l'équipement est **perdu à la mort** (sauf éléments méta, voir ci-dessous) → ça maintient la tension du run.

## 6. Progression méta (entre les runs)

Pour donner une raison de réessayer après un échec (essentiel pour la dimension "challenge" et pour adoucir la courbe d'apprentissage sans réduire la difficulté en run) :

- Une **monnaie/relique** est récupérée même en cas d'échec (ex : un fragment ramassé juste avant de mourir, ou un % des ressources récoltées).
- Cette monnaie permet, dans un **hub** entre les runs, de débloquer : un meilleur équipement de départ, une recette de craft supplémentaire, un nouvel objet consommable, ou des variantes cosmétiques.
- Optionnel : un **compteur de profondeur max atteinte** affiché dans le hub → objectif personnel clair, dans l'esprit "high score" qui pousse à retenter.

Ce système permet de garder une difficulté élevée (mort = retour au début) tout en donnant un sentiment de progrès global — un équilibre que Hades et Nightreign maîtrisent très bien.

## 7. Le défi central : "sauras-tu arriver au bout ?"

- Le jeu a une **fin définie et visible** (battre le boss final du dernier biome), pas une boucle infinie sans objectif — important pour le côté "défi à relever" plutôt que "occupation sans fin".
- Mort = permadeath du run (retour au hub), mais grâce à la progression méta, chaque tentative rapproche un peu plus de la réussite.
- Idée optionnelle pour prolonger la durée de vie une fois le jeu "fini" : un **mode difficile / boucle infinie** débloqué après la première victoire, où les biomes s'enchaînent indéfiniment avec une difficulté croissante (mode "combien de temps peux-tu survivre ?").

## 8. Direction artistique

- Pixel art, lisible et coloré (palette distincte par biome — référence Terraria/Core Keeper pour la clarté, touche d'ambiance façon Hollow Knight pour les biomes plus tardifs/sombres).
- Animations simples mais avec du "feedback" fort : flash/recul à l'impact, particules à la récolte, screen shake léger sur les coups puissants — ça compte énormément pour le ressenti du combat, plus que la complexité graphique.
- Un visuel distinctif (palette, silhouette d'ennemis, design du personnage) vaut mieux que beaucoup de contenu générique — vu que LOTR: Return to Moria (genre proche de Valheim) n'a pas accroché malgré le bon concept, l'identité visuelle et le "feel" sont déterminants.

## 9. Scope conseillé pour un développement solo (par étapes)

1. **Noyau jouable** : déplacement, combat de base, un seul biome généré, un boss → un run jouable du début à la fin, même très court.
2. **Craft & équipement** : ajout des ressources, de l'établi, des paliers d'armes/armures.
3. **Progression méta & hub** : monnaie persistante, déblocages, écran de hub entre les runs.
4. **Extension du contenu** : les 2 biomes restants (sur les 3 prévus) + leurs ennemis/boss, plus la zone finale du Noyau et son boss.
5. **Polish final** : animations, sons, musique, équilibrage de la difficulté.

Chaque étape produit une version jouable et amusante — utile pour tester le ressenti de ton fils sur une démo courte sans révéler la surprise (tu peux tester toi-même, ou avec un autre testeur).

## 10. Les 3 biomes & le Noyau

Une proposition de progression cohérente avec le thème de la descente, à ajuster librement :

**Biome 1 — Galeries de surface**
Palette terreuse (bruns, verts mousse), grottes peu profondes avec racines et lumière naturelle qui filtre. Ennemis simples (limaces, insectes, chauves-souris basiques) avec des patterns d'attaque évidents. Ressources : bois, pierre, cuivre. C'est le biome "tutoriel" — apprentissage des contrôles et du craft de base.

**Biome 2 — Profondeurs cristallines**
Palette froide (bleus, violets), cavernes lumineuses parsemées de cristaux, obscurité plus présente (un point d'éclairage limité peut devenir une mécanique intéressante). Ennemis plus retors (golems de cristal, créatures volantes avec attaques à distance), pièges environnementaux (cristaux instables qui explosent ou s'effondrent). Ressources : fer, éclats de cristal. Palier d'équipement intermédiaire.

**Biome 3 — Approches du Noyau**
Palette chaude (rouges, oranges, lave), ruines anciennes fusionnées à la roche en fusion, ennemis les plus coriaces du jeu, dangers environnementaux marqués (lave, geysers). Ressources : matériau rare unique à ce biome, pour le palier d'équipement final.

**Le Noyau (zone finale)**
Arène finale où attend le **boss final** (ex : "le Gardien du Noyau"). Le vaincre = fin du run réussie = "tu es arrivé au bout". Visuellement, c'est le point culminant : design le plus marquant du jeu, pour que l'instant soit mémorable.

## 11. Notes techniques pour Godot

Quelques pistes pour structurer le projet sans verrouiller les choix d'implémentation :

- **Génération procédurale** : un `TileMap` par biome, alimenté par un script de génération (par exemple génération par "rooms" prédéfinies connectées aléatoirement, ou automate cellulaire pour les cavités — l'automate cellulaire est simple à implémenter et donne de bons résultats organiques).
- **Données par biome** : externaliser les stats des ennemis, des ressources et des recettes de craft dans des fichiers `Resource` (.tres) ou JSON, pour que chaque biome ne soit qu'un jeu de données différent réutilisant le même code (ennemis, craft, etc.).
- **Joueur & combat** : `CharacterBody2D` pour le joueur, `Area2D` pour les hitboxes d'attaque/dégâts. Un état machine simple (idle/attaque/dash/etc.) suffit largement pour un combat lisible.
- **Sauvegarde de la progression méta** : un singleton (autoload) qui gère la monnaie persistante et les déblocages, sauvegardé via `ConfigFile` ou JSON dans `user://`.
- **Transitions de biome** : chaque passage de biome peut être une simple transition de scène (`change_scene_to_file`), ce qui évite de garder plusieurs mondes en mémoire en même temps — cohérent avec la structure "pas de retour en arrière" décrite en section 3.

## 12. Récapitulatif des décisions

| Élément | Décision |
|---|---|
| Titre | CoreDive Challenge |
| Mode | Solo |
| Structure | Runs courts (10-20 min) |
| Thème | Descente vers le Noyau |
| Nombre de biomes | 3 + Noyau (zone finale/boss) |
| Style visuel | Pixel art (Terraria/Core Keeper/Hollow Knight) |
| Moteur | Godot |
| Objectif central | Atteindre le Noyau ("sauras-tu arriver au bout ?") |

## 13. Points encore ouverts

- **Identité du boss final / du Noyau** : une créature, une machine ancienne, une entité abstraite ? Ça orientera toute la direction artistique du biome 3.
- **Mécanique de lumière dans le biome 2** : à creuser si tu veux une vraie variation de gameplay entre les biomes (pas juste une palette différente).
- **Ce qui est débloqué en méta-progression** : équipement de départ amélioré, recettes supplémentaires, et/ou cosmétiques — à prioriser selon ce qui est le plus simple à implémenter en premier.