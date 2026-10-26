import 'package:flutter/material.dart';

import '../logic/setup_engine.dart';
import '../theme.dart';

class BBCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  const BBCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
    this.color,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    return Material(
      color: color ?? BB.card,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor ?? BB.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Widget? trailing;
  const SectionLabel(this.text, {super.key, this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      if (icon != null) ...[
        Icon(icon, size: 18, color: BB.textDim),
        const SizedBox(width: 10),
      ],
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
            color: BB.textDim,
          ),
        ),
      ),
      if (trailing != null) trailing!,
    ]);
  }
}

class ScreenHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String subtitle;
  const ScreenHeader(
      {super.key, required this.eyebrow, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(eyebrow.toUpperCase(),
          style: const TextStyle(
              fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w600, color: BB.textDim)),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(subtitle, style: const TextStyle(fontSize: 14, color: BB.textDim)),
    ]);
  }
}

class PrimaryButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final bool chevron;
  const PrimaryButton(
      {super.key, required this.label, required this.onPressed, this.icon, this.chevron = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: BB.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
          Flexible(
            child: Text(label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 13)),
          ),
          if (chevron) ...[const SizedBox(width: 10), const Icon(Icons.chevron_right, size: 22)],
        ]),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  const SecondaryButton(
      {super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: BB.text,
          backgroundColor: BB.card,
          side: const BorderSide(color: BB.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label.toUpperCase(),
            style: const TextStyle(
                fontWeight: FontWeight.w700, letterSpacing: 0.6, fontSize: 12)),
      ),
    );
  }
}

/// Rząd przycisków-wyborów (segmenty) z czerwoną ramką na zaznaczonym.
class ChoiceRow<T> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;
  const ChoiceRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (final o in options)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: o == options.last ? 0 : 6),
            child: GestureDetector(
              onTap: () => onChanged(o),
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: o == selected ? BB.red.withValues(alpha: 0.08) : BB.cardAlt,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: o == selected ? BB.red : BB.border, width: o == selected ? 1.5 : 1),
                ),
                child: Text(labelOf(o),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: o == selected ? FontWeight.w600 : FontWeight.w400,
                        color: o == selected ? BB.text : BB.textDim)),
              ),
            ),
          ),
        ),
    ]);
  }
}

class LevelBars extends StatelessWidget {
  final Level level;
  final Color color;
  const LevelBars({super.key, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    final n = level.index + 1;
    return Row(children: [
      for (var i = 0; i < 4; i++)
        Container(
          width: 20,
          height: 5,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: i < n ? color : BB.track,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
    ]);
  }
}

IconData iconForParam(String key) {
  switch (key) {
    case 'frontWing':
    case 'rearWing':
      return Icons.flight;
    case 'diffOn':
    case 'diffOff':
      return Icons.settings;
    case 'camberFront':
    case 'camberRear':
      return Icons.tire_repair;
    case 'toeFront':
    case 'toeRear':
      return Icons.swap_horiz;
    case 'suspFront':
    case 'suspRear':
      return Icons.vertical_align_center;
    case 'arbFront':
    case 'arbRear':
      return Icons.linear_scale;
    case 'rideFront':
    case 'rideRear':
      return Icons.height;
    case 'brakePressure':
    case 'brakeBias':
      return Icons.disc_full;
    default:
      return Icons.circle_outlined;
  }
}

/// Karta z suwakiem pojedynczego parametru.
class ParamSliderCard extends StatelessWidget {
  final Param param;
  final double value;
  final ValueChanged<double> onChanged;
  const ParamSliderCard(
      {super.key, required this.param, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final div = ((param.max - param.min) / param.step).round().clamp(1, 1000);
    return BBCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: BB.cardAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: BB.border)),
          child: Icon(iconForParam(param.key), size: 18, color: BB.textDim),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: Text(param.label,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
              Text(param.format(value),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ]),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(trackHeight: 4),
              child: Slider(
                value: value.clamp(param.min, param.max),
                min: param.min,
                max: param.max,
                divisions: div,
                onChanged: onChanged,
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(param.format(param.min),
                  style: const TextStyle(fontSize: 11, color: BB.textDim)),
              Text(param.format(param.max),
                  style: const TextStyle(fontSize: 11, color: BB.textDim)),
            ]),
          ]),
        ),
      ]),
    );
  }
}
