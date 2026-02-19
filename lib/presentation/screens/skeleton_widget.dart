import 'package:flutter/material.dart';

class SkeletonWidget extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonWidget({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  State<SkeletonWidget> createState() => _SkeletonWidgetState();
}

class _SkeletonWidgetState extends State<SkeletonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

// ── Skeleton for Food Card (horizontal list) ──
class FoodCardSkeleton extends StatelessWidget {
  const FoodCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SkeletonWidget(width: 100, height: 12, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 8),
          SkeletonWidget(width: 60,  height: 10, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 10),
          SkeletonWidget(
            width: double.infinity,
            height: 100,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonWidget(width: 60, height: 10, borderRadius: BorderRadius.circular(6)),
                  const SizedBox(height: 4),
                  SkeletonWidget(width: 50, height: 10, borderRadius: BorderRadius.circular(6)),
                ],
              ),
              SkeletonWidget(
                width: 34, height: 34,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Cart Item ──
class CartItemSkeleton extends StatelessWidget {
  const CartItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonWidget(
            width: 60, height: 60,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(width: 120, height: 12, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                SkeletonWidget(width: 70,  height: 10, borderRadius: BorderRadius.circular(6)),
              ],
            ),
          ),
          Row(
            children: [
              SkeletonWidget(width: 28, height: 28, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 10),
              SkeletonWidget(width: 20, height: 14, borderRadius: BorderRadius.circular(6)),
              const SizedBox(width: 10),
              SkeletonWidget(width: 28, height: 28, borderRadius: BorderRadius.circular(8)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Favorite Card (grid) ──
class FavoriteCardSkeleton extends StatelessWidget {
  const FavoriteCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(
            width: double.infinity,
            height: 110,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonWidget(width: 100, height: 12, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                SkeletonWidget(width: 60,  height: 10, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonWidget(width: 50, height: 10, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(width: 8),
                    SkeletonWidget(width: 40, height: 10, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Order Item ──
class OrderItemSkeleton extends StatelessWidget {
  const OrderItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(width: 130, height: 14, borderRadius: BorderRadius.circular(6)),
              SkeletonWidget(width: 70,  height: 24, borderRadius: BorderRadius.circular(20)),
            ],
          ),
          const SizedBox(height: 12),
          SkeletonWidget(width: 180, height: 11, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 8),
          SkeletonWidget(width: 120, height: 11, borderRadius: BorderRadius.circular(6)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(width: 80, height: 12, borderRadius: BorderRadius.circular(6)),
              SkeletonWidget(width: 90, height: 34, borderRadius: BorderRadius.circular(12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Notification Item ──
class NotificationItemSkeleton extends StatelessWidget {
  const NotificationItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonWidget(
            width: 44, height: 44,
            borderRadius: BorderRadius.circular(22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonWidget(width: 140, height: 13, borderRadius: BorderRadius.circular(6)),
                    SkeletonWidget(width: 40,  height: 10, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
                const SizedBox(height: 8),
                SkeletonWidget(width: double.infinity, height: 11, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 5),
                SkeletonWidget(width: 180, height: 11, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 10),
                SkeletonWidget(width: 80,  height: 24, borderRadius: BorderRadius.circular(10)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Search Item ──
class SearchItemSkeleton extends StatelessWidget {
  const SearchItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SkeletonWidget(
            width: 65, height: 65,
            borderRadius: BorderRadius.circular(12),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonWidget(width: 120, height: 13, borderRadius: BorderRadius.circular(6)),
                    SkeletonWidget(width: 60,  height: 22, borderRadius: BorderRadius.circular(10)),
                  ],
                ),
                const SizedBox(height: 8),
                SkeletonWidget(width: double.infinity, height: 11, borderRadius: BorderRadius.circular(6)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    SkeletonWidget(width: 50, height: 11, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(width: 8),
                    SkeletonWidget(width: 50, height: 11, borderRadius: BorderRadius.circular(6)),
                    const SizedBox(width: 8),
                    SkeletonWidget(width: 40, height: 11, borderRadius: BorderRadius.circular(6)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton for Home Section (horizontal scroll) ──
class HomeSectionSkeleton extends StatelessWidget {
  const HomeSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SkeletonWidget(width: 150, height: 18, borderRadius: BorderRadius.circular(8)),
              SkeletonWidget(width: 50,  height: 14, borderRadius: BorderRadius.circular(6)),
            ],
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 4,
            itemBuilder: (_, __) => const FoodCardSkeleton(),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}