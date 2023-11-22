# How it works ?

The goal of this document is to explain how the man\_reader script works so that you can take inspiration from it and maybe learn some useful shell commands.

# Table of Contents

# Page retrieval

## Getting all references to a given page

To find all the references to a given page in the manual. The script uses the command :
```bash
whereis <page>
```
where `<page>` references the required `page`.<br/>

> :bulb: The command `whereis` allows to locate the binary, sources and manual pages
> files for a command.

Without any option, the command whereis outputs all the information about the given command.
To keep the required `page` we have two options :

1.	Using the option `-m` of the whereis command to limit the search to manual pages and the option
`-M /usr/share/man$section` where $section resolves to a number between 1 and 8 representing the
man section we are searching in
2.	Using a RegEx to only keep the parts of the query that interest us and act upon them

> :bulb: Using the first option would be a cleaner solution but as it is a good occasion of learning how
> RegExes work, we will go for the second choice.
