import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder to satisfy DispatcherFactory
class DummyBinder implements BaseTruthBinder {
  @override
  List<String> getAllTruthNames() => [];

  @override
  Future<Map<String, String>> findTruth({required String truthName}) async => {};

  @override
  Future<List<Map<String, String>>> findChildren({
    required String truthName,
    required String childKey,
  }) async => [];
}

void main() {
  group('tight_dispatcher', () {
    late Map<String, String> context;
    final dummyBinder = DummyBinder();
    final dispatcherFactory = DispatcherFactory(binder: dummyBinder);

    setUp(() {
      context = <String, String>{};
    });

    test('normalizes spacing but keeps line breaks', () async {
      final template = '''{@tight
final   result   =   someService
    .doThing(    "now"     )
    .when(  user   )
    .go( ) ;
:}''';

      final parser = MightyEagleParser(
        template: template,
        context: context,
        dispatcher: dispatcherFactory.dispatch('truth')!,
      );

      final output = await parser.parse();

final expected = '''
final result = someService
 .doThing( "now" )
 .when( user )
 .go( ) ;
'''.trim();

      expect(output.trim(), equals(expected));
    });
  });
}
