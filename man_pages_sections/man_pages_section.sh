#!/usr/bin/bash
# shellcheck disable=SC1090 # sources for file scripts will never be constant
# shellcheck disable=SC1091 # Don't need to follow sources

colorcodes="colorcodes.sh"
utils="utils/utils.sh"
remote_utils="https://raw.githubusercontent.com/nsainton/Scripts/file_splitting/""$utils"
echo "$remote_utils"
. "../utils/utils.sh"
. "man_splitting.sh"
#curl -s "$remote_utils"
#if [ ! -f "$utils" ] ; then . <(curl -s "$remote_utils") ; fi

man_section(){
	declare	page
	declare	section="${*:2}"
	declare usage="Usage: man_section page section"

	source_file  "$colorcodes"
	find_page_section "$1"
	if [ "$section" = "" ] ; then echo -e "$usage" ; return ; fi
	page="$ret_val"
	add_slash page "b"
	list_sections "$page"
	pick_section "$ret_val" "$(build_regex "$section")"
	cut_man "$page" "$section" "$ret_val"
}

main(){
	local ret_val
	man_section "$@"
}

main "$@"
#find_page_section "$1"
#build_regex "$*"
