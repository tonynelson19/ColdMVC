/**
 * @extends coldmvc.Helper
 */
component {

	public any function init() {

		setWords();
		setPatterns();
		return this;

	}

	/**
	 * @viewHelper singularize
	 */
	public string function singularize(required string string) {

		var length = len(arguments.string);

		if (structKeyExists(variables.plurals, arguments.string)) {
			return variables.plurals[arguments.string];
		}

		if (len(arguments.string) <= 2) {
			return addPlural(arguments.string, arguments.string);
		}

		if (length >= 4) {

			if (listFindNoCase("bies,cies,dies,fies,gies,hies,jies,kies,lies,mies,nies,pies,ries,sies,ties,vies,wies,xies,zies", right(arguments.string, 4))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 3) & "y");
			} else if (listFindNoCase("ches,shes", right(arguments.string, 4))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 2));
			} else if (listFindNoCase("zzes", right(arguments.string, 4))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 3));
			} else if (listFindNoCase("men", right(arguments.string, 3))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 3) & "man");
			}

		}

		if (length >= 3) {
			if (listFindNoCase("ses,zes,xes", right(arguments.string, 3))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 2));
			}
		}

		if (length >= 2) {
			if (listFindNoCase("ae", right(arguments.string, 2))) {
				return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 1));
			}
		}

		if (right(arguments.string, 1) == "i") {
			return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 1) & "us");
		}

		if (right(arguments.string, 1) == "s") {
			return addPlural(arguments.string, left(arguments.string, len(arguments.string) - 1));
		}

		return addPlural(arguments.string, arguments.string);

	}

	/**
	 * @viewHelper pluralize
	 */
	public string function pluralize(required string string, numeric count="0") {

		if (arguments.count == 1) {
			return singularize(arguments.string);
		}

		if (structKeyExists(variables.singulars, arguments.string)) {
			return variables.singulars[arguments.string];
		}

		var i = "";

		for (i = 1; i <= arrayLen(patterns); i++) {

			if (reFindNoCase(patterns[i].key, arguments.string)) {

				var pattern = createObject("java", "java.util.regex.Pattern").compile(javaCast("string", patterns[i].key));
				var matcher = pattern.matcher(javaCast("string", arguments.string));

				return addSingular(arguments.string, matcher.replaceAll(patterns[i].string));

			}

		}

		return addSingular(arguments.string, arguments.string);

	}

	public string function addPlural(required string key, required any value) {

		return setAndReturn(variables.plurals, arguments.key, arguments.value);

	}

	public string function addSingular(required string key, required any value) {

		return setAndReturn(variables.singulars, arguments.key, arguments.value);

	}

	private string function setAndReturn(required struct data, required string key, required string value) {

		arguments.data[arguments.key] = arguments.value;

		return arguments.value;

	}

	/**
	 * @viewHelper singularOrPlural
	 */
	public string function singularOrPlural(required numeric value, required string singularPhrase, string pluralPhrase, string zeroPhrase) {

		if (arguments.value == 1) {

			return arguments.singularPhrase;

		} else if (arguments.value == 0) {

			if (!structKeyExists(arguments, "pluralPhrase")) {
				arguments.pluralPhrase = pluralize(arguments.singularPhrase);
			}

			if (!structKeyExists(arguments, "zeroPhrase")) {
				arguments.zeroPhrase = arguments.pluralPhrase;
			}

			return arguments.zeroPhrase;

		} else {

			if (!structKeyExists(arguments, "pluralPhrase")) {
				arguments.pluralPhrase = pluralize(arguments.singularPhrase);
			}

			return arguments.pluralPhrase;

		}

	}

	/**
	 * @viewHelper propercase
	 */
	public string function capitalize(required string string) {

		var i = "";

	    arguments.string = ucase(arguments.string);
	    arguments.string = replace(arguments.string, "_", " ", "all");
	    arguments.string = replace(arguments.string, "-", " ", "all");

		var list = "A,AN,OF";
		var i = "";

		for (i = 1; i <= listLen(list); i++) {
			arguments.string = replace(arguments.string," #listGetAt(list, i)# ", " #lcase(listGetAt(list, i))# ", "all");
		}

	    arguments.string = reReplace(arguments.string, "([[:upper:]])([[:upper:]]*)", "\1\L\2\E", "all");

	    return trim(arguments.string);

	}

	public string function pascalize(required string string) {

		arguments.string = replace(arguments.string, "_", " ", "all");
		arguments.string = replace(arguments.string, "-", " ", "all");

		if (find(" ", arguments.string)) {

			var array = listToArray(arguments.string, " ");
			var i = "";

			for (i = 1; i <= arrayLen(array); i++) {
				array[i] = upperfirst(array[i]);
			}

			arguments.string = arrayToList(array, "");

		} else {
			arguments.string = upperfirst(arguments.string);
		}

	    return arguments.string;

	}

	public string function camelize(required string string) {

		return lowerfirst(pascalize(arguments.string));

	}

	public string function upperfirst(required string string) {

		var remainder = len(arguments.string) - 1;

		if (remainder > 0) {
			arguments.string = ucase(left(arguments.string, 1)) & right(arguments.string, remainder);
		} else {
			arguments.string = ucase(arguments.string);
		}

		return arguments.string;

	}

	public string function lowerfirst(required string string) {

		var remainder = len(arguments.string) - 1;

		if (remainder > 0) {
			arguments.string = lcase(left(arguments.string, 1)) & right(arguments.string, remainder);
		} else {
			arguments.string = lcase(arguments.string);
		}

		return arguments.string;

	}

	/**
	 * @viewHelper humanize
	 */
	public string function humanize(required string string) {

		if (arguments.string != "") {

			arguments.string = capitalize(arguments.string);

			if (len(arguments.string) > 1) {
				arguments.string = left(arguments.string, 1) & lcase(right(arguments.string, len(arguments.string) - 1));
			}

		}

		return arguments.string;

	}

	/**
	 * @viewHelper propercase
	 */
	public string function propercase(required string string) {

		return capitalize(uncamelize(arguments.string));
	}

	public string function slugify(required string string) {

		arguments.string = lcase(trim(arguments.string));
		arguments.string = replace(arguments.string, "'", "", "all");
	    arguments.string = reReplace(arguments.string, "[^a-z0-9-]", "-", "all");
	    arguments.string = reReplace(arguments.string, "-+", "-", "all");

	    if (left(arguments.string, 1) == "-") {
	        arguments.string = right(arguments.string, len(arguments.string) - 1);
		}

		if (right(arguments.string, 1) == "-") {
			arguments.string = left(arguments.string, len(arguments.string) - 1);
		}

		return arguments.string;

	}

	public string function underscore(required string string) {

		arguments.string = replace(arguments.string, " ", "_", "all");
		arguments.string = replace(arguments.string, "-", "_", "all");

		var array = [];
		var i = "";

		for (i = 1; i <= len(arguments.string); i++) {

			var char = mid(arguments.string, i, 1);

			if (i == 1) {
    			arrayAppend(array, ucase(char));
   			} else {
    			if (reFind("[A-Z]", char)) {
     				arrayAppend(array, "_" & char);
   				} else {
     				arrayAppend(array, lcase(char));
    			}
   			}
  		}

		arguments.string = trim(lcase(arrayToList(array, "")));

	    return replace(arguments.string, "__", "_", "all");

	}

	public string function uncamelize(required string string) {

		return humanize(underscore(arguments.string));

	}

	/**
	 * @viewHelper truncate
	 */
	public string function truncate(required string string, numeric length=50) {

		if (len(arguments.string) > arguments.length) {
			return left(arguments.string, arguments.length) & "...";
		} else {
			return arguments.string;
		}

	}

	public string function isLower(required string string) {

		return compare(arguments.string, lcase(arguments.string)) == 0;

	}

	public string function isUpper(required string string) {

		return compare(arguments.string, ucase(arguments.string)) == 0;

	}

	public boolean function startsWith(required string string, required string substring) {

		return left(arguments.string, len(arguments.substring)) == arguments.substring;

	}

	public boolean function endsWith(required string string, required string substring) {

		return right(arguments.string, len(arguments.substring)) == arguments.substring;

	}

	public array function toArray(required string string, string delimeter=",") {

		var array = listToArray(arguments.string, arguments.delimeter);
		var i = "";

		for (i = 1; i <= arrayLen(array); i++) {
			array[i] = trim(array[i]);
		}

		return array;

	}

	public string function toOrdinal(required string string) {

		var lastTwo = right(arguments.string, 2);

		if (listFind("11,12,13", lastTwo)) {
			var check = lastTwo;
		} else {
			var check = right(arguments.string, 1);
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

		return arguments.string & ordinal;

	}

	private string function setWords() {

		var words = {};
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

		variables.singulars = words;
		variables.plurals = {};

		var i = "";
		for (i in words) {
			variables.plurals[words[i]] = i;
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