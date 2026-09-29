import 'package:customer/core/class/client_capabilities.dart';
import 'package:flutter_test/flutter_test.dart';

/// [price-decimal] يرسّخ الاسم والقيمة اللذين يفهمهما الخادم
/// (`moneyPolicy.cjs`): أي تغيير هنا بلا تغيير هناك يعيد الأسعار مقرَّبة بصمت.
void main() {
  test('ترويسة القدرات كما يتوقّعها الخادم', () {
    expect(kClientCapabilitiesHeader.toLowerCase(), 'x-client-capabilities');
    expect(kPriceDecimalsCapability, 'price-decimals');
    expect(clientCapabilityHeaders, {'X-Client-Capabilities': 'price-decimals'});
  });
}
