NAME			= inception

USER			?= $(shell whoami)
DATA_PATH		= /home/$(USER)/data

MODE ?= normal

COMPOSE_DIR			= srcs
COMPOSE_FILE		= $(COMPOSE_DIR)/docker-compose.yml
COMPOSE_BONUS_FILE	= $(COMPOSE_DIR)/docker-compose-bonus.yml
ENV_FILE			= $(COMPOSE_DIR)/.env

COMPOSE = docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE) $(if $(filter bonus,$(MODE)),-f $(COMPOSE_BONUS_FILE),)

SECRET_DIR = ./secrets
SECRET_FILES = db_password db_root_password wp_admin_password wp_user_password ftp_password

all: up

up: data secrets
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

restart: down up

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

data:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	if [ "$(MODE)" = "bonus" ]; then \
		mkdir -p $(DATA_PATH)/redis; \
		mkdir -p $(DATA_PATH)/ftp; \
		mkdir -p $(DATA_PATH)/adminer; \
		mkdir -p $(DATA_PATH)/static; \
		mkdir -p $(DATA_PATH)/portainer; \
	fi

clean-data:
	@sudo rm -rf $(DATA_PATH)/*

init-secrets:
	@mkdir -p $(SECRET_DIR)
	@for f in $(SECRET_FILES); do \
		if [ ! -f $(SECRET_DIR)/$$f.txt ]; then \
			openssl rand -base64 24 > $(SECRET_DIR)/$$f.txt; \
			echo "$$f.txt generated."; \
		fi \
	done

secrets:
	@missing=0; \
	if [ ! -d $(SECRET_DIR) ]; then \
		echo "Directory $(SECRET_DIR) is"; \
		mkdir -p $(SECRET_DIR); \
	fi; \
	for f in $(SECRET_FILES); do \
		if [ ! -f $(SECRET_DIR)/$$f.txt ]; then \
			echo "Missing: $(SECRET_DIR)/$$f.txt"; \
			missing=1; \
		fi; \
	done; \
	if [ $$missing -eq 1 ]; then \
		echo "Create the missing files before running 'make up'."; \
		exit 1; \
	fi

clean: down
	docker system prune -af

fclean: clean clean-data
	docker volume prune -f
	docker network prune -f


re: fclean all

.PHONY: all up down stop start restart logs ps data secrets clean fclean re clean-data init-secrets