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


public class GaugeFactory {

	private static GaugeFactory instance;
	private GaugeFactory() {}

    public static GaugeFactory get_instance() {
		
		if(instance == null) {
			instance = new GaugeFactory();
		}
		return instance;	
	}

	public ControlIF? new_gauge(string gauge_type) {
		
		if(gauge_type == "round_meter") {
			return new RoundMeter();
		}

		return null;
	}
}
