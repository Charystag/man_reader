#!/usr/bin/bash

export MAN_PAGES=1

declare install_path="$HOME/.local/bin/man_pages.sh"

:<<-'PARSE_OPTION'
	Parse a provided option and sets the right variables
	according to the provided option
	PARSE_OPTION
parse_option(){
	declare optarg

	while getopts "$optstring" optarg
	do
		case "${optarg}" in [i] )
			option_install="$install_path" ;;
							[l] )
			option_list=1 ;;
							[o] )
			option_output=1 ;;
							[h] )
			help ; exit 0 ;;
		esac
	done
}

:<<-'HELP'
	Prints help and exits
	HELP
help(){
	declare	suffix

	suffix=".$(echo "$0" | awk -F '.' '{print $NF}')"
	echo -e "Usage:"
	printf "%-40b%b\n" "- $0" "Opens the main menu"
	printf "%-40b%b\n" "- $0 page section" "Opens the given section in the given manpage.\nOptionnal '.' can be used \
to specify a man section to search in"
	echo -e "Example : $0 man.7 Fonts"
	echo -e "Options:"
	printf "%-12b%b\n" "\t-h" "Display this help and exits"
	printf "%-12b%b\n" "\t-l page" "Lists the sections of the given man page"
	printf "%-12b%b\n" "\t-i [PATH]" "Installs this script in the provided PATH or \
$install_path if no path is provided"
	printf "%-12b%b\n" "\t-o" "When running, output the full script in $(dirname "$0")/$(basename -s "$suffix" "$0")_full.sh"
}

main(){
	declare -i option_help=0
	declare option_install
	declare -i option_output
	declare -i option_list=0
	declare optstring="iolh"

	echo "$@|args"
	parse_option "$@"
	shift "$((OPTIND - 1))"
	OPTIND=1
}

main "$@"
