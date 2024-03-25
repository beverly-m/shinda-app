import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_provider.dart';
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show Session, User;
import 'package:test/test.dart';

void main() {
  group("Mock Authentication Test", () {
    final provider = MockAuthProvider();

    test("Authentication provider should not be initialized at first", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if authentication provider is not initialised", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Cannot log in if authentication provider is not initialised", () {
      expect(
        provider.logInEmailPassword(
          email: "exampleuser@email.com",
          password: "root123!",
        ),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Cannot create user if authentication provider is not initialised",
        () {
      expect(
        provider.createUser(
          email: "exampleuser@email.com",
          password: "root123!",
          data: {"full_name": "Jane Doe"},
        ),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Authentication provider can be initialised", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User is null after initialising authentication provider", () {
      expect(provider.currentUser, null);
    });

    test("Create user (register) should validate user input", () async {
      // email already exists
      expect(
        provider.createUser(
          email: "existinguser@email.com",
          password: "root123!",
          data: {"full_name": "Jane Doe"},
        ),
        throwsA(const TypeMatcher<EmailAlreadyInUseAuthException>()),
      );

      // invalid email
      expect(
        provider.createUser(
          email: "foo@",
          password: "root123!",
          data: {"full_name": "Foo bar"},
        ),
        throwsA(const TypeMatcher<InvalidEmailAuthException>()),
      );

      // short password
      expect(
        provider.createUser(
          email: "example@email.com",
          password: "roo",
          data: {"full_name": "Jane Doe"},
        ),
        throwsA(const TypeMatcher<PasswordTooShortAuthException>()),
      );

      // empty email
      expect(
        provider.createUser(
          email: "",
          password: "root123!",
          data: {"full_name": "Jane Doe"},
        ),
        throwsA(const TypeMatcher<NoEmailProvidedAuthException>()),
      );

      // empty password
      expect(
        provider.createUser(
          email: "example@email.com",
          password: "",
          data: {"full_name": "Jane Doe"},
        ),
        throwsA(const TypeMatcher<NoPasswordProvidedAuthException>()),
      );

      // empty data (no full name provided)
      expect(
        provider.createUser(
          email: "example@email.com",
          password: "root123!",
          data: {},
        ),
        throwsA(const TypeMatcher<NoDataProvidedAuthException>()),
      );
    });

    test("Create user returns a user object", () async {
      final user = await provider.createUser(
        email: "example@email.com",
        password: "root123!",
        data: {"full_name": "Jane Doe"},
      );

      expect(provider.currentUser, user);
    });

    test("Newly registered user email is not automatically verified", () {
      expect(provider.currentUser!.isEmailVerified, false);
    });

    test("User with unverified email cannot log in", () async {
      expect(
          provider.logInEmailPassword(
            email: "example@email.com",
            password: "root123!",
          ),
          throwsA(const TypeMatcher<UnverifiedUserAuthException>()));
    });

    test("User can be verified", () async {
      await provider.sendEmailVerification();
      final user = provider.currentUser;

      expect(user, isNotNull);

      expect(user!.isEmailVerified, true);
    });

    test("Log in should validate user input", () async {
      // empty password
      expect(
        provider.logInEmailPassword(
          email: "example@email.com",
          password: "",
        ),
        throwsA(const TypeMatcher<NoPasswordProvidedAuthException>()),
      );
      // empty email
      expect(
        provider.logInEmailPassword(
          email: "",
          password: "root123!",
        ),
        throwsA(const TypeMatcher<NoEmailProvidedAuthException>()),
      );

      // short password
      expect(
        provider.logInEmailPassword(
          email: "example@email.com",
          password: "ro",
        ),
        throwsA(const TypeMatcher<PasswordTooShortAuthException>()),
      );

      // invalid password
      expect(
        provider.logInEmailPassword(
          email: "example@email.com",
          password: "somepassword123!",
        ),
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      // email does not exist
      expect(
        provider.logInEmailPassword(
          email: "strange@email.com",
          password: "root123!",
        ),
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      // invalid email
      expect(
        provider.logInEmailPassword(
          email: "foo@",
          password: "root123!",
        ),
        throwsA(const TypeMatcher<InvalidEmailAuthException>()),
      );
    });

    test("Logged in user should have a session", () async {
      await provider.logInEmailPassword(
        email: "example@email.com",
        password: "root123!",
      );

      expect(provider.currentSession, isNotNull);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logOut();

      expect(provider.currentUser, null);

      expect(provider.currentSession, null);

      await provider.logInEmailPassword(
        email: "example@email.com",
        password: "root123!",
      );

      expect(provider.currentUser, isNotNull);

      expect(provider.currentSession, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class PasswordTooShortAuthException implements Exception {}

class NoDataProvidedAuthException implements Exception {}

class NoEmailProvidedAuthException implements Exception {}

class NoPasswordProvidedAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  bool _isInitialized = false;
  Session? _currentSession;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    if (email == "existinguser@email.com") {
      throw EmailAlreadyInUseAuthException();
    }

    if (password.isNotEmpty && password.length < 8) {
      throw PasswordTooShortAuthException();
    }

    if (email.isEmpty) throw NoEmailProvidedAuthException();

    if (password.isEmpty) throw NoPasswordProvidedAuthException();

    if (data.isEmpty) throw NoDataProvidedAuthException();

    await Future.delayed(const Duration(seconds: 1));

    return logInEmailPassword(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> logInEmailPassword({
    required email,
    required password,
  }) async {
    if (!isInitialized) throw NotInitializedException();

    await Future.delayed(const Duration(seconds: 1));

    if (password.isNotEmpty && password.length < 8) {
      throw PasswordTooShortAuthException();
    }

    if (email.isEmpty) throw NoEmailProvidedAuthException();

    if (password.isEmpty) throw NoPasswordProvidedAuthException();

    if (email == 'strange@email.com') throw InvalidCredentialAuthException();

    if (email == 'foo@') throw InvalidEmailAuthException();

    if (password != 'root123!') throw InvalidCredentialAuthException();

    if (currentUser != null) {
      if (!currentUser!.isEmailVerified) throw UnverifiedUserAuthException();
    }

    const user = AuthUser(
      isEmailVerified: false,
      email: 'example@email.com',
      fullName: 'Jane Doe',
      id: '33110ad8-3b28-4532-9d43-39c31cf9286c',
    );
    _user = user;
    _currentSession = Session(
        accessToken: "accessToken",
        tokenType: "tokenType",
        user: const User(
          id: "id",
          appMetadata: {"appMetadata": "appMetadata"},
          userMetadata: {"userMetadata": "userMetadata"},
          aud: "aud",
          createdAt: "createdAt",
        ));
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
    _currentSession = null;
  }

  @override
  Future<void> refreshUserCredentials() async {
    if (!isInitialized) throw NotInitializedException();
    const newUser = AuthUser(
      isEmailVerified: true,
      email: 'example@email.com',
      fullName: 'Jane Doe',
      id: '33110ad8-3b28-4532-9d43-39c31cf9286c',
    );
    _user = newUser;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await refreshUserCredentials();
  }

  @override
  Session? get currentSession => _currentSession;
}
