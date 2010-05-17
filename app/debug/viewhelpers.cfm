<cfsilent>
<cfset viewHelpers = $.factory.get("viewHelperManager").getViewHelpers() />
</cfsilent>

<cfoutput>
<h2>View Helpers</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(viewHelpers), 'textnocase')#" index="i">
				<cfset viewHelper = viewHelpers[i] />
				<tr>
					<td class="coldmvc_label">#viewHelper.name#:</td>
					<td class="coldmvc_field">
						<cfif viewHelper.beanName neq "">
							#viewHelper.beanName#.#viewHelper.method#()
						<cfelse>
							$.#viewHelper.helper#.#viewHelper.method#()
						</cfif>
					</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>