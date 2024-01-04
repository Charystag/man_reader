#!/usr/bin/env python3

import curses

# Init the curses screen and returns a window object 
# representing the entire screen
stdscr = curses.initscr()

# Allows the application to turn off automatic echoicng of keys to the screen
curses.noecho()

# Allows the input to be unbuffered
curses.cbreak()

# Allows curse to treat multibyte escape sequence keys internally
# with the special value curses.KEY_LEFT
stdscr.keypad(True)

# Closing the application
# Restoring default parameters
curses.nocbreak()
stdscr.keypad(False)
curses.echo()

# Restore the terminal to its original operating mode
curses.endwin()

def main(stdscr):
	stdscr.clear()

	for i in range(0, 11):
		v = i - 10
		stdscr.addstr(i, 0, '10 divided by {} is {}'.format(v, 10/v))
	stdscr.refresh()
	stdscr.getkey()

curses.wrapper(main)
