import 'package:flutter/material.dart';

class ScoreSection extends StatelessWidget {
  final String name;
  final void Function() onTap;
  final bool isSelected;
  const ScoreSection(
      {super.key,
      required this.name,
      required this.onTap,
      required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          // borderRadius: BorderRadius.circular(16),
          color: isSelected
              ? Theme.of(context).highlightColor
              : Colors.transparent,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isTablet = constraints.maxWidth < 600;
              return Text(
                isTablet
                    ? name.toLowerCase().replaceAll('_', ' ')
                    : name.replaceAll('_', ' '),
                // style: TextStyle(fontSize: isTablet ? 12 : 14),
              );
            },
          ),
        ),
      ),
    );
  }
}
