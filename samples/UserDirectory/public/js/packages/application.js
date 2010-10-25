/* coldmvc.js: /coldmvc/public/js/coldmvc.js */
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

/* coldmvc.validation.js: /plugins/validation/public/js/coldmvc.validation.js */
ColdMVC.validation = {

	validators: {},
	
	getValidator: function(form){
	
		if (!(form in this.validators)) {		
			this.validators[form] = new ColdMVC.validation.validator(form, this);
		}
		
		return this.validators[form];
		
	},
	
	rules: {

		required: function(value) {
			return !ColdMVC.validation.optional(value);
		},
		
		min: function(value, data) {
			return ColdMVC.validation.optional(value) || value.length >= data.value;
		},
		
		max: function(value, data) {
			return ColdMVC.validation.optional(value) || value.length <= data.value;
		},
		
		date: function(value) {
			return ColdMVC.validation.optional(value) || !/Invalid|NaN/.test(new Date(value));
		}

	},
	
	hasRule: function(name) {
		return name in this.rules;
	},
	
	setRule: function(name, method) {				
		this.rules[name] = method;	
	},
	
	getRule: function(name) {
		return this.rules[name];
	},
	
	optional: function(value) {	
		return value == '';	
	}

}

ColdMVC.validation.validator = function(form, validation) {
	
	this.form = form;
	this.validation = validation;
	
	var instance = this;
	
	if ($('#' + form).length) {
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
		var formObj = $('#' + this.form).get(0);		
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
				if (!$('#validation_'+this.form).length) {
					$('#' + instance.form).before('<div id="validation_'+this.form+'" class="validation"></div>');
				}
				
				$('#validation_'+this.form).html(html);
				
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
			
			if (rule.property in data) {
				value = data[rule.property];
			}
			
			if (this.validation.hasRule(rule.rule)) {
			
				var method = this.validation.getRule(rule.rule);
				
				if (!method(value, rule.data)) {
					this.addError(rule.property, rule.message);
				}
				
			}
			
		}
		
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
			rule: $.noop,
			message: '',
			data: {}
		}
		
		rule = $.extend(defaults, rule);
		
		this.rules.push(rule);
	
	},
	
	addFunction: function(fn) {
		this.functions.push(fn);		
	},
	
	getData: function() {
		return ColdMVC.serializeForm('#' + this.form);
	}

});