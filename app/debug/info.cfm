<cfsilent>
<cfset debugManager = coldmvc.factory.get("debugManager") />

<cfset reloadKey = coldmvc.config.get("reloadKey") />
<cfset reloadPassword = coldmvc.config.get("reloadPassword") />

<cfif reloadPassword neq "">
	<cfset reloadString = "#reloadKey#=#reloadPassword#" />
<cfelse>
	<cfset reloadString = "#reloadKey#" />
</cfif>

<cfset queryString = coldmvc.cgi.get("query_string") />

<cfif queryString eq reloadString>
	<cfset queryString = "" />
<cfelseif right(queryString, len(reloadString)) eq reloadString>
	<cfset queryString = left(queryString, len(queryString) - len(reloadString)) />
</cfif>

<cfif queryString eq "">
	<cfset queryString = reloadString />
<cfelse>
	<cfset queryString = queryString & "&" & reloadString />
</cfif>

<cfset reload = coldmvc.config.get("urlPath") />
<cfif coldmvc.event.path() neq "">
	<cfset reload = reload & coldmvc.event.path() />
</cfif>

<cfset reload =  reload & "?" & queryString />
</cfsilent>

<cfoutput>
<h2>ColdMVC Debug Information</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<tr>
				<td class="coldmvc_label">Controller:</td>
				<td class="coldmvc_field">#debugManager.getController()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Action:</td>
				<td class="coldmvc_field">#debugManager.getAction()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">View:</td>
				<td class="coldmvc_field">#debugManager.getView()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Layout:</td>
				<td class="coldmvc_field">#debugManager.getLayout()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Route:</td>
				<td class="coldmvc_field">#debugManager.getRoute()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Development:</td>
				<td class="coldmvc_field">#debugManager.getDevelopment()# (<a href="#reload#">reload</a>)</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Reloaded:</td>
				<td class="coldmvc_field">#coldmvc.debug.get("reloaded", false)#</td>
			</tr>
		</tbody>
	</table>
</div>
</cfoutput>