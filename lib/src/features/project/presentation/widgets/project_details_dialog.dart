import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:portfolio/src/localization/generated/locale_keys.g.dart';
// Import your Project model here
// import 'package:portfolio/src/common/domain/project.dart';

class ProjectDetailDialog extends StatefulWidget {
  final String name;
  final String description;
  final List<String>
      images; // Local asset paths e.g. ['assets/projects/chaty/1.jpg']

  const ProjectDetailDialog({
    super.key,
    required this.name,
    required this.description,
    required this.images,
  });

  static Future<void> show(
    BuildContext context, {
    required String name,
    required String description,
    required List<String> images,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => ProjectDetailDialog(
        name: name,
        description: description,
        images: images,
      ),
    );
  }

  @override
  State<ProjectDetailDialog> createState() => _ProjectDetailDialogState();
}

class _ProjectDetailDialogState extends State<ProjectDetailDialog> {
  int _selectedImageIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      // Reduced padding to allow the dialog to expand wider on large screens
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        // Responsive constraints: takes up more space (up to 950px wide and 85% height)
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.90,
          maxHeight: screenSize.height * 0.85,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Project Title + Close Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.name,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable Content Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Responsive Image Viewer / Carousel
                    if (widget.images.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          // Dynamic height based on screen size (takes ~45% of screen height)
                          height: screenSize.height * 0.45,
                          constraints: const BoxConstraints(
                            minHeight: 250,
                            maxHeight: 500,
                          ),
                          color: Colors.black.withAlpha(128),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: widget.images.length,
                            onPageChanged: (index) {
                              setState(() => _selectedImageIndex = index);
                            },
                            itemBuilder: (context, index) {
                              return InteractiveViewer(
                                // Allows users to zoom in/out of screenshots if needed
                                panEnabled: true,
                                scaleEnabled: true,
                                minScale: 1.0,
                                maxScale: 30.0,
                                child: Image.asset(
                                  widget.images[index],
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 48,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Image Thumbnails Indicator List
                      if (widget.images.length > 1)
                        SizedBox(
                          height: 70,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              final isSelected = _selectedImageIndex == index;
                              return GestureDetector(
                                onTap: () {
                                  _pageController.animateToPage(
                                    index,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: Container(
                                  width: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : Colors.transparent,
                                      width: 2.5,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.asset(
                                      widget.images[index],
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 24),
                    ],

                    // Description Section
                    Text(
                      tr(LocaleKeys.aboutProject),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.6,
                        color: theme.textTheme.bodyMedium?.color
                            ?.withAlpha(217),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
