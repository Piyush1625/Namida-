import 'package:flutter/material.dart';

import 'package:namida/class/track.dart';

/// Quality tiers shown by [HiResBadge].
enum HiResTier {
  /// 24-bit and/or up to 96 kHz.
  hiRes,

  /// 24-bit / 176.4 kHz and above.
  hiResPlus;

  String get label => switch (this) {
    HiResTier.hiRes => 'Hi-Res',
    HiResTier.hiResPlus => 'Hi-Res+',
  };

  List<Color> get gradient => switch (this) {
    HiResTier.hiRes => const [Color(0xFFF6D365), Color(0xFFE8A33D)],
    HiResTier.hiResPlus => const [Color(0xFFFFE29F), Color(0xFFFF7E5F)],
  };
}

extension HiResTrackExt on TrackExtended {
  /// Returns the Hi-Res tier of this track, or `null` if it is not Hi-Res.
  /// Lossy files are never Hi-Res.
  HiResTier? get hiResTier {
    if (isLossless == false) return null;
    const lossy = {'mp3', 'aac', 'ogg', 'opus', 'm4a_lossy', 'wma', 'amr'};
    if (lossy.contains(format.toLowerCase())) return null;
    final isHiBits = bits >= 24;
    final isHiRate = sampleRate >= 88200;
    if (!isHiBits && !isHiRate) return null;
    if (sampleRate >= 176400) return HiResTier.hiResPlus;
    return HiResTier.hiRes;
  }

  bool get isHiRes => hiResTier != null;
}

/// A small gold pill: mini waveform glyph + "Hi-Res" text.
/// Original design, not derived from any third-party artwork.
class HiResBadge extends StatelessWidget {
  final HiResTier tier;
  final double height;
  final bool compact;

  const HiResBadge({
    super.key,
    this.tier = HiResTier.hiRes,
    this.height = 14.0,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = height * 0.62;
    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: height * 0.3),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: tier.gradient),
        borderRadius: BorderRadius.circular(height * 0.3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            size: Size(height * 0.7, height * 0.55),
            painter: _WavePainter(const Color(0xFF3A2A00)),
          ),
          if (!compact) ...[
            SizedBox(width: height * 0.2),
            Text(
              tier.label,
              style: TextStyle(
                fontSize: fontSize,
                height: 1.0,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
                color: const Color(0xFF3A2A00),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Color color;
  const _WavePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = size.width / 9;
    const heights = [0.4, 0.9, 0.6, 1.0, 0.5];
    final step = size.width / (heights.length - 1);
    for (var i = 0; i < heights.length; i++) {
      final h = size.height * heights[i];
      final x = i * step;
      canvas.drawLine(Offset(x, (size.height - h) / 2), Offset(x, (size.height + h) / 2), paint);
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.color != color;
}
