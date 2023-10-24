# Man Reader - A nice command-line viewer for man pages

## What does it do ?

### Short intro

This script allow you to navigate the man pages in a more friendly manner
To do so, it parses the man page to retrieve the sections and subsections
It then outputs a table of contents that looks like this one
(Example is from `man man.1` man page, which is like `man 1 man`)

![man 1 man table of contents](/assets/man1_toc.png "man 1 man")

### Basic actions

After printing the table of contents, it prompts the user with an action
The following actions are available to the user :
- `number` : A number between 1 and the number of sections (18 on our example) \
entering an invalid section number quits the man page rendering
- `n` : renders the next section of the man page. Pressing `n` at the first section \
will render the first section while pressing `n` at the end will exit the page rendering \
and prompt the user for another man page to read
- `p` : renders the previous section of the man page
- `k` : calls the utility `clear` to clear the terminal output
- `s` : prints the sections of the man page
- `q` : quits the man page rendering


### Section rendering

Let's try, for example, to print the number `8`. We get this output in the terminal :

![man.1 section 7.1](/assets/man1-8.png "section 7.1 of man in section 1")

> :warning: Beware that at the present time, this script doesn't distinguish between rendering
> sections and subsections. This means that, if we decide to render the section 7 (number 7 on our example)
> the script will render from number 7 to number 8, which is the part of section 7 that is before the first
> subsection

That is, if we try for example to print the number `7` instead of number `8`. We get the following output :

![man.1 section 7](/assets/man1-7.png "section 7 of man in section 1")

## How to use this script ?

### Run from online source

To run the script, you can run the following command in your terminal

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nsainton/Scripts/main/man_reader.sh)
```
