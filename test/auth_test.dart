import 'package:shinda_app/services/auth/auth_exceptions.dart';
import 'package:shinda_app/services/auth/auth_provider.dart';
import 'package:shinda_app/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() {
  group("Mock Authentication", () {
    final provider = MockAuthProvider();

    test("Provider should not be initialized at first", () {
      expect(provider.isInitialized, false);
    });

    test("Cannot log out if provider is not initialised", () {
      expect(
        provider.logOut(),
        throwsA(const TypeMatcher<NotInitializedException>()),
      );
    });

    test("Provider can be initialised", () async {
      await provider.initialize();
      expect(provider.isInitialized, true);
    });

    test("User is null after initialising provider", () {
      expect(provider.currentUser, null);
    });

    test(
      "Can initialise in less than 2 seconds",
      () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      },
      timeout: const Timeout(Duration(seconds: 2)),
    );

    test("Create user should delegate to log in function", () async {
      final unavailableEmailUser = provider.createUser(
        email: "foo@bar.com",
        password: "root123",
      );

      expect(
        unavailableEmailUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      final invalidEmailUser = provider.createUser(
        email: "foo@",
        password: "root123",
      );

      expect(
        invalidEmailUser,
        throwsA(const TypeMatcher<InvalidEmailAuthException>()),
      );

      final wrongPasswordUser = provider.createUser(
        email: "someone@bar.com",
        password: "foobar",
      );

      expect(
        wrongPasswordUser,
        throwsA(const TypeMatcher<InvalidCredentialAuthException>()),
      );

      final user = await provider.createUser(
        email: "someone@bar.com",
        password: "root123",
      );

      expect(provider.currentUser, user);

      expect(user.isEmailVerified, false);
    });

    test("Logged in user can be verified", () {
      provider.sendEmailVerification();
      final user = provider.currentUser;

      expect(user, isNotNull);

      expect(user!.isEmailVerified, true);
    });

    test("Should be able to log out and log in again", () async {
      await provider.logOut();

      expect(provider.currentUser, null);

      await provider.logInEmailPassword(
        email: "email",
        password: "password",
      );

      expect(provider.currentUser, isNotNull);
    });
  });
}

class NotInitializedException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({
    required email,
    required password,
  }) async {
    if (!isInitialized) throw NotInitializedException();
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
    if (email == 'foo@bar.com') throw InvalidCredentialAuthException();
    if (email == 'foo@') throw InvalidEmailAuthException();
    if (password == 'foobar') throw InvalidCredentialAuthException();
    const user = AuthUser(isEmailVerified: false);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logOut() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> refreshUserCredentials() async {
    if (!isInitialized) throw NotInitializedException();
    const newUser = AuthUser(isEmailVerified: true);
    _user = newUser;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!isInitialized) throw NotInitializedException();
    if (_user == null) throw UserNotLoggedInAuthException();
    await refreshUserCredentials();
  }
}
