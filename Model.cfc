/**
 * @accessors true
 * @extends coldmvc.Component
 */
component {

	property DAO;
	property createdOn;
	property createdBy;
	property updatedOn;
	property updatedBy;

	public any function add(required string to, required any object) {

		return DAO.add(this, arguments.to,  arguments.object);

	}

	public numeric function count() {

		return DAO.count(this);

	}

	public numeric function countWhere(required struct parameters) {

		return DAO.countWhere(this, arguments.parameters);

	}

	public void function delete(boolean flush="true") {

		DAO.delete(this, arguments.flush);

	}

	public boolean function exists(string id) {

		if (isNull(id)) {
			return DAO.exists(this);
		}

		return DAO.exists(this, id);

	}

	public array function findAll(required string query, struct parameters, struct options) {

		if (!structKeyExists(arguments, "parameters")) {
			 arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.findAll(this, arguments.query, arguments.parameters, arguments.options);

	}

	public any function findWhere(required struct parameters, struct options) {

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.findWhere(this, parameters, options);

	}

	public array function findAllWhere(required struct parameters, struct options) {

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.findAllWhere(this, parameters, options);

	}

	public any function _get(required string property) {

		var value = "";

		if (structKeyExists(this, "get#property#")) {
			value = evaluate("get#property#()");
		} else {

			if (right(property, 2) == "ID") {

				var relationship = left(property, len(property)-2);

				if (structKeyExists(this, "get#relationship#")) {

					var related = evaluate("get#relationship#()");

					if (!isNull(related)) {
						value = related.getID();
					}

				}

			}

		}

		if (isNull(value)) {
			value = "";
		}

		return value;

	}

	public any function get(required string id, any data) {

		var model = DAO.get(this, id);

		if (structKeyExists(arguments, "data")) {
			model.populate(data);
		}

		return model;

	}

	public array function getAll(required any ids, struct options) {

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.getAll(this, arguments.ids, arguments.options);

	}

	public boolean function has(required string property) {

		var value = _get(arguments.property);

		return coldmvc.data.count(value) > 0;

	}

	public array function list(struct options) {

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.list(this, arguments.options);

	}

	public any function new(any data, string properties="") {

		var model = DAO.new(this);

		if (structKeyExists(arguments, "data")) {
			model.populate(arguments.data, arguments.properties);
		}

		return model;

	}

	public any function populate(any data, string properties="") {

		return DAO.populate(this, data, properties);

	}

	public any function prop(required string property, any value) {

		if (structKeyExists(arguments, "value")) {

			_set(arguments.property, arguments.value);

			return this;

		} else {

			return _get(arguments.property);

		}

	}

	public any function save(boolean flush="true") {

		return DAO.save(this, arguments.flush);

	}

	public any function _set(required string property, any value) {

		if (structKeyExists(this, "set#property#")) {

			if (!structKeyExists(arguments, "value") || isNull(value) || (isSimpleValue(value) && value == "")) {
				evaluate("set#property#(javaCast('null', ''))");
			} else {
				evaluate("set#property#(value)");
			}

		}

		return this;

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		return DAO.missingMethod(this, arguments.missingMethodName, arguments.missingMethodArguments);

	}

}