#!/usr/bin/bash

:<<-'FIND_PAGE_SECTION'
	Finds a man page in a given man section or picks the first man page available
	FIND_PAGE_SECTION
find_page_section(){
	prompt="please give a man page to find, you can give an optional section with a .\n
Example: wait.2"
	declare page="$1"
	declare section
	declare vars

	if [ "$1" = "" ] ; then user_input "$prompt" page ; fi
	IFS='.' read -ra vars <<<"$page"
	page=${vars[0]}
	if [ "${vars[1]}" != "" ] ; then section="${vars[1]}" ; fi
	ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]+share/man${section}[^ ]+\>" | tr '\n' ' ' | awk '{ print $1 }')
	if [ "$ret_val" = "" ] && [ "$section" != "" ]
	then 
		printf "%b\n" "${page} ${RED}not found ${CRESET}in section ${section}. Picking first match"
		ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]*man[^ ]*\>" | tr '\n' ' ' | awk '{ print $1 }')
	fi
	if [ "$ret_val" = "" ] ; then echo -e "${page} ${RED}not found ${CRESET}" ; fi
}

:<<-'LIST_SECTIONS'
	Function that takes a path to a man page as an input and
	lists all the sections `.SH` tag and subsections `.SS` tag
	contained within it
	LIST_SECTIONS
list_sections(){
	declare page
	declare list
	declare separator
	declare prompt="Please provide the path to a .gz file containing a manpage"

	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
	if [ "$2" != "" ] ; then separator="$2" ; else separator="=" ; fi
	add_slash page "b"
	list="$(zcat "$page" | grep -E '^\.SS|^\.SH' | tr '\n' "$separator")"
	ret_val="$list"
}

:<<-'PICK_SECTION'
	Function that picks the next section with the provided regexp
	Example with man page of `git-status` and section "SYNOPSIS"
	The following section or subsection is "DESCRIPTION"
	Thus the function returns description
	PICK_SECTION
pick_section(){
	declare input="$1"
	declare regex="$2"
	declare separator
	declare usage="Usage: pick_section input regex"
	declare tmp
	declare -i i

	if [ "$2" = "" ] ; then echo "$usage" ; return ; fi
	if [ "$3" != "" ] ; then separator="$2" ; else separator="=" ; fi
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
	header_end="/$(build_regex ".SH")/="
	header_end="$(zcat "$page" | sed -n -E "$header_end" | head -n 1)"
	commands="1,$((header_end - 1))p;" 
	build_range "$base" "$stop"
	commands="${commands}$ret_val"
	man_section="$(zcat "$page" | sed -n -E "$commands")"
	man <(echo "$man_section")
}
