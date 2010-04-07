<cfcomponent extends="coldmvc.utils.ViewHelper">

	<!------>

	<cffunction name="button" access="public" output="false" returntype="string">

		<cfset arguments.tag = "button" />

		<cfif structKeyExists(arguments, "class")>
			<cfset arguments.class = arguments.class & " button" />
		<cfelse>
			<cfset arguments.class = "button" />
		</cfif>

		<cfset configure(arguments) />

		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<span class="button">
				<input type="button" #arguments.common# value="#htmlEditFormat(arguments.label)#" onclick="window.location='#htmlEditFormat(arguments.url)#';" />
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

	<cffunction name="email" access="public" output="false" returntype="string">

		<cfset arguments.tag = "email" />

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

		<cfset configure(arguments) />

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

	<cffunction name="password" access="public" output="false" returntype="string">

		<cfset arguments.tag = "password" />

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
					<option value="#htmlEditFormat(option.id)#" title="#htmlEditFormat(option.title)#">#htmlEditFormat(option.name)#</option>
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

		<cfif structKeyExists(arguments, "class")>
			<cfset arguments.class = arguments.class & " button" />
		<cfelse>
			<cfset arguments.class = "button" />
		</cfif>

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

</cfcomponent>