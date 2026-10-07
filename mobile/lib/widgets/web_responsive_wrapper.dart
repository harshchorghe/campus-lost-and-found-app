import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final bool showCardStyle;

  const WebResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 900.0,
    this.showCardStyle = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: showCardStyle
                  ? Card(
                      margin: const EdgeInsets.all(24),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: child,
                    )
                  : child,
            ),
          );
        }
        return child;
      },
    );
  }
}
