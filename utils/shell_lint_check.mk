# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: nsainto <nsainton@student.42.fr>           +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2023/09/19 14:18:51 by nsainto           #+#    #+#              #
#    Updated: 2023/09/19 15:43:43 by nsainto          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

RED=\e[0;31m
GRN=\e[0;32m
BLU=\e[0;34m
CRESET=\e[0m

SHELL = /usr/bin/bash

SHELL_FILES := $(shell find . -path "*.sh")

define lint_check = 
LOGS="$@.log"
shellcheck $(1) > $$LOGS
RESULT=$$?
if [ $$RESULT -ne 0 ]
then
	printf "%b\n" "$(RED) Errors found in $(BLU) $(1) $(RED), checking stops $(CRESET)"
	cat $$LOGS
	rm -f $$LOGS
	exit 1
else
	printf "%b\n" "$(GRN) No error found in $(BLU) $(1) $(CRESET)"
	rm -f $$LOGS
fi

endef

.PHONY: check
check:
	@$(foreach arg, $(SHELL_FILES), $(call lint_check,$(arg)))

.ONESHELL:
