# odg
from [Google Code:](https://code.google.com/p/odg)

An attempt to create a collection of display gauges for my needs with Vala/GTK+ since I found none suitable when searching the web.

## Features
- Round meter (like speedometer)
- half round meter (like fuel level meter)
- numeric meter (shown numeric values)
- values shown in meters are routed to all registered gauges in gauge control
- different kind of sources for values shown in meters are possible through gauge control (Json message interface)

## Future plans
- create more gauges (bar, half-round, numeric, more?)
- show labels in left,top,right oriented half round meter correctly
- add possibility to register a filter for values shown by meters.
- add support for different kind of sources for data displayed in gauges. First one is a simple data generator for testing, another one would be ODB II interface.
- fix the bugs

## Instructions

Checkout the code and run

    cmake .

in base directory.
Then run

    make

This will build the odg library and demo(s) in demo directory.
cd to demo and run demo(s).

## Requirements

- Vala
- Gtk+3.0 & GObject framework
- (CMake)
