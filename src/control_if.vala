
public interface ControlIF: Object {

	public abstract double current_value { get; set; }
	public abstract string label { get; set; }
	public abstract Alarm alarm { get; set; }
	
	protected abstract void on_label_changed();
	protected abstract void on_current_value_changed();
	protected abstract void on_alarm_changed();
}
