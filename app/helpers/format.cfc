component {

	/*
	 * indentXml pretty-prints XML and XML-like markup without requiring valid XML.
	 *
	 * @param xml      XML string to format. (Required)
	 * @param indent      String used for creating the indention. Defaults to a space. (Optional)
	 * @return Returns a string.
	 * @author Barney Boisvert (bboisvert@gmail.com)
	 * @version 2, July 30, 2010
	 */
	public string function html(required string html, string indent="  ") {

		arguments.html = trim(REReplace(arguments.html, "(^|>)\s*(<|$)", "\1#chr(10)#\2", "all"));
		var lines = listToArray(arguments.html, chr(10));
		var depth = 0;
		var i = "";

		for (i = 1; i <= arrayLen(lines); i++) {

			var line = trim(lines[i]);
			var isCDATAStart = left(line, 9) == "<![CDATA[";
			var isCDATAEnd = right(line, 3) == "]]>";

			if (!isCDATAStart && !isCDATAEnd && left(line, 1) == "<" && right(line, 1) == ">") {

				var isEndTag = left(line, 2) == "</";
				var isSelfClose = right(line, 2) == "/>" || rEFindNoCase("<([a-z0-9_-]*).*</\1>", line);

				if (isEndTag) {
					depth = max(0, depth - 1);
				}

				lines[i] = repeatString(arguments.indent, depth) & line;

				if (!isEndTag && !isSelfClose) {
					depth = depth + 1;
				}

			} else {

				lines[i] = repeatString(arguments.indent, depth) & line;

			}

	  	}

	  return arrayToList(lines, chr(10));

	}

	/*
	 * Formats an XML document for readability.
	 * update by Fabio Serra to CR code
	 *
	 * @param XmlDoc XML document. (Required)
	 * @return Returns a string.
	 * @author Steve Bryant (steve@bryantwebconsulting.com)
	 * @version 2, March 20, 2006
	 */
	public string function xml(required any xml) {

		var elem = "";
		var result = "";
		var tab = " ";
		var att = "";
		var i = 0;
		var temp = "";
		var cr = createObject("java", "java.lang.System").getProperty("line.separator");

		if (isXmlDoc(arguments.xml)) {
			elem = arguments.xml.xmlRoot; // If this is an XML Document, use the root element
		} else if (isXmlElem(arguments.xml)) {
			elem = arguments.xml; // If this is an XML Document, use it as-as
		} else if (not isXmlDoc(arguments.xml)) {
			arguments.xml = reReplace(arguments.xml, "^[^<]*", "", "all" );
			arguments.xml = xmlParse(arguments.xml); // Otherwise, try to parse it as an XML string
			elem = arguments.xml.xmlRoot; // Then use the root of the resulting document
		}

		// Now we are just working with an XML element
		result = "<#elem.xmlName#"; // start with the element name
		if (structKeyExists(elem, "xmlAttributes")) { // Add any attributes

			for (att in elem.xmlAttributes) {
				result = '#result# #att#="#xmlFormat(elem.xmlAttributes[att])#"';
			}

		}

		if (len(elem.xmlText) || (structKeyExists(elem, "xmlChildren") && arrayLen(elem.xmlChildren) > 0)) {

			result = "#result#>"; // Add a carriage return for text/nested elements

			if (len(trim(elem.xmlText))) { // Add any text in this element
				result = "#cr##result##xmlFormat(trim(elem.xmlText))#";
			} else {
				result = "#cr##result##cr#";
			}

			if (structKeyExists(elem, "xmlChildren") && arrayLen(elem.xmlChildren) > 0) {

				for (i = 1; i <= arrayLen(elem.xmlChildren); i++) {
					temp = trim(this.xml(elem.xmlChildren[i]));
					temp = "#tab##ReplaceNoCase(trim(temp), cr, '#cr##tab#', 'all')#"; // indent
					result = "#result##temp##cr#";
				}
				// Add each nested-element (indented) by using recursive call

			}

			result = "#result#</#elem.xmlName#>"; // Close element
		} else {
			result = "#result# />"; // self-close if the element doesn't contain anything
		}

		return trim(result);

	}

}