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


public class GaugeResources {

	private static Resource resources { get; private set; default=null;}
	
	public static void initialize(string path="") {

		string p;
		if(path != "") {
			p = path + "/resources/";
		} else {
			p = "resources/";
		}
		try {
			resources = Resource.load(p + "gauge.gresource");
			resources._register();
		}
		catch(Error e) {
			stdout.printf ("Resource loading failed: \"%s\"\n", e.message);
		}
	}
}
