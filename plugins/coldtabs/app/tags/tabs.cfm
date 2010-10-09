<cfparam name="attributes.id" default="" />
<cfparam name="attributes.class" default="" />
<cfparam name="attributes.querystring" default="" />

<cfoutput>
<cfif thisTag.executionMode eq "end">

	<cfif not structKeyExists(attributes, "tabs")>

		<cfset attributes.tabs = coldmvc.factory.get("tabManager").getTabs(argumentCollection=attributes) />

		<cfif structKeyExistS(attributes, "model")>

			<cfloop array="#attributes.tabs#" index="tab">
				<cfset tab.url = coldmvc.link.to({controller=tab.controller, action=tab.action, id=attributes.model}, coldmvc.querystring.combine(tab.querystring, attributes.querystring)) />
			</cfloop>

		</cfif>

	</cfif>

	<ul<cfif attributes.id neq ""> id="#attributes.id#"</cfif><cfif attributes.class neq ""> class="#attributes.class#"</cfif>>
		<cfloop array="#attributes.tabs#" index="tab">
			<li<cfif tab.class neq ""> class="#tab.class#"</cfif>><a href="#tab.url#" title="#tab.title#"<cfif tab.target neq ""> target="#tab.target#"</cfif>><span>#tab.name#</span></a></li>
		</cfloop>
	</ul>

</cfif>
</cfoutput>