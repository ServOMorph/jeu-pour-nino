# Signals — jeu   (MAJ 2026-06-25)

## Actions ouvertes

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\Godot\godot.exe` ; le PATH utilisateur expose `godot` dans les nouveaux terminaux
- Manette : interact=JOY_BUTTON_Y, ui_accept=JOY_BUTTON_A, ui_cancel=JOY_BUTTON_B (tous dans joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- craft_menu.gd : PROCESS_MODE_ALWAYS + _process (pas _input) pour input fiable en pause
- Règle absolue : toute valeur numérique gameplay doit être dans game/data/*.json — aucune constante hardcodée dans les scripts
- Configs JSON : player.json / weapons.json / armor.json / enemies.json / boss.json / level.json
- Stats équipement chargées au runtime — _apply_equipment() connecté à Inventory.items_changed
- contact_damage ennemis = 2 ; armure_bois damage_reduction = 1 → 1 dégât avec armure
- Menu titre 2 niveaux : accueil (JOUER / MODE DEV) → sous-menu dev (toggle 100 MIN / JOUER / ATELIER / TEST BOSS / RETOUR)
- Spawn "atelier" : défini dans game/data/level.json, sans ennemis
- craft_menu.gd : PH calculé dynamiquement = 26 + recipes.size() * ROW_H + 20
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-25 — externalisation niveau)
# Session du 2026-06-25

## Décisions prises
- Données de niveau externalisées dans game/data/level.json.

## Livrables produits ou modifiés
- game/data/level.json : ajouté, contient dimensions, couleurs, plateformes, spawns, ennemis, minerais, établi, boss et porte.
- game/scripts/level.gd : charge les données depuis level.json.
- game/scripts/title.gd : mise en page du menu dev corrigée et validée.
- README.md / _contexte/* / CHANGELOG.md : mis à jour pour clôture.

## Hypothèses validées / invalidées
- VALIDE : toggle 100 MIN, spawn atelier et mise en page menu titre validés utilisateur.
- VALIDE : level.json parsable ; lancement Godot headless OK via D:\Godot\godot.exe.

## Prochaine étape exacte
Définir les axes v2.

## Question bloquante pour la session suivante
Aucune
