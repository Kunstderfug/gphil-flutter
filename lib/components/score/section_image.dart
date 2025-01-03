// import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gphil/models/section.dart';
import 'package:gphil/services/app_state.dart';
import 'package:gphil/services/sanity_service.dart';
import 'package:gphil/theme/constants.dart';
import 'package:provider/provider.dart';

class SectionImageFrame extends StatelessWidget {
  final File? imageFile;
  final Section section;
  const SectionImageFrame({super.key, this.imageFile, required this.section});

  Widget _noImage(BuildContext context) => AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.grey[300], borderRadius: BorderRad().bRadiusMd),
          child: Center(
            child: Text(
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: fontSizeMd),
              'No image yet',
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final a = Provider.of<AppConnection>(context);

    if (imageFile == null) {
      return _noImage(context);
    } else {
      return kIsWeb
          ? AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRad().bRadiusMd,
                ),
                child: CachedNetworkImage(
                  imageUrl: SanityService()
                      .getImageUrl(section.sectionImage!.asset.ref),
                  placeholder: (context, url) => const Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator())),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fadeInDuration: const Duration(milliseconds: 200),
                  fadeOutDuration: const Duration(milliseconds: 200),
                ),
              ),
            )
          : AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRad().bRadiusMd,
                ),
                child: Center(
                    child: a.appState == AppState.offline && imageFile == null
                        ? const Text(
                            'Image is not available, app is offline',
                            style: TextStyle(color: Colors.black54),
                          )
                        : Image.file(
                            imageFile!,
                            filterQuality: FilterQuality.medium,
                            isAntiAlias: true,
                            fit: BoxFit.contain,
                          )),
              ),
            );
    }
  }
}
