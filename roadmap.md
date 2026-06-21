# Roadmap v2 — CoreDive Challenge (la boucle de ressources & de craft)

*Roadmap de développement pour Godot. Chaque phase se termine par un jalon testable, pour avancer par petites itérations jouables plutôt que par gros blocs invisibles.*

> **v1 livrée** : squelette d'action complet — déplacement, combat de base, un boss, boucle complète (titre → run → victoire/défaite → relance), biome 1 fait main, support manette PowerA NSW. Voir l'historique git et `game/README.md`.

## Objectif de la v2

Transformer le couloir-combat de la v1 en un vrai **run façon Terraria** : le joueur **récolte des ressources** en chemin, les **fabrique en équipement** à un établi, et **devient tangiblement plus fort *pendant* le run** avant d'affronter le boss. C'est le cœur de l'ADN du jeu (GDD §5) et le signal le plus fort du profil joueur (244 h de Terraria, 488 h de 2D crafting/survie) — donc l'ajout le plus rentable maintenant.

On **n'ajoute pas encore** la génération procédurale, le hub méta, ni les biomes 2/3 : on prouve d'abord que la boucle de craft est amusante, sur le biome 1 enrichi. Même discipline que la v1 (ne pas empiler deux gros chantiers à la fois).

**Décisions de cadrage v2** :
- **Périmètre** : boucle de craft seule (ressources + établi + paliers d'équipement + consommables), biome 1 enrichi.
- **À la mort** : tout l'équipement et toutes les ressources sont perdus (GDD §5, tension maximale du run). La persistance méta (monnaie, déblocages, hub) arrive en v3.

---

## Phase 1 — Récolte de ressources

- [x] Singleton autoload `Inventory` : compteurs de ressources du run (réinitialisé à chaque nouveau run)
- [x] Nœuds de ressources placés dans le niveau : filons minables (ex. pierre, cuivre), PV propres au filon
- [x] Récolte : le coup d'arme (ou une action dédiée) endommage puis casse un filon → drop de ressources dans l'inventaire
- [x] Feedback de récolte fort : flash du filon, particules, son — c'est ce qui rend la boucle satisfaisante (plus que le visuel)
- [x] Affichage HUD discret des ressources collectées

**Jalon** : on parcourt le niveau, on casse des filons, le compteur monte avec un retour visuel/sonore satisfaisant. C'est le premier "plaisir Nino" du run.

---

## Phase 2 — Établi & craft

- [x] Station **établi/forge** posée dans le niveau (`Area2D` + prompt "interagir", manette Y)
- [x] Menu de craft minimal (3 recettes) : `ressource(s) → objet`, ouverture/fermeture propre (pause du run pendant le menu)
- [x] Données de recettes externalisées (JSON) — réutilisable tel quel pour les futurs biomes
- [x] Validation : impossible de crafter sans les ressources requises (feedback clair)

**Jalon** : on s'approche de l'établi, on ouvre le menu, on fabrique un objet en dépensant ses ressources, le menu se referme et le run reprend.

---

## Phase 3 — Paliers d'équipement

- [x] Rendre les stats du joueur pilotables par l'équipement équipé (aujourd'hui en dur dans `player.gd` : dégâts, portée, PV max…)
- [x] 3 paliers d'arme craftables : bois → cuivre → fer (dégâts / portée croissants)
- [x] 1-2 paliers d'armure : réduction de dégâts ou +PV max
- [x] Équipement automatiquement actif une fois crafté (pas de gestion d'inventaire complexe en v2)
- [x] Feedback visuel du palier (couleur de l'arme / du joueur change) pour rendre la progression lisible

**Jalon** : crafter une meilleure arme rend les combats nettement plus faciles → **sensation de progression *pendant* le run**, pas seulement entre les runs.

---

## Phase 4 — Consommables & tension du run

- [x] Potion de soin craftable (rend des PV)
- [ ] 1-2 autres consommables simples (ex. bombe, ou grappin de déplacement — cité au GDD §5 comme excellent modèle)
- [x] Slot de consommable + touche d'usage (clavier + manette)
- [x] **Tout est perdu à la mort** (équipement + ressources + consommables) — la persistance méta, c'est v3

**Jalon** : on doit arbitrer ses ressources entre "crafter une meilleure arme" et "garder de quoi se soigner" → vraie décision de run, vraie tension.

---

## Phase 5 — Niveau étendu & rééquilibrage

- [x] Allonger / densifier le niveau biome 1 pour laisser de la place à la récolte et au craft (le couloir actuel ~1600px est trop court pour une boucle de craft)
- [x] Répartir filons et établi(s) pour rythmer le run (récolter avant l'établi, crafter avant le boss)
- [x] Rééquilibrer PV/dégâts des ennemis et du boss en tenant compte des paliers d'équipement (le boss doit rester un vrai mur sans bon stuff)
- [x] Ajuster les limites de la `Camera2D` au niveau étendu

**Jalon** : un run complet "explore → récolte → craft → boss" qui dure ~8-15 min et **donne envie de recommencer**. **C'est la v2 testable.**

---

## Phase 6 — Playtest & ajustements

- [x] Tester soi-même "à la place d'un nouveau joueur" : la boucle de craft est-elle lisible et gratifiante ?
- [x] Vérifier que la progression d'équipement se *ressent* clairement en combat
- [x] Équilibrer le coût des recettes (ni trop grindy, ni trivial) et le taux de drop des filons
- [x] Corriger les bugs les plus gênants (récolte, menu de craft, équipement)
- [ ] Noter les retours pour la v3 (ce qui manque, ce qui frustre, ce qui marche)

**Jalon** : v2 stable, jouable de bout en bout, avec une boucle de craft qui semble "juste" — gratifiante sans être pénible.

---

## Après la v2

Une fois la boucle de craft prouvée amusante, la trajectoire (alignée sur le GDD) :

- **v3 — Génération procédurale + hub méta** : génération du biome 1 (automate cellulaire ou rooms connectées, GDD §3/§11) pour remplacer le niveau statique, et hub entre les runs avec monnaie persistante + déblocages (GDD §6). La persistance "tout perdu à la mort" de la v2 devient alors "tout perdu sauf la monnaie méta".
- **v4 — Biomes 2 & 3 + Noyau** : contenu réplicable grâce au système de données par biome posé en v2 (ennemis, recettes, tileset) + boss final (GDD §10).
- **v5 — Polish** : art final (remplacer les Polygon2D placeholder), vrais sons/musique, équilibrage global de la difficulté.

---

## Astuces pour avancer efficacement

- Garder les assets placeholder (Polygon2D de couleur) tant que la boucle de craft n'est pas validée — l'art final, c'est le polish (v5).
- Externaliser dès la v2 les données (recettes, plus tard ennemis/ressources) dans des `Resource`/JSON : chaque futur biome ne sera qu'un jeu de données réutilisant le même code.
- Tester après chaque tâche cochée plutôt qu'à la fin d'une phase : repérer tôt une récolte "pas satisfaisante" ou un craft "pas lisible".
- Un commit par jalon (fin de phase) pour des points de retour propres.
- Résister à l'envie d'attaquer le procédural ou les biomes suivants avant que la boucle récolte/craft/équipement ne soit déjà "fun" toute seule sur le biome 1.
