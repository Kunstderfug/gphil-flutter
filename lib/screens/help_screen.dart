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
        padding: const EdgeInsets.only(
            left: paddingXl,
            right: paddingXl,
            top: paddingXl,
            bottom: paddingXs),
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
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _sections[_activeSection] ?? const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
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
        child != null
            ? Expanded(child: child!)
            : Expanded(child: const SizedBox()),
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
          question: 'Is the app free to use?',
          answer:
              'Yes, it is. If you use GPhil for commercial purposes (for example paid performances or recordings), please contact us at vyacheslav@g-phil.app',
        ),
        _FAQItem(
          question: 'Can the app be used offline?',
          answer:
              "Yes, the app can be used offline. Here's what you need to know:",
          child: OfflineUsageInfo(),
        ),
        _FAQItem(
          question: 'What if there is a problem with the app?',
          // answer: '',
          child: BagReportSection(),
        ),
        _FAQItem(
          question: 'Credits and Copyright',
          answer:
              "GPhil's concept, software realization and contents of the GPhil library are made by Vyacheslav Gryaznov.\nAll rights reserved © 2024",
        ),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String? answer;
  final Widget? child;

  const _FAQItem({required this.question, this.answer, this.child});

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(widget.question, style: TextStyles().textLg),
            ),
            trailing: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.all(paddingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.answer != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.answer!, style: TextStyles().textMd),
                        SizedBox(height: paddingLg),
                      ],
                    ),
                  if (widget.child != null) widget.child!,
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class OfflineUsageInfo extends StatelessWidget {
  const OfflineUsageInfo({super.key});

  Widget _buildInfoSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeMd)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: fontSizeMd)),
        ],
      ),
    );
  }

  Widget _buildImportantNote(String content) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // color: Colors.yellow[800],
        border: Border.all(color: redColor, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Important Note',
              style:
                  TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeMd)),
          const SizedBox(height: 4),
          Text(content, style: const TextStyle(fontSize: fontSizeMd)),
        ],
      ),
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.key + 1}. ',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(entry.value)),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          title: 'Automatic Caching',
          content:
              'Audio files, pictures, and metronome files from visited and practiced scores are automatically saved in the app\'s cache.',
        ),
        _buildInfoSection(
          title: 'Manual Download',
          content:
              'Use the [Download] button in the score details screen to download all files associated with a score at once.',
        ),
        _buildInfoSection(
          title: 'Offline Access',
          content:
              'Once downloaded, you can access these files without an internet connection.',
        ),
        const SizedBox(height: 16),
        _buildImportantNote(
          'Be aware that there may be numerous files to download, which could take some time depending on your connection speed.',
        ),
      ],
    );
  }
}

class BagReportSection extends StatelessWidget {
  const BagReportSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Submit a bug report using the button at the bottom of the sidebar or on the Practice page. This will forward you to the Discord server dedicated to bugs and errors.',
            style: TextStyle(fontSize: fontSizeMd)),
        const SizedBox(height: 16),
        const Text('Please include the following information:',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeMd)),
        const SizedBox(height: 8),
        _buildNumberedList([
          'What you were doing when the error occurred',
          'What you expected to happen',
          'What actually happened',
          'Your device information (e.g., model, OS version)',
        ]),
      ],
    );
  }

  Widget _buildNumberedList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${entry.key + 1}. ',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: fontSizeMd)),
              Expanded(
                  child: Text(entry.value,
                      style: const TextStyle(fontSize: fontSizeMd))),
            ],
          ),
        );
      }).toList(),
    );
  }
}
