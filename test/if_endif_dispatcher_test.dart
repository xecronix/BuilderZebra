import 'package:test/test.dart';
import 'package:builderzebra/engine/mighty_eagle.dart';
import 'package:builderzebra/runtime/dispatcher_factory.dart';
import 'package:builderzebra/abstracts/base_truth_binder.dart';

// DummyBinder to satisfy DispatcherFactory
class DummyBinder extends BaseTruthBinder {
  
  DummyBinder(this._data);
  
  final List<Map<String, Map<String, dynamic>>> _logicStack = [];
  final Map<String, String> _data;

  /// Pushes a single conditional logic unit onto the stack
  @override 
  void stackPush(Map<String, Map<String, dynamic>> value) {
    _logicStack.add(value);
  }

  /// Pops the most recent entry off the stack (LIFO)
  @override
  Map<String, Map<String, dynamic>>? stackPop() {
    if (_logicStack.isEmpty) return null;
    return _logicStack.removeLast();
  }

  /// Peeks at the last item in the stack without removing it
  @override
  Map<String, Map<String, dynamic>>? stackPeek() {
    if (_logicStack.isEmpty) return null;
    return _logicStack.last;
  }

  /// Dumps the full contents of the stack for debugging
  @override
  void stackDump() {
    if (_logicStack.isEmpty) {
      print('[BZ Stack] (empty)');
    } else {
      print('[BZ Stack] ${_logicStack.length} entries:');
      for (var i = 0; i < _logicStack.length; i++) {
        final entry = _logicStack[i];
        final label = entry.keys.first;
        final content = entry[label];
        print('  [$i] <$label>: $content');
      }
    }
  }


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
  test('if block renders when condition is true', () async {
    final binder = DummyBinder({ 'x': '5' });
    final factory = DispatcherFactory(binder: binder);
    final dispatcher = factory.dispatch('truth')!;
    final template = '''
{@if|x==5|Correct branch :}
{@endif:}
''';

    final parser = MightyEagleParser(
      template: template,
      context: { 'x': '5' },
      dispatcher: dispatcher,
    );

    final result = await parser.parse();
    expect(result.trim(), equals('Correct branch'));
  });

  test('if block does not render when condition is false', () async {
    final binder = DummyBinder({ 'x': '7' });
    final factory = DispatcherFactory(binder: binder);
    final dispatcher = factory.dispatch('truth')!;
    final template = '''
{@if|x==5|Wrong branch :}
{@endif:}
''';

    final parser = MightyEagleParser(
      template: template,
      context: { 'x': '7' },
      dispatcher: dispatcher,
    );

    final result = await parser.parse();
    expect(result.trim(), equals(''));
  });

  test('if branch triggers when condition is true', () async {
    final binder = DummyBinder({ 'x': '5' });
    final factory = DispatcherFactory(binder: binder);
    final dispatcher = factory.dispatch('truth')!;
    final template = '''
{@if|x==5|Branch A :}
{@elseif|x==6|Branch B :}
{@else||Branch C :}
{@endif:}
''';

    final parser = MightyEagleParser(
      template: template,
      context: { 'x': '5' },
      dispatcher: dispatcher,
    );

    final result = await parser.parse();
    expect(result.trim(), equals('Branch A'));
  });

  test('elseif branch triggers when if fails but elseif is true', () async {
    final binder = DummyBinder({ 'x': '6' });
    final factory = DispatcherFactory(binder: binder);
    final dispatcher = factory.dispatch('truth')!;
    final template = '''
{@if|x==5|Branch A :}
{@elseif|x==6|Branch B :}
{@else||Branch C :}
{@endif:}
''';

    final parser = MightyEagleParser(
      template: template,
      context: { 'x': '6' },
      dispatcher: dispatcher,
    );

    final result = await parser.parse();
    expect(result.trim(), equals('Branch B'));
  });

  test('else branch triggers when all conditions fail', () async {
    final binder = DummyBinder({ 'x': '99' });
    final factory = DispatcherFactory(binder: binder);
    final dispatcher = factory.dispatch('truth')!;
    final template = '''
{@if|x==5|Branch A :}
{@elseif|x==6|Branch B :}
{@else||Branch C :}
{@endif:}
''';

    final parser = MightyEagleParser(
      template: template,
      context: { 'x': '99' },
      dispatcher: dispatcher,
    );

    final result = await parser.parse();
    expect(result.trim(), equals('Branch C'));
  });
}
