# infra-traefik

*NOTE : vous pouvez taper la commande `make`pour voir les commandes disponible*  

## Spécificitées

- Après avoir installé mkcert sur linux via la commande apt,
  executer la command  `mkcert -install` afin de certifié les futurs certificat.  
  vous pouvez continuer l'installation  

## Génération de clefs SSL  

1. copier coller le fichier `.env.example` et renommer le en `.env`  
changer les ports à l'interieur si besoin (par default laisser les ports deja configuré)  

2. creer les certificats SSL
```bash
# si il existe deja des clefs dans le dossier `certs` supprimer les avec la commande
make cert-clean

# generer les certificats SSL
make cert

### ajouter ses certificats à votre systeme ###

# sur mac
make cert-mac

# sur linux
make cert-linux
```

3. sur mac donner confiance au certificat `localhost` dans le trousseau d'accès de votre machine

4. redémarrer votre navigateur

## Démarrer traefik en mode dev

```bash
# lancer traefik en mode dev
make up

# accèder au dashboard traefik
# ouvrir votre navigateur et taper "localhost:8080"

# arreter traefik
make down
```

## Démarrer traefik en mode prod

- pour le mode prod veuillez recommencer la procedure avec le fichier `.env.example`  
- vous n'avez pas besoin de faire la procedure des certificats SSL, cela est géré d'une autre façon.  
- utilisez toujours les commandes du Makefile pour lancer le mode prod, rappel de la commande `make`
