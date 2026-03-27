import 'package:flutter_test/flutter_test.dart';
import 'package:health/health.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:spring_health_member/services/health_service.dart';

@GenerateNiceMocks([MockSpec<Health>()])
import 'health_service_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HealthService isAvailable', () {
    late MockHealth mockHealth;

    setUp(() {
      mockHealth = MockHealth();
    });

    test('returns true on non-Android platform', () async {
       final service = HealthService.forTest(
         health: mockHealth,
         isAndroid: false,
       );

       final result = await service.isAvailable();

       expect(result, true);
       verify(mockHealth.configure()).called(1);
       verifyNever(mockHealth.getHealthConnectSdkStatus());
    });

    test('returns true on Android when SDK is available', () async {
       when(mockHealth.getHealthConnectSdkStatus())
           .thenAnswer((_) async => HealthConnectSdkStatus.sdkAvailable);

       final service = HealthService.forTest(
         health: mockHealth,
         isAndroid: true,
       );

       final result = await service.isAvailable();

       expect(result, true);
       verify(mockHealth.configure()).called(1);
       verify(mockHealth.getHealthConnectSdkStatus()).called(1);
    });

    test('returns false on Android when SDK is unavailable', () async {
       when(mockHealth.getHealthConnectSdkStatus())
           .thenAnswer((_) async => HealthConnectSdkStatus.sdkUnavailable);

       final service = HealthService.forTest(
         health: mockHealth,
         isAndroid: true,
       );

       final result = await service.isAvailable();

       expect(result, false);
       verify(mockHealth.configure()).called(1);
       verify(mockHealth.getHealthConnectSdkStatus()).called(1);
    });

    test('returns false when initialization throws an error', () async {
       when(mockHealth.configure()).thenThrow(Exception('Mock configuration failed'));

       final service = HealthService.forTest(
         health: mockHealth,
         isAndroid: true,
       );

       final result = await service.isAvailable();

       expect(result, false);
       verify(mockHealth.configure()).called(1);
    });
  });
}
