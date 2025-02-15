# infra-traefik

## Mode dev  

- copier coller le fichier `.env.example` et renommer le en `.env`  
changer les ports à l'interieur si besoin  
- verifier que le host que vous voulez creer est bien dans la liste `served-hostnames`  
- vous pouvez taper la commande `make`pour voir les commandes disponible  
- avant de lancer en mode dev, vous devez creer les certificats SSL 
lancer la commande `make cert`pour supprimer les anciens certificats et générer des nouveaux  
si le fichier n'a pas été modifier depuis la derniere generation les clef ne seront pas regenérer  
supprimer directement les anciennes clef avec la commande `make cert-clean` si vous voulez forcer la re-génération de clefs.  
- une fois les clefs generer il faut il associer à votre systeme pour que le navigateur les prenne en compte  
pour cela 2 commandes existe `make cert-mac` ou `make cert-linux` choisissez celle qui vous convient et lancé la.  
- une fois les clefs creer ou modifier + ajouter à votre system, lancer traefik en mode dev avec la commande  
`make dev` et rendez-vous sur `localhost:8080` pour accèder au dashboard

## Mode prod  

- pour le mode prod veuillez recommencer la procedure avec le fichier `.env.example`  
- vous n'avez pas besoin de faire la procedure des certificats SSL, cela est géré d'une autre façon.  
- utilisez toujours les commandes du Makefile pour lancer le mode prod, rappel de la commande `make`  
