## v1.1 — 2026-06-21

### Modifié
- Mémoire persistante migrée du dossier auto vers `.claude/memory.md` (manette + règle contrôles)
- CLAUDE.md : commande `/memory` renommée `/create_memory`
- roadmap.md : cases Phase 1 (core) et Phase 2 (core) cochées

---

## v1.0 — 2026-06-21

### Ajouté
- Phase 1 complète : autoload `Inventory` + filons minables (`ore_node.gd`)
- Phase 2 implémentée : établi (`workbench.gd`) + menu craft (`craft_menu.gd`, PROCESS_MODE_ALWAYS) + recettes JSON externalisées
- Manette uniquement : interact=Y, ui_accept=A, ui_cancel=B (joymap.gd)
- Refacto v2 (A+B+C) : `take_damage` unifié, stats joueur pilotables, HUD extrait dans `hud.gd`
- Mode dev navigable (autoload Dev, menu sélection scène)
- Protocole vibecoding v2.2 initialisé (`_contexte/`, `zones.md`, `signals.md`)
