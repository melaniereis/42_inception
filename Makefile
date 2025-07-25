# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: meferraz <meferraz@student.42porto.pt>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/15 16:35:04 by meferraz          #+#    #+#              #
#    Updated: 2025/07/25 21:36:57 by meferraz         ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

#----------------------------------------------------------------------------#
#                                   NAMES                                    #
#----------------------------------------------------------------------------#

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
BUG         = 🐞
TARGET      = 🎯
INFO        = ℹ️
GEAR        = ⚙️

SEPARATOR   = ===================================================

#------------------------------------------------------------------------------#
#                                 PATHS                                        #
#------------------------------------------------------------------------------#

SRC         = srcs
DOCKER_YML  = $(SRC)/docker-compose.yml

#------------------------------------------------------------------------------#
#                                COMMANDS                                      #
#------------------------------------------------------------------------------#

DOCKER      = docker
COMPOSE     = $(DOCKER) compose -f $(DOCKER_YML) -p $(NAME)

#------------------------------------------------------------------------------#
#                              SERVICE NAMES                                   #
#------------------------------------------------------------------------------#

NGINX       = nginx
WORDPRESS   = wordpress
MARIADB     = mariadb

#------------------------------------------------------------------------------#
#                           42 SCHOOL MANDATORY RULES                         #
#------------------------------------------------------------------------------#

.PHONY: clean fclean re help check_env check_volumes

# Default target (42 school requirement)
all: $(NAME)  ## 🚀 Build and start all services (default target)

# Main target - equivalent to $(NAME) rule (42 school requirement)
$(NAME): .inception_up  ## 🎯 Complete inception setup

# Inception setup - checks environment, builds images, and starts services
.inception_up: $(DOCKER_YML)
	@$(MAKE) check_env check_volumes build up
	@touch .inception_up
	@echo "$(GREEN)$(CHECKMARK) Inception is ready.$(RESET)"

# Clean rule - stop containers but keep images (42 school requirement)
clean:  ## 🧹 Stop and remove containers
	@echo "$(BROOM) Cleaning containers..."
	@$(COMPOSE) down --remove-orphans || true
	@rm -f .inception_up
	@echo "$(CHECKMARK) Containers cleaned."

# Full clean - remove everything (42 school requirement)
fclean: clean  ## 🧹 Remove containers, volumes, and images
	@echo "$(BROOM) Full cleanup: removing images and volumes..."
	@$(COMPOSE) down --volumes --remove-orphans || true
	@$(DOCKER) system prune -f || true
	@$(DOCKER) rm inception_db_data inception_wp_data || true
	@$(DOCKER) volume prune -f || true
	@echo "$(CHECKMARK) Full cleanup complete."

# Rebuild everything (42 school requirement)
re: fclean all  ## 🔄 Full rebuild (fclean + all)

#------------------------------------------------------------------------------#
#                            ENHANCED TARGETS                                  #
#------------------------------------------------------------------------------#

.PHONY: build up down restart logs status debug
.PHONY: nginx wordpress mariadb
.PHONY: nginx-logs wordpress-logs mariadb-logs
.PHONY: nginx-shell wordpress-shell mariadb-shell

# Environment and volume checks
check_env:  ## 🔍 Check Docker environment prerequisites
	@echo "$(TARGET) Checking environment..."
	@if ! command -v $(DOCKER) > /dev/null 2>&1; then \
		echo "$(RED)$(WARNING) Docker is not installed. Please install Docker.$(RESET)"; exit 1; \
	fi
	@if ! $(DOCKER) info > /dev/null 2>&1; then \
		echo "$(RED)$(WARNING) Cannot connect to Docker daemon. Is Docker running?$(RESET)"; exit 1; \
	fi
	@echo "$(GREEN)$(CHECKMARK) Docker is available and running.$(RESET)"
	@if [ "$$($(DOCKER) ps -q)" != "" ]; then \
		echo "$(YELLOW)$(WARNING) Found running containers. Use 'make clean' first if needed.$(RESET)"; \
	fi

check_volumes:  ## 📁 Ensure host volume directories exist
	@echo "$(TARGET) Checking host volumes..."
	@mkdir -p $(HOME)/data/db $(HOME)/data/wp
	@chown -R $(shell id -u):$(shell id -g) $(HOME)/data
	@chmod -R 775 $(HOME)/data
	@echo "$(GREEN)$(CHECKMARK) Volumes at $(HOME)/data/ are ready.$(RESET)"

# Build and deployment
build:  ## 🔨 Build all Docker images
	@echo "$(TARGET) Building Docker images..."
	@$(COMPOSE) build --no-cache
	@echo "$(GREEN)$(CHECKMARK) Build complete.$(RESET)"

up:  ## 🚀 Start all services in detached mode
	@echo "$(ROCKET) Starting services..."
	@$(COMPOSE) up -d
	@echo "$(GREEN)$(CHECKMARK) Services are up.$(RESET)"
	@echo "$(INFO) Access your site at: https://$(USER).42.fr"

down:  ## 🛑 Stop all services
	@echo "$(BUG) Stopping services..."
	@$(COMPOSE) down
	@echo "$(GREEN)$(CHECKMARK) Services stopped.$(RESET)"

restart: down up  ## 🔄 Restart all services

