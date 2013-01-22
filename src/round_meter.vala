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

public class RoundMeter: Gauge {

	private bool is_valid;

	private Pattern grad;

	private Surface bg_layer;
	private Surface hand_layer;
	private Context bg_ctx;
	private Context hand_ctx;

	public uint range { get; set; default = 10; }
	public uint sub_range { get; set; default = 9; }
	public uint low_range_highlight { get; set; default = 20;}
	public uint mid_range_highlight { get; set; default = 50;}
	public uint high_range_highlight { get; set; default = 20;}
	private double old_value;
	private bool redraw_all;

	private double[] mark_x;
	private double[] mark_y;
	private double[] sub_mark_x;
	private double[] sub_mark_y;

	private double radius;

	public RoundMeter (uint num_dots=10, uint num_sub_dots=9,
					   uint low_range_hl=20, uint mid_range_hl=50,
					   uint high_range_hl=20, string label_text="km/h") {

		this.old_value = 0.0;
		this.range = num_dots;
		this.is_valid = false;
		this.mark_x = new double[this.range];
		this.mark_y = new double[this.range];		
		this.sub_mark_x = new double[this.range*this.sub_range];
		this.sub_mark_y = new double[this.range*this.sub_range];
		label = label_text;
		redraw_all = true;

		low_range_highlight = low_range_hl;
		mid_range_highlight = mid_range_hl;
		high_range_highlight = high_range_hl;

		set_app_paintable(true);
		set_visual(get_screen().get_rgba_visual());

		draw.connect(on_draw);

		this.expand = true;

		radius = get_allocated_width()/2;
		
		app_paintable = false;
		double_buffered = false;

		set_has_window(false);
	}

	private void create_gradient() {

		int width = (int)radius;
		int height = (int)radius;

		grad = new Cairo.Pattern.radial(width, height, 0,
										width, height, radius);

		grad.add_color_stop_rgba(0.0, c(10), c(10), c(190), 1.0);
		grad.add_color_stop_rgba(0.8, c(10), c(10), c(190), 0.7);
		grad.add_color_stop_rgba(1.0, c(10), c(10), c(190), 0.5);
	}

	private void calc_marks() {

		int width = (int)radius;
		int height = (int)radius;

		double shift_angle = 2.0 * Math.PI * 0.375;
		for(int i = 0; i < this.range; i++) {

			var x = Math.cos(2.0 * Math.PI * (i/((float)this.range-1)) * 0.75);
			var y = Math.sin(2.0 * Math.PI * (i/((float)this.range-1)) * 0.75);
			var new_x = ((x * Math.cos(shift_angle)) -
						 (y * Math.sin(shift_angle)));
			var new_y = ((x * Math.sin(shift_angle)) +
						 (y * Math.cos(shift_angle)));
			mark_x[i] = (width + (0.85 * width * new_x));
			mark_y[i] = (height + (0.85 * height * new_y));
		}
	}

	private void calc_sub_marks() {

		int width = (int)radius;
		int height = (int)radius;
		double shift_angle = 2.0 * Math.PI * 0.375;

		var num = (this.range * this.sub_range);

		for(int i = 0; i < num; i++) {

			var x = Math.cos(2.0*Math.PI*((float)i)/num*0.75);
			var y = Math.sin(2.0*Math.PI*((float)i)/num*0.75);
			var new_x = ((x * Math.cos(shift_angle)) -
						 (y * Math.sin(shift_angle)));
			var new_y = ((x * Math.sin(shift_angle)) +
						 (y * Math.cos(shift_angle)));
			sub_mark_x[i] = (width + (0.85 * width * new_x));
			sub_mark_y[i] = (height + (0.85 * height * new_y));
		}
	}

