import 'dart:developer';

import 'package:flutter_sanity/flutter_sanity.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:gphil/models/library.dart';
import 'package:gphil/models/score.dart';

class SanityService {
  static const String sanityProjectId = 'b8uar5wl';

  static final SanityClient sanity = SanityClient(
    projectId: sanityProjectId,
    dataset: 'production',
  );

  static final imageBuilder = ImageUrlBuilder(sanity);

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
        "{_id,_updatedAt,_rev,composer,instrument,price_id,price,key,about,movements,pathName,ready,shortTitle,tips,audio_format,'slug': slug.current,title,full_score_url, piano_score_url, layers}";

    return '$query $params';
  }

  String queryImageUrl(String imageRef) {
    int lastIndex = imageRef.lastIndexOf("-");

    if (lastIndex != -1) {
      imageRef = imageRef.replaceRange(lastIndex, lastIndex + 1, ".");
    }
    imageRef = imageRef.replaceFirst('image-', '');
    return 'https://cdn.sanity.io/images/b8uar5wl/production/$imageRef?w=1536&auto=format';
  }

  Future<List<LibraryItem>> fetchLibrary() async {
    final query = queryLibrary();
    final response = await sanity.fetch(query);
    return libraryFromJson(response);
  }

  Future<Score?> fetchScore(String id) async {
    final query = queryScore(id);
    try {
      final response = await sanity.fetch(query);
      return Score.fromJson(response[0]);
    } catch (e) {
      log('Error: $e');
    }
    return null;
  }

  ImageUrlBuilder urlForImage(SanityImageSource asset) {
    log('urlforimage: $asset');
    return imageBuilder.image(asset);
  }
}
