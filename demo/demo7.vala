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
	g1.range = 100;
	g1.low_range_highlight = 20;
	g1.mid_range_highlight = 60;
	g1.high_range_highlight = 20;
	g1.label = "Throttle";
	g1.sub_label = "pos";
	grid.attach(g1, 0, 0, 1, 1);
		
	wnd.show_all ();
	wnd.resize(480, 120);

	gif1.current_value = 0.0;

	GaugeControl.use_thread = true;
	GaugeControl gctrl = GaugeControl.get_instance();
	MyMessageSourceFactory f = new MyMessageSourceFactory();
	
	Timeout.add(10,
				() => { gif1.current_value += 0.1;
						if(g1.current_value >= g1.range) {

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
