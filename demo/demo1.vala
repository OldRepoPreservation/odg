// This file is part of Odg.

//     Odg is free software: you can redistribute it and/or modify
//     it under the terms of the GNU General Public License as published by
//     the Free Software Foundation, either version 3 of the License, or
//     (at your option) any later version.

//     Odg is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//     GNU General Public License for more details.

//     You should have received a copy of the GNU General Public License
//     along with Odg.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2013 Jukka-Pekka Partanen (jukpart@gmail.com)


using Gtk;

int main (string[] args) {

	Gtk.init (ref args);

	var wnd = new Window();
	wnd.set_size_request (200, 200);
	wnd.title = "Gauge test1";
	wnd.destroy.connect (Gtk.main_quit);
	
	Gtk.Grid grid = new Gtk.Grid();
	wnd.add (grid);

	var gif1 = GaugeFactory.get_instance().new_gauge("round_meter");
	var g1 = gif1 as RoundMeter;
	g1.range = 10;
	g1.sub_range = 9;
	g1.low_range_highlight = 20;
	g1.mid_range_highlight = 60;
	g1.high_range_highlight = 10;
	grid.attach(g1, 0, 0, 1, 1);
	var gif2 = GaugeFactory.get_instance().new_gauge("round_meter");
	var g2 = gif2 as RoundMeter;
	g2.range = 6;
	g2.sub_range = 5;
	g2.low_range_highlight = 2;
	g2.mid_range_highlight = 24;
	g2.high_range_highlight = 4;
	g2.label = "RPM";
	grid.attach(g2, 1, 0, 1, 1);
	
	wnd.show_all ();	
	wnd.resize(480, 240);

	gif1.current_value = 0.0;
	gif2.current_value = 0.0;
	Timeout.add(50, 
				() => { gif1.current_value += 0.5;
						if(g1.current_value >= g1.range*g1.sub_range) {
							return false;
						}
						
						return true;
				}
		);
	Timeout.add(50, 
				() => { gif2.current_value += 0.1;
						if(g2.current_value >= g2.range*g2.sub_range) {
							return false;
						}
						
						return true;
				}
		);
	Gtk.main ();

	return 0;
}
