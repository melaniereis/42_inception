# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: meferraz <meferraz@student.42porto.pt>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/15 16:35:04 by meferraz          #+#    #+#              #
#    Updated: 2025/08/15 11:36:59 by meferraz         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

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
INFO        = ℹ️

#------------------------------------------------------------------------------#
#                                 PATHS                                        #
#------------------------------------------------------------------------------#

COMPOSE     = docker-compose -f srcs/docker-compose.yml

#------------------------------------------------------------------------------#
#                                 RULES                                        #
#------------------------------------------------------------------------------#

.PHONY: all build up down clean fclean logs restart

all: up

build:
	@echo "$(BLUE)$(ROCKET) Building Docker images...$(RESET)"
	$(COMPOSE) build

up:
	@echo "$(GREEN)$(CHECKMARK) Starting containers...$(RESET)"
	$(COMPOSE) up -d --build
	@echo "$(CHECKMARK) Containers are up and running!$(RESET)"
	@echo "$(INFO) Access the application at http://$(USER).42.fr$(RESET)"

down:
	@echo "$(WARNING)Stopping containers...$(RESET)"
	$(COMPOSE) down

restart: down up

clean:
	@echo "$(BROOM) Cleaning up Docker system...$(RESET)"
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	@echo "$(RED)Removing all containers, images, volumes, and networks...$(RESET)"
	docker stop $(shell docker ps -qa) 2>/dev/null || true
	docker rm $(shell docker ps -qa) 2>/dev/null || true
	docker rmi -f $(shell docker images -qa) 2>/dev/null || true
	docker volume rm $(shell docker volume ls -q) 2>/dev/null || true
	docker network rm $(shell docker network ls -q) 2>/dev/null || true

logs:
	@echo "$(BLUE)Showing logs...$(RESET)"
	$(COMPOSE) logs -f

re: fclean all
