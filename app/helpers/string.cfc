/**
 * @extends coldmvc.Helper
 */
component {

	public any function init() {
		setWords();
		setPatterns();
		return this;
	}

	public string function singularize(required string string) {

		var length = len(string);

		if (structKeyExists(plurals, string)) {
			return plurals[string];
		}

		if (len(string) <= 2) {
			return setAndReturn(plurals, string, string);
		}

		if (length >= 4) {

			if (listFindNoCase("bies,cies,dies,fies,gies,hies,jies,kies,lies,mies,nies,pies,ries,sies,ties,vies,wies,xies,zies", right(string, 4))) {
				return setAndReturn(plurals, string, left(string, len(string)-3) & "y");
			}
			else if (listFindNoCase("ches,shes", right(string, 4))) {
				return setAndReturn(plurals, string, left(string, len(string)-2));
			}
			else if (listFindNoCase("zzes", right(string, 4))) {
				return setAndReturn(plurals, string, left(string, len(string)-3));
			}
			else if (listFindNoCase("men", right(string, 3))) {
				return setAndReturn(plurals, string, left(string, len(string)-3) & "man");
			}

		}

		if (length >= 3) {

			if (listFindNoCase("ses,zes,xes", right(string, 3))) {
				return setAndReturn(plurals, string, left(string, len(string)-2));
			}

		}

		if (length >= 2) {

			if (listFindNoCase("ae", right(string, 2))) {
				return setAndReturn(plurals, string, left(string, len(string)-1));
			}

		}

		if (right(string, 1) == "i") {
			return setAndReturn(plurals, string, left(string, len(string)-1) & "us");
		}

		if (right(string, 1) == "s") {
			return setAndReturn(plurals, string, left(string, len(string)-1));
		}

		return setAndReturn(plurals, string, string);

	}

	public string function pluralize(required string string, numeric count="0") {

		var i = "";

		if (count == 1) {
			return singularize(string);
		}

		if (structKeyExists(singulars, string)) {
			return singulars[string];
		}

		for (i = 1; i <= arrayLen(patterns); i++) {

			if (reFindNoCase(patterns[i].key, string)) {

				var pattern = createObject("java", "java.util.regex.Pattern").compile(javaCast("string", patterns[i].key));

				var matcher = pattern.matcher(javaCast("string", string));

				return setAndReturn(singulars, string, matcher.replaceAll(patterns[i].string));

			}

		}

		return setAndReturn(singulars, string, string);

	}

	private string function setAndReturn(required struct data, required string key, required any string) {

		data[key] = string;

		return string;

	}

	public string function capitalize(required string string) {

		var i = "";

	    string = ucase(string);

	    string = replace(string, "_", " ", "all");

		var list = "A,AN,OF";
		for (i = 1; i <= listLen(list); i++) {
			string = replace(string," #listGetAt(list, i)# ", " #lcase(listGetAt(list, i))# ", "all");
		}

	    string = reReplace(string, "([[:upper:]])([[:upper:]]*)", "\1\L\2\E", "all");

	    return trim(string);

	}

	public string function pascalize(required string string) {

		string = replace(string, "_", " ", "all");

		if (find(" ", string)) {

			var array = listToArray(string, " ");

			for (i = 1; i <= arrayLen(array); i++) {
				array[i] = upperfirst(array[i]);
			}

			string = arrayToList(array, "");

		}
		else {
			string = upperfirst(string);
		}

	    return string;

	}

	public string function camelize(required string string) {

		return lowerfirst(pascalize(string));

	}

	public string function upperfirst(required string string) {

		var remainder = len(string) - 1;

		if (remainder > 0) {
			string = ucase(left(string, 1)) & right(string, remainder);
		}
		else {
			string = ucase(string);
		}

		return string;

	}

	public string function lowerfirst(required string string) {

		var remainder = len(string) - 1;

		if (remainder > 0) {
			string = lcase(left(string, 1)) & right(string, remainder);
		}
		else {
			string = lcase(string);
		}

		return string;

	}

	public string function humanize(required string string) {

		if (string != "") {

			string = capitalize(string);

			if (len(string) > 1) {
				string = left(string, 1) & lcase(right(string, len(string)-1));
			}

		}

		return string;

	}

	public string function slugify(required string string) {

		string = lcase(trim(string));
		string = replace(string, "'", "", "all");
	    string = reReplace(string, "[^a-z0-9-]", "-", "all");
	    string = reReplace(string, "-+", "-", "all");

	    if (left(string, 1) == "-") {
	        string = right(string, len(string)-1);
		}

		if (right(string, 1) == "-") {
			 string = left(string, len(string)-1);
		}

		return string;

	}

	public string function underscore(required string string) {

		var array = [];
		var i = "";

		for (i = 1; i <= len(string); i++) {

			var char = mid(string, i, 1);

			if (i == 1) {
    			arrayAppend(array, ucase(char));
   			}
   			else {
    			if (reFind("[A-Z]", char)) {
     				arrayAppend(array, "_" & char);
   				}
    			else {
     				arrayAppend(array, lcase(char));
    			}
   			}
  		}

  		var name = arrayToList(array, "");

  		return trim(lcase(name));

	}

	public string function uncamelize(required string string) {

		return humanize(underscore(string));

	}

	public string function isLower(required string string) {

		return compare(string, lcase(string)) == 0;

	}

	public string function isUpper(required string string) {

		return compare(string, ucase(string)) == 0;

	}

	public boolean function startsWith(required string string, required string substring) {

		return left(string, len(substring)) == substring;

	}

	public boolean function endsWith(required string string, required string substring) {

		return right(string, len(substring)) == substring;

	}

	public array function toArray(required string string, string delimeter=",") {

		var array = listToArray(string, delimeter);
		var i = "";

		for (i = 1; i <= arrayLen(array); i++) {
			array[i] = trim(array[i]);
		}

		return array;

	}

	public string function toOrdinal(required string string) {

		var lastTwo = right(string, 2);

		if (listFind("11,12,13", lastTwo)) {
			var check = lastTwo;
		}
		else {
			var check = right(string, 1);
		}

		var ordinal = "th";

		// 1st, 2nd, 3rd, everything else is "th"
		switch(check) {
			case "1": {
				ordinal = "st";
				break;
			}
			case "2": {
				ordinal = "nd";
				break;
			}
			case "3": {
				ordinal = "rd";
				break;
			}
		}

		return string & ordinal;

	}

	private string function setWords() {

		var words = {};
		var i = "";

		words["advice"] = "advice";
		words["afterlife"] = "afterlives";
		words["air"] = "air";
		words["analysis"] = "analyses";
		words["appendix"] = "appendices";
		words["axis"] = "axes";
		words["basis"] = "bases";
		words["bedouin"] = "bedouin";
		words["blood"] = "blood";
		words["buzz"] = "buzzes";
		words["calf"] = "calves";
		words["cherub"] = "cherubim";
		words["child"] = "children";
		words["cod"] = "cod";
		words["cookie"] = "cookies";
		words["criterion"] = "criteria";
		words["curriculum"] = "curricula";
		words["datum"] = "data";
		words["deer"] = "deer";
		words["diagnosis"] = "diagnoses";
		words["die"] = "dice";
		words["dormouse"] = "dormice";
		words["elf"] = "elves";
		words["elk"] = "elk";
		words["equipment"] = "equipment";
		words["erratum"] = "errata";
		words["family"] = "families";
		words["fish"] = "fish";
		words["food"] = "food";
		words["foot"] = "feet";
		words["fox"] = "foxes";
		words["furniture"] = "furniture";
		words["garbage"] = "garbage";
		words["genie"] = "genii";
		words["genus"] = "genera";
		words["goose"] = "geese";
		words["graffiti"] = "graffiti";
		words["grass"] = "grass";
		words["grouse"] = "grouse";
		words["hake"] = "hake";
		words["half"] = "halves";
		words["headquarters"] = "headquarters";
		words["hippo"] = "hippos";
		words["homework"] = "homework";
		words["hoof"] = "hooves";
		words["housewife"] = "housewives";
		words["housework"] = "housework";
		words["hypothesis"] = "hypotheses";
		words["index"] = "indices";
		words["information"] = "information";
		words["jackknife"] = "jackknives";
		words["knife"] = "knives";
		words["knowledge"] = "knowledge";
		words["labium"] = "labia";
		words["leaf"] = "leaves";
		words["life"] = "lives";
		words["loaf"] = "loaves";
		words["louse"] = "lice";
		words["luggage"] = "luggage";
		words["man"] = "men";
		words["mathematics"] = "mathematics";
		words["matrix"] = "matrices";
		words["meat"] = "meat";
		words["memorandum"] = "memoranda";
		words["midwife"] = "midwives";
		words["milk"] = "milk";
		words["millennium"] = "millennia";
		words["money"] = "money";
		words["moose"] = "moose";
		words["mouse"] = "mice";
		words["music"] = "music";
		words["neurosis"] = "neuroses";
		words["nova"] = "novas";
		words["offspring"] = "offspring";
		words["ovum"] = "ova";
		words["ox"] = "oxen";
		words["passerby"] = "passersby";
		words["penknife"] = "penknives";
		words["person"] = "people";
		words["phenomenon"] = "phenomena";
		words["pocketknife"] = "pocketknives";
		words["pollution"] = "pollution";
		words["reindeer"] = "reindeer";
		words["research"] = "research";
		words["rhinoceros"] = "rhinoceros";
		words["rice"] = "rice";
		words["roe"] = "roe";
		words["salmon"] = "salmon";
		words["sand"] = "sand";
		words["scarf"] = "scarves";
		words["self"] = "selves";
		words["seraph"] = "seraphim";
		words["series"] = "series";
		words["sex"] = "sexes";
		words["sheaf"] = "sheaves";
		words["sheep"] = "sheep";
		words["shelf"] = "shelves";
		words["soap"] = "soap";
		words["software"] = "software";
		words["species"] = "species";
		words["spectrum"] = "spectra";
		words["stratum"] = "strata";
		words["sugar"] = "sugar";
		words["supernova"] = "supernovas";
		words["swine"] = "swine";
		words["thesis"] = "theses";
		words["thief"] = "thieves";
		words["tooth"] = "teeth";
		words["traffic"] = "traffic";
		words["transportation"] = "transportation";
		words["trash"] = "trash";
		words["travel"] = "travel";
		words["trout"] = "trout";
		words["water"] = "water";
		words["wife"] = "wives";
		words["wildebeest"] = "wildebeest";
		words["wolf"] = "wolves";
		words["yen"] = "yen";

		singulars = words;
		plurals = {};

		for (i in words) {
			plurals[words[i]] = i;
		}

	}

	private void function setPatterns() {

		patterns = [];

		addPattern("(.*)fe?$", "$1ves");
		addPattern("(.*)man$", "$1men");
		addPattern("(.+[aeiou]y)$", "$1s");
		addPattern("(.+[^aeiou])y$", "$1ies");
		addPattern("(.+z)$", "$1zes");
		addPattern("([m|l])ouse$", "$1ice");
		addPattern("(.+)(e|i)x$", "$1ices");
		addPattern("(octop|vir)us$", "$1i");
		addPattern("(.+(s|x|sh|ch))$", "$1es");
		addPattern("(.+)", "$1s");

	}

	private void function addPattern(string key, string string) {
		arrayAppend(patterns, arguments);
	}

}