/**
 * @accessors true
 * @singleton
 */
component {

	property pluginManager;
	property javaLoader;

	public void function setJavaLoader(required any javaLoader) {

		variables.javaLoader = arguments.javaLoader;
		variables.javaLoader.add(getDirectoryFromPath(getCurrentTemplatePath()) & "lesscss-engine-1.0.22.jar");

	}

	/**
	 * @events applicationStart
	 */
	public void function generateFiles() {

		var lessEngine = javaLoader.create("com.asual.lesscss.LessEngine").init();
		var directories = pluginManager.getPluginPaths();
		var i = "";
		var directory = "";

		arrayAppend(directories, expandPath("/public/css/"));

		for (directory in directories) {

			var files = directoryList(directory, true, "query", "*.less");

			for (i = 1; i <= files.recordCount; i++) {

				var source = files.directory[i] & "/" & files.name[i];
				var destination = files.directory[i] & "/" & replaceNoCase(files.name[i], ".less", ".css");
				var content = fileRead(source);

				fileWrite(destination, lessEngine.compile(content));

			}

		}

	}

}