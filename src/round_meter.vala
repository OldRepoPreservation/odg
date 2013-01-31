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


public class RoundMeterConfig {

	private uint real_low_range_highlight;
	private uint real_mid_range_highlight;
	private uint real_high_range_highlight;

	public uint *low_range_highlight { get; private set; default=null; }
	public uint *mid_range_highlight { get; private set; default=null; }
	public uint *high_range_highlight { get; private set; default=null; }
	public string label { get; private set; default=null; }
	public string[] mark_labels { get; set; default = null; }
	
	public RoundMeterConfig.with_label(string l) {
		label = l;
	}
	
	public RoundMeterConfig.with_label_and_mark_labels(string l, string[] ml) {
		label = l;
		mark_labels = ml;
	}
	
	public RoundMeterConfig.with_labels_and_highlight(string l,
													  string[] ml,
													  uint low_range_hl,
													  uint mid_range_hl,
													  uint high_range_hl) {
		label = l;
		mark_labels = ml;
		real_low_range_highlight = low_range_hl;
		real_mid_range_highlight = mid_range_hl;
		real_high_range_highlight = high_range_hl;
		low_range_highlight = &real_low_range_highlight;
		mid_range_highlight = &real_mid_range_highlight;
		high_range_highlight = &real_high_range_highlight;
	}
}

public delegate void RoundMeterConfigDelegate(RoundMeter m, RoundMeterConfig c);

void round_meter_set_config_default(RoundMeter m, RoundMeterConfig c) {
	
	if(c.label != null) {
		m.label = c.label;
	}
	if(c.mark_labels != null) {
		m.mark_labels = c.mark_labels;
	}
	if(c.low_range_highlight != null) {
		m.low_range_highlight = *(c.low_range_highlight);
	}
	if(c.mid_range_highlight != null) {
		m.mid_range_highlight = *(c.mid_range_highlight);
	}
	if(c.high_range_highlight != null) {
		m.high_range_highlight = *(c.high_range_highlight);
	}
}

public class RoundMeter: Gauge {

	private bool is_valid;

	private Pattern grad;

	private Surface bg_layer;
	private Surface hand_layer;

	protected double radius;

	private double old_value;
	private bool redraw_all;

	private double[] mark_x;
	private double[] mark_y;
	private double[] sub_mark_x;
	private double[] sub_mark_y;

	public string[] mark_labels { get; set; default = null; }
	public uint range { get; set; default = 10; }
	public uint sub_range { get; set; default = 9; }
	public uint low_range_highlight { get; set; default = 20;}
	public uint mid_range_highlight { get; set; default = 50;}
	public uint high_range_highlight { get; set; default = 20;}

	protected double hand_line_width_base { get; set; default = 0.05; }
	protected double range_shift_angle_coeff { get; set; default = 0.375; }
	protected double range_scale { get; set; default = 0.75; }
	
	public void set_config(RoundMeterConfigDelegate d,
						   RoundMeterConfig c) {
		d(this, c);
		if(is_valid) {
			Idle.add(() => {
					queue_draw();
					return false;
				});
		}
	}
	
	public RoundMeter(uint num_dots=10, uint num_sub_dots=9) {

		this.is_valid = false;
		this.old_value = 0.0;
		this.range = num_dots;
		this.mark_x = new double[this.range];
		this.mark_y = new double[this.range];		
		this.sub_mark_x = new double[this.range*this.sub_range];
		this.sub_mark_y = new double[this.range*this.sub_range];
		redraw_all = true;

		set_app_paintable(true);
		set_visual(get_screen().get_rgba_visual());

		draw.connect(on_draw);
		size_allocate.connect(on_size_allocate);

		this.app_paintable = true;
        this.double_buffered = false;
		
		this.expand = true;
		
		current_value_changed.connect(receive_current_value_changed);

		set_has_window(false);
	}

	private void create_gradient() {

		int width = (int)radius;
		int height = (int)radius;

		grad = new Cairo.Pattern.radial(width, height, 0,
										width, height, radius);

		grad.add_color_stop_rgba(0.0, c(10), c(10), c(10), 1.0);
		grad.add_color_stop_rgba(0.2, c(10), c(10), c(190), 0.7);
		grad.add_color_stop_rgba(0.8, c(10), c(10), c(190), 0.5);
		grad.add_color_stop_rgba(1.0, c(10), c(10), c(190), 0.2);
	}

	private void calc_marks() {

		int width = (int)radius;
		int height = (int)radius;

		double shift_angle = 2.0 * Math.PI * range_shift_angle_coeff;
		for(int i = 0; i < this.range; i++) {

			var x = Math.cos(2.0*Math.PI*(i/((float)this.range-1))*range_scale);
			var y = Math.sin(2.0*Math.PI*(i/((float)this.range-1))*range_scale);
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
		double shift_angle = 2.0 * Math.PI * range_shift_angle_coeff;

		var num = (this.range * this.sub_range);

		for(int i = 0; i < num; i++) {

			var x = Math.cos(2.0*Math.PI*((float)i)/num*range_scale);
			var y = Math.sin(2.0*Math.PI*((float)i)/num*range_scale);
			var new_x = ((x * Math.cos(shift_angle)) -
						 (y * Math.sin(shift_angle)));
			var new_y = ((x * Math.sin(shift_angle)) +
						 (y * Math.cos(shift_angle)));
			sub_mark_x[i] = (width + (0.85 * width * new_x));
			sub_mark_y[i] = (height + (0.85 * height * new_y));
		}
	}

/* Actual method for widget to draw it self */
	protected virtual bool on_draw(Context ctx) {
		
//		stdout.printf("on_draw()\n");
		
		if(!is_valid) {
			return false;
		}

		// (re)create background only on demand
		if(redraw_all) {
			var bg_ctx = new Context(bg_layer);
			draw_bg(bg_ctx);
		}
		// paint background from background layer surface
		ctx.set_source_surface(bg_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();

		// and paint it on top of background from hand layer surface
		ctx.set_source_surface(hand_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.ATOP);
		ctx.paint_with_alpha(0.7);

		redraw_all = true;
		return true;
	}
	protected virtual void create_bg_layer() {
		
		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			bg_layer = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
													 rect.width, rect.height);
			var bg_ctx = new Context(bg_layer);
			bg_ctx.set_source_rgba(1.0,1.0,1.0,0.0);
			bg_ctx.set_operator(Cairo.Operator.SOURCE);
			bg_ctx.paint();
		}
	}

	protected virtual void create_hand_layer() {

		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			hand_layer = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
													   rect.width, rect.height);
			var hand_ctx = new Context(hand_layer);
			hand_ctx.set_source_rgba(1.0,1.0,1.0,0.0);
			hand_ctx.set_operator(Cairo.Operator.SOURCE);
			hand_ctx.paint();
		}
	}

	private void draw_range_highlight(Context ctx) {

		ctx.save();

		ctx.set_line_width(radius / 30);
		ctx.translate(radius, radius);
		double shift_angle = 2.0 * Math.PI * range_shift_angle_coeff;
		var num = (this.range * this.sub_range);
		ctx.rotate(shift_angle);

		double angle = 0.0;
		var angle2 = (2.0*Math.PI*((float)low_range_highlight/(float)num)*
					  range_scale);
		if(angle2 != 0) {
			ctx.set_source_rgba(c(200), c(255), c(0), 0.6);
			ctx.arc(0, 0, radius*0.9, angle, angle2-0.01);
			ctx.stroke();
		}

		angle = angle2;
		angle2 = (2.0*Math.PI*((float)mid_range_highlight/(float)num)*
				  range_scale);
		if(angle != 0) {
			ctx.set_source_rgba(c(0), c(255), c(0), 0.6);
			ctx.arc(0, 0, radius*0.9, angle, angle+angle2-0.01);
			ctx.stroke();
		}

		angle += angle2;
		angle2 = (2.0*Math.PI*((float)high_range_highlight/(float)num)*
				  range_scale);
		if(angle != 0) {
			ctx.set_source_rgba(c(150), c(50), c(0), 0.6);
			ctx.arc(0, 0, radius*0.9, angle, angle+angle2);
			ctx.stroke();
		}

		ctx.restore();
	}

	protected virtual void draw_marks_bg(Context ctx) {
	
		ctx.save();

		var start_mark_y = -((mark_y[0]-radius)/(radius*0.85));
		var start_mark_x = ((mark_x[0]-radius)/(radius*0.85));
		var end_mark_y = -((mark_y[range-1]-radius)/(radius*0.85));
		var end_mark_x = ((mark_x[range-1]-radius)/(radius*0.85));
		double start_angle;
		double end_angle;
		if(start_mark_x > 0) {
			start_angle = Math.asin(start_mark_y);
		} else {
			start_angle = Math.asin(-start_mark_y)+Math.PI;
		}
		if(end_mark_x > 0) {
			end_angle = Math.asin(end_mark_y);
		} else {
			end_angle = Math.asin(-end_mark_y)+Math.PI;
		}
//		stdout.printf("%f,%f\n", start_angle, end_angle);
		start_angle = 2*Math.PI-start_angle;
		end_angle = 2*Math.PI-end_angle;
		
		ctx.translate(radius, radius);
		ctx.set_source_rgba(1.0, 1.0, 1.0, 0.2);
		ctx.set_operator(Cairo.Operator.OVER);
		ctx.set_line_width(0.08 * radius);
		ctx.arc(0, 0, radius*0.81, start_angle, end_angle);
		ctx.stroke();

		ctx.restore();
	}
	
	protected virtual void draw_marks(Context ctx) {

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

	protected virtual void draw_sub_marks(Context ctx) {

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
	
	protected virtual void draw_mark_labels(Context ctx) {

		int i = 0;
		double w;
		double h;
		if(mark_labels != null) {

			ctx.set_font_size(radius/8.0);
			ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
			TextExtents te;
			
			foreach(string ml in mark_labels) {

				if(i >=  mark_x.length) {
					break;
				}
				double x = mark_x[i];
				double y = mark_y[i];
				ctx.save();
				ctx.scale(0.75, 0.75);
				ctx.translate(radius*0.35, radius*0.35);
				ctx.text_extents(ml, out te);
				w = te.width;
				h = te.height;
				ctx.translate(-(w/2), 0);
				ctx.set_source_rgba (1.0, 1.0, 1.0, 0.5);
				ctx.move_to(x, y);
				ctx.show_text(ml);
				ctx.stroke();
				ctx.restore();
				i++;
			}
		}
	}

	protected virtual void draw_label(Context ctx, int yoff) {

// Draw the label in the middle of the bottom area
		
		double w;
		double h;

// Pango could be also used but it did not display all characters ???
		ctx.set_font_size(radius/7.0);
		ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.BOLD);
		TextExtents te;
		ctx.text_extents(label, out te);
		w = te.width;
		h = te.height;
		var xoff = (int)radius - w/2;
		ctx.set_source_rgba(0.5, 0.5, 0.5, 0.5);
		ctx.move_to(xoff, yoff - h*2);
		ctx.show_text(label);
		ctx.stroke();
	}

	protected virtual int get_label_ypos() {
		return ((int)(radius*2));
	}

	protected virtual void draw_bg_pre(Context ctx) {
		// Paint the entire window transparent
		// causes text not to render correctly, characters missing
		//ctx.set_source_rgba(1.0, 1.0, 1.0, 0.0);
		//ctx.set_operator(Cairo.Operator.SOURCE);
		//ctx.paint();
	}
	protected virtual void draw_bg_post(Context ctx) {}
	protected virtual void draw_hand_pre(Context ctx) {}
	protected virtual void draw_hand_post(Context ctx) {}
	
	protected virtual void draw_bg(Context ctx) {

		draw_bg_pre(ctx);
		
// Set the gradient as source and paint a circle.
		ctx.set_source(grad);
		ctx.arc(radius, radius, radius, 0, 2.0*3.14);
		ctx.fill();
		ctx.stroke();

		draw_range_highlight(ctx);
		draw_marks_bg(ctx);
		draw_sub_marks(ctx);
		draw_marks(ctx);

		draw_label(ctx, get_label_ypos());
		draw_mark_labels(ctx);

// Draw the center dot
		ctx.set_source_rgba(c(124), c(32), c(113), 0.7);
		ctx.arc(radius, radius, 0.1 * radius, 0, 2.0*3.14);
		ctx.fill();
		ctx.stroke();

		draw_bg_post(ctx);

//		stdout.printf("draw_bg()\n");
	}

	protected virtual void draw_hand(Context ctx) {

		draw_hand_pre(ctx);

		double shift_angle = 2.0 * Math.PI * range_shift_angle_coeff;
		double max = (double)(this.range*this.sub_range);
		
		double dh = (old_value/max)*(2.0 * Math.PI)*range_scale;
		double end_x = (0.7 * radius * Math.cos(dh));
		double end_y = (0.7 * radius * Math.sin(dh));
		var new_x = ((end_x * Math.cos(shift_angle)) -
					 (end_y * Math.sin(shift_angle)));
		var new_y = ((end_x * Math.sin(shift_angle)) +
					 (end_y * Math.cos(shift_angle)));

		ctx.set_line_width((hand_line_width_base+0.01) * radius);
		ctx.set_operator(Cairo.Operator.CLEAR);
		ctx.move_to(radius, radius);
		ctx.rel_line_to(new_x, new_y);
		ctx.set_line_cap(LineCap.ROUND);
		ctx.stroke();

		old_value = current_value;
		
		dh = (current_value/max) * (2.0 * Math.PI)*range_scale;
		end_x = (0.7 * radius * Math.cos(dh));
		end_y = (0.7 * radius * Math.sin(dh));
		new_x = ((end_x * Math.cos(shift_angle)) -
				 (end_y * Math.sin(shift_angle)));
		new_y = ((end_x * Math.sin(shift_angle)) +
				 (end_y * Math.cos(shift_angle)));

		ctx.set_line_width(hand_line_width_base * radius);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.move_to(radius, radius);
		ctx.set_source_rgba(0, 0, 0, 1.0);
		ctx.rel_line_to(new_x, new_y);
		ctx.stroke();

		draw_hand_post(ctx);
//		stdout.printf("draw_hand()\n");
	}

	private double c(int val) {

		return val / 255.0;
	}

	protected virtual double calc_radius(Allocation allocation) {
		
		return (allocation.width / 2);
	}
	
	protected virtual void on_size_allocate(Allocation allocation) {
/*
 * This method gets called by Gtk+ when the actual size is known
 * and the widget is told how much space could actually be allocated.
 * It is called every time the widget size changes, for example when the
 * user resizes the window.
 */
		radius = calc_radius(allocation);
		calc_marks();
		calc_sub_marks();
		create_gradient();
		create_bg_layer();
		create_hand_layer();
		var ctx1 = new Context(bg_layer);
		draw_bg(ctx1);
		var ctx2 = new Context(hand_layer);
		draw_hand(ctx2);
		is_valid = true;
	}

	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){

		minimum_height = width;
		natural_height = width;
	}

	protected override void on_label_changed() {
//		stdout.printf("on_label_changed(): label = %s\n", label);
		if(is_valid) {
			Idle.add(() => {
					queue_draw();
					return false;
				});
		}
	}

	protected virtual void receive_current_value_changed() {
		
		if(is_valid) {
			Idle.add(() => {
					var ctx = new Context(hand_layer);
					draw_hand(ctx);
					queue_draw();
					redraw_all = false;
					return false;
				});
		}
	}

	protected override void on_current_value_changed() {

		if(current_value < 0) {
			return;
		}
		if(current_value > range*sub_range) {
			return;
		}
		
		current_value_changed();

//		stdout.printf("on_current_value_changed(): current_value = %f\n", 
//					  current_value);
	}

}

