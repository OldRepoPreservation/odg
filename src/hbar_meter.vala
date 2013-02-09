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
using OdgUtils;


public class HBarMeter: Gauge {

	public bool ghost_mark { get; set; default=false; }
	public uint range { get; set; default=100; }
	public uint low_range_highlight { get; set; default=20;}
	public uint mid_range_highlight { get; set; default=60;}
	public uint high_range_highlight { get; set; default=20;}
	
	private Surface bg_layer;
	private Surface bar_layer;
	private bool redraw_all;
	private double old_value;
	private Cairo.Pattern grad;
	
	public HBarMeter(uint rng=100) {
		
		range = rng;
		current_value_changed.connect(receive_current_value_changed);
		label_changed.connect(receive_label_changed);
		draw.connect(on_draw);
		size_allocate.connect(on_size_allocate);
		set_has_window(false);
		expand = true;
		app_paintable = true;
        double_buffered = false;
		redraw_all = true;
		old_value = 0.0;
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

	protected virtual void create_bar_layer() {
		
		var my_wnd = get_window();
		if (my_wnd != null) {
			
			var region = my_wnd.get_clip_region();
			var rect = region.get_extents();
			bar_layer = my_wnd.create_similar_surface(Content.COLOR_ALPHA,
													  rect.width, rect.height);
			var bar_ctx = new Context(bar_layer);
			bar_ctx.set_source_rgba(1.0,1.0,1.0,0.0);
			bar_ctx.set_operator(Cairo.Operator.SOURCE);
			bar_ctx.paint();
		}
	}

	protected virtual void draw_marks(Context ctx, int w, int h) {

	}

	protected virtual void draw_bg(Context ctx, int width, int height) {

		var font_size = height/4.0;
		
		draw_rect(ctx, 0.01*width, 0.01*width, 0.98*width, 0.95*height, grad);
		draw_marks(ctx, width, height);

		ctx.set_source_rgba (1.0, 1.0, 1.0, 0.5);
		ctx.select_font_face("Sans", FontSlant.NORMAL, FontWeight.NORMAL);
		ctx.set_font_size(font_size);
		ctx.move_to(0.05*width, 0.3*height);
		ctx.show_text(label);
		ctx.stroke();

		ctx.set_source_rgba (1.0, 1.0, 1.0, 0.3);
		ctx.set_font_size(font_size/1.5);
		TextExtents te;
		ctx.text_extents(sub_label, out te);
		ctx.move_to(width-(te.width+20), 0.25*height);
		ctx.show_text(sub_label);
		ctx.stroke();

		ctx.translate(0.09*width, 0.58*height);
		ctx.set_source_rgba (1.0, 1.0, 1.0, 0.3);
		ctx.rectangle(0, 0, 0.85*width, 0.14*height);
		ctx.stroke();
	}

	protected virtual void draw_bar(Context ctx, int max_width, int height) {
		
		ctx.translate(0.1*max_width, 0.6*height);
		
		// erase bar rectangle
		ctx.set_operator(Cairo.Operator.CLEAR);
		ctx.rectangle(0, 0, calc_bar_width(old_value, 0.85*max_width),
					  0.11*height);
		ctx.fill();
		
		if(current_value < low_range_highlight) {
			ctx.set_source_rgba(c(200), c(255), c(0), 0.6);
		} else if(current_value > (high_range_highlight+
								   mid_range_highlight)) {
			ctx.set_source_rgba(c(150), c(50), c(0), 0.6);
		} else {
			ctx.set_source_rgba(c(0), c(255), c(0), 0.6);
		}
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.rectangle(0, 0, calc_bar_width(current_value, 0.83*max_width),
					  0.10*height);
		ctx.fill();
		
		old_value = current_value;
	}

	/* Actual method for widget to draw it self */
	protected virtual bool on_draw(Context ctx) {
		
		Allocation a;
		get_allocation(out a);
		
		if(current_value > range) {
			current_value = range;
		}
		
		// (re)create background only on demand
		if(redraw_all) {
			var bg_ctx = new Context(bg_layer);
			draw_bg(bg_ctx, a.width, a.height);
		}
		
		var bar_ctx = new Context(bar_layer);
		draw_bar(bar_ctx, a.width, a.height);

		// paint background from background layer surface
		ctx.set_source_surface(bg_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.SOURCE);
		ctx.paint();
		
		// and paint bar on top of background from bar layer surface
		ctx.set_source_surface(bar_layer, 0 ,0);
		ctx.set_operator(Cairo.Operator.ATOP);
		ctx.paint_with_alpha(0.7);
		
		redraw_all = true;

		return true;
	}

	protected virtual void receive_current_value_changed() {
		Idle.add(() => {
				redraw_all = false;
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
		grad = new Cairo.Pattern.linear(0, 0, 0.94*allocation.width,
										0.90*allocation.height);
		grad.add_color_stop_rgba(0.0, c(10), c(10), c(10), 1.0);
		grad.add_color_stop_rgba(0.5, c(10), c(10), c(190), 0.5);
		grad.add_color_stop_rgba(1.0, c(10), c(10), c(190), 0.2);
		
		create_bg_layer();
		create_bar_layer();
		var ctx1 = new Context(bg_layer);
		draw_bg(ctx1, allocation.width, allocation.height);
		var ctx2 = new Context(bar_layer);
		draw_bar(ctx2, allocation.width, allocation.height);
	}

	public override SizeRequestMode get_request_mode() {
		
		return SizeRequestMode.HEIGHT_FOR_WIDTH;
	}
	
	public override void get_preferred_height_for_width(int width,
														out int minimum_height,
														out int natural_height){

		minimum_height = calc_height(width);
		natural_height = minimum_height;
	}
	
	protected virtual int calc_height(int w) {
		
		return (int)(w*0.2);
	}

	protected virtual double calc_bar_width(double value, double max) {

		return ((value/(double)range) * max);
	}
}
