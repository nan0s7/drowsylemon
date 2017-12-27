# drowsylemon
A lazy/battery efficient Bash script for managing _lemonbar_.

What that means is that Drowsy lemonbar only updates when it needs to. It is also easy to seperate commands so that they update at different periods, delaying the battery hungry ones as long as possible.

I'm constantly working on ways to make this more efficient without needing to reduce the usability drastically.

The Bash and Python versions are not always equal in features and functionality. Usually the one with the most recent commit is the one most up-to-date but again that's not guaranteed. If you're unsure, check the output string to see if they're similar (my aim is to make them look the same when being used).

## Plugins
~I have seperated the get_tasks command/function so that it can be easily used in someone elses own LemonBar script or config. It will echo the structured string so if you want that to go into a variable, just call it by `$(./get_tasks.sh)`. Uses the two commands `wmctrl` and `pfw` (from wmutils).~
Under construction. Right now using `source <script>` then just use function from <script> inside `lb.sh`.

## Dependencies
**Bash version:**
- some packages (to be ammended at a later date)

uses the commands: wmctrl, ~xdotools~, ~xprop~, ~ps~, ~wc~, uname, acpi (T), date, pfw, ~wattr~, ~lsw~

the (T) means the command may be replaced on a later date

**Python version:**
- python3
- modules: subprocess, time
- everything the Bash version needs

## Display
So far the bar displays;
- current desktop number
- currently focused window
- date and time
- battery information
- open windows

This information is just what I've found somewhat useful so far, and can easily be modified.

## Usage
You may have to extend the clickable areas when you run lemonbar in the folliwing pipelines. I have mine currently set to 20 areas but your usage may vary.
Change `lemonbar` to `lemonbar -a 20` in the following examples. The default value is 10.


Simply execute the script and pipe it into _lemonbar_, making sure to use the `-p` option.

For example: `./lb.sh | lemonbar`
You will need to pipe that to another program for the task manager actions to work:
`./lb.sh | lemonbar | sh`


A similar method is used for the Python version: `python3 pydlb.py | lemonbar`

For the task-manager plugin to work you need to pipe the output into sh as follows:
`python3 pydlb.py | lemonbar | sh`

Please keep in mind that this is for my personal use at the moment, and I will change things and break things often as I see fit whilst I experiment. Additionally, in its unreleased state, things will be re-arranged and added/removed quite frequently.
