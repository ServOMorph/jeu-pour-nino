# Contexte — jeu

## Objectif (immuable sauf décision explicite)
Jeu de plateforme/action pixel art fait pour Nino. Roguelite : exploration de biomes, craft, mort-résurrection, boss adaptatif. Cible finale : CoreDive Challenge v3.

## Stack / contraintes techniques (stable, rarement modifié)
- Godot 4.5
- GDScript

## État actuel (réécrit intégralement à chaque /close)
**Phase 3 livrée côté code — validation manuelle J1 non faite.** Le HUB est jouable avec quatre portails, Grimoire, établi tier 1 et soin complet à l'entrée ; `GameFlow` centralise le run multi-biomes.
Un outil stabilise les candidats `player/run` par détourage chroma/alpha, échelle uniforme, ligne de sol et assembly de sheet.
Le premier lot ImageGen de 16 frames passe les contrôles techniques mais échoue visuellement ; la sheet runtime validée est restaurée.
L'autorisation utilisateur de correction géométrique automatique vaut seulement pour les candidats `player/run`, jamais pour une intégration sans validation.
Prochaine étape : produire un lot de poses cohérent, puis vérifier le HUB en jeu et valider J1 avant la Phase 4.

## Décisions structurantes (append only — 10 entrées max, archiver au-delà)
- 2026-07-11 : Bug de compilation `equipment_menu.gd` (`SLOT_ORDER` non typé) corrigé ; affichage équipement retravaillé.
- 2026-07-11 : Validation manuelle Phase 2 engagée — deux blocages identifiés (découverte de recettes absente, sélection consommable sans effet visible) à traiter en priorité avant de clore la Phase 2.
- 2026-07-12 : Validation manuelle Phase 2 complétée (sections 1-9, sans anomalie bloquante). Diagnostic 8.6 : faux bug, comportement correct.
- 2026-07-12 : `discover_recipe()` branché sur victoire boss uniquement (3/20 recettes non-starter) — triggers salle/porteur attendent des systèmes non développés (biomes multiples, porteurs).
- 2026-07-12 : Audit mémoire projet + pivot pixel art — `.claude/memory.md` corrigé (bindings manette, dimensions player) ; confirmé qu'aucune trace active de l'ancien pixel art ne subsiste côté jeu, hors `ref_to_sprite.py` (dette game_art, tracée dans `backlog_art.md`).
- 2026-07-14 : Phase 3 livrée côté code — autoload `GameFlow` (unique point de `RunState.reset()`), HUB (`hub.tscn`/`hub.gd`/`hub.json`), scène de biome générique paramétrée par `next_biome_id`, portail de sortie volontaire, soin complet au HUB, boss vaincu mémorisé par biome. Battre un boss de biome ne termine plus le run (retour HUB). Abandon de run via la pause traité comme un run raté (PC ×0.5) — décision à confirmer. Validation en jeu du jalon J1 reportée à la session suivante.
- 2026-07-12 : P1 restant de Phase 2 complété — barème PC, armes à distance (bouton `attack` partagé avec le mêlée, sans bouton dédié, décision explicite utilisateur), outils dev unifiés menu titre/pause via l'autoload `Dev`, défilement ajouté à `craft_menu.gd`/`grimoire_menu.gd`. GUT 40/40 vert, validation manuelle complète (12 sections). 2 tâches mineures de Phase 2 restent ouvertes dans `roadmap.md` (hors périmètre demandé).
- 2026-09-13 : Composition visuelle du HUB fixée : quatre portails intégrés au fond plein écran sur la ligne de marche, sans noms ni placeholders ; établi décalé à droite.
- 2026-09-13 : Refonte `player/run` non intégrée : les candidats ImageGen et WanGP échouent respectivement les contraintes d'alpha/grille et de profil droit ; un workflow dédié doit être recherché avec Astra.
- 2026-09-13 : Pour les candidats `player/run`, l'utilisateur autorise la stabilisation géométrique automatique. Le premier lot 16 frames passe alpha/grille/appuis mais est rejeté visuellement ; la sheet runtime est restaurée.
