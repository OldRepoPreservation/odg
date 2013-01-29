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
	
	const double amp = 35.0;
	const double A = 0.3;
	const double B = 0.2;
	const double C = 0.5;
	const double a = 2*Math.PI*0.002;
	const double b = 2*Math.PI*0.005;
	const double c = 2*Math.PI*0.003;
	const double offset = 35.0;
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
		thread = new Thread<void*> ("OdgSourceSimulator2", st.run);
	}
	
	public void initialize() {}
	
	public void clear_alarm() {}
}

public class MyMessageSourceFactory: MessageSourceFactory {

	public override MessageSourceIF? create() {
		return new Simulator() as MessageSourceIF;
	}
}

class SimulatorThread2 {
	
	const double amp = 10.0;
	const double A = 0.3;
	const double B = 0.2;
	const double C = 0.5;
	const double a = 2*Math.PI*0.002;
	const double b = 2*Math.PI*0.005;
	const double c = 2*Math.PI*0.003;
	const double offset = 10.0;
	uint32 x;
	GaugeControl ctrl;
	
	public SimulatorThread2() {
		
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
		ctrl.json_msg(@"{\"type\":\"value\",\"data\":{\"name\":\"test2\",\"value\":$value}}");
	}
	private void send2(double value) {
		ctrl.json_msg(@"{\"type\":\"value\",\"data\":{\"name\":\"test3\",\"value\":$value}}");
	}
	
    public void *run() {
		
		double value;
        while(true) {
			value = calc();
			x += 1;
			send(value);
			Thread.usleep(50000);
			send2(value*0.5);
            Thread.usleep(10*10000);
        }
		
		return null;
    }
}

public class Simulator2: GLib.Object, MessageSourceIF {
	
	SimulatorThread2 st;
	Thread<void*> thread;
	
	public Simulator2() {
		st = new SimulatorThread2();
	}
	
	public void start() {
		thread = new Thread<void*> ("OdgSourceSimulator", st.run);
	}
	
	public void initialize() {}
	
	public void clear_alarm() {}
}

public class MyMessageSourceFactory2: MessageSourceFactory {

	public override MessageSourceIF? create() {
		return new Simulator2() as MessageSourceIF;
	}
}

int main (string[] args) {

	Gtk.init (ref args);

	var wnd = new Window();
	wnd.title = "Gauge test3";
	wnd.destroy.connect (Gtk.main_quit);
	
	Gtk.Grid grid = new Gtk.Grid();
	wnd.add (grid);
	
	var gif0 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g0 = gif0 as HalfRoundMeter;
	var gif1 = GaugeFactory.get_instance().new_gauge("round_meter");
	var g1 = gif1 as RoundMeter;
	var gif2 = GaugeFactory.get_instance().new_gauge("round_meter");
	var g2 = gif2 as RoundMeter;
	var gif3 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g3 = gif3 as HalfRoundMeter;
	
	g0.range = 5;
	g0.sub_range = 4;
	g0.low_range_highlight = 5;
	g0.mid_range_highlight = 13;
	g0.high_range_highlight = 2;
	g0.mark_labels = {"Empty", "1/4", "1/2", "3/4", "Full" };
	g0.label = "Fuel";
	g0.bottom_align = true;
	grid.attach(g0, 0, 0, 1, 1);

	g1.range = 8;
	g1.sub_range = 9;
	g1.low_range_highlight = 10;
	g1.mid_range_highlight = 47;
	g1.high_range_highlight = 15;
	g1.label = "RPM";
	g1.mark_labels = {"0", "1000", "2000", "3000",
					  "4000", "5000", "6000", "7000" };
	grid.attach(g1, 1, 0, 1, 1);
	
	g2.range = 10;
	g2.sub_range = 9;
	g2.low_range_highlight = 0;
	g2.mid_range_highlight = 0;
	g2.high_range_highlight = 0;
	g2.label = "Km/h";
	g2.mark_labels = {"", "20", "40", "60", "80", "100",
					  "120", "140", "160", "180" };
	grid.attach(g2, 2, 0, 1, 1);

	g3.range = 5;
	g3.sub_range = 4;
	g3.low_range_highlight = 10;
	g3.mid_range_highlight = 5;
	g3.high_range_highlight = 5;
	g3.mark_labels = {"0", "30", "60", "90", "120" };
	g3.label = "Temp";
	g3.bottom_align = true;
	grid.attach(g3, 3, 0, 1, 1);

	wnd.resize(940, 250);
	// show all widgets.
	// currently this needs to be after all the widgets have been
	// created because gauges will receive their size when shown
	wnd.show_all();

	g0.current_value = 6.4;
	g2.current_value = 33.0;
	g3.current_value = 14.0;

	// start thread for reading message queue in GaugeControl
//	GaugeControl.use_thread = false;
	GaugeControl.use_thread = true;
	// add source to GaugeControl
	GaugeControl gctrl = GaugeControl.get_instance();
	MyMessageSourceFactory f = new MyMessageSourceFactory();
	gctrl.add_source(f, "test_source");
	MyMessageSourceFactory2 f2 = new MyMessageSourceFactory2();
	gctrl.add_source(f2, "test_source2");

	// add gauge to GaugeControl with and receive values named 'test'
	gctrl.listen_value(gif0, "test2");
	gctrl.listen_value(gif1, "test");
	gctrl.listen_value(gif2, "test");
	gctrl.listen_value(gif3, "test3");
	
	// add idle event handler to main loop
	// checks GaugeControl message queues for new msgs if thread is not used
	// this uses polling to read GaugeControl message queue
    // Idle.add(gctrl.check_for_msg);

	Gtk.main();

	return 0;
}
