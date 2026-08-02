# Signals - game_art

## Actions ouvertes
- [P1] Poursuivre la Phase 7 `Pipeline d'animations video guidees` sur `player/run` avec Wan2.2-Animate en mode remplacement et un controle realiste pre-normalise.
  fait quand: un cycle complet de `16` frames regenerees en une sequence temporelle, sans correction des frames finales, passe les controles automatiques puis les validations editeur et jeu.
  ref: `game_art/roadmap_editeur.md` Phase 7, `game_art/assets/generated_raw/player/run_video_v1/`, `game_art/tools/build_wan_animate_realistic_control.py`
- [P2] Formaliser le profil reproductible et le rapport d'audit du candidat final.
  fait quand: un JSON versionne contient entrees, empreintes, modele, seed, parametres, seuils et verdict global reproductible.
  ref: `game_art/roadmap_editeur.md` etape 7.1/7.6, `game_art/assets/generated_raw/player/run_video_v1/`

## Blocages
*Aucun blocage materiel : Wan2.2-Animate quantifie fonctionne localement sur la RTX 4060 8 Go avec offload RAM.*

## Contexte chaud
- Reference maitre validee : `game_art/assets/generated_raw/player/run_v5_master_reference_canvas.png`, SHA-256 `813c5a1483f75b9da8c629e1569a99caae7dcf5f1ef99234826754676edf873`.
- Ne pas remplacer `game_art/assets/player/player_run_sheet.png` avant validation complete ; la sheet runtime actuelle est restee intacte.
- Modele local : `D:/AI/WanGP/ckpts/wan2.2_animate_14B_quanto_bf16_int8.safetensors`. Test 512x736, 81 frames, 20 etapes : 35 min, pic observe environ 6,8 Go VRAM et 27 Go RAM.
- Reconstruction/rig locaux disponibles : TripoSR + UniRig. Le rig est coherent, mais le rendu direct de la cape et des membres est impropre a la livraison.

## Derniere session
# Session du 2026-08-02

## Decisions prises
- Le backend distant est abandonne ; la production doit rester locale sur RTX 4060 8 Go et 48 Go RAM.
- Wan2.2-Animate quantifie avec offload est valide techniquement en local ; le mode animation reste rejete artistiquement et le prochain essai doit utiliser le mode remplacement.
- Toute sortie qui echoue sur une frame ou sur un seuil rejette le lot entier ; aucune correction d'une frame finale n'est autorisee.
- La sheet runtime `player_run_sheet.png` reste inchangee tant qu'un candidat n'est pas completement valide.

## Livrables produits ou modifies
- `game_art/tools/` : outils de controle OpenPose/SD1.5, reconstruction TripoSR, rig UniRig, sondes Flux et generation Wan locale.
- `game_art/assets/generated_raw/player/run_video_v1/` : references, controles, configurations, rapports et candidats rejetes conserves pour reprise.
- `D:/AI/TripoSR` et `D:/AI/UniRig` : environnements locaux operationnels ; rig texture `D:/AI/UniRig/results/nino_highres_rigged.glb`.

## Hypotheses validees / invalidees
- VALIDE : Wan2.2-Animate 14B INT8 s'execute localement sans OOM a 512x736/81 frames.
- VALIDE : TripoSR puis UniRig produit localement un personnage texture et un squelette 28 os exploitable comme controle.
- INVALIDE : MimicMotion, Wan Animate/Move, SCAIL2, SD1.5, Flux pose ou Flux img2img satisfont simultanement identite, course lisible et seuils geometriques.
- INVALIDE : le controle realiste du candidat 37 ameliore l'identite mais fige presque la course et n'alterne pas correctement les jambes.

## Prochaine etape exacte
Normaliser les guides realistes avant generation, puis tester Wan2.2-Animate en mode remplacement `PVBAIH#`. Auditer visuellement et par DWPose ; rejeter le lot entier en cas d'echec.

## Question bloquante pour la session suivante
Aucune
