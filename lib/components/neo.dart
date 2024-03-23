import 'package:flutter/material.dart';

class Neo extends StatelessWidget {
  final Widget? child;
  const Neo({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          //darker shadow on bottom right
          BoxShadow(
            color: Colors.grey.shade500,
            blurRadius: 15,
            offset: const Offset(4, 4), // changes position of shadow
          ),

          //lighter shadow on bottom left
          const BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            offset: Offset(-4, -4), // changes position of shadow
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }
}
