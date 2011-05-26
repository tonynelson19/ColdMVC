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

	public numeric function count() {

		return DAO.count(this);

	}

	public numeric function countWhere(required struct parameters) {

		return DAO.countWhere(this, arguments.parameters);

	}

	public any function createQuery() {

		return DAO.createQuery(this);

	}

	public void function delete(boolean flush="true") {

		DAO.delete(this, arguments.flush);

	}

	public boolean function exists(string id) {

		if (isNull(arguments.id)) {
			return DAO.exists(this);
		}

		return DAO.exists(this, arguments.id);

	}

	public any function find(required string query, struct parameters, struct options) {

		if (!structKeyExists(arguments, "parameters")) {
			 arguments.parameters = {};
		}

		if (!structKeyExists(arguments, "options")) {
			 arguments.options = {};
		}

		return DAO.find(this, arguments.query, arguments.parameters, arguments.options);

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

	public any function populate(required struct data, string properties="") {

		return DAO.populate(this, arguments.data, arguments.properties);

	}

	public any function prop(required string property, any value) {

		if (structKeyExists(arguments, "value")) {
			return DAO.setProperty(this, arguments.property, arguments.value);
		} else {
			return DAO.getProperty(this, arguments.property);
		}

	}

	public any function save(boolean flush="true") {

		return DAO.save(this, arguments.flush);

	}

	public any function onMissingMethod(required string missingMethodName, required struct missingMethodArguments) {

		return DAO.missingMethod(this, arguments.missingMethodName, arguments.missingMethodArguments);

	}

}