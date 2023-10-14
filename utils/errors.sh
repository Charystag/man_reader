#!/usr/bin/bash

:<<-'COMMENT'
	The function error exit takes a list of params terminated by an exit code
	it prints all the parameters and then exits with the given exit code
	If the last argument is not a number, the function will exit 0
COMMENT
error_exit (){
	if [ $# -eq 0 ] ; then exit 1 ; fi
	params=("$@")
	declare -i i=0
	while [ $i -lt $(($# - 1)) ] ; do printf "%b" "${params[$i]}" ; ((++i)) ; if [ "$i" -lt $(($# - 1)) ] ; then echo -n " " ; fi; done
	if [ $# -gt 1 ] ; then echo ; fi
	exit $((${params[$(($#-1))]}))
}
