// import 'package:flutter/material.dart';
// import '../models/product.dart';
// import '../theme/palette.dart';

// class ModernProductCard extends StatelessWidget {
//   final Product product;
//   final String? Function(Product) imgUrl;
//   final ValueNotifier<int> Function(Product) qtyVN;
//   final void Function(Product) onAddToCart;
//   final void Function(Product) onInc;
//   final void Function(Product) onDec;
//   final String Function(Product) priceTextFn;
//   final int Function(Product) maxPerItem;

//   /// Heart state + callback
//   final bool isFavorite;
//   final void Function(Product)? onToggleFavorite;

//   const ModernProductCard({
//     super.key,
//     required this.product,
//     required this.imgUrl,
//     required this.qtyVN,
//     required this.onAddToCart,
//     required this.onInc,
//     required this.onDec,
//     required this.priceTextFn,
//     required this.maxPerItem,
//     this.isFavorite = false,
//     this.onToggleFavorite,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final vn = qtyVN(product);
//     final image = imgUrl(product);
//     final priceText = priceTextFn(product);

//     final stock = product.stock;
//     final isOut = stock <= 0;
//     final isLow = stock > 0 && stock <= 5;

//     const double actionSize = 40; // circle button diameter
//     const double actionInset = 0; // offset from card edges
//     const double reserveRight = actionSize + 8; // space kept on right of text

//     return Card(
//       color: kBgBottom,
//       elevation: 0,
//       margin: const EdgeInsets.all(8),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ===== IMAGE + TOP OVERLAYS =====
//           Stack(
//             children: [
//               AspectRatio(
//                 aspectRatio: 1.0,
//                 child: ColorFiltered(
//                   colorFilter: isOut
//                       ? const ColorFilter.mode(
//                           Colors.white70,
//                           BlendMode.srcATop,
//                         )
//                       : const ColorFilter.mode(
//                           Colors.transparent,
//                           BlendMode.srcATop,
//                         ),
//                   child: Container(
//                     color: const Color(0xFFF4F6F6),
//                     child: image == null
//                         ? Center(
//                             child: Icon(
//                               Icons.image,
//                               color: kTextPrimary.withValues(alpha: .7),
//                               size: 40,
//                             ),
//                           )
//                         : Image.network(
//                             image,
//                             fit: BoxFit.cover,
//                             cacheWidth: 700,
//                             filterQuality: FilterQuality.low,
//                             errorBuilder: (_, __, ___) => Center(
//                               child: Icon(
//                                 Icons.broken_image_outlined,
//                                 color: kTextPrimary.withValues(alpha: .7),
//                                 size: 40,
//                               ),
//                             ),
//                             loadingBuilder: (ctx, child, progress) {
//                               if (progress == null) return child;
//                               return const Center(
//                                 child: SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     strokeWidth: 2,
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                   ),
//                 ),
//               ),

