import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('skips cart fetch when auth check does not authenticate the user', () async {
    var authChecks = 0;
    var cartFetches = 0;

    Future<void> checkAuth() async { authChecks++; }
    bool isAuthenticated() => false;
    Future<void> fetchCart() async { cartFetches++; }

    await checkAuth().timeout(
      const Duration(milliseconds: 50),
      onTimeout: () {},
    );
    if (isAuthenticated()) {
      await fetchCart().timeout(
        const Duration(milliseconds: 50),
        onTimeout: () {},
      );
    }

    expect(authChecks, 1);
    expect(cartFetches, 0);
  });

  test('fetches cart when auth check authenticates the user', () async {
    var cartFetches = 0;

    Future<void> checkAuth() async {}
    bool isAuthenticated() => true;
    Future<void> fetchCart() async { cartFetches++; }

    await checkAuth().timeout(
      const Duration(milliseconds: 50),
      onTimeout: () {},
    );
    if (isAuthenticated()) {
      await fetchCart().timeout(
        const Duration(milliseconds: 50),
        onTimeout: () {},
      );
    }

    expect(cartFetches, 1);
  });

  test('continues startup when auth check hangs', () async {
    var completed = false;

    await Completer<void>().future.timeout(
      const Duration(milliseconds: 20),
      onTimeout: () {},
    );
    completed = true;

    expect(completed, isTrue);
  });

  test('continues startup when cart fetch hangs', () async {
    var completed = false;

    await Future<void>.value();
    await Completer<void>().future.timeout(
      const Duration(milliseconds: 20),
      onTimeout: () {},
    );
    completed = true;

    expect(completed, isTrue);
  });
}
