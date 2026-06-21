# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Phase 2 : confirmer A (craft) + B (fermer) fonctionnels en jeu, déplacer établi de x=150 (debug) à position définitive
- [P1|ouvert] Phase 3 : stats joueur pilotées par l'équipement crafté (3 paliers arme, 1-2 paliers armure)
- [P2|ouvert] Refacto étape D (externaliser données de niveau) — à faire AU MOMENT de la Phase 5, pas avant
- [P2|ouvert] Phase 6 v1 : playtest & ajustements de difficulté boss

## Questions ouvertes
- A (craft) confirmé fonctionnel en jeu après les derniers fixes joymap ?

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Mode dev menu (sélection navigable + A pour valider) opérationnel — architecture scalable via Dev autoload
- `take_damage(amount, knockback: Vector2)` : signature unique pour TOUS les receveurs (player, boss, enemy_base)
- Stats joueur pilotables : `max_hp`, `attack_damage`, `attack_range` sont des `var` dans player.gd
- HUD = `hud.gd` autonome (setup/show_boss_bar/hide_boss_bar)
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Établi à x=150 (DEBUG) — à déplacer à sa position définitive avant livraison Phase 2

## Dernière session (2026-06-21)
# Session du 2026-06-21

## Décisions prises
- Phase 1 complète : autoload `Inventory` + filons minables dans le niveau
- Phase 2 implémentée : établi interactif + menu de craft + recettes JSON externalisées
- Manette uniquement : `interact`→Y, `ui_accept`→A, `ui_cancel`→B ajoutés dans joymap.gd
- `_process` + `PROCESS_MODE_ALWAYS` retenu pour craft_menu (plus fiable qu'`_input` en pause)

## Livrables produits ou modifiés
- game/scripts/inventory.gd : créé (autoload Inventory — resources, items, spend, add_item, has_item)
- game/scripts/ore_node.gd : créé (filons minables, PV propres, drop ressources)
- game/scripts/workbench.gd : créé (StaticBody2D, zone Area2D mask=2, signal interact_requested)
- game/scripts/craft_menu.gd : créé (CanvasLayer layer=10, PROCESS_MODE_ALWAYS, pause run)
- game/data/recipes.json : créé (3 recettes externalisées)
- game/scripts/joymap.gd : étendu (interact=Y, ui_accept=A, ui_cancel=B)
- game/scripts/level.gd : étendu (_spawn_workbench, établi à x=150 debug)

## Hypothèses validées / invalidées
- VALIDE : collision_mask=2 obligatoire (player sur layer 2, pas layer 1)
- VALIDE : `_process` + PROCESS_MODE_ALWAYS plus fiable qu'`_input` pendant pause
- VALIDE : Godot UI defaults ne bindent pas JOY_BUTTON_A/B → ajout explicite requis
- INVALIDE : JOY_BUTTON_X pour interact → conflit avec `ui_up` Godot → pivot : JOY_BUTTON_Y
- EN ATTENTE : confirmation A (craft) et B (fermer) opérationnels après fix joymap

## Prochaine étape exacte
1. Confirmer A (craft) + B (fermer) fonctionnels en jeu
2. Déplacer l'établi de x=150 (debug) à sa position définitive dans le niveau
3. Si Phase 2 validée → attaquer Phase 3 (stats joueur pilotées par équipement crafté)

## Question bloquante pour la session suivante
A (craft) confirmé fonctionnel en jeu après les derniers fixes joymap ?
