<cfsilent>
<cfset tagManager = coldmvc.factory.get("tagManager") />
<cfset tags = tagManager.getTags() />
</cfsilent>

<cfoutput>
<h2>Tags</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(tags), 'textnocase')#" index="tag">
				<tr>
					<td class="coldmvc_label">#tag#:</td>
					<td class="coldmvc_field">#tags[tag].source#</td>
				</tr>
			</cfloop>
			<cfif structIsEmpty(tags)>
				<tr>
					<td class="coldmvc_label">None</td>
					<td class="coldmvc_field">&nbsp;</td>
				</tr>
			</cfif>
		</tbody>
	</table>
</div>
</cfoutput>