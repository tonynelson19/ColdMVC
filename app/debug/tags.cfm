<cfsilent>
<cfset tagManager = coldmvc.factory.get("tagManager") />
<cfset tags = tagManager.getTemplates() />
<cfset tagLibraries = tagManager.getTagLibraries() />
</cfsilent>

<cfoutput>
<h2>Tags</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(tags), 'textnocase')#" index="tag">
				<tr>
					<td class="coldmvc_label">#listFirst(tags[tag].name, ".")#:</td>
					<td class="coldmvc_field">#tags[tag].path#</td>
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
<h2>Tag Libraries</h2>
<div class="coldmvc_debug_section">
	<table>
		<tbody>
			<cfloop list="#listSort(structKeyList(tagLibraries), 'textnocase')#" index="prefix">
				<tr>
					<td class="coldmvc_label">#prefix#:</td>
					<td class="coldmvc_field">#tagLibraries[prefix]#</td>
				</tr>
			</cfloop>
		</tbody>
	</table>
</div>
</cfoutput>