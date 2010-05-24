ColdMVC = {
	
	arrayAppend: function(array, value) {
		
		return array.push(value);		
	
	},
	
	arrayLen: function(array) {
		
		return array.length;
		
	},
		
	arrayPrepend: function(array, value) {
		
		return array.unshift(value);		
	
	},
	
	arrayToList: function(array) {
		
		var delimiter = this.getArgument(arguments, 2, ',');		
		
		return array.join(delimiter);
		
	},
	
	getArgument: function(args, position, def) {		
		
		return (args.length >= position) ? args[position-1] : def;		
	
	},
	
	listAppend: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
			
		return (list != '') ? list+delimiter+value : value;

	},
	
	listGetAt: function(list, position) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
		
		var array = this.listToArray(list, delimiter);
		
		return array[position-1];
		
	},
	
	listLen: function(list) {
		
		if (list == '') {
			return 0;
		}
		
		var delimiter = this.getArgument(arguments, 3, ',');
		var array = this.listToArray(list, delimiter);
		return array.length;

	},
	
	listFind: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
		var array = this.listToArray(list, delimiter);
		
		for (var i in array) {
			
			if (array[i] == value) {
				return i+1;
			}
	
		}

		return 0;
		
	},
	
	listFindNoCase: function(list, value) {
		
		value = value.toLowerCase();
		var delimiter = this.getArgument(arguments, 3, ',');
		var array = this.listToArray(list, delimiter);
		
		for (var i in array) {
			
			if (array[i].toLowerCase() == value) {
				return i+1;
			}
	
		}

		return 0;
		
	},
	
	listFirst: function(list) {
		
		var delimiter = this.getArgument(arguments, 2, ',');
			
		var array = this.listToArray(list, delimiter);
		
		return (array.length > 0) ? array[0] : '';
		
	},
	
	listPrepend: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
		
		return (list != '') ? value+delimiter+list : value;

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
			
			if (field.name in data) {
				data[field.name] = this.listAppend(data[field.name], value);
			}
			else {
				data[field.name] = value;
			}

		}
		
		return data;
		
	},
	
	getFormElementTypes: function(form) {
		
		var elements = {};
		
		$('#'+form+' input, #'+form+' select, #'+form+' textarea').each(function() {
			
			if (this.name != '') {
			
				var name = this.name;
				var type = ColdMVC.listFirst(this.type.toLowerCase(), '-');
				
				if (name in elements) {
					if (!ColdMVC.listFind(elements[name], type)) {
						elements[name] = ColdMVC.listAppend(elements[name], type);
					}
				}
				else {
					elements[name] = type;
				}
				
			}
		
		});
		
		return elements;
		
	},
	
	getFormElementType: function(form, name) {
		
		var elements = this.getFormElementTypes(form);
		
		return elements[name];
		
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