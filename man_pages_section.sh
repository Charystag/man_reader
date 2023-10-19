#!/usr/bin/bash

curl_url="https://raw.githubusercontent.com/nsainton/Scripts/main/"

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


:<<-'SOURCE_FILE'
	Allows to source a given file and tries to get it from online sources if not found in
	directory
	SOURCE_FILE
source_file(){
	declare filename="$1"
	declare file
	if [ "$filename" = "" ]
	then
		user_input "Please provide a file :\nExample: colorcodes.sh" filename
	fi
	file="$(find . -type f -path "**$filename" | head -n 1)"
	if [ "$file" != "" ] ; then . "$file" ; echo $file; return ; fi
	if [ "$2" = "" ] ; then echo "no url provided" ; return ; fi
	file="$2"
	declare rev_name="$(echo $file | rev)"
	echo $rev_name
	if [ "${rev_name:0:1}" != '/' ] ; then file="${file}/" ; fi
	file="${file}${filename}"
	echo "This is the file : $file"
	. <(curl -s $file)
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
	echo $page
	if [ "${vars[1]}" != "" ] ; then section="${vars[1]}" ; fi
	echo section is : $section
	ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]*man${section}[^ ]*\>" | tr '\n' ' ' | awk '{ print $1 }')
	if [ "$ret_val" = "" ] && [ "$section" != "" ]
	then 
		echo "${page} not found in section ${section}. Picking first match"
		ret_val=$(whereis "$page"  | grep -E -o "\<[^ ]*man[^ ]*\>" | tr '\n' ' ' | awk '{ print $1 }')
	fi
	echo $ret_val
}

main(){
	local ret_val
	find_page_section $@
}

#main $@
source_file $@ $curl_url
