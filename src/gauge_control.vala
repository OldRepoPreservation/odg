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
		gauge_alarms = new HashTable<string,List<ControlIF>>(str_hash,
															 str_equal);
		value_queue = new AsyncQueue<Msg>();
		alarm_queue = new AsyncQueue<Msg>();
		
		msg_sources = new HashTable<string,MessageSourceIF>(str_hash,str_equal);
	}
	
    private AsyncQueue<Msg> value_queue;
	private AsyncQueue<Msg> alarm_queue;

	private static GaugeControl instance;
	private GaugeControl() {}
	
	private HashTable<string,List<ControlIF>> gauge_msgs;
	private HashTable<string,List<ControlIF>> gauge_alarms;
	
	private HashTable<string,MessageSourceIF> msg_sources;

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
	// or from a separate thread
	public void check_for_msg() {
		
		AlarmMsg a = alarm_queue.try_pop() as AlarmMsg;
		if(a != null) {
			unowned List<ControlIF> l = gauge_alarms.get(a.name);
			if(l != null) {
				foreach(ControlIF cif in l) {
					cif.alarm.is_valid = a.valid;
				}	
				return;
			} else {
				stderr.printf("check_for_msg: unknown alarm %s\n", a.name);
				return;
			}
		}
		
		ValueMsg v = value_queue.try_pop() as ValueMsg;
		if(v != null) {
			unowned List<ControlIF> l = gauge_msgs.get(v.name);
			if(l != null) {
				foreach(ControlIF cif in l) {
					cif.current_value = v.value;
				}
			} else {
				stderr.printf("check_for_msg: unknown value %s\n", v.name);
			}
		}
	}

	// add a source that provides values for gauges
    // and also raises alarms
	// factory is used to create an instance of source
	// and it is then initalized and start method is finally called
	public void add_source(MessageSourceFactory factory, string source_name) {

		MessageSourceIF ms = factory.create();
		msg_sources.insert(source_name, ms);
		ms.initialize();
		ms.start();
	}
	

	// gauge value source and alarm source related methods begin.
	// executed in callers context

	private void raise_alarm(string name) {
		
		stdout.printf("GaugeControl.raise_alarm: name=%s\n", name);
		AlarmMsg msg = new AlarmMsg();
		msg.name = name;
		msg.valid = true;
		alarm_queue.push(msg);
	}
	
	private void clear_alarm(string name) {

		stdout.printf("GaugeControl.clear_alarm: name=%s\n", name);
		AlarmMsg msg = new AlarmMsg();
		msg.name = name;
		msg.valid = false;
		alarm_queue.push(msg);
	}

	private void set_value(string name, double value) {
		
		stdout.printf("GaugeControl.set_value: name=%s, value=%f\n",
					  name, value);
		ValueMsg msg = new ValueMsg();
		msg.name = name;
		msg.value = value;
		value_queue.push(msg);
	}
	
	// message source uses this to send values and alarms
	// data is a json struct 
	// Alarm
	// { "type": "alarm", "name": "<alarm name>", "valid": <true|false> }
	// Value
    // { "type": "alarm", "name": "<value name>", "value": <double value> }
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


