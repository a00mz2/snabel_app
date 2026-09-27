import 'package:customer/view/widget/ProductsDetailWidget/NamePriceWidget.dart';
import 'package:customer/view/widget/widgetApp/RatingStars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// [detail-overflow] سطر الاسم/السعر في صفحة تفاصيل المنتج كان يتجاوز بـ٢٣ بكسل.
///
/// السبب كان تخطيطياً بحتاً: `SizedBox(width: 100)` ثابت بين العمودين، وعمود
/// السعر بلا حدّ أعلى فيأخذ عرضه الطبيعي كاملاً، فلا يبقى لصفّ التقييم
/// (عرضه الطبيعي ~253 بكسل) ما يكفيه.
Widget _rtl(Widget child, {required double width}) => MaterialApp(
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          body: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    );

const _rating = RatingSummary(avg: 3.8, count: 4, avgLabel: '3.8');

/// يلغي التركيب ثم يركّب من جديد.
///
/// إلزامي في حلقة العروض: Flutter يبلّغ عن التجاوز **مرة واحدة لكل
/// RenderFlex**، فلو أعيد استعمال الشجرة لمرّت الأعراض التالية بلا استثناء ونجح
/// الاختبار كذباً (أول صياغة لهذا الملف سقطت في هذا بالضبط).
Future<void> _pumpFresh(WidgetTester tester, Widget child, double width) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(_rtl(child, width: width));
}

/// عرض المحتوى الفعلي = عرض الجهاز − ٣٢ (`horizontalPadding: 16` في الشاشة).
const _contentWidths = <double>[
  288, // 320: أضيق جهاز مدعوم
  328, // 360
  380, // 412: الشائع
  568, // 600: لوح صغير
];

void main() {
  group('RatingSummaryRow', () {
    testWidgets('لا يتجاوز مهما ضاق العرض', (tester) async {
      for (final w in [120.0, 150.0, 200.0, 253.0, 400.0]) {
        await _pumpFresh(tester, const RatingSummaryRow(rating: _rating), w);
        expect(tester.takeException(), isNull, reason: 'العرض $w');
      }
    });

    testWidgets('«لا توجد تقييمات» لا يتجاوز', (tester) async {
      await tester.pumpWidget(
        _rtl(const RatingSummaryRow(rating: null), width: 120),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('لا توجد تقييمات بعد'), findsOneWidget);
    });
  });

  group('ProductNamePriceLayout', () {
    testWidgets('اسم طويل + تقييم + سعر: لا تجاوز على أي عرض', (tester) async {
      for (final w in _contentWidths) {
        await _pumpFresh(
          tester,
          const ProductNamePriceLayout(
            name: 'توست حبة قمح كاملة مع بذور الكتان وعباد الشمس',
            piecesLabel: '(12 قطعة)',
            priceLabel: '24,000  د.ع',
            rating: _rating,
          ),
          w,
        );
        expect(tester.takeException(), isNull, reason: 'العرض $w');
      }
    });

    testWidgets('سعر عشري طويل لا يتجاوز ولا يُقصّ', (tester) async {
      // الأسعار صارت تقبل الكسور بلا حدّ، فالنصّ قد يطول كثيراً.
      for (final w in _contentWidths) {
        await _pumpFresh(
          tester,
          const ProductNamePriceLayout(
            name: 'توست حبة قمح كاملة',
            piecesLabel: '(120 قطعة)',
            priceLabel: '1,333,333.46  د.ع',
            rating: _rating,
            showSpecialBadge: true,
          ),
          w,
        );
        expect(tester.takeException(), isNull, reason: 'العرض $w');
        // يُقلَّص لا يُبتر: النصّ كاملاً ما زال معروضاً.
        expect(find.text('1,333,333.46  د.ع'), findsOneWidget);
      }
    });

    testWidgets('عمود السعر لا يتجاوز 45% من الصفّ', (tester) async {
      const width = 380.0;
      await tester.pumpWidget(
        _rtl(
          const ProductNamePriceLayout(
            name: 'توست',
            piecesLabel: '(1200 قطعة)',
            priceLabel: '117,333,330.84  د.ع',
            rating: _rating,
          ),
          width: width,
        ),
      );
      final priceBox = tester.getSize(
        find.ancestor(
          of: find.text('117,333,330.84  د.ع'),
          matching: find.byType(ConstrainedBox),
        ).first,
      );
      expect(priceBox.width, lessThanOrEqualTo(width * 0.45 + 0.01));
    });

    testWidgets('بلا تقييم ولا شارة: يعمل كما هو', (tester) async {
      await tester.pumpWidget(
        _rtl(
          const ProductNamePriceLayout(
            name: 'توست',
            piecesLabel: '(1 قطعة)',
            priceLabel: '2,000  د.ع',
          ),
          width: 328,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('لا توجد تقييمات بعد'), findsOneWidget);
      expect(find.byType(RatingStarsDisplay), findsNothing);
    });
  });
}
