USER        := $(shell whoami)
DATA_DIR    := /home/$(USER)/data
COMPOSE     := docker compose -f srcs/docker-compose.yml

all: setup
	$(COMPOSE) up -d --build

setup:
	mkdir -p $(DATA_DIR)/db $(DATA_DIR)/wordpress
	grep -qxF "127.0.0.1 ajelloul.42.fr" /etc/hosts || \
		echo "127.0.0.1 ajelloul.42.fr" | sudo tee -a /etc/hosts

down:
	$(COMPOSE) down

clean: down
	docker system prune -af
	sudo rm -rf $(DATA_DIR)

re: clean all

.PHONY: all setup down clean re
