import 'package:flutter_sanity/flutter_sanity.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';

final sanityClient = SanityClient(
  dataset: 'production',
  projectId: 'b8uar5wl',
);

final sanityImageBuilder = ImageUrlBuilder(sanityClient);

ImageUrlBuilder urlFor(asset) {
  return sanityImageBuilder.image(asset);
}
