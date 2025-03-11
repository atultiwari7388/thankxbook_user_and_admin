import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLineEffect extends StatelessWidget {
  const ShimmerLineEffect({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 16, // Adjust the height of the lines
              width:
                  index == 0 ? 150 : (index == 1 ? 120 : 100), // Varying widths
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
          ),
        );
      }),
    );
  }
}
