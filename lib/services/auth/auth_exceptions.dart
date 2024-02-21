// login exceptions
class InvalidCredentialAuthException implements Exception {}

class UnverifiedUserAuthException implements Exception {}

// register exceptions
class WeakPasswordAuthException implements Exception {}

class EmailAlreadyInUseAuthException implements Exception {}

// login and register exceptions

class InvalidEmailAuthException implements Exception {}

// general firebase exceptions

class NetworkRequestedFailedAuthException implements Exception {}

class UserNotLoggedInAuthException implements Exception {}

// generic exceptions

class GenericAuthException implements Exception {}
