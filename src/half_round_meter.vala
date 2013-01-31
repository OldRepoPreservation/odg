
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


// TODO: draw labels on LEFT,TOP,RIGHT oriented half round meters correctly
//       should this implement also Gtk.Orientable interface ?

public class HalfRoundMeter: RoundMeter {

	public PositionType position {get; set; default=PositionType.BOTTOM; }
	
	public HalfRoundMeter(uint num_dots=5, uint num_sub_dots=6) {
		
		base(num_dots, num_sub_dots);
		hand_line_width_base = 0.03;
		range_shift_angle_coeff = 0.5;
		range_scale = 0.5;
	}
	
	protected override double calc_radius(Allocation allocation) {
		
		switch(position) {
		case PositionType.BOTTOM:
		case PositionType.TOP:
			return (allocation.width / 2.1);
		case PositionType.LEFT:
		case PositionType.RIGHT:
			return (allocation.width * 0.9);
		default:
			return (allocation.width / 2.1);
		}
	}
	
	public override SizeRequestMode get_request_mode () {
		
		return SizeRequestMode.HEIGHT_FOR_WIDTH;			
	}
	
	public override void get_preferred_width(out int minimum_width,
											  out int natural_width) {
		
		switch(position) {
		case PositionType.LEFT:
		case PositionType.RIGHT:
			minimum_width = 50;
			natural_width = 120;
			break;
		case PositionType.BOTTOM:
		case PositionType.TOP:
			minimum_width = 100;
			natural_width = 240;
			break;
		default:
			natural_width = 100;
			natural_width = 240;
			break;
		}
	}

	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){

		switch(position) {
		case PositionType.LEFT:
		case PositionType.RIGHT:
			minimum_height = (int)(width*2.0);
			natural_height = (int)(width*2.0);
			break;
		case PositionType.BOTTOM:
		case PositionType.TOP:
			minimum_height = (int)(width*0.6);
			natural_height = (int)(width*0.6);
			break;
		default:
			natural_height = width;
			break;
		}
	}
	
	protected override void draw_bg_pre(Context ctx) {
	   
//		Allocation a;
//		get_allocation(out a);
//		stdout.printf("%d:%d\n", a.width, a.height);

		switch(position) {
		case PositionType.BOTTOM:
			ctx.rectangle(0, 0, radius*2, radius*1.1);
			ctx.clip();
			break;
		case PositionType.TOP:
			ctx.translate(radius, radius);
			ctx.rotate(Math.PI);
			ctx.translate(-radius, -radius*0.1);
			ctx.rectangle(0, 0, radius*2, radius*1.1);
			ctx.clip();
			break;
		case PositionType.LEFT:
			ctx.translate(radius, radius);
			ctx.rotate(Math.PI/2.0);
			ctx.translate(-radius, -radius*0.1);
			ctx.rectangle(0, 0, radius*2, radius*1.1);
			ctx.clip();
			break;
		case PositionType.RIGHT:
			ctx.translate(radius, radius);
			ctx.rotate(1.5*Math.PI);
			ctx.translate(-radius, -radius);
			ctx.rectangle(0, 0, radius*2, radius*1.1);
			ctx.clip();
			break;
		}
	}
	
	protected override void draw_hand_pre(Context ctx) {
		
		switch(position) {
		case PositionType.BOTTOM:
			break;
		case PositionType.TOP:
			ctx.translate(radius,radius);
			ctx.rotate(Math.PI);
			ctx.translate(-radius, -radius*0.1);
			break;
		case PositionType.LEFT:
			ctx.translate(radius, radius);
			ctx.rotate(Math.PI/2.0);
			ctx.translate(-radius, -radius*0.1);
			break;
		case PositionType.RIGHT:
			ctx.translate(radius, radius);
			ctx.rotate(1.5*Math.PI);
			ctx.translate(-radius, -radius);
			break;
		}
	}

	protected override int get_label_ypos() {
		
		return ((int)(radius));
	}
}

