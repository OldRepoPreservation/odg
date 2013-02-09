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
	wnd.title = "Gauge test6";
	wnd.destroy.connect (Gtk.main_quit);
	
	Gtk.Grid grid = new Gtk.Grid();
	wnd.add (grid);

	var gif1 = GaugeFactory.get_instance().new_gauge("numeric_meter");
	var g1 = gif1 as NumericMeter;
	g1.range = 100;
	g1.low_range_highlight = 20;
	g1.mid_range_highlight = 60;
	g1.high_range_highlight = 20;
	g1.label = "Speed";
	g1.sub_label = "km/h";
	grid.attach(g1, 0, 0, 1, 1);
	var gif2 = GaugeFactory.get_instance().new_gauge("numeric_meter");
	var g2 = gif2 as NumericMeter;
	g2.range = 100;
	g2.low_range_highlight = 20;
	g2.mid_range_highlight = 60;
	g2.high_range_highlight = 20;
	g2.label = "Distance";
	g2.sub_label = "km";
	grid.attach(g2, 1, 0, 1, 1);
	var gif3 = GaugeFactory.get_instance().new_gauge("numeric_meter");
	var g3 = gif3 as NumericMeter;
	g3.range = 100;
	g3.low_range_highlight = 20;
	g3.mid_range_highlight = 60;
	g3.high_range_highlight = 20;
	g3.label = "Speed";
	g3.sub_label = "km/h";
	grid.attach(g3, 0, 1, 1, 1);
	var gif4 = GaugeFactory.get_instance().new_gauge("numeric_meter");
	var g4 = gif4 as NumericMeter;
	g4.range = 100;
	g4.low_range_highlight = 20;
	g4.mid_range_highlight = 60;
	g4.high_range_highlight = 20;
	g4.label = "Distance";
	g4.sub_label = "km";
	grid.attach(g4, 1, 1, 1, 1);
	
	wnd.show_all ();
	wnd.resize(960, 480);

	gif1.current_value = 0.0;
	gif2.current_value = 0.0;
	gif3.current_value = 43.4;
	gif4.current_value = 68.3;

	Timeout.add(50, 
				() => { gif1.current_value += 0.1;
						if(g1.current_value >= g1.range) {
							return false;
						}
						
						return true;
				}
		);
	Timeout.add(200,
				() => { gif2.current_value += 0.1;
						if(g2.current_value >= g2.range) {
							return false;
						}
						
						return true;
				}
		);
	
	Gtk.main ();

	return 0;
}
