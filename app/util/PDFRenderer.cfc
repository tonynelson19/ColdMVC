<cfcomponent output="false" accessors="true">

	<!--- allow for injecting attributes --->
	<cfproperty name="pdf" />

	<cffunction name="init" access="public" output="false" returntype="any">

		<cfset variables.pdf = {} />

		<cfreturn this />

	</cffunction>

	<cffunction name="toPDF" access="public" output="false" returntype="void">
		<cfargument name="html" required="true" type="string" />

		<cfset variables.pdf.format = "pdf" />

		<cfdocument attributeCollection="#variables.pdf#"><cfoutput>#arguments.html#</cfoutput></cfdocument>

	</cffunction>

</cfcomponent>