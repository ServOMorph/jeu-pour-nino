# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Roadmap v2 Phase 1 : singleton `Inventory` + filons de ressources
- [P2|ouvert] Refacto étape D (externaliser données de niveau) — à faire AU MOMENT de la Phase 5, pas avant
- [P2|ouvert] Phase 6 v1 : playtest & ajustements de difficulté boss

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Mode dev menu (sélection navigable + A pour valider) opérationnel — architecture scalable via Dev autoload
- `take_damage(amount, knockback: Vector2)` : signature unique pour TOUS les receveurs (player, boss, enemy_base). Tout nouvel appelant doit passer un Vector2.
- Stats joueur pilotables : `max_hp`, `attack_damage`, `attack_range` sont des `var` dans player.gd (prêtes pour la Phase 3 équipement)
- HUD = `hud.gd` autonome (setup/show_boss_bar/hide_boss_bar) ; le HUD ressources Phase 1 s'y greffe

## Dernière session (2026-06-21)
# Session du 2026-06-21

## Décisions prises
- Refacto préparatoire v2 ciblée : étapes A+B+C avant la Phase 1, étape D reportée à la Phase 5
- A : interface `take_damage` unifiée en `(int, Vector2)` partout
- B : stats joueur (max_hp, attack_damage, attack_range) sorties des const vers var
- C : HUD extrait de level.gd vers hud.gd autonome

## Livrables produits ou modifiés
- game/scripts/player.gd : signature take_damage unifiée, stats en var
- game/scripts/boss.gd : _slam_impact passe un Vector2
- game/scripts/boss_projectile.gd : fix régression — passait un float au lieu de Vector2
- game/scripts/hud.gd : créé (CanvasLayer autonome)
- game/scripts/level.gd : HUD retiré (237 → 187 lignes), branche hud.gd

## Hypothèses validées / invalidées
- VALIDE : refacto A+B+C — jeu entier retesté manuellement OK
- INVALIDE puis corrigé : refacto A avait raté boss_projectile.gd → tirs boss sans effet, fix appliqué et validé

## Prochaine étape exacte
Attaquer roadmap v2 Phase 1 : autoload `Inventory` (compteurs réinitialisés par run) + nœuds filons minables (PV propres, drop au cassage, feedback flash/particules/son) + HUD ressources discret.

## Question bloquante pour la session suivante
Aucune
