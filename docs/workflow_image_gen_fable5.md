# Workflow image_gen / Codex — sprites 2D standard

## Statut

Document actif. Les sections historiques liées au pixel art ne font plus foi.

## Workflow retenu

Le workflow par défaut pour les sprites du projet est :

`generation image HD -> fond transparent ou chroma-key -> nettoyage local -> resize exact à la taille cible -> intégration`

Ce workflow s'applique en priorité :
- au joueur ;
- aux ennemis ;
- aux boss ;
- aux objets visibles en jeu.

## Principes

- L'image générée n'est pas automatiquement le livrable final.
- Le livrable final est le PNG redimensionné à la taille runtime exacte.
- Pour une animation, ne pas régénérer toute la série sans contrainte commune.
- Partir d'une frame maître puis dériver les variantes.
- Contrôler systématiquement cadrage, échelle et point d'ancrage.

## Cas d'usage

`image_gen` / génération image sert à :
- explorer une silhouette ;
- établir une matière ou une palette ;
- créer une frame maître ;
- corriger ou décliner un asset bitmap.

Ce workflow ne sert pas à :
- produire du pixel art ;
- imposer une palette réduite ;
- reconstruire manuellement chaque sprite pixel par pixel ;
- découper une planche globale non contrainte.

## Méthode recommandée

### Objet simple

1. Générer une version HD propre.
2. Détourer si nécessaire.
3. Redimensionner à la taille cible.
4. Vérifier lisibilité et halo.
5. Intégrer.

### Personnage ou ennemi animé

1. Générer une frame maître propre.
2. Valider silhouette, proportions et tenue à taille réelle.
3. Dériver les autres poses à partir de cette base.
4. Redimensionner chaque frame à la taille cible exacte.
5. Vérifier la stabilité inter-frames dans l'éditeur.
6. Corriger les offsets dans `animations.json` si besoin.

## Risques principaux

- dérive d'échelle entre frames ;
- recadrages incohérents ;
- halos de détourage après resize ;
- détails trop fins qui disparaissent à taille réelle ;
- rendu trop flou si la source HD est faible.

Si l'un de ces points apparaît, régénérer la source maître plutôt que compenser en cascade sur tout le cycle d'animation.

## Validation

Un sprite est acceptable si :
- il est lisible à taille de jeu ;
- la silhouette est claire ;
- l'animation ne saute pas visuellement ;
- le fond est proprement détouré ;
- la cohérence visuelle avec les autres assets est respectée.

## Outils de validation

- `python run_editeur.py`
- `python sync.py`
- `python run_game.py`
- `D:\tmp\godot45\Godot_v4.5-stable_win64.exe --headless --path game --quit-after 3`

## Note de compatibilité

Le nom de ce fichier est conservé, mais sa doctrine a changé : il décrit désormais un pipeline 2D standard, pas un pipeline pixel art.
