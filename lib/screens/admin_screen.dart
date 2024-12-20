// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/section_info.dart';
import 'package:gphil/providers/library_provider.dart';
import 'package:gphil/services/sanity_service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:gphil/models/score.dart';
import 'package:gphil/models/movement.dart';
import 'package:gphil/models/section.dart';
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
  Map<String, List<String>> folderStructure = {};
  Map<String, SectionInfo> sectionsInfo = {};
  int imagesFound = 0;
  final SanityService _sanityService = SanityService();
  bool isUpdating = false;
  bool publishImmediately = false;

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

  void analyzeFolderStructure(String folderPath) {
    Directory directory = Directory(folderPath);
    Map<String, List<String>> structure = {};
    Map<String, List<int>> temposBySection = {};
    Map<String, String> sectionImages = {};

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
          }
        }
      });
    }

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
        imagePath: sectionImages[sectionName.toUpperCase()],
      );
    });

    setState(() {
      folderStructure = structure;
      sectionsInfo = sectionInfoMap;
    });
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

  List<Map<String, dynamic>> createSectionsStructure() {
    if (selectedFolderPath == null || movementIndex == null) {
      throw Exception('Required data is missing');
    }

    List<Map<String, dynamic>> sections = sectionsInfo.values.map((info) {
      Map<String, dynamic> section = {
        "name": info.sectionName,
        "movementIndex": int.parse(movementIndex!),
        // "_key": info.sectionName,
        "tempoRangeFull": [info.minTempo, info.maxTempo],
        "step": info.step,
        "defaultTempo": info.minTempo,
        "metronomeAvailable": true,
        "autoContinue": false,
        "beatsPerBar": 4,
        // "defaultSectionLength": 30.0,
        "beatLength": 4,
        // "layerStep": info.step,
        // "tempoRangeLayers": [info.minTempo, info.maxTempo],
        "updateRequired": false,
      };

      // Add sectionImage if available
      if (info.imagePath != null) {
        section["sectionImage"] = {
          "_type": "image",
          "asset": {"_type": "reference", "_ref": info.imagePath}
        };
      }

      return section;
    }).toList();

    sections.sort((a, b) => a["name"].compareTo(b["name"]));
    return sections;
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
            width: 400,
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

        return DropdownButton<String>(
          value: selectedScoreId,
          hint: const Text('Select score from library'),
          isExpanded: true,
          items: allScores.map((LibraryItem score) {
            return DropdownMenuItem<String>(
              value: score.id,
              child: Text('${score.composer} - ${score.shortTitle}'),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedScoreId = newValue;
            });
          },
        );
      },
    );
  }

  Future<void> updateScore() async {
    if (selectedScoreId == null) return;

    setState(() {
      isUpdating = true;
    });

    try {
      // First create empty movement
      final movementKey = await _sanityService.createEmptyMovement(
          selectedScoreId!, int.parse(movementIndex!));

      if (movementKey == null) {
        throw Exception('Failed to create movement');
      }

      // Then update with sections
      List<Map<String, dynamic>> sectionsJson = createSectionsStructure();

      final success = await _sanityService.updateMovementSections(
        selectedScoreId!,
        movementKey,
        sectionsJson,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating score: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
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
          width: 400,
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
        const Text('Publish immediately'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width - 240,
      height: MediaQuery.sizeOf(context).height - 120,
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
              Text('Images found: $imagesFound'),
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

  // Update createScoreStructure() to use the new sectionsInfo
  InitScore createScoreStructure() {
    if (selectedFolderPath == null) {
      return InitScore(
        pathName: '',
        slug: '',
        movements: [],
        updatedAt: DateTime.now(),
        rev: '',
        id: '',
        shortTitle: '',
        composer: '',
      );
    }

    List<InitSection> sections = sectionsInfo.values
        .map((info) => InitSection(
              name: info.sectionName,
              movementIndex: int.parse(info.movementIndex),
              key: info.sectionName,
              tempoRangeFull: [info.minTempo, info.maxTempo],
              step: info.step,
              defaultTempo: info.minTempo,
            ))
        .toList();

    List<InitMovement> movements = [
      InitMovement(
        score: ScoreRef(ref: scoreName!),
        index: int.parse(movementIndex!),
        key: 'movement_$movementIndex',
        title: 'Movement $movementIndex',
        sections: sections,
      )
    ];

    return InitScore(
      pathName: path.basename(selectedFolderPath!),
      slug: scoreName!.toLowerCase(),
      movements: movements,
      updatedAt: DateTime.now(),
      rev: '1',
      id: scoreName!,
      shortTitle: scoreName!.split('_')[0],
      composer: scoreName!.split('_')[0],
    );
  }
}
