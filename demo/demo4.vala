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
	wnd.title = "Gauge test4";
	wnd.destroy.connect (Gtk.main_quit);
	
	Gtk.Grid grid = new Gtk.Grid();
	grid.set_column_homogeneous(false);
	grid.set_row_homogeneous(false);
	wnd.add (grid);
	
	var gif0 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g0 = gif0 as HalfRoundMeter;
	var gif1 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g1 = gif1 as HalfRoundMeter;
	var gif2 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g2 = gif2 as HalfRoundMeter;
	var gif3 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g3 = gif3 as HalfRoundMeter;
	
	g0.range = 5;
	g0.sub_range = 4;
	g0.low_range_highlight = 5;
	g0.mid_range_highlight = 13;
	g0.high_range_highlight = 2;
	g0.mark_labels = {"Empty", "1/4", "1/2", "3/4", "Full" };
	g0.label = "Tank 1";
	g0.position = PositionType.BOTTOM;
	grid.attach(g0, 1, 2, 1, 1);

	g1.range = 5;
	g1.sub_range = 4;
	g1.low_range_highlight = 5;
	g1.mid_range_highlight = 13;
	g1.high_range_highlight = 2;
	g1.mark_labels = {"Empty", "1/4", "1/2", "3/4", "Full" };
	g1.label = "Tank 2";
	g1.position = PositionType.LEFT;
	grid.attach(g1, 0, 1, 1, 1);

	g2.range = 5;
	g2.sub_range = 4;
	g2.low_range_highlight = 5;
	g2.mid_range_highlight = 13;
	g2.high_range_highlight = 2;
	g2.mark_labels = {"Empty", "1/4", "1/2", "3/4", "Full" };
	g2.label = "Tank 3";
	g2.position = PositionType.TOP;
	grid.attach(g2, 1, 0, 1, 1);

	g3.range = 5;
	g3.sub_range = 4;
	g3.low_range_highlight = 5;
	g3.mid_range_highlight = 13;
	g3.high_range_highlight = 2;
	g3.mark_labels = {"Empty", "1/4", "1/2", "3/4", "Full" };
	g3.label = "Tank 4";
	g3.position = PositionType.RIGHT;
	grid.attach(g3, 2, 1, 1, 1);

   
	wnd.resize(480, 480);
	wnd.override_background_color(StateFlags.NORMAL, {0,0,0,0});
	// show all widgets.
	// currently this needs to be after all the widgets have been
	// created because gauges will receive their size when shown
	wnd.show_all();

	g0.current_value = 6.4;
	g1.current_value = 3.2;
	g2.current_value = 5.1;
	g3.current_value = 1.5;
	
	// add idle event handler to main loop
	// checks GaugeControl message queues for new msgs if thread is not used
	// this uses polling to read GaugeControl message queue
    // Idle.add(gctrl.check_for_msg);

	Gtk.main();

	return 0;
}
