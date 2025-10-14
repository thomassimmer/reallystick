# Le tracking

Pour éviter à l’utilisateur de dire plusieurs fois qu’il a pratiqué une habitude le même jour, on créé un objet DailyTracking qui n’est pas lié à une habitude, ni à un challenge, mais uniquement à un utilisateur pour une date donnée.

Cet objet contient une propriété data, un json des activités qu’il a réalisé, dans un format correspondant à l’activité.

Dès qu’il rentre dans une habitude ou un challenge pour dire ce qu’il a fait, il touche à cet objet.

Chaque nuit, ces objets peuvent être récupérés dans une commande pour mettre à jour les statistiques des challenges / habitudes.

C’est au front de récupérer ces objets (les 5 derniers par exemple, sur la page d’accueil) pour afficher les streaks.

Dans les challenges, c’est au front aussi de déterminer si les objectifs du jour ont été atteints en regardant le DailyTracking de l’utilisateur.

Ainsi l'activité n'est pas enregistrée dans les habitudes ou les challenges mais dans ces objets, qui sont ensuite lus par les autres structures.
