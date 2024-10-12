import 'package:flutter/material.dart';
import 'package:gphil/components/keyboard_shortcuts.dart';
import 'package:gphil/theme/constants.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _activeSection = 'about';

  final Map<String, Widget> _sections = {
    'about': const _SectionContent(title: 'About GPhil', content: [
      'GPhil is an innovative app designed for musicians to play instrumental concertos with flexible virtual orchestral accompaniment. Whether you\'re practicing for a performance or simply enjoying your favorite concertos, GPhil provides a rich, interactive experience.',
    ]),
    'navigation': const _SectionContent(title: 'Navigating GPhil', content: [
      '1. Select a score from the library\n2. Choose the movement you want to practice\n3. Navigate to the practice screen',
    ]),
    'performance': const _SectionContent(
      title: 'Practice',
      content: [
        'Switch to Performance mode for seamless live performances. This mode disables looping and skipping features to ensure an uninterrupted play-through.',
      ],
      child: KeyboardShortcuts(),
    ),
    'faq': const _FAQSection(),
  };

  final double bottom = 90;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: MediaQuery.sizeOf(context).height - bottom,
        maxHeight: MediaQuery.sizeOf(context).height - bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(paddingXl),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 38,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: _sections.keys.map((section) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: ElevatedButton(
                          onPressed: () =>
                              setState(() => _activeSection = section),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _activeSection == section
                                ? highlightColor
                                : Colors.grey.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            textStyle: TextStyles().textMd,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            // side: BorderSide(
                            //     color: Colors.white.withOpacity(0.2), width: 1),
                          ),
                          child: Text(
                              section[0].toUpperCase() + section.substring(1)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const SeparatorLine(),
                const SizedBox(height: 24),
                _sections[_activeSection] ?? const SizedBox.shrink(),
              ],
            ),
            Positioned(
              right: paddingXl,
              bottom: paddingXl,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  OutlineGlowButton(
                    onPressed: () {
                      /* TODO: Implement feedback functionality */
                    },
                    child: const Text('Feedback'),
                  ),
                  const SizedBox(width: 16),
                  OutlineGlowButton(
                    onPressed: () {
                      /* TODO: Implement support functionality */
                    },
                    child: const Text('Support'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

TextStyle textStyle = TextStyles().textMd;

class _SectionContent extends StatelessWidget {
  final String title;
  final List<String> content;
  final Widget? child;

  const _SectionContent(
      {required this.title, required this.content, this.child});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: paddingLg),
              for (String text in content) Text(text, style: textStyle),
              SizedBox(height: paddingLg),
            ],
          ),
        ),
        if (child != null) Expanded(child: child!),
      ],
    );
  }
}

class _FAQSection extends StatelessWidget {
  const _FAQSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FAQ', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        _FAQItem(
          question: 'How do I provide feedback?',
          answer:
              'Use the Feedback button below to send us your thoughts and suggestions.',
        ),
        _FAQItem(
          question: 'Where can I get support?',
          answer:
              'Click the Support button below to access our customer support resources.',
        ),
        _FAQItem(
          question: 'Credits and Copyright',
          answer:
              'GPhil is developed by Music Tech Innovations. All rights reserved. © 2024',
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({required this.question, required this.answer});

  @override
  __FAQItemState createState() => __FAQItemState();
}

class __FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          ListTile(
            title: Text(widget.question, style: TextStyles().textLg),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Text(widget.answer, style: TextStyles().textMd),
            ),
        ],
      ),
    );
  }
}

class OutlineGlowButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;

  const OutlineGlowButton(
      {super.key, required this.onPressed, required this.child});

  final double radius = 32;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: greenColor.withOpacity(0.2),
            spreadRadius: 4,
            blurRadius: 5,
          ),
        ],
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.green[500],
          backgroundColor: Colors.transparent,
          side: BorderSide(color: Colors.green[500]!, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius)),
        ),
        child: DefaultTextStyle(
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }
}
