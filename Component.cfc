component {

	this.prototype = new coldmvc.Prototype(this, variables);

	public void function onMissingMethod(string missingMethodName, struct missingMethodArguments) {

		if (left(missingMethodName, 3) == "set") {
			var property = replace(missingMethodName, "set", "");
			variables[property] = missingMethodArguments[1];
		}

	}

}