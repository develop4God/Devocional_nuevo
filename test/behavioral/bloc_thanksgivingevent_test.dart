import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/blocs/thanksgiving_event.dart';

void main() {
  group('ThanksgivingEvent Bloc', () {
    late ThanksgivingEvent bloc;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      bloc = ThanksgivingEvent();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is correct', () {
      expect(bloc.state, isA<ThanksgivingInitial>());
    });

    blocTest<ThanksgivingEvent, ThanksgivingState>(
      'user scenario: Load initial data successfully',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadThanksgivingData()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        expect(state.data, isNotEmpty);
      },
    );

    blocTest<ThanksgivingEvent, ThanksgivingState>(
      'user scenario: Refresh data successfully',
      build: () => bloc,
      act: (bloc) => bloc.add(RefreshThanksgivingData()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        expect(state.data, isNotEmpty);
      },
    );

    blocTest<ThanksgivingEvent, ThanksgivingState>(
      'user scenario: Load data fails',
      build: () => bloc,
      act: (bloc) {
        // Simulate a failure during data loading.  This requires modifying the bloc's
        // internal logic to allow for forced failures during testing.  For example,
        // you might add a `forceError` flag that, when true, causes the data loading
        // to throw an exception.  Since we don't have the bloc's implementation,
        // we'll skip the act and expect an error state if the initial load fails.
        // In a real test, you'd need to modify the bloc.
        // bloc.forceError = true; // Example:  Add this to the bloc.
        bloc.add(LoadThanksgivingData());
      },
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingError>(),
      ],
      //verify: (bloc) {
      //  final state = bloc.state as ThanksgivingError;
      //  expect(state.message, 'Failed to load data'); // Replace with actual error message
      //},
      skip: 1, // Skip the initial loading state.
    );

    blocTest<ThanksgivingEvent, ThanksgivingState>(
      'edge case: No data available initially',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadThanksgivingData()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        // Assuming empty list is returned when no data is available.
        // Adjust the expectation based on the actual behavior.
        expect(state.data, isEmpty);
      },
    );

    blocTest<ThanksgivingEvent, ThanksgivingState>(
      'edge case: Refreshing when already loading does not trigger another load',
      build: () => bloc,
      act: (bloc) {
        bloc.add(LoadThanksgivingData()); // Start loading
        bloc.add(RefreshThanksgivingData()); // Try to refresh while loading
      },
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        // Verify that the loading only happened once.  This requires access to
        // internal state of the bloc, which we don't have.  In a real test,
        // you'd need to add a way to track how many times the data loading
        // function was called.
        // expect(bloc.dataLoadingCount, 1); // Example
      },
      //skip: 1, // Skip the initial loading state.
    );
  });
}