# Roadmap v1 — CoreDive Challenge (biome 1 jouable, combat de base, un boss)

*Roadmap de développement pour Godot. Chaque phase se termine par un jalon testable, pour avancer par petites itérations jouables plutôt que par gros blocs invisibles.*

## Objectif de la v1

Une boucle complète et jouable : le joueur démarre dans le biome 1 (niveau **conçu à la main**, pas encore généré procéduralement), se déplace, combat quelques ennemis basiques, puis affronte un boss. Victoire ou défaite, avec un écran de fin et la possibilité de relancer. C'est la base de gameplay sur laquelle tout le reste (craft, génération procédurale, biomes 2/3, méta-progression) viendra se greffer ensuite.

---

## Phase 0 — Mise en place du projet

- [ ] Créer le projet Godot (figer une version, ex. Godot 4.x, pour éviter les surprises de compatibilité)
- [ ] Définir une résolution de base basse (ex. 320×180 ou 480×270) avec mise à l'échelle entière (Project Settings > Display > Window) pour un rendu pixel art net
- [ ] Désactiver le filtrage des textures (Project Settings > Rendering > Textures > Default Texture Filter = Nearest)
- [ ] Mettre en place l'arborescence : `scenes/player`, `scenes/enemies`, `scenes/levels`, `scenes/ui`, `scripts/`, `assets/sprites`, `assets/tilesets`, `resources/`
- [x] Configurer l'Input Map : gauche/droite, saut, attaque (clavier/souris + manette PowerA NSW via joymap.gd)
- [ ] Récupérer un pack d'assets pixel art placeholder (gratuit, ex. Kenney.nl, itch.io) pour ne jamais être bloqué par l'art pendant le prototypage

**Jalon** : projet Godot vide qui se lance, structure de dossiers prête.

---

## Phase 1 — Personnage & déplacements

- [ ] Scène Player : `CharacterBody2D` + `AnimatedSprite2D` + `CollisionShape2D`
- [ ] Script de mouvement : gauche/droite, gravité, saut (ajouter un peu de tolérance — "coyote time", buffer de saut — pour un meilleur feel dès le départ)
- [ ] Animations placeholder : idle, run, jump/fall
- [ ] `Camera2D` qui suit le joueur, avec limites
- [ ] Scène de test : une plateforme plate pour valider le mouvement isolément

**Jalon** : le joueur se déplace et saute dans une scène vide, et le mouvement "feel" bien (pas flottant, pas trop rigide) — c'est la base sur laquelle tout le reste repose, ça vaut le coup d'itérer ici avant d'avancer.

---

## Phase 2 — Niveau du biome 1 (version statique)

- [ ] Créer un `TileSet` pour le biome 1 (sol, murs, fond, décor — placeholder ok)
- [ ] Construire à la main un niveau représentatif : un parcours avec quelques plateformes/obstacles, menant à une arène finale pour le boss
- [ ] Définir la zone de spawn du joueur et les limites du niveau
- [ ] Ajuster les limites de la `Camera2D` au niveau

> Pour cette v1, le niveau est fait à la main — la génération procédurale (cf. GDD section 3) viendra remplacer ce niveau statique plus tard, une fois le gameplay validé. Ça évite de cumuler deux problèmes (gameplay + génération) en même temps.

**Jalon** : le joueur peut parcourir le niveau du début jusqu'à l'arène du boss, sans bug de collision.

---

## Phase 3 — Combat de base & premiers ennemis

- [ ] Système de santé du joueur : variable HP, fonction `take_damage()`, mort → signal "game over"
- [ ] Attaque de mêlée : animation + hitbox temporaire (`Area2D`) activée pendant l'animation
- [ ] Système hitbox/hurtbox générique, réutilisable pour le joueur et les ennemis
- [ ] Feedback visuel des coups : flash sur l'ennemi touché, léger recul (knockback) — important pour le ressenti, peu coûteux à faire
- [ ] 1 à 2 types d'ennemis basiques pour le biome 1 (ex. un ennemi au sol qui patrouille et attaque au contact ; éventuellement un ennemi volant simple), avec script générique (PV, dégâts, détection du joueur)
- [ ] Placer ces ennemis dans le niveau

