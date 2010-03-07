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
		return DAO.add(this, to, object);
	}
	
	public numeric function count() {		
		return DAO.count(this);		
	}
	
	public void function delete(boolean flush="true") {
		DAO.delete(this, flush);
	}
	
	public boolean function exists(string id) {
		
		if (isNull(id)) {		
			return DAO.exists(this);
		}
		
		return DAO.exists(this, id);
	
	}
	
	public array function findAll(required string query, struct filters, struct options) {
		
		if (isNull(filters)) {
			filters = {};
		}
		
		if (isNull(options)) {
			options = {};
		}
		
		return DAO.findAll(this, query, filters, options);

	}
	
	public array function findAllWhere(required struct parameters, struct options) {
	
		if (isNull(options)) {
			options = {};
		}
		
		return DAO.findAllWhere(this, parameters, options);
	
	}
	
	public any function _get(required string property) {
		
		var value = "";
		
		if (structKeyExists(this, "get#property#")) {
			value = evaluate("get#property#()");
		}
		else {
			
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
	
	public any function getAll(required string ids) {
		return DAO.getAll(this, ids);
	}
	
	public boolean function has(required string property) {
		
		var value = _get(property);
		
		return $.data.count(value) > 0;
		
	}
	
	public array function list(struct options) {
		
		if (isNull(options)) {
			arguments.options = {};
		}
		
		return DAO.list(this, arguments.options);

	}
	
	public any function new(any data) {
		
		var model = DAO.new(this);
		
		var relationships = $.model.relationships(model);
		
		var i = "";
		
		for (i in relationships) {
			model._set(relationships[i].property, []);
		}
		
		if (structKeyExists(arguments, "data")) {
			model.populate(data);
		}
		
		return model;
		
	}
	
	public any function populate(any data, string properties="") {
		return DAO.populate(this, data, properties);
	}
	
	public any function save(boolean flush="true") {
		return DAO.save(this, flush);
	}
	
	public any function _set(required string property, any value) {
		
		if (structKeyExists(this, "set#property#")) {
		
			if (!structKeyExists(arguments, "value") or isNull(value) or (isSimpleValue(value) and value eq "")) {
				evaluate("set#property#(javacast('NULL', ''))");
			}
			else {
				evaluate("set#property#(value)");
			}
			
		}
		
		return this;
		
	}
	
	public any function onMissingMethod(string missingMethodName, struct missingMethodArguments) {		
		return DAO.missingMethod(this, missingMethodName, missingMethodArguments);	
	}

}