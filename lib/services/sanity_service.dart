import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/score.dart';
import 'package:http/http.dart';
import 'package:sanity_client/sanity_client.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

final persistentController = PersistentDataController();

class AppVersionInfo {
  final String date;
  final String build;
  final List<String> changes;
  bool? test;

  AppVersionInfo({
    required this.date,
    required this.build,
    required this.changes,
    this.test,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    return AppVersionInfo(
      date: json['date'],
      build: json['build'],
      test: json['test'] ?? false,
      changes: List<String>.from(json['changes'] ?? []),
    );
  }
}

class SanityService {
  static const String projectId = 'b8uar5wl';
  static const String apiVersion = 'v2024-12-20';
  static const String dataset = 'production';
  static const String projectUrl =
      'https://b8uar5wl.api.sanity.io/$apiVersion/data/query/production?query=';
  static const String token =
      'skH2b5XXYUO0lGjSeeGeVJt91QitMN8OIYEWK8AIMCajlwLVQFS6k2pSenDZ6sqeZo4QxR8T0Em8Y2QDdeNs1uLfEhTiI5YciLqjTYvZcoSsNdrJwiW0zguARBivl4QO4YzDT1GbpNZs659ASliD6Z771TFJBu9S2jHUvVgxrgTQLnuF93Cc';

  final SanityClient sanityClient = SanityClient(SanityConfig(
    projectId: projectId,
    dataset: dataset,
    token: token,
    perspective: Perspective.raw,
    explainQuery: true,
    // useCdn: true,
    apiVersion: apiVersion,
  ));

  String queryVersion() {
    const query =
        '*[_type == "app_version" ${kDebugMode ? '' : '&& test != true'}] | order(build desc)[0]';
    return query;
  }

  //set query for library
  static String queryLibrary() {
    const String isAdmin = kDebugMode ? '' : '&& complete>0';

    const query =
        '*[_type == "score" && private != true $isAdmin] | order(title asc)';

    const params =
        "{_id,_updatedAt,_rev,composer,instrument,key,pathName,private,ready,complete,shortTitle,'slug': slug.current, layers}";

    return '$query$params';
  }

//set query for score by id
  static String queryScore(String id) {
    final query = "*[_type == 'score' && _id == '$id']";
    const params =
        "{_id,_updatedAt,_rev,composer,instrument,price_id,price,key,about,movements,pathName,ready,shortTitle,tips,audio_format,'slug': slug.current,title,'full_score_url':full_score_download.asset->url,'piano_score_url':piano_score_download.asset->url, layers}";

    return '$query $params';
  }

  static String scoreRevisionQuery(String id) {
    return "*[_type == 'score' && _id == '$id']._rev";
  }

  //get app version
  Future<AppVersionInfo?> getOnlineVersion() async {
    final String query = queryVersion();
    final queryRequest = Uri.encodeQueryComponent(query);
    try {
      final response = await Client().get(Uri.parse(projectUrl + queryRequest));
      if (response.statusCode == 200) {
        // log('online version: ${json.decode(response.body)['result']}');
        return AppVersionInfo.fromJson(json.decode(response.body)['result']);
      } else {
        log('Sanity Error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  String getImageUrl(String imageRef) {
    int lastIndex = imageRef.lastIndexOf("-");

    if (lastIndex != -1) {
      imageRef = imageRef.replaceRange(lastIndex, lastIndex + 1, ".");
    }
    imageRef = imageRef.replaceFirst('image-', '');
    final imageUrl =
        'https://cdn.sanity.io/images/b8uar5wl/production/$imageRef?w=1536&auto=format';

    return imageUrl;
  }

  Future<List<LibraryItem>> fetchLibrary() async {
    final String query = queryLibrary();
    final String queryRequest = Uri.encodeQueryComponent(query);
    try {
      Response response = await Client().get(
        Uri.parse(projectUrl + queryRequest),
      );

      if (response.statusCode == 200) {
        return (json.decode(response.body)['result'] as List)
            .map((e) => LibraryItem.fromJson(e))
            .toList();
      } else {
        log(response.body.toString());
      }
    } catch (e) {
      log('Error: $e');
    }
    return [];
  }

  Future<InitScore?> fetchScore(String id) async {
    final String query = queryScore(id);
    final queryRequest = Uri.encodeQueryComponent(query);
    try {
      Response response = await Client().get(
        Uri.parse(projectUrl + queryRequest),
      );
      if (response.statusCode == 200) {
        return InitScore.fromJson(json.decode(response.body)['result'][0]);
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  Future<String?> getScoreRevision(String id) async {
    final String query = scoreRevisionQuery(id);
    final queryRequest = Uri.encodeQueryComponent(query);
    try {
      Response response = await Client().get(
        Uri.parse(projectUrl + queryRequest),
      );
      if (response.statusCode == 200) {
        return json.decode(response.body)['result'][0];
      }
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  Future<String?> createEmptyMovement(
      String scoreId, int movementIndex, String title,
      {bool publishImmediately = false}) async {
    try {
      // Generate a unique key for the movement
      String movementKey = 'movement_${DateTime.now().millisecondsSinceEpoch}';

      final mutation = {
        'mutations': [
          {
            'patch': {
              'id': scoreId,
              'insert': {
                'after': 'movements[-1]',
                'items': [
                  {
                    '_key': movementKey,
                    '_type': 'movement',
                    'index': movementIndex,
                    'score': {'_ref': scoreId, '_type': 'reference'},
                    'title': title,
                    'sections': []
                  }
                ]
              }
            }
          }
        ]
      };

      final url = Uri.parse(
          'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset?returnDocuments=true'
          '${publishImmediately ? '&publish=true' : ''}');

      final response = await Client().post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(mutation),
      );

      if (response.statusCode == 200) {
        // Instead of trying to get the key from the response,
        // return the key we generated
        log('Created Movement: ${response.body}');
        return movementKey;
      }

      log('Sanity Error: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      log('Error creating movement: $e');
      return null;
    }
  }

  Future<bool> updateMovementSections(
      String scoreId, String movementKey, List<Map<String, dynamic>> sections,
      {bool publishImmediately = false,
      void Function(String message, double? progress)? onProgress}) async {
    try {
      //take two sections for thesting
      // sections = sections.sublist(0, 2);

      // First, upload all images and update sections with image references
      final uuid = Uuid();
      final processedSections = <Map<String, dynamic>>[];
      int totalImages = sections
          .where((s) =>
              s['sectionImage'] is String &&
              File(s['sectionImage']).existsSync())
          .length;
      int uploadedImages = 0;

      for (var section in sections) {
        var processedSection = Map<String, dynamic>.from(section);
        processedSection['_key'] ??= uuid.v4();

        if (section.containsKey('sectionImage') &&
            section['sectionImage'] is String &&
            File(section['sectionImage']).existsSync()) {
          String imagePath = section['sectionImage'];

          try {
            // Update progress
            onProgress?.call('Uploading image for section: ${section['name']}',
                uploadedImages / totalImages);
            // log('Debug image path: $imagePath');
            final file = File(imagePath);
            final bytes = await file.readAsBytes();
            final extension = path.extension(imagePath).toLowerCase();

            // Determine content type based on file extension
            final contentType = switch (extension) {
              '.jpg' || '.jpeg' => 'image/jpeg',
              '.png' => 'image/png',
              '.gif' => 'image/gif',
              '.webp' => 'image/webp',
              _ => 'image/jpeg'
            };

            final url = Uri.parse(
                'https://$projectId.api.sanity.io/$apiVersion/assets/images/$dataset');

            final response = await post(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': contentType,
              },
              body: bytes, // Send raw binary data
            );

            // log('Response status: ${response.statusCode}');
            // log('Response body: ${response.body}');

            if (response.statusCode == 200 || response.statusCode == 201) {
              final jsonResponse = json.decode(response.body);
              processedSection['sectionImage'] = {
                '_type': 'image',
                'asset': {
                  '_type': 'reference',
                  '_ref': jsonResponse['document']['_id'],
                }
              };
              uploadedImages++;
              onProgress?.call('Uploaded image for section: ${section['name']}',
                  uploadedImages / totalImages);
            }
          } catch (e) {
            log('Error processing image: $e');
            // Continue with the section even if image upload fails
            processedSection.remove('sectionImage');
          }
        }

        processedSections.add(processedSection);
      }

      onProgress?.call('Updating movement with sections...', null);

      // Create mutation with processed sections
      final mutation = {
        'mutations': [
          {
            'patch': {
              'id': scoreId,
              'set': {
                'movements[_key == "$movementKey"].sections': processedSections
              }
            }
          }
        ]
      };

      // log('Final mutation payload: ${jsonEncode(mutation)}');

      // log('First section example: ${jsonEncode(sections.first)}');

      final url = Uri.parse(
          'https://$projectId.api.sanity.io/$apiVersion/data/mutate/$dataset'
          '${publishImmediately ? '?publish=true' : ''}');

      final response = await Client().post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(mutation),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // log(responseData);
        return responseData['results'] != null;
      }

      log('Sanity Error: ${response.statusCode} ${response.body}');
      return false;
    } catch (e) {
      log('Error updating movement sections: $e');
      return false;
    }
  }
}
