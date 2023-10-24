#!/usr/bin/bash
# shellcheck disable=SC1090 # sources for file scripts will never be constant
# shellcheck disable=SC1091 # Don't need to follow sources

export MAN_PAGES_SECTION=1

:<<-'PICK_SECTION_NUMBER'
	Picks the right section according to a section number
	Usage: pick_section_number sections_list number
	PICK_SECTION_NUMBER
pick_section_number(){
	declare -a sections
	declare -i number
	declare -i i=0
	declare -iI sections_number
	declare -I separator
	declare usage

	usage="Usage: pick_section_number sections_list number"
	if [ "$separator" = "" ] ; then separator="=" ; fi
	if [ "$2" = "" ] ; then echo -e "$usage" ; return 1 ; fi
	number="$2"
	IFS="$separator" read -ra sections <<<"$1"
	while [ "$i" -lt "$sections_number" ]
	do
		(( ++i ))
		if [ "$i" -eq "$number" ] ; then section="${sections[$((i-1))]}" ; break ; fi
	done
}

:<<-'MAN_SECTION'
	Opens a man page in an optionnal man section to a given section
	Example: man_section man.7 Fonts
	MAN_SECTION
man_section(){
	declare	page
	declare	section="${*:2}"
	declare -I separator
	declare -i sections_number
	declare usage="Usage: man_section page section"

	find_page_section "$1"
	if [ "$section" = "" ] ; then echo -e "$usage" ; return ; fi
	if [ "$separator" = "" ] ; then separator="=" ; fi

# shellcheck disable=SC2154 #ret_val will be declared in calling function
	page="$ret_val"
	add_slash page "b"
	list_sections "$page"
	sections_number="$(echo "$ret_val" | tr "$separator" '\n' | wc -l)"
	if is_int "$section"  && [ "$section" -gt "0" ] && [ "$section" -le "$sections_number" ]
	then pick_section_number "$ret_val" "$section" ; fi
	pick_section "$ret_val" "$(build_regex "$section")"
	cut_man "$page" "$section" "$ret_val"
}
