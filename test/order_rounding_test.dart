import 'package:flutter_test/flutter_test.dart';
import 'package:customer/core/functions/orderRounding.dart';

void main() {
  group('roundUpToStep', () {
    test('للأعلى إلى مضاعف 250، الصفر والسالب كما هما', () {
      expect(roundUpToStep(0), 0);
      expect(roundUpToStep(1), 250);
      expect(roundUpToStep(249), 250);
      expect(roundUpToStep(250), 250);
      expect(roundUpToStep(251), 500);
      expect(roundUpToStep(10100), 10250);
      expect(roundUpToStep(-5), -5);
      expect(roundUpToStep(10100, step: 500), 10500);
      expect(roundUpToStep(10100.4), 10250);
      expect(roundUpToStep(null), 0);
      expect(roundUpToStep(double.nan), 0);
    });
  });

  test('roundingStepOrDefault', () {
    expect(roundingStepOrDefault(null), 250);
    expect(roundingStepOrDefault(0), 250);
    expect(roundingStepOrDefault('abc'), 250);
    expect(roundingStepOrDefault(500), 500);
    expect(roundingStepOrDefault('1000'), 1000);
  });

  group('previewAfterDelta', () {
    test('طلب مقرَّب: يطرح التقريب السابق ثم يقرّب من جديد', () {
      final r = previewAfterDelta(
        currentTotal: 12250,
        currentRounding: 150,
        lineDelta: -100,
      );
      expect(r.base, 12000);
      expect(r.totalPrice, 12000);
      expect(r.roundingAdjustment, 0);
      expect(r.delta, -250);

      final up = previewAfterDelta(
        currentTotal: 12250,
        currentRounding: 150,
        lineDelta: 300,
      );
      expect(up.totalPrice, 12500);
      expect(up.delta, 250);

      final absorbed = previewAfterDelta(
        currentTotal: 12250,
        currentRounding: 150,
        lineDelta: 100,
      );
      expect(absorbed.totalPrice, 12250);
      expect(absorbed.delta, 0);
      expect(absorbed.roundingAdjustment, 50);
    });

    test('طلب قديم غير مقرَّب: التخفيض لا يرفع الإجمالي', () {
      final reduce = previewAfterDelta(currentTotal: 10100, lineDelta: -50);
      expect(reduce.totalPrice, 10100);
      expect(reduce.delta, 0);

      final big = previewAfterDelta(currentTotal: 10100, lineDelta: -1000);
      expect(big.totalPrice, 9250);
      expect(big.delta, -850);

      final inc = previewAfterDelta(currentTotal: 10100, lineDelta: 300);
      expect(inc.totalPrice, 10500);
      expect(inc.delta, 400);

      final none = previewAfterDelta(currentTotal: 10100, lineDelta: 0);
      expect(none.delta, 0);
    });

    test('الفرق لا يكون موجباً عند التخفيض مهما كانت الخطوة', () {
      for (final step in [250, 500, 1000]) {
        for (final total in [10100, 10250, 10500, 12000]) {
          for (final ld in [-1, -50, -249, -250, -251, -999]) {
            final r = previewAfterDelta(
              currentTotal: total,
              currentRounding: 150,
              lineDelta: ld,
              step: step,
            );
            expect(r.delta <= 0, isTrue, reason: 's=$step t=$total ld=$ld');
            expect(r.roundingAdjustment >= 0 && r.roundingAdjustment < step, isTrue);
          }
        }
      }
    });
  });

  test('walletDeltaPreview: بلا إجمالي يعود فرق البند الخام', () {
    expect(walletDeltaPreview(orderTotal: null, lineDelta: -300), -300);
    expect(
      walletDeltaPreview(orderTotal: 12250, orderRounding: 150, lineDelta: -100),
      -250,
    );
  });
}
