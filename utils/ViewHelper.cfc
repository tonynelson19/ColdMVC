<cfcomponent accessors="true" extends="coldmvc.Helper">

	<cfset this.bindTags = "checkbox,email,hidden,input,radio,select,textarea,upload" />

	<!------>

	<cffunction name="configure" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />

		<cfif structKeyExists(args, "_processed")>
			<cfreturn />
		</cfif>
		
		<cfset var i = "" />

		<cfset args._processed = true />

		<cfset args.tag = getKey(args, "tag") />		
		<cfset args.allowBinding = getAllowBinding(args) />
		<cfset args.binding = getKey(args, "binding", args.allowBinding) />
		<cfset args.bind = getKey(args, "bind") />
		<cfset args.name = getKey(args, "name") />
		<cfset args.label = getLabel(args) />
		<cfset args.value = getValue(args, "value") />
		<cfset args.name = getName(args) />
		<cfset args.id = getID(args) />
		<cfset args.title = getKey(args, "title", args.label) />
		<cfset args.alt = getKey(args, "alt", args.label) />
		<cfset args.wrapper = getKey(args, "wrapper", true) />
		<cfset args.readonly = getKey(args, "readonly", false) />
		<cfset args.disabled = getKey(args, "disabled", false) />
		<cfset args.visible = getKey(args, "visible", true) />
		<cfset args.controller = getEvent(args, "controller") />
		<cfset args.action = getEvent(args, "action") />
		<cfset args.params = getEvent(args, "params") />
		<cfset args.url = getKey(args, "url") />

		<cfloop list="class,style,instructions" index="i">
			<cfset args[i] = getKey(args, i) />
		</cfloop>
		
		<cfset args.common = [] />
		
		<cfloop list="name,id,title,class" index="i">
			<cfif args[i] neq "">
				<cfset arrayAppend(args.common, '#i#="#htmlEditFormat(args[i])#"') />
			</cfif>
		</cfloop>

		<cfloop list="blur,change,click,dblclick,focus,keyup,keydown,keypress,submit" index="i">
			<cfset var event = "on#i#" />
			<cfset args[event] = getKey(args, event) />
			<cfif args[event] neq "">
				<cfset arrayAppend(args.common, '#event#="#args[event]#"') />
			</cfif>
		</cfloop>
		
		<cfloop list="readonly,disabled" index="i">
			<cfif args[i] eq "true">
				<cfset arrayAppend(args.common, '#i#="#htmlEditFormat(args[i])#"') />
			</cfif>
		</cfloop>
		
		<cfset args.common = arrayToList(args.common, " ") />

	</cffunction>
	
	<!------>
	
	<cffunction name="configureOptions" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />
		
		<cfset var array = [] />
		<cfset var option = "" />
		<cfset var i = "" />
		
		<cfif not structKeyExists(args, "options")>
			<cfset args.options = "" />
		</cfif>
	
		<cfif not structKeyExists(args, "optionKey")>
			<cfset args.optionKey = "id" />
		</cfif>
		
		<cfif not structKeyExists(args, "optionValue")>
			<cfset args.optionValue = "name" />
		</cfif>
		
		<cfif not structKeyExists(args, "optionTitle")>
			<cfset args.optionTitle = args.optionValue />
		</cfif>
		
		<!--- if it's a list, convert it to an array --->
		<cfif isSimpleValue(args.options)>

			<cfloop list="#args.options#" index="i">

				<cfset var option = {
					id = trim(i),
					name = trim(i),
					title = trim(i)
				} />

				<cfset arrayAppend(array, option) />

			</cfloop>

		<cfelseif isArray(args.options)>

			<cfset var length = arrayLen(args.options) />

			<cfif length gt 0>

				<cfif isObject(args.options[1])>

					<cfloop array="#args.options#" index="option">
						
						<cfset var item = {
							id = evaluate("option.#args.optionKey#()"),
							name = evaluate("option.#args.optionValue#()"),
							title = evaluate("option.#args.optionTitle#()")
						} />
						
						<cfset arrayAppend(array, item) />

					</cfloop>

				<cfelse>

					<cfif args.optionKey neq "id" or args.optionValue neq "name" or args.optionTitle neq "name" or args.optionValue neq args.optionTitle>

						<cfloop array="#args.options#" index="option">
							
							<cfset var item = {
								id = option[args.optionKey],
								name = option[args.optionValue],
								title = option[args.optionTitle]
							} />
							
							<cfset arrayAppend(array, item) />

						</cfloop>
						
					<cfelse>
					
						<cfset array = args.options />

					</cfif>

				</cfif>

			</cfif>

		<cfelseif isQuery(args.options)>

			<cfloop query="args.options">
			
				<cfset var item = {
					id = args.options[args.optionKey][currentRow],
					name = args.options[args.optionValue][currentRow],
					title = args.options[args.optionTitle][currentRow]
				} />
				
				<cfset arrayAppend(array, item) />

			</cfloop>			

		</cfif>
		
		<cfset args.options = array />
		
		<!--- if we're dealing with options, make sure we're dealing with a simple value --->
		<cfif not isSimpleValue(args.value)>

			<cfset var value = [] />

			<cfloop array="#args.options#" index="option">
				<cfset arrayAppend(value, option.id) />
			</cfloop>

			<cfset args.value = arrayToList(value) />

		</cfif>
	
	</cffunction>
	
	<!------>
	
	<cffunction name="getAllowBinding" access="private" output="false" returntype="boolean">
		<cfargument name="args" required="true" type="struct" />
		
		<cfif listFindNoCase(variables.this.bindTags, args.tag)>
			<cfreturn true />
		</cfif>
		
		<cfreturn false />
		
	</cffunction>
	
	<!------>
	
	<cffunction name="getName" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		
		<cfset var name = args.name />
		
		<cfif args.binding>
		
			<cfset var binding = $.bind.get("form") />
			
			<cfif binding neq "">
				
				<cfset name = $.string.camelize(binding) & "." & args.name />
				
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
		
		<cfif not structKeyExists(args, "id")>
			<cfset args.id = replace(args.name, " ", "_", "all") />
		</cfif>

		<cfreturn args.id />

	</cffunction>
	
	<!------>
	
	<cffunction name="getValue" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		
		<cfset var value = "" />
		
		<cfif structKeyExists(args, "value")>
			
			<cfset value = args.value />
		
		<cfelse>
				
			<cfif args.binding>
			
				<cfset var binding = $.bind.get("form") />
				
				<cfif binding neq "">
					
					<cfif structKeyExists(params, binding)>
						<cfset value = params[binding]._get(args.name) />
					</cfif>
					
				</cfif>
			
			</cfif>
			
		</cfif>
		
		<cfif isSimpleValue(value)>
			<cfset value = trim(value) />
		</cfif>

		<cfreturn value />
	
	</cffunction>

	<!------>

	<cffunction name="getKey" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="key" required="true" type="string" />
		<cfargument name="default" required="false" default="" type="string" />

		<cfset var value = default />

		<cfif structKeyExists(args, key)>
			<cfset value = args[key] />
		</cfif>

		<cfif isSimpleValue(value)>
			<cfset value = trim(value) />
		</cfif>

		<cfreturn value />

	</cffunction>
	
	<!------>
	
	<cffunction name="getEvent" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="key" required="true" type="string" />

		<cfset value = "" />

		<cfif structKeyExists(args, key)>			
			<cfset value = args[key] />		
		<cfelse>			
			<cfset value =  $.event.get(key) />			
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

		<cfif not structKeyExists(args, "label")>

			<cfset args.label = $.string.underscore(args.name) />
			
			<cfset args.label = $.string.humanize(args.label) />

			<cfif right(args.label, 3) eq " ID">
				<cfset args.label = left(args.label, len(args.label)-3) />
			</cfif>

		</cfif>

		<cfreturn trim(args.label) />

	</cffunction>

	<!------>
	
	<cffunction name="field" access="public" output="false" returntype="string">
		<cfargument name="field" required="true" type="string" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfif not arguments.wrapper>

			<cfreturn trim(arguments.field) />

		<cfelse>

			<cfsavecontent variable="local.string">
				<div #_wrapper(arguments)#>
					<div class="label">
						<label id="label_for_#arguments.id#" for="#arguments.id#" title="#htmlEditFormat(arguments.title)#">#htmlEditFormat(arguments.label)#:</label>
					</div>
					<div class="field">
						#trim(arguments.field)#
						<cfif arguments.instructions neq "">
							<div class="instructions">
								#arguments.instructions#
							</div>
						</cfif>
					</div>
				</div>
			</cfsavecontent>

		</cfif>
		</cfoutput>

		<cfreturn trim(local.string) />

	</cffunction>
	
	<!------>
	
	<cffunction name="_wrapper" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
g
		<cfset var string = 'class="wrapper"' />

		<cfif args.id neq "">
			<cfset string = string & ' id="wrapper_for_#args.id#"' />
		</cfif>

		<cfif not args.visible>
			<cfset string = string & ' style="display:none;"' />
		</cfif>
		
		<cfreturn string />

	</cffunction>
	
	<!------>

</cfcomponent>