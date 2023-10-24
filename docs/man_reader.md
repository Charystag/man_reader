# Man Reader - A nice command-line viewer for man pages

## What does it do ?

This script allow you to navigate the man pages in a more friendly manner
To do so, it parses the man page to retrieve the sections and subsections
It then outputs a table of contents that looks like this one
(Example is from `man man.1` man page, which is like `man 1 man`)

![man 1 man table of contents](/assets/man1_toc.png "man 1 man")

After printing the table of contents, it prompts the user with an action
The following actions are available to the user :
- `#number` : A number between 1 and the number of sections (18 on our example) \
entering an invalid section number quits the man page rendering
- `n` : renders the next section of the man page. Pressing `n` at the first section \
will render the first section while pressing `n` at the end will exit the page rendering \
and prompt the user for another man page to read
- `p` : renders the previous section of the man page
- `k` : calls the utility `clear` to clear the terminal output
- `s` : prints the sections of the man page
- `q` : quits the man page rendering
