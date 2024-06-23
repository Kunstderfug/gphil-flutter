import 'dart:convert';
import 'dart:developer';
import 'package:gphil/controllers/persistent_data_controller.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/score.dart';
import 'package:http/http.dart';

final persistentController = PersistentDataController();

class SanityService {
  static const String sanityProjectId = 'b8uar5wl';
  static const String projectUrl =
      'https://b8uar5wl.api.sanity.io/v2023-05-03/data/query/production?query=';

  //set query for library
  static String queryLibrary() {
    const query =
        '*[_type == "score" && private != true && complete>0] | order(title asc)';

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
}
