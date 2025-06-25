// widgets/upload_options_modal.dart
import 'package:flutter/material.dart';
import 'dart:io';
import '../services/image_service.dart';

class UploadOptionsModal extends StatefulWidget {
  final Function(File) onBillUpload;
  final Function(File) onRefrigeratorUpload;

  const UploadOptionsModal({
    Key? key,
    required this.onBillUpload,
    required this.onRefrigeratorUpload,
  }) : super(key: key);

  @override
  State<UploadOptionsModal> createState() => _UploadOptionsModalState();
}

class _UploadOptionsModalState extends State<UploadOptionsModal>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _handleBillOption() async {
    await _showImageSourceDialog((File image) {
      widget.onBillUpload(image);
    });
  }

  Future<void> _handleRefrigeratorOption() async {
    await _showImageSourceDialog((File image) {
      widget.onRefrigeratorUpload(image);
    });
  }

  Future<void> _showImageSourceDialog(Function(File) onImageSelected) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.pickImageFromCamera();
                if (image != null) {
                  onImageSelected(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final image = await ImageService.pickImageFromGallery();
                if (image != null) {
                  onImageSelected(image);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            margin: const EdgeInsets.only(top: 100),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'Upload Your Photo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose what you\'d like to scan for recipes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      
                      // Grocery Bill Option
                      _buildUploadOption(
                        icon: Icons.receipt_long,
                        title: 'Grocery Bill',
                        subtitle: 'Scan your grocery receipt to generate meal plans',
                        color: Colors.blue,
                        onTap: _handleBillOption,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Refrigerator Option
                      _buildUploadOption(
                        icon: Icons.kitchen,
                        title: 'Refrigerator Contents',
                        subtitle: 'Photo of your fridge for available ingredients',
                        color: Colors.green,
                        onTap: _handleRefrigeratorOption,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Cancel Button
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 28,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}