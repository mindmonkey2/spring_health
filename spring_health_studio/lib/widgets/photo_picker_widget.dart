import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Drop-in reusable widget for member and trainer photo upload/display.
///
/// Usage:
///   PhotoPickerWidget(
///     currentPhotoUrl: member.photoUrl,
///     initials: member.name.substring(0, 1),
///     accentColor: AppColors.success,
///     onPhotoSelected: (file) => setState(() => _pickedFile = file),
///   )
class PhotoPickerWidget extends StatefulWidget {
  final String? currentPhotoUrl;
  final String initials;
  final Color accentColor;
  final double radius;
  final void Function(File file) onPhotoSelected;

  const PhotoPickerWidget({
    super.key,
    this.currentPhotoUrl,
    required this.initials,
    required this.accentColor,
    this.radius = 48,
    required this.onPhotoSelected,
  });

  @override
  State<PhotoPickerWidget> createState() => _PhotoPickerWidgetState();
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget> {
  // FIX 1: Use ImagePicker directly — StorageService has no pickImage()
  final _picker = ImagePicker();

  File? _localFile;
  bool _isPicking = false;

  ImageProvider? get _imageProvider {
    if (_localFile != null) return FileImage(_localFile!);
    if (widget.currentPhotoUrl != null &&
        widget.currentPhotoUrl!.isNotEmpty) {
      return NetworkImage(widget.currentPhotoUrl!);
    }
    return null;
  }

  void _showSourcePicker() {
    // FIX 2: Guard against opening sheet while already picking
    if (_isPicking) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Photo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.photo_library_rounded,
                  color: widget.accentColor),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                await _pick(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt_rounded,
                  color: widget.accentColor),
              title: const Text('Take a Photo'),
              onTap: () async {
                Navigator.pop(context);
                await _pick(ImageSource.camera);
              },
            ),
            // FIX 3: Show remove option only when a photo exists
            if (_localFile != null || widget.currentPhotoUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded,
                    color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _localFile = null);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    setState(() => _isPicking = true);
    try {
      // FIX 4: Compress to 85% quality at max 800px — reduces upload size significantly
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked == null) return; // user cancelled

      final file = File(picked.path);
      setState(() => _localFile = file);
      widget.onPhotoSelected(file);
    } catch (e) {
      // FIX 5: Surface errors to user instead of silently failing
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.camera
                  ? 'Camera permission denied or unavailable'
                  : 'Could not access gallery',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIX 6: Wrap Stack in SizedBox so badge Positioned doesn't overflow unpredictably
    final diameter = widget.radius * 2;
    return GestureDetector(
      onTap: _showSourcePicker,
      child: SizedBox(
        width: diameter + 16,
        height: diameter + 16,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // FIX 7: Show loading indicator while picking
            if (_isPicking)
              CircleAvatar(
                radius: widget.radius,
                backgroundColor:
                    widget.accentColor.withValues(alpha: 0.15),
                child: SizedBox(
                  width: widget.radius * 0.6,
                  height: widget.radius * 0.6,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: widget.accentColor,
                  ),
                ),
              )
            else
              CircleAvatar(
                radius: widget.radius,
                backgroundColor:
                    widget.accentColor.withValues(alpha: 0.15),
                // FIX 8: backgroundImage must be null when child is shown,
                // and child must be null when image is shown
                backgroundImage: _imageProvider,
                child: _imageProvider == null
                    ? Text(
                        widget.initials.isNotEmpty
                            ? widget.initials[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: widget.radius * 0.6,
                          fontWeight: FontWeight.bold,
                          color: widget.accentColor,
                        ),
                      )
                    : null,
              ),
            // Camera badge
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _isPicking ? Colors.grey : widget.accentColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  _isPicking
                      ? Icons.hourglass_top_rounded
                      : Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
