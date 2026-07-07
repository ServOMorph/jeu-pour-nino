# Questions à trancher avant développement — CoreDive Challenge v3

Analyse croisée de : `docs/v3/*` (design doc + 3 docs satellites), `roadmap.md`, `docs/profi joueur nino.md`, `docs/charte_graphique_pixel_art_dark_fantasy.md`, `.claude/memory.md`, `_contexte/contexte.md`, code existant (`game/`).

**Priorités :**
- **P1** — Bloquant : la réponse conditionne l'architecture ou contredit un document existant. À trancher avant de lancer l'agent.
- **P2** — Structurant : nécessaire avant la phase concernée, mais ne remet pas en cause les fondations.
- **P3** — Contenu/polish : peut être tranché en cours de route sans risque architectural.

Les thèmes sont ordonnés par priorité décroissante. Chaque contradiction détectée entre documents est signalée par ⚠.

---

## 1. Structure du run et boucle de jeu (P1 — le cœur du problème)

**Q001 (P1)** ✅ **TRANCHÉ : modèle (a) — run multi-biomes.** Un run = toute la descente. Le HUB est *dans* le run ; matériaux, équipement et cicatrices persistent à travers les allers-retours HUB ↔ biomes. Le run ne se termine qu'à la mort définitive (plus de résurrection) ou à la victoire finale (Miroir du Noyau). `RunState.reset()` doit avoir lieu au *lancement d'un nouveau run* (depuis le titre), pas à chaque entrée en biome depuis le HUB.

