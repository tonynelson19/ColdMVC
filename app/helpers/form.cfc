<cfcomponent extends="coldmvc.app.util.HTMLHelper">

	<!------>

	<cffunction name="button" access="public" output="false" returntype="string">

		<cfset arguments.tag = "button" />

		<cfset append(arguments, "class", "button") />

		<cfif not structKeyExists(arguments, "url")>

			<cfif structKeyExists(arguments, "parameters")
				or structKeyExists(arguments, "controller")
				or structKeyExists(arguments, "action")
				or structKeyExists(arguments, "querystring")>

				<cfset arguments.url = getURL(arguments) />

			<cfelse>

				<cfset arguments.url = "" />

			</cfif>

		</cfif>

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
		<cfargument name="name" required="false" default="form" />
		<cfargument name="method" required="false" default="post" />

		<cfset arguments.tag = "form" />
		<!--- prevent the form tag from having a title --->
		<cfset arguments.title = "" />

		<cfset configure(arguments) />
		<cfset arguments.url = getURL(arguments) />

		<cfreturn '<form action="#arguments.url#" method="#arguments.method#" enctype="multipart/form-data" #arguments.common#>' />

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

		<cfset arguments.tag = "number" />

		<cfset append(arguments, "class", "number") />
		<cfset configure(arguments) />

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

	<cffunction name="radio" access="public" output="false" returntype="string">

		<cfreturn radioOrCheckbox(arguments, "radio") />

	</cffunction>

	<!------>

	<cffunction name="radioOrCheckbox" access="private" output="false" returntype="string">
		<cfargument name="args" required="true" type="struct" />
		<cfargument name="type" required="true" type="string" />

		<cfset var i = "" />

		<cfset args.tag = type />

		<cfset configure(args) />
		<cfset configureOptions(args) />

		<cfset var length = arrayLen(args.options) />

		<cfif length neq 0>
			<cfset args.id = "#args.name#[1]" />
		</cfif>

		<cfif not structKeyExists(args, "align")>
			<cfif length gt 2>
				<cfset args.align = "vertical" />
			<cfelse>
				<cfset args.align = "horizontal" />
			</cfif>
		</cfif>

		<cfoutput>
		<cfsavecontent variable="args.field">
			<ul class="#type# #args.align#">
				<cfloop from="1" to="#length#" index="i">
					<li <cfif i eq 1>class="first"<cfelseif i eq local.length>class="last"</cfif>><input type="#type#" name="#args.name#" id="#args.name#[#i#]" value="#htmlEditFormat(args.options[i].id)#" title="#htmlEditFormat(args.options[i].title)#" <cfif listFindNoCase(args.value, args.options[i].id) or (args.value eq args.options[i].id)>checked="checked"</cfif>><label for="#args.name#[#i#]" title="#htmlEditFormat(args.options[i].title)#">#args.options[i].name#</label></li>
				</cfloop>
			</ul>
		</cfsavecontent>
		</cfoutput>

		<cfreturn this.field(argumentCollection=args) />

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