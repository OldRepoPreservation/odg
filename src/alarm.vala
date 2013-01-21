
public class Alarm {

	public string name { get; private set; default="Unnamed"; }
	public string description { get; private set; default="Unknown"; }
	public bool is_valid { get; set; default=false; }
	public Gdk.Pixbuf icon { get; set; }

	public Alarm() {

		try {
			icon = new Gdk.Pixbuf.from_file("resource:///icons/default_alarm_icon.svg");
		}
		catch (Error e) {
			error ("Alarm icon loading failed: %s", e.message);
		}
	}

	public Alarm.with_name(string nam) {

		name = nam;
		var n = "resource:///icons/default_alarm_icon.svg";
		try {
			icon = new Gdk.Pixbuf.from_file(n);
		}
		catch (Error e) {
			error ("Alarm icon loading failed: %s", e.message);
		}
	}

	public Alarm.with_name_and_icon(string nam, string icon_name) {

		name = nam;
		var n = "resource:///icons/" + icon_name;
		try {
			icon = new Gdk.Pixbuf.from_file(n);
		}
		catch (Error e) {
			error ("Alarm icon loading failed: %s", e.message);
		}
		if(icon == null) {
			n = "resource:///icons/default_alarm_icon.svg";
			try {
				icon = new Gdk.Pixbuf.from_file(n);
			}
			catch (Error e) {
				error ("Alarm icon loading failed: %s", e.message);
			}
		}
	}

	public Alarm.with_name_icon_and_desc(string nam, string icon_name,
										 string desc) {

		name = nam;
		var n = "resource:////icons/" + icon_name;
		try {
			icon = new Gdk.Pixbuf.from_file(n);
		}
		catch (Error e) {
			error ("Alarm icon loading failed: %s", e.message);
		}
		if(icon == null) {
			n = "resource:////icons/default_alarm_icon.svg";
			try {
				icon = new Gdk.Pixbuf.from_file(n);
			}
			catch (Error e) {
				error ("Alarm icon loading failed: %s", e.message);
			}
		}
		description = desc;
	}
}
