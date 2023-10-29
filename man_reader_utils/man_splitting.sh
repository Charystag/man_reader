#!/usr/bin/bash

export MAN_SPLITTING=1

#-----------------------------------------------------------------------
#----------------------------PAGE RETRIEVAL-----------------------------
#-----------------------------------------------------------------------

:<<-'RETRIEVE_PAGE'
	If multiple pages are found when looking for a man page in a given section
	Ensure to take the non posix one
	Usage: retrieve_page pages
	RETRIEVE_PAGE
retrieve_page(){
	declare -i i=0
	declare -a pages

	if [ "$1" = "" ] ; then return 1 ; fi
	IFS=' ' read -ra pages<<<"$1"
	if [ "${#pages[@]}" -lt "2" ] ; then ret_val="${pages[0]}" ; return 0 ; fi
	while [ "$i" -lt "${#pages[@]}" ]
	do
		if echo "${pages[$i]}" | grep -E -i "posix" 1>/dev/null
		then (( ++i )) ; else ret_val="${pages[$i]}" ; return 0 ; fi
	done
	ret_val="${pages[$((i-1))]}"
	return 0
}

:<<-'FIND_PAGE_SECTION'
	Finds a man page in a given man section or picks the first man page available
	FIND_PAGE_SECTION
find_page_section(){
	declare prompt
	declare page="$1"
	declare pages
	declare section
	declare available_sections
	declare -a vars

	prompt="please give a man page to find, you can give an optional section with a .\n
Example: wait.2"
	if [ "$1" = "" ] ; then user_input "$prompt" page ; fi
	IFS='.' read -ra vars <<<"$page"
	page="$(echo "${vars[0]}" | tr '=' '.')"
	if [ "${vars[1]}" != "" ] ; then section="${vars[1]}" ; fi
	pages="$(whereis "$page"  | grep -E -o "\<[^ ]+man/man${section}[^ ]+\>" | tr '\n' ' ' | rev | cut -c 2- | rev)"
	if [ "$pages" = "" ] && [ "$section" != "" ]
	then 
		printf "%b\n" "${page} ${RED}not found ${CRESET}in section ${section}. Picking first match"
		pages="$(whereis "$page"  | grep -E -o "\<[^ ]+man/man[^ ]+\>" | tr '\n' ' ' | rev | cut -c 2- | rev)"
	fi
	retrieve_page "$pages"
	section="$(echo "$ret_val" | grep -E -o "[[:digit:]]+")"
	section="${section:0:1}"
	if [ "$section" != "" ] ; then printf "%b\n" "${GRN}Man page${CRESET} from : section ${GRN}$section${CRESET}" ; fi
	if [ "$ret_val" = "" ] ; then echo -e "${page} ${RED}not found ${CRESET}" ; return 1 ; fi
	available_sections="$(whereis "$page" | grep -E -o '[[:digit:]]' | uniq | tr '\n' '-' | rev | cut -c 2- | rev)"
	printf "%b\n" "${GRN}Available sections ${CRESET}are : $available_sections"
}

#-------------------------------------------------------------------------------------------------
#------------------------------------SECTIONS LISTING---------------------------------------------
#-------------------------------------------------------------------------------------------------

:<<-'LIST_SECTIONS'
	Function that takes a path to a man page as an input and
	lists all the sections `.SH` tag and subsections `.SS` tag
	contained within it
	Usage: list_sections man_page
	LIST_SECTIONS
list_sections(){
	declare page
	declare list
	declare -I separator
	declare prompt="Please provide the path to a .gz file containing a manpage"
	declare command

	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
	if [ "$separator" = "" ] ; then separator="=" ; fi
	add_slash page "b"
	if [ "$(echo "$page" | awk -F'.' '{ print $NF }')" = "gz" ]
	then command="zcat" ; else command="cat" ; fi
	list="$(eval "$command" "$page" | grep -E '^\.S(s|S)|^\.S(h|H)' | tr '\n' "$separator")"
	ret_val="$list"
}

:<<-'PRINT_SECTION'
	Print a given man section in a user friendly format
	Usage: print_section section
	section should be a man page section formatted as a traditionnal man_page
	The variables section_number and subsection_number are to be defined in
	the calling function (or they will be declared as global anyways)
	PRINT_SECTION
