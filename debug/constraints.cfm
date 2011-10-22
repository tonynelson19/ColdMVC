<cfsilent>
<cfset constraints = coldmvc.framework.getBean("validator").getConstraints() />
</cfsilent>

<cfoutput>
<h2>Constraints</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(constraints), 'textnocase')#" index="constraint">
				<tr>
					<td class="coldmvc_label">#constraint#:</td>
					<td class="coldmvc_field">#constraints[constraint].class#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>