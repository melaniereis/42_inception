# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: meferraz <meferraz@student.42porto.pt>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/15 16:35:04 by meferraz          #+#    #+#              #
#    Updated: 2025/08/15 09:09:41 by meferraz         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#------------------------------------------------------------------------------#
#                                   NAMES                                      #
#------------------------------------------------------------------------------#

NAME        = inception
USER        = meferraz

#------------------------------------------------------------------------------#
#                             COLORS & EMOJIS                                  #
#------------------------------------------------------------------------------#

GREEN       = \033[0;32m
BLUE        = \033[0;34m
RED         = \033[0;31m
YELLOW      = \033[0;33m
RESET       = \033[0m

CHECKMARK   = ✅
WARNING     = ⚠️
ROCKET      = 🚀
BROOM       = 🧹
TARGET      = 🎯
INFO        = ℹ️

SEPARATOR   = ===================================================

#------------------------------------------------------------------------------#
#                                 PATHS                                        #
#------------------------------------------------------------------------------#
NAME=inception
USER=meferraz

WP_VOL_PATH=~/data/wordpress
MDB_VOL_PATH=~/data/mariadb

COMPOSE=docker compose -f srcs/docker-compose.yml

.PHONY: all up down clean fclean secrets

all: up

init_dirs:
	@echo "Ensuring data directories exist and have correct permissions..."
	@mkdir -p $(WP_VOL_PATH) $(MDB_VOL_PATH)
	@sudo chown -R 999:999 $(MDB_VOL_PATH)  # For MariaDB
	@sudo chown -R 33:33 $(WP_VOL_PATH)      # For WordPress (www-data)
	@if [ ! -d "srcs/secrets" ]; then \
		mkdir -p srcs/secrets; \
		touch srcs/secrets/db_password.txt srcs/secrets/wp_admin_password.txt srcs/secrets/wp_user_password.txt; \
		chmod 600 srcs/secrets/*; \
		echo "Secret files created at srcs/secrets/"; \
	else \
		echo "Secret directory already exists, not overwriting secrets."; \
	fi

up: init_dirs
	@echo "Creating host volume directories..."
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean: down
	docker system prune -af --volumes
fclean: clean
	docker stop $(docker ps -qa)
	docker rm $(docker ps -qa)
	docker rmi -f $(docker images -qa)
	docker volume rm $(docker volume ls -q)
	docker network rm $(docker network ls -q) 2>/dev/null
