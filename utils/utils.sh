#!/usr/bin/bash
# shellcheck disable=SC1090 # sources for file scripts will never be constant

export UTILS=1

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


#---------------------------------------------------------------------
#--------------------------PATH BUILDING------------------------------
#---------------------------------------------------------------------

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

