import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCardEffectWidget extends StatelessWidget {
  const ShimmerCardEffectWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8.r)),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(height: 10.h, color: Colors.grey[300]),
            SizedBox(height: 10.h),
            Container(height: 10.h, width: 50.w, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
