# Workflow Blender — personnage SF3D

## Environnement vérifié

- Blender : `D:\blender\blender.exe` (Blender 5.2.0 LTS).
- Génération locale : `game_art/models/run_sf3d_local.py`.
- Base actuelle : `game_art/models/sf3d_player_v1/player_adventurer_sf3d_v1.glb`.
- Référence principale : `game_art/assets/concept/player_adventurer_orthographic_v1.png`.

Ne pas conclure que Blender est absent si `blender` n'est pas dans le `PATH`. Vérifier d'abord le chemin ci-dessus avec `D:\blender\blender.exe --version`.

## Règles d'exécution

- Ne jamais modifier la scène Blender active de l'utilisateur sans demande explicite.
- Pour les traitements automatiques, utiliser une instance séparée avec `D:\blender\blender.exe --background --python <script>`.
- Écrire chaque itération dans un nouveau dossier `game_art/models/sf3d_player_vN/` ; ne pas écraser la version validée.
- Vérifier chaque GLB par un import Blender en arrière-plan et relever maillages, sommets, faces et matériaux.
- Le MCP Blender est désactivé. Ne l'activer que sur demande explicite ; son absence ne bloque pas l'automatisation par ligne de commande.

## Passe de réalisme

1. Comparer silhouette, proportions et accessoires aux vues face, profils et dos.
2. Nettoyer le maillage : supprimer éléments isolés, corriger normales, lisser et préserver les UV exploitables.
3. Corriger les matériaux PBR : métal, cuir, tissu, peau et cheveux doivent rester séparables.
4. Créer un rig humanoïde minimal, contrôler la déformation des épaules, coudes, hanches et genoux.
5. Rendre des vues de contrôle face, profil, dos et trois-quarts sous éclairage neutre.
6. Exporter un GLB Godot uniquement après validation visuelle de ces contrôles.

## Limite actuelle

Le GLB SF3D provient d'une vue de face : il est une base de travail, pas un personnage final réaliste. Une passe de réalisme nécessite des références multi-vues précises et des corrections artistiques ciblées.
