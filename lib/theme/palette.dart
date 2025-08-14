// import 'package:flutter/material.dart';

// /// Warm, eye-friendly palette
// const kPrimary = Color(0xFF8D5A63); // plum-rose (buttons, accents)
// const kPrimarySoft = Color(0xFFF5D9D2); // peach tint (chips, pills, hovers)
// const kBgTop = Color(0xFFFBEDE6); // header gradient start
// const kBgBottom = Color(0xFFFFFBFA); // header gradient end / page bg
// const kCard = Color(0xFFFFF7F4); // cards (optional)
// const kBorder = Color(0xFFE8DAD5); // subtle borders
// const kTextPrimary = Color(0xFF3E2F33); // warm dark text

/// Calm, eye-friendly blue palette
// const kPrimary = Color(0xFF3B82F6); // azure blue (buttons, accents)
// const kPrimarySoft = Color(0xFFE8F1FF); // soft blue tint (chips, pills, hovers)
// const kBgTop = Color(0xFFEFF5FF); // header gradient start
// const kBgBottom = Color(0xFFFAFCFF); // header gradient end / page bg
// const kCard = Color(0xFFF7FAFF); // subtle blue card background
// const kBorder = Color(0xFFD7E3FF); // gentle blue border
// const kTextPrimary = Color(0xFF1F2A44); // deep blue-gray text

//MINT GREEN
// const kPrimary = Color(0xFF10B981); // mint/emerald (buttons, accents)
// const kPrimarySoft = Color(0xFFE8F8F2); // soft mint tint (chips, hovers)
// const kBgTop = Color(0xFFF2FBF8); // header gradient start
// const kBgBottom = Color(0xFFFAFFFD); // header gradient end / page bg
// const kCard = Color(0xFFF6FCF9); // subtle mint card background
// const kBorder = Color(0xFFCFEDE3); // gentle mint border
// const kTextPrimary = Color(0xFF1E2B28); // deep greenish text

//EMERALD GREEN
// const kPrimary = Color(0xFF059669); // emerald (buttons, accents)
// const kPrimarySoft = Color(0xFFDDF7EF); // soft emerald tint
// const kBgTop = Color(0xFFEAFBF5); // header gradient start
// const kBgBottom = Color(0xFFF9FFFC); // header gradient end / page bg
// const kCard = Color(0xFFF1FBF7); // subtle emerald card background
// const kBorder = Color(0xFFBFE9DB); // gentle emerald border
// const kTextPrimary = Color(0xFF0E2A22); // dark teal-green text

//VIBRANT
// const kPrimary = Color(0xFF22C55E); // fresh green (buttons, accents)
// const kPrimarySoft = Color(0xFFEAFBF1); // soft green tint
// const kBgTop = Color(0xFFF2FCF6); // header gradient start
// const kBgBottom = Color(0xFFFAFFFC); // header gradient end / page bg
// const kCard = Color(0xFFF5FDF9); // subtle green card background
// const kBorder = Color(0xFFCFEFDD); // gentle green border
// const kTextPrimary = Color(0xFF13281C); // deep forest text

// //OLIVE GREEN
// const kPrimary = Color(0xFF6EA523); // olive (buttons, accents)
// const kPrimarySoft = Color(0xFFF0F6E7); // soft olive tint
// const kBgTop = Color(0xFFF5FAEE); // header gradient start
// const kBgBottom = Color(0xFFFCFFFA); // header gradient end / page bg
// const kCard = Color(0xFFF7FCF1); // subtle olive card background
// const kBorder = Color(0xFFDCEAD0); // gentle olive border
// const kTextPrimary = Color(0xFF2A341F); // deep olive text

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single palette shape.
class AppPalette {
  final Color primary;
  final Color primarySoft;
  final Color bgTop;
  final Color bgBottom;
  final Color card;
  final Color border;
  final Color textPrimary;

  const AppPalette({
    required this.primary,
    required this.primarySoft,
    required this.bgTop,
    required this.bgBottom,
    required this.card,
    required this.border,
    required this.textPrimary,
  });
}

// 1) Azure Blue
const _blue = AppPalette(
  primary: Color(0xFF3B82F6),
  primarySoft: Color(0xFFE8F1FF),
  bgTop: Color(0xFFEFF5FF),
  bgBottom: Color(0xFFFAFCFF),
  card: Color(0xFFF7FAFF),
  border: Color(0xFFD7E3FF),
  textPrimary: Color(0xFF1F2A44),
);

