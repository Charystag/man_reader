#!/usr/bin/bash
# shellcheck disable=SC1090 # sources will never be constant

export MAN_PAGES=1
trap "echo Exiting..." EXIT

declare install_path="$HOME/.local/bin/man_pages.sh"
declare remote_path="https://raw.githubusercontent.com/nsainton/Scripts/main"
declare script_dir="man_reader_utils"
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
	if [ "$1" != "" ] && ! curl -fsSL "$remote_path/man_reader.sh" >> "$install_path" ;
	then echo -e "Problem encountered while sourcing file :\e[0;31m $remote_path/man_pages.sh \e[0m" ; exit 1 ; fi
	echo -e "\e[0;32mAll dependencies are met\e[0m"
}

:<<-'INSTALL_SCRIPT'
	Installs the script in the required location
	INSTALL_SCRIPT
install_script(){
	declare installed_prompt

	installed_prompt="Script installed at : $install_path"
	if [ -f "$install_path" ]
	then echo -e "Script already exists at : $install_path" ; exit 0 ; fi
	if ! mkdir -p "$(dirname "$install_path")"
	then echo "Couldn't create directory : $(dirname "$install_path")" ; exit 1
	else touch "$install_path" && chmod "+x" "$install_path" && \
	source_utils 1 && echo -e "$installed_prompt" && exit 0 ; fi
	echo -e "Couldn't install script"
	exit 1
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
							[h] )
			help ; exit 0 ;;
		esac
	done
}

:<<-'HELP'
	Prints help and exits
	HELP
help(){
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
	exit 0
}

:<<-'TOC'
	Prints the table of contents of a given man page
	Usage: toc page
	Where page is the name (optionnaly followed with a '.' for the section) of a man page
	TOC
toc(){
	declare page

	find_page_section "$1"
	if [ "$ret_val" = "" ] ; then return 1 ; fi
	page="$ret_val"
	add_slash page "b"
	print_sections "$page"
	return 0
}

main(){
	declare -i option_help=0
	declare option_install
	declare -i option_list=0
	declare optstring="ilh"
	local ret_val

	parse_option "$@"
	shift "$((OPTIND - 1))"
	OPTIND=1
	if [ "$option_help" -eq "1" ] ; then help ; fi
	if [ "$option_install" != "" ]
	then install_script ; fi
	source_utils
	if [ "$option_list" -eq "1" ] ; then toc "$1" ; return "$?" ; fi
	if [ "${#@}" -gt "2" ]
	then echo -e "${RED}Error${CRESET} : Invalid number of arguments provided" ; help ; fi
	if [ "${#@}" -eq "1" ] ; then read_page "$@" ; return 0 ; fi
	if [ "${#@}" -eq "2" ] ; then man_section "$@" ; return 0 ; fi
	main_menu
}

main "$@"
