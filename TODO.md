# Todo list

## Réflexion sur le fonctionnement

Il y a deux différentes données à étudier : 

Les tâches qui n'ont qu'une durée : elles peuvent s'enchainer normalement
Les tâches qui ont un headline : elles doivent commencer le moment venu

Prenons un cas concert : il est 11:30 et l'on lance la lecture des tâches.
* Si des tâches sont d'un jour précédent => on les supprime
* Si des tâches sont d'aujourd'hui mais avant l'heure => on doit demander quoi faire => proposer d'organiser les tâches en fonction du temps
* Si des tâches sont pour la suite du jour, mais se chevauchent, demander s'il faut les organiser

=> Faire en testant une méthode Alertes.organiser