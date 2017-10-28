# ndrowsylemon
A lazy/battery efficient Bash script for managing _lemonbar_.

What that means is that Drowsy lemonbar only updates once a second by default. It is also easy to seperate commands so that they update at different periods, delaying the battery hungry ones as long as possible.

I'm constantly working on ways to make this more efficient without needing to reduce the usability drastically.

## Usage
Simply execute the script and pipe it into _lemonbar_, making sure to use the `-p` option.

For example: `./lb.sh | lemonbar -p`

Please keep in mind that this is for my personal use at the moment, and I will change things and break things often as I see fit whilst I experiment.
