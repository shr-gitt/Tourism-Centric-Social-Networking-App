import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ImageDisplayWithButtons extends StatefulWidget {
  final List<String> imageUrls;
  const ImageDisplayWithButtons({super.key, required this.imageUrls});

  @override
  State<ImageDisplayWithButtons> createState() =>
      _ImageDisplayWithButtonsState();
}

class _ImageDisplayWithButtonsState extends State<ImageDisplayWithButtons> {
  final PageController _pageController = PageController();
  //int _currentPage = 0;

  /*void _goToNextPage() {
    if (_currentPage < widget.imageUrls.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }*/

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 250,
      child: Column(
        children: [
          // Prev Button
          /*IconButton(
            onPressed: _currentPage > 0 ? _goToPreviousPage : null,
            icon: const Icon(Icons.arrow_back_ios),
          ),*/
          // Image carousel
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.imageUrls.length,
              //onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                );
              },
            ),
          ),
          // Next Button
          /*IconButton(
            onPressed: _currentPage < widget.imageUrls.length - 1
                ? _goToNextPage
                : null,
            icon: const Icon(Icons.arrow_forward_ios),
          ),*/
          SizedBox(height: 10),
          SmoothPageIndicator(
            controller: _pageController,
            count: widget.imageUrls.length,
            effect: WormEffect(
              dotHeight: 8,
              dotWidth: 8,
              activeDotColor: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
