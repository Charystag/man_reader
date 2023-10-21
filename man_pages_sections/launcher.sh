#!/usr/bin/bash

trap "echo Exiting..." EXIT

main_menu(){
	local ret_val
	declare -a sections
	declare prompt
	declare continue_prompt
	declare -l continue_value
	declare page

	continue_prompt="Would you like to read another page?[y/n]"
	prompt="Please provide a man page to read:\n\
You can provide an section to look in with an optionnal .\n\
Example: man or man.7
"
	while true
	do
		echo -e "$prompt"
		read -r page
		read_page "$page"
		echo -e "$continue_prompt"
		read -r continue_value
		if [ "$continue_value" != 'y' ] then break ; fi
	done
	if [ "$continue_value" = "n" ]
	then echo "Thanks for using"
	else echo "Unrecognized option"
	fi
}
