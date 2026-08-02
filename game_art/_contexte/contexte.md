# Contexte - game_art

## Objectif
Centraliser tous les assets visuels du jeu dans game_art/ et fournir un editeur Godot
pour visualiser, animer et auditer les sprites. Cible player actuelle :
150 px de haut, animations multi-frames, spritesheets.

## Stack
- Godot 4.5 (projet editeur autonome, res:// = game_art/)
- Sprites : pipeline majoritairement en spritesheets pour les entites animees
- Schema animations : game_art/data/animations.json (source de verite)
- Synchro vers jeu : sync.py a la racine projet (gere par zone jeu)

## Etat actuel
La Phase 7 `player/run` est en cours ; la reference maitre est validee et la sheet runtime reste intacte.
Wan2.2-Animate 14B INT8 fonctionne localement sur RTX 4060 8 Go avec offload dans 48 Go RAM.
Les pipelines MimicMotion, Wan Animate, SCAIL2, SD1.5, Flux et rendu direct TripoSR/UniRig ont produit des candidats, tous rejetes visuellement ou metrologiquement.
Le candidat Wan local 512x736/81 frames confirme la faisabilite materielle mais fige la course avec un controle realiste.
Prochaine etape : controle pre-normalise puis Wan2.2-Animate en mode remplacement, audit DWPose du lot complet.

## Decisions structurantes
- Le workflow historique par frames separees reste documente pour les assets existants,
  mais il est abandonne pour les nouvelles refontes : il ne garantit pas suffisamment
  la stabilite de taille, d'identite et de placement.
- Le workflow cible pour une nouvelle animation est : cycle de poses deterministe,
  generation video temporelle depuis une reference HD validee, extraction chronologique,
  detourage commun, resize uniforme du canevas complet, audit puis validation manuelle.
- Aucune frame d'un lot video ne peut recevoir de crop, resize, offset, recentrage ou
  regeneration individuel. Une anomalie impose la regeneration complete du lot.
- `player/run` sera le premier test du pipeline video guide : `16` frames `104x150` a
  `16 fps`. La sheet actuelle reste la version runtime validee jusqu'a validation complete.
- `player.jump` suit desormais une sheet `3` frames regeneree completement depuis la reference validee, au lieu d'une pose mono-frame.
- `player.run` utilise des cases `104x150` dans la sheet pour permettre l'edition manuelle sans changer les poses source.
- `player.attack` utilise desormais des cases `150x150`, validees apres elargissement lateral de la sheet sans retouche pixel.
- Le biome 1 est maintenant servi par une passe parallax `3` couches precomposee en grandes bandes pour attenuer les jonctions visibles en runtime.
- Les plateformes du biome 1 affichent une texture de roche et mousses repeteable, chargee depuis `game/data/biomes/biome1.json`.
- 2026-08-02 : la production finale de `player/run` reste strictement locale. Wan2.2-Animate 14B INT8 est executable sur RTX 4060 8 Go via offload RAM ; le mode animation est rejete pour manque d'adherence au cycle, et le prochain pivot est le mode remplacement avec controle pre-normalise. Aucun candidat ne remplace la sheet runtime avant audit complet.
