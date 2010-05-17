/**
 * @extends coldmvc.Helper
 */
component {

	public string function get(required xml xml, required string key, string def="") {
	
		var value = def;
		
		if (structKeyExists(xml, key)) {
			value = xml[key].xmlText;
		}
		else if (structKeyExists(xml, "xmlAttributes") && structKeyExists(xml.xmlAttributes, key)) {
			value = xml.xmlAttributes[key];
		}
		
		return value;
	
	}
	
	public string function format(required any xml) {
		
		var elem = "";
		var result = "";
		var tab = " ";
		var att = "";
		var i = 0;
		var temp = "";
		var cr = createObject("java","java.lang.System").getProperty("line.separator");

		if (isXmlDoc(xml)) {
			elem = xml.xmlRoot; //If this is an XML Document, use the root element
		} 
		else if (isXmlElem(xml)) {
			elem = xml; //If this is an XML Document, use it as-as
		} 
		else if (not isXmlDoc(xml)) {
			xml = reReplace(xml, "^[^<]*", "", "all" );
			xml = xmlParse(xml); //Otherwise, try to parse it as an XML string
			elem = xml.xmlRoot; //Then use the root of the resulting document
		}
		
		//Now we are just working with an XML element
		result = "<#elem.xmlName#"; //start with the element name
		if (structKeyExists(elem, "xmlAttributes")) { //Add any attributes
			
			for (att in elem.xmlAttributes) {
				result = '#result# #att#="#xmlFormat(elem.xmlAttributes[att])#"';
			}
			
		}		
		
		if (len(elem.xmlText) or (structKeyExists(elem, "xmlChildren") and arrayLen(elem.xmlChildren) > 0)) {
			
			result = "#result#>"; //Add a carriage return for text/nested elements
			
			if (len(trim(elem.xmlText))) { //Add any text in this element
				result = "#cr##result##xmlFormat(trim(elem.xmlText))#";
			}
			else {
				result = "#cr##result##cr#";
			}
			
			if (structKeyExists(elem, "xmlChildren") and arrayLen(elem.xmlChildren) > 0) {
				
				for (i = 1; i <= arrayLen(elem.xmlChildren); i++) {
					temp = trim(format(elem.xmlChildren[i]));
					temp = "#tab##ReplaceNoCase(trim(temp), cr, '#cr##tab#', 'all')#"; //indent
					result = "#result##temp##cr#";
				}
				//Add each nested-element (indented) by using recursive call
				
			}
			
			result = "#result#</#elem.xmlName#>"; //Close element
		} 
		else {
			result = "#result# />"; //self-close if the element doesn't contain anything
		}

		return trim(result);
		
	}

}