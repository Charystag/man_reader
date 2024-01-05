#!/usr/bin/env python3

import curses
import time

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

try:
	curses.wrapper(main)
except ZeroDivisionError:
	print("You can't divide by zero my G")

begin_x = 20; begin_y = 7
height = 5; width = 40
win = curses.newwin(height, width, begin_y, begin_x)
win.noutrefresh()
curses.doupdate()
time.sleep(1)
win.clear()
curses.endwin()

pad = curses.newpad(100, 100)

for y in range(0, 99):
	for x in range(0, 99):
		pad.addch(y, x, ord('a') + (x * x + y * y) % 26)

# Displays a section of the pad in the middle of the screen
# (0,0) : coordinate of upper-left corner of pad area to display
# (5,5) : coordinate of upper-left corner of window area to be filled
#			with pad content.
# (20, 75) : coordinate of lower-right corner of window area to be
#			filled with pad content.
pad.refresh(0, 0, 5, 5, 20, 75)
time.sleep(1)
curses.endwin()
