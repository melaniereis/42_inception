# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: meferraz <meferraz@student.42porto.pt>     +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/07/15 16:35:04 by meferraz          #+#    #+#              #
#    Updated: 2025/08/14 14:00:05 by meferraz         ###   ########.fr        #
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

include srcs/.env

SRC         = srcs
DOCKER_YML  = $(SRC)/docker-compose.yml
COMPOSE     = docker-compose -f $(DOCKER_YML)

#------------------------------------------------------------------------------#
#                           42 SCHOOL MANDATORY RULES                         #
#------------------------------------------------------------------------------#

.PHONY: all clean fclean re

# Default target (42 school requirement)
all: volumes up  ## 🚀 Build and start all services (default target)
	@echo "$(GREEN)$(CHECKMARK) Inception is ready!$(RESET)"
	@echo "$(INFO) Access your site at: https://$(USER).42.fr"

# Clean rule - stop containers but keep images (42 school requirement)
clean:  ## 🧹 Stop and remove containers
	@echo "$(BROOM) Cleaning containers..."
	@$(COMPOSE) down --remove-orphans || true
	@echo "$(GREEN)$(CHECKMARK) Containers cleaned.$(RESET)"

# Full clean - remove everything (42 school requirement)
fclean: clean  ## 🧹 Remove containers, volumes, images and host data
	@echo "$(BROOM) Full cleanup: removing images, volumes and host data..."
	@$(COMPOSE) down --volumes --rmi all || true
	@rm -rf $(WP_VOL_PATH) $(MDB_VOL_PATH) || true
	@echo "$(GREEN)$(CHECKMARK) Full cleanup complete.$(RESET)"

# Rebuild everything (42 school requirement)
re: fclean all  ## 🔄 Full rebuild (fclean + all)

#------------------------------------------------------------------------------#
#                            SIMPLIFIED TARGETS                                #
#------------------------------------------------------------------------------#

.PHONY: up down status volumes

up:  ## 🚀 Start all services
	@echo "$(ROCKET) Starting services..."
	@$(COMPOSE) up -d --build
	@echo "$(GREEN)$(CHECKMARK) Services are up.$(RESET)"

down:  ## 🛑 Stop all services
	@echo "$(TARGET) Stopping services..."
	@$(COMPOSE) down
	@echo "$(GREEN)$(CHECKMARK) Services stopped.$(RESET)"

status:  ## 📊 Show status of all services
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(INFO) INCEPTION PROJECT STATUS"
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(TARGET) Container Status:"
	@$(COMPOSE) ps
	@echo ""
	@echo "$(TARGET) Volume Status:"
	@docker volume ls | grep $(NAME) || echo "No inception volumes found"
	@echo "$(INFO) $(SEPARATOR)"

#------------------------------------------------------------------------------#
#                          VOLUME DIRECTORY CREATION                           #
#------------------------------------------------------------------------------#

volumes:
	@echo "🎯 Creating WordPress directory at $(WP_VOL_PATH)..."
	@mkdir -p $(WP_VOL_PATH)
	@echo "🎯 Creating MariaDB directory at $(MDB_VOL_PATH)..."
	@mkdir -p $(MDB_VOL_PATH)
	@echo "$(GREEN)$(CHECKMARK) Directories ready.$(RESET)"

#------------------------------------------------------------------------------#
#                          SELF-DOCUMENTING HELP                               #
#------------------------------------------------------------------------------#

help:  ## 📚 Display this help message
	@echo "$(INFO) $(SEPARATOR)"
	@echo "$(INFO) INCEPTION PROJECT - Available Commands"
	@echo "$(INFO) $(SEPARATOR)"
	@echo ""
	@echo "$(YELLOW)42 School Mandatory Targets:$(RESET)"
	@grep -E '^(all|clean|fclean|re):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Service Management:$(RESET)"
	@grep -E '^(up|down|status|volumes):.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(YELLOW)Help:$(RESET)"
	@grep -E '^help:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""
	@echo "$(INFO) Usage: make <target>"
	@echo "$(INFO) Default: make (runs 'all' target)"
	@echo "$(INFO) $(SEPARATOR)"
