#!/usr/bin/bash

export MAN_SPLITTING=1

:<<-'FIND_PAGE_SECTION'
	Finds a man page in a given man section or picks the first man page available
	FIND_PAGE_SECTION
find_page_section(){
	declare prompt
	declare page="$1"
	declare section
	declare -a vars

	prompt="please give a man page to find, you can give an optional section with a .\n
Example: wait.2"
	if [ "$1" = "" ] ; then user_input "$prompt" page ; fi
	IFS='.' read -ra vars <<<"$page"
	page=${vars[0]}
	if [ "${vars[1]}" != "" ] ; then section="${vars[1]}" ; fi
	ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]+man/man${section}[^ ]+\>" | tr '\n' ' ' | awk '{ print $1 }')
	if [ "$ret_val" = "" ] && [ "$section" != "" ]
	then 
		printf "%b\n" "${page} ${RED}not found ${CRESET}in section ${section}. Picking first match"
		ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]+man/man[^ ]+\>" | tr '\n' ' ' | awk '{ print $1 }')
		section="$(echo "$ret_val" | grep -E -o "[[:digit:]]+")"
		printf "%b\n" "${GRN}First match${CRESET} is : section ${GRN}$section${CRESET}"
	fi
	if [ "$ret_val" = "" ] ; then echo -e "${page} ${RED}not found ${CRESET}" ; fi
}

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

	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
	if [ "$separator" = "" ] ; then separator="=" ; fi
	add_slash page "b"
	list="$(zcat "$page" | grep -E '^\.SS|^\.SH' | tr '\n' "$separator")"
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
	if [ "${1:0:3}" = ".SH" ]
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

:<<-'CUT_MAN'
	Function that cuts a man page using the given sections
	In this function we have to use a named pipe to ensure
	the communication between our script and its children
	CUT_MAN
cut_man(){
	declare	commands
	declare man_section
	declare header_end
	declare page="$1"
	declare base="$2"
	declare stop="$3"
	declare usage="Usage: cut_man man_page base_section stop_section"

	if [ "$stop" == "" ] ; then echo -e "$usage" ; return ; fi
	add_slash page "b"
	header_end="/$(build_regex ".SH")/="
	header_end="$(zcat "$page" | sed -n -E "$header_end" | head -n 1)"
	commands="1,$((header_end - 1))p;" 
	build_range "$base" "$stop"
	commands="${commands}$ret_val"
	man_section="$(zcat "$page" | sed -n -E "$commands")"
	man <(echo "$man_section")
}