#------------------------------------------------------------------------------#
#                         INDIVIDUAL SERVICE MANAGEMENT                        #
#------------------------------------------------------------------------------#

# Individual service targets
nginx:  ## 🌐 Start only NGINX service
	@echo "$(ROCKET) Starting NGINX..."
	@$(COMPOSE) up -d $(NGINX)
	@echo "$(GREEN)$(CHECKMARK) NGINX is running.$(RESET)"

wordpress:  ## 📝 Start WordPress service (requires MariaDB)
	@echo "$(ROCKET) Starting WordPress..."
	@$(COMPOSE) up -d $(MARIADB) $(WORDPRESS)
	@echo "$(GREEN)$(CHECKMARK) WordPress is running.$(RESET)"

mariadb:  ## 🗄️ Start only MariaDB service
	@echo "$(ROCKET) Starting MariaDB..."
	@$(COMPOSE) up -d $(MARIADB)
	@echo "$(GREEN)$(CHECKMARK) MariaDB is running.$(RESET)"

#------------------------------------------------------------------------------#
#                              LOGGING & DEBUGGING                             #
#------------------------------------------------------------------------------#

logs:  ## 📋 Show logs for all services
	@echo "$(TARGET) Showing logs for all services..."
	@$(COMPOSE) logs -f

nginx-logs:  ## 📋 Show NGINX logs
	@echo "$(TARGET) Showing NGINX logs..."
	@$(COMPOSE) logs -f $(NGINX)

wordpress-logs:  ## 📋 Show WordPress logs
	@echo "$(TARGET) Showing WordPress logs..."
	@$(COMPOSE) logs -f $(WORDPRESS)

mariadb-logs:  ## 📋 Show MariaDB logs
	@echo "$(TARGET) Showing MariaDB logs..."
	@$(COMPOSE) logs -f $(MARIADB)

#------------------------------------------------------------------------------#
#                             SHELL ACCESS                                     #
#------------------------------------------------------------------------------#

nginx-shell:  ## 💻 Access NGINX container shell
	@echo "$(GEAR) Accessing NGINX container..."
	@$(COMPOSE) exec $(NGINX) /bin/sh

wordpress-shell:  ## 💻 Access WordPress container shell
	@echo "$(GEAR) Accessing WordPress container..."
	@$(COMPOSE) exec $(WORDPRESS) /bin/bash

mariadb-shell:  ## 💻 Access MariaDB container shell
	@echo "$(GEAR) Accessing MariaDB container..."
	@$(COMPOSE) exec $(MARIADB) /bin/bash

#------------------------------------------------------------------------------#
#                          STATUS & MONITORING                                 #
#------------------------------------------------------------------------------#

status:  ## 📊 Show status of all services
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(INFO) INCEPTION PROJECT STATUS"
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(TARGET) Docker System Info:"
	@$(DOCKER) system df
	@echo ""
	@echo "$(TARGET) Container Status:"
	@$(COMPOSE) ps
	@echo ""
	@echo "$(TARGET) Network Status:"
	@$(DOCKER) network ls | grep $(NAME) || echo "No inception networks found"
	@echo ""
	@echo "$(TARGET) Volume Status:"
	@$(DOCKER) volume ls | grep $(NAME) || echo "No inception volumes found"
	@echo "$(INFO) $(SEPARATOR)"

debug:  ## 🐞 Show detailed debug information
	@echo "$(BUG) $(SEPARATOR)"
	@echo "$(BUG) INCEPTION DEBUG INFORMATION"
	@echo "$(BUG) $(SEPARATOR)"
	@echo "$(TARGET) Docker Version:"
	@$(DOCKER) --version
	@echo ""
	@echo "$(TARGET) Docker Compose Version:"
	@$(COMPOSE) version
	@echo ""
	@echo "$(TARGET) System Resources:"
	@$(DOCKER) system info | grep -E "(CPUs|Total Memory|Docker Root Dir)"
	@echo ""
	@echo "$(TARGET) Active Networks:"
	@$(DOCKER) network ls
	@echo ""
	@echo "$(TARGET) All Volumes:"
	@$(DOCKER) volume ls
	@echo ""
	@echo "$(TARGET) Running Containers:"
	@$(DOCKER) ps -a
	@echo "$(BUG) $(SEPARATOR)"

#------------------------------------------------------------------------------#
#                          SELF-DOCUMENTING HELP                               #
#------------------------------------------------------------------------------#

help:  ## 📚 Display this help message
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(INFO) INCEPTION PROJECT - Available Commands"
	@echo "$(INFO) $(SEPARATOR)"
	@echo ""
	@echo "$(YELLOW)42 School Mandatory Targets:$(RESET)"
	@grep -E '^(all|$(NAME)|clean|fclean|re):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Build & Deployment:$(RESET)"
	@grep -E '^(check_env|check_volumes|build|up|down|restart):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Individual Services:$(RESET)"
	@grep -E '^(nginx|wordpress|mariadb):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Logging & Debugging:$(RESET)"
	@grep -E '^(logs|.*-logs|.*-shell|status|debug):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Help:$(RESET)"
	@grep -E '^help:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(INFO) Usage: make <target>"
	@echo "$(INFO) Default: make (runs 'all' target)"
	@echo "$(INFO) $(SEPARATOR)"