//               // stock badge (top-left)
//               if (isOut || isLow)
//                 Positioned(
//                   left: 8,
//                   top: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: isOut
//                           ? Colors.red.shade600
//                           : Colors.orange.shade600,
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     child: Text(
//                       isOut ? 'OUT OF STOCK' : 'LOW STOCK',
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 10.5,
//                         letterSpacing: .2,
//                       ),
//                     ),
//                   ),
//                 ),
//             ],
//           ),

//           // ===== BOTTOM AREA: text column + floating action bottom-right =====
//           Padding(
//             // a bit more bottom padding so the circle doesn’t clip shadow
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//             child: Stack(
//               children: [
//                 // LEFT: title, subtitle, price — keep right space reserved for action
//                 Padding(
//                   padding: const EdgeInsets.only(right: reserveRight),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Product name: show full text (wrap), smaller font
//                       Text(
//                         product.name,
//                         softWrap: true,
//                         // no maxLines, no ellipsis -> full name is visible
//                         style: TextStyle(
//                           color: kTextPrimary,
//                           fontSize: 9.0, // smaller
//                           fontWeight: FontWeight.w500,
//                           height: 1.2, // tighter leading
//                         ),
//                       ),
//                       const SizedBox(height: 2),

//                       // Subtitle: keep compact (1 line)
//                       Text(
//                         product.categoryName.isNotEmpty
//                             ? product.categoryName
//                             : 'Description',
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: kTextPrimary.withValues(alpha: .55),
//                           fontSize: 8.0,
//                           height: 1.1,
//                           fontWeight: FontWeight.w300,
//                         ),
//                       ),
//                       const SizedBox(height: 6),

//                       // Price: 1 line, compact
//                       Text(
//                         priceText,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                           color: kTextPrimary,
//                           fontSize: 13.5, // slightly smaller
//                           fontWeight: FontWeight.w700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // RIGHT: action pinned to bottom-right
//                 Positioned(
//                   right: actionInset,
//                   bottom: actionInset,
//                   child: ValueListenableBuilder<int>(
//                     valueListenable: vn,
//                     builder: (_, qty, __) {
//                       if (qty == 0 && isOut) {
//                         return const _CircleButton(
//                           onTap: null,
//                           icon: Icons.add,
//                           disabled: true,
//                         );
//                       }
//                       if (qty == 0) {
//                         return _CircleButton(
//                           onTap: () => onAddToCart(product),
//                           icon: Icons.add,
//                         );
//                       }
//                       final canInc =
//                           !isOut &&
//                           qty < product.stock &&
//                           qty < maxPerItem(product);
//                       return _MiniStepper(
//                         qty: qty,
//                         onMinus: () => onDec(product),
//                         onPlus: canInc ? () => onInc(product) : null,
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // ===== atoms =====

// class _CircleButton extends StatelessWidget {
//   final VoidCallback? onTap;
//   final IconData icon;
//   final bool disabled;
//   const _CircleButton({
//     required this.onTap,
//     required this.icon,
//     this.disabled = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: disabled ? kBorder : kPrimary,
//       shape: const CircleBorder(),
//       elevation: 3,
//       child: InkWell(
//         onTap: disabled ? null : onTap,
//         customBorder: const CircleBorder(),
//         child: const SizedBox(
//           width: 40,
//           height: 40,
//           child: Center(child: Icon(Icons.add, color: Colors.white, size: 22)),
//         ),
//       ),
//     );
//   }
// }

// class _MiniStepper extends StatelessWidget {
//   final int qty;
//   final VoidCallback onMinus;
//   final VoidCallback? onPlus;
//   const _MiniStepper({
//     required this.qty,
//     required this.onMinus,
//     required this.onPlus,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       elevation: 3,
//       borderRadius: BorderRadius.circular(18),
//       child: Container(
//         height: 34,
//         padding: const EdgeInsets.symmetric(horizontal: 6),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(18),
//           border: Border.all(color: kPrimary, width: 1.6),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _ChipIcon(icon: Icons.remove, onTap: onMinus, background: kPrimary),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               child: Text(
//                 '$qty',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.w900,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//             _ChipIcon(
//               icon: Icons.add,
//               onTap: onPlus,
//               background: onPlus == null ? kBorder : kPrimary,
//               disabled: onPlus == null,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _ChipIcon extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback? onTap;
//   final Color background;
//   final bool disabled;
//   const _ChipIcon({
//     required this.icon,
//     required this.onTap,
//     required this.background,
//     this.disabled = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkResponse(
//       onTap: disabled ? null : onTap,
//       radius: 18,
//       child: Container(
//         width: 22,
//         height: 22,
//         decoration: BoxDecoration(color: background, shape: BoxShape.circle),
//         child: Icon(icon, size: 15, color: Colors.white),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import '../models/product.dart';
import '../theme/palette.dart';

class ModernProductCard extends StatelessWidget {
  final Product product;
  final String? Function(Product) imgUrl;
  final ValueNotifier<int> Function(Product) qtyVN;
  final void Function(Product) onAddToCart;
  final void Function(Product) onInc;
  final void Function(Product) onDec;
  final String Function(Product) priceTextFn;
  final int Function(Product) maxPerItem;

  /// Heart state + callback
  final bool isFavorite;
  final void Function(Product)? onToggleFavorite;

  const ModernProductCard({
    super.key,
    required this.product,
    required this.imgUrl,
    required this.qtyVN,
    required this.onAddToCart,
    required this.onInc,
    required this.onDec,
    required this.priceTextFn,
    required this.maxPerItem,
    this.isFavorite = false,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final vn = qtyVN(product);
    final image = imgUrl(product);
    final priceText = priceTextFn(product);

    final stock = product.stock;
    final isOut = stock <= 0;
    final isLow = stock > 0 && stock <= 5;

    const double actionSize = 40; // circle button diameter
    const double actionInset = 0; // offset from card edges
    const double reserveRight = actionSize + 8; // space kept on right of text

    return Card(
      color: kBgBottom,
      elevation: 0,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== IMAGE + TOP OVERLAYS =====
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: ColorFiltered(
                    colorFilter: isOut
                        ? const ColorFilter.mode(
                            Colors.white70,
                            BlendMode.srcATop,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.srcATop,
                          ),
                    child: Container(
                      color: const Color(0xFFF4F6F6),
                      child: image == null
                          ? Center(
                              child: Icon(
                                Icons.image,
                                color: kTextPrimary.withValues(alpha: .7),
                                size: 40,
                              ),
                            )
                          : Image.network(
                              image,
                              fit: BoxFit.cover,
                              cacheWidth: 700,
                              filterQuality: FilterQuality.low,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: kTextPrimary.withValues(alpha: .7),
                                  size: 40,
                                ),
                              ),
                              loadingBuilder: (ctx, child, progress) {
                                if (progress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ),
                ),
              ),

              // stock badge (top-left)
              if (isOut || isLow)
                Positioned(
                  left: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOut
                          ? Colors.red.shade600
                          : Colors.orange.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isOut ? 'OUT OF STOCK' : 'LOW STOCK',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 10.5,
                        letterSpacing: .2,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // ===== BOTTOM AREA: text column + floating action bottom-right =====
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: reserveRight),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        softWrap: true,
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 9.0,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.categoryName.isNotEmpty
                            ? product.categoryName
                            : 'Description',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kTextPrimary.withValues(alpha: .55),
                          fontSize: 8.0,
                          height: 1.1,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        priceText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kTextPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: actionInset,
                  bottom: actionInset,
                  child: ValueListenableBuilder<int>(
                    valueListenable: vn,
                    builder: (_, qty, __) {
                      if (qty == 0 && isOut) {
                        return const _CircleButton(
                          onTap: null,
                          icon: Icons.add,
                          disabled: true,
                        );
                      }
                      if (qty == 0) {
                        return _CircleButton(
                          onTap: () => onAddToCart(product),
                          icon: Icons.add,
                        );
                      }
                      final canInc =
                          !isOut &&
                          qty < product.stock &&
                          qty < maxPerItem(product);
                      return _MiniStepper(
                        qty: qty,
                        onMinus: () => onDec(product),
                        onPlus: canInc ? () => onInc(product) : null,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== atoms =====

class _CircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final IconData icon;
  final bool disabled;
  const _CircleButton({
    required this.onTap,
    required this.icon,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: disabled ? kBorder : kPrimary,
      shape: const CircleBorder(),
      elevation: 3,
      child: InkWell(
        onTap: disabled ? null : onTap,
        customBorder: const CircleBorder(),
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Center(child: Icon(Icons.add, color: Colors.white, size: 22)),
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  final int qty;
  final VoidCallback onMinus;
  final VoidCallback? onPlus;
  const _MiniStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 34,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: kPrimary, width: 1.6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChipIcon(icon: Icons.remove, onTap: onMinus, background: kPrimary),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '$qty',
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
            _ChipIcon(
              icon: Icons.add,
              onTap: onPlus,
              background: onPlus == null ? kBorder : kPrimary,
              disabled: onPlus == null,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color background;
  final bool disabled;
  const _ChipIcon({
    required this.icon,
    required this.onTap,
    required this.background,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: disabled ? null : onTap,
      radius: 18,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 15, color: Colors.white),
      ),
    );
  }
}
