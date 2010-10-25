ColdMVC = {
	
	arrayToList: function(array) {
		
		var delimiter = this.getArgument(arguments, 2, ',');		
		
		return array.join(delimiter);
		
	},
	
	getArgument: function(args, position, def) {		
		
		return (args.length >= position) ? args[position - 1] : def;		
	
	},
	
	listAppend: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
			
		return (list != '') ? list + delimiter + value : value;

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
		
	}
	
}