/**
 * @accessors true
 */
component {

	property modelFactory;

	public any function init() {

		cache = {};

		var settings = application.getApplicationSettings();
		ormEnabled = settings.ormEnabled;

		if (ormEnabled) {

			try {
				ormGetSessionFactory();
			}
			catch(any e) {
				// No entity using this datasource.
				ormEnabled = false;
			}

		}

		return this;

	}

	private string function convertJavaType(required string type) {

		if (type == "integer") {
			return "int";
		}

		return type;

	}

	public struct function getModel(required any model) {

		var name = getName(model);

		if (!structKeyExists(cache, name)) {

			var i = "";
			var j = "";

			if (!isObject(model)) {
				model = modelFactory.get(name);
			}

			var metaData = getMetaData(model);
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
						}
						else if (relationshipMetaData.isOneToMany()) {
							relationship.type = "OneToMany";
						}
						else {
							relationship.type = "";
						}

					}
					else {

						var relationshipMetaData = ormGetSessionFactory().getClassMetaData(propertyTypes[i].getName());

						relationship.entity = relationshipMetaData.getEntityName();
						relationship.type = "ManyToOne";

					}

					relationship.table = relationshipMetaData.getTableName();
					relationship.param = coldmvc.string.camelize(relationship.entity) & "ID";

					if (structKeyExists(result.properties, relationship.property)) {

						result.properties[relationship.property].relationship = relationship;

					}
					else {

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

			cache[name] = result;

		}

		return cache[name];

	}

	public struct function getModels() {

		var i = "";

		if (!structKeyExists(variables, "models")) {

			var models = {};

			if (ormEnabled) {

				var classes = ormGetSessionFactory().getAllClassMetadata();

				for (i in classes) {
					models[i] = {
						name = i,
						metaData = classes[i],
						model = modelFactory.get(i)
					};
				}

			}

			variables.models = models;

		}

		return variables.models;

	}

	public string function getAlias(required any model) {

		return coldmvc.string.camelize(getName(model));

	}

	public string function getClass(required any model) {

		return getModel(model).class;

	}

	public string function getClassName(required any model) {

		var className = model;

		if (isObject(model)) {
			className = getMetaData(model).fullname;
		}

		return listLast(className, ".");

	}

	public string function getID(required any model) {

		return getModel(model).id;

	}

	public string function getName(required any model) {

		var models = getModels();

		if (isSimpleValue(model)) {
			if (structKeyExists(models, model)) {
				return models[model].name;
			}
		}

		var className = getClassName(model);

		if (structKeyExists(models, className)) {
			return models[className].name;
		}

		return "";

	}

	public string function getJavaType(required any model, required string property) {

		var properties = getProperties(model);

		return properties[property].javatype;

	}

	public struct function getProperties(required any model) {

		return getModel(model).properties;

	}

	public struct function getRelationships(required any model) {

		return getModel(model).relationships;

	}

	public string function getProperty(required any model, required string property) {

		var properties = getProperties(model);

		return properties[property].name;

	}

	public boolean function hasProperty(required any model, required string property) {

		var properties = getProperties(model);

		return structKeyExists(properties, property);

	}

	public boolean function modelExists(required any model) {

		var name = getName(model);
		var models = getModels();

		return structKeyExists(models, name);

	}

}