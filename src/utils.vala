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
using Cairo;

namespace OdgUtils {
	
	void draw_rect(Context ctx, double x, double y,
				   double width, double height, Cairo.Pattern? fill_pat) {
		
		// This is inspired by
		// http://cairographics.org/samples/rounded_rectangle/

		double aspect = 1.0;     /* aspect ratio */
		double corner_radius = height / 10.0;  /* and corner curvature radius */
		double radius = corner_radius / aspect;
		double degrees = Math.PI / 180.0;
		
		Cairo.Pattern grad;
		if(fill_pat == null) {
			
			grad = new Cairo.Pattern.linear(0, 0, width, height);
			grad.add_color_stop_rgba(0.0, c(10), c(10), c(10), 1.0);
			grad.add_color_stop_rgba(0.5, c(10), c(10), c(190), 0.5);
			grad.add_color_stop_rgba(1.0, c(10), c(10), c(190), 0.2);

		} else {
			
			grad = fill_pat;
		}
		
		ctx.new_sub_path();
		ctx.arc(x + width - radius, y + radius, radius,
				-90 * degrees, 0 * degrees);
		ctx.arc(x + width - radius, y + height - radius, radius,
				0 * degrees, 90 * degrees);
		ctx.arc (x + radius, y + height - radius,
				 radius, 90 * degrees, 180 * degrees);
		ctx.arc(x + radius, y + radius, radius, 180 * degrees, 270 * degrees);
		ctx.close_path();
		
		ctx.set_source(grad);
		ctx.fill_preserve();
		ctx.set_source_rgb(0.5, 0.5, 0.5);
		ctx.set_line_width(2.0);
		ctx.stroke();
	}

	double c(int val) {	
		return val / 255.0;
	}
}
