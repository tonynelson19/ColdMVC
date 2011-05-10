<cfsilent>
<cfset modelHelpers = coldmvc.factory.get("modelHelperManager").getModelHelpers() />
</cfsilent>

<cfoutput>
<h2>Model Helpers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(modelHelpers), 'textnocase')#" index="i">
				<cfset modelHelper = modelHelpers[i] />
				<tr>
					<td class="coldmvc_label">#modelHelper.name#:</td>
					<td class="coldmvc_field">
						<cfif modelHelper.beanName neq "">
							#modelHelper.beanName#.#modelHelper.method#()
						<cfelse>
							$.#modelHelper.helper#.#modelHelper.method#()
						</cfif>
					</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(modelHelpers)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>