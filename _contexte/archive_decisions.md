# Archive — Décisions structurantes

- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
- 2026-06-21 : Mode dev intégré au menu (navigable, autoload Dev, registre _spawn_points() scalable).
- 2026-06-21 : JUMP_VELOCITY -250 → -320 pour permettre le saut par-dessus le boss.
- 2026-06-21 : Refacto v2 cadrée — A+B+C avant Phase 1, étape D (données niveau externalisées) reportée à la Phase 5.
- 2026-06-21 : `take_damage(int, Vector2)` = interface unique pour tous les receveurs de dégâts.
- 2026-06-21 : Stats joueur (max_hp, attack_damage, attack_range) en var, pilotables par le futur équipement.
- 2026-06-21 : HUD extrait dans hud.gd autonome (découplé de level.gd).
- 2026-06-21 : Phase 1 complète — autoload Inventory + filons minables.
- 2026-06-21 : Phase 2 complète — établi + craft_menu (CanvasLayer, PROCESS_MODE_ALWAYS) + recettes JSON externalisées.
- 2026-06-21 : Manette uniquement pour nouvelles actions — ui_accept=A, ui_cancel=B, interact=Y (joymap.gd).
- 2026-06-21 : Phase 3 complète — stats joueur pilotées par équipement via weapons.json / armor.json.
- 2026-06-21 : Configs externalisées : player.json, weapons.json, armor.json, enemies.json.
- 2026-06-21 : contact_damage ennemis = 2 ; armure_bois damage_reduction = 1.
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
- 2026-06-21 : Toutes valeurs gameplay dans game/data/*.json — aucune constante numérique dans les scripts.
