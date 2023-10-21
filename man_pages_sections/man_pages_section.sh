#!/usr/bin/bash
# shellcheck disable=SC1090 # sources for file scripts will never be constant

colorcodes="colorcodes.sh"

:<<-'USER_INPUT'
	Allows to prompt something to the user and to read one line of input from
	the user 
	USER_INPUT
user_input(){
	if [ "$2" = "" ] ; then echo "Function usage: user_input prompt var" ; return 1 ; fi
	declare -n ref="$2"
	echo -e "$1"

# shellcheck disable=SC2034 # Referenced variable used in function to store
# user input
	read -r ref
}


:<<-'COLORED_MAN'
	Forces `less` to use colors to display man pages
	COLORED_MAN
man() {
LESS_TERMCAP_md=$'\e[01;31m' \
LESS_TERMCAP_me=$'\e[0m' \
LESS_TERMCAP_us=$'\e[01;32m' \
LESS_TERMCAP_ue=$'\e[0m' \
LESS_TERMCAP_so=$'\e[45;93m' \
LESS_TERMCAP_se=$'\e[0m' \
command man "$@"
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
	rev_path="$(echo "$path" | rev)"
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
	ret_val="[[:space:]]*"
	i=0
	while [ "$i" -lt "${#input}" ]
	do
		tmp="${input:$i:1}"
		case "$tmp" in ( [" ".'"'] ) ret_val="$ret_val\\$tmp" ;;
						* ) ret_val="$ret_val$tmp" ;;
		esac
		((++i))
	done
	ret_val="${ret_val}""[[:space:]]*"
	echo "$ret_val"
}

:<<-'BUILD_RANGE'
	Builds a range of addresses for sed
	Input: two man sections or $ for the second section if last
	BUILD_RANGE
build_range(){
	declare first="$1"
	declare second="$2"
	declare usage="Usage: build_range section1 section2"
	declare range

	if [ "$second" = "" ] ; then echo -e "$usage" ; return ; fi
	range="/"
	range="${range}$(build_regex "$first")/,"
	if [ "$second" = "$" ]
	then range="${range}$" ; else range="${range}/$(build_regex "$second")/"
	fi
	range="${range}p"
	ret_val="$range"
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
	declare script_utils_url="https://raw.githubusercontent.com/nsainton/Scripts/main/utils"

	IFS=" " read -ra args <<<"$@"
	if [ "$filename" = "" ]
	then
		user_input "Please provide a file :\nExample: colorcodes.sh" filename
	fi
	file="$(find . -type f -path "**$filename" | head -n 1)"
	if [ "$file" != "" ] ; then . "$file" ; return ; fi
	if [ "$2" = "" ] ; then echo "no url provided" ; return ; fi
	args+=( "$script_utils_url" )
	while [ "$i" -lt "${#args[@]}" ]
	do
		file="${args[$i]}"
		add_slash file
		file="${file}${filename}"
		script="$(curl -s "$file")"

# shellcheck disable=SC2181 #Can't check return code within if condition
		if [ "$?" -gt "0" ] ; then script="404" ; fi
		tmp="$(echo ${script:0:3} | grep -E '[[:digit:]]{3}')"
		if [ "$tmp" != "" ] ; then  ((++i))
		else break ; fi
	done
	if [ "$tmp" != "" ]
	then echo "Script not found at any of the provided locations" ; return ; fi
	. <(echo "$script")
}

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
	declare prompt="Please provide the path to a .gz file containing a manpage"

	page="$1"
	if [ "$page" = "" ] ; then user_input "$prompt" page ; fi
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
	declare usage="Usage: pick_section input regex"
	declare tmp
	declare -i i

	if [ "$2" = "" ] ; then echo "$usage" ; return ; fi
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

main(){
	local	ret_val
	declare	page
	declare	section="${*:2}"
	declare	separator="="
	declare usage="Usage: man_section page section"

	source_file  "$colorcodes" "$script_utils_url"
	find_page_section "$1"
	if [ "$section" = "" ] ; then echo -e "$usage" ; return ; fi
	page="$ret_val"
	add_slash page "b"
	list_sections "$page"
	pick_section "$ret_val" "$(build_regex "$section")"
	cut_man "$page" "$section" "$ret_val"
}

main "$@"
#find_page_section "$1"
#build_regex "$*"
