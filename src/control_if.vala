
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


public interface ControlIF: Object {

	public abstract double current_value { get; set; }
	public abstract string label { get; set; }
	public abstract string sub_label { get; set; }
	public abstract Alarm alarm { get; set; }
	
	protected abstract void on_label_changed();
	protected abstract void on_current_value_changed();
	protected abstract void on_alarm_changed();
}
