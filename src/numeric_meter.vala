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


public class NumericMeter: Gauge {
	
	public uint range { get; set; default=100; }
	public uint precision { get; set; default=1; }
	public uint low_range_highlight { get; set; default = 20;}
	public uint mid_range_highlight { get; set; default = 60;}
	public uint high_range_highlight { get; set; default = 20;}

	protected double font_size;
	protected char []cv_str;
	
	public NumericMeter(uint rng=100) {

		range = rng;
		current_value_changed.connect(receive_current_value_changed);
		label_changed.connect(receive_label_changed);
		draw.connect(on_draw);
		size_allocate.connect(on_size_allocate);
		set_has_window(false);
		expand = true;
		app_paintable = true;
        double_buffered = false;
		var tmp = (range.to_string()+".");
		cv_str = new char[tmp.length + precision + 1];
		current_value.format(cv_str, "%0.01f");
	}
	
	private void draw_rect(Context ctx, double x, double y,
						   double width, double height) {
		
		// This is modified from
		// http://cairographics.org/samples/rounded_rectangle/

		double aspect = 1.0;     /* aspect ratio */
		double corner_radius = height / 10.0;  /* and corner curvature radius */
		double radius = corner_radius / aspect;
		double degrees = Math.PI / 180.0;

		var grad = new Cairo.Pattern.linear(0, 0, width, height);

		grad.add_color_stop_rgba(0.0, c(10), c(10), c(10), 1.0);
		grad.add_color_stop_rgba(0.5, c(10), c(10), c(190), 0.5);
		grad.add_color_stop_rgba(1.0, c(10), c(10), c(190), 0.2);

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

	/* Actual method for widget to draw it self */
	protected virtual bool on_draw(Context ctx) {

		if(current_value > range) {
			current_value = range;
		}
		
		Allocation a;
		get_allocation(out a);

		ctx.set_source_rgba(1.0, 1.0, 1.0, 0.0);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();
	   
		draw_rect(ctx, 0.05*a.width, 0.05*a.width, 0.94*a.width, 0.90*a.height);

		ctx.set_source_rgba (1.0, 1.0, 1.0, 0.5);
		ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
		ctx.set_font_size(font_size/3.0);
		ctx.move_to(0.1*a.width, 0.3*a.height);
		ctx.show_text(label);
		ctx.stroke();

		ctx.set_source_rgba (1.0, 1.0, 1.0, 0.3);
		ctx.set_font_size(font_size/5.0);
		TextExtents te;
		ctx.text_extents(sub_label, out te);
		ctx.move_to(a.width-(te.width+20), 0.25*a.height);
		ctx.show_text(sub_label);
		ctx.stroke();

		current_value.format(cv_str, "%0.01f");

		ctx.move_to(0.1*a.width, 0.9*a.height);
		if(current_value < low_range_highlight) {
			ctx.set_source_rgba(c(200), c(255), c(0), 0.6);
		} else if(current_value > (high_range_highlight+
								   mid_range_highlight)) {
			ctx.set_source_rgba(c(150), c(50), c(0), 0.6);
		} else {
			ctx.set_source_rgba(c(0), c(255), c(0), 0.6);
		}
		ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
		ctx.set_font_size(font_size);
		ctx.show_text((string)cv_str);
		ctx.stroke();
		return true;
	}

	protected virtual void receive_current_value_changed() {
		Idle.add(() => {
				queue_draw();
				return false;
			});
	}
	
	protected virtual void receive_label_changed() {
		Idle.add(() => {
				queue_draw();
				return false;
			});
	}
	
	protected virtual void on_size_allocate(Allocation allocation) {
/*
 * This method gets called by Gtk+ when the actual size is known
 * and the widget is told how much space could actually be allocated.
 * It is called every time the widget size changes, for example when the
 * user resizes the window.
 */
		// try to calculate correct font size
		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			var s = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
												  rect.width, rect.height);
			var ctx = new Context(s);
			ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
			font_size = allocation.height;
			ctx.set_font_size(font_size);
			var tmp = (range.to_string()+".");
			char []str = new char[tmp.length + precision + 1];
			((double)range).format(str, "%0.01f");
			TextExtents te;
			ctx.text_extents((string)str, out te);
			while(te.width+(0.1*rect.width) > allocation.width) {
				
				font_size *= 0.95;
				ctx.set_font_size(font_size);
				ctx.text_extents((string)str, out te);
			}
		}
	}

	public override SizeRequestMode get_request_mode () {
		
		return SizeRequestMode.HEIGHT_FOR_WIDTH;
	}
	
	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){

		minimum_height = calc_height(width);
		natural_height = minimum_height;
	}

	
	protected virtual int calc_height(int w) {
		
		return (int)(w*0.5);
	}

	private double c(int val) {	
		return val / 255.0;
	}
}
