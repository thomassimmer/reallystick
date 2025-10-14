Pour permettre une messagerie chiffré de bout-en-bout, nous avons besoin de paire de clés publique / privée pour chaque utilisateurs.

La complexité ici réside dans le fait que :
- l'utilisateur peut se connecter sur un autre appareil et doit donc pouvoir récupérer sa clé privée de n'importe où pour lire ses messages.
- l'utilisateur peut oublier son mot de passe et utiliser un code de récupération pour avoir à nouveau accès à son compte.

Fonctionnement :

1. Première connexion :
    L'utilisateur rentre son mot de passe et son nom d'utilisateur. Une paire de clé public / privé est générée et stockée grâce à FlutterSecureStorage. C'est la paire "principal". On chiffre ensuite la clé privée à l'aide du mot de passe. On génère ensuite un code de récupération. On chiffre ensuite la clé privée à l'aide de ce code. On envoie au back:
        - le nom d'utilisateur
        - le mot de passe
        - le code de récupération
        - la clé publique
        - la clé privée chiffrée par le mot de passe
        - le sel utilisé pour chiffrer la clé privée chiffrée par le mot de passe
        - la clé privée chiffrée par le code de récupération
        - le sel utilisé pour chiffrer la clé privée chiffrée par le code de récupération

    Le serveur hache puis stocke le mot de passe et le code de récupération, ainsi que les autres éléments passés.

2. Connexion ultérieure :
    L'utilisateur se connecte grâce à son nom d'utilisateur et son de mot de passe. Le back vérifie que c'est bon et renvoie la clé privée chiffrée par le mot de passe. L'utilisateur peut la déchiffrer en front et la stocker avec FlutterSecureStorage. Il peut donc se connecter de n'importe quel appareil et pouvoir lire ses messages. Il faut bien faire attention à supprimer sa clé privée de l'appareil lorsqu'il se déconnecte.

    -> Problème ici si on veut pouvoir déconnecter un appareil à distance. Invalider la session ne rend pas invalide la clé privée stockée. Il faudrait pouvoir la désactiver en même temps que le token d'accès.

3. Génération d'un nouveau code de récupération :
    A tout moment, l'utilisateur a la possibilité de générer un nouveau code de récupération. Le code est généré en front. On chiffre la clé privée principale avec. On envoie le code et la clé principale chiffrée par le code de récupération au back qui remplace celui existant.

4. Changement de mot de passe :
    Idem que pour le nouveau code de récupération mais on chiffre avec le mot de passe.

5. Envoie de message :
    L'utilisateur tape un message. Une paire de clés publique / privé est créée pour ce message. Le message est chiffré avec la clé publique. On chiffre la clé privée avec la clé publique principale du créateur. On chiffre également la clé privée avec la clé publique principale du destinataire. On stocke en back :
        - le contenu du message chiffré par la clé publique qui vient d'être créée
        - la clé privée qui vient d'être créée chiffré par la clé publique du créateur
        - le sel utilisé pour chiffrer la clé privée par la clé publique du créateur
        - la clé privée qui vient d'être créée chiffré par la clé publique du destinataire
        - le sel utilisé pour chiffrer la clé privée par la clé publique du destinataire

6. Lecture de message :
    Pour lire un message, il suffit de déchiffrer la clé privée associée au message avec sa clé principale, puis déchiffrer le contenu du message avec cette clé déchiffrée.
