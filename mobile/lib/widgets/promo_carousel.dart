import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class PromoCarousel extends StatefulWidget {
  final List<dynamic> items;
  final void Function(dynamic item) onOrderNow;

  const PromoCarousel({
    super.key,
    required this.items,
    required this.onOrderNow,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  final PageController _controller = PageController();
  static const _autoSlideDelay = Duration(seconds: 4);
  static const _slideDuration = Duration(milliseconds: 450);
  int _page = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant PromoCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _page = 0;
      if (_controller.hasClients) {
        _controller.jumpToPage(0);
      }
    }
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    if (widget.items.length < 2) return;

    _timer = Timer.periodic(_autoSlideDelay, (_) {
      if (!mounted || !_controller.hasClients || widget.items.length < 2) {
        return;
      }

      final next = (_page + 1) % widget.items.length;
      _animateToPage(next);
    });
  }

  void _animateToPage(int page) {
    if (!_controller.hasClients) return;
    _controller.animateToPage(
      page,
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _goToPrevious() {
    final previous = (_page - 1 + widget.items.length) % widget.items.length;
    _animateToPage(previous);
    _startTimer();
  }

  void _goToNext() {
    final next = (_page + 1) % widget.items.length;
    _animateToPage(next);
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 188,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.items.length,
            onPageChanged: (i) {
              setState(() => _page = i);
              _startTimer();
            },
            itemBuilder: (_, i) => _buildSlide(widget.items[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildSlide(dynamic item) {
    final imageUrl =
        item['image'] != null ? ApiService.productImage(item['image'] as String) : null;
    final rawPrice = item['price'];
    final price = rawPrice != null ? double.tryParse(rawPrice.toString()) : null;
    final badge = item['badge_text'] as String?;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildBackground(imageUrl),
          _buildGradient(),
          _buildContent(item, badge, price),
          if (widget.items.length > 1) _buildSlideControls(),
        ],
      ),
    );
  }

  Widget _buildBackground(String? imageUrl) {
    if (imageUrl == null) {
      return Container(color: AppColors.surfaceContainerHigh);
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          Container(color: AppColors.surfaceContainerHigh),
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Container(color: AppColors.surfaceContainerHigh);
      },
    );
  }

  Widget _buildGradient() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xEE0B1326),
            Color(0xAA0B1326),
            Color(0x550B1326),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildContent(dynamic item, String? badge, double? price) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (badge != null && badge.isNotEmpty) _buildBadge(badge),
          const Spacer(),
          Text(
            item['title']?.toString() ?? '',
            style: GoogleFonts.anybody(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
              letterSpacing: 0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item['description'] != null) ...[
            const SizedBox(height: 4),
            Text(
              item['description'].toString(),
              style: GoogleFonts.hankenGrotesk(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (price != null)
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: GoogleFonts.anybody(
                    color: AppColors.primaryFixed,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              GestureDetector(
                onTap: () => widget.onOrderNow(item),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: glowLime(opacity: 0.35, blur: 14),
                  ),
                  child: Text(
                    'Order Now',
                    style: GoogleFonts.hankenGrotesk(
                      color: AppColors.onPrimaryFixed,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
        boxShadow: glowPurple(opacity: 0.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.local_fire_department_rounded,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.hankenGrotesk(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildArrowButton(Icons.chevron_left, _goToPrevious),
          const SizedBox(width: 8),
          _buildArrowButton(Icons.chevron_right, _goToNext),
        ],
      ),
    );
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: AppColors.surfaceDim.withValues(alpha: 0.68),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}
