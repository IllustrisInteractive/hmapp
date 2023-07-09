class UserData {
  String? _f_name = "";
  String? _l_name = "";
  String? _dateOfBirth = "";
  String? _phone = "";
  String? _email = "";
  String? _address = "";
  String? profilePicture;
  static final UserData _instance = UserData._internal();

  factory UserData() {
    return _instance;
  }

  UserData._internal() {}

  void setData(String f_name, String l_name, String dateOfBirth, String phone,
      String email, String address) {
    _f_name = f_name;
    _l_name = l_name;
    _dateOfBirth = dateOfBirth;
    _phone = phone;
    _email = email;
    _address = address;
  }

  void setProfilePicture(String? url) {
    this.profilePicture = url;
  }

  String? getFName() {
    return _f_name;
  }

  String? getLName() {
    return _l_name;
  }

  String? getDate() {
    return _dateOfBirth;
  }

  String? getPhone() {
    return _phone;
  }

  String? getEmail() {
    return _email;
  }

  String? getAddress() {
    return _address;
  }
}
