import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitologi_clothing_mobile/core/api/api_config.dart';
import 'package:mitologi_clothing_mobile/features/catalog/domain/models/product_detail_model.dart';
import 'package:mitologi_clothing_mobile/features/catalog/presentation/views/product_detail_view.dart';
import 'package:mitologi_clothing_mobile/widgets/common/cached_image_widget.dart';

void main() {
  testWidgets('ProductReviewAvatar renders reviewer avatar image when present',
      (tester) async {
    final review = ProductReview(
      id: 1,
      userName: 'Rifqy',
      userAvatar: 'avatars/rifqy.png',
      rating: 5,
      comment: 'Produk bagus.',
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductReviewAvatar(review: review),
        ),
      ),
    );

    final image = tester.widget<CachedImageWidget>(
      find.byType(CachedImageWidget),
    );

    expect(image.imageUrl, ApiConfig.buildImageUrl('avatars/rifqy.png'));
  });

  testWidgets('ProductReviewAvatar falls back to reviewer initial',
      (tester) async {
    final review = ProductReview(
      id: 1,
      userName: 'Rifqy',
      rating: 5,
      comment: 'Produk bagus.',
      createdAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProductReviewAvatar(review: review),
        ),
      ),
    );

    expect(find.byType(CachedImageWidget), findsNothing);
    expect(find.text('R'), findsOneWidget);
  });
}
