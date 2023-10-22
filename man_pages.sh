#!/usr/bin/bash

export MAN_PAGES=1

declare install_path="$HOME/.local/bin/man_pages.sh"

:<<-'PARSE_OPTION'
	Parse a provided option and sets the right variables
	according to the provided option
	PARSE_OPTION
parse_option(){
	declare optarg
	declare nextarg

	while getops "$optstring" optarg
	do
		case "${OPTARG}" in [i] )
			option_install="$install_path" ;;
							[l] )
			option_list=1 ;;
							[o] )
			option_output=1
		esac
	done
}

:<<-'HELP'
	Prints help and exits
	HELP
help(){
}

main(){
	declare -i option_help=0
	declare option_install
	declare -i option_output
	declare -i option_list=0
	declare optstring="iol"
}