	private void draw_bg() {
		
		var ctx = bg_ctx;

// This makes the current color transparent (a = 0.0)
		ctx.set_source_rgba(1.0,1.0,1.0,0.0);
		
// Paint the entire window transparent to start with.
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();
		
// Set the gradient as our source and paint a circle.
		ctx.set_source(grad);
		ctx.arc(radius, radius, radius, 0, 2.0*3.14);
		ctx.fill();
		ctx.stroke();
		
		draw_range_highlight(ctx);
		draw_sub_marks(ctx);
		draw_marks(ctx);
		
// Draw the center dot
		ctx.set_source_rgba(c(124), c(32), c(113), 0.7);
		ctx.arc(radius, radius, 0.1 * radius, 0, 2.0*3.14);
		ctx.fill();
		ctx.stroke();
		
// Draw the label in the middle of the bottom area
		var font_desc = new Pango.FontDescription();
		font_desc.set_family("Sans");
		font_desc.set_weight(Pango.Weight.BOLD);
		var text_layout = create_pango_layout(label);
		font_desc.set_size((int)(radius/10 * Pango.SCALE));
		text_layout.set_font_description(font_desc);
		Pango.cairo_update_layout(ctx, text_layout);
		int w, h;
		text_layout.get_pixel_size(out w, out h);
		var xoff = (int)radius - w/2;
		ctx.set_source_rgba (0.5, 0.5, 0.5, 0.5);
		ctx.move_to(xoff, radius*2 - h*2);
		Pango.cairo_show_layout(ctx, text_layout);
//		stdout.printf("draw_bg()\n");
	}

/* Actual method for widget to draw it self */
	private bool on_draw(Context ctx) {

		// initialize when widget has already been realized
		if(!is_valid) {
			
			create_gradient();
			calc_marks();
			calc_sub_marks();
			create_bg_layer();
			create_hand_layer(); 
			is_valid = true;
		}

		// create background only on demand
		if(redraw_all) {
			draw_bg();
		}
		// paint background from background layer surface
		ctx.set_source_surface(bg_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();
		
		// create/update hand
		if((current_value >= 0) || (current_value <= range*sub_range)) {	
			draw_hand();
		}
		// and paint it on top of background from hand layer surface
		ctx.set_source_surface(hand_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.ATOP);
		ctx.paint_with_alpha(0.7);

		redraw_all = true;
//		stdout.printf("draw_hand()\n");
		return true;
	}

	private void create_bg_layer() {
		
		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			bg_layer = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
													   rect.width, rect.height);
			bg_ctx = new Context(bg_layer);
			bg_ctx.set_source_rgba(1.0,1.0,1.0,0.0);
			bg_ctx.set_operator(Cairo.Operator.SOURCE);
			bg_ctx.paint();
		}
	}

	private void create_hand_layer() {

		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			hand_layer = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
													   rect.width, rect.height);
			hand_ctx = new Context(hand_layer);
			hand_ctx.set_source_rgba(1.0,1.0,1.0,0.0);
			hand_ctx.set_operator(Cairo.Operator.SOURCE);
			hand_ctx.paint();
		}
	}

	private void draw_range_highlight(Context ctx) {

		ctx.save();
		ctx.set_line_width(radius / 30);
		ctx.translate(radius, radius);
		double shift_angle = 2.0 * Math.PI * 0.375;
		var num = (this.range * this.sub_range);
		ctx.rotate(shift_angle);

		double angle = 0.0;
		var angle2 = (2.0*Math.PI*((float)low_range_highlight/(float)num)*0.75);
		ctx.set_source_rgba(c(200), c(255), c(0), 0.6);
		ctx.arc(0, 0, radius*0.95, angle, angle2-0.01);
		ctx.stroke();

		angle = angle2;
		angle2 = (2.0*Math.PI*((float)mid_range_highlight/(float)num)*0.75);
		ctx.set_source_rgba(c(0), c(255), c(0), 0.6);
		ctx.arc(0, 0, radius*0.95, angle, angle+angle2-0.01);
		ctx.stroke();

		angle += angle2;
		angle2 = (2.0*Math.PI*((float)high_range_highlight/(float)num)*0.75);
		ctx.set_source_rgba(c(150), c(50), c(0), 0.6);
		ctx.arc(0, 0, radius*0.95, angle, angle+angle2);
		ctx.stroke();

		ctx.restore();
	}

	private void draw_marks(Context ctx) {

		double rad = radius / 30.0;
		ctx.set_line_width(1);
		ctx.set_source_rgba(c(226), c(119), c(214), 0.8);
		for(int i = 0; i < this.range; i++) {

			double x = mark_x[i];
			double y = mark_y[i];

			ctx.arc(x, y, rad, 0, 2.0 * 3.14);
			ctx.fill();
			ctx.stroke();
		}
	}

	private void draw_sub_marks(Context ctx) {

		ctx.set_line_width(1);
		ctx.set_source_rgba(0, 0, 0, 1);
		ctx.save();
		var num = (this.range * this.sub_range);
		for(int i = 0; i < num; i++) {

			double x = sub_mark_x[i];
			double y = sub_mark_y[i];
			ctx.save();
			ctx.move_to(x, y);
			ctx.translate(0.1*radius, 0.1*radius);
			ctx.scale(0.9, 0.9);
			ctx.line_to(x, y);
			ctx.stroke();
			ctx.restore();
		}
		ctx.restore();
	}

	private void draw_hand() {
		
		var ctx = hand_ctx;

		double shift_angle = 2.0 * Math.PI * 0.375;
		double max = (double)(this.range*this.sub_range);
		
		double dh = (old_value/max)*(2.0 * Math.PI)*0.75;
		double end_x = (0.7 * radius * Math.cos(dh));
		double end_y = (0.7 * radius * Math.sin(dh));
		var new_x = ((end_x * Math.cos(shift_angle)) -
					 (end_y * Math.sin(shift_angle)));
		var new_y = ((end_x * Math.sin(shift_angle)) +
					 (end_y * Math.cos(shift_angle)));

		ctx.set_line_width(0.06 * radius);
		ctx.set_operator(Cairo.Operator.CLEAR);
		ctx.move_to(radius, radius);
		ctx.rel_line_to(new_x, new_y);
		ctx.set_line_cap(LineCap.ROUND);
		ctx.stroke();

		old_value = current_value;
		
		dh = (current_value/max) * (2.0 * Math.PI)*0.75;
		end_x = (0.7 * radius * Math.cos(dh));
		end_y = (0.7 * radius * Math.sin(dh));
		new_x = ((end_x * Math.cos(shift_angle)) -
				 (end_y * Math.sin(shift_angle)));
		new_y = ((end_x * Math.sin(shift_angle)) +
				 (end_y * Math.cos(shift_angle)));

		ctx.set_line_width(0.05 * radius);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.move_to(radius, radius);
		ctx.set_source_rgba(0, 0, 0, 1.0);
		ctx.rel_line_to(new_x, new_y);
		ctx.stroke();
	}

	private double c(int val) {

		return val / 255.0;
	}

	public override void size_allocate (Allocation allocation) {
		
// The base method will save the allocation and resize the
// widget's GDK window if the widget is already realized.
		base.size_allocate (allocation);
		radius = allocation.width / 2;
		calc_marks();
		calc_sub_marks();
		create_gradient();
		create_bg_layer();
		create_hand_layer();
	}

	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){

		minimum_height = width;
		natural_height = width;
	}

	protected override void on_label_changed() {
		stdout.printf("on_label_changed(): label = %s\n", label);
		queue_draw();
	}

	protected override void on_current_value_changed() {

		if(current_value < 0) {
			return;
		}
		if(current_value > range*sub_range) {
			return;
		}
		redraw_all = false;
		queue_draw();
		stdout.printf("on_current_value_changed(): current_value = %f\n", 
					  current_value);
	}
}

