# Archive décisions — game_art

- game_art/ = racine du projet Godot éditeur (res:// pointe ici)
- game/assets/sprites/ et game/data/animations.json = copies générées (ne pas éditer manuellement)
- Format sprites cible = spritesheets (grille de frames, découpe AtlasTexture)
- Schéma animations.json étendu avec champs sheet/frame_size/frames (rétro-compatible)
- Périmètre zone game_art : éditeur + sprites + animations. Contrôles et affichage = zone jeu.
- Typage GDScript des scripts sans class_name : préférer `const X := preload("res://...")`
  + `var v: X` plutôt que `class_name`, pour rester robuste sans cache `.godot/` généré.
- UI multi-panneaux : ne jamais mettre plus de 2 enfants dans un `HSplitContainer`
  (comportement non defini / superposition) ; imbriquer des splits si besoin d'un 3e panneau.
- Sauvegarde `animations.json` : toujours appeler `JSON.stringify(data, indent, false)`
  (sort_keys=false explicite) ; le defaut Godot reordonne tout le fichier.
- Verification des changements GDScript sans interaction souris/clavier : privilegier
  les scripts de test headless qui appellent directement `main.gd`/`inspector.gd`.
- L'inspecteur doit rester utilisable en demi-ecran : panneau droit compact,
  controles empiles si necessaire, pas de dependance a un scroll horizontal.
- `player.run.fps` est valide a 8.1 depuis la cloture Phase 3.3 du 2026-07-05.
- Le manifest d'audit utilise un schema par etat, pas par entite, pour supporter
  des tailles differentes comme `player.attack` en `129x150`.
- Les regressions de la phase audit sont verifiees en headless via
  `test_audit.gd` et `test_audit_ui.gd`.
- Pour les petits sprites gameplay, le process valide etait : reference visuelle,
  production directe a la taille finale sur grille, palette limitee, preview x8,
  puis validation. Une reduction d'image IA ne devait pas etre livree comme asset final.
