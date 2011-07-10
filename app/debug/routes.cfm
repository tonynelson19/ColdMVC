<cfsilent>
<cfset routes = coldmvc.factory.get("router").getRoutes() />
</cfsilent>

<cfoutput>
<h2>Routes</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop array="#routes#" index="route">
				<tr>
					<td class="coldmvc_label" nowrap>#route.pattern#</td>
					<td class="coldmvc_field">#route.expression#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>