# Signals — jeu   (MAJ 2026-06-21)

## Actions ouvertes
- [P1|ouvert] Phase 6 : playtest & ajustements (en cours)
- [P2|ouvert] Démarrer boucle de ressources & craft (roadmap v2)

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Mode dev menu (sélection navigable + A pour valider) opérationnel — architecture scalable via Dev autoload

## Dernière session (2026-06-21)
# Session du 2026-06-21

## Décisions prises
- Mode dev intégré au menu titre : sélection navigable (flèches/stick), confirmation A
- Architecture spawn dev via autoload `Dev` (scalable) + registre `_spawn_points()` dans level.gd
- Hauteur de saut augmentée : JUMP_VELOCITY -250 → -320 (saut jouable par-dessus le boss)

## Livrables produits ou modifiés
- game/scripts/title.gd : menu navigable avec items JOUER / TEST BOSS
- game/scripts/level.gd : class_name supprimé, registre _spawn_points(), résolution via Dev.spawn
- game/scripts/dev.gd : autoload créé (Dev.spawn)
- game/project.godot : autoload Dev ajouté
- game/scripts/player.gd : JUMP_VELOCITY -250 → -320

## Hypothèses validées / invalidées
- VALIDE : autoload = solution correcte pour partager état inter-scènes sans cache éditeur
- INVALIDE : class_name Level + static var → ne fonctionne pas sans éditeur ouvert (cache manquant)
- VALIDE : tous les tests manuels OK (menu, spawn boss, saut)

## Prochaine étape exacte
Continuer phase 6 : ajustements de difficulté boss (dégâts, patterns, timings).
Puis roadmap v2 — boucle de ressources & craft.

## Question bloquante pour la session suivante
Aucune
