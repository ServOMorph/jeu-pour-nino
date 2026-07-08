# Charte graphique — dark fantasy 2D standard

## Statut

Le nom de fichier est historique. Le contenu actif décrit la direction visuelle actuelle : 2D standard raster, pas pixel art.

## Intention

Le jeu vise une direction visuelle dark fantasy majestueuse, sombre et lisible, avec une sensation de ruines anciennes, de monde souterrain sacré et dangereux.

Référence d'ambiance : Elden Ring pour le ton général, l'échelle mythique, les silhouettes usées, les ruines, l'or ancien et la mélancolie.

Interdit :
- copier des personnages, armures, boss, symboles, interfaces ou lieux précis ;
- reproduire une identité visuelle existante ;
- basculer vers une imagerie cartoon saturée.

## Mots-clés

- souterrain
- ancien
- sacré
- ruiné
- mystérieux
- dangereux
- mélancolique
- minéral
- doré terni
- lumière rare

## Style général

- 2D raster lisible, avec silhouettes fortes
- détails contrôlés, jamais bruités pour le plaisir
- décor sombre, personnages et ennemis bien détachés du fond
- couleurs désaturées, sans obligation de palette réduite
- effets lumineux rares mais marquants
- éléments de gameplay immédiatement identifiables

## Palette cible

### Dominantes

- pierre froide : gris bleuté, gris vert, ardoise
- terre sombre : brun noir, brun mousse, ocre sale
- métal usé : fer sombre, acier froid, cuivre oxydé
- or ancien : jaune terni, ambre, bronze
- ombres : bleu nuit, violet très sombre, noir adouci

### Accents

- minerai : cuivre chaud, fer clair, cristal froid
- danger : rouge sombre, orange lave, éclat sang
- magie / noyau : or lumineux, blanc chaud, cyan très rare
- vie / soin : vert doux ou rouge potion, avec retenue

## Règles de lisibilité

- le joueur doit rester plus lisible que le décor
- les ennemis doivent avoir une silhouette distincte
- les projectiles et attaques ont une couleur d'accent claire
- le fond ne doit pas confondre plateformes et volumes traversables
- les objets interactifs doivent se distinguer immédiatement
- la lecture à taille réelle prime sur le détail zoomé

## Joueur

Direction :
- aventurier de mine / chevalier pauvre
- fragile mais déterminé
- jamais héroïque ou suréquipé dès le départ

Silhouette :
- compacte
- cape courte ou tissu usé possible
- casque simple, capuche ou cheveux visibles
- arme lisible en main

Couleurs :
- brun, gris, cuir
- petit accent clair
- progression visible par matériau et qualité d'équipement

## Ennemis

### Mob au sol

- créature de galerie, insecte, bête de roche ou équivalent
- silhouette basse
- lecture immédiate du danger
- accent lumineux possible

### Mob volant

- silhouette plus fine et aérienne
- appendices ou ailes visibles
- lecture claire sur fond sombre

## Boss

- silhouette massive
- plusieurs zones visuelles claires
- accent lumineux fort
- impression de gardien ancien
- menace lisible avant même l'animation

## Biomes

### Biome 1 — Galeries Verdoyantes

- pierre humide
- racines
- cuivre
- lumière chaude rare

### Biome 2 — Mines Obscures

- galeries sombres
- métal usé
- lecture compatible avec l'overlay d'obscurité

### Biome 3 — Îles Célestes

- cristaux
- lumière froide
- verticalité

### Biome 4 — Descente vers le Noyau

- roche en fusion
- fissures lumineuses
- corruption
- chaleur visuelle

## Interface

- sobre
- lisible
- fond sombre semi-opaque si nécessaire
- titres et accents en or terni
- rouge pour danger
- couleurs d'icônes cohérentes avec leur fonction

## Format des assets

- PNG avec alpha propre
- pas de grille imposée
- pas d'obligation de palette limitée
- pas d'obligation de contours noirs
- pas d'obligation de rendu pixelisé
- tailles définies par les besoins runtime du jeu

## À éviter

- couleurs trop vives
- volumes trop flous
- décor qui masque le gameplay
- surcharge d'effets
- détail microscopique illisible à taille réelle

## Priorité de production

1. joueur
2. ennemis
3. boss
4. décors / tilesets
5. UI

## Critère de validation

Un asset est accepté si :
- il reste lisible à taille réelle dans Godot
- sa silhouette est identifiable sans zoom
- il respecte la direction dark fantasy
- il ne copie pas une référence existante
- il améliore la compréhension du gameplay
