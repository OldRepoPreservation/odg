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
	public string type;
	public string name;
}

class ValueMsg: Msg {
	public double value;
}

class AlarmMsg: Msg {
	public bool valid;
}

class GaugeList {
	public unowned List<ControlIF> list { get; private set; }
	public GaugeList() {
		list = new List<ControlIF>();
	}
}

public class GaugeControl: GLib.Object {
	
    private AsyncQueue<Msg> msg_queue;

	public static bool use_thread { get; set; default=false; }
	private static GaugeControl instance;
	private GaugeControl() {}
	
	private HashTable<string,GaugeList> gauge_msgs;
	private HashTable<string,GaugeList> gauge_alarms;
	
	private HashTable<string,MessageSourceIF> msg_sources;

	private Thread<void*> thread;

	construct {
		
		gauge_msgs = new HashTable<string,GaugeList>(str_hash, str_equal);
		gauge_alarms = new HashTable<string,GaugeList>(str_hash,
													   str_equal);
		msg_queue = new AsyncQueue<Msg>();
		
		msg_sources = new HashTable<string,MessageSourceIF>(str_hash,
															str_equal);
		if(use_thread) {
			thread = new Thread<void*> ("GaugeControl",
										this.check_for_msg_thread);
			stdout.printf("GaugeControl: started thread for message queues\n");
		}
	}

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
	
	public void listen_value(ControlIF g, string value_name) {
		
		GaugeList l = gauge_msgs.lookup(value_name);
		if(l == null) {
			gauge_msgs.insert(value_name, new GaugeList());
		}
		l = gauge_msgs.lookup(value_name);
		l.list.append(g);
	}
	
	public void forget_value(ControlIF g, string value_name) {
		
		GaugeList l = gauge_msgs.lookup(value_name);
		if(l == null) {
			return;
		}
		l.list.remove(g);
	}

	private void listen_alarm(ControlIF g, string alarm_name) {
		
		GaugeList l = gauge_alarms.lookup(alarm_name);
		if(l == null) {
			gauge_alarms.insert(alarm_name, new GaugeList());
		}
		l = gauge_alarms.lookup(alarm_name);
		l.list.append(g);
	}
	
	private void forget_alarm(ControlIF g, string alarm_name) {
		
		GaugeList l = gauge_alarms.lookup(alarm_name);
		if(l == null) {
			return;
		}
		l.list.remove(g);
	}

	public void *check_for_msg_thread() {

		while(true) {

			Msg m = msg_queue.pop();
			
			if(m.type == "alarm") {
				
				GaugeList l = gauge_alarms.lookup(m.name);
				if(l != null) {
					foreach(ControlIF cif in l.list) {
						cif.alarm.is_valid = (m as AlarmMsg).valid;
					}	
					continue;
				} else {
					stderr.printf("check_for_msg_thread: unknown alarm '%s'\n", 
								  m.name);
					continue;
				}
			}
			
			if(m.type == "value") {
				
				GaugeList l = gauge_msgs.lookup(m.name);
				if(l != null) {
					foreach(ControlIF cif in l.list) {
						cif.current_value = (m as ValueMsg).value;
					}
				} else {
					stderr.printf("check_for_msg_thread: unknown value '%s'\n",
								  m.name);
				}
			}
		}
		
		return null;
	}
	

	// method to check message queues
    // should be called for example from main loop (idle.add)
	// or from a separate thread
	public bool check_for_msg() {
		
		if(use_thread) {
			stderr.printf("check_for_msg: thread is used for message queues\n");
			return true;
		}

		Msg m = msg_queue.try_pop();
		if(m == null) {
			return true;
		}
		
		if(m.type == "alarm") {
			
			GaugeList l = gauge_alarms.lookup(m.name);
			if(l != null) {
				foreach(ControlIF cif in l.list) {
					cif.alarm.is_valid = (m as AlarmMsg).valid;
				}	
				return true;
			} else {
				stderr.printf("check_for_msg: unknown alarm '%s'\n", 
							  m.name);
				return true;
			}
		}
		
		if(m.type == "value") {

			GaugeList l = gauge_msgs.lookup(m.name);
			if(l != null) {
				foreach(ControlIF cif in l.list) {
					cif.current_value = (m as ValueMsg).value;
				}
			} else {
				stderr.printf("check_for_msg: unknown value '%s'\n", m.name);
			}
		}
		
		return true;
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
		msg.type = "alarm";
		msg.name = name;
		msg.valid = true;
		msg_queue.push(msg as Msg);
	}
	
	private void clear_alarm(string name) {

		stdout.printf("GaugeControl.clear_alarm: name=%s\n", name);
		AlarmMsg msg = new AlarmMsg();
		msg.type = "alarm";
		msg.name = name;
		msg.valid = false;
		msg_queue.push(msg as Msg);
	}

	private void set_value(string name, double value) {
		
		ValueMsg msg = new ValueMsg();
		msg.type = "value";
		msg.name = name;
		msg.value = value;
		msg_queue.push(msg as Msg);
	}
	
	// message source uses this to send values and alarms
	// data is a json struct 
	// Alarm
	// {"msg": {"alarm": { "name": "<alarm name>", "valid": <true|false> }}}
	// Value
    // {"msg": {"value": { "name": "<value name>", "value": <double value>}}}
	public void json_msg(string data) {

//		stdout.printf("GaugeControl.json_msg: %s\n", data);
		
		try {
			var parser = new Parser();
			parser.load_from_data(data, -1);
			var root_node = parser.get_root();
			if(root_node.get_node_type() != Json.NodeType.OBJECT) {
				stderr.printf("Invalid JSON message ->\n");
				stderr.printf("%s\n", data);
				return;
			}

			var root_obj = root_node.get_object();
			var type = root_obj.get_string_member("type");
			var data_obj = root_obj.get_object_member("data");
			var name = data_obj.get_string_member("name");
			if(type == "alarm") {
				
				var valid = data_obj.get_boolean_member("valid");
				if(valid) {
					stdout.printf("GaugeControl.json_msg: ALARM %s\n", name);
					raise_alarm(name);
				} else {
					stdout.printf("GaugeControl.json_msg: CLEAR alarm %s\n",
								  name);
					clear_alarm(name);
				}
				
			} else if(type == "value") {
				
				var value = data_obj.get_double_member("value");
				stdout.printf("GaugeControl.json_msg: name:%s, value:%f\n",
							  name, value);
				set_value(name, value);
			}
			
		} catch (Error e) {
			stderr.printf("Invalid JSON message ->\n");
			stderr.printf("%s\n", data);
		}
	}
	
}


