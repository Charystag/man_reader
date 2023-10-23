#!/usr/bin/bash

export MAN_PAGES=1
trap "echo Exiting..." EXIT

declare install_path="$HOME/.local/bin/man_pages.sh"
declare remote_path="https://raw.githubusercontent.com/nsainton/Scripts/main"
declare remote_utils="https://raw.githubusercontent.com/nsainton/Scripts/main/utils/"
declare script_dir="man_pages_sections"
declare utils_dir="utils"
declare -a utils=( "${script_dir}/launcher.sh" "${script_dir}/man_pages_section.sh" \
"${script_dir}/man_splitting.sh" "${utils_dir}/colorcodes.sh" "${utils_dir}/utils.sh" )

:<<-'SOURCE_UTILS'
	Source files needed to run the script
	SOURCE_UTILS
source_utils(){	
	declare -i i=0
	declare file
	declare command

	if [ "$MAN_SPLITTING" = "1" ] ; then return 0  ; fi
	while [ "$i" -lt "${#utils[@]}" ]
	do
		file="${utils[$i]}"
		if [ "$1" != "" ] ; then command="curl -fsSL $remote_path/$file >> $install_path"
		else command=". <(curl -fsSL $remote_path/$file)" ; fi
		if [ -f "$file" ] && [ "$1" = "" ] ; then . "$file"
		elif ! eval "$command"
		then echo -e "Problem encountered while sourcing file :\e[0;31m $remote_path/$file \e[0m" ; exit 1 ; fi
		(( ++i ))
	done
	if [ "$1" != "" ] && ! curl -fsSL "$remote_path/man_pages.sh" >> "$install_path" ;
	then echo -e "Problem encountered while sourcing file :\e[0;31m $remote_path/man_pages.sh \e[0m" ; exit 1 ; fi
	echo -e "\e[0;32mAll dependencies have been installed\e[0m"
}

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
$install_path if no path is provided\n\
(This option currently takes no optionnal PATH and only installs the script in $install_path)"
#	printf "%-12b%b\n" "\t-o" "When running, output the full script in $(dirname "$0")/$(basename -s "$suffix" "$0")_full.sh"
	exit 0
}

main(){
	declare -i option_help=0
	declare option_install
	declare -i option_output
	declare -i option_list=0
	declare optstring="iolh"
	local ret_val

	parse_option "$@"
	shift "$((OPTIND - 1))"
	OPTIND=1
	if [ "$option_help" -eq "1" ] ; then help ; fi
	if [ "$option_install" != "" ] ; then source_utils 1 ; fi
	source_utils
	if [ "$option_list" -eq "1" ] ; then print_sections "$1" ; return 0 ; fi
	if [ "${#@}" -ne "2" ] && [ "${#@}" -ne "0" ]
	then echo -e "${RED}Error${CRESET} : Invalid number of arguments provided" ; help ; fi
	if [ "${#@}" -eq "2" ] ; then man_section "$@" ; return 0 ; fi
	main_menu
}

main "$@"
