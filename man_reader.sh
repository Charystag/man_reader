#!/usr/bin/bash
# shellcheck disable=SC1090 # sources will never be constant

declare NAME="man_reader"
declare VERSION_ID=4

export MAN_PAGES=1
trap "echo Exiting..." EXIT

declare install_path="$HOME/.local/bin/man_reader"
declare remote_path="https://raw.githubusercontent.com/nsainton/Scripts/main"
declare script_dir="man_reader_utils"
declare utils_dir="utils"
declare -a utils=( "${script_dir}/launcher.sh" "${script_dir}/man_pages_section.sh" \
"${script_dir}/man_splitting.sh" "${utils_dir}/colorcodes.sh" "${utils_dir}/utils.sh" \
"${script_dir}/.version" )

:<<-'SOURCE_UTILS'
	Source files needed to run the script
	SOURCE_UTILS
source_utils(){	
	declare -i i=0
	declare file
	declare command

	if [ "$MAN_SPLITTING" = "1" ] && [ "$1" = "" ] ; then return 0  ; fi
	while [ "$i" -lt "${#utils[@]}" ]
	do
		file="${utils[$i]}"
		if [ "$1" != "" ] ; then command="curl --connect-timeout 10 -fsSL $remote_path/$file >> $install_path"
		else command=". <(curl --connect-timeout 10 -fsSL $remote_path/$file)" ; fi
		if [ -f "$file" ] && [ "$1" = "" ] ; then . "$file"
		elif ! eval "$command"
		then echo -e "Problem encountered while sourcing file :\e[0;31m $remote_path/$file \e[0m" ; exit 1 ; fi
		(( ++i ))
	done
	file="man_reader.sh"
	if [ "$1" != "" ] && ! curl -fsSL "$remote_path/$file" >> "$install_path" ;
	then echo -e "Problem encountered while sourcing file :\e[0;31m $remote_path/$file \e[0m" ; exit 1 ; fi
	echo -e "\e[0;32mAll dependencies are met\e[0m"
}

:<<-'INSTALL_SCRIPT'
	Installs the script in the required location
	INSTALL_SCRIPT
install_script(){
	declare installed_prompt
	declare -l user_reply
	declare RED="\e[0;31m"
	declare CRESET="\e[0m"

	installed_prompt="Script installed at : $install_path"
	if [ -f "$install_path" ]
	then
		echo -e "Script already exists at : $install_path.\n\
Would you like to remove and install? [y/n]"
		read -r -n 1 user_reply
		echo
		if [ "$user_reply" != 'y' ] ; then return 0 ; fi
		if ! rm "$install_path" ; then echo "Couldn't remove : $install_path" ; fi
	fi
	echo -e "Installing script..."
	if ! mkdir -p "$(dirname "$install_path")"
	then echo -e "${RED}Couldn't create directory${CRESET} : $(dirname "$install_path")" ; exit 1
	else touch "$install_path" && chmod "+x" "$install_path" && \
	source_utils 1 && echo -e "$installed_prompt" && return 0 ; fi
	echo -e "${RED}Couldn't install script${CRESET}"
	return 1
}

:<<-'CHECK_UPDATE'
	Check for updates in remote version of script
	If an update is needed, it will prompt the user to update the script
	CHECK_UPDATE
check_update(){
	declare update_prompt
	declare -l user_input
	declare version_file
	
	update_prompt="An update is available. Would you like to update ?[y/n]"
	version_file="${remote_path}/${script_dir}/.version"
	if ! . <(curl --connect-timeout 10 --stderr /dev/null -fsSL "$version_file") ; then return ; fi
	if [ "$((VERSION_ID))" -ge "$((REMOTE_VERSION_ID))" ] ; then return ; fi
	echo -e "$update_prompt"
	read -r -n 1 user_input
	echo
	case "$user_input" in ( [y] ) 
			rm -f "$install_path" && install_script \
			&& option_install= && echo -e "You can now relaunch the script to run with new update" && exit 0 || echo -e "Couldn't update script " ;;
								[n] ) echo "Not updating" ;;
								* ) echo "Unrecognized option" ;;
	esac
	echo -e "To update, you can run $NAME -i"
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
			help ;;
							[n] )
			no_autoupdate=1 ;;
		esac
	done
}

:<<-'HELP'
	Prints help and exits
	HELP
help(){
	echo -e "Usage:"
	printf "%-40b%b\n" "- man_reader" "Opens the main menu"
	printf "%-40b%b\n" "- man_reader page section" "Opens the given section in the given manpage.\nOptionnal '.' can be used \
to specify a man section to search in"
	echo -e "Example : man_reader man.7 Fonts or man_reader man.7 3"
	echo -e "If your man page contains a '.', like sources.list for the apt package, you can replace the '.' by a '=' \
when providing a section name.\n\
Example : man_reader sources=list will look for the sources.list man page (which is in section 5)"
	echo -e "Options:"
	printf "%-12b%b\n" "\t-h" "Display this help and exits"
	printf "%-12b%b\n" "\t-n" "Runs the script without checking for update. Mainly for usage within scripts"
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
	declare -i no_autoupdate=0
	declare option_install
	declare -i option_list=0
	declare optstring="ilhn"
	declare -l user_input
	local ret_val

	parse_option "$@"
	shift "$((OPTIND - 1))"
	OPTIND=1
	if [ "$option_help" -eq "1" ] ; then help ; fi
	if [ "$no_autoupdate" -eq "0" ] ; then check_update ; fi
	if [ "$option_install" != "" ] ; then install_script ; exit "$?" ; fi
	source_utils
	if [ "$option_list" -eq "1" ] ; then toc "$1" ; return "$?" ; fi
	if [ "${#@}" -gt "2" ]
	then echo -e "${RED}Error${CRESET} : Invalid number of arguments provided" ; help ; fi
	if [ "${#@}" -eq "1" ] ; then read_page "$@" ; return 0 ; fi
	if [ "${#@}" -eq "2" ] ; then man_section "$@" ; return 0 ; fi
	main_menu
}

main "$@"
