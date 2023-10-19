#!/usr/bin/bash

script_url="https://raw.githubusercontent.com/nsainton/Scripts/main/"
script_utils_url="https://raw.githubusercontent.com/nsainton/Scripts/main/utils"
colorcodes="colorcodes.sh"

# shellcheck disable=SC2034 # Referenced variable used in function to store
# user input
:<<-'USER_INPUT'
	Allows to prompt something to the user and to read one line of input from
	the user 
	USER_INPUT
user_input(){
	if [ "$2" = "" ] ; then echo "Function usage: user_input prompt var" ; return 1 ; fi
	declare -n ref="$2"
	echo -e "$1"
	read -r ref
}


:<<-'ADD_SLASH'
	Takes a path and adds a slash at the beginning or the end if needed.
	ADD_SLASH
add_slash(){
	declare rev_path
	if [ "$1" = "" ] ; then echo "Please provide a path" ; return ; fi
	declare -n path="$1"
	if [ "$2" = "b" ]
	then
		if [ "${path:0:1}" != '/' ] ; then path="/$path" ; fi
		return
	fi
	rev_path="$(echo $path | rev)"
	if [ "${rev_path:0:1}" != '/' ] ; then path="${path}/" ; fi
}

:<<-'BUILD_REGEX'
	Builds a regex that matches the input string
	BUILD_REGEX
build_regex(){
	declare input
	declare prompt
	declare tmp
	declare -i i
	input="$1"
	prompt="please provide a string to match.\nExample: 'Short Format'"
	if [ "$input" = "" ] ; then user_input "$prompt" input ; fi
	ret_val=
	i=0
	while [ "$i" -lt "${#input}" ]
	do
		tmp="${input:$i:1}"
		case "$tmp" in ( [" ".] ) ret_val="$ret_val\\$tmp" ;;
						* ) ret_val="$ret_val$tmp" ;;
		esac
		((++i))
	done
	echo $ret_val
}

:<<-'SOURCE_FILE'
	Allows to source a given file and tries to get it from online sources if not found in
	directory
	SOURCE_FILE
source_file(){
	declare filename="$1"
	declare file
	declare script
	declare tmp
	declare -i i=1
	IFS=" " read -ra args <<<"$@"
	if [ "$filename" = "" ]
	then
		user_input "Please provide a file :\nExample: colorcodes.sh" filename
	fi
	file="$(find . -type f -path "**$filename" | head -n 1)"
	if [ "$file" != "" ] ; then . "$file" ; return ; fi
	if [ "$2" = "" ] ; then echo "no url provided" ; return ; fi
	while [ "$i" -lt "${#args[@]}" ]
	do
		file="${args[$i]}"
		echo $file : $i
		add_slash file
		file="${file}${filename}"
		echo "$file"
		script="$(curl -s $file)"
		if [ "$?" -gt "0" ] ; then script="404" ; fi
		tmp="$(echo ${script:0:3} | grep -E '40[[:digit:]]{1}')"
		if [ "$tmp" != "" ] ; then  ((++i))
		else break ; fi
	done
	if [ "$tmp" != "" ]
	then echo "Script not found at any of the provided locations" ; return ; fi
	echo "This is the file : $file"
	. <(echo "$script")
}

:<<-'FIND_PAGE_SECTION'
	Finds a man page in a given man section or picks the first man page available
	FIND_PAGE_SECTION
find_page_section(){
	prompt="please give a man page to find, you can give an optional section with a .\n
Example: wait.2"
	declare page="$1"
	if [ "$1" = "" ] ; then user_input "$prompt" page ; fi
	declare vars
	IFS='.' read -ra vars <<<"$page"
	declare section
	page=${vars[0]}
	if [ "${vars[1]}" != "" ] ; then section="${vars[1]}" ; fi
	ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]*man${section}[^ ]*\>" | tr '\n' ' ' | awk '{ print $1 }')
	if [ "$ret_val" = "" ] && [ "$section" != "" ]
	then 
		echo -e "${page} ${RED}not found ${CRESET}in section ${section}. Picking first match"
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
	declare prompt="Please provide the path to a .gz file containing a manpage"
	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
	add_slash page "b"
	list="$(zcat $page | grep -E '^\.SS|^\.SH')"
	ret_val="$list"
	echo $ret_val
}

:<<-'PICK_SECTION'
	Function that picks the right section with the provided regexp
	PICK_SECTION
pick_section(){
	declare input="$1"
	declare regex="$2"
	declare usage="Usage: pick_section input regex"
	if [ "$2" = "" ] ; then echo "$usage" ; return ; fi
	echo input is $input
	echo regex is $regex
	echo $input | sed -n "/$regex/,+1p" 
	ret_val=$(echo $input | sed -n "/$regex/,+1p")
	echo $ret_val
}

main(){
	local ret_val
	local section="${@:2}"
	source_file  "$colorcodes" "$script_utils_url"
	find_page_section $1
	list_sections $ret_val
	pick_section "$ret_val" "$(build_regex "$section")"
	echo $section
	build_regex "$section"
}

main $@
#build_regex "$*"
