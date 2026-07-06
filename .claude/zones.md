# Zones — jeu

| Alias | Dossier |
|-------|---------|
|jeu       | "D:\ServOMorph\Jeu pour Nino"|
|game_art       |"D:\ServOMorph\Jeu pour Nino\game_art"|

## Propriété des fichiers partagés

Chaque fichier ci-dessous n'a qu'un seul agent autorisé à écrire dedans (sauf mention contraire).
En cas de doute, ne pas écrire hors de sa propriété — référencer plutôt le fichier concerné.

| Fichier | Écrit par | Détail |
|---|---|---|
| `roadmap.md` (racine) | jeu | seul propriétaire |
| `game_art/roadmap_editeur.md` | game_art | seul propriétaire |
| `game_art/backlog_art.md` | les deux, par champ | jeu : crée les entrées + `debloque:` + statut `livre→integre` ; game_art : `specs`, `livraison:`, statut `a_faire→en_cours→livre` |
| `_contexte/` (zone jeu) | jeu | game_art ne doit jamais y écrire (canal remplacé par `backlog_art.md`) |
| `game_art/_contexte/` (zone game_art) | game_art | jeu ne doit jamais y écrire |
| `README.md` (racine) | jeu | mis à jour uniquement par `/close jeu` |
| `CHANGELOG.md` (racine) | les deux | jamais en parallèle — voir close.md étape 8 |
| `questions.md` (racine) | jeu | source d'arbitrage commune, mais seul le dev tranche/écrit ; game_art la consulte |
