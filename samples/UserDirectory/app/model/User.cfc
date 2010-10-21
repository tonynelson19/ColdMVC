/**
 * @extends coldmvc.Model
 * @persistent true
 */
component  {

	property id;
	property firstName;
	property lastName;
	property email;
	property birthDate;

	function getName() {
		return firstName & " " & lastName;
	}

}