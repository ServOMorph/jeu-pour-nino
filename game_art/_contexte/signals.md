# Signals — game_art

## Actions ouvertes

- [P1] Phase 3.3 : tests manuels de bout en bout de la sauvegarde éditeur.
  fait quand: fps modifié via l'inspecteur (ex. player.run 8→4) persiste après
  relance de l'éditeur ; `python sync.py` + `python run_game.py` reflète le
  nouveau timing en jeu ; un état legacy (liste de chemins, sans `sheet`)
  survit intact à une sauvegarde.
  réf: game_art/roadmap_editeur.md (section 3.3), game_art/editeur/main.gd (_save).

## Blocages

## Dernière session

# Session du 2026-07-05

## Décisions prises
- JSON.stringify appelé avec sort_keys=false dans _save() (le défaut true
  cassait l'ordre des clés à chaque sauvegarde).
- Vérification des changements GDScript via test headless Godot
  (editeur/test_save_roundtrip.gd) plutôt que par pilotage OS souris/clavier,
  trop fragile pour ce cas.

## Livrables produits ou modifiés
- game_art/editeur/inspector.gd (nouveau) : panneau d'édition fps/loop/offset/
  frame_size/frames, signal state_edited.
- game_art/editeur/animation_driver.gd : + load_from_dict(), + get_sheet_frame_count().
- game_art/editeur/main.gd : instanciation inspecteur, sauvegarde (bouton +
  Ctrl+S, écriture atomique .tmp+rename, indicateur titre non-sauvé).
- game_art/editeur/test_save_roundtrip.gd (nouveau) : script de test headless
  (modes mutate/verify/normalize), pas destiné à la prod.
- game_art/data/animations.json : normalisé (commit séparé), aucune valeur
  métier changée.
- game_art/roadmap_editeur.md : Phase 3.1 et 3.2 cochées.

## Hypothèses validées / invalidées
- VALIDÉ : Dictionary GDScript préserve l'ordre d'insertion — le
  réordonnancement observé venait de JSON.stringify(sort_keys=true par défaut),
  pas du Dictionary.
- INVALIDE : hypothèse roadmap "diff minimal dès le premier aller-retour" ->
  pivot : diff minimal après un commit de normalisation ponctuel (int→float
  et arrays multi-lignes sont inhérents à JSON.stringify, non évitables).

## Prochaine étape exacte
Phase 3.3 : test manuel en conditions réelles dans l'éditeur Godot (édition
fps/offset via l'inspecteur, sync.py, run_game.py) — nécessite une session
interactive, non automatisable en headless.

## Question bloquante pour la session suivante
Aucune
