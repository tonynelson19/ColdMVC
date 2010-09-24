<cfcomponent output="false" extends="coldmvc.Helper">

	<!------>
	
	<cffunction name="init" access="public" output="false" returntype="any">
		
		<cfset variables.tables = {} />
		
		<cfreturn this />
		
	</cffunction>

	<!------>

	<cffunction name="save" access="public" output="false" returntype="string">		
		<cfargument name="table" requried="true" type="string" />
		<cfargument name="fields" required="false" type="struct" />

		<cfset var i = "" />
		<cfset var counter = 0 />
		<cfset var query = "" />
		<cfset var result = "" />

		<cfset var data = parseArguments(arguments) />

		<cfif data.id eq "">

			<cfif data.validate eq "cf_sql_integer">

				<cfquery name="query">
					insert into [#data.table#]
						(
						<cfset counter = 0 />
						<cfloop collection="#data.fields#" item="i">
							<cfset counter = counter + 1 />
							[#data.fields[i].name#]<cfif counter neq data.count>,</cfif>
						</cfloop>
						)
					values
						(
						<cfset counter = 0 />
						<cfloop collection="#data.fields#" item="i">
							<cfset counter = counter + 1 />
							<cfif data.fields[i].value neq "">
								<cfqueryparam value="#data.fields[i].value#" cfsqltype="#data.fields[i].validate#" />
							<cfelse>
								null
							</cfif>
							<cfif counter neq data.count>,</cfif>
						</cfloop>
						)
					select #data.key# = scope_identity()
				</cfquery>

				<cfset data.id = query[data.key] />

			<cfelse>

				<cfquery name="query">
					declare @id uniqueidentifier
					set @id = newId()
					insert into [#data.table#]
						(
						<cfloop collection="#data.fields#" item="i">
							[#data.fields[i].name#],
						</cfloop>
						#data.key#
						)
					values
						(
						<cfloop collection="#data.fields#" item="i">
							<cfif data.fields[i].value neq "">
								<cfqueryparam value="#data.fields[i].value#" cfsqltype="#data.fields[i].validate#" />,
							<cfelse>
								null,
							</cfif>
						</cfloop>
						@id
						)
					select #data.key# = @id

				</cfquery>

				<cfset data.id = query[data.key] />

			</cfif>

		<cfelse>

			<cfquery name="query" result="result">
				update [#data.table#]
				set
					<cfset counter = 1 />
					<cfloop collection="#data.fields#" item="i">
						<cfif data.fields[i].value neq "">
							[#data.fields[i].name#] = <cfqueryparam value="#data.fields[i].value#" cfsqltype="#data.fields[i].validate#" />
						<cfelse>
							[#data.fields[i].name#] = null
						</cfif>
						<cfif counter neq data.count>,</cfif>
						<cfset counter = counter + 1 />
					</cfloop>
				where #data.key# = <cfqueryparam value="#data.id#" cfsqltype="#data.validate#" />
			</cfquery>
			
			<cfif result.recordCount eq 0>

				<cfquery name="query">
					declare @id uniqueidentifier
					set @id = '#data.id#'
					insert into [#data.table#]
						(
						<cfloop collection="#data.fields#" item="i">
							[#data.fields[i].name#],
						</cfloop>
						#data.key#
						)
					values
						(
						<cfloop collection="#data.fields#" item="i">
							<cfif data.fields[i].value neq "">
								<cfqueryparam value="#data.fields[i].value#" cfsqltype="#data.fields[i].validate#" />,
							<cfelse>
								null,
							</cfif>
						</cfloop>
						@id
						)
					select #data.key# = @id
				</cfquery>

				<cfset data.id = query[data.key] />

			</cfif>

		</cfif>

		<cfreturn data.id />

	</cffunction>

	<!------>

	<cffunction name="delete" access="public" output="false" returntype="void">
		<cfargument name="table" required="true" type="string" />
		<cfargument name="id" required="true" type="string" />

		<cfif arguments.id neq "">
			
			<cfset table = getTable(table) />
			
			<cfif structKeyExists(table.fields, "is_deleted")>
				
				<cfset var record = {} />
				<cfset record[table.id] = id />
				<cfset record["is_deleted"] = 1 />
				
				<cfset save(table, record) />
				
			<cfelse>
				
				<cfquery>
					delete from [#table.name#]
					where #table.id# = <cfqueryparam value="#arguments.id#" cfsqltype="#table.validate#" />
				</cfquery>
				
			</cfif>

		</cfif>

	</cffunction>

	<!------>
	
	<cffunction name="parseArguments" access="private" output="false" returntype="struct">
		<cfargument name="args" required="true" type="struct" />
		
		<cfset var i = "" />

		<cfset var table = getTable(args.table) />
		<cfset var primary_key = "" />
		<cfif structKeyExists(args.fields, table.id)>
			<cfset primary_key = args.fields[table.id] />
		</cfif>

		<cfset var fields = {} />
		
		<cfif primary_key eq "">
			
			<cfif structKeyExists(table.fields, "is_deleted") and not structKeyExists(args.fields, "is_deleted")>
				<cfset args.fields.is_deleted = 0 />
			</cfif>
			
			<cfif structKeyExists(table.fields, "created_on") and not structKeyExists(args.fields, "created_on")>
				<cfset args.fields.created_on = coldmvc.date.get() />
			</cfif>
			
			<cfif structKeyExists(table.fields, "created_by") and not structKeyExists(args.fields, "created_by")>
				<cfset args.fields.created_by = coldmvc.user.id() />
			</cfif>
			
		</cfif>
		
		<cfif structKeyExists(table.fields, "updated_on") and not structKeyExists(args.fields, "updated_on")>
			<cfset args.fields.updated_on = coldmvc.date.get() />
		</cfif>
		
		<cfif structKeyExists(table.fields, "updated_by") and not structKeyExists(args.fields, "updated_by")>
			<cfset args.fields.updated_by = coldmvc.user.id() />
		</cfif>
		
		<cfloop collection="#args.fields#" item="i">

			<cfif structKeyExists(table.fields, i) and i neq table.id>
				
				<cfset var field = {} />
				<cfset field.name = table.fields[i].name />
				<cfset field.type = table.fields[i].type />
				<cfset field.validate = table.fields[i].validate />
				<cfset field.value = trim(args.fields[i]) />

				<cfif field.type eq "datetime">

					<cfif coldmvc.valid.date(field.value)>
						<cfset field.value = createODBCDateTime(field.value) />
					<cfelse>
						<cfset field.value = "" />
					</cfif>

				<cfelseif field.type eq "uniqueidentifier">

					<cfif not coldmvc.valid.guid(field.value)>
						<cfset field.value = "" />
					</cfif>

				<cfelseif field.type eq "bit">

					<cfif not coldmvc.valid.boolean(field.value)>
						<cfset field.value = "" />
					</cfif>

				<cfelseif listFindNoCase("int,smallint", field.type)>

					<cfif not coldmvc.valid.integer(field.value)>
						<cfset field.value = "" />
					</cfif>

				</cfif>

				<cfset fields[field.name] = field />

			</cfif>

		</cfloop>

		<cfset var result = {} />
		<cfset result.table = table.name />
		<cfset result.key = table.id />
		<cfset result.type = table.type />
		<cfset result.validate = table.validate />
		<cfset result.id = primary_key />
		<cfset result.fields = fields />
		<cfset result.count = structCount(result.fields) />

		<cfreturn result />

	</cffunction>
	
	<!------>
	
	<cffunction name="getTable" access="private" output="false" returntype="struct">
		<cfargument name="name" required="true" type="string" />

		<cfif not structKeyExists(variables.tables, name)>

			<cfset var primary_key = getPrimaryKey(name) />

			<cfset var table = {} />
			<cfset table.name = name />
			<cfset table.id = primary_key.name />
			<cfset table.type = primary_key.type />
			<cfset table.validate = getValidationType(table.type) />
			<cfset table.fields = getFields(table.name) />

			<cfset variables.tables[name] = table />

		</cfif>

		<cfreturn variables.tables[name] />

	</cffunction>

	<!------>
	
	<cffunction name="getPrimaryKey" access="private" output="false" returntype="query">
		<cfargument name="table" required="true" type="string" />

		<cfset var query = "" />

		<cfquery name="query">
			select syscolumns.name, systypes.name as type
			from sysindexes
			inner join sysobjects on sysindexes.id = sysobjects.id
			inner join sysobjects sysobjectspk on sysindexes.name = sysobjectspk.name and sysobjectspk.parent_obj = sysindexes.id and sysobjectspk.xtype = 'PK'
			inner join sysindexkeys on sysindexes.id = sysindexkeys.id and sysindexes.indid = sysindexkeys.indid
			inner join syscolumns on sysindexkeys.id = syscolumns.id and sysindexkeys.colid = syscolumns.colid
			inner join systypes on syscolumns.xtype = systypes.xtype
			where sysobjects.name = <cfqueryparam value="#arguments.table#" cfsqltype="cf_sql_varchar" />
		</cfquery>

		<cfreturn query />

	</cffunction>

	<!------>
	
	<cffunction name="getFields" access="private" output="false" returntype="struct">
		<cfargument name="table" required="true" />

		<cfset var records = "" />
		<cfset var fields = {} />
		<cfset var field = "" />
		<cfset var i = "" />

		<cfquery name="records">
			select lower(syscolumns.name) as name, lower(systypes.name) as type
			from sysobjects
			inner join syscolumns on sysobjects.id = syscolumns.id
			inner join systypes on syscolumns.xtype = systypes.xtype
			where sysobjects.xtype = 'U'
			and systypes.name <> 'sysname'
			and sysobjects.name = <cfqueryparam value="#arguments.table#" cfsqltype="cf_sql_varchar" />
			order by name asc, type asc
		</cfquery>

		<cfloop query="records">
			
			<cfset field = coldmvc.query.toStruct(records, currentRow) />
	
			<cfset field.validate = getValidationType(type) />
			
			<cfset fields[field.name] = field />
		
		</cfloop>

		<cfreturn fields />

	</cffunction>
	
	<!------>
	
	<cffunction name="getValidationType" access="private" output="false" returntype="string">
		<cfargument name="type" required="true" type="string" />
		
		<cfif type eq "datetime">
			<cfreturn "cf_sql_timestamp" />
		<cfelseif type eq "uniqueidentifier">
			<cfreturn "cf_sql_idstamp" />
		<cfelseif type eq "bit">
			<cfreturn "cf_sql_bit" />
		<cfelseif listFindNoCase("int,smallint", type)>
			<cfreturn "cf_sql_integer" />
		</cfif>
		
		<cfreturn "cf_sql_varchar" />
		
	</cffunction>

	<!------>
	
</cfcomponent>