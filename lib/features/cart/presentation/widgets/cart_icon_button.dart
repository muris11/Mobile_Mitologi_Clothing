import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mitologi_clothing_mobile/core/theme/app_colors.dart';
import 'package:mitologi_clothing_mobile/features/cart/presentation/cart_view_model.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

class CartIconButton extends StatelessWidget {
  final Color? iconColor;
  const CartIconButton({super.key, this.iconColor});

  CartViewModel? _cartViewModel(BuildContext context) {
    try {
      return context.watch<CartViewModel>();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = _cartViewModel(context);
    final itemCount = cartVM?.cart?.items.fold<int>(
          0,
          (sum, item) => sum + item.quantity,
        ) ??
        0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: const Icon(PhosphorIconsRegular.shoppingCart),
          color: iconColor ?? AppColors.primary,
          tooltip: 'Keranjang',
          onPressed: () => context.push('/cart'),
        ),
        if (itemCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: IgnorePointer(
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  itemCount > 99 ? '99' : '$itemCount',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF000613),
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
