# Charte graphique — Pixel art dark fantasy

## Intention

Le jeu doit évoluer vers une direction visuelle **dark fantasy majestueuse**, sombre et lisible, avec une sensation de ruines anciennes, de monde souterrain sacré et dangereux.

Référence d'ambiance : **Elden Ring** pour le ton général, l'échelle mythique, les silhouettes usées, les ruines, l'or ancien et la mélancolie.  
Attention : il ne faut pas copier des personnages, armures, boss, symboles, interfaces ou lieux précis. L'objectif est de retrouver une famille d'ambiance, pas de reproduire une identité existante.

## Mots-clés

- Souterrain
- Ancien
- Sacré
- Ruiné
- Mystérieux
- Dangereux
- Mélancolique
- Minéral
- Doré terni
- Lumière rare

## Style général

- Pixel art lisible, avec silhouettes fortes.
- Peu de détails fins : priorité à la forme globale et au contraste.
- Décor sombre, personnages et ennemis bien détachés du fond.
- Couleurs moins saturées que du pixel art arcade classique.
- Effets lumineux rares mais importants : torches, minerais, magie, noyau, yeux ennemis.
- Les éléments importants doivent être identifiables immédiatement : joueur, ennemis, minerais, établi, boss, porte.

## Palette cible

### Couleurs dominantes

- Pierre froide : gris bleuté, gris vert, ardoise.
- Terre sombre : brun noir, brun mousse, ocre sale.
- Métal usé : fer sombre, acier froid, cuivre oxydé.
- Or ancien : jaune terni, ambre, bronze.
- Ombres : bleu nuit, violet très sombre, noir adouci.

### Couleurs d'accent

- Minerai : cuivre chaud, fer clair, cristal froid.
- Danger : rouge sombre, orange lave, éclat sang.
- Magie / noyau : or lumineux, blanc chaud, cyan très rare.
- Vie / soin : vert doux ou rouge potion, mais utilisé avec retenue.

## Règles de lisibilité

- Le joueur doit rester plus lisible que le décor.
- Les ennemis doivent avoir une silhouette différente du joueur.
- Les projectiles et attaques doivent utiliser une couleur d'accent claire.
- Le fond ne doit pas partager exactement la même luminosité que les plateformes.
- Les zones praticables doivent être immédiatement compréhensibles.
- Les objets interactifs doivent avoir un détail lumineux ou une couleur distinctive.

## Joueur

### Direction

Petit aventurier de mine / chevalier pauvre, fragile mais déterminé. Il ne doit pas ressembler à un héros royal ou surpuissant.

### Silhouette

- Corps compact.
- Cape courte ou tissu usé possible.
- Casque simple, capuche ou cheveux visibles.
- Arme lisible en main.
- Pioche ou équipement de départ visible si possible.

### Couleurs

- Tenue sombre : brun, gris, cuir.
- Accent clair : foulard, bord de cape, petit éclat métallique.
- Améliorations visibles par matériaux : bois, cuivre, fer.

### Animations prioritaires

- Idle
- Marche / course
- Saut
- Attaque
- Dégât reçu
- Mort

## Ennemis

## Mob au sol

Créature de galerie : mélange d'insecte, limace blindée ou bête de roche.

Règles :
- Silhouette basse.
- Déplacement menaçant mais simple.
- Couleur proche du biome, avec yeux ou noyau lumineux.
- Doit rester identifiable même en petit format.

## Mob volant

Créature légère : chauve-souris minérale, insecte cavernicole, fragment vivant.

Règles :
- Silhouette plus fine et aérienne.
- Ailes ou appendices immédiatement visibles.
- Couleur légèrement plus froide que le mob au sol.
- Point lumineux possible pour aider à le suivre.

## Boss

Le boss doit donner une impression de gardien ancien, plus grand que le joueur, lié à la roche ou au noyau.

Règles :
- Silhouette massive.
- Plusieurs zones visuelles : tête, bras, coeur, arme ou cornes.
- Accent lumineux fort : coeur doré, oeil, fissures magiques.
- Animation lente mais menaçante.
- Le joueur doit comprendre visuellement que c'est un mur de fin de run.

## Biome 1 — Galeries de surface

Ambiance : grotte ancienne proche de la surface, racines, pierre humide, traces d'un vieux monde enfoui.

Palette :
- bruns sombres
- verts mousse
- gris pierre
- cuivre
- lumière chaude faible

Éléments visuels :
- racines
- pierres fissurées
- minerais de cuivre
- planches ou restes d'atelier
- torches rares

## Biome 2 — Profondeurs cristallines

Ambiance : cavernes froides, cristaux, silence, magie ancienne.

Palette :
- bleu sombre
- violet désaturé
- gris froid
- cyan rare
- blanc bleuté

Éléments visuels :
- cristaux lumineux
- brume légère
- pierre noire
- reflets froids

## Biome 3 — Approches du Noyau

Ambiance : ruines brûlées, chaleur, pression, monde qui se déforme près du coeur.

Palette :
- rouge sombre
- orange lave
- brun brûlé
- noir chaud
- or ancien

Éléments visuels :
- fissures lumineuses
- lave ou braises
- structures anciennes cassées
- minerais rares

## Interface

L'interface doit rester simple et lisible, sans surcharge décorative.

Règles :
- Texte clair et court.
- Fond sombre semi-opaque si nécessaire.
- Couleur or terni pour titres ou éléments importants.
- Rouge pour danger / PV.
- Vert ou rouge potion pour soin.
- Icônes simples en pixel art pour potion, minerai, or.

## Format des sprites

Formats recommandés :
- Joueur : 24x24 ou 32x32 px.
- Mob au sol : 24x16 ou 32x24 px.
- Mob volant : 24x24 px.
- Boss : 64x64 à 96x96 px.
- Tiles : 16x16 px.
- Objets interactifs : 16x16 ou 24x24 px.

Règles techniques :
- Fond transparent.
- Pas d'anti-aliasing flou.
- Contours lisibles, pas forcément noirs.
- Palette limitée par sprite.
- Export PNG.

## À éviter

- Couleurs trop vives façon cartoon.
- Personnages trop mignons si cela casse la tension.
- Décor trop détaillé qui masque le gameplay.
- Copie directe d'armures, boss, symboles ou lieux Elden Ring.
- Trop de noir pur : préférer des ombres colorées.
- Trop d'effets visuels qui rendent les attaques illisibles.

## Priorité de production

1. Sprite joueur avec idle, course, saut, attaque.
2. Mob au sol.
3. Mob volant.
4. Boss.
5. Minerais et établi.
6. Tiles biome 1.
7. UI icons : potion, or, minerai.

## Critère de validation

Un asset est accepté si :
- il reste lisible à sa taille réelle dans Godot ;
- sa silhouette est identifiable sans zoom ;
- il respecte la palette dark fantasy ;
- il ne copie pas une référence existante ;
- il améliore la compréhension du gameplay.
