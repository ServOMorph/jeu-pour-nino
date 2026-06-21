# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Phase 6 v1 : playtest & ajustements de difficulté boss
  fait quand: run complet jouable de bout en bout, boss équilibré
  réf: game/scripts/boss.gd, game/data/boss.json
- [P2|ouvert] Refacto étape D (externaliser données de niveau) — à faire AU MOMENT de la Phase 5, pas avant
  fait quand: données de niveau dans un fichier JSON externe chargé par level.gd
  réf: game/scripts/level.gd

## Questions ouvertes
(aucune)

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Règle absolue : toute valeur numérique gameplay doit être dans game/data/*.json — aucune constante hardcodée dans les scripts
- Configs JSON : player.json (groupes movement/jump/combat/hurt/aim) / weapons.json / armor.json / enemies.json / boss.json (groupes Boss.physics/charge/slam/volley/flash + BossProjectile)
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 2 ; armure_bois damage_reduction = 1 → 1 dégât avec armure
- Menu dev : JOUER / JOUER 100 MIN / TEST BOSS (Dev.dev_resources injecté dans Inventory après reset)

## Dernière session (2026-06-21 — boss.json + externalisation complète)
# Session du 2026-06-21

## Décisions prises
- boss.json créé : toutes les valeurs gameplay du boss et des projectiles externalisées
- player.json restructuré en 5 groupes cohérents (movement, jump, combat, hurt, aim)
- boss.json structuré en sous-groupes (physics, charge, slam, volley, durations, flash) + BossProjectile
- Règle actée : aucune constante numérique gameplay ne doit rester hardcodée dans les scripts GDScript

## Livrables produits ou modifiés
- game/data/boss.json : créé (Boss + BossProjectile, tous groupés)
- game/data/player.json : restructuré en groupes, 10 nouvelles clés ajoutées (accel, friction, air_accel, max_fall, coyote_time, buffer, cut_factor, screen_shake, invuln_flash_rate, contact_dmg_default, aim.stick_deadzone, hurt.bounce_y, hurt.stun)
- game/scripts/boss.gd : _load_config() complet, toutes constantes → vars lues depuis JSON
- game/scripts/boss_projectile.gd : _load_config() depuis boss.json["BossProjectile"]
- game/scripts/player.gd : _load_configs() adapté aux groupes JSON, _apply_equipment() sans fallbacks hardcodés
- .claude/memory.md : règle externalisation ajoutée

## Hypothèses validées / invalidées
- VALIDE : toutes les valeurs des JSON étaient déjà câblées sauf boss.json (inexistant) et les nouvelles clés ajoutées cette session

## Prochaine étape exacte
Phase 6 v1 : faire un run complet (explore → récolte → craft → boss) et ajuster la difficulté dans boss.json uniquement (HP, dégâts, vitesse projectiles, timings).

## Question bloquante pour la session suivante
Aucune
