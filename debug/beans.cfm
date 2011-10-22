<cfsilent>
<cfset beans = coldmvc.factory.getBeanDefinitions() />
</cfsilent>

<cfoutput>
<h2>Beans</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(beans), 'textnocase')#" index="bean">
				<tr>
					<td class="coldmvc_label">#bean#:</td>
					<td class="coldmvc_field">#beans[bean]#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>