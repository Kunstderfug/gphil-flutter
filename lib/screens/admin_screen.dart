// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/section_info.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/services/sanity_service.dart';
// import 'package:gphil/theme/constants.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'dart:convert';

import 'package:provider/provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  String? selectedFolderPath;
  String? scoreName;
  String? movementIndex;
  String? selectedScoreId;
  String movementTitle = 'Movement title';
  Map<String, List<String>> folderStructure = {};
  Map<String, SectionInfo> sectionsInfo = {};
  int imagesFound = 0;
  final SanityService _sanityService = SanityService();
  bool isUpdating = false;
  bool publishImmediately = false;
  TextEditingController movementTitleController = TextEditingController();
  final ValueNotifier<String> _progressMessage = ValueNotifier('');
  final ValueNotifier<double?> _progressValue = ValueNotifier(null);
  int globalBeatsPerBar = 4;
  int globalBeatLength = 4;
  int defaultTempo = 120;
  bool isDraft = false;

  Future<void> pickFolder() async {
    String? result = await FilePicker.platform.getDirectoryPath();

    if (result != null) {
      // Parse folder name first
      String folderName = path.basename(result);
      List<String> folderParts = folderName.split('_');

      // Last part is movement index
      movementIndex = folderParts.last;
      // Rest is score name
      scoreName = folderParts.sublist(0, folderParts.length - 1).join('_');

      setState(() {
        selectedFolderPath = result;
        analyzeFolderStructure(result);
      });
    }
  }

  void analyzeFolderStructure(String folderPath) async {
    Directory directory = Directory(folderPath);
    Map<String, List<String>> structure = {};
    Map<String, List<int>> temposBySection = {};
    Map<String, String> sectionImages = {};

    Future<void> processImagesFolder(String folderPath) async {
      try {
        // First, look for images in the PIC folder
        Directory picDirectory = Directory('$folderPath/PIC');
        if (picDirectory.existsSync()) {
          picDirectory.listSync().forEach((FileSystemEntity entity) {
            if (entity is File && path.extension(entity.path) == '.png') {
              String fileName = path.basename(entity.path);
              int firstUnderscoreIndex = fileName.indexOf('_');

              if (firstUnderscoreIndex != -1) {
                // Take everything after first underscore, remove .png extension, and convert to uppercase
                String sectionName = fileName
                    .substring(firstUnderscoreIndex + 1)
                    .replaceAll('.png', '')
                    .toUpperCase(); // Convert to uppercase to match section names
                sectionImages[sectionName] = fileName;
                imagesFound++;
              }
            }
          });
        }
      } catch (e) {
        log('Error processing images folder: $e');
      }
    }

    await processImagesFolder(folderPath);

    // Traverse through all files in the directory and subdirectories
    directory.listSync(recursive: true).forEach((FileSystemEntity entity) {
      if (entity is File && path.extension(entity.path) == '.mp3') {
        String fileName = path.basename(entity.path);
        List<String> parts = fileName.split('_');

        if (parts.length >= 2) {
          // Get tempo (last part before .mp3)
          String tempo = parts.last.replaceAll('.mp3', '');

          // Get section name (everything between score name and tempo)
          String sectionName = parts
              .sublist(scoreName!.split('_').length + 1, parts.length - 1)
              .join('_');

          // Store file in structure
          if (!structure.containsKey(sectionName)) {
            structure[sectionName] = [];
          }
          structure[sectionName]!.add(fileName);

          // Store tempo information
          if (!temposBySection.containsKey(sectionName)) {
            temposBySection[sectionName] = [];
          }
          temposBySection[sectionName]!.add(int.parse(tempo));
        }
      }
    });

    // Create SectionInfo objects
    Map<String, SectionInfo> sectionInfoMap = {};
    temposBySection.forEach((sectionName, tempos) {
      sectionInfoMap[sectionName] = SectionInfo(
        sectionName: sectionName,
        movementIndex: movementIndex!,
        tempos: tempos,
        imagePath:
            '$selectedFolderPath/PIC/${sectionImages[sectionName.toUpperCase()]}',
      );
    });

    setState(() {
      folderStructure = structure;
      sectionsInfo = sectionInfoMap;
    });

    // Set defaultTempo to the closest available tempo
    if (sectionsInfo.isNotEmpty) {
      SectionInfo firstSection = sectionsInfo.values.first;
      // Set default tempo to the minimum tempo of the first section
      setState(() {
        defaultTempo = firstSection.minTempo;
      });
    }
  }

  void exportJson() {
    if (selectedFolderPath == null) return;

    try {
      List<Map<String, dynamic>> sectionsJson = createSectionsStructure();
      String jsonString = JsonEncoder.withIndent('  ').convert(sectionsJson);

      // Create the JSON file in the selected folder
      File jsonFile = File('${selectedFolderPath!}/sections.json');
      jsonFile.writeAsStringSync(jsonString);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('JSON file created successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating JSON: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String getFormattedScoreId(String scoreId) {
    if (isDraft) {
      return 'drafts.$scoreId';
    }
    return scoreId;
  }

  List<Map<String, dynamic>> createSectionsStructure() {
    if (selectedFolderPath == null || movementIndex == null) {
      throw Exception('Required data is missing');
    }

    List<Map<String, dynamic>> sections = sectionsInfo.values.map((info) {
      Map<String, dynamic> section = {
        "name": info.sectionName,
        "movementIndex": int.parse(movementIndex!),
        "tempoRangeFull": [info.minTempo, info.maxTempo],
        "step": info.step,
        "defaultTempo": defaultTempo,
        "metronomeAvailable": true,
        "autoContinue": false,
        "beatsPerBar": globalBeatsPerBar,
        "beatLength": globalBeatLength,
        "updateRequired": false,
      };

      // Add sectionImage if available
      if (info.imagePath != null) {
        section["sectionImage"] = info.imagePath;
      }

      return section;
    }).toList();

    sections.sort((a, b) => a["name"].compareTo(b["name"]));
    return sections;
  }

  Widget buildTempoControls() {
    // Get the first section's tempos if available
    List<int> availableTempos = [];
    if (sectionsInfo.isNotEmpty) {
      SectionInfo firstSection = sectionsInfo.values.first;
      int minTempo = firstSection.minTempo;
      int maxTempo = firstSection.maxTempo;
      int step = firstSection.step;

      // Generate tempo list
      for (int tempo = minTempo; tempo <= maxTempo; tempo += step) {
        availableTempos.add(tempo);
      }

      if (!availableTempos.contains(defaultTempo)) {
        // Set to the closest available tempo
        defaultTempo = availableTempos.reduce((a, b) =>
            (a - defaultTempo).abs() < (b - defaultTempo).abs() ? a : b);
      }
    }

    return Row(
      children: [
        SizedBox(
          width: 200,
          child: availableTempos.isEmpty
              ? TextField(
                  decoration: const InputDecoration(
                    labelText: 'Default Tempo',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Color(0xFF808080),
                  ),
                  keyboardType: TextInputType.number,
                  controller:
                      TextEditingController(text: defaultTempo.toString()),
                  onChanged: (value) {
                    setState(() {
                      defaultTempo = int.tryParse(value) ?? 120;
                    });
                  },
                )
              : DropdownButtonFormField<int>(
                  value: defaultTempo,
                  decoration: const InputDecoration(
                    labelText: 'Default Tempo',
                    labelStyle: TextStyle(color: Colors.white70),
                    border: OutlineInputBorder(),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    filled: true,
                    fillColor: Color(0xFF808080),
                  ),
                  items: availableTempos.map((tempo) {
                    return DropdownMenuItem<int>(
                      value: tempo,
                      child: Text(tempo.toString()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        defaultTempo = value;
                      });
                    }
                  },
                ),
        ),
      ],
    );
  }

  Widget buildGlobalControls() {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Beats Per Bar',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Color(0xFF808080),
            ),
            keyboardType: TextInputType.number,
            controller:
                TextEditingController(text: globalBeatsPerBar.toString()),
            onChanged: (value) {
              setState(() {
                globalBeatsPerBar = int.tryParse(value) ?? 4;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        SizedBox(
          width: 100,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Beat Length',
              labelStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white54),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              filled: true,
              fillColor: Color(0xFF808080),
            ),
            keyboardType: TextInputType.number,
            controller:
                TextEditingController(text: globalBeatLength.toString()),
            onChanged: (value) {
              setState(() {
                globalBeatLength = int.tryParse(value) ?? 4;
              });
            },
          ),
        ),
      ],
    );
  }

  void _showJsonPreview() {
    if (selectedFolderPath == null) return;

    try {
      List<Map<String, dynamic>> sections = createSectionsStructure();
      String jsonString = JsonEncoder.withIndent('  ').convert(sections);

      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            width: 600,
            height: MediaQuery.of(context).size.height * 0.8,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Added this
              children: [
                const Text(
                  'JSON Preview',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center, // Added this
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Container(
                    // Wrapped in Container
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        jsonString,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14, // Added font size
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  // Wrapped button in Align
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating JSON preview: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void resetData() {
    setState(() {
      selectedFolderPath = null;
      scoreName = null;
      movementIndex = null;
      imagesFound = 0;
      movementTitleController.clear();
      movementTitle = 'Movement title';
      folderStructure.clear();
      sectionsInfo.clear();
    });
  }

  Widget buildScoreSelector() {
    return Consumer<LibraryProvider>(
      builder: (context, libraryProvider, child) {
        if (libraryProvider.isLoading) {
          return const CircularProgressIndicator();
        }

        List<LibraryItem> allScores = libraryProvider.library;

        return Row(
          children: [
            Expanded(
              child: DropdownButton<String>(
                value: selectedScoreId,
                hint: const Text('Select score from library'),
                isExpanded: true,
                items: allScores.map((LibraryItem score) {
                  bool isScoreDraft = score.id.startsWith('drafts.');

                  return DropdownMenuItem<String>(
                    value: score.id,
                    child: Row(
                      children: [
                        Text('${score.composer} - ${score.shortTitle}'),
                        if (isScoreDraft)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DRAFT',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedScoreId = newValue;
                    // Update isDraft based on selected score
                    isDraft = selectedScoreId?.startsWith('drafts.') ?? false;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            // Add draft toggle switch
            Row(
              children: [
                Transform.scale(
                  scale: 0.7,
                  child: CupertinoSwitch(
                    value: isDraft,
                    onChanged: (value) {
                      setState(() {
                        isDraft = value;
                      });
                    },
                  ),
                ),
                const Text('Draft'),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> updateScore() async {
    if (selectedScoreId == null) return;

    final String formattedScoreId = getFormattedScoreId(selectedScoreId!);

    setState(() {
      isUpdating = true;
    });

    try {
      // Show progress dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            content: SizedBox(
              width: 500,
              height: 200,
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  ValueListenableBuilder<String>(
                    valueListenable: _progressMessage,
                    builder: (context, message, _) => Text(message),
                  ),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<double?>(
                    valueListenable: _progressValue,
                    builder: (context, progress, _) => progress != null
                        ? LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.2),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // First create empty movement
      final movementKey = await _sanityService.createEmptyMovement(
          formattedScoreId, int.parse(movementIndex!), movementTitle);

      if (movementKey == null) {
        throw Exception('Failed to create movement');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Movement created successfully'),
          backgroundColor: Colors.green,
        ));
      }

      // Then update with sections
      List<Map<String, dynamic>> sectionsJson = createSectionsStructure();

      final success = await _sanityService.updateMovementSections(
        formattedScoreId,
        movementKey,
        sectionsJson,
        onProgress: (message, progress) {
          _progressMessage.value = message;
          _progressValue.value = progress;
        },
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Score updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refresh the library
        Provider.of<LibraryProvider>(context, listen: false).getLibrary();
      } else {
        throw Exception('Failed to update movement sections');
      }
    } catch (e) {
      // Close progress dialog if still open
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      log(e.toString());
    } finally {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      setState(() {
        isUpdating = false;
      });
    }
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 500,
          child: buildScoreSelector(),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _showJsonPreview,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          child: const Text('Preview JSON'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: exportJson,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            padding: const EdgeInsets.all(16),
          ),
          child: const Text('Generate JSON'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: isUpdating || selectedScoreId == null ? null : updateScore,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
            padding: const EdgeInsets.all(16),
          ),
          child: isUpdating
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Update Score'),
        ),
        buildPublishToggle(),
      ],
    );
  }

  Widget buildPublishToggle() {
    return Row(
      children: [
        Transform.scale(
          scale: 0.7,
          child: CupertinoSwitch(
            value: publishImmediately,
            onChanged: (value) {
              setState(() {
                publishImmediately = value;
              });
            },
          ),
        ),
        const Text('Publish'),
      ],
    );
  }

  // Add dispose method to clean up the controller
  @override
  void dispose() {
    movementTitleController.dispose();
    _progressMessage.dispose();
    _progressValue.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width - 240,
      height: MediaQuery.sizeOf(context).height - 80,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: pickFolder,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Select Folder'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: resetData,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedFolderPath != null) ...[
              Text('Score Name: $scoreName'),
              Text('Movement Index: $movementIndex'),
              Text('Selected folder: $selectedFolderPath'),
              Text(
                  'Images found: $imagesFound, sections: ${sectionsInfo.length}'),
              Text(
                  'selected score ID:  ${selectedScoreId != null ? selectedScoreId! : ''}'),
              const SizedBox(height: 20),
              Row(
                spacing: 40,
                children: [
                  SizedBox(
                    width: 400,
                    child: TextField(
                      controller: movementTitleController,
                      cursorColor: Colors.white,
                      decoration: InputDecoration(
                        labelText: 'Movement Title',
                        labelStyle: const TextStyle(
                            color: Colors.white70), // Label color
                        hintText: 'Enter movement title',
                        hintStyle: const TextStyle(
                            color: Colors.white30), // Hint color
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white54),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        filled: true,
                        fillColor: Colors.grey[800],
                      ),
                      onChanged: (value) {
                        setState(() {
                          movementTitle = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 40),
                  buildGlobalControls(),
                  const SizedBox(width: 16),
                  buildTempoControls(),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: sectionsInfo.length,
                    itemBuilder: (context, index) {
                      String sectionName = sectionsInfo.keys.elementAt(index);
                      SectionInfo info = sectionsInfo[sectionName]!;
                      return ListTile(
                        title: Text(sectionName),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Tempo Range: ${info.minTempo} - ${info.maxTempo}'),
                            Text('Step: ${info.step}'),
                            Text('Movement Index: ${info.movementIndex}'),
                            if (info.imagePath != null)
                              Text('Image: ${info.imagePath}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildButtons(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
