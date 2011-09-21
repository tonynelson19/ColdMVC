<cfcomponent extends="coldmvc.app.util.HTMLHelper">

	<!------>

	<cffunction name="button" access="public" output="false" returntype="string">

		<cfset arguments.tag = "button" />

		<cfset append(arguments, "class", "button") />

		<cfset arguments.url = getURL(arguments) />

		<cfif arguments.url neq "">
			<cfset arguments.onclick = "window.location='#htmlEditFormat(arguments.url)#';" />
		</cfif>

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<span class="button">
				<input type="button" #arguments.common# value="#htmlEditFormat(arguments.label)#" />
			</span>
		</cfsavecontent>
		</cfoutput>

		<cfreturn arguments.field />

	</cffunction>

	<!------>

	<cffunction name="checkbox" access="public" output="false" returntype="string">

		<cfreturn radioOrCheckbox(arguments, "checkbox") />

	</cffunction>

	<!------>

	<cffunction name="color" access="public" output="false" returntype="string">

		<cfset arguments.tag = "color" />

		<cfset append(arguments, "class", "color") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="color" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="date" access="public" output="false" returntype="string">

		<cfset arguments.tag = "date" />

		<cfset append(arguments, "class", "date") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="date" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="email" access="public" output="false" returntype="string">

		<cfset arguments.tag = "email" />

		<cfset append(arguments, "class", "email") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="email" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="fieldset" access="public" output="false" returntype="string">
		<cfargument name="label" required="false" />

		<cfset arguments.tag = "fieldset" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="local.string">
			<fieldset>
				<cfif arguments.label neq "">
					<legend>#arguments.label#</legend>
				</cfif>
		</cfsavecontent>
		</cfoutput>

		<cfreturn trim(local.string) />

	</cffunction>

	<!------>

	<cffunction name="form" access="public" output="false" returntype="string">
		<cfargument name="id" required="false" default="form" />
		<cfargument name="method" required="false" default="post" />

		<cfset arguments.tag = "form" />

		<!--- prevent the form tag from having unnecessary attributes --->
		<cfset arguments.name = "" />
		<cfset arguments.title = "" />

		<cfset configure(arguments) />

		<cfset arguments.url = getURL(arguments) />
		
		<cfset var attributes = [] />
		<cfset arrayAppend(attributes, 'action="#arguments.url#"') />
		<cfset arrayAppend(attributes, 'method="#arguments.method#"') />
		<cfset arrayAppend(attributes, 'enctype="multipart/form-data"') />
		<cfset arrayAppend(attributes, arguments.common) />
		
		<cfif structKeyExists(arguments, "novalidate")>
			<cfif isBoolean(arguments.novalidate) and arguments.novalidate>
				<cfset arguments.novalidate = "novalidate" />
			</cfif>
			<cfset arrayAppend(attributes, 'novalidate="#arguments.novalidate#"') />
		</cfif>

		<cfreturn '<form #arrayToList(attributes, " ")#>' />

	</cffunction>

	<!------>

	<cffunction name="hidden" access="public" output="false" returntype="string">

		<cfset arguments.tag = "hidden" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="hidden" name="#arguments.name#" id="#arguments.id#" value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn arguments.field />

	</cffunction>

	<!------>

	<cffunction name="input" access="public" output="false" returntype="string">

		<cfset arguments.tag = "input" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="text" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="number" access="public" output="false" returntype="string">
		<cfargument name="min" required="false" />
		<cfargument name="max" required="false" />
		<cfargument name="step" required="false" />

		<cfset arguments.tag = "number" />

		<cfset append(arguments, "class", "number") />
		<cfset configure(arguments, "min,max,step") />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="number" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="password" access="public" output="false" returntype="string">

		<cfset arguments.tag = "password" />

		<cfset append(arguments, "class", "password") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="password" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="phone" access="public" output="false" returntype="string">

		<cfset arguments.tag = "phone" />

		<cfset append(arguments, "class", "phone") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="tel" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="radio" access="public" output="false" returntype="string">

		<cfreturn radioOrCheckbox(arguments, "radio") />

	</cffunction>

	<!------>

	<cffunction name="radioOrCheckbox" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="type" required="true" type="string" />

		<cfset var i = "" />

		<cfset arguments.args.tag = arguments.type />

		<cfset configure(arguments.args) />
		<cfset configureOptions(arguments.args) />

		<cfset var length = arrayLen(arguments.args.options) />

		<cfif length neq 0>
			<cfset arguments.args.id = "#arguments.args.name#[1]" />
		</cfif>

		<cfif not structKeyExists(arguments.args, "align")>
			<cfif length gt 2>
				<cfset arguments.args.align = "vertical" />
			<cfelse>
				<cfset arguments.args.align = "horizontal" />
			</cfif>
		</cfif>

		<cfoutput>
		<cfsavecontent variable="arguments.args.field">
			<ul class="#type# #arguments.args.align#">
				<cfloop from="1" to="#length#" index="i">
					<li <cfif i eq 1>class="first"<cfelseif i eq local.length>class="last"</cfif>><input type="#type#" name="#arguments.args.name#" id="#arguments.args.name#[#i#]" value="#htmlEditFormat(arguments.args.options[i].id)#" title="#htmlEditFormat(arguments.args.options[i].title)#" <cfif listFindNoCase(arguments.args.value, arguments.args.options[i].id) or (arguments.args.value eq arguments.args.options[i].id)>checked="checked"</cfif> #arguments.args.events#><label for="#arguments.args.name#[#i#]" title="#htmlEditFormat(arguments.args.options[i].title)#">#arguments.args.options[i].name#</label></li>
				</cfloop>
			</ul>
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments.args) />

	</cffunction>

	<!------>

	<cffunction name="range" access="public" output="false" returntype="string">

		<cfset arguments.tag = "range" />

		<cfset append(arguments, "class", "range") />
		<cfset configure(arguments, "min,max,step") />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="range" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="search" access="public" output="false" returntype="string">

		<cfset arguments.tag = "search" />

		<cfset append(arguments, "class", "search") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="search" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="select" access="public" output="false" returntype="string">
		<cfargument name="blank" required="false" default="true" type="boolean" />
		<cfargument name="blankKey" required="false" default="" type="string" />

		<cfset var option = "" />

		<cfset arguments.tag = "select" />

		<cfset configure(arguments) />
		<cfset configureOptions(arguments) />

		<cfif not structKeyExists(arguments, "blankValue")>
			<cfset arguments.blankValue = "- #arguments.label# -" />
		</cfif>

		<cfif not structKeyExists(arguments, "blankTitle")>
			<cfset arguments.blankTitle = arguments.label />
		</cfif>

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<select #arguments.common#>
				<cfif arguments.blank>
					<option value="#htmlEditFormat(arguments.blankKey)#" title="#htmlEditFormat(arguments.blankTitle)#">#htmlEditFormat(arguments.blankValue)#</option>
				</cfif>
				<cfloop array="#arguments.options#" index="option">
					<option value="#htmlEditFormat(option.id)#" title="#htmlEditFormat(option.title)#" <cfif arguments.value eq htmlEditFormat(option.id)>selected</cfif>>#htmlEditFormat(option.name)#</option>
				</cfloop>
			</select>
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="submit" access="public" output="false" returntype="string">
		<cfargument name="name" required="false" default="save" />

		<cfset arguments.tag = "submit" />
		<cfset append(arguments, "class", "button") />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<span class="button">
				<input type="submit" #arguments.common# value="#htmlEditFormat(arguments.label)#" />
			</span>
		</cfsavecontent>
		</cfoutput>

		<cfreturn arguments.field />

	</cffunction>

	<!------>

	<cffunction name="text" access="public" output="false" returntype="string">

		<cfset arguments.tag = "text" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			#htmlEditFormat(arguments.value)#
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="textarea" access="public" output="false" returntype="string">

		<cfset arguments.tag = "textarea" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<textarea #arguments.common#>#htmlEditFormat(arguments.value)#</textarea>
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="time" access="public" output="false" returntype="string">

		<cfset arguments.tag = "time" />

		<cfset append(arguments, "class", "time") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="time" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="upload" access="public" output="false" returntype="string">

		<cfset arguments.tag = "upload" />

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="file" #arguments.common# />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

	<cffunction name="url" access="public" output="false" returntype="string">

		<cfset arguments.tag = "url" />

		<cfset append(arguments, "class", "url") />
		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<input type="url" #arguments.common# value="#htmlEditFormat(arguments.value)#" />
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=arguments) />

	</cffunction>

	<!------>

</cfcomponent>