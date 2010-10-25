component {

	public any function init() {

		variables.javaLoader = new src.JavaLoader([], true);

		return this;

	}

	public any function create(required string className) {

		return javaLoader.create(className);

	}

	public void function add(required any jars) {

		if (isSimpleValue(jars)) {
			jars = [ jars ];
		}

		var urlClassLoader = javaLoader.getURLClassLoader();
		var i = "";

		for (i = 1; i <= arrayLen(jars); i++) {

			var file = createObject("java", "java.io.File").init(jars[i]);

			urlClassLoader.addUrl(file.toURL());

		}

	}

}