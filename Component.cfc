component {

	public void function onMissingMethod(string missingMethodName, struct missingMethodArguments) {

		if (left(missingMethodName, 3) == "set") {
			var propery = replace(missingMethodName, "set", "");
			variables[property] = missingMethodArguments[1];
		}

	}

}