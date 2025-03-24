# Détection de Lima et récupération du bon socket Docker
IS_LIMA=$(shell ps aux | grep -v grep | grep -i lima >/dev/null && echo 1 || echo 0)
DOCKER_SOCKET_PATH=$(if $(filter 1,$(IS_LIMA)),/run/user/501/docker.sock,/var/run/docker.sock)

# Commandes Docker Compose avec la bonne socket
DOCKER_COMPOSE_DEV=DOCKER_SOCKET_PATH=$(DOCKER_SOCKET_PATH) docker compose -f compose.dev.yaml $(if $(filter 1,$(IS_LIMA)),-f compose.override.yaml)
DOCKER_COMPOSE_PROD=docker compose -f compose.prod.yaml
DOCKER_EXE=docker exec -it

# key ssl variable
MKCERT := $(shell which mkcert 2>/dev/null)
CERT_DIR=certs
CERT_FILE=$(CERT_DIR)/selfsigned.pem
KEY_FILE=$(CERT_DIR)/selfsigned.key
SERV_HOST=served-hostnames

# Misc
.DEFAULT_GOAL = help
.PHONY        : help dev prod stop logs status cert cert-mac cert-linux cert-clean

## —— 🎵 🐳 The Traefik Docker Makefile 🐳 🎵 ——————————————————————————————————
help: ## Outputs this help screen
	@grep -E '(^[a-zA-Z0-9\./_-]+:.*?##.*$$)|(^##)' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}{printf "\033[32m%-30s\033[0m %s\n", $$1, $$2}' | sed -e 's/\[32m##/[33m/'

## —— 🎵 🐳 Mode DEV 🐳 🎵 ——————————————————————————————————

up: ## Start Traefik mode dev
	@echo "🚀 🐳 🎵 Lancement de Traefik en mode DEV..."
	$(DOCKER_COMPOSE_DEV) up -d
	@echo "✅ 🐳 🎵 Start en mode DEV OK..."


cert-clean: ## clean certificats
	@echo "🧹 Suppression des anciens certificats..."
	@rm -f $(CERT_FILE) $(KEY_FILE) 2>/dev/null || true
	@echo "✅ Certificats nettoyés."

cert: cert-clean ## Generate keys certs for dev mode with mkcert
	@if [ -z "$(MKCERT)" ]; then \
		echo "⚠️ mkcert non trouvé. Installez-le avec 'brew install mkcert' sur macOS ou 'sudo apt install mkcert' sur Linux"; \
		exit 1; \
	fi
	@echo "🔐 Génération du certificat auto-signé..."
	@echo "Liste des hostnames :"
	@cat $(SERV_HOST)
	@echo "🚀 Génération en cours..."
	@$(MKCERT) -cert-file $(CERT_FILE) -key-file $(KEY_FILE) `cat $(SERV_HOST) | xargs`
	@echo "✅ Génération terminée..."
	@echo "Liste des fichiers générés :"
	@ls -l $(CERT_DIR)
	@echo "✅ Génération OK..."

cert-mac: ## add certificate in macOS
	@echo "🚀 🔐 Ajout du certificat dans la machine locale (macOS)"
	@sudo security delete-certificate -c "localhost" /Library/Keychains/System.keychain 2>/dev/null || true
	@sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain $(CERT_FILE)
	@echo "✅ Certificat ajouté avec succès."

cert-linux: ## add certificate in linux
	@echo "🚀 🔐 Ajout du certificat dans la machine locale (linux)"
	@if [ -d /usr/local/share/ca-certificates ]; then \
		sudo cp $(CERT_FILE) /usr/local/share/ca-certificates/selfsigned.crt; \
		sudo update-ca-certificates; \
	elif [ -d /etc/pki/ca-trust/source/anchors ]; then \
		sudo cp $(CERT_FILE) /etc/pki/ca-trust/source/anchors/selfsigned.crt; \
		sudo update-ca-trust; \
	else \
		echo "⚠️ Impossible de détecter le gestionnaire de certificats de votre système."; \
	fi
	@echo "✅ Certificat ajouté avec succès."

## —— 🎵 🐳 🚀 Mode PROD 🚀 🐳 🎵 ——————————————————————————————————

prod: ## Start Traefik mode prod
	@echo "🚀 Lancement de Traefik en mode PROD..."
	$(DOCKER_COMPOSE_PROD) up -d
	@echo "✅ 🎵 Start en mode PROD OK..."

prod-delete-cert: ## Force le renouvellement des certificats Let's Encrypt
	@echo "🚀 Suppression des certificats Let's Encrypt..."
	@rm -f letsencrypt/acme.json
	@echo "✅ Certificats supprimés. Relance Traefik pour en générer de nouveaux."

## —— 🐳 Commande générique 🐳 ——————————————————————————————————

down: ## Stop All Traefik
	@echo "🛑 Arrêt de Traefik, arrêt de tout les containers du réseau..."
	$(DOCKER_COMPOSE_DEV) down --remove-orphans
	$(DOCKER_COMPOSE_PROD) down --remove-orphans

logs: ## logs of Traefik real time
	@echo "📜 Affichage des logs de Traefik..."
	$(DOCKER_COMPOSE_DEV) logs -f traefik || $(DOCKER_COMPOSE_PROD) logs -f traefik

shell: ## go to shell container
	@echo "📜 Start shell container traefik..."
	@$(DOCKER_EXEC) traefik-nseven sh

status: ## Check status of Traefik
	@echo "🔍 Vérification du statut des conteneurs..."
	docker ps | grep traefik || echo "⚠️ Traefik ne tourne pas !"

debug-sock:
	@echo "IS_LIMA=$(IS_LIMA)"
	@echo "DOCKER_SOCKET_PATH=$(DOCKER_SOCKET_PATH)"