<cfsilent>
<cfset debugManager = coldmvc.factory.get("debugManager") />
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
				<td class="coldmvc_label">Format:</td>
				<td class="coldmvc_field">#debugManager.getFormat()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Route:</td>
				<td class="coldmvc_field">#debugManager.getRoute()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Environment:</td>
				<td class="coldmvc_field">#debugManager.getEnvironment()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Development:</td>
				<td class="coldmvc_field">#debugManager.getDevelopment()#</td>
			</tr>
			<tr>
				<td class="coldmvc_label">Reloaded:</td>
				<td class="coldmvc_field">#coldmvc.debug.get("reloaded", false)# (<a href="#debugManager.getReloadURL()#">reload</a>)</td>
			</tr>
		</tbody>
	</table>
</div>
</cfoutput>