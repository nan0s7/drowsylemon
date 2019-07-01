# drowsylemon
**Note:** With my adventures with the `smldr` (small drowsylemon) variant, which only displays the current time and date, I haven't updated the main `drowsylemon` script in a while. `smldr` is a POSIX compliant script that shows the time accurate to about 5 seconds, while being super efficient. If a time display is all you need, then I would recommend using this.

A lazy/battery efficient Bash script for managing _lemonbar_.

What that means is that Drowsy-lemonbar only updates when it needs to. It is also easy to seperate commands so that they update at different periods, delaying the battery hungry ones as long as possible.

I'm constantly working on ways to make this more efficient without needing to reduce the usability drastically.

For example; my script only updates the time once per minute, and every few minutes it makes sure to sync when it checks for a new time with when the new minute starts. This ensures the time updates use as little power as possible while keeping the displayed time reliable and accurate to a few seconds.

## Plugins
Under construction. Right now you can add a plugin by using `source <script>` then just use the function from `<script>` inside `drowsylemon`. 

If it adds something to the bar to be displayed, add it to the _info_ array in the `init_vals` function and add the function using `try_update` in the main loop (or if you want it to update each second add it to the `run_sec_cmds` function).

**Currently reworking a lot of the plugins; so right now the time and battery percentage work as 
expected. I'm also working on the config file for this script to make things a little easier 
to edit, as well as hopefully making it clearer on how things work.**

## Dependencies
**Bash version:**
- coreutils
- wmutils
- wmctrl

Please note that the get_desktop and get_tasks plugins need the get_info plugin in order to work.

## Display
So far the bar displays;
- current desktop & whether a desktop has an active window in it
- currently focused window & other windows on the current desktop
- date and time
- battery information

This information is just what I've found somewhat useful so far, and can easily be modified.

## Usage
You may have to extend the clickable areas when you run lemonbar in the folliwing pipelines; the default is 10, so if you have more than 10 (or expect more than 10) just add in the extra parameter below. I have mine currently set to 20 areas but your usage may vary.
Change `lemonbar` to `lemonbar -a 20` in the following examples.


Simply execute the script and pipe it into _lemonbar_.

For example: 

`./drowsylemon | lemonbar`

You will need to pipe that to another program for the mouse-click actions to work:

`./drowsylemon | lemonbar | sh`


A similar method is used for the Python version:

`python3 pydlb.py | lemonbar`

For the task-manager plugin to work you need to pipe the output into sh as follows:

`python3 pydlb.py | lemonbar | sh`


Please keep in mind that this is for my personal use at the moment, and I will change things and break things often as I see fit whilst I experiment. Additionally, in its unreleased state, things will be re-arranged and added/removed quite frequently.


# TODO
- Add clickable areas by default
- Make customisation easier/simpler to do
- Remove `acpi` command
