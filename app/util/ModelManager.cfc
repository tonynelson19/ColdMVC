/**
 * @accessors true
 */
component {

	property modelFactory;

	public any function init() {

		cache = {};

		var settings = application.getApplicationSettings();
		ormEnabled = settings.ormEnabled;

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
					column = classMetaData.getPropertyColumnNames(propertyNames[i])[1],
					type = propertyTypes[i].getName(),
					relationship = {}
				};

				property.javatype = convertJavaType(property.type);

				result.properties[property.name] = property;

				arrayAppend(result.propertyNames, property.name);

			}

			for (i = 1; i <= arrayLen(propertyTypes); i++) {

				if (propertyTypes[i].isAssociationType()) {

					var relationship = {};

					if (propertyTypes[i].isCollectionType()) {

						var collectionMetaData = ormGetSessionFactory().getCollectionMetaData(propertyTypes[i].getRole());

						relationship.name = propertyTypes[i].getRole();
						relationship.entity = collectionMetaData.getCollectionType().getAssociatedEntityName(ormGetSessionFactory());
						relationship.table = collectionMetaData.getTableName();
						relationship.property = listLast(relationship.name, ".");
						relationship.param = coldmvc.string.camelize(relationship.entity) & "ID";

						if (collectionMetaData.isManyToMany()) {
							relationship.type = "ManyToMany";
						}
						else if (collectionMetaData.isOneToMany()) {
							relationship.type = "OneToMany";
						}
						else {
							relationship.type = "";
						}

					}
					else {

						relationship.name = propertyTypes[i].getName();

						var associationMetaData = ormGetSessionFactory().getClassMetaData(relationship.name);

						relationship.entity = associationMetaData.getEntityName();
						relationship.table = associationMetaData.getTableName();
						relationship.property = coldmvc.string.camelize(relationship.entity);
						relationship.param = relationship.property & "ID";
						relationship.type = "ManyToOne";

					}

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