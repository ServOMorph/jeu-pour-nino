---
description: Charge le contexte d'une zone en debut de session
argument-hint: [zone]
model: haiku
---

# /start [zone]

## Zones valides et dossiers reels

Lire `.claude/zones.md` pour obtenir la table des alias -> dossiers reels.

## Procedure

1. Lire l'argument fourni ($ARGUMENTS).
   - Si absent : utiliser le working directory courant comme dossier cible (zone implicite).
   - Si present mais non reconnu dans la table ci-dessus :
     repondre "Erreur : zone inconnue. Zones valides : <liste des alias>"
     et s'arreter.
   - Si present et reconnu : resoudre le dossier via la table.

2. Verifier que `<dossier>/_contexte/signals.md` et `<dossier>/_contexte/contexte.md` existent.
   Si absents : proposer d'initialiser la structure `_contexte/` pour cette zone (creer
   `contexte.md` et `signals.md` vides) et s'arreter.

3. Charger dans l'ordre :
   1. `_contexte/signals.md` - actions ouvertes, blocages, derniere session (priorite absolue)
   2. `_contexte/contexte.md` - contexte stable
   3. `roadmap*.md` - si un fichier correspondant existe dans `<dossier>`, le charger
   4. Si la zone resolue est `game_art` : charger aussi `backlog_art.md`
      - le traiter comme source de verite operationnelle pour la production visuelle
      - considerer qu'il fait le lien entre l'agent codeur du projet et l'agent design
      - considerer que les demandes qui debloquent directement l'avancement du dev sont prioritaires sur tout le reste
      - lire son contenu utile, pas seulement constater son existence
      - remonter explicitement en premier les entrees prioritaires qui bloquent ou debloquent l'avancement dev
   4bis. Si la zone resolue est `jeu` : charger aussi `game_art/backlog_art.md`
      - c'est l'unique canal de handoff art -> dev, a lire systematiquement
      - filtrer les entrees au statut `livre` : assets produits par game_art, prets a etre integres cote jeu
      - remonter ces entrees `livre` en tete de reponse (bloc `Assets a integrer`), avec le champ `livraison:` (chemin des fichiers)
      - ne jamais modifier le contenu de `backlog_art.md` en dehors de la procedure `/close` (champ `debloque:` ou passage `livre` -> `integre`)

   > **Economie tokens :** si `signals.md` suffit a repondre a la question immediate,
   > `contexte.md` peut etre charge a la demande plutot que systematiquement.
   > En cas de doute : le charger.

4. Afficher le contenu integral de `signals.md` (sans resume ni reformulation).

4b. Pour chaque action listee dans `signals.md` qui contient un champ `ref:`, lire les fichiers
    references avant d'afficher la synthese. Si une action semble ambigue mais qu'une `ref:` existe,
    lire la reference en priorite plutot que de demander des precisions.

    Ajouter ensuite, a partir des autres fichiers charges : la phase en cours si roadmap active,
    le point d'attention immediat, et si la zone est `game_art` un bloc explicite
    `Urgent backlog_art` place en fin de reponse listant les choses urgentes a faire
    issues de ce fichier pour faire avancer le dev. Si la zone est `jeu`, le bloc
    `Assets a integrer` (etape 4bis) est place juste apres l'affichage de `signals.md`.

4c. Si la zone est `game_art`, determiner les urgences de `backlog_art.md` avec cet ordre strict :
    1. tout ce qui debloque directement une tache du dev ou remplace un placeholder utilise en jeu
    2. parmi ces elements, priorite la plus haute d'abord
    3. a priorite egale, prendre les elements au statut `en_cours` avant `a_faire`
    4. ignorer le reste tant que ces urgences ne sont pas traitees

5. Afficher en fin de reponse : 🎉🎉🎉
