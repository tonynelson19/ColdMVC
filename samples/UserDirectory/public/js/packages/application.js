/* coldmvc.js: /coldmvc/public/js/coldmvc.js */
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
		
		return (args.length >= position) ? args[position - 1] : def;		
	
	},
	
	listAppend: function(list, value) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
			
		return (list != '') ? list + delimiter + value : value;

	},
	
	listGetAt: function(list, position) {
		
		var delimiter = this.getArgument(arguments, 3, ',');
		
		var array = this.listToArray(list, delimiter);
		
		return array[position - 1];
		
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
				return i + 1;
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
				return i + 1;
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
		
		return (list != '') ? value + delimiter + list : value;

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
		
		$('#' + form + ' input, #' + form + ' select, #' + form + ' textarea').each(function() {
			
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

/* coldmvc.validation.js: /plugins/validation/public/js/coldmvc.validation.js */
ColdMVC.validation = {

	validators: {},
	
	getValidator: function(form){
	
		if (!ColdMVC.structKeyExists(this.validators, form)) {		
			var validator = new ColdMVC.validation.validator(form);
			this.validators[form] = validator;			
		}
		
		return this.validators[form];
		
	},
	
	rules: {

		NotEmpty: function(value) {
			return !this.optional(value);
		},
		
		Min: function(value, data) {
			return this.optional(value) || value.length >= data.value;
		},
		
		Max: function(value, data) {
			return this.optional(value) || value.length <= data.value;
		},
		
		Date: function(value) {
			return this.optional(value) || !/Invalid|NaN/.test(new Date(value));
		}

	},
	
	addRule: function(name, method) {
		
		if (!ColdMVC.structKeyExists(this.rules, name)) {
			this.rules[name] = method;
		}
	
	},
	
	optional: function(value) {
		return value == '';
	}

}

ColdMVC.validation.validator = function(form) {
	
	this.form = form;
	var instance = this;
	
	if ($('#'+form).length) {
		instance.init();
	}
	else {
		$(document).ready(function() {
			if ($('#' + form).length) {			
				instance.init();			
			}
		});
	}
	
	return this;
}

$.extend(ColdMVC.validation.validator.prototype, {
		
	errors: [],
	rules: [],
	functions: [],
	
	init: function() {

		var instance = this;
		var formObj = $('#'+this.form).get(0);		
		var fn = formObj.onsubmit;

		if (typeof(fn) == 'function') {
			this.addFunction(fn);
		}

		formObj.onsubmit = function() {
		
			instance.clearErrors();
			instance.validate();
			
			if (instance.hasErrors()) {
			
				var errors = instance.getErrors();
				var html = [];
				
				$.each(errors, function(i, error){
					html.push(error.message);
				});
				
				html = ColdMVC.arrayToList(html, '<br />');

				// make more dynamic
				if (!$('#validation').length) {
					$('#'+instance.form).before('<div id="validation"></div>');
				}
				
				$('#validation').html(html);
				
				return false;
				
			}
			
			return true;
			
		}

	},
	
	validate: function() {
		
		var data = this.getData();
		
		for (var i in this.rules) {
			
			var rule = this.rules[i];
			var value = '';
			
			if (ColdMVC.structKeyExists(data, rule.property)) {
				value = data[rule.property];
			}
			
			if (!rule.method(value, rule.data)) {
				this.addError(rule.property, rule.message);
			}
			
		}
		
		// loop over custom functions?
		
	},
	
	addError: function(property, message) {
		
		this.errors.push({
            property: property,
			message: message
        });
		
	},

	clearErrors: function() {
		this.errors = [];
	},

	hasErrors: function() {
		return this.errors.length > 0;
	},

	getErrors: function() {
		return this.errors;
	},		
	
	addRule: function(rule) {
		
		var defaults = {
			property: '',
			message: '',
			method: $.noop,
			data: {}
		}
		
		rule = $.extend(defaults, rule);
			
		this.rules.push(rule);		
	},
	
	addFunction: function(fn) {
		this.functions.push(fn);		
	},
	
	getData: function() {
		return ColdMVC.serializeForm('#'+this.form);
	}

});