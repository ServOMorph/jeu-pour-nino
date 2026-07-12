# Mémoire projet
<!-- Fichier géré via /memory. Ne pas modifier manuellement sauf pour supprimer des entrées. -->

## 2026-06-21 — Manette et contrôles input

**Manette :** PowerA NSW Wired Controller — GUID `03002d7bd620000019a7000000000000`, calibrée le 2026-06-14.

**Architecture :** input centralisée dans `game/scripts/joymap.gd` (autoload). Aucun index joypad codé en dur ailleurs. Si la manette change → relancer `scenes/ui/calibration.tscn`.

**Mapping brut calibré :**
A=btn2, B=btn1, X=btn3, Y=btn0, LB=btn4, RB=btn5, ZL=btn6, ZR=btn7, Select=btn9, Start=btn12, L stick clic=btn10, R stick clic=btn11, Croix=hat switch (h0.1/4/8/2), Stick gauche=axes 0/1, Stick droit=axes 2/3.

**Actions → bindings :**
- move : stick gauche / croix
- jump : JOY_BUTTON_A
- attack : JOY_BUTTON_RIGHT_SHOULDER
- interact : JOY_BUTTON_Y
- ui_accept : JOY_BUTTON_A, ui_cancel : JOY_BUTTON_B

**Pièges Godot :**
- `JOY_BUTTON_X` réservé à `ui_up` par défaut → ne pas utiliser pour action custom.
- `ui_cancel` n'inclut pas `JOY_BUTTON_B` par défaut → l'ajouter explicitement via `joymap.gd`.

**Règle contrôles (décision 2026-06-21) :** manette uniquement. Pas de bindings clavier sur les nouvelles actions. Toute nouvelle action → binding joypad ajouté dans `joymap.gd`, pas dans `project.godot`.

## 2026-06-21 — Externalisation valeurs gameplay
Toutes les valeurs numériques gameplay (stats, timings, physique, feel) doivent être dans les JSON de `game/data/`. Aucune constante numérique gameplay ne doit rester hardcodée dans les scripts GDScript. S'applique à `player.gd`, `boss.gd`, `enemy_base.gd` et tout nouveau script gameplay.

## 2026-06-27 — Risques animation (principes, dimensions obsolètes retirées le 2026-07-12)

**Qualité upscale :** si les nouveaux sprites sont juste des upscales des anciens, le résultat restera mauvais. Refaire réellement plutôt que scaler.

**Mobs sans frames :** mobs n'ont qu'une seule image statique. Architecture `animation_driver.gd` doit accepter animations à une frame (pas de crash, pas de boucle mal gérée).

**Ne pas mélanger timing :** durées attaque/invulnérabilité/stun/dégâts restent dans JSON gameplay, pas en dur dans animation. Animation = pur visuel, gameplay = pur gameplay.

## 2026-07-09 — Refonte animations
Pour refaire une animation, toujours régénérer toutes les frames à partir d’une frame de référence validée. Ne jamais corriger des frames isolées.

## 2026-07-12 — Bindings manette actuels (complète l'entrée 2026-06-21)
Actions manette additionnelles actives dans `joymap.gd`, absentes de l'entrée initiale : `use_item` = JOY_BUTTON_LEFT_SHOULDER, `sprint` = JOY_BUTTON_LEFT_STICK, `pause_menu` = JOY_BUTTON_START.
