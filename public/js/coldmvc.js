ColdMVC = {
	
	arrayToList: function(array) {
		
		var delimiter = this.getArgument(arguments, 2, ',');		
		var list = '';
		
		for (var i in array) {
			list = this.listAppend(list, array[i], delimiter);
		}
		
		return list;
		
	},
	
	getArgument: function(args, position, def) {		
		
		return (args.length == position) ? args[position-1] : def;		
	
	},
	
	listAppend: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
	
		if (list != '') {
			return list+delimiter+value;
		}
		else {
			return value;
		}

	},
	
	listFindNoCase: function(list, value) {
		
		value = value.toLowerCase();
		var delimiter = this.getArgument(arguments, 3, ',');
		var array = this.listToArray(list, delimiter);
		
		for (var i in array) {
			
			if (array[i].toLowerCase() == value) {
				return true;
			}
	
		}

		return false;
		
	},
	
	listToArray: function(list) {
		
		var delimiter = this.getArgument(arguments, 2, ',');		
		
		return list.split(delimiter);
		
	},
	
	serializeForm: function(form) {
		
		var array = $(form).serializeArray();		
		var data = {};
		
		for (var i in array) {
			
			var field = array[i];
			var value = $.trim(field.value);
			
			if (this.structKeyExists(data, field.name)) {
				data[field.name] = this.listAppend(data[field.name], value);
			}
			else {
				data[field.name] = value;
			}

		}
		
		return data;
		
	},
	
	structKeyList: function(struct) {
		
		var delimiter = this.getArgument(arguments, 2, ',');		
		var list = '';
		
		for (var i in struct) {
			list = this.listAppend(list, i, delimiter);
		}
		
		return list;
		
	},
	
	structKeyExists: function(struct, key) {
		
		return key in struct;

	}

}