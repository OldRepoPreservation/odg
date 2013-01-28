
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


public class HalfRoundMeter: RoundMeter {

	public HalfRoundMeter(uint num_dots=5, uint num_sub_dots=6) {
		
		base(num_dots, num_sub_dots);
		hand_line_width_base = 0.03;
		range_shift_angle_coeff = 0.5;
		range_scale = 0.5;
	}

	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){
		
		minimum_height = width;
		natural_height = (int)(width*0.55);
	}
	
	protected override void draw_bg(Context ctx) {
	   
		ctx.translate(0, radius);
		ctx.rectangle(0, 0, radius*2, radius*1.1);
		ctx.clip();
		base.draw_bg(ctx);
	}

	protected override void draw_hand(Context ctx) {

		ctx.translate(0, radius);
		ctx.rectangle(0, 0, radius*2, radius*1.1);
		ctx.clip();
		base.draw_hand(ctx);
	}
}

