# Archive — Décisions structurantes

## Archivées le 2026-09-13

- 2026-07-11 : Menu titre/dev reformaté (suppression hint manette, menu dev tenant dans la fenêtre).
- 2026-07-07 : Pivot pixel art → 2D standard acté. Résolution 1920×1080 conservée. Pipeline de production : génération Codex + rescale.
- 2026-07-08 : Migration résolution 1920×1080 validée formellement côté jeu (GUT + headless + test manuel).
- 2026-07-08 : Socle Phase 2 branché côté jeu — schéma recettes cible, Grimoire dev, équipement via pause, craft filtré par maîtrise/tier.

- 2026-07-06 : Gating de minage Phase 1 branché via `weapons.json` ; setup de test atelier ajouté pour tiers 2/3 ; sprite `minerai_abyssal` à produire côté game_art.
- 2026-07-06 : Phase 1 close — run manuel complet validé, sprites `minerai_abyssal`/`fer` intégrés.
- 2026-07-06 : Périmètre de `game_art/roadmap_editeur.md` clarifié — l'éditeur couvre sprites/animations d'entités uniquement, pas tilesets/parallax/shaders/icônes UI ; passe en maintenance après Phase 5.
- 2026-07-06 : Taille player conservée telle que validée en jeu pour la suite de la production.
- 2026-07-06 : Phase 0 validée — `inventory.gd` supprimé, 20 tests GUT verts, run complet manuel OK.

- 2026-07-02 : Dette bloquante identifiée — 3 appels résiduels à `Inventory` (autoload supprimé) font crasher le jeu ; correction requise avant validation Phase 0.
- 2026-06-30 : Phase 0 implémentée — RunState/MetaState/SaveManager autoloads, Inventory retiré, GUT v9.7.0 installé, 20 tests Phase 0 écrits.
- 2026-07-02 : Phase 5 — persistance de l'état du biome à la résurrection tranchée : scène biome conservée en mémoire (detach/reattach) plutôt que sérialisation complète, jugée plus simple et moins risquée.
- 2026-07-02 : Roadmap réordonnée — mort/résurrection/cicatrices avant contenu biomes 2/3/4 ; jalons jouables J1-J7 ; placeholders systématiques (aucune phase jeu n'attend game_art) ; Miroir du Noyau limité à 2 paramètres (backlog post-v3 pour boss vaincus/style de jeu).
- 2026-07-02 : Objectif de couverture de tests 85 % sur la logique data-driven/état ; jalon de refacto R1.5 ajouté après Phase 4.
- 2026-06-21 : v1 complète — Phase 6 v1 validée, run complet de bout en bout fonctionnel.
- 2026-06-21 : Menu titre 2 niveaux — sous-menu dev avec toggle 100 MIN et spawn atelier (title.gd refonte complète).
- 2026-06-25 : Données de niveau externalisées dans game/data/level.json, chargé par level.gd.
- 2026-06-25 : Roadmap active v2.1 — retours playtest avant v3, ancienne v2 archivée.
- 2026-06-25 : v2.1 gameplay — potions empilables, monnaie de run, sprint au sol, respawn mobs, boss durci.
- 2026-06-25 : v2.1 validée utilisateur — gameplay testé nickel, correctifs finaux intégrés.
- 2026-06-25 : Sprites finaux générés un par un selon docs/process_generation_sprites.md, pas par découpe de planche.
- 2026-06-25 : Menu pause runtime sur Start — quitter ferme le programme, dev runtime sans redémarrage sauf téléports.
- 2026-06-25 : Animations branchées sur un driver partagé animation_driver.gd piloté par game/data/animations.json.
- 2026-06-25 : Nouvelle cible visuelle personnages type Terraria — player 40x56, attaque 48x56, idle v2 intégré pour test.

- 2026-06-21 : Initialisation du protocole vibecoding.
- 2026-06-21 : Adoption du protocole vibecoding v2.2 — gestion contexte inter-sessions via /start /close.
- 2026-06-21 : Mode dev intégré au menu (navigable, autoload Dev, registre _spawn_points() scalable).
- 2026-06-21 : JUMP_VELOCITY -250 → -320 pour permettre le saut par-dessus le boss.
- 2026-06-21 : Refacto v2 cadrée — A+B+C avant Phase 1, étape D (données niveau externalisées) reportée à la Phase 5.
- 2026-06-21 : `take_damage(int, Vector2)` = interface unique pour tous les receveurs de dégâts.
- 2026-06-21 : Stats joueur (max_hp, attack_damage, attack_range) en var, pilotables par le futur équipement.
- 2026-06-21 : HUD extrait dans hud.gd autonome (découplé de level.gd).
- 2026-06-21 : Phase 1 complète — autoload Inventory + filons minables.
- 2026-06-21 : Phase 2 complète — établi + craft_menu (CanvasLayer, PROCESS_MODE_ALWAYS) + recettes JSON externalisées.
- 2026-06-21 : Manette uniquement pour nouvelles actions — ui_accept=A, ui_cancel=B, interact=Y (joymap.gd).
- 2026-06-21 : Phase 3 complète — stats joueur pilotées par équipement via weapons.json / armor.json.
- 2026-06-21 : Configs externalisées : player.json, weapons.json, armor.json, enemies.json.
- 2026-06-21 : contact_damage ennemis = 2 ; armure_bois damage_reduction = 1.
- 2026-06-21 : Menu dev — option "JOUER 100 MIN" (Dev.dev_resources injecté après Inventory.reset()).
- 2026-06-21 : Toutes valeurs gameplay dans game/data/*.json — aucune constante numérique dans les scripts.
- 2026-06-27 : Affichage plein écran 1920×1080 (viewport pixel 480×270 ×4, nearest).
- 2026-06-27 : Contrôles clavier complets ajoutés (flèches, Z, E, R, Shift, Echap) — manette conservée.
- 2026-06-27 : game_art/ = source de vérité sprites/animations ; sync.py → game/ ; zone jeu ne gère plus les sprites.
- 2026-06-27 : Design document v3 rédigé — 4 biomes libres, Grimoire/PC, mort-résurrection/Voile, cicatrices shaders, boss adaptatif modulaire.
- 2026-06-27 : Génération biomes = templates assemblés (PCG pur écarté).
- 2026-06-27 : Roadmap v3 créée — 11 phases, jalons refacto R1/R2/R3, stratégie tests GUT. Pas de rewrite : noyau gameplay conservé.
- 2026-07-03 : Convention confirmée — aucun `.import` sous `game/assets/sprites/` ; toute texture PNG s'y charge en runtime (`Image.load_from_file`), jamais via `preload()` direct (sinon crash au lancement sans indexation éditeur préalable).
- 2026-07-05 : Phase 2 game_art (2.1 à 2.4) close — validation visuelle jeu/éditeur confirmée par l'utilisateur.
- 2026-07-06 : 77+1 questions de conception v3 tranchées (`questions.md`) — run multi-biomes, planchers durs de cicatrices, 4 slots d'équipement, armes à distance, 1 seul Gardien du Voile au lancement, rareté réalignée, solo strict, audio reporté en fin de projet.
- 2026-07-06 : `roadmap.md`, `docs/v3/*.md` et `game_art/backlog_art.md` mis à jour en cohérence avec `questions.md` ; développement prévu via 2 agents séparés (jeu et game_art).
