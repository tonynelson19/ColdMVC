/**
 * @extends coldmvc.Helper
 */
component {

	public any function init() {
		cache = {};
		return this;
	}

	public boolean function enabled() {

		var settings = application.getApplicationSettings();

		return settings.ormEnabled;
	}

	public string function getClassName(required any data) {

		var className = data;

		if (isObject(data)) {
			className = getMetaData(data).fullname;
		}

		return listLast(className, ".");
	}

	public struct function getEntities() {

		var i = "";

		if (!structKeyExists(variables, "entities")) {

			var entities = {};

			if (enabled()) {

				var classes = ormGetSessionFactory().getAllClassMetadata();

				for (i in classes) {
					entities[i] = {
						name = i,
						metaData = classes[i]
					};
				}

			}

			variables.entities = entities;

		}

		return variables.entities;
	}

	public any function getEntityMetaData(required any data) {

		var entityName = getEntityName(data);

		if (!structKeyExists(cache, entityName)) {

			var i = "";
			var j = "";

			if (isObject(data)) {
				var metaData = getMetaData(data);
			}
			else {
				var metaData = getComponentMetaData(data);
			}

			var classMetaData = ormGetSessionFactory().getClassMetaData(entityName);

			var entityMetaData = {};
			entityMetaData.name = classMetaData.getEntityName();
			entityMetaData.alias = $.string.camelize(entityMetaData.name);
			entityMetaData.table = classMetaData.getTableName();
			entityMetaData.path = metaData.path;
			entityMetaData.class = metaData.fullName;
			entityMetaData.properties = {};
			entityMetaData.relationships = {};
			entityMetaData.propertyNames = [];
			entityMetaData.identifier = classMetaData.getIdentifierPropertyName();

			var propertyTypes = classMetaData.getPropertyTypes();

			var property = {
				name = entityMetaData.identifier,
				column = classMetaData.getPropertyColumnNames(entityMetaData.identifier)[1],
				type = classMetaData.getIdentifierType().getName(),
				relationship = {}
			};

			property.javatype = getJavaType(property.type);

			entityMetaData.properties[property.name] = property;

			arrayAppend(entityMetaData.propertyNames, property.name);

			var propertyNames = classMetaData.getPropertyNames();

			for (i = 1; i <= arrayLen(propertyNames); i++) {

				property = {
					name = propertyNames[i],
					column = classMetaData.getPropertyColumnNames(propertyNames[i])[1],
					type = propertyTypes[i].getName(),
					relationship = {}
				};

				property.javatype = getJavaType(property.type);

				entityMetaData.properties[property.name] = property;

				arrayAppend(entityMetaData.propertyNames, property.name);
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
						relationship.param = $.string.camelize(relationship.entity) & "ID";

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
						relationship.property = $.string.camelize(relationship.entity);
						relationship.param = relationship.property & "ID";
						relationship.type = "ManyToOne";

					}

					if (structKeyExists(entityMetaData.properties, relationship.property)) {
						entityMetaData.properties[relationship.property].relationship = relationship;
					}
					else {
						for (j in entityMetaData.properties) {
							if (entityMetaData.properties[j].type == relationship.name) {
								entityMetaData.properties[j].relationship = relationship;
								break;
							}
						}
					}

					entityMetaData.relationships[relationship.name] = relationship;

				}

			}

			cache[entityName] = entityMetaData;

		}

		return cache[entityName];
	}

	public string function getEntityName(required any data) {

		var entities = getEntities();

		if (isSimpleValue(data)) {
			if (structKeyExists(entities, data)) {
				return entities[data].name;
			}
		}

		var className = getClassName(data);

		if (structKeyExists(entities, className)) {
			return entities[className].name;
		}

		return "";

	}

	public string function getIdentifier(required any data) {

		var entityName = getEntityName(data);

		return ormGetSessionFactory().getClassMetaData(entityName).getIdentifierPropertyName();

	}

	private string function getJavaType(required string type) {

		if (type == "integer") {
			return "int";
		}

		return type;

	}

	public array function getPropertyNames(required any data) {
		return getEntityMetaData(data).propertyNames;
	}

	public struct function getProperties(required any data) {
		return getEntityMetaData(data).properties;
	}

	public struct function getRelationships(required any data) {
		return getEntityMetaData(data).relationships;
	}

	public boolean function hasProperty(required any data, required string property) {

		var properties = getProperties(data);

		return structKeyExists(properties, property);

	}

	public boolean function isEntity(required any data) {

		var className = getClassName(data);

		var entities = getEntities();

		return structKeyExists(entities, className);

	}

}