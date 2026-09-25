import 'package:flutter_test/flutter_test.dart';
void main(){
  test('factory economy',(){
    var coins=1200; var packaged=10;
    packaged-=3; coins+=210;
    expect(packaged,7); expect(coins,1410);
  });
}
