<cfcomponent extends="coldmvc.Helper">

	<!--- to add to this list, use setAllowBinding("mytag") --->
	<cfset this.bindTags = "checkbox,color,date,email,hidden,input,number,password,phone,radio,range,search,select,text,textarea,time,upload,url" />

	<!------>

	<cffunction name="append" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="attribute" required="true" type="string" />
		<cfargument name="value" required="true" type="string" />

		<cfif structKeyExists(args, attribute)>
			<cfset args[attribute] = args[attribute] & " " & value />
		<cfelse>
			<cfset args[attribute] = value />
		</cfif>

	</cffunction>

	<!------>

	<cffunction name="configure" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="commonKeys" required="false" default="" type="string" />

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
		<cfset args.originalName = args.name />
		<cfset args.label = getLabel(args) />
		<cfset args.value = getValue(args) />
		<cfset args.name = getName(args) />
		<cfset args.id = getID(args) />
		<cfset args.title = getKey(args, "title", args.label) />
		<cfset args.alt = getKey(args, "alt", args.label) />
		<cfset args.wrapper = getKey(args, "wrapper", true) />
		<cfset args.readonly = getKey(args, "readonly", false) />
		<cfset args.disabled = getKey(args, "disabled", false) />
		<cfset args.visible = getKey(args, "visible", true) />

		<cfloop list="class,style,instructions,placeholder,#commonKeys#" index="i">
			<cfset args[i] = getKey(args, i) />
		</cfloop>

		<cfset args.common = [] />

		<cfloop list="name,id,title,class,placeholder,#commonKeys#" index="i">
			<cfif args[i] neq "">
				<cfset arrayAppend(args.common, '#i#="#htmlEditFormat(args[i])#"') />
			</cfif>
		</cfloop>

		<cfset args.events = [] />

		<cfloop list="blur,change,click,dblclick,focus,keyup,keydown,keypress,submit" index="i">
			<cfset var event = "on#i#" />
			<cfset args[event] = getKey(args, event) />
			<cfif args[event] neq "">
				<cfset arrayAppend(args.events, '#event#="#args[event]#"') />
				<cfset arrayAppend(args.common, '#event#="#args[event]#"') />
			</cfif>
		</cfloop>

		<cfloop list="readonly,disabled" index="i">
			<cfif args[i] eq "true">
				<cfset arrayAppend(args.common, '#i#="#htmlEditFormat(args[i])#"') />
			</cfif>
		</cfloop>

		<cfloop list="size,maxlength,rows,cols" index="i">
			<cfset var value = getKey(args, i) />
			<cfif isNumeric(value)>
				<cfset arrayAppend(args.common, '#i#="#value#"') />
			</cfif>
		</cfloop>

		<cfset args.common = arrayToList(args.common, " ") />
		<cfset args.events = arrayToList(args.events, " ") />

	</cffunction>

	<!------>

	<cffunction name="configureOptions" access="private" output="false" returntype="void">
		<cfargument name="args" required="true" type="struct" />

		<cfset var array = [] />
		<cfset var option = "" />
		<cfset var i = "" />

		<cfif not structKeyExists(args, "options")>

			<cfif structKeyExists(args, "optionValues")>

				<cfif not structKeyExists(args, "optionKeys")>
					<cfset args.optionKeys = args.optionValues />
				</cfif>

				<cfif not structKeyExists(args, "optionTitles")>
					<cfset args.optionTitles = args.optionValues />
				</cfif>

				<cfset args.options = [] />

				<cfloop from="1" to="#listLen(args.optionValues)#" index="i">

					<cfset var option = {
						id = listGetAt(args.optionKeys, i),
						name = listGetAt(args.optionValues, i),
						title = listGetAt(args.optionTitles, i)
					} />

					<cfset arrayAppend(args.options, option) />

				</cfloop>


			<cfelse>

				<cfif coldmvc.params.has(args.originalName)>
					<cfset args.options = coldmvc.params.get(args.originalName) />
				<cfelseif coldmvc.params.has(coldmvc.string.pluralize(args.originalName))>
					<cfset args.options = coldmvc.params.get(coldmvc.string.pluralize(args.originalName)) />
				<cfelse>
					<cfset args.options = "" />
				</cfif>

			</cfif>

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

					<cfloop array="#args.options#" index="option">

						<cfset var item = {
							id = option[args.optionKey],
							name = option[args.optionValue],
							title = option[args.optionTitle]
						} />

						<cfset arrayAppend(array, item) />

					</cfloop>

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

	<cffunction name="setAllowBinding" access="private" output="false" returntype="void">
		<cfargument name="tag" required="true" type="string" />

		<cfif not listFindNoCase(this.bindTags, tag)>
			<cfset this.bindTags = listAppend(this.bindTags, tag) />
		</cfif>

	</cffunction>

	<!------>

	<cffunction name="getAllowBinding" access="private" output="false" returntype="boolean">
		<cfargument name="args" required="true" type="struct" />

		<cfif listFindNoCase(this.bindTags, args.tag)>
			<cfreturn true />
		</cfif>

		<cfreturn false />

	</cffunction>

	<!------>

	<cffunction name="getBinding" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfif args.bind neq "">
			<cfreturn args.bind />
		<cfelse>
			<cfreturn coldmvc.bind.get() />
		</cfif>

	</cffunction>

	<!------>

	<cffunction name="getName" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfset var name = args.name />

		<cfif args.binding>

			<cfset var binding = getBinding(args) />

			<cfif binding neq "">
				<cfset name = coldmvc.string.camelize(binding) & "." & args.name />
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
			<cfset args.id = replace(args.id, ".", "_", "all") />
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

				<!--- if there's a param with the same name --->
				<cfif coldmvc.params.has(args.name)>
					<cfset value = coldmvc.params.get(args.name) />
				</cfif>

				<!--- if you're currently inside a form that's bound to a param --->
				<cfset var binding = getBinding(args) />

				<cfif binding neq "">

					<!--- check to see if the binding exists (aka params.user) --->
					<cfif coldmvc.params.has(binding)>

						<cfset var param = coldmvc.params.get(binding) />
						<cfset var type = coldmvc.data.type(param) />

						<cfswitch expression="#type#">

							<cfcase value="object">
								<cfset value = param.prop(args.name) />
							</cfcase>

							<cfcase value="struct">
								<cfset value = param[args.name] />
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
			<cfset value =  coldmvc.event.get(key) />
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

			<cfset args.label = coldmvc.string.uncamelize(args.name) />

			<cfif right(args.label, 3) eq " ID">
				<cfset args.label = left(args.label, len(args.label)-3) />
			</cfif>

		</cfif>

		<cfreturn trim(args.label) />

	</cffunction>

	<!------>

	<cffunction name="getURL" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />

		<cfif not structKeyExists(args, "url")>

			<cfset args.querystring = getKey(args, "querystring") />

			<cfif not structKeyExists(args, "parameters")>

				<cfset args.parameters.controller = getKey(args, "controller", coldmvc.event.controller()) />
				<cfset args.parameters.action = getKey(args, "action", coldmvc.event.action()) />

			</cfif>

			<cfset args.url = coldmvc.link.to(args.parameters, args.querystring) />

		</cfif>

		<cfreturn trim(args.url) />

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