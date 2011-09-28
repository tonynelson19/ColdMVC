component {

	this.prototype = new coldmvc.Prototype(this, variables);

	public void function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		if (left(arguments.missingMethodName, 3) == "set") {
			var property = replace(arguments.missingMethodName, "set", "");
			variables[property] = arguments.missingMethodArguments[1];
		}

	}

}