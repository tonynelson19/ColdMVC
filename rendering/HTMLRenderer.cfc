<cfcomponent>

	<!------>

	<cffunction name="init" access="public" output="false" returntype="any">

		<!--- to add to this list, use setAllowBinding("mytag") --->
		<cfset variables.allowBinding = {
			checkbox = true,
			color = true,
			date = true,
			email = true,
			hidden = true,
			input = true,
			number = true,
			password = true,
			phone = true,
			radio = true,
			range = true,
			search = true,
			select = true,
			text = true,
			textarea = true,
			time = true,
			upload = true,
			url = true
		} />

		<cfset variables.options = {
			button = {
				class = "button",
				display = true,
				tag = "span"
			},
			buttons = {
				class = "buttons",
				tag = "div"
			},
			checkbox = {
				class = "",
				tag = "ul"
			},
			description = {
				class = "description",
				display = true,
				tag = "div"
			},
			errors = {
				class = "errors"
			},
			field = {
				class = "field",
				display = true,
				tag = "div"
			},
			flash = {
				class = "flash",
				tag = "div"
			},
			form = {
				class = "",
				enctype = "multipart/form-data"
			},
			instructions = {
				class = "instructions",
				display = true,
				tag = "div"
			},
			label = {
				class = "label",
				display = true,
				suffix = ":",
				tag = "div"
			},
			radio = {
				class = "",
				tag = "ul"
			},
			required = {
				class = "required",
				content = "*",
				display = true,
				placement = "after",
				separator = "",
				tag = "span"
			},
			submit = {
				class = ""
			},
			table = {
				class = "list"
			},
			text = {
				class = "",
				tag = "div"
			},
			wrapper = {
				class = "wrapper",
				display = true,
				tag = "div"
			}
		} />

		<cfreturn this />

	</cffunction>

	<!------>

	<cffunction name="setOptions" access="public" output="false" returntype="any">
		<cfargument name="options" required="true" type="struct" />

		<cfset var key = "" />

		<cfloop collection="#arguments.options#" item="key">

			<cfif not structKeyExists(variables.options, key)>
				<cfset variables.options[key] = {} />
			</cfif>

			<cfset structAppend(variables.options[key], arguments.options[key], true) />

		</cfloop>

		<cfreturn this />

	</cffunction>

	<!------>

	<cffunction name="getOption" access="public" output="false" returntype="any">
		<cfargument name="name" required="true" type="string" />
		<cfargument name="key" required="true" type="string" />

		<cfreturn variables.options[arguments.name][arguments.key] />

	</cffunction>

	<!------>

	<cffunction name="append" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="attribute" required="true" type="string" />
		<cfargument name="value" required="true" type="string" />

		<cfif arguments.value neq "">

			<cfif structKeyExists(arguments.args, arguments.attribute)>
				<cfset arguments.args[arguments.attribute] = arguments.args[arguments.attribute] & " " & arguments.value />
			<cfelse>
				<cfset arguments.args[arguments.attribute] = arguments.value />
			</cfif>

		</cfif>

	</cffunction>

	<!------>

	<cffunction name="configure" access="public" output="false" returntype="struct">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="commonKeys" required="false" default="" type="string" />

		<cfif structKeyExists(arguments.args, "_processed")>
			<cfreturn arguments.args />
		</cfif>

		<cfset var i = "" />
		<cfset var key = "" />

		<cfset arguments.args._processed = true />

		<cfset arguments.args.tag = getKey(arguments.args, "tag") />
		<cfset arguments.args.allowBinding = getAllowBinding(arguments.args) />
		<cfset arguments.args.binding = getKey(arguments.args, "binding", arguments.args.allowBinding) />
		<cfset arguments.args.bind = getKey(arguments.args, "bind") />
		<cfset arguments.args.name = getKey(arguments.args, "name") />
		<cfset arguments.args.originalName = arguments.args.name />
		<cfset arguments.args.label = getLabel(arguments.args) />
		<cfset arguments.args.value = getValue(arguments.args) />
		<cfset arguments.args.name = getName(arguments.args) />
		<cfset arguments.args.id = getID(arguments.args) />
		<cfset arguments.args.title = getKey(arguments.args, "title", arguments.args.label) />
		<cfset arguments.args.alt = getKey(arguments.args, "alt", arguments.args.label) />
		<cfset arguments.args.escape = getKey(arguments.args, "escape", true) />
		<cfset arguments.args.wrapper = getKey(arguments.args, "wrapper", true) />
		<cfset arguments.args.readonly = getKey(arguments.args, "readonly", false) />
		<cfset arguments.args.disabled = getKey(arguments.args, "disabled", false) />
		<cfset arguments.args.visible = getKey(arguments.args, "visible", true) />
		<cfset arguments.args.required = getKey(arguments.args, "required", false) />
		<cfset arguments.args.autofocus = getKey(arguments.args, "autofocus", false) />

		<cfloop list="class,style,description,instructions,placeholder,autocomplete,#arguments.commonKeys#" index="i">
			<cfset arguments.args[i] = getKey(arguments.args, i) />
		</cfloop>

		<cfset arguments.args.common = [] />

		<!--- check for common attributes --->
		<cfloop list="name,id,title,class,placeholder,autocomplete,#arguments.commonKeys#" index="i">
			<cfif arguments.args[i] neq "">
				<cfset arrayAppend(arguments.args.common, '#i#="#htmlEditFormat(arguments.args[i])#"') />
			</cfif>
		</cfloop>

		<!--- check for boolean-only attributes --->
		<cfloop list="required,autofocus" index="i">
			<cfif isBoolean(arguments.args[i]) && arguments.args[i]>
				<cfset arrayAppend(arguments.args.common, i) />
			</cfif>
		</cfloop>

		<!--- store events outside of common for use w/ radios and checkboxes --->
		<cfset arguments.args.events = [] />

		<!--- check for data attributes --->
		<cfloop collection="#arguments.args#" item="key">
			<cfif left(key, 5) eq "data-" and arguments.args[key] neq "">
				<cfset arrayAppend(arguments.args.common, '#lcase(key)#="#htmlEditFormat(arguments.args[key])#"') />
			<cfelseif left(key, 2) eq "on" and arguments.args[key] neq "">
				<cfset arrayAppend(arguments.args.events, '#lcase(key)#="#arguments.args[key]#"') />
				<cfset arrayAppend(arguments.args.common, '#lcase(key)#="#arguments.args[key]#"') />
			</cfif>
		</cfloop>

		<!--- check for boolean attributes --->
		<cfloop list="readonly,disabled" index="i">
			<cfif arguments.args[i] eq "true">
				<cfset arrayAppend(arguments.args.common, '#i#="#htmlEditFormat(arguments.args[i])#"') />
			</cfif>
		</cfloop>

		<!--- check for numeric values --->
		<cfloop list="size,maxlength,rows,cols" index="i">
			<cfset var value = getKey(arguments.args, i) />
			<cfif isNumeric(value)>
				<cfset arrayAppend(arguments.args.common, '#i#="#value#"') />
			</cfif>
		</cfloop>

		<cfset arguments.args.common = arrayToList(arguments.args.common, " ") />
		<cfset arguments.args.events = arrayToList(arguments.args.events, " ") />

		<cfreturn arguments.args />

	</cffunction>

	<!------>

	<cffunction name="configureOptions" access="public" output="false" returntype="struct">
		<cfargument name="args" required="true" type="struct" />

		<cfset var array = [] />
		<cfset var option = "" />
		<cfset var i = "" />
		<cfset var requestContext = getRequestContext() />

		<cfif not structKeyExists(arguments.args, "options")>

			<cfif structKeyExists(arguments.args, "optionValues")>

				<cfif not structKeyExists(arguments.args, "optionKeys")>
					<cfset arguments.args.optionKeys = arguments.args.optionValues />
				</cfif>

				<cfif not structKeyExists(arguments.args, "optionTitles")>
					<cfset arguments.args.optionTitles = arguments.args.optionValues />
				</cfif>

				<cfset arguments.args.options = [] />

				<cfif not isArray(arguments.args.optionKeys)>
					<cfset arguments.args.optionKeys = listToArray(arguments.args.optionKeys) />
				</cfif>

				<cfif not isArray(arguments.args.optionValues)>
					<cfset arguments.args.optionValues = listToArray(arguments.args.optionValues) />
				</cfif>

				<cfif not isArray(arguments.args.optionTitles)>
					<cfset arguments.args.optionTitles = listToArray(arguments.args.optionTitles) />
				</cfif>

				<cfloop from="1" to="#arrayLen(arguments.args.optionKeys)#" index="i">

					<cfset var option = {
						id = arguments.args.optionKeys[i],
						name = arguments.args.optionValues[i],
						title = arguments.args.optionTitles[i]
					} />

					<cfset arrayAppend(arguments.args.options, option) />

				</cfloop>

			<cfelse>

				<!--- look for the plural version first in case you're working with a dropdown filter --->
				<!--- for example, params.status should not affect params.statuses from appearing in the select --->
				<cfset var pluralized = coldmvc.string.pluralize(arguments.args.originalName) />

				<cfif requestContext.hasParam(pluralized)>
					<cfset arguments.args.options = requestContext.getParam(pluralized) />
				<cfelseif requestContext.hasParam(arguments.args.originalName)>
					<cfset arguments.args.options = requestContext.getParam(arguments.args.originalName) />
				<cfelse>
					<cfset arguments.args.options = "" />
				</cfif>

			</cfif>

		</cfif>

		<cfif not structKeyExists(arguments.args, "optionKey")>
			<cfset arguments.args.optionKey = "id" />
		</cfif>

		<cfif not structKeyExists(arguments.args, "optionValue")>
			<cfset arguments.args.optionValue = "name" />
		</cfif>

		<cfif not structKeyExists(arguments.args, "optionTitle")>
			<cfset arguments.args.optionTitle = arguments.args.optionValue />
		</cfif>

		<!--- if it's a list, convert it to an array --->
		<cfif isSimpleValue(arguments.args.options)>

			<cfloop list="#arguments.args.options#" index="i">

				<cfset var option = {
					id = trim(i),
					name = trim(i),
					title = trim(i)
				} />

				<cfset arrayAppend(array, option) />

			</cfloop>

		<cfelseif isArray(arguments.args.options)>

			<cfset var length = arrayLen(arguments.args.options) />

			<cfif length gt 0>

				<cfset var first = arguments.args.options[1] />

				<cfif isObject(first)>

					<cfloop array="#arguments.args.options#" index="option">

						<cfset var item = {
							id = evaluate("option.#arguments.args.optionKey#()"),
							name = evaluate("option.#arguments.args.optionValue#()"),
							title = evaluate("option.#arguments.args.optionTitle#()")
						} />

						<cfset arrayAppend(array, item) />

					</cfloop>

				<cfelseif isSimpleValue(first)>

					<cfloop array="#arguments.args.options#" index="option">

						<cfset var item = {
							id = option,
							name = option,
							title = option
						} />

						<cfset arrayAppend(array, item) />

					</cfloop>

				<cfelse>

					<cfloop array="#arguments.args.options#" index="option">

						<cfset var item = {
							id = option[arguments.args.optionKey],
							name = option[arguments.args.optionValue],
							title = option[arguments.args.optionTitle]
						} />

						<cfset arrayAppend(array, item) />

					</cfloop>

				</cfif>

			</cfif>

		<cfelseif isQuery(arguments.args.options)>

			<cfloop query="arguments.args.options">

				<cfset var item = {
					id = arguments.args.options[arguments.args.optionKey][currentRow],
					name = arguments.args.options[arguments.args.optionValue][currentRow],
					title = arguments.args.options[arguments.args.optionTitle][currentRow]
				} />

				<cfset arrayAppend(array, item) />

			</cfloop>

		<cfelseif isStruct(arguments.args.options)>
			
			<cfset var optionKeys = structKeyArray(arguments.args.options) />
			<cfset arraySort(optionKeys, "textnocase") />
				
			<cfloop from="1" to="#arrayLen(optionKeys)#" index="i">
				
				<cfset var id = optionKeys[i] />
				<cfset var value = arguments.args.options[id] />
				
				<cfif isSimpleValue(value)>
						
					<cfset var option = {
						id = id,
						name = trim(value),
						title = trim(value)
					} />	
						
					<cfset arrayAppend(array, option) />	
						
				<cfelse>
					
					<!--- struct of structs --->					
					<cfset var option = {
						id = id,
						name = trim(value[arguments.args.optionValue]),
						title = trim(value[arguments.args.optionTitle])
					} />
					
					<cfset arrayAppend(array, option) />
					
				</cfif>
				
			</cfloop>

		</cfif>

		<cfset arguments.args.options = array />

		<!--- if we're dealing with options, make sure we're dealing with a simple value --->
		<cfif not isSimpleValue(arguments.args.value)>

			<cfset var value = [] />

			<cfloop array="#arguments.args.options#" index="option">
				<cfset arrayAppend(value, option.id) />
			</cfloop>

			<cfset arguments.args.value = arrayToList(value) />

		</cfif>

		<cfreturn arguments.args />

	</cffunction>

	<!------>

	<cffunction name="getRequestContext" access="private" output="false" returntype="any">

		<cfreturn coldmvc.framework.getBean("requestManager").getRequestContext() />

	</cffunction>

	<!------>

	<cffunction name="setAllowBinding" access="private" output="false" returntype="void">
		<cfargument name="tag" required="true" type="string" />

		<cfset variables.allowBinding[arguments.tag] = true />

	</cffunction>

	<!------>

	<cffunction name="getAllowBinding" access="private" output="false" returntype="boolean">
		<cfargument name="args" required="true" type="struct" />

		<cfreturn structKeyExists(variables.allowBinding, arguments.args.tag) />

	</cffunction>

	<!------>

	<cffunction name="getBinding" access="private" output="false" returntype="struct">
		<cfargument name="args" required="true" type="struct" />

		<cfif arguments.args.bind neq "">
			<cfreturn { key = arguments.args.bind, index = "" } />
		<cfelse>
			<cfreturn coldmvc.bind.get() />
		</cfif>

	</cffunction>

	<!------>

	<cffunction name="getName" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfset var name = arguments.args.name />

		<cfif arguments.args.binding>

			<cfset var binding = getBinding(arguments.args) />

			<cfif binding.key neq "">

				<cfset var camelized = coldmvc.string.camelize(binding.key) />

				<cfif binding.index neq "">
					<cfset name = "#camelized#[#binding.index#].#arguments.args.name#" />
				<cfelse>
					<cfset name = "#camelized#.#arguments.args.name#" />
				</cfif>

			<cfelse>

				<cfset name = arguments.args.name />

			</cfif>

		</cfif>

		<cfif isSimpleValue(name)>
			<cfset name = trim(name) />
		</cfif>

		<cfreturn name />

	</cffunction>

	<!------>

	<cffunction name="getID" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfif not structKeyExists(arguments.args, "id")>
			<cfset arguments.args.id = replace(arguments.args.name, " ", "_", "all") />
			<cfset arguments.args.id = replace(arguments.args.id, ".", "_", "all") />
			<cfset arguments.args.id = replace(arguments.args.id, "[", "_", "all") />
			<cfset arguments.args.id = replace(arguments.args.id, "]", "_", "all") />
			<cfset arguments.args.id = replace(arguments.args.id, "__", "_", "all") />
		</cfif>

		<cfreturn arguments.args.id />

	</cffunction>

	<!------>

	<cffunction name="getValue" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfset var value = "" />
		<cfset var requestContext = getRequestContext() />

		<cfif structKeyExists(arguments.args, "value")>

			<cfset value = arguments.args.value />

		<cfelse>

			<cfif arguments.args.binding>

				<!--- if there's a param with the same name --->
				<cfif requestContext.hasParam(arguments.args.name)>
					<cfset value = requestContext.getParam(arguments.args.name) />
				</cfif>

				<!--- if you're currently inside a form that's bound to a param --->
				<cfset var binding = getBinding(arguments.args) />

				<cfif binding.key neq "">

					<!--- check to see if the binding exists (aka params.user) --->
					<cfif requestContext.hasParam(binding.key)>

						<cfset var param = requestContext.getParam(binding.key) />
						<cfset var type = coldmvc.data.type(param) />

						<cfif binding.index neq "">

							<cfset param = coldmvc.data.value(param, binding.index) />
							<cfset type = coldmvc.data.type(param) />

						</cfif>

						<cfswitch expression="#type#">

							<cfcase value="object">
								<cfset value = param.prop(arguments.args.name) />
							</cfcase>

							<cfcase value="struct">
								<cfif structKeyExists(param, arguments.args.name)>
									<cfset value = param[arguments.args.name] />
								</cfif>
							</cfcase>

						</cfswitch>

					</cfif>

				</cfif>

			</cfif>

		</cfif>

		<cfif isSimpleValue(value)>
			<cfset value = trim(value) />
		<cfelseif isObject(value)>
			<cfset value = value.id() />
		<cfelseif isArray(value)>

			<cfset var array = value />
			<cfset var item = "" />
			<cfset value = [] />

			<cfloop array="#array#" index="item">

				<cfif isSimpleValue(item)>
					<cfset arrayAppend(value, item) />
				<cfelseif isObject(item)>
					<cfset arrayAppend(value, item.id()) />
				<cfelseif isStruct(item)>
					<cfset arrayAppend(value, item.id) />
				</cfif>

			</cfloop>

			<cfset value = arrayToList(value) />

		</cfif>

		<cfreturn value />

	</cffunction>

	<!------>

	<cffunction name="getKey" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="key" required="true" type="string" />
		<cfargument name="default" required="false" default="" type="string" />

		<cfset var value = arguments.default />

		<cfif structKeyExists(arguments.args, arguments.key)>
			<cfset value = arguments.args[arguments.key] />
		</cfif>

		<cfif isSimpleValue(value)>
			<cfset value = trim(value) />
		</cfif>

		<cfreturn value />

	</cffunction>

	<!------>

	<cffunction name="getLabel" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfset var local = {} />

		<cfif not structKeyExists(arguments.args, "label")>
			<cfset arguments.args.label = coldmvc.string.propercase(arguments.args.name) />
		</cfif>

		<cfreturn trim(arguments.args.label) />

	</cffunction>

	<!------>

	<cffunction name="getURL" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfif not structKeyExists(arguments.args, "url")>

			<cfif structKeyExists(arguments.args, "parameters")
				or structKeyExists(arguments.args, "module")
				or structKeyExists(arguments.args, "controller")
				or structKeyExists(arguments.args, "action")>

				<cfif not structKeyExists(arguments.args, "parameters")>

					<cfset arguments.args.parameters = {} />

					<cfset var i = "" />
					<cfloop list="module,controller,action" index="i">
						<cfif structKeyExists(arguments.args, i)>
							<cfset arguments.args.parameters[i] = arguments.args[i] />
						</cfif>
					</cfloop>

				</cfif>

				<cfset arguments.args.url = coldmvc.link.to(arguments.args.parameters) />

			<cfelse>

				<cfset arguments.args.url = "" />

			</cfif>

		</cfif>

		<cfreturn trim(arguments.args.url) />

	</cffunction>

	<!------>

	<cffunction name="field" access="public" output="false" returntype="string">
		<cfargument name="field" required="true" type="string" />

		<cfset configure(arguments) />

		<cfif not arguments.wrapper>
			<cfreturn trim(arguments.field) />
		</cfif>

		<cfset var result = "" />

		<cfoutput>
		<cfsavecontent variable="result">
			#trim(arguments.field)#
			<cfif arguments.instructions neq "" and variables.options.instructions.display>
				<#variables.options.instructions.tag# class="#variables.options.instructions.class#">
					#arguments.instructions#
				</#variables.options.instructions.tag#>
			</cfif>
			<cfif arguments.description neq "" and variables.options.description.display>
				<#variables.options.description.tag# class="#variables.options.description.class#">
					#arguments.description#
				</#variables.options.description.tag#>
			</cfif>
		</cfsavecontent>
		</cfoutput>

		<cfif variables.options.field.display>
			<cfoutput>
			<cfsavecontent variable="result">
				<#variables.options.field.tag# class="#variables.options.field.class#">
					#result#
				</#variables.options.field.tag#>
			</cfsavecontent>
			</cfoutput>
		</cfif>

		<cfif variables.options.label.display>

			<cfset var labelText = htmlEditFormat(arguments.label) & variables.options.label.suffix />

			<cfif arguments.required>

				<cfif variables.options.required.display>

					<cfif variables.options.required.tag neq "">
						<cfset var labelRequired = '<#variables.options.required.tag# class="#variables.options.required.class#">#variables.options.required.content#</#variables.options.required.tag#>' />
					<cfelse>
						<cfset var labelRequired = variables.options.required.content />
					</cfif>

					<cfif variables.options.required.placement eq "append">
						<cfset labelText = labelRequired & variables.options.required.separator & labelText />
					<cfelse>
						<cfset labelText = labelText & variables.options.required.separator & labelRequired />
					</cfif>

				</cfif>

			</cfif>

			<cfset var labelHTML = '<label for="#arguments.id#" title="#htmlEditFormat(arguments.title)#">#labelText#</label>' />

			<cfif variables.options.label.tag neq "">

				<cfoutput>
				<cfsavecontent variable="result">
					<#variables.options.field.tag# class="#variables.options.label.class#">
						#labelHTML#
					</#variables.options.field.tag#>
					#result#
				</cfsavecontent>
				</cfoutput>

			<cfelse>

				<cfoutput>
				<cfsavecontent variable="result">
					#labelHTML#
					#result#
				</cfsavecontent>
				</cfoutput>

			</cfif>

		</cfif>

		<cfif variables.options.wrapper.display>

			<cfset var wrapperClass = variables.options.wrapper.class />

			<cfif arguments.required>
				<cfset wrapperClass = wrapperClass & " " & variables.options.required.class />
			</cfif>

			<cfset var wrapperAttributes = 'class="#trim(wrapperClass)#"' />

			<cfif not arguments.visible>
				<cfset wrapperAttributes = wrapperAttributes & ' style="display:none;"' />
			</cfif>

			<cfoutput>
			<cfsavecontent variable="result">
				<#variables.options.wrapper.tag# #wrapperAttributes#>
					#result#
				</#variables.options.wrapper.tag#>
			</cfsavecontent>
			</cfoutput>

		</cfif>

		<cfreturn trim(result) />

	</cffunction>

	<!------>

	<cffunction name="renderTag" access="public" output="false" returntype="string">
		<cfargument name="tag" required="true" type="string" />
		<cfargument name="content" required="true" type="string" />
		<cfargument name="attributes" required="false" type="struct" />

		<cfif arguments.tag eq "">
			<cfreturn arguments.content />
		</cfif>

		<cfif not structKeyExists(arguments, "attributes")>
			<cfset arguments.attributes = {} />
		</cfif>

		<cfif structIsEmpty(arguments.attributes)>
			<cfreturn '<#arguments.tag#>#arguments.content#</#arguments.tag#>' />
		</cfif>

		<cfset arguments.attributes = coldmvc.struct.toAttributes(arguments.attributes) />

		<cfif arguments.attributes eq "">
			<cfreturn '<#arguments.tag#>#arguments.content#</#arguments.tag#>' />
		<cfelse>
			<cfreturn '<#arguments.tag# #arguments.attributes#>#arguments.content#</#arguments.tag#>' />
		</cfif>

	</cffunction>

	<!------>

</cfcomponent>