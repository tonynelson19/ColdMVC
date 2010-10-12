/**
 * @accessors true
 * @extends coldmvc.Controller
 */
component {

	property _User;
	property _Role;

	function index() {

		var admin = _Role.findByName("Admin");

		if (!admin.exists()) {
			admin.name("Admin");
			admin.save();
		}

		var basic = _Role.findByName("Basic");

		if (!basic.exists()) {
			basic.name("Basic");
			basic.save();
		}

		var user = _User.findByUserName("tonynelson19");

		if (!user.exists()) {

			user.populate({
				firstName = "Tony",
				lastName = "Nelson",
				userName = "tonynelson19",
				roles = [admin, basic]
			});

			user.save();

		}

		var user = _User.findByUserName("johndoe");

		if (!user.exists()) {

			user.populate({
				firstName = "John",
				lastName = "Doe",
				userName = "johndoe",
				roles = [basic]
			});

			user.save();

		}

	}

	function guest() {
		$.user.clearID();
		redirect({action="index"});
	}

	function basic() {
		var user = _User.findByUserName("johndoe");
		$.user.id(user.id());
		redirect({action="index"});
	}

	function admin() {
		var user = _User.findByUserName("tonynelson19");
		$.user.id(user.id());
		redirect({action="index"});
	}

}