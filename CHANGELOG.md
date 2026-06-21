## v1.2 — 2026-06-21

### Ajouté
- Phase 3 : stats joueur pilotées par équipement crafté (arme 3 paliers, armure 1 palier + damage_reduction)
- Configs externalisées : `game/data/player.json`, `weapons.json`, `armor.json`, `enemies.json`
- Menu dev : option "JOUER 100 MIN" (Dev.dev_resources)

### Modifié
- `enemy_base.gd` : HP et contact_damage chargés depuis enemies.json (contact_damage 1→2)
- `enemy_ground.tscn` : max_hp 4→5
- `player.gd` : constantes de mouvement converties en vars configurables via player.json

---

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