**Q002 (P1)** ✅ **TRANCHÉ : régénéré à chaque entrée.** Quitter puis revenir dans un biome (via le HUB) déclenche une nouvelle génération (nouvel agencement, gisements/ennemis remis à neuf). Un seul biome vivant en mémoire à la fois — cohérent avec l'option (a) déjà retenue pour l'Arène du Voile en Phase 5 (elle reste la seule exception à conserver une scène en mémoire, car elle est traversée *au sein* d'un même passage en biome).

**Q003 (P1)** ✅ **TRANCHÉ : vaincre le Miroir du Noyau.** Battre le Gardien du Noyau (B4) ouvre l'accès au Miroir mais ne suffit pas — le bonus PC « réussite d'un run » n'est accordé qu'à la victoire finale contre le Miroir.

**Q004 (P1)** ✅ **TRANCHÉ : écran de fin puis retour HUB.** Pas de New Game+, pas de fin définitive façon roguelite classique : après la victoire, écran de récapitulatif puis retour au HUB pour enchaîner un nouveau run.

**Q005 (P1)** ✅ **TRANCHÉ : pas de plafond dur.** Aucune limite fixe du nombre de résurrections. L'escalade de difficulté des Gardiens du Voile (5+ = niveau boss) suffit à borner naturellement les tentatives — la formulation « tentatives de résurrection restent » de la roadmap est à corriger : il n'y a jamais d'épuisement artificiel, seulement une difficulté croissante.

**Q006 (P1)** ✅ **TRANCHÉ : sortie volontaire possible, via un objet/portail de retour.** Le joueur peut quitter un biome en cours d'exploration sans mourir ni battre le boss, en activant un point/objet de retour, et conserve ce qu'il a récolté. Détail du mécanisme précis (portail fixe en début de biome ? objet consommable ?) à définir en Phase 3/4.

**Q007 (P2)** ✅ **TRANCHÉ : le biome reste explorable, le boss ne réapparaît pas.** Après avoir battu le boss d'un biome, ce dernier reste accessible et re-générable (cf. Q002) dans le même run, mais ce boss précis ne redéclenche pas avant le run suivant.

**Q008 (P2)** ✅ **TRANCHÉ : run court, ~30-45 min.** Choix guidé par la simplicité technique : un run court/moyen n'exige pas de persister l'état du run en cours (`RunState`) entre deux sessions — seule la progression méta (`MetaState` : Grimoire, PC) est sauvegardée via `SaveManager`, comme c'est déjà le cas. Si le jeu se ferme en plein run, le run est perdu (accepté). Un run 2h+ aurait exigé une sérialisation complète de l'état de run, non prévue par l'architecture actuelle.

**Q009 (P2)** ✅ **TRANCHÉ : le Gardien du Noyau (B4) seul suffit.** Aucun prérequis minimal de biomes/cicatrices — un joueur efficace peut foncer direct au Biome 4 et affronter un Miroir « faible » (peu de paramètres). Cohérent avec la liberté totale annoncée par le design.

---

## 2. Choix fondateurs jamais tranchés explicitement (P1)

**Q010 (P1)** ✅ **TRANCHÉ : solo strict.** v3 est solo uniquement, sans aucune anticipation architecturale pour une coop future. La coop part au backlog post-v3, sans contrainte sur le code actuel.

**Q011 (P1)** ✅ **TRANCHÉ : Windows uniquement, PC de Nino.** Export Godot Windows standalone installé localement sur une machine connue. Pas de portage à prévoir.

**Q012 (P1)** ✅ **TRANCHÉ : accessible dans les options.** `calibration.tscn` doit être intégré au menu options du jeu final, pas seulement accessible en mode dev — utile si la manette change ou doit être recalibrée sans intervention développeur.

**Q013 (P2)** ✅ **TRANCHÉ : pas de versioning, reset accepté.** Aucun champ `version` ni migration à implémenter pendant le développement. Les données de progression de Nino peuvent être réinitialisées à chaque jalon majeur sans que ce soit un problème.

**Q014 (P3)** ✅ **TRANCHÉ : un seul profil.** Une seule sauvegarde `meta_state.json`, pas de gestion multi-profils.

---

## 3. Mécaniques joueur et combat (P1/P2)

**Q015 (P1)** ✅ **TRANCHÉ : double saut + corde/grappin.** Moveset final : déplacement, saut simple, double saut, corde/grappin (mécanique précise à détailler en Q021). Pas de dash, pas de wall jump. Les templates de salles (Phase 4) doivent être conçus en tenant compte de la hauteur atteignable avec double saut et des passages nécessitant la corde/grappin.

**Q016 (P1)** ✅ **TRANCHÉ : ajout d'armes à distance.** Le combat inclut des armes à distance (projectiles) en plus du mêlée. Nécessite : un bouton manette dédié (à réserver dans `joymap.gd`), une mécanique de visée, un nouveau type de données dans `weapons.json` (portée, vitesse de projectile, munitions ?), et une scène de projectile. Impact à cadrer en Phase 2/7 (armes) et sur `player.gd`. **Précision tranchée : usage illimité, pas de munitions.** L'arme à distance fonctionne comme l'arme de mêlée — équipée, utilisable sans limite, différenciée par cooldown/dégâts/portée plutôt que par ressource consommée.

**Q017 (P1)** ✅ **TRANCHÉ : 4 slots — Arme (mêlée ou distance, un seul slot), Armure, Accessoire, Outil/torche.** La pioche n'est pas un équipement (capacité passive de minage), la corde est un consommable/utilitaire à usage ponctuel (pas un slot permanent). L'Anneau des Revenants occupe le slot Accessoire ; la Torche occupe le slot Outil, séparé de l'Arme (le joueur doit pouvoir voir et combattre simultanément en Biome 2). `_apply_equipment()` et l'UI d'équipement doivent gérer ces 4 slots.

**Q018 (P1)** ✅ **TRANCHÉ (révisé, voir Q021a) : obscurité réelle liée à la Torche, sans système d'éclairage dynamique complet.** Sans Torche équipée, le Biome 2 est réellement trop sombre pour bien jouer (voile/overlay sombre pénalisant la visibilité — plateformes, ennemis, gisements difficiles à distinguer). Avec la Torche équipée (slot Outil), la visibilité redevient normale. Pas besoin d'un vrai Light2D avec rayon dynamique suivant le joueur et occlusion de décor : un overlay global (shader plein écran ou vignette sombre) activé/désactivé selon équipement Torche suffit — plus simple qu'une lumière ponctuelle qui suit le joueur. Le joueur peut entrer dans le biome sans Torche, mais y voit mal.

**Q019 (P2)** ✅ **TRANCHÉ : 1 slot consommable, bouton dédié.** Un seul consommable actif à la fois, changé via le menu pause/inventaire, utilisé par un bouton manette dédié (à réserver dans `joymap.gd`, en tenant compte du nouveau bouton d'arme à distance de Q016).

**Q020 (P2)** ✅ **TRANCHÉ : illimité.** Confirme le comportement actuel : compteurs par matériau sans plafond, aucune gestion de poids/capacité à coder.

**Q021 (P2)** ✅ **TRANCHÉ — mécaniques des utilitaires de départ :**
- **Torche** : équipable (slot Outil). Effet gameplay réel : sans elle équipée, le Biome 2 est trop sombre pour bien jouer (overlay sombre pénalisant la visibilité) ; équipée, la visibilité redevient normale. Voir Q018 révisé. Pas de durée limitée (pas de consommation) — objet permanent une fois découvert/crafté.
- **Corde** : fusionnée avec le grappin déjà tranché en Q015 — pas un objet distinct, pour éviter la redondance avec la mobilité verticale (double saut + grappin).
- **Établi Portable** : repositionnable à volonté (objet permanent de l'inventaire, jamais consommé), mais ne permet de crafter que les recettes de **tier 1**. Les établis avancés trouvés en biome sont nécessaires pour les tiers supérieurs.

**Q022 (P2)** ✅ **TRANCHÉ : gaté par tier.** Une pioche de tier insuffisant ne peut pas miner un gisement de matériau plus rare (façon Terraria). Nécessite : un champ `tier` dans `materials.json` (section ore) et dans la config de pioche, comparé au tier de pioche équipée avant d'autoriser le minage.

**Q023 (P2)** ✅ **TRANCHÉ : uniquement via équipement.** Aucun arbre de stats, aucune augmentation permanente achetable en PC. Les PC ne servent qu'à débloquer des recettes (Grimoire) — confirme le design doc.

**Q024 (P2)** ✅ **TRANCHÉ : Potions + régénération complète au HUB, pas de soin post-boss.** Les potions sont la seule source de soin pendant l'exploration d'un biome. Revenir au HUB restaure intégralement les PV — renforce le rôle de sanctuaire du HUB et donne un usage stratégique au retour volontaire (Q006). Pas de régénération automatique après avoir vaincu un boss, pas de régénération passive dans le temps.

**Q025 (P3)** ✅ **TRANCHÉ : attaque simple uniquement.** Une seule attaque au bouton dédié, pas de combo ni charge ni attaque directionnelle. Les armes diffèrent par dégâts/portée/vitesse uniquement — cohérent avec le système actuel, simple à équilibrer en JSON.

---

## 4. Cicatrices et Arène du Voile (P1/P2)

**Q026 (P1)** ✅ **TRANCHÉ : les 5 cicatrices du design doc, liste définitive.**
| Cicatrice | Effet | Clé de modificateur |
| --- | --- | --- |
| Cicatrice du Sang | -10 % PV max | `max_hp_mult: 0.9` (remplace `max_hp_add` par un multiplicateur, plus lisible en %) |
| Cicatrice de l'Os | Vitesse de déplacement réduite | `speed_mult` (déjà prévu) |
| Cicatrice de l'Âme | Soins moins efficaces | `heal_mult` — **nouvelle clé à ajouter** à `scars.json`/`_recompute_stats()` |
| Cicatrice de la Peur | Détection ennemie accrue | `detection_mult` — **nouvelle clé, nécessite un rayon de détection paramétrable sur les ennemis (cf. Q027)** |
| Cicatrice du Noyau | +20 % dégâts / -20 % PV max | `attack_damage_mult` + `max_hp_mult` combinés |

Les exemples `membre_raidi`/`vision_voilee` de la roadmap Phase 6 sont abandonnés au profit de cette liste. La Phase 6 doit être mise à jour en conséquence (schéma `scars.json`, clés de modificateurs).

**Q026b (P1)** ✅ **TRANCHÉ : planchers durs par stat (garde-fou contre le cumul de cicatrices en cas de nombreuses résurrections).** Sans plafond de résurrections (Q005), les cicatrices s'empilent au-delà des 5 types une fois tous possédés (doublons cumulés, règle héritée du design doc). Sans borne, un stack important (ex. ~20 doublons de la Cicatrice du Sang, `max_hp_mult: 0.9` composé) ferait tendre une stat vers zéro et rendrait le personnage injouable bien avant une centaine de morts — alors que l'escalade des Gardiens plafonne, elle, à ×2.5 dès la 5ᵉ mort (Q031). Pour éviter cet état dégénéré :
- Chaque stat modifiable par cicatrice porte un **plancher dur** défini dans `scars.json` (pas dans le code) : ex. `speed_mult` jamais sous 0.5× la base, `max_hp` jamais sous 2, `heal_mult` jamais sous 0.3×, `attack_damage_mult` toujours ≥ un minimum non nul.
- Le calcul de stats (`_recompute_stats()`) applique les modificateurs cumulés puis clamp au plancher — les cicatrices excédentaires du même type au-delà du plancher n'ont plus d'effet mécanique supplémentaire (mais peuvent rester comptabilisées/affichées si besoin visuel).
- Ainsi, un joueur peut techniquement mourir et ressusciter des dizaines de fois sans que le personnage devienne totalement inerte : la difficulté vient de l'escalade des Gardiens (plafonnée) combinée à un personnage affaibli mais jamais à zéro.
- Tests dédiés (`test_scars.gd`) : vérifier qu'un stack extrême (ex. 50 cicatrices du même type) respecte les planchers.

**Q027 (P2)** ✅ **TRANCHÉ : ajouter un rayon de détection paramétrable.** Nouveau champ `detection_radius` dans `enemies.json` et `enemy_base.gd`, multiplié par `detection_mult` quand la Cicatrice de la Peur est active. À prévoir en Phase 6 (cicatrices) — travail ciblé, réutilisable plus largement pour l'IA ennemie.

**Q028 (P2)** ✅ **TRANCHÉ : aléatoire imposé, annoncé.** Tirage aléatoire uniforme parmi les non-possédées (confirmé), affiché dramatiquement au joueur via un écran dédié à la résurrection — pas de choix, renforce la philosophie « prix imposé par le Noyau ». *(Reste ouvert : une cicatrice peut-elle être retirée en cours de run via une recette du Voile type Élixir de Résurgence ? Non tranché explicitement — l'Élixir de Résurgence donne un « bonus temporaire après résurrection », distinct d'un retrait de cicatrice.)*

**Q029 (P2)** ✅ **TRANCHÉ : un seul Gardien en Phase 5 — Le Veilleur des Cendres.** Les 7 autres Gardiens du pool (Roi Sans Visage, Collecteur d'Âmes, Veuve du Vide, Dévoreur de Souvenirs, Porte-Flamme, Gardien des Os, Écho du Noyau) sont ajoutés en R2/Phase 7, sans bloquer J3. Un seul Gardien tiré à chaque mort en attendant (pas de vraie variabilité avant R2 — accepté).

**Fiche de gameplay — Le Veilleur des Cendres :** machine à états calquée sur `boss.gd` existant (réutilise directement les états charge/volley/slam). 3 attaques : charge au sol, projectile de cendres, zone d'explosion retardée. Phase de pause vulnérable entre les attaques (fenêtre de riposte).

**Q030 (P2)** ✅ **TRANCHÉ : PV restaurés à l'entrée, consommables utilisables.** Le joueur arrive dans l'Arène du Voile avec ses PV pleins et peut utiliser son consommable équipé (slot unique, Q019) comme en biome normal.

**Q031 (P3)** ✅ **TRANCHÉ : table provisoire d'escalade.** Palier 1 = ×1.0, 2 = ×1.3, 3 = ×1.6 (+ nouveau pattern), 4 = ×2.0, 5+ = ×2.5. Appliquée à HP et dégâts. Équilibrage définitif renvoyé à la Phase 10 comme prévu par la roadmap.

---

## 5. Génération des biomes et level design (P1/P2)

**Q032 (P1)** ✅ **TRANCHÉ : supporter top/bottom dès la Phase 4.** Le format de salle et `biome_generator.gd` gèrent 4 directions de connexion (left/right/top/bottom) dès la Phase 4, même si seul le biome 1 (horizontal) est généré à ce stade. Évite de casser le format des templates en Phase 7 quand B3 (vers le haut) et B4 (vers le bas) seront développés.

**Q033 (P1)** ✅ **TRANCHÉ : indice visuel discret.** Une salle secrète est signalée par un détail visuel discret (fissure, luminosité différente) sans être évidente — pas un mur à traverser en aveugle. Le générateur la place comme une salle taggée `secret`, connectée par un embranchement optionnel (dépend de Q036, structure des biomes).

**Q034 (P2)** ✅ **TRANCHÉ : progression douce.** B1 : 5-7 salles, B2 : 6-8, B3 : 7-9, B4 : 8-10. Cohérent avec un run cible de 30-45 min (Q008).

**Q035 (P2)** ✅ **TRANCHÉ : 8-10 templates par biome.** Volume raisonnable pour un développement solo (4 biomes × 8-10 = 32-40 salles au total) — assez de variété sans exploser le temps de production.

**Q036 (P2)** ✅ **TRANCHÉ : embranchements légers.** Chemin principal linéaire + quelques embranchements courts menant à des culs-de-sac (trésor, salle secrète, gisement bonus). Nécessite le format `connections` étendu au-delà de left/right/top/bottom déjà tranché en Q032 — un embranchement suppose qu'une salle du chemin principal expose une connexion supplémentaire vers une salle annexe.

**Q037 (P2)** ✅ **TRANCHÉ : élite = variante boostée sur spawn normal ; porteur = salle taggée.** Un élite est un ennemi normal avec stats majorées (HP/dégâts) et une teinte/effet visuel distinctif, tiré aléatoirement sur un spawn point normal (pas de salle dédiée). Les porteurs de recettes apparaissent sur des salles spécifiquement taggées, avec une probabilité définie dans la config biome.

**Q038 (P2)** ✅ **TRANCHÉ : écran fixe par salle.** Chaque salle = un écran de 1920×1080 sans scroll interne (résolution native depuis la migration viewport, `plan_resolution_1920x1080.md` — 480×270 d'origine obsolète). Confirme le comportement actuel, pas de caméra dynamique à gérer par salle.

**Q039 (P2)** ✅ **TRANCHÉ : rien de plus pour l'instant.** Le HUB reste minimal : 4 sorties, Grimoire, établi. Un HUB évolutif (décorations débloquables, PNJ, coffre persistant) part au backlog post-v3.

**Q040 (P3)** ✅ **TRANCHÉ : non, aucun pour l'instant.** Pas de plateformes cassables, pièges ni leviers en v3. Le décor reste statique hors gisements/ennemis/porteurs — simplifie la génération et le format de salle.

---

## 6. Craft, économie et progression (P2)

**Q041 (P2)** ✅ **TRANCHÉ — table des matériaux v3 :**

| id | Nom | Biome | Rareté | Obtention |
| --- | --- | --- | --- | --- |
| `bois` | Bois | B1 | Commune | Minage (arbre/racine) |
| `pierre` | Pierre | B1 | Commune | Minage |
| `cuivre` | Cuivre | B1 | Commune | Minage |
| `cuir` | Cuir | B1 | Commune | Drop ennemi (créatures végétales/faune) |
| `fer` | Fer | B2 | Peu commune | Minage |
| `charbon` | Charbon | B2 | Peu commune | Minage |
| `minerai_sombre` | Minerai sombre | B2 | Rare | Minage (remplace « minerais renforcés ») |
| `cristal` | Cristal | B3 | Rare | Minage |
| `minerai_celeste` | Minerai céleste | B3 | Rare | Minage |
| `essence_vent` | Essence de vent | B3 | Rare | Drop ennemi (élémentaires du vent) |
| `fragment_noyau` | Fragment du Noyau | B4 | Épique | Drop boss/minage rare |
| `minerai_abyssal` | Minerai abyssal | B4 | Épique | Minage (remplace « minerais légendaires ») |
| `essence_voile` | Essence du Voile | B4/Voile | Légendaire | Drop Gardien du Voile uniquement |

**Q042 (P2)** ✅ **TRANCHÉ — table de rareté réalignée sur les biomes réels.** Contradiction résolue : les cristaux restent au Biome 3 (Lance Cristalline y est donc rattachée, pas au B2) ; l'imagerie volcanique est réattribuée au **Biome 4** (« roche en fusion » colle mieux au thème que les Îles Célestes) :

| Rareté | Biome source | Exemples |
| --- | --- | --- |
| Commune | B1 — Galeries Verdoyantes | Épée de Cuivre, Armure de Cuivre |
| Peu commune / Rare | B2 — Mines Obscures | Épée de Fer, Armure Renforcée, Bombe Instable (arme à distance) |
| Épique | B3 — Îles Célestes | Lance Cristalline, Armure de Cristal |
| Épique/Légendaire | B4 — Descente vers le Noyau | Marteau Magmatique, Armure Volcanique |
| Légendaire | Noyau / Voile (post-B4) | Lame du Noyau, Couronne Spectrale, Armure des Revenants |

Le doc `docs/v3/CoreDive Challenge — Système de Progression, Craft, Mort et Résurrection.md` utilise d'anciens noms de biomes (« Profondeurs Cristallines », « Approches du Noyau ») — à corriger pour refléter B1-B4 définitifs lors de la mise à jour des docs.

**Q043 (P2)** ✅ **TRANCHÉ — Grimoire complet, 27 recettes :**

| id | Nom | Rareté | Tier établi | Coût PC | Matériaux | Découverte |
| --- | --- | --- | --- | --- | --- | --- |
| `epee_bois` | Épée en Bois | Starter | 1 | 0 (maîtrisée d'office) | bois:2 | Starter |
| `armure_bois` | Armure en Bois | Starter | 1 | 0 | bois:3 | Starter |
| `pioche_renforcee` | Pioche Renforcée | Starter | 1 | 0 | bois:1, pierre:2 | Starter |
| `potion_petite` | Petite Potion de Soin | Starter | 1 | 0 | bois:1, cuir:1 | Starter |
| `torche` | Torche | Starter | 1 | 0 | bois:1, pierre:1 | Starter |
| `corde` | Corde/Grappin | Starter | 1 | 0 | cuir:2 | Starter |
| `etabli_portable` | Établi Portable | Starter | 1 | 0 | bois:3, pierre:2 | Starter |
| `epee_cuivre` | Épée de Cuivre | Commune | 1 | 2 | cuivre:3, bois:1 | Salle B1 |
| `armure_cuivre` | Armure de Cuivre | Commune | 1 | 2 | cuivre:4 | Salle B1 |
| `arc_bois` | Arc en Bois | Commune | 1 | 2 | bois:3, cuir:1 | Salle B1 |
| `epee_fer` | Épée de Fer | Peu commune | 2 | 2 | fer:3, charbon:1 | Salle B2 |
| `armure_renforcee` | Armure Renforcée | Peu commune | 2 | 3 | fer:4, minerai_sombre:1 | Salle B2 |
| `bombe_instable` | Bombe Instable | Peu commune | 2 | 3 | charbon:2, minerai_sombre:1 | Salle B2 |
| `arbalete_fer` | Arbalète de Fer | Peu commune | 2 | 3 | fer:2, bois:2 | Salle B2 |
| `lance_cristalline` | Lance Cristalline | Rare | 2 | 5 | fer:2, cristal:3 (synergie B2+B3) | Salle B3 |
| `armure_cristal` | Armure de Cristal | Rare | 2 | 4 | cristal:4, minerai_celeste:2 | Salle B3 |
| `arc_celeste` | Arc Céleste | Rare | 2 | 4 | minerai_celeste:2, essence_vent:2 | Salle B3 |
| `bottes_vent` | Bottes du Vent (accessoire) | Rare | 2 | 4 | essence_vent:3 | Salle B3 |
| `marteau_magmatique` | Marteau Magmatique | Épique | 3 | 7 | minerai_abyssal:3, fragment_noyau:1 | Salle B4 |
| `armure_volcanique` | Armure Volcanique | Épique | 3 | 6 | minerai_abyssal:4 | Salle B4 |
| `epee_tempete_noyau` | Épée Tempête du Noyau | Épique | 3 | 8 | fer:3, cristal:3, fragment_noyau:1 (synergie B2+B3+B4) | Salle B4 |
| `armure_noyau` | Armure du Noyau | Légendaire | 3 | 10 | fragment_noyau:5, minerai_abyssal:3 | Porteur (Forgeron Maudit) |
| `lame_noyau` | Lame du Noyau | Légendaire | 3 | 10 | fragment_noyau:4, essence_voile:2 | Porteur (Forgeron Maudit) |
| `couronne_spectrale` | Couronne Spectrale (accessoire) | Légendaire | 3 | 8 | essence_voile:3 | Porteur (Archiviste Perdu) |
| `lame_spectrale` | Lame Spectrale | Voile | 3 | 6 | essence_voile:2, fer:2 | Victoire Gardien du Voile |
| `anneau_revenants` | Anneau des Revenants (accessoire) | Voile | 3 | 6 | essence_voile:3 | Victoire Gardien du Voile |
| `elixir_resurgence` | Élixir de Résurgence | Voile | 2 | 4 | essence_voile:1, cristal:1 | Victoire Gardien du Voile |

**Q044 (P2)** ✅ **TRANCHÉ — barème PC provisoire (`game/data/progression.json`) :**

| Source | PC |
| --- | --- |
| Biome visité (première fois dans le run) | 1 |
| Salle secrète découverte | 1 |
| Élite vaincu | 1 |
| Boss de biome vaincu | 2 |
| Résurrection réussie (Gardien du Voile vaincu) | 1 |
| Victoire finale (Miroir du Noyau vaincu) | +3 bonus |
| Run raté (mort définitive) | ×0.5 sur le total accumulé (arrondi) |

Pas de PC par salle normale explorée (éviterait une inflation avec des runs longs à faible risque). Un run modeste (1 biome visité + boss vaincu + 1 salle secrète) rapporte ~4 PC ; un run complet réussi peut atteindre 10-15+ PC — cohérent avec les coûts de maîtrise 2-10 PC de la table Q043. Équilibrage définitif en Phase 10.

**Q045 (P2)** ✅ **TRANCHÉ : suppression des coins.** Les PC remplacent totalement l'or. `coins` retiré de `RunState` en Phase 1 (dette à nettoyer, cf. `hud.gd:61-70` abonné à `coins_changed`).

**Q046 (P2)** ✅ **TRANCHÉ — 3 tiers d'établi :**
- **Tier 1** : Établi Portable (starter) — recettes starters + B1 commune.
- **Tier 2** : établi trouvé en B2/B3 — débloque en plus les recettes peu communes/rares de B2/B3 et l'Élixir de Résurgence.
- **Tier 3** : établi trouvé en B4/Voile — débloque les recettes épiques/légendaires de B4 et toutes les recettes du Voile/Noyau.

Chaque recette de la table Q043 porte son `workbench_tier` correspondant.

**Q047 (P2)** ✅ **TRANCHÉ : porteurs + Gardiens + starters uniquement.** Aucune autre source de découverte (pas de coffres, pas de bonus de première extraction). Chaque salle spéciale (secrète = PC, porteur = recette) garde un rôle clair et non redondant.

**Q048 (P3)** ✅ **TRANCHÉ : rien du tout.** Un drop en doublon ne donne rien de plus — la récompense principale est déjà d'avoir vaincu le porteur/ennemi rare.

**Q049 (P3)** ✅ **TRANCHÉ — effets des 3 objets du Voile :**
- **Anneau des Revenants** : atténue l'impact des malus de cicatrices actives (ex : -50 % sur les valeurs des modificateurs négatifs).
- **Lame Spectrale** : dégâts accrus contre les créatures du Voile (Gardiens du Voile, Miroir du Noyau).
- **Élixir de Résurgence** : soin complet + bref buff de dégâts après une résurrection réussie.

---

## 7. Ennemis et boss (P2)

**Q050 (P2)** ✅ **TRANCHÉ — archétypes ennemis par biome.** 4 nouveaux archétypes ajoutés aux `ground`/`flyer` existants : `rooted` (stationnaire, attaque de zone périodique), `jumper` (bondit vers le joueur), `turret` (stationnaire, tir de projectile), `teleporter` (téléportation courte).

| Biome | Ennemi | Archétype | Comportement |
| --- | --- | --- | --- |
| B1 | Limace | `ground` | Lente, contact simple, faible HP/dégâts |
| B1 | Scarabée | `ground` | Rapide, charge courte |
| B1 | Chauve-souris | `flyer` | Vol erratique, contact |
| B1 | Créature végétale | `rooted` | Immobile, attaque de zone courte portée |
| B2 | Mineur spectral | `ground` | Marche, mêlée, vitesse faible |
| B2 | Golem de pierre | `ground` (variante tanky) | Lent, HP élevés, charge |
| B2 | Araignée géante | `jumper` | Bondit vers le joueur périodiquement |
| B2 | Machine abandonnée | `turret` | Stationnaire, tir de projectile |
| B3 | Sentinelle volante | `flyer` (variante distance) | Tire un projectile |
| B3 | Élémentaire du vent | `flyer` | Erratique, repousse le joueur au contact |
| B3 | Créature céleste | `flyer` | Rapide, contact |
| B3 | Gardien cristallin | `turret` | Stationnaire, bouclier + attaque de zone |
| B4 | Revenant | `ground` (variante drain) | Mêlée avec vol de vie mineur |
| B4 | Créature corrompue | `ground`/`flyer` hybride | Erratique |
| B4 | Manifestation du Voile | `teleporter` | Téléportation courte, contact |

**Q051 (P2)** ✅ **TRANCHÉ — fiches des 4 boss de biome.** Le boss actuel (charge/volley/slam) devient **Le Gardien des Racines (B1)**, reskinné à thème racines/lianes — aucune réécriture de machine à états, juste re-thématisation visuelle et config JSON.

| Boss | Arène | Attaques (3-4) | Phase |
| --- | --- | --- | --- |
| Gardien des Racines (B1) | Chambre caverneuse | Charge de racines, invocation de lianes (spawn de minions), slam de racines (zone) | — (réutilise boss.gd existant) |
| Foreur Maudit (B2) | Atelier de forage | Charge frontale, tir de boulons, mine posée (explosion différée) | Rage à bas HP (vitesse accrue) |
| Orage Éternel (B3) | Plateforme aérienne | Éclair ciblé (zone télégraphiée), déplacement rapide/téléportation courte, tempête de cristaux (projectiles multiples) | — |
| Gardien du Noyau (B4) | Sanctuaire du Noyau | Charge lourde, onde de corruption (zone), invocation de revenants | Phase 2 à mi-HP (nouvelle attaque de zone majeure) |

**Q052 (P2)** ✅ **TRANCHÉ — première version `mirror.json` :**

| Biome exploré | Modules hérités |
| --- | --- |
| Galeries Verdoyantes | Racines, immobilisation, invocation végétale |
| Mines Obscures | Armure renforcée, charge, explosion |
| Îles Célestes | Déplacement aérien, éclairs, cristaux |
| Descente vers le Noyau | Énergie du Noyau, corruption, attaque de zone majeure |

| Cicatrice | Mutation boss |
| --- | --- |
| Sang | Attaques de saignement (DoT), vitesse d'attaque accrue |
| Os | Résistance accrue (réduction de dégâts subis) |
| Âme | Attaques drainantes/spirituelles |
| Peur | Vitesse de déplacement/poursuite accrue |
| Noyau | Dégâts très élevés, corruption |

**Q053 (P3)** ✅ **TRANCHÉ : pas de respawn, salle nettoyée = définitif.** Tant que le biome n'est pas quitté/régénéré (Q002), une salle nettoyée reste vide. Retourner au HUB puis re-rentrer régénère tout.

**Q054 (P3)** ✅ **TRANCHÉ : oui, drop de matériaux thématiques.** Chaque ennemi a une table de loot simple dans `enemies.json` (ex : créatures de B1 dropent du cuir, élémentaires du vent dropent de l'essence de vent) — renforce le lien biome/ressource.

---

## 8. Interface et UX (P2)

**Q055 (P2)** ✅ **TRANCHÉ : choix manuel via écran pause.** Avec 4 slots (arme mêlée/distance interchangeable, armure, accessoire, outil) et des styles d'armes différents, l'auto-équipement « meilleure arme » n'a plus de sens univoque. Un écran d'équipement accessible depuis la pause remplace `_apply_equipment()` automatique par une sélection manuelle par slot. Consulter les matériaux et changer le consommable équipé (Q019) se font depuis le même écran.

**Q056 (P2)** ✅ **TRANCHÉ : HUB uniquement.** Le Grimoire (consultation et dépense de PC) n'est accessible qu'au HUB, jamais pendant l'exploration d'un biome — cohérent avec le rôle du HUB comme centre de gestion méta.

**Q057 (P2)** ✅ **TRANCHÉ : barres de vie au-dessus des ennemis, uniquement.** Pas de chiffres de dégâts flottants, pas de minimap/indicateur de direction. Chaque ennemi affiche une barre de vie fine pendant le combat, en plus de la barre de boss déjà existante.

**Q058 (P2)** ✅ **TRANCHÉ : volumes musique/SFX, plein écran/fenêtré, recalibration manette (Q012).** Persisté dans un fichier séparé `user://settings.json`, distinct de `meta_state.json` (les réglages techniques ne sont pas de la progression de jeu).

**Q059 (P3)** ✅ **TRANCHÉ : écran de rappel des contrôles.** Un écran statique listant les contrôles manette, accessible depuis le menu ou au premier lancement. Pas de tutoriel interactif — adapté à un joueur déjà expérimenté sur des jeux similaires (Terraria, Hollow Knight).

**Q060 (P3)** ✅ **TRANCHÉ : « Nouvelle partie » efface avec confirmation.** L'écran titre propose Continuer/Nouvelle partie ; « Nouvelle partie » affiche une confirmation explicite avant d'effacer le Grimoire/PC existants.

---

## 9. Narration et univers (P2/P3)

**Q061 (P2)** ✅ **TRANCHÉ : textes courts aux moments clés.** Pas de dialogues ni cinématiques : quelques phrases affichées aux moments forts (première mort, victoire de Gardien, entrée au Miroir) + descriptions courtes dans le Grimoire. Budget d'écriture minimal.

**Q062 (P3)** ✅ **TRANCHÉ : personnage anonyme/générique.** Pas de nom donné explicitement — le héros reste un aventurier silencieux sans identité nommée (pas « Nino »).

**Q063 (P3)** ✅ **TRANCHÉ : texte simple avec fondu.** Les messages scénarisés (« Le Noyau t'a compris », première mort, première résurrection) apparaissent en fondu sur fond noir/sombre, quelques secondes, sans animation complexe — coût de production minimal.

---

## 10. Audio (P2/P3)

**Q064 (P2)** ✅ **TRANCHÉ : audio définitif reporté à la toute fin, juste avant la mise en prod.** Pendant tout le développement, sons/musiques restent des placeholders générés en code (`AudioManager`, déjà en place). Le remplacement par des assets définitifs (musiques, bruitages) constitue la dernière étape avant la sortie, cohérent avec la Phase 10 de la roadmap. **Réserve :** garder au minimum les placeholders sonores (pas seulement visuels) actifs dès que possible pendant le développement — un jeu totalement muet pendant les playtests J1-J6 avec Nino risque de sembler plus fade qu'il ne l'est, et les bruitages de base (saut, attaque, coup reçu) sont bon marché à intégrer au fil de l'eau via `AudioManager`. Seul le *remplacement par des assets définitifs/soignés* est reporté à la fin.

**Q065 (P2)** ✅ **TRANCHÉ : décision reportée à la fin du développement**, en cohérence avec Q064. Pas de nombre de pistes ni de choix dynamique/boucle simple à figer maintenant — sera tranché lors de la Phase 10 avec une vision complète du jeu terminé.

**Q066 (P3)** ✅ **TRANCHÉ — liste fermée des bruitages indispensables :** saut, attaque (mêlée + distance), coup reçu, minage, craft, découverte de recette, maîtrise de recette, mort, résurrection, victoire boss/Gardien, ouverture menu/Grimoire.

**Q067 (P3)** ✅ **TRANCHÉ : aucune voix.** Cohérent avec la narration par textes courts (Q061) et le développement solo.

---

## 11. Direction artistique et assets (P2/P3)

**Q068 (P2)** ✅ **TRANCHÉ (révisé) : plus de grille de tiles imposée.** Décision d'origine (grille 16×16, résolution 480×270, pixel art) obsolète depuis le pivot vers des graphismes 2D standard (`plan_graphismes_standard_2d.md`) et la migration résolution native 1920×1080. Tuiles/décors désormais produits à résolution native, sans contrainte de grille ni de palette réduite. Les templates de salles (Phase 4) restent valides dans leur logique de composition, pas dans leur unité de mesure pixel art.

**Q069 (P2)** ✅ **TRANCHÉ : 2-3 couches de parallax.** Fond lointain + fond intermédiaire + plateformes au premier plan. Bon compromis profondeur/charge de production pour un développement solo.

**Q070 (P3)** ✅ **TRANCHÉ — 5 paliers d'effets shaders réalisables en Godot :**
1. Léger overlay lumineux (yeux) + particules discrètes.
2. Shader de teinte veines lumineuses + halo.
3. Shader de transparence partielle.
4. Overlay de fragments flottants + teinte cristalline.
5+. Combinaison de tous les shaders précédents à intensité maximale + particules denses.
Tous réalisables avec les outils Godot standards (shaders 2D, CPUParticles2D).

**Q071 (P3)** ✅ **TRANCHÉ : joueur > ennemis > boss > tilesets > UI.** Le joueur est vu en permanence (priorité maximale), puis les ennemis (variété rencontrée souvent), puis les boss (rares mais impactants), puis les tilesets/décor, enfin l'UI (fonctionnelle avant d'être jolie).

---

## 12. Performances, technique, configuration (P2/P3)

**Q072 (P2)** ✅ **TRANCHÉ : 60 FPS, plein écran par défaut.** Résolution de rendu 1920×1080 native (`plan_resolution_1920x1080.md` — 480×270 upscalé d'origine obsolète). Basculable en fenêtré via les options (Q058). Aucun enjeu de performance réel vu la simplicité technique du jeu.

**Q073 (P2)** ✅ **TRANCHÉ : un seul biome vivant en mémoire à la fois.** L'Arène du Voile est l'unique exception (biome détaché mais conservé pendant la traversée de l'Arène lors d'une résurrection, Phase 5). Jamais plusieurs biomes simultanés — cohérent avec Q002 (régénération à chaque entrée).

**Q074 (P3)** ✅ **TRANCHÉ : écran de transition accepté.** Un bref écran de chargement/transition (fondu, quelques centaines de ms à 1-2s) est acceptable entre HUB et biome — n'impose pas de contrainte d'instantanéité à `biome_generator.gd`.

**Q075 (P3)** ✅ **TRANCHÉ : sauvegarde à chaque événement méta.** `SaveManager.save_meta()` est appelé immédiatement à chaque découverte/maîtrise de recette et gain de PC, pas seulement en fin de run — protège la progression permanente contre un crash en cours de run, cohérent avec l'acceptation de perdre uniquement le run en cours (Q008).

---

## 13. Tests, validation, processus (P3)

**Q076 (P3)** ✅ **TRANCHÉ : équilibrage JSON amendable, architecture gelée.** Les retours de playtest de Nino aux jalons J1-J7 peuvent ajuster l'équilibrage (valeurs dans les JSON : PC, coûts, HP, taille des biomes) sans jamais remettre en cause l'architecture ou les formats de données tranchés dans ce document. Concilie playtests réels et objectif de gel préalable.

**Q077 (P3)** ✅ **TRANCHÉ : J7 + Phase 10 suffit.** Le jeu est considéré terminé quand tous les jalons J1-J7 sont validés et la Phase 10 (équilibrage/polish) close, sans critère de qualité formel supplémentaire (pas de « zéro bug » ou « X runs sans crash » imposé).

---

## Récapitulatif des contradictions documentaires — toutes résolues

| # | Contradiction | Résolution | Questions liées |
|---|---|---|---|
| 1 | Synergies cross-biomes vs run mono-biome avec `RunState.reset()` | Run multi-biomes (modèle a) : HUB dans le run, `reset()` seulement à un nouveau run | Q001, Q002 |
| 2 | Nombre limité de résurrections (roadmap) vs escalade infinie (design) | Pas de plafond dur ; l'escalade des Gardiens borne naturellement | Q005 |
| 3 | Cicatrices : 5 nommées (design) vs exemples différents + clés de modificateurs incomplètes (roadmap) | Les 5 du design doc retenues, nouvelles clés `heal_mult`/`detection_mult` ajoutées | Q026, Q027 |
| 4 | Générateur horizontal (left/right, `arena_x`) vs biomes verticaux (B3 haut, B4 bas) | Connexions top/bottom supportées dès la Phase 4 | Q032 |
| 5 | Table de rareté des recettes vs attribution des ressources aux biomes ; anciens noms de biomes dans le doc progression | Table réalignée : cristaux restent B3, imagerie volcanique réattribuée à B4 | Q042 |
| 6 | Coop évoquée comme piste forte (profil joueur) vs jamais tranchée | Solo strict, coop exclue (backlog post-v3) | Q010 |

---

## Statut : 77/77 questions tranchées (2026-07-06)

Toutes les réponses ci-dessus sont marquées ✅ TRANCHÉ. Ce document constitue la base pour la mise à jour de `roadmap.md` et des docs `docs/v3/*` avant de lancer l'agent de développement sur le projet.

---

## Ce qui est déjà tranché (ne pas re-questionner)

Pour éviter de rouvrir des décisions actées : Godot 4.5 + GDScript ; manette uniquement via `joymap.gd` ; toutes valeurs gameplay en JSON ; génération par templates de salles (pas de PCG pur) ; persistance biome pendant l'Arène par détachement de scène ; Miroir limité à 2 paramètres ; placeholders systématiques + `game_art/backlog_art.md` ; GUT avec couverture 85 % ; jalons J1-J7 et refactos R1/R1.5/R2/R3 ; textes en français ; charte dark fantasy en 2D standard (pixel art abandonné, `plan_graphismes_standard_2d.md`) ; sprites joueur ~150 px de haut (résolution native 1920×1080, `plan_resolution_1920x1080.md`) ; PNG chargés en runtime (pas de `preload`).
