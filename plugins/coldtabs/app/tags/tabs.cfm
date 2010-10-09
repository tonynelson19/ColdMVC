<cfparam name="attributes.id" default="" />
<cfparam name="attributes.class" default="" />

<cfoutput>
<cfif thisTag.executionMode eq "end">

	<cfset tabs = coldmvc.factory.get("tabManager").getTabs(argumentCollection=attributes) />

	<ul<cfif attributes.id neq ""> id="#attributes.id#"</cfif><cfif attributes.class neq ""> class="#attributes.class#"</cfif>>
		<cfloop array="#tabs#" index="tab">
			<li<cfif tab.class neq ""> class="#tab.class#"</cfif>><a href="#tab.url#" title="#tab.title#"<cfif tab.target neq ""> target="#tab.target#"</cfif>><span>#tab.name#</span></a></li>
		</cfloop>
	</ul>

</cfif>
</cfoutput>