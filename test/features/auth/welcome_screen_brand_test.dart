import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/design_system/brand/brand_assets.dart';
import 'package:school_pulse/features/branding/presentation/widgets/school_badge.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'SchoolBadge fallback shows the brand mark (${dark ? 'dark' : 'light'})',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              brightness: dark ? Brightness.dark : Brightness.light,
            ),
            home: Builder(
              builder: (context) => SchoolBadge(
                fallback: Image.asset(BrandAssets.logoMark(context)),
              ),
            ),
          ),
        );
        final image = tester.widget<Image>(find.byType(Image));
        expect(
          (image.image as AssetImage).assetName,
          dark ? BrandAssets.logoMarkDark : BrandAssets.logoMarkLight,
        );
        expect(find.byIcon(Icons.school_outlined), findsNothing);
      },
    );
  }
}
