
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
