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

## Dernière session (2026-06-21 — méta/mémoire)
# Session du 2026-06-21

## Décisions prises
- Mémoire persistante migrée du dossier auto (`memory/`) vers `.claude/memory.md` (manette + règle contrôles ; Ollama exclu)
- CLAUDE.md mis à jour : commande `/memory` → `/create_memory`
- Fichiers du dossier auto `memory/` à supprimer (décision actée, non encore exécutée)

## Livrables produits ou modifiés
- `.claude/memory.md` : créé (synthèse manette PowerA NSW + règle contrôles manette uniquement)
- `.claude/CLAUDE.md` : mis à jour par l'utilisateur

## Hypothèses validées / invalidées
- VALIDE : dossier `memory/` auto contenait une référence morte (`ollama_operational.md` absent)

## Prochaine étape exacte
1. Supprimer les fichiers de `C:\Users\raph6\.claude\projects\d--ServOMorph-Jeu-pour-Nino\memory\`
2. Reprendre Phase 2 : confirmer A (craft) + B (fermer) en jeu, déplacer établi à position définitive
3. Si Phase 2 validée → Phase 3 (stats joueur pilotées par équipement crafté)

## Question bloquante pour la session suivante
Aucune
