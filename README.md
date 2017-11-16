# ndrowsylemon
A lazy/battery efficient Bash script for managing _lemonbar_.

What that means is that Drowsy lemonbar only updates when it needs to. It is also easy to seperate commands so that they update at different periods, delaying the battery hungry ones as long as possible.

I'm constantly working on ways to make this more efficient without needing to reduce the usability drastically.

## Dependencies
**Bash version:**
- some packages (to be ammended at a later date)

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

This information is just what I've found somewhat useful so far, and can easily be modified.

## Usage
Simply execute the script and pipe it into _lemonbar_, making sure to use the `-p` option.

For example: `./lb.sh | lemonbar -p`

A similar method is used for the Python version: `python3 pydlb.py | lemonbar -p`

Please keep in mind that this is for my personal use at the moment, and I will change things and break things often as I see fit whilst I experiment. Additionally, in its unreleased state, things will be re-arranged and added/removed often.
