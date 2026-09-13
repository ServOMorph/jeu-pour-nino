# Test de workflow player/run — 2026-09-13

Verdict : REJETÉ. Aucun asset runtime ni fichier animations.json modifié.

## Hypothèse testée

Générer les 16 phases simultanément dans une planche 4×4 depuis la référence maître validée, avec contraintes explicites de phase, profil droit, grille, échelle et transparence. Cet essai explore une alternative au pipeline vidéo de la Phase 7 ; il ne le valide ni ne le remplace.

Référence : `../run_v5_master_reference_canvas.png`.
SHA-256 vérifié : `813c5a1483f75b9da8c629e1569a99caae7dcf5f1ef99234826754676edf8733`.
Outil : ImageGen intégré. Seed et version précise du modèle non exposés ; reproduction identique non garantie.
Sortie brute : `candidate_01.png`, copie sans modification de la sortie générée.

## Protocole

1. Générer le cycle complet depuis la référence, sans utiliser les anciennes frames.
2. Contrôler format, alpha et divisibilité de la grille avant toute extraction.
3. Contrôler visuellement les 16 phases, le profil, l'identité et les contacts.
4. Seulement si ces contrôles passent : extraire chronologiquement les cases fixes et vérifier le cycle à 16 fps ; aucune correction individuelle.
5. N'intégrer qu'après validation technique et visuelle, puis validation manuelle en jeu.

## Mesures et observations

- Taille réelle : 1045×1506, au lieu des 1664×2400 demandés.
- Mode Pillow : RGB ; canaux R, G, B ; aucun canal alpha. Transparence réelle impossible dans ce fichier.
- Grille 4×4 : 1045 modulo 4 = 1 ; 1506 modulo 4 = 2. Pas de découpage en 16 cases entières identiques sur le canevas brut.
- Observation visuelle : 16 silhouettes orientées à droite ; les phases de course demandées ne sont pas respectées dans leur ordre, plusieurs poses sont très similaires et les appuis ne constituent pas une alternance crédible démontrée.
- Stabilité du bassin, distance tête-bassin et raccord animé : non mesurés ; rejet préalable sur le format et la séquence visuelle. Aucune prétention de validation de boucle.

## Conclusion

La génération directe d'une planche avec contraintes textuelles ne satisfait pas le contrat sur cet essai. Répéter le même procédé ou détourer ce candidat ne résoudrait pas son défaut de séquence. Le lot est conservé uniquement pour audit ; aucune frame n'a été retouchée, interpolée, réordonnée ou intégrée.

Une piste différente serait un personnage 3D correctement construit et riggé, rendu par caméra orthographique avec matériau et alpha contrôlés, et un cycle de course déterministe à 16 phases. Cela permettrait de contrôler géométriquement caméra, grille et contacts, mais la fidélité graphique resterait à valider. Le rig automatique TripoSR/UniRig déjà essayé est signalé impropre à la livraison dans le contexte projet : ce n'est donc pas une solution prête. Cette piste n'a pas été testée ici et demanderait une reprise du modèle/rig, au-delà de cet essai ImageGen.

## Prompt envoyé

Generate a completely NEW sixteen-frame running animation sprite sheet from the provided validated character reference. Reference is identity only, not an existing animation to edit. Asset type: dark fantasy 2D game animation, detailed painted raster matching reference. Output a PNG with REAL transparent alpha background, not a painted checkerboard, no green background. Exactly 16 full-body poses arranged in a precise 4-column by 4-row regular grid, read left to right then top to bottom. Canvas ideally 1664x2400, each equal cell 416x600. Each character has identical scale and strict RIGHT-FACING ORTHOGRAPHIC SIDE PROFILE; pelvis x=208 within each cell, imaginary ground y=560; all contact soles touch that exact line. No grid lines, numbers, text, shadows, ground artwork or labels. Preserve the same man, black hair, short beard, dark leather armor, torn dark cape, boots and one sheathed sword on back throughout. Generate ALL 16 poses anew as ONE smoothly phased run-in-place cycle, not walking: frame 0 near leg forward contact far leg behind; 1 near leg weight compression; 2 near leg support under hip far knee recovering; 3 near toe pushing off far knee forward; 4 airborne near leg behind far thigh advancing; 5 airborne far knee forward near heel recovering; 6 far leg extends to next contact; 7 far foot approaches ground; 8 far leg forward contact near leg behind; 9 far leg compression; 10 far support under hip near knee recovering; 11 far toe pushing off near knee forward; 12 airborne far leg behind near thigh advancing; 13 airborne near knee forward far heel recovering; 14 near leg extends to next contact; 15 near foot approaches ground leading smoothly back to frame 0. Arms counter-swing naturally, torso inclination consistent, small credible vertical bounce, cape follows motion smoothly. Both feet may be above the common ground in flight phases. Fit entire silhouette including sword and cape inside every equal cell with clear margins. No duplicated or missing limbs, no front or three-quarter rotation. This is a new full cycle, no reuse or rearrangement of old animation frames.
