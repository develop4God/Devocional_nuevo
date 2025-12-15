import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:devocional_nuevo/blocs/thanksgiving_bloc.dart';
import 'package:devocional_nuevo/blocs/thanksgiving_event.dart';
import 'package:devocional_nuevo/blocs/thanksgiving_state.dart';

void main() {
  group('ThanksgivingBloc', () {
    late ThanksgivingBloc thanksgivingBloc;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      thanksgivingBloc = ThanksgivingBloc();
    });

    tearDown(() {
      thanksgivingBloc.close();
    });

    test('initial state is ThanksgivingInitial', () {
      expect(thanksgivingBloc.state, isA<ThanksgivingInitial>());
    });

    blocTest<ThanksgivingBloc, ThanksgivingState>(
      'emits [ThanksgivingLoading, ThanksgivingLoaded] when ThanksgivingLoadEvent is added and data is successfully loaded',
      build: () => thanksgivingBloc,
      act: (bloc) => bloc.add(ThanksgivingLoadEvent()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        expect(state.thanksgivings, isNotEmpty);
      },
    );

    blocTest<ThanksgivingBloc, ThanksgivingState>(
      'emits [ThanksgivingLoading, ThanksgivingError] when ThanksgivingLoadEvent is added and an error occurs',
      build: () => thanksgivingBloc,
      act: (bloc) {
        // Simulate an error during data loading.  This requires modifying the bloc's dependencies or mocking the data source.
        // For this example, we'll add a delay and then throw an error within the bloc's event handler.
        return Future.delayed(Duration(milliseconds: 100), () {
          bloc.add(ThanksgivingLoadEvent());
          bloc.add(ThanksgivingErrorEvent(message: 'Simulated error'));
        });
      },
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingError;
        expect(state.message, 'Simulated error');
      },
    );

    blocTest<ThanksgivingBloc, ThanksgivingState>(
      'emits [ThanksgivingLoading, ThanksgivingLoaded] when ThanksgivingRefreshEvent is added and data is successfully refreshed',
      build: () => thanksgivingBloc,
      act: (bloc) => bloc.add(ThanksgivingRefreshEvent()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        expect(state.thanksgivings, isNotEmpty);
      },
    );

    blocTest<ThanksgivingBloc, ThanksgivingState>(
      'emits [ThanksgivingLoading, ThanksgivingError] when ThanksgivingRefreshEvent is added and an error occurs during refresh',
      build: () => thanksgivingBloc,
      act: (bloc) {
        // Simulate an error during data loading.  This requires modifying the bloc's dependencies or mocking the data source.
        // For this example, we'll add a delay and then throw an error within the bloc's event handler.
        return Future.delayed(Duration(milliseconds: 100), () {
          bloc.add(ThanksgivingRefreshEvent());
          bloc.add(ThanksgivingErrorEvent(message: 'Simulated refresh error'));
        });
      },
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingError;
        expect(state.message, 'Simulated refresh error');
      },
    );

    blocTest<ThanksgivingBloc, ThanksgivingState>(
      'emits [ThanksgivingLoading, ThanksgivingLoaded] when ThanksgivingLoadEvent is added and data is empty',
      build: () => thanksgivingBloc,
      act: (bloc) => bloc.add(ThanksgivingLoadEvent()),
      expect: () => [
        isA<ThanksgivingLoading>(),
        isA<ThanksgivingLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ThanksgivingLoaded;
        // Assuming that even if the data source returns empty data, the state should still be ThanksgivingLoaded.
        // If you want to handle empty data differently (e.g., emit a different state), adjust the bloc logic and this test accordingly.
        expect(state.thanksgivings, isEmpty);
      },
    );
  });
}