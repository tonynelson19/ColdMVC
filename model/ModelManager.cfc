/**
 * @accessors true
 */
component {

	property coldmvc;
	property modelFactory;
	property metaDataFlattener;

	public any function init() {

		variables.cache = {};

		var settings = application.getApplicationSettings();
		variables.ormEnabled = settings.ormEnabled;

		if (variables.ormEnabled) {

			try {
				ormGetSessionFactory();
			}
			catch(any e) {
				// No entity using this datasource.
				variables.ormEnabled = false;
			}

		}

		return this;

	}

	private string function convertJavaType(required string type) {

		if (arguments.type == "integer") {
			return "int";
		}

		return type;

	}

	public struct function getModel(required any model) {

		var name = getName(arguments.model);

		if (!structKeyExists(variables.cache, name)) {

			var i = "";
			var j = "";

			if (!isObject(arguments.model)) {
				arguments.model = modelFactory.getModel(name);
			}

			var metaData = metaDataFlattener.flattenMetaData(arguments.model);
			var classMetaData = ormGetSessionFactory().getClassMetaData(name);

			var result = {};
			result.name = classMetaData.getEntityName();
			result.alias = coldmvc.string.camelize(result.name);
			result.table = classMetaData.getTableName();
			result.path = metaData.path;
			result.class = metaData.fullName;
			result.properties = {};
			result.relationships = {};
			result.propertyNames = [];
			result.id = classMetaData.getIdentifierPropertyName();
			result.sort = structKeyExists(metaData, "sort") ? metaData.sort : "";
			result.order = structKeyExists(metaData, "order") ? metaData.order : "";

			var propertyTypes = classMetaData.getPropertyTypes();

			var property = {
				name = result.id,
				column = classMetaData.getPropertyColumnNames(result.id)[1],
				type = classMetaData.getIdentifierType().getName(),
				relationship = {}
			};

			property.javatype = convertJavaType(property.type);

			result.properties[property.name] = property;

			arrayAppend(result.propertyNames, property.name);

			var propertyNames = classMetaData.getPropertyNames();

			for (i = 1; i <= arrayLen(propertyNames); i++) {

				property = {
					name = propertyNames[i],
					type = propertyTypes[i].getName(),
					relationship = {}
				};

				var columns = classMetaData.getPropertyColumnNames(propertyNames[i]);

				// hack to support computed properties that don't have columns
				try {property.column = columns[1];
				}
				catch (any e) {
					property.column = "";
				}

				property.javatype = convertJavaType(property.type);

				result.properties[property.name] = property;

				arrayAppend(result.propertyNames, property.name);

			}

			for (i = 1; i <= arrayLen(propertyTypes); i++) {

				if (propertyTypes[i].isAssociationType()) {

					var relationship = {};
					relationship.name = propertyNames[i];
					relationship.property = relationship.name;

					if (propertyTypes[i].isCollectionType()) {

						var relationshipMetaData = ormGetSessionFactory().getCollectionMetaData(propertyTypes[i].getRole());

						relationship.entity = relationshipMetaData.getCollectionType().getAssociatedEntityName(ormGetSessionFactory());

						if (relationshipMetaData.isManyToMany()) {
							relationship.type = "ManyToMany";
						} else if (relationshipMetaData.isOneToMany()) {
							relationship.type = "OneToMany";
						} else {
							relationship.type = "";
						}

					} else {

						var relationshipMetaData = ormGetSessionFactory().getClassMetaData(propertyTypes[i].getName());

						relationship.entity = relationshipMetaData.getEntityName();

						if (propertyTypes[i].isOneToOne()) {
							relationship.type = "OneToOne";
						} else {
							relationship.type = "ManyToOne";
						}

					}

					relationship.table = relationshipMetaData.getTableName();
					relationship.param = coldmvc.string.camelize(relationship.entity) & "ID";

					if (structKeyExists(result.properties, relationship.property)) {

						result.properties[relationship.property].relationship = relationship;

					} else {

						for (j in result.properties) {

							var property = result.properties[j];

							// do this in case you're joining on the same entity multiple times with different properties
							if (property.type == relationship.name) {

								var name = coldmvc.string.pascalize(property.name);

								if (!structKeyExists(result.relationships, name)) {

									relationship.name = name;
									relationship.param = property.name & "ID";
									relationship.property = property.name;

									property.relationship = relationship;

									break;

								}

							}

						}

					}

					result.relationships[relationship.name] = relationship;

				}

			}

			variables.cache[name] = result;

		}

		return variables.cache[name];

	}

	public struct function getModels() {

		var i = "";

		if (!structKeyExists(variables, "models")) {

			var models = {};

			if (variables.ormEnabled) {

				var classes = ormGetSessionFactory().getAllClassMetadata();

				for (i in classes) {
					models[i] = {
						name = i,
						metaData = classes[i],
						model = modelFactory.getModel(i)
					};
				}

			}

			variables.models = models;

		}

		return variables.models;

	}

	public string function getAlias(required any model) {

		return coldmvc.string.camelize(getName(arguments.model));

	}

	public string function getClass(required any model) {

		return getModel(arguments.model).class;

	}

	public string function getClassName(required any model) {

		var className = arguments.model;

		if (isObject(arguments.model)) {
			className = getMetaData(arguments.model).fullname;
		}

		return listLast(className, ".");

	}

	public string function getID(required any model) {

		return getModel(arguments.model).id;

	}

	public string function getName(required any model) {

		var models = getModels();

		if (isSimpleValue(arguments.model)) {
			if (structKeyExists(models, arguments.model)) {
				return models[arguments.model].name;
			}
		}

		var className = getClassName(arguments.model);

		if (structKeyExists(models, className)) {
			return models[className].name;
		}

		return "";

	}

	public string function getSort(required any model) {

		return getModel(arguments.model).sort;

	}

	public string function getOrder(required any model) {

		return getModel(arguments.model).order;

	}

	public string function getJavaType(required any model, required string property) {

		var properties = getProperties(arguments.model);

		return properties[arguments.property].javatype;

	}

	public struct function getProperties(required any model) {

		return getModel(arguments.model).properties;

	}

	public array function getPropertyNames(required any model) {

		return getModel(arguments.model).propertyNames;

	}

	public struct function getRelationships(required any model) {

		return getModel(arguments.model).relationships;

	}

	public string function getProperty(required any model, required string property) {

		var properties = getProperties(arguments.model);

		return properties[arguments.property].name;

	}

	public boolean function hasProperty(required any model, required string property) {

		var properties = getProperties(arguments.model);

		return structKeyExists(properties, arguments.property);

	}

	public boolean function modelExists(required any model) {

		var name = getName(arguments.model);
		var models = getModels();

		return structKeyExists(models, name);

	}

}