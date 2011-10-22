<cfsilent>
<cfset validators = coldmvc.framework.getBean("validatorFactory").getValidators() />
</cfsilent>

<cfoutput>
<h2>Validators</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(validators), 'textnocase')#" index="validator">
				<tr>
					<td class="coldmvc_label">#validator#:</td>
					<td class="coldmvc_field">#validators[validator]#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>