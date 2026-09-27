import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/formatNumber.dart' as driver;
import 'package:flutter_test/flutter_test.dart';

/// [price-decimal] يرسّخ أن عرض المال يتحمّل الكسر في الجهتين.
///
/// العطل الذي أنتج هذا الملف: `formatNumber` كان توقيعه `int`، وكل مستدعٍ
/// يمرّر قيمة `dynamic` من JSON. فسعر منتج عشري كان يرمي
/// `double is not a subtype of int` في تسع شاشات، وبلا أي رسالة: التطبيق بلا
/// معالج أخطاء عام، فيظهر مستطيل رمادي فارغ مكان السعر أو سطر الطلب كاملاً.
void main() {
  group('جهة الزبون', () {
    test('الكسر يُعرض بخانتين ولا يرمي', () {
      expect(formatNumber(1333.4), '1,333.40');
      expect(formatNumber(16750.5), '16,750.50');
      expect(formatNumber(0.5), '0.50');
    });

    test('الصحيح بلا كسور', () {
      expect(formatNumber(1333), '1,333');
      expect(formatNumber(1333.0), '1,333');
      expect(formatNumber(0), '0');
    });

    test('يقبل int كما كان فلا ينكسر مستدعٍ قائم', () {
      // كل المستدعين القدامى يمرّرون int؛ التوقيع الجديد `num` يشملهم.
      const int legacy = 16750;
      expect(formatNumber(legacy), '16,750');
    });

    test('الغائب يُعامل صفراً لا يرمي', () {
      expect(formatNumber(null), '0');
    });
  });

  group('جهة السائق', () {
    test('صارت تعرض الكسر بعد أن كانت عاجزة عنه', () {
      // نسخة السائق لم تكن تملك صيغة متسامحة إطلاقاً.
      expect(driver.formatNumber(1333.4), '1,333.40');
      expect(driver.formatNumber(1333), '1,333');
      expect(driver.formatNumber(null), '0');
    });

    test('عدد الخانات قابل للتحديد', () {
      expect(driver.formatNumberNum(1333.456, decimalDigits: 0), '1,333');
      expect(driver.formatNumberNum(1333.4, decimalDigits: 3), '1,333.400');
    });
  });
}
