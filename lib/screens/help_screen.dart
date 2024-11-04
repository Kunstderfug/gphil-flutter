import 'package:flutter/material.dart';
import 'package:gphil/components/standart_button.dart';
import 'package:gphil/theme/constants.dart';

TextStyle textStyle = TextStyles().textMd;
final double bottom = 90;

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _activeSection = 'about';

  final Map<String, Widget> _sections = {
    'about': const _SectionContent(title: 'About GPhil', content: [
      'GPhil is an innovative app designed for musicians to play instrumental concertos with flexible virtual orchestral accompaniment. Whether you\'re practicing for a performance or simply enjoying your favorite concertos, GPhil provides a rich, interactive experience.\n',
      'Advanced Virtual Orchestra: GPhil uses cutting-edge virtual orchestra technology based on high-quality sample libraries and synthesized instruments to create a realistic and immersive audio experience.\n',
      'For All Skill Levels: GPhil is designed to cater to musicians of all levels, from beginners to professionals. The app focuses on fostering true ensembleship and collaboration with the virtual orchestra during rehearsals and performances, providing a valuable tool for musical growth and expression.\n',
      'Professional Musician Insight: A key advantage of GPhil is the combination of advanced technology with real-world musical expertise. Developed by a professional musician with years of experience in music production and performance, the app incorporates practical insights that enhance the user\'s musical journey.\n',
      'Open-Source Foundation: GPhil is built on top of open-source technologies, including the Dart programming language, Flutter framework, and the SoLoud audio engine. This foundation ensures reliability, performance, and the potential for community-driven improvements.\n',
    ]),
    'navigation': const NavigationSection(),
    'practice': const PracticeSection(),
    'faq': const _FAQSection(),
  };

  @override
  Widget build(BuildContext context) {
    final currentIndex = _sections.keys.toList().indexOf(_activeSection);
    final nextIndex = (currentIndex + 1) % _sections.length;
    final int previousIndex =
        (currentIndex - 1 + _sections.length) % _sections.length;

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
                        Padding(
                          padding: const EdgeInsets.all(paddingMd),
                          child: Row(
                            children: [
                              StandartButton(
                                label: 'Previous',
                                icon: Icons.arrow_back,
                                iconAlignment: IconAlignment.start,
                                callback: () {
                                  setState(() => _activeSection =
                                      _sections.keys.elementAt(previousIndex));
                                },
                              ),
                              const SizedBox(width: paddingLg),
                              StandartButton(
                                  label: 'Next',
                                  icon: Icons.arrow_forward,
                                  iconAlignment: IconAlignment.end,
                                  callback: () {
                                    setState(() => _activeSection =
                                        _sections.keys.elementAt(nextIndex));
                                  }),
                            ],
                          ),
                        ),
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
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              SizedBox(height: paddingLg),
              for (String text in content) Text(text, style: textStyle),
              SizedBox(height: paddingLg),
            ],
          ),
        ),
        SizedBox(width: paddingLg),
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
              'Yes, it is. If you use GPhil for commercial purposes (for example paid performances or recordings), please contact us at vyacheslav@g-phil.app.',
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
          child: BugReportSection(),
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

class NavigationSection extends StatelessWidget {
  const NavigationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Navigating GPhil',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        _SectionContent(title: 'Step 1', content: [
          'Select a score from the library. Currently newly updated/finished scores, as well as recently accessed ones are shown in the lower part of the library screen.\n',
        ]),
        _SectionContent(title: 'Step 2', content: [
          'Explore the contents of the score. Click on the movement - you\'ll see the list of sections with a visual representation where the section starts exactly (locate a red line).\n',
          'You can listen to each section by pressing the Play button belowe the section image. The audio will start playing from the beginning of the section using the default tempo for the current section.\n',
        ]),
        _SectionContent(title: 'Step 3', content: [
          'You can download the audio files associated with the score by clicking the Download button in the score details screen. This will download all audio files for the score. Once downloaded, you can access these files without an internet connection and loading them will be almost instant.\n',
          'If there is an update for the current score, you\'ll see an Update button in the score details screen. Clicking on it will update the score to the latest version.\n',
        ]),
        _SectionContent(title: 'Step 4', content: [
          'To listen to all available tempos, add the movement (or all movements) to the Practice Playlist by clicking the + button on the right side of the movement name. This will add all sections of the movement to the Practice Playlist. You can then navigate to the Practice screen and start practicing.\n',
        ]),
      ],
    );
  }
}

class PracticeSection extends StatelessWidget {
  const PracticeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Practice', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Text('This screen is designed for practice and performance purposes. ',
            style: TextStyles().textMd),
        const SizedBox(height: 24),
        _SectionContent(title: '1. Practice Mode', content: [
          'Practice mode allows you to work in different tempos, loop sections which you want to practice repeatedly or skip ones you don\'t need.\n',
        ]),
        _SectionContent(title: '2. Performance Mode', content: [
          'Switch to Performance Mode for seamless live performance. This mode disregards looping and skipping features per section to ensure an uninterrupted play-through. The auto-continue settings will still be respected.\n',
          'Sections with auto-continue will be played back to back without needing to press the Enter key, although, if for some reason you prefer to start the next section manually, you can do so by toggling Auto-continue switch.\n'
        ]),
        _SectionContent(title: '3. Using page-turner pedal', content: [
          'Using the page-turner pedal is the best way to practice and this is what GPhil is designed for. The page-turner pedal allows you to start/stop sections while playing and makes run through possible.\n',
          'Practice and Performance modes use the same keyboard shortcuts: Enter to start/start next section, Space to stop. Set your page-turner pedal to Enter/Space mode and you\'ll be able to use it in GPhil.\n',
        ]),
        _SectionContent(title: '4. Practical tips', content: [
          'Don\'t fight with the orchestral track. Even though the tracks are created with some common freedom in mind, it is impossible to satisfy every performer\'s rubato taste and habits.\n',
          'Try to understand what orchestra is doing and what to listen to in order to stay in sync with it. It is the best way to deeply integrate your playing into the whole ensemble and be extremely comfortable with the real life orchestra accompaniment.\n',
        ]),
      ],
    );
  }
}

class OfflineUsageInfo extends StatelessWidget {
  const OfflineUsageInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoSection(
          title: 'Automatic Caching',
          content: [
            'Audio files, pictures, and metronome files from visited and practiced scores are automatically cached in the app.'
          ],
        ),
        _buildInfoSection(
          title: 'Manual Download',
          content: [
            'Use the [Download] button in the score details screen to download all files associated with a score at once.'
          ],
        ),
        _buildInfoSection(
          title: 'Offline Access',
          content: [
            'Once downloaded, you can access these files without an internet connection.'
          ],
        ),
        const SizedBox(height: 16),
        _buildImportantNote(
          'Be aware that there may be numerous files to download, which could take some time depending on your connection speed.',
        ),
      ],
    );
  }
}

Widget _buildInfoSection(
    {required String title, required List<String> content}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: fontSizeMd)),
        const SizedBox(height: 4),
        for (String text in content)
          Column(
            children: [
              Text(text, style: const TextStyle(fontSize: fontSizeMd)),
              SizedBox(height: paddingLg),
            ],
          ),
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

class BugReportSection extends StatelessWidget {
  const BugReportSection({super.key});

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
}
