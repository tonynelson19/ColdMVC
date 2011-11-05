component {

	public boolean function array(required any value) {

		return isArray(arguments.value);

	}

	public boolean function binary(required any value) {

		return isBinary(arguments.value);

	}

	public boolean function boolean(required any value) {

		return isBoolean(arguments.value);

	}

	public boolean function creditCard(required any value) {

		return isValid("creditCard", arguments.value);

	}

	public boolean function date(required any value) {

		return isDate(arguments.value);

	}

	public boolean function email(required any value) {

		return isValid("email", arguments.value);

	}

	public boolean function guid(required any value) {

		return isValid("guid", arguments.value);

	}

	public boolean function instanceOf(required any value, required string type) {

		return isInstanceOf(arguments.value, arguments.type);

	}

	public boolean function integer(required any value) {

		return isNumeric(arguments.value) && arguments.value == round(arguments.value);

	}

	public boolean function json(required any value) {

		return isJSON(arguments.value);

	}

	public boolean function max(required any value, required numeric max) {

		return isNumeric(arguments.value) && arguments.value <= arguments.max;

	}

	public boolean function min(required any value, required numeric min) {

		return isNumeric(arguments.value) && arguments.value >= arguments.min;

	}

	public boolean function numeric(required any value) {

		return isNumeric(arguments.value);

	}

	public boolean function object(required any value) {

		return isObject(arguments.value);

	}

	public boolean function query(required any value) {

		return isQuery(arguments.value);

	}

	public boolean function range(required any value, required numeric min, required numeric max) {

		return isNumeric(arguments.value) && arguments.value >= arguments.min && arguments.value <= arguments.max;

	}

	public boolean function regex(required any value, required string pattern) {

		return isValid("regex", arguments.value, arguments.pattern);

	}

	public boolean function size(required any value, required numeric min, required numeric max) {

		return range(coldmvc.data.count(arguments.value), arguments.min, arguments.max);

	}

	public boolean function ssn(required any value) {

		return isValid("ssn", arguments.value);

	}

	public boolean function string(required any value) {

		return isSimpleValue(arguments.value);

	}

	public boolean function struct(required any value) {

		return isStruct(arguments.value);

	}

	public boolean function phone(required any value) {

		return isValid("telephone", arguments.value);

	}

	public boolean function url(required any value) {

		return isValid("url", arguments.value);

	}

	public boolean function xml(required any value) {

		return isXML(arguments.value);

	}

	public boolean function zipCode(required any value) {

		return isValid("zipCode", arguments.value);

	}

}