import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
// show: intl يُصدّر TextDirection خاصاً به ويحجب نظيره في Flutter
import 'package:intl/intl.dart' show NumberFormat;

/// ملخّص تقييم جاهز للعرض.
///
/// الخادم يرسل `rating: { avgX10: 43, avgText: "4.3", count, total }` — **`avgText` نص**
/// لأن JSON لا يفرّق بين int و double، فمتوسط 4.0 يصل كـ int و4.3 كـ double وينهار
/// التحويل نصف الوقت (نفس سبب `'double' is not a subtype of 'int'` في أسعار المنتجات).
class RatingSummary {
  const RatingSummary({required this.avg, required this.count, required this.avgLabel});

  final double avg;
  final int count;

  /// نص المتوسط كما أرسله الخادم («4.3»)، أو مبنيّ محلياً عند الحاجة.
  final String avgLabel;
}

final NumberFormat _avgFormat = NumberFormat('#,##0.#', 'en');

/// يقبل خريطة المنتج/السائق كاملة **أو** خريطة `rating` نفسها.
///
/// يُرجع `null` عند غياب الحقل أو `count == 0` — قاعدة واحدة تحلّ «لا توجد تقييمات»
/// و«0 مقابل null» وتوافق الخوادم القديمة معاً، على نمط [hasSpecialPrice].
RatingSummary? parseRating(dynamic raw) {
  if (raw is! Map) return null;
  final node = raw['rating'] is Map ? raw['rating'] as Map : raw;

  final countRaw = node['count'];
  final count = countRaw is num
      ? countRaw.toInt()
      : int.tryParse('${countRaw ?? ''}') ?? 0;
  if (count <= 0) return null;

  double? avg;
  final avgX10 = node['avgX10'];
  if (avgX10 is num) {
    avg = avgX10.toDouble() / 10;
  } else {
    final direct = node['avg'];
    if (direct is num) {
      avg = direct.toDouble();
    } else {
      avg = double.tryParse('${node['avgText'] ?? ''}');
    }
  }
  if (avg == null || !avg.isFinite || avg <= 0) return null;

  final text = node['avgText'];
  final label = (text is String && text.trim().isNotEmpty)
      ? text.trim()
      : _avgFormat.format(avg);

  return RatingSummary(avg: avg, count: count, avgLabel: label);
}

/// صف نجوم للقراءة فقط.
///
/// ⚠️ مغلَّف بـ `Directionality(ltr)` عمداً: داخل شجرة RTL يملأ الصف من اليمين،
/// فيُضيء تقييم 2/5 النجمتين **اليمنيتين** وتنعكس النجمة النصفية.
class RatingStarsDisplay extends StatelessWidget {
  const RatingStarsDisplay({
    super.key,
    required this.value,
    this.size = 16,
    this.color,
  });

  final double value;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final filled = color ?? Theme.of(context).primaryColor;
    const empty = Color(0xffD0CAC8);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final position = i + 1;
          final IconData icon;
          if (value >= position - 0.25) {
            icon = Icons.star_rounded;
          } else if (value >= position - 0.75) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_border_rounded;
          }
          return Icon(
            icon,
            size: size,
            color: icon == Icons.star_border_rounded ? empty : filled,
          );
        }),
      ),
    );
  }
}

/// شارة مدمجة فوق صورة المنتج في البطاقات: نجمة واحدة + الرقم.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.rating,
    this.compact = false,
    this.showCount = false,
  });

  final RatingSummary? rating;
  final bool compact;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final r = rating;
    if (r == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_rounded,
            size: compact ? 12 : 14,
            color: theme.primaryColor,
          ),
          const SizedBox(width: 2),
          Text(
            showCount ? '${r.avgLabel} (${r.count})' : r.avgLabel,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: compact ? 10 : 11,
              fontWeight: MyFontWeight.semiBold,
              color: const Color(0xff231F1E),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// عرض موسّع: نجوم + الرقم + عدد التقييمات (صفحة تفاصيل المنتج).
class RatingSummaryRow extends StatelessWidget {
  const RatingSummaryRow({super.key, required this.rating, this.starSize = 18});

  final RatingSummary? rating;
  final double starSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = rating;
    if (r == null) {
      return Text(
        'لا توجد تقييمات بعد',
        style: theme.textTheme.titleLarge!.copyWith(
          fontSize: 12,
          fontWeight: MyFontWeight.light,
          color: const Color(0xff7C7C7C),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingStarsDisplay(value: r.avg, size: starSize),
        const SizedBox(width: 6),
        Text(
          r.avgLabel,
          style: theme.textTheme.titleLarge!.copyWith(
            fontSize: 15,
            fontWeight: MyFontWeight.semiBold,
            color: const Color(0xff231F1E),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${r.count} تقييم)',
          style: theme.textTheme.titleLarge!.copyWith(
            fontSize: 12,
            fontWeight: MyFontWeight.light,
            color: const Color(0xff7C7C7C),
          ),
        ),
      ],
    );
  }
}

/// إدخال تقييم 1..5.
///
/// `GestureDetector` لا `IconButton`: الأخير يفرض هدف لمس 48 بكسل فيكسر تخطيط الورقة.
/// الضغط على النجمة المحددة لا يُصفّرها — الصفر يعني «لم يختر بعد» ولا يُرسَل أبداً.
class RatingStarsInput extends StatelessWidget {
  const RatingStarsInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 36,
    this.enabled = true,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final filled = Theme.of(context).primaryColor;
    const empty = Color(0xffD0CAC8);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final position = i + 1;
          final isOn = value >= position;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: enabled ? () => onChanged(position) : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Icon(
                isOn ? Icons.star_rounded : Icons.star_border_rounded,
                size: size,
                color: enabled ? (isOn ? filled : empty) : empty,
              ),
            ),
          );
        }),
      ),
    );
  }
}