// 2) Mint Green
const _mint = AppPalette(
  primary: Color(0xFF10B981),
  primarySoft: Color(0xFFE8F8F2),
  bgTop: Color(0xFFF2FBF8),
  bgBottom: Color(0xFFFAFFFD),
  card: Color(0xFFF6FCF9),
  border: Color(0xFFCFEDE3),
  textPrimary: Color(0xFF1E2B28),
);

// 3) Emerald Green
const _emerald = AppPalette(
  primary: Color(0xFF059669),
  primarySoft: Color(0xFFDDF7EF),
  bgTop: Color(0xFFEAFBF5),
  bgBottom: Color(0xFFF9FFFC),
  card: Color(0xFFF1FBF7),
  border: Color(0xFFBFE9DB),
  textPrimary: Color(0xFF0E2A22),
);

// 4) Fresh Green
const _fresh = AppPalette(
  primary: Color(0xFF22C55E),
  primarySoft: Color(0xFFEAFBF1),
  bgTop: Color(0xFFF2FCF6),
  bgBottom: Color(0xFFFAFFFC),
  card: Color(0xFFF5FDF9),
  border: Color(0xFFCFEFDD),
  textPrimary: Color(0xFF13281C),
);

// 5) Olive Green
const _olive = AppPalette(
  primary: Color(0xFF6EA523),
  primarySoft: Color(0xFFF0F6E7),
  bgTop: Color(0xFFF5FAEE),
  bgBottom: Color(0xFFFCFFFA),
  card: Color(0xFFF7FCF1),
  border: Color(0xFFDCEAD0),
  textPrimary: Color(0xFF2A341F),
);

// 6) Lavender Lilac
const _lavender = AppPalette(
  primary: Color(0xFF8B5CF6),
  primarySoft: Color(0xFFF1EAFE),
  bgTop: Color(0xFFF6F2FF),
  bgBottom: Color(0xFFFCFBFF),
  card: Color(0xFFFAF7FF),
  border: Color(0xFFE7DDFC),
  textPrimary: Color(0xFF27233A),
);

// 7) Blush Pink
const _blush = AppPalette(
  primary: Color(0xFFEC6A8C),
  primarySoft: Color(0xFFFDE9F0),
  bgTop: Color(0xFFFFF3F7),
  bgBottom: Color(0xFFFFFCFE),
  card: Color(0xFFFFF7FA),
  border: Color(0xFFF5D3DE),
  textPrimary: Color(0xFF3B2430),
);

// 8) Coral Peach
const _coral = AppPalette(
  primary: Color(0xFFF78C6B),
  primarySoft: Color(0xFFFFF0EB),
  bgTop: Color(0xFFFFF6F2),
  bgBottom: Color(0xFFFFFCFB),
  card: Color(0xFFFFF8F5),
  border: Color(0xFFFAD8CF),
  textPrimary: Color(0xFF382421),
);

// 9) Warm Sand
const _sand = AppPalette(
  primary: Color(0xFFD4A373),
  primarySoft: Color(0xFFF8EFE6),
  bgTop: Color(0xFFFBF6F0),
  bgBottom: Color(0xFFFFFCFA),
  card: Color(0xFFFCF8F4),
  border: Color(0xFFEADACA),
  textPrimary: Color(0xFF2E271E),
);

// 10) Soft Teal
const _teal = AppPalette(
  primary: Color(0xFF14B8A6),
  primarySoft: Color(0xFFE7FBF8),
  bgTop: Color(0xFFEFFDFB),
  bgBottom: Color(0xFFFAFFFE),
  card: Color(0xFFF4FDFC),
  border: Color(0xFFCFF3EE),
  textPrimary: Color(0xFF14312E),
);

// 11) Seafoam
const _seafoam = AppPalette(
  primary: Color(0xFF2DD4BF),
  primarySoft: Color(0xFFEAFBF7),
  bgTop: Color(0xFFF2FDFB),
  bgBottom: Color(0xFFFAFFFE),
  card: Color(0xFFF6FDFB),
  border: Color(0xFFCFEFEA),
  textPrimary: Color(0xFF16302C),
);

// 12) Sky Cyan
const _cyan = AppPalette(
  primary: Color(0xFF06B6D4),
  primarySoft: Color(0xFFE6FAFF),
  bgTop: Color(0xFFF0FCFF),
  bgBottom: Color(0xFFFAFEFF),
  card: Color(0xFFF5FDFF),
  border: Color(0xFFCFEFF7),
  textPrimary: Color(0xFF0F2B33),
);

// 13) Periwinkle
const _periwinkle = AppPalette(
  primary: Color(0xFF7C98FF),
  primarySoft: Color(0xFFEEF2FF),
  bgTop: Color(0xFFF4F6FF),
  bgBottom: Color(0xFFFCFDFF),
  card: Color(0xFFF7F9FF),
  border: Color(0xFFDDE5FF),
  textPrimary: Color(0xFF22283D),
);

// 14) Mauve
const _mauve = AppPalette(
  primary: Color(0xFFA36AA6),
  primarySoft: Color(0xFFF7ECF8),
  bgTop: Color(0xFFFBF4FC),
  bgBottom: Color(0xFFFFFDFF),
  card: Color(0xFFFCF7FD),
  border: Color(0xFFE8D3EA),
  textPrimary: Color(0xFF2E2330),
);

// 15) Peony Rose
const _peony = AppPalette(
  primary: Color(0xFFE6677D),
  primarySoft: Color(0xFFFCE9ED),
  bgTop: Color(0xFFFFF2F5),
  bgBottom: Color(0xFFFFFBFC),
  card: Color(0xFFFFF6F8),
  border: Color(0xFFF5D7DF),
  textPrimary: Color(0xFF321F24),
);

// 16) Apricot
const _apricot = AppPalette(
  primary: Color(0xFFFEB273),
  primarySoft: Color(0xFFFFF3E8),
  bgTop: Color(0xFFFFF7F0),
  bgBottom: Color(0xFFFFFCFA),
  card: Color(0xFFFFF8F2),
  border: Color(0xFFFADFCB),
  textPrimary: Color(0xFF3A2A1E),
);

// 17) Butter
const _butter = AppPalette(
  primary: Color(0xFFE9B949),
  primarySoft: Color(0xFFFFF8E1),
  bgTop: Color(0xFFFFFAE8),
  bgBottom: Color(0xFFFFFDF5),
  card: Color(0xFFFFFAEF),
  border: Color(0xFFF4E4B9),
  textPrimary: Color(0xFF2E2A14),
);

// 18) Slate Blue-Gray
const _slate = AppPalette(
  primary: Color(0xFF64748B),
  primarySoft: Color(0xFFEFF3F7),
  bgTop: Color(0xFFF5F7FA),
  bgBottom: Color(0xFFFCFDFE),
  card: Color(0xFFF8FAFC),
  border: Color(0xFFDFE7F0),
  textPrimary: Color(0xFF1F2937),
);

// 19) Dusty Rose
const _dustyRose = AppPalette(
  primary: Color(0xFFC06C84),
  primarySoft: Color(0xFFF9EEF2),
  bgTop: Color(0xFFFCF5F7),
  bgBottom: Color(0xFFFFFCFD),
  card: Color(0xFFFDF7FA),
  border: Color(0xFFEBD2DB),
  textPrimary: Color(0xFF2E2327),
);

// 20) Sage Green
const _sage = AppPalette(
  primary: Color(0xFF84A98C),
  primarySoft: Color(0xFFEFF6F1),
  bgTop: Color(0xFFF5FAF6),
  bgBottom: Color(0xFFFCFFFD),
  card: Color(0xFFF7FBF8),
  border: Color(0xFFDCE8E1),
  textPrimary: Color(0xFF243128),
);

/// ===== Manager =====

class PaletteManager {
  static const _prefKey = 'palette_index_v1';

  static final List<AppPalette> _all = [
    _blue,
    _mint,
    _emerald,
    _fresh,
    _olive,
    _lavender,
    _blush,
    _coral,
    _sand,
    _teal,
    _seafoam,
    _cyan,
    _periwinkle,
    _mauve,
    _peony,
    _apricot,
    _butter,
    _slate,
    _dustyRose,
    _sage,
  ];

  static late AppPalette _current;

  /// Call this once before runApp().
  static Future<void> initRandom() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_prefKey);
    if (saved != null && saved >= 0 && saved < _all.length) {
      _current = _all[saved];
      return;
    }
    final idx = Random().nextInt(_all.length);
    await prefs.setInt(_prefKey, idx);
    _current = _all[idx];
  }

  static int get index {
    final i = _all.indexOf(_current);
    return i < 0 ? 0 : i;
  }

  static AppPalette get current => _current;
}

/// ===== Public color getters (runtime-selected; not const) =====
Color get kPrimary => PaletteManager.current.primary;
Color get kPrimarySoft => PaletteManager.current.primarySoft;
Color get kBgTop => PaletteManager.current.bgTop;
Color get kBgBottom => PaletteManager.current.bgBottom;
Color get kCard => PaletteManager.current.card;
Color get kBorder => PaletteManager.current.border;
Color get kTextPrimary => PaletteManager.current.textPrimary;
