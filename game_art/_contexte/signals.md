# Signals - game_art

## Actions ouvertes

- [P1] Valider visuellement l'editeur apres suppression du panneau Reference.
  fait quand: `python run_editeur.py` affiche la preview `Produit` centree pour le player et les sprites statiques, sans decalage visible.
  ref: game_art/editeur/main.gd, game_art/editeur/test_preview_center.gd.
- [P2] Valider en jeu les sprites critiques livres cette session.
  fait quand: `boss_guardian_ashes`, `boss_guardian_ashes_pause`, `boss_projectile_ash`, `enemy_ground`, `enemy_flyer`, les gisements dedies (`ore_bois`, `ore_pierre`, `ore_charbon`, `ore_minerai_sombre`, `ore_cristal`, `ore_minerai_celeste`, `ore_fragment_noyau`) et `workbench` sont verifies en jeu sans probleme visible de lisibilite, d'echelle, d'ancrage ou de depart de projectile.
  ref: game/assets/sprites/enemies/, game/assets/sprites/objects/, game/scripts/boss.gd, game/scenes/enemies/boss_projectile.tscn.

## Blocages

## Derniere session
# Session du 2026-07-09

## Decisions prises
- Les PNG player legacy sont archives dans `assets/player/legacy_archive/` et exclus du perimetre de l'audit.
- Les gisements utilisent maintenant des sprites dedies par materiau au lieu du fallback cuivre.
- Le Veilleur des Cendres est livre avec un sprite principal, une pose `pause` vulnérable et un projectile dedie branche jusqu'au runtime.

## Livrables produits ou modifies
- game_art/assets/player/legacy_archive/ : anciens PNG player archives hors audit.
- game_art/assets/objects/ore_*.png, game/data/materials.json : set dedie des gisements complete et branche.
- game_art/assets/enemies/boss_guardian_ashes.png, boss_guardian_ashes_pause.png, boss_projectile_ash.png : set du Veilleur des Cendres livre.
- game_art/data/animations.json, game/data/animations.json, game/scenes/enemies/boss_projectile.tscn, game/scripts/boss.gd, game/scripts/boss_projectile.gd : branchement runtime du Gardien et du projectile d'ash.
- game_art/editeur/audit.gd, game_art/editeur/test_audit.gd, game_art/audit_report.md : audit aligne sur l'archivage des PNG legacy.

## Hypotheses validees / invalidees
- VALIDE : les PNG player legacy peuvent rester comme sources locales a condition d'etre archives et ignores par l'audit.
- VALIDE : le pipeline `generation HD -> detourage -> resize exact` tient pour les gisements dedies et le Gardien.
- EN ATTENTE : validation visuelle en jeu du Veilleur des Cendres, de son projectile et des nouveaux gisements.

## Prochaine etape exacte
Lancer `python run_game.py` et verifier en jeu le depart du projectile depuis le coeur du boss,
la lisibilite du Veilleur des Cendres et l'ancrage des gisements dedies. Puis relancer
`python run_editeur.py` pour valider une derniere fois la preview `Produit`.

## Question bloquante pour la session suivante
Aucune
