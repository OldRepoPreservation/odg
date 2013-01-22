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
