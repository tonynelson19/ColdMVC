<cfsilent>
<cfset modelManager = coldmvc.framework.getBean("modelManager") />
<cfset models = modelManager.getModels() />
</cfsilent>

<cfoutput>
<h2>Models</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(models), 'textnocase')#" index="model">
				<tr>
					<td class="coldmvc_label">#model#:</td>
					<td class="coldmvc_field">#modelManager.getClass(model)#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(models)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>