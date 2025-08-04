import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:devocional_nuevo/pages/devocionales_page.dart';
import 'package:devocional_nuevo/blocs/devocionales/devocionales_bloc.dart';
import 'package:mocktail/mocktail.dart';

// Mocks and fakes
class MockDevocionalesBloc extends Mock implements DevocionalesBloc {}
class FakeDevocionalesEvent extends Fake implements DevocionalesEvent {}
class FakeDevocionalesState extends Fake implements DevocionalesState {}

void main() {
  late DevocionalesBloc devocionalesBloc;

  setUpAll(() {
    registerFallbackValue<DevocionalesEvent>(FakeDevocionalesEvent());
    registerFallbackValue<DevocionalesState>(FakeDevocionalesState());
  });

  setUp(() {
    devocionalesBloc = MockDevocionalesBloc();
  });

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      home: BlocProvider<DevocionalesBloc>.value(
        value: devocionalesBloc,
        child: child,
      ),
    );
  }

  testWidgets('renders DevocionalesPage and title', (tester) async {
    when(() => devocionalesBloc.state).thenReturn(DevocionalesInitial());
    await tester.pumpWidget(makeTestableWidget(const DevocionalesPage()));

    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('Devocionales'), findsOneWidget);
  });

  testWidgets('shows loading indicator when loading', (tester) async {
    when(() => devocionalesBloc.state).thenReturn(DevocionalesLoading());
    await tester.pumpWidget(makeTestableWidget(const DevocionalesPage()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows list of devocionales when loaded', (tester) async {
    final devos = [Devocional(id: 1, title: 'Test Title', content: 'Test Content')];
    when(() => devocionalesBloc.state).thenReturn(DevocionalesLoaded(devocionales: devos));
    await tester.pumpWidget(makeTestableWidget(const DevocionalesPage()));
    await tester.pump(); // Rebuild after state

    expect(find.byType(ListView), findsOneWidget);
    expect(find.text('Test Title'), findsOneWidget);
  });

  testWidgets('shows error message when error state', (tester) async {
    when(() => devocionalesBloc.state).thenReturn(DevocionalesError(message: 'Error occurred'));
    await tester.pumpWidget(makeTestableWidget(const DevocionalesPage()));

    expect(find.text('Error occurred'), findsOneWidget);
  });
}