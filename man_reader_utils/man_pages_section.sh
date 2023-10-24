#!/usr/bin/bash
# shellcheck disable=SC1090 # sources for file scripts will never be constant
# shellcheck disable=SC1091 # Don't need to follow sources

export MAN_PAGES_SECTION=1

:<<-'MAN_SECTION'
	Opens a man page in an optionnal man section to a given section
	Example: man_section man.7 Fonts
	MAN_SECTION
man_section(){
	declare	page
	declare	section="${*:2}"
	declare usage="Usage: man_section page section"

	find_page_section "$1"
	if [ "$section" = "" ] ; then echo -e "$usage" ; return ; fi

# shellcheck disable=SC2154 #ret_val will be declared in calling function
	page="$ret_val"
	add_slash page "b"
	list_sections "$page"
	pick_section "$ret_val" "$(build_regex "$section")"
	cut_man "$page" "$section" "$ret_val"
}
