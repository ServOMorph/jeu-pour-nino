---
description: Charge le contexte d'une zone en début de session
argument-hint: [zone]
model: haiku
---

# /start [zone]

## Zones valides et dossiers réels

Lire `.claude/zones.md` pour obtenir la table des alias → dossiers réels.


## Procédure

1. Lire l'argument fourni ($ARGUMENTS).
   - Si absent : utiliser le working directory courant comme dossier cible (zone implicite).
   - Si présent mais non reconnu dans la table ci-dessus :
     répondre "Erreur : zone inconnue. Zones valides : <liste des alias>"
     et s'arrêter.
   - Si présent et reconnu : résoudre le dossier via la table.

2. Vérifier que `<dossier>/_contexte/signals.md` et `<dossier>/_contexte/contexte.md` existent.
   Si absents : proposer d'initialiser la structure `_contexte/` pour cette zone (créer
   `contexte.md` et `signals.md` vides) et s'arrêter.

3. Charger dans l'ordre :
   1. `_contexte/signals.md` — actions ouvertes, blocages, dernière session (priorité absolue)
   2. `_contexte/contexte.md` — contexte stable
   3. `roadmap*.md` — si un fichier correspondant existe dans `<dossier>`, le charger

   > **Économie tokens :** si `signals.md` suffit à répondre à la question immédiate,
   > `contexte.md` peut être chargé à la demande plutôt que systématiquement.
   > En cas de doute : le charger.

4. Afficher le contenu intégral de `signals.md` (sans résumé ni reformulation).

4b. Pour chaque action listée dans `signals.md` qui contient un champ `réf:`, lire les fichiers
    référencés avant d'afficher la synthèse. Si une action semble ambiguë mais qu'une `réf:` existe,
    lire la référence en priorité plutôt que de demander des précisions.

    Ajouter ensuite, à partir des autres fichiers chargés : la phase en cours si roadmap active,
    et le point d'attention immédiat.

5. Afficher en fin de réponse : 🎉🎉🎉

<!-- SPECIFICITES PROJET : DEBUT (préservé par /update, ne pas toucher hors de ce bloc) -->
<!-- Convention : toute règle liée à une étape précise de la Procédure ci-dessus doit la
     référencer explicitement par son numéro (ex: "Étape 3 : ..."), plutôt que compter sur la
     position physique de cette zone (toujours en fin de fichier). -->

**Étape 3 (chargement) — multi-zone `jeu` / `game_art` :**
- Si la zone résolue est `game_art` : charger aussi `backlog_art.md`
  - le traiter comme source de vérité opérationnelle pour la production visuelle
  - considérer qu'il fait le lien entre l'agent codeur du projet et l'agent design
  - considérer que les demandes qui débloquent directement l'avancement du dev sont prioritaires sur tout le reste
  - lire son contenu utile, pas seulement constater son existence
  - remonter explicitement en premier les entrées prioritaires qui bloquent ou débloquent l'avancement dev
- Si la zone résolue est `jeu` : charger aussi `game_art/backlog_art.md`
  - c'est l'unique canal de handoff art → dev, à lire systématiquement
  - filtrer les entrées au statut `livre` : assets produits par game_art, prêts à être intégrés côté jeu
  - remonter ces entrées `livre` en tête de réponse (bloc `Assets à intégrer`), avec le champ `livraison:` (chemin des fichiers)
  - ne jamais modifier le contenu de `backlog_art.md` en dehors de la procédure `/close` (champ `debloque:` ou passage `livre` → `integre`)

**Étape 4 (affichage) :**
- Si la zone est `game_art` : ajouter en fin de réponse un bloc `Urgent backlog_art` listant les urgences issues de `backlog_art.md` pour faire avancer le dev.
- Si la zone est `jeu` : le bloc `Assets à intégrer` (voir étape 3) est placé juste après l'affichage de `signals.md`.
- Urgences de `backlog_art.md` (zone `game_art`), ordre strict :
  1. tout ce qui débloque directement une tâche du dev ou remplace un placeholder utilisé en jeu
  2. parmi ces éléments, priorité la plus haute d'abord
  3. à priorité égale, prendre les éléments au statut `en_cours` avant `a_faire`
  4. ignorer le reste tant que ces urgences ne sont pas traitées

<!-- SPECIFICITES PROJET : FIN -->
