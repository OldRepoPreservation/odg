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

public class Gauge: Widget, ControlIF {

	construct {
		notify.connect(on_property_changed);
	}
	
	public double current_value { get; set; default=0.0; }
	public string label { get; set; default="Label"; }
	public Alarm alarm { get; set; }
	
	protected signal void current_value_changed();
	protected signal void alarm_changed();
	protected signal void label_changed();

	private void on_property_changed(Object o, ParamSpec p) {

		switch(p.name) {
		case "current-value":
			on_current_value_changed();
			break;
		case "label":
			on_label_changed();
			break;
		case "alarm":
			on_alarm_changed();
			break;
		}
	}
	
	protected virtual void on_label_changed() {
		label_changed();
		stdout.printf("**UNIMPLEMENTED** Set label: %s\n", label);
	}

	protected virtual void on_current_value_changed() {
		current_value_changed();
		stdout.printf("**UNIMPLEMENTED** Current value changed: %f\n",
					  current_value);
	}

	protected virtual void on_alarm_changed() {
		alarm_changed();
		stdout.printf("**UNIMPLEMENTED** Alarm changed: %s\n", alarm.name);
	}
}

