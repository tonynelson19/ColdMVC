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
		
		<cfif arguments.url neq "">
			<cfset local.buttonLocation = $.link.to(address=arguments.url) />
		<cfelse>
			<cfset local.buttonLocation = $.link.to(arguments.controller, arguments.action, arguments.params) />
		</cfif>
		
		<cfset local.buttonAction = ' onclick="window.location=''#local.buttonLocation#'';"' />
			
		<cfoutput>
		<cfsavecontent variable="arguments.field">
			<span class="button">
				<input type="button" #arguments.common# value="#htmlEditFormat(arguments.label)#" #local.buttonAction# />
			</span>
		</cfsavecontent>
		</cfoutput>

		<cfreturn arguments.field />
		
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
		<cfargument name="controller" required="false" />
		<cfargument name="action" required="false" />
		<cfargument name="name" required="false" default="form" />
		<cfargument name="method" required="false" default="post" />
		
		<cfset arguments.tag = "form" />

		<cfset configure(arguments) />
		
		<cfset local.url = $.link.to(arguments.controller, arguments.action, "") />

		<cfreturn '<form action="#local.url#" method="#arguments.method#" enctype="multipart/form-data" #arguments.common#>' />

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
			#htmlEditFormat(arguments.value)#"
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