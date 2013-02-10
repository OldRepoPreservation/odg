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

class SimulatorThread {
	
	const double amp = 45.0;
	const double A = 0.3;
	const double B = 0.2;
	const double C = 0.5;
	const double a = 2*Math.PI*0.002;
	const double b = 2*Math.PI*0.005;
	const double c = 2*Math.PI*0.003;
	const double offset = 45.0;
	uint32 x;
	GaugeControl ctrl;
	
	public SimulatorThread() {
		
		x = 0;
		ctrl = GaugeControl.get_instance();
	}
	
//	private double calc() {
//		
//		var result = (A*Math.sin(B*x+C)+D);
//		stdout.printf("%f\n", result);
//		return result;
//	}

	private double calc() {
		return (amp*(A*Math.sin(a*x) +
					 B*Math.sin(b*x) +
					 C*Math.sin(c*x)) + 
				offset);
	}

	private void send(double value) {

//		stdout.printf("%f\n", value);
		ctrl.json_msg(@"{\"type\":\"value\",\"data\":{\"name\":\"test\",\"value\":$value}}");
	}
	
    public void *run() {
		
		double value;
        while(true) {
			value = calc();
			x += 1;
			send(value);
            Thread.usleep(10000);
        }
		
		return null;
    }
}

public class Simulator: GLib.Object, MessageSourceIF {
	
	SimulatorThread st;
	Thread<void*> thread;
	
	public Simulator() {
		st = new SimulatorThread();
	}
	
	public void start() {
		thread = new Thread<void*> ("OdgSourceSimulator", st.run);
	}
	
	public void initialize() {}
	
	public void clear_alarm() {}
}

public class MyMessageSourceFactory: MessageSourceFactory {

	public override MessageSourceIF? create() {
		return new Simulator() as MessageSourceIF;
	}
}

int main (string[] args) {

	Gtk.init (ref args);

	var wnd = new Window();
	wnd.title = "Gauge test7";
	wnd.destroy.connect (Gtk.main_quit);
	
	Gtk.Grid grid = new Gtk.Grid();
	wnd.add (grid);

	var gif1 = GaugeFactory.get_instance().new_gauge("hbar_meter");
	var g1 = gif1 as HBarMeter;
	g1.range = 10;
	g1.sub_range = 10;
	g1.draw_range = true;
	g1.draw_sub_range = true;
	g1.low_range_highlight =10;
	g1.mid_range_highlight = 85;
	g1.high_range_highlight = 5;
	g1.label = "BFV";
	g1.sub_label = "pos";
	g1.mark_labels = {"CT", "", "", "", "", "1/2", "", "", "", "", "WOT"};
	grid.attach(g1, 0, 0, 1, 1);
	
	var gif2 = GaugeFactory.get_instance().new_gauge("hbar_meter");
	var g2 = gif2 as HBarMeter;
	g2.range = 10;
	g2.sub_range = 10;
	g2.draw_range = true;
	g2.draw_sub_range = true;
	g2.low_range_highlight = 30;
	g2.mid_range_highlight = 70;
	g2.high_range_highlight = 0;
	g2.label = "MAP";
	g2.sub_label = "bar";
	g2.mark_labels = {"0", "", "", "", "idle", ".5", ".6", ".7", ".8", ".9", "WOT"};
	grid.attach(g2, 0, 1, 1, 1);

	var gif3 = GaugeFactory.get_instance().new_gauge("hbar_meter");
	var g3 = gif3 as HBarMeter;
	g3.range = 5;
	g3.sub_range = 10;
	g3.draw_range = true;
	g3.draw_sub_range = false;
	g3.low_range_highlight = 3;
	g3.mid_range_highlight = 17;
	g3.high_range_highlight = 30;
	g3.label = "EGO";
	g3.sub_label = "%";
	g3.mark_labels = {"0", "", "", "", "", "100"};
	grid.attach(g3, 0, 2, 1, 1);

	var gif4 = GaugeFactory.get_instance().new_gauge("hbar_meter");
	var g4 = gif4 as HBarMeter;
	g4.range = 5;
	g4.sub_range = 10;
	g4.draw_range = true;
	g4.draw_sub_range = false;
	g4.low_range_highlight = 15;
	g4.mid_range_highlight = 25;
	g4.high_range_highlight = 10;
	g4.label = "IAT";
	g4.sub_label = "C°";
	g4.mark_labels = {"MIN", "", "", "21", "", "MAX"};
	grid.attach(g4, 0, 3, 1, 1);

	wnd.show_all ();
	wnd.resize(480, 480);

	gif1.current_value = 0.0;
	gif2.current_value = 41.4;
	gif3.current_value = 12.3;
	gif4.current_value = 35.1;

	GaugeControl.use_thread = true;
	GaugeControl gctrl = GaugeControl.get_instance();
	MyMessageSourceFactory f = new MyMessageSourceFactory();
	
	Timeout.add(10,
				() => { gif1.current_value += 0.1;
						if(g1.current_value >= g1.range*g1.sub_range) {

							gctrl.add_source(f, "test_source");
							gctrl.listen_value(gif1, "test");
							return false;
						}
						
						return true;
				}
		);
	
	Gtk.main ();

	return 0;
}