**Jalon** : le joueur peut frapper et tuer les ennemis du biome 1, et peut mourir s'il prend trop de dégâts (game over basique, même un simple restart de la scène pour l'instant).

---

## Phase 4 — Le boss

- [ ] Concevoir l'arène du boss (espace dégagé, lisible, sans éléments parasites)
- [ ] Scène du boss : PV élevés, sprite distinct (même placeholder, mais visuellement différencié)
- [ ] 2 à 3 patterns d'attaque via une machine à états simple (ex. `idle → charge au sol → pause → attaque de zone → pause → projectile → ...`)
- [ ] Barre de vie du boss affichée pendant le combat
- [ ] Déclenchement du combat (ex. porte qui se ferme à l'entrée de l'arène, ou activation au contact)
- [ ] Condition de victoire : boss vaincu → écran "Victoire / Noyau atteint"

**Jalon** : le joueur peut affronter le boss, perdre ou gagner, avec un retour clair à l'écran dans les deux cas. C'est le cœur du "défi" — prévoir du temps pour itérer sur les patterns jusqu'à ce que le combat soit lisible et juste.

---

## Phase 5 — Boucle de jeu complète & HUD

- [ ] HUD joueur : barre de vie (et éventuellement un repère de progression dans le niveau)
- [ ] Écran de game over avec "Réessayer" (recharge la scène du niveau)
- [ ] Écran de victoire (boss vaincu)
- [ ] Écran de titre minimal avec "Jouer"
- [ ] Sons/musique basiques (placeholder) : coups, dégâts, ambiance, musique de boss

**Jalon** : on lance le jeu depuis le menu, on joue un run complet (début → boss → victoire ou défaite), et on peut relancer sans bug. **C'est la v1 testable.**

---

## Phase 6 — Playtest & ajustements

- [ ] Tester toi-même en te mettant "à la place d'un nouveau joueur"
- [ ] Si possible, faire tester par une tierce personne sans lui expliquer les contrôles au préalable
- [ ] Ajuster l'équilibrage : dégâts, PV, vitesse des ennemis/boss, durée du niveau
- [ ] Corriger les bugs de collision/animation les plus gênants
- [ ] Noter les retours pour la suite (ce qui manque, ce qui frustre, ce qui marche bien)

**Jalon** : v1 stable, jouable de bout en bout, avec une difficulté qui semble "juste" — ni trivial, ni impossible.

---

## Après la v1

Une fois ce socle solide et amusant, les prochaines étapes (déjà esquissées dans le GDD) sont :

- Craft & équipement (GDD section 5)
- Génération procédurale du biome 1, pour remplacer le niveau statique (GDD section 3)
- Biomes 2 et 3 + zone du Noyau et son boss final
- Progression méta & hub entre les runs (GDD section 6)

---

## Astuces pour avancer efficacement

- Utiliser des assets placeholder gratuits dès le départ pour ne jamais être bloqué par l'art pendant que le gameplay se construit — on remplace par de l'art final plus tard.
- Tester après chaque tâche cochée plutôt qu'à la fin d'une phase entière : ça permet de repérer un mouvement "pas fun" ou un combat "pas lisible" tôt, avant d'avoir construit du contenu par-dessus.
- Versionner avec git dès le début, même en solo : un commit par jalon (fin de phase) donne des points de retour en arrière propres.
- Résister à l'envie d'ajouter du contenu (craft, procédural, biomes suivants) avant que les fondamentaux — déplacement, combat, boss — ne soient déjà "fun" tout seuls. C'est ce socle qui déterminera le ressenti global du jeu.