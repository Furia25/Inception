NAME			= inception

USER			?= $(shell whoami)
DATA_PATH		= /home/$(USER)/data

COMPOSE_DIR		= srcs
COMPOSE_FILE	= $(COMPOSE_DIR)/docker-compose.yml
ENV_FILE		= $(COMPOSE_DIR)/.env

COMPOSE			= docker compose --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

SECRET_FILES = db_password db_root_password wp_admin_password wp_user_password

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

init-secrets:
	@mkdir -p $(COMPOSE_DIR)/secrets
	@for f in $(SECRET_FILES); do \
		if [ ! -f $(COMPOSE_DIR)/secrets/$$f.txt ]; then \
			openssl rand -base64 24 > $(COMPOSE_DIR)/secrets/$$f.txt; \
			echo "$$f.txt genere."; \
		else \
			echo "$$f.txt existe deja, ignore."; \
		fi \
	done

secrets:
	@if [ ! -d $(COMPOSE_DIR)/secrets ]; then \
		echo "Directory $(COMPOSE_DIR)/secrets is missing."; \
		echo "Need: $(SECRET_FILES)"; \
		exit 1; \
	fi

clean: down
	docker system prune -af

fclean: clean
	@sudo rm -rf $(DATA_PATH)/mariadb/*
	@sudo rm -rf $(DATA_PATH)/wordpress/*
	docker volume prune -f
	docker network prune -f

re: fclean all

.PHONY: all up down stop start restart logs ps data secrets clean fclean re