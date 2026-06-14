# Profil joueur — synthèse pour la conception d'un jeu 2D

*Document de travail basé sur le relevé Steam (44 jeux, ~1 967 heures cumulées, soit environ 82 jours de jeu).*

## 1. Le constat principal : la survie/crafting/sandbox écrase tout le reste

Près de **58 % du temps de jeu total (~1 135 h)** est concentré sur des jeux de survie, crafting et construction en monde ouvert : Valheim (342 h), Terraria (244 h), Project Zomboid (135 h), Fallout 76 (72 h), Scrap Mechanic (52 h), Kenshi (45 h), tModLoader (44 h), Enshrouded (44 h), Core Keeper (29 h), Icarus (26 h), Rust (22 h), Volcanoids (20 h), Muck (20 h), Project Winter (18 h), Ylands (11 h), VoidTrain (11 h).

Ce n'est pas un genre parmi d'autres : c'est **le** genre. Tous les autres jeux très joués (Elden Ring, Hollow Knight, Noita, Hades...) viennent en complément, mais la boucle « explorer → récolter des ressources → fabriquer/améliorer son équipement → construire une base → affronter un défi plus dur avec un meilleur stuff » est clairement celle qui le retient le plus longtemps.

## 2. Les jeux 2D qu'il a déjà beaucoup joués (signal direct pour ton projet)

C'est la partie la plus utile : **~488 h (25 % du total)** sont passées sur des jeux qui sont déjà en 2D / pixel art, donc on a un signal direct sur le type de jeu 2D qu'il aime, pas juste une extrapolation depuis des jeux 3D.

| Jeu | Heures | Ce que ça représente |
|---|---|---|
| Terraria | 244 | Survie/crafting/exploration 2D, biomes, boss, progression d'équipement |
| tModLoader | 44 | Même chose, en version moddée/personnalisée → il aime *enrichir* et *bricoler* le jeu lui-même |
| Noita | 60 | Roguelike 2D physique, génération procédurale, alchimie/magie émergente, die & retry |
| Hollow Knight | 54 | Metroidvania 2D, ambiance sombre/onirique, combat exigeant, exploration non-linéaire |
| Hollow Knight Silksong | 7 | Confirme l'attrait pour le metroidvania exigeant (jeu très récent, donc engagement précoce) |
| Core Keeper | 29 | Survie/crafting 2D façon Terraria, plus orienté coop et donjons |
| Rogue Tower | 24 | Tower defense en run, logique roguelite |
| Cult of the Lamb | 2 | Roguelike + gestion de base (signal plus faible mais cohérent) |
| Brawlhalla | 7 | Combat 2D compétitif |
| Pico Park | 5 | Puzzle coopératif 2D |
| Your Only Move Is Hustle | 6 | Fighting 2D |

Le tModLoader est un détail important : passer 44 h sur des **mods** de Terraria montre un vrai goût pour la personnalisation, le contenu généré/étendu et le bricolage de système — pas juste pour « finir » un jeu.

## 3. Les autres traits dominants de son profil

**Goût pour le challenge et le die & retry.** Elden Ring (248 h) + Elden Ring Nightreign (106 h) + Lies of P (8 h) + Crimson Desert (14 h) + Hollow Knight/Silksong (61 h) + Hades (26 h) représentent ~463 h (24 % du total) de jeux réputés exigeants, où l'échec fait partie de la boucle de progression. Combiné à la survie, ça dessine un joueur qui aime **être mis en difficulté tant qu'il y a une vraie sensation de progression derrière**.

**Génération procédurale / monde à (re)découvrir.** Valheim, Terraria, Noita, Core Keeper, Deep Rock Galactic, Icarus, Kenshi, Enshrouded, Fallout 76 = ~892 h (45 %). L'exploration d'un monde qui n'est pas toujours le même, avec des surprises, est clairement valorisée.

**Roguelike/roguelite avec progression permanente.** Noita, Hades, Elden Ring Nightreign, Rogue Tower, Muck, Cult of the Lamb = ~238 h. Il apprécie les boucles courtes ("runs") qui débloquent des choses permanentes — un bon complément à la survie en monde persistant.

**Coopération valorisée mais pas obligatoire.** Les jeux à forte composante coop (Valheim, Deep Rock Galactic, Project Zomboid, Scrap Mechanic, Pico Park, Crab Game, Project Winter, Muck, Enshrouded) totalisent ~657 h (33 %). C'est un vrai plus, surtout pour les jeux "longue durée", mais une bonne partie de son temps de jeu se fait aussi en solo (Elden Ring, Terraria, Noita, Hollow Knight, Hades...).

