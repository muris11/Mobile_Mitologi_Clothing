import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/services/api_service.dart';
import 'package:mitologi_clothing_mobile/services/profile_service.dart';

import '../helpers/test_binding.dart';
import '../helpers/test_helpers.dart';
import '../mocks/mock_api_client.dart';

void main() {
  setUpAll(() {
    initializeTestBinding();
    mockSecureStorageChannel();
  });

  group('ProfileService Tests', () {
    late MockApiClient mockClient;
    late ApiService apiService;
    late ProfileService profileService;

    setUp(() {
      // Reset storage to authenticated state
      resetToAuthenticatedState();
      mockClient = MockApiClient();
      apiService = ApiService(client: mockClient.client);
      profileService = ProfileService(apiService);
    });

    tearDown(() {
      mockClient.clear();
    });

    group('getProfile', () {
      test('returns user profile', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile',
          {'user': TestHelpers.sampleUser},
        );

        // Act
        final result = await profileService.getProfile();

        // Assert
        expect(result.id, 1);
        expect(result.name, 'Test User');
        expect(result.email, 'test@example.com');
        expect(result.phone, '08123456789');
      });

      test('throws exception when not authenticated', () async {
        // Arrange
        resetToUnauthenticatedState();

        // Act & Assert
        expect(
          () => profileService.getProfile(),
          throwsA(isA<Exception>()),
        );
      });

      test('parses profile from nested data.user payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile',
          {
            'data': {'user': TestHelpers.sampleUser}
          },
        );

        // Act
        final result = await profileService.getProfile();

        // Assert
        expect(result.id, 1);
        expect(result.email, 'test@example.com');
      });
    });

    group('updateProfile', () {
      test('updates profile successfully', () async {
        // Arrange
        final updatedUser = {
          ...TestHelpers.sampleUser,
          'name': 'Updated Name',
          'phone': '08987654321',
        };
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile',
          {'user': updatedUser},
        );

        // Act
        final result = await profileService.updateProfile(
          name: 'Updated Name',
          phone: '08987654321',
        );

        // Assert
        expect(result.name, 'Updated Name');
        expect(result.phone, '08987654321');
      });

      test('updates email successfully', () async {
        // Arrange
        final updatedUser = {
          ...TestHelpers.sampleUser,
          'email': 'newemail@example.com',
        };
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile',
          {'user': updatedUser},
        );

        // Act
        final result = await profileService.updateProfile(
          email: 'newemail@example.com',
        );

        // Assert
        expect(result.email, 'newemail@example.com');
      });

      test('throws exception on update failure', () async {
        // Arrange
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile',
          {'message': 'Email already in use'},
          statusCode: 422,
        );

        // Act & Assert
        expect(
          () => profileService.updateProfile(email: 'existing@example.com'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('changePassword', () {
      test('changes password successfully', () async {
        // Arrange
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/password',
          {'message': 'Password updated successfully'},
        );

        // Act & Assert - should not throw
        await expectLater(
          profileService.changePassword(
            currentPassword: 'oldpass123',
            newPassword: 'newpass123',
            confirmPassword: 'newpass123',
          ),
          completes,
        );
      });

      test('throws exception on wrong current password', () async {
        // Arrange
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/password',
          {'message': 'Current password is incorrect'},
          statusCode: 400,
        );

        // Act & Assert
        expect(
          () => profileService.changePassword(
            currentPassword: 'wrongpass',
            newPassword: 'newpass123',
            confirmPassword: 'newpass123',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('throws exception when passwords do not match', () async {
        // Arrange
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/password',
          {'message': 'Password confirmation does not match'},
          statusCode: 422,
        );

        // Act & Assert
        expect(
          () => profileService.changePassword(
            currentPassword: 'oldpass123',
            newPassword: 'newpass123',
            confirmPassword: 'different123',
          ),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateAvatar', () {
      test('uploads avatar successfully', () async {
        final avatarFile = await File(
          '${Directory.systemTemp.path}/mitologi_test_avatar.jpg',
        ).writeAsBytes(const [0, 1, 2]);

        expect(avatarFile.existsSync(), isTrue);
      },
          skip:
              'Multipart uploads bypass the injected mock client in ApiService.');

      test('throws exception on invalid file', () async {
        final invalidFile = await File(
          '${Directory.systemTemp.path}/mitologi_test_avatar.txt',
        ).writeAsString('not-an-image');

        expect(invalidFile.existsSync(), isTrue);
      },
          skip:
              'Multipart uploads bypass the injected mock client in ApiService.');
    });

    group('getAddresses', () {
      test('returns user addresses', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'addresses': TestHelpers.sampleAddresses},
        );

        // Act
        final result = await profileService.getAddresses();

        // Assert
        expect(result, isA<List>());
        expect(result.length, 2);
        expect(result.first.label, 'Home');
        expect(result[1].label, 'Office');
      });

      test('returns empty list when no addresses', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'addresses': []},
        );

        // Act
        final result = await profileService.getAddresses();

        // Assert
        expect(result, isEmpty);
      });

      test('parses addresses from nested data.addresses payload', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {
            'data': {'addresses': TestHelpers.sampleAddresses}
          },
        );

        // Act
        final result = await profileService.getAddresses();

        // Assert
        expect(result, hasLength(2));
        expect(result.first.recipientName, 'Test User');
      });
    });

    group('addAddress', () {
      test('adds new address successfully', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'address': TestHelpers.sampleAddress},
        );

        // Act
        final result = await profileService.addAddress(
          label: 'Home',
          recipientName: 'Test User',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          city: 'Jakarta',
          postalCode: '12345',
          isDefault: true,
        );

        // Assert
        expect(result.label, 'Home');
        expect(result.recipientName, 'Test User');
        expect(result.isDefault, true);
      });

      test('throws exception on validation error', () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'message': 'Invalid postal code'},
          statusCode: 422,
        );

        // Act & Assert
        expect(
          () => profileService.addAddress(
            label: 'Home',
            recipientName: 'Test',
            phone: '08123456789',
            address: 'Jl. Test',
            city: 'Jakarta',
            postalCode: 'invalid',
          ),
          throwsA(isA<ApiException>()),
        );
      });

      test('parses add-address result from nested data.address payload',
          () async {
        // Arrange
        mockClient.setResponse(
          'POST',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {
            'data': {'address': TestHelpers.sampleAddress}
          },
        );

        // Act
        final result = await profileService.addAddress(
          label: 'Home',
          recipientName: 'Test User',
          phone: '08123456789',
          address: 'Jl. Test No. 123',
          city: 'Jakarta',
          postalCode: '12345',
        );

        // Assert
        expect(result.city, 'Jakarta');
      });
    });

    group('updateAddress', () {
      test('updates address successfully', () async {
        // Arrange
        final updatedAddress = {
          ...TestHelpers.sampleAddress,
          'label': 'Updated Home',
          'phone': '08999999999',
        };
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses/1',
          {'address': updatedAddress},
        );

        // Act
        final result = await profileService.updateAddress(
          1,
          label: 'Updated Home',
          phone: '08999999999',
        );

        // Assert
        expect(result.label, 'Updated Home');
        expect(result.phone, '08999999999');
      });

      test('throws exception for non-existent address', () async {
        // Arrange
        mockClient.setResponse(
          'PUT',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses/999',
          {'message': 'Address not found'},
          statusCode: 404,
        );

        // Act & Assert
        expect(
          () => profileService.updateAddress(999, label: 'New Label'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteAddress', () {
      test('deletes address successfully', () async {
        // Arrange
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses/1',
          {'message': 'Address deleted'},
        );

        // Act & Assert - should not throw
        await expectLater(
          profileService.deleteAddress(1),
          completes,
        );
      });

      test('throws exception for non-existent address', () async {
        // Arrange
        mockClient.setResponse(
          'DELETE',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses/999',
          {'message': 'Address not found'},
          statusCode: 404,
        );

        // Act & Assert
        expect(
          () => profileService.deleteAddress(999),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getDefaultAddress', () {
      test('returns default address when exists', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'addresses': TestHelpers.sampleAddresses},
        );

        // Act
        final result = await profileService.getDefaultAddress();

        // Assert
        expect(result, isNotNull);
        expect(result?.isDefault, true);
        expect(result?.label, 'Home');
      });

      test('returns first address when no default', () async {
        // Arrange
        final addressesWithoutDefault = TestHelpers.sampleAddresses
            .map((a) => {...a, 'is_default': false})
            .toList();
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'addresses': addressesWithoutDefault},
        );

        // Act
        final result = await profileService.getDefaultAddress();

        // Assert
        expect(result, isNotNull);
        expect(result?.label, 'Home');
      });

      test('returns null when no addresses', () async {
        // Arrange
        mockClient.setResponse(
          'GET',
          'https://adminmitologiclothing.center.biz.id/api/v1/profile/addresses',
          {'addresses': []},
        );

        // Act
        final result = await profileService.getDefaultAddress();

        // Assert
        expect(result, isNull);
      });
    });
  });
}
