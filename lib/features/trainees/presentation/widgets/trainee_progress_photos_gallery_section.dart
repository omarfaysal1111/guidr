import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/progress_photo.dart';
import '../bloc/trainees_bloc.dart';
import '../utils/trainee_media_url.dart';

/// Collapsible gallery of [ProgressPhoto] rows from `progressPhotos`, with camera/gallery upload.
class TraineeProgressPhotosGallerySection extends StatelessWidget {
  final String traineeId;
  final List<ProgressPhoto> photos;

  const TraineeProgressPhotosGallerySection({
    super.key,
    required this.traineeId,
    required this.photos,
  });

  void _openSourceSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(context, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(context, ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUpload(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final x = await picker.pickImage(
      source: source,
      imageQuality: 88,
      requestFullMetadata: false,
    );
    if (x == null) return;

    final bytes = await x.readAsBytes();
    if (bytes.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not read the image.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    var name = x.name;
    if (name.isEmpty) {
      name = 'progress_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }

    if (!context.mounted) return;
    context.read<TraineesBloc>().add(
          UploadProgressPhotoEvent(
            traineeId: traineeId,
            fileBytes: bytes,
            fileName: name,
          ),
        );
  }

  void _openViewer(BuildContext context, List<ProgressPhoto> ordered, int initialIndex) {
    final urls = ordered.map((p) => resolveTraineeMediaUrl(p.fileUrl).toString()).toList();
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (ctx) => _ProgressPhotoGalleryViewer(
          imageUrls: urls,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordered = [...photos]..sort((a, b) {
        final da = a.uploadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final db = b.uploadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return db.compareTo(da);
      });

    return BlocListener<TraineesBloc, TraineesState>(
      listenWhen: (previous, current) {
        if (previous is! TraineesLoaded || current is! TraineesLoaded) return false;
        return previous.progressPhotoUploadSaving &&
            !current.progressPhotoUploadSaving &&
            current.progressPhotoUploadError != null;
      },
      listener: (context, state) {
        if (state is TraineesLoaded && state.progressPhotoUploadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.progressPhotoUploadError!),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocBuilder<TraineesBloc, TraineesState>(
        buildWhen: (previous, current) {
          if (previous is! TraineesLoaded || current is! TraineesLoaded) {
            return current is TraineesLoaded;
          }
          return previous.progressPhotoUploadSaving != current.progressPhotoUploadSaving;
        },
        builder: (context, state) {
          final uploading = state is TraineesLoaded && state.progressPhotoUploadSaving;
          final count = ordered.length;

          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(top: 8),
                initiallyExpanded: false,
                title: Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 22, color: Colors.teal.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Progress Photos',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '$count',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                subtitle: const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Tap a thumbnail to open the gallery. Add photos from the camera or gallery.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.tonalIcon(
                      onPressed: uploading ? null : () => _openSourceSheet(context),
                      icon: uploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.add_a_photo_rounded, size: 20),
                      label: Text(uploading ? 'Uploading…' : 'Add photo'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (ordered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'No progress photos yet.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    )
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: ordered.length,
                      itemBuilder: (context, index) {
                        final p = ordered[index];
                        final uri = resolveTraineeMediaUrl(p.fileUrl);
                        final url = uri.toString();
                        return Material(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openViewer(context, ordered, index),
                            child: url.isEmpty
                                ? const Center(
                                    child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
                                  )
                                : Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Icons.broken_image_outlined, color: AppColors.error),
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProgressPhotoGalleryViewer extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _ProgressPhotoGalleryViewer({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        pageController: PageController(initialPage: initialIndex),
        itemCount: imageUrls.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrls[index]),
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.5,
            errorBuilder: (context, error, stackTrace) => Center(
              child: Text(
                'Could not load image',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
          );
        },
        loadingBuilder: (context, event) => Center(
          child: CircularProgressIndicator(
            color: Colors.white.withValues(alpha: 0.9),
            value: event == null
                ? null
                : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
          ),
        ),
      ),
    );
  }
}
