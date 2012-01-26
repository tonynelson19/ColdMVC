component accessors="true" {

	/**
	 * @inject coldmvc
	 */
	property coldmvc;
    
    /**
     * @inject coldmvc
     */
    property $;

	/**
	 * @inject coldmvc
	 */
	property tagInvoker;

	public any function init(required any formFactory) {

		variables.formFactory = arguments.formFactory;

		variables.attributes = {};
		variables.elements = [];
		variables.elementStruct = {};

		return this;

	}

	public any function create() {

		return this;

	}

	public string function render() {

		var content = [];
		var i = "";

		for (i = 1; i <= arrayLen(variables.elements); i++) {
			arrayAppend(content, variables.elements[i].render());
		}

		var attribs = duplicate(variables.attributes);
		attribs.generatedContent = arrayToList(content, chr(10));

		return variables.tagInvoker.invoke("form", attribs);

	}

	public struct function getAttributes() {

		return variables.attributes;

	}

	public any function getAttribute(required string key) {

		return variables.attributes[arguments.key];

	}

	public any function setAttributes(required struct attributes) {

		variables.attributes = arguments.attributes;

		return this;

	}

	public any function setAttribute(required string key, required any value) {

		variables.attributes[arguments.key] = arguments.value;

		return this;

	}

	public boolean function hasAttribute(required string key) {

		return structKeyExists(variables.attributes, arguments.key);

	}

	public any function removeAttribute(required string key) {

		structDelete(variables.attributes, arguments.key);

		return this;

	}
    
    public any function setLabel(required string label) {

        return setAttribute("label", arguments.label);

    }

	public array function getElements() {

		return variables.elements;

	}

	public struct function getElementStruct() {

		return variables.elementStruct;

	}

	public any function getElement(required string name) {

		return variables.elementStruct[arguments.name];

	}

	public any function addElements(required array elements) {

		var i = "";

		for (i = 1; i <= arrayLen(arguments.elements); i++) {
			addElement(arguments.elements[i]);
		}

		return this;

	}

	public any function addElement(required any element) {

		if (isSimpleValue(arguments.element)) {

			var type = arguments.element;
			var name = arguments[2];

			if (structKeyExists(arguments, 3)) {
				var attributes = arguments[3];
			} else {
				var attributes = {};
			}

			arguments.element = createElement(type, name, attributes);

		}

		var name = arguments.element.getName();

		if (hasElement(name)) {
			removeElement(name);
		}

		arrayAppend(variables.elements, arguments.element);
		variables.elementStruct[name] = arguments.element;
		this[name] = arguments.element;

		return arguments.element;

	}

	public any function createElement(required string type, required string name, struct attributes) {

		if (!structKeyExists(arguments, "attributes")) {
			arguments.attributes = {};
		}

		if (!structKeyExists(arguments.attributes, "name")) {
			arguments.attributes.name = arguments.name;
		}

		if (!structKeyExists(arguments.attributes, "label")) {
			arguments.attributes.label = coldmvc.string.propercase(arguments.attributes.name);
		}

		if (!structKeyExists(arguments.attributes, "value")) {
			arguments.attributes.value = "";
		}

		var element = formFactory.createElement(arguments.type, arguments.attributes);

		element.setForm(this);

		return element;

	}

	public boolean function hasElement(required string name) {

		return structKeyExists(variables.elementStruct, arguments.name);

	}

	public any function removeElement(required string name) {

		var i = "";
		for (i = 1; i <= arrayLen(variables.elements); i++) {
			if (variables.elements[i].getName() == arguments.name) {
				arrayDeleteAt(variables.elements, i);
				break;
			}
		}

		structDelete(variables.elementStruct, arguments.name);
		structDelete(this, arguments.name);

		return this;

	}

	public struct function getValues(string elements) {

        if (structKeyExists(arguments, "elements")) {
            arguments.elements = listToArray(arguments.elements);
        } else {
            arguments.elements = variables.elements;
        }  
        
		var values = {};
		var i = "";    
            
        for (i = 1; i <= arrayLen(arguments.elements); i++) {
                
            var element = getElement(arguments.elements[i]);

            if (!element.getIgnore()) {
                values[element.getName()] = element.getValue();
            }
        
        }

		return values;

	}

	public any function populate(required struct data) {

		var key = "";
		for (key in arguments.data) {

			if (hasElement(key)) {

				var element = getElement(key);

				if (!element.getIgnore()) {
					element.setValue(arguments.data[key]);
				}

			}

		}

		return this;

	}

	public any function validate(struct data) {

		if (structKeyExists(arguments, "data")) {
			populate(arguments.data);
		}

		var result = new coldmvc.validation.Result();
		var i = "";
		var j = "";

		for (i = 1; i <= arrayLen(variables.elements); i++) {

			var element = variables.elements[i];

			if (!element.getIgnore() && !element.isValid()) {

				var errors = element.getErrors();

				for (j = 1; j <= arrayLen(errors); j++) {
					var error = new coldmvc.validation.Error(element.getName(), errors[j]);
					result.addError(error);
				}
			}

		}

		return result;

	}

	public boolean function isValid() {

		var result = validate();

		return result.isValid();

	}

}
