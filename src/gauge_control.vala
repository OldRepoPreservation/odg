using Json;

class Msg {
	public string name;
}

class ValueMsg: Msg {
	public double value;
}

class AlarmMsg: Msg {
	public bool valid;
}

public class GaugeControl: GLib.Object {
	
	construct {

		gauge_msgs = new HashTable<string,List<ControlIF>>(str_hash, str_equal);
		gauge_alarms = new HashTable<string,List<ControlIF>>(str_hash, str_equal);
		value_queue = new AsyncQueue<Msg>();
		alarm_queue = new AsyncQueue<Msg>();
	}
	
    private AsyncQueue<Msg> value_queue;
	private AsyncQueue<Msg> alarm_queue;

	private static GaugeControl instance;
	private GaugeControl() {}
	
	private static HashTable<string,List<ControlIF>> gauge_msgs;
	private static HashTable<string,List<ControlIF>> gauge_alarms;

	public static GaugeControl get_instance() {

		if(instance == null) {
			instance = new GaugeControl();
		}
		return instance;
	}
	
	// Gauge related methods begin

	public void send_value(string name, double value) {
		stdout.printf("GaugeControl.send: name=%s ; value=%f\n", name, value);
	}
	
	public void listen_value(Gauge g, string value_name) {
		
		unowned List<ControlIF> l = gauge_msgs.get(value_name);
		if(l == null) {
			gauge_msgs.insert(value_name, new List<ControlIF>());
		}
		l = gauge_msgs.get(value_name);
		l.append(g);
	}
	
	public void forget_value(Gauge g, string value_name) {
		
		unowned List<ControlIF> l = gauge_msgs.get(value_name);
		if(l == null) {
			return;
		}
		l.remove(g);
	}

	private void listen_alarm(Gauge g, string alarm_name) {
		
		unowned List<ControlIF> l = gauge_alarms.get(alarm_name);
		if(l == null) {
			gauge_alarms.insert(alarm_name, new List<ControlIF>());
		}
		l = gauge_alarms.get(alarm_name);
		l.append(g);
	}
	
	private void forget_alarm(Gauge g, string alarm_name) {
		
		unowned List<ControlIF> l = gauge_alarms.get(alarm_name);
		if(l == null) {
			return;
		}
		l.remove(g);
	}

	// method to check message queues
    // should be called for example from main loop (idle.add)
	// or from a thread
	public void check_for_msg() {
		
	}

	// gauge value source and alarm source related methods begin.
	// executed in Source thread context

	private void raise_alarm(string name) {
		
		stdout.printf("GaugeControl.raise_alarm: name=%s\n", name);
		AlarmMsg msg = new AlarmMsg();
		msg.name = name;
		msg.valid = true;
		alarm_queue.@lock();
		alarm_queue.push(msg);
		alarm_queue.unlock();
	}
	
	private void clear_alarm(string name) {

		stdout.printf("GaugeControl.clear_alarm: name=%s\n", name);
		AlarmMsg msg = new AlarmMsg();
		msg.name = name;
		msg.valid = false;
		alarm_queue.@lock();
		alarm_queue.push(msg);
		alarm_queue.unlock();
	}

	private void set_value(string name, double value) {
		
		stdout.printf("GaugeControl.set_value: name=%s, value=%f\n",
					  name, value);
		ValueMsg msg = new ValueMsg();
		msg.name = name;
		msg.value = value;
		value_queue.@lock();
		value_queue.push(msg);
		value_queue.unlock();
	}
	
	public void json_msg(string data) {

		stdout.printf("GaugeControl.json_msg\n");
		
		try {
			var parser = new Parser();
			parser.load_from_data(data, -1);			
			var root_node = parser.get_root();
			var reader = new Reader(root_node);
			reader.read_member("type");
			string type = reader.get_string_value();
			reader.read_member("name");
			string name = reader.get_string_value();
			if(type == "alarm") {
				
				reader.read_member("valid");
				var valid = reader.get_boolean_value();
				if(valid) {
					stdout.printf("GaugeControl.json_msg: ALARM %s\n", name);
					raise_alarm(name);
				} else {
					stdout.printf("GaugeControl.json_msg: CLEAR alarm %s\n",
								  name);
					clear_alarm(name);
				}
				
			} else { // type is value

				reader.read_member("value");
				var value = reader.get_double_value();
				stdout.printf("GaugeControl.json_msg: name: %s, value:%f\n",
							  name, value);
				set_value(name, value);
			}
			
		} catch (Error e) {
			stderr.printf("Invalid JSON message ->\n");
			stderr.printf("%s\n", data);
		}
	}
	
}


