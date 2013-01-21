
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
