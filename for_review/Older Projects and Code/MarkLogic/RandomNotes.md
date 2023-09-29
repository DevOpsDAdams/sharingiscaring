# Random Notes and Stuff For Fun

This is a collection of random tips, tricks, one-liners, and other assorted odds
and ends that I've picked up over the years.

## Cool Linux/MacOS Commandline Stuffs in No Order or Reason

This will commit a fixup to the active branch and push your code.
`git commit -a --fixup=HEAD; git push`
You can also `alias` this in a Linux or MacOS environment with something like:
`alias gfu="git commit -a --fixup=HEAD; git push"`


Here's a good way to add a user and keep track of who they are and what they do.
`useradd -u 42069 -g 42069 -b /home -m david -c "David Adams User Account"`
Obviously replace the parameters as required.

Some `rsync` magic! Or madness, depending on how you view `rsync`
`rsync -aHAxv --numeric-ids --delete --progress -e "ssh -T -c arcfour -o Compression=no -x" <<source/path>> <<destination_server>>:<<destination/path>>`

If you have a service account that keeps getting hit with an expiring password
try running something like this
`chage -I -1 -m 0 -M 99999 -E -1 <username>`

Ever want to find your external IP address from the CLI?
`curl ifconfig.me`
`curl -4 icanhazip.com`




## Random programming stuffs

Python Regular Expression Quick Guide

`^`        Matches the beginning of a line
`$`        Matches the end of the line
`.`        Matches any character
`\s`       Matches whitespace
`\S`       Matches any non-whitespace character
`*`        Repeats a character zero or more times
`*?`       Repeats a character zero or more times (non-greedy)
`+`        Repeats a character one or more times
`+? `      Repeats a character one or more times (non-greedy)
`[aeiou]`  Matches a single character in the listed set
`[^XYZ]`   Matches a single character not in the listed set
`[a-z0-9]` The set of characters can include a range
`(`        Indicates where string extraction is to start
`)`        Indicates where string extraction is to end
