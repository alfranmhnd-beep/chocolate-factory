import 'package:flutter_test/flutter_test.dart';
import 'package:chocolate_factory/models/game_models.dart';

void main() {
  test('Game models are defined', () {
    expect(ItemType.values.length, greaterThan(3));
    expect(StationKind.values.length, greaterThan(5));
  });
}