**Tolérance au grind / aux systèmes profonds.** Avec une moyenne proche de 45 h par jeu (et plusieurs au-delà de 100 h), il n'est clairement pas dans une logique de jeux "à consommer vite". Il s'investit dans des systèmes qu'il apprend à maîtriser sur la durée.

## 4. Ce qui n'a visiblement pas pris (signaux négatifs utiles)

- **L'horreur ne retient pas longtemps** : Project Playtime (6 h), et en dessous d'1 h pour Five Nights at Freddy's, Poppy Playtime. L'ambiance horrifique seule ne suffit pas à le fidéliser.
- **La course/simulation pure ne l'intéresse pas** : NASCAR Heat 5 (<1 h), Cube Racer (6 h).
- **Le PvP compétitif "pur"** (The Finals, Arc Raiders, Supervive, Laser League) reste à un niveau modéré (5-20 h) : il y joue, mais ça ne devient jamais son jeu principal.
- **The Lord of the Rings: Return to Moria** (<1 h) est intéressant : c'est presque le même genre que Valheim (survie/crafting coop en monde ouvert), mais il n'a pas accroché. Ça confirme que **le genre seul ne garantit rien** — l'exécution, le feeling des contrôles, le rythme de progression et l'ambiance comptent énormément. Un "Valheim-like" mal exécuté ne suffira pas.

## 5. Synthèse : la recette qui a le plus de chances de fonctionner en 2D

En croisant tous ces signaux, le profil qui se dégage est celui d'un joueur qui aime :

1. Un **monde à explorer** (idéalement généré ou semi-procédural, avec des biomes/zones distinctes),
2. dans lequel il **collecte des ressources et fabrique/améliore son équipement** (boucle de crafting lisible et gratifiante),
3. pour pouvoir **affronter des défis/boss exigeants** où la maîtrise du joueur compte autant que le stuff,
4. avec une **base/un foyer** qu'il peut construire et faire évoluer,
5. et idéalement une **structure en "runs" ou en paliers** qui offre des objectifs courts en plus de la progression longue,
6. dans un **univers avec une vraie identité visuelle/atmosphérique** (pas juste un système de jeu nu),
7. avec, si possible, un **mode coop** (même optionnel) pour jouer avec des amis/avec toi.

Autrement dit : un peu de Terraria (boucle crafting/exploration/boss) + un peu de Hollow Knight (ambiance, combat exigeant, exploration soignée) + un peu de Noita/Hades (génération procédurale, runs, magie/capacités qui se débloquent).

## 6. Pistes concrètes de game design 2D à creuser

- **"Terraria-like" recentré et stylisé** : un sandbox 2D survie/crafting/exploration avec une identité graphique forte (pas générique), des biomes et des boss de progression — le pari le plus "sûr" vu les 488 h déjà investies dans ce type de jeu.
- **Metroidvania exigeant à boucle de craft légère** : exploration non-linéaire façon Hollow Knight, avec un système de progression (amélioration d'armes/capacités via ressources trouvées) pour ajouter la dimension "récompense tangible" qu'il aime dans la survie.
- **Roguelite d'expédition avec base persistante** : un hub/base que l'on construit et améliore entre des "runs" générés procéduralement (façon Hades/Nightreign mais avec une vraie base à la Valheim/Core Keeper) — combine sa préférence pour le run court ET pour la progression longue.
- **Sandbox d'action physique/procédural** : dans l'esprit Noita, avec des systèmes émergents (alchimie, environnements destructibles, magie qui se combine) — adapté s'il aime plutôt bricoler des systèmes que suivre un scénario.
- **Coop 2D survie/construction entre amis** : un Valheim/Core Keeper en 2D pensé dès le départ pour 2-4 joueurs, avec une vraie raison de revenir régulièrement (saisons, événements, défis communs).

## 7. Questions à clarifier avant de te lancer

- **Solo, coop, ou les deux ?** Vu que ~33 % de son temps est en coop mais que ses jeux les plus joués (Terraria, Elden Ring, Hollow Knight, Noita) se font très bien en solo, le coop est un bonus, pas un prérequis.
- **Durée de session visée** : runs courts (15-30 min, façon roguelite) ou sessions longues (survie monde persistant) ? Les deux l'intéressent, mais ça change beaucoup la structure du jeu.
- **Niveau de difficulté/punition** : il tolère très bien la difficulté (Elden Ring, Lies of P, Hollow Knight), donc ne pas hésiter à proposer un vrai challenge plutôt qu'un jeu "confort".
- **Style visuel** : pixel art détaillé/atmosphérique (Hollow Knight, Terraria) vs. plus minimaliste/géométrique (Noita) — un test rapide avec lui sur des références visuelles pourrait orienter la direction artistique.