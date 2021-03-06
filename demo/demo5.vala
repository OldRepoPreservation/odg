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
            Thread.usleep(50000);
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
	wnd.title = "Gauge test5";
	wnd.destroy.connect (Gtk.main_quit);
	
	var gif0 = GaugeFactory.get_instance().new_gauge("half_round_meter");
	var g0 = gif0 as HalfRoundMeter;
	
	g0.range = 5;
	g0.sub_range = 4;
	g0.low_range_highlight = 5;
	g0.mid_range_highlight = 13;
	g0.high_range_highlight = 2;
	g0.mark_labels = {"CT", "1/4", "1/2", "3/4", "WOT" };
	g0.label = "Throttle";
//	g0.position = PositionType.BOTTOM;
//	wnd.resize(240, 130);
//	g0.position = PositionType.TOP;
//  wnd.resize(240, 130);
	g0.position = PositionType.LEFT;
	wnd.resize(130, 240);
//	g0.position = PositionType.RIGHT;
//	wnd.resize(130, 240);


	wnd.add(g0);
	// show all widgets.
	// currently this needs to be after all the widgets have been
	// created because gauges will receive their size when shown ??
	wnd.show_all();

	// start thread for reading message queue in GaugeControl
//	GaugeControl.use_thread = false;
	GaugeControl.use_thread = true;
	// add source to GaugeControl
	GaugeControl gctrl = GaugeControl.get_instance();
	MyMessageSourceFactory f = new MyMessageSourceFactory();
	gctrl.add_source(f, "test_source");

	// add gauge to GaugeControl with and receive values named 'test'
	gctrl.listen_value(gif0, "test");
	
	// add idle event handler to main loop
	// checks GaugeControl message queues for new msgs if thread is not used
	// this uses polling to read GaugeControl message queue
    // Idle.add(gctrl.check_for_msg);

	Gtk.main();

	return 0;
}
