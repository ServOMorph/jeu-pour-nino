# Signals — game_art

## Actions ouvertes

- [P2] Phase 2.2 : compléter la visualisation (infos frame, fond damier, état
  play/pause visible, gestion textures manquantes).
  fait quand: preview affiche frame/total + taille + fps + loop, fond damier visible,
  bouton II/> reflète l'état, PNG manquant affiche damier magenta + warning console.
  réf: game_art/editeur/main.gd, game_art/roadmap_editeur.md (section 2.2).

## Blocages

## Dernière session

# Session du 2026-07-03

## Décisions prises
- Aucune décision structurante nouvelle (session de correction de bugs bloquants).

## Livrables produits ou modifiés
- game_art/editeur/main.gd : `class_name AnimationDriverEditor` remplacé par
  `preload()` + typage sur le script préchargé (robuste sans cache `.godot/`) ;
  `HSplitContainer` unique (3 enfants, non supporté) remplacé par deux
  `HSplitContainer` imbriqués (galerie | (preview | inspecteur)).

## Hypothèses validées / invalidées
- VALIDÉ : le rendu gris venait d'une erreur de parse GDScript (`class_name` non
  résolu sans cache `.godot/` généré par l'éditeur Godot), pas d'un problème d'anchors.
- VALIDÉ : `HSplitContainer` ne gère proprement que 2 enfants ; le 3e panneau
  (inspecteur) se superposait au premier (galerie).
- INVALIDE : hypothèse anchors du VBoxContainer racine — déjà correctement
  configurés (anchor_right/bottom = 1.0) avant cette session.

## Prochaine étape exacte
Phase 2.2 : ajouter le label d'infos de frame sous la preview, le fond damier,
l'état play/pause visible sur le bouton, et le placeholder magenta pour textures
manquantes (voir roadmap_editeur.md section 2.2).

## Question bloquante pour la session suivante
Aucune