print_section(){
	declare usage="Usage: print_section section"
	declare section

	section="$(echo "$1" | grep -E -o '[ ]+.*$' )"
	if [ "$section_number" = "" ] ; then declare -gi section_number=1 ; fi
	if [ "$subsection_number" = "" ] ; then declare -gi subsection_number=1 ; fi
	if [ "$1" = "" ] ; then echo "$usage" ; return 1 ; fi
	if [ "${1:0:3}" = ".SH" ] || [ "${1:0:3}" = ".Sh" ]
	then 
		printf "%-5b%-20b%b\n" "($((i+1)))" "Section $section_number " "-$section"
		(( ++section_number )) ; (( subsection_number=1 ))
	else
		printf "%-5b%-20b%b\n" "($((i+1)))" "    Subsection $subsection_number " "-$section"
		(( ++subsection_number ))
	fi
}

:<<-'PRINT_SECTIONS'
	Prints the list of the available man sections in a user friendly format
	Usage: print_sections man_page [separator]
	Where man_page is the full path to a man_page
	The separator is the separator to be used for the function list section
	PRINT_SECTIONS
print_sections(){
	declare -I separator
	declare -a sections
	declare page
	declare ret_val
	declare -i i=0
	declare -i section_number=1
	declare -i subsection_number=1
	declare prompt="Please provide the path to a .gz file containing a manpage"

	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
	if [ "$separator" = "" ] ; then separator="=" ; fi
	list_sections "$page" "$separator"
	IFS="$separator" read -ra sections <<<"$ret_val"
	while [ "$i" -lt "${#sections[@]}" ]
	do
		print_section "${sections[$i]}"
		(( ++i ))
	done
}


#-----------------------------------------------------------------------------------
#-------------------------------SECTION SELECTION-----------------------------------
#-----------------------------------------------------------------------------------

:<<-'PICK_SECTION'
	Function that picks the next section with the provided regexp
	Example with man page of `git-status` and section "SYNOPSIS"
	The following section or subsection is "DESCRIPTION"
	Thus the function returns description
	Usage: pick_section input regex
	Where input is the list returned by the function list sections
	and regex is the regex built with build_regex that represents
	the name of our section
	PICK_SECTION
pick_section(){
	declare input="$1"
	declare regex="$2"
	declare -I separator
	declare usage="Usage: pick_section input regex"
	declare tmp
	declare -i i

	if [ "$2" = "" ] ; then echo "$usage" ; return ; fi
	if [ "$separator" = "" ] ; then separator="=" ; fi
	IFS="$separator" read -ra sections<<<"$input"
	i=0
	ret_val="$"
	while [ "$i" -lt "${#sections[@]}" ]
	do
		tmp="$(echo "${sections[$i]}" | grep -E "$regex")"
		if [ "$tmp" != "" ]
		then
			if [ "$i" -eq "$((${#sections[@]} - 1))" ]
			then ret_val="$"
			else ret_val="${sections[$((i+1))]}"
			fi
			break
		fi
		((++i))
	done
	#ret_val=$(echo $input | sed -n "/$regex/,+1p")
}


#--------------------------------------------------------
#----------------------PAGE PRINTING---------------------
#--------------------------------------------------------

:<<-'CUT_MAN'
	Function that cuts a man page using the given sections
	In this function we have to use a named pipe to ensure
	the communication between our script and its children
	CUT_MAN
cut_man(){
	declare	commands
	declare command
	declare man_section
	declare tmp_file
	declare header_end
	declare page="$1"
	declare base="$2"
	declare stop="$3"
	declare usage="Usage: cut_man man_page base_section stop_section"

	if [ "$stop" == "" ] ; then echo -e "$usage" ; return ; fi
	if [ "$(echo "$page" | awk -F'.' '{ print $NF }')" = "gz" ]
	then command="zcat" ; else command="cat" ; fi
	add_slash page "b"
	header_end="/^\.S(h|H)/="
	header_end="$(eval "$command" "$page" | sed -n -E "$header_end" | head -n 1)"
	commands="1,$((header_end - 1))p;" 
	build_range "$base" "$stop"
	commands="${commands}$ret_val"
	man_section="$(eval "$command" "$page" | sed -n -E "$commands")"
	if [ "$(uname -s)" = "Darwin" ]
	then tmp_file="$(mktemp)" && echo "$man_section" > "$tmp_file" && man "$tmp_file" && rm "$tmp_file"
	else man <(echo "$man_section") ; fi
}
