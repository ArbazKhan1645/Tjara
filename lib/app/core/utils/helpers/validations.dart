extension Validator on String {
  bool isValidEmail() {
    return RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$')
        .hasMatch(this);
  }

  bool isValiedPassword() {
    return RegExp(
            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~.]).{6,}$')
        .hasMatch(this);
  }

  bool isValidPhone() {
    return RegExp(
            r'^(\+?(?:[0-9]?){1,3}[-.\s]?)(\(?\d{1,4}\)?[-.\s]?)([0-9][0-9-. ]{6,11})((?:[0-9]{1,2})?)$')
        .hasMatch(this);
  }
}
