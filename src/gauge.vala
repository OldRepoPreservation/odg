using Gtk;

public class Gauge: Widget, ControlIF {

	construct {
		notify.connect(on_property_changed);
	}
	
	public double current_value { get; set; default=0.0; }
	public string label { get; set; default="Label"; }
	public Alarm alarm { get; set; }

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
		stdout.printf("**UNIMPLEMENTED** Set label: %s\n", label);
	}

	protected virtual void on_current_value_changed() {
		stdout.printf("**UNIMPLEMENTED** Current value changed: %f\n",
					  current_value);
	}

	protected virtual void on_alarm_changed() {
		stdout.printf("**UNIMPLEMENTED** Alarm changed: %s\n", alarm.name);
	}
}

