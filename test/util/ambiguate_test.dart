import 'package:bonfire/util/ambiguate.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'Given a nullable or non-nullable value, when ambiguate is called, then the result is always nullable',
      () {
    // arrange
    String nonNullable = 'nonNullable';
    String? nullable;

    // act
    final nonNullableAsNullable = ambiguate(nonNullable);
    final nullableAsNullable = ambiguate(nullable);

    // assert
    expect(nonNullableAsNullable, isA<String?>()); // String Nullable
    expect(nullableAsNullable, isA<String?>()); // String Nullable
  });
}
