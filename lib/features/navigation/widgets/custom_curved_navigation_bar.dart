import 'package:flutter/material.dart';

class CustomNavBarItem {
  final IconData icon;
  final String label;
  final bool showBadge;

  CustomNavBarItem({
    required this.icon,
    required this.label,
    this.showBadge = false,
  });
}

class CustomCurvedNavigationBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<CustomNavBarItem> items;
  final Color backgroundColor;
  final Color activeColor;
  final Color inactiveColor;

  const CustomCurvedNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    this.backgroundColor = const Color(0xFF2C4375),
    this.activeColor = Colors.white,
    this.inactiveColor = Colors.white60,
  });

  @override
  State<CustomCurvedNavigationBar> createState() => _CustomCurvedNavigationBarState();
}

class _CustomCurvedNavigationBarState extends State<CustomCurvedNavigationBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.selectedIndex;
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _animation = Tween<double>(begin: _previousIndex.toDouble(), end: widget.selectedIndex.toDouble())
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(CustomCurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _previousIndex = oldWidget.selectedIndex;
      _animation = Tween<double>(begin: _previousIndex.toDouble(), end: widget.selectedIndex.toDouble())
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: SizedBox(
          height: 52,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final itemWidth = (MediaQuery.of(context).size.width - 32) / widget.items.length;
              final notchX = (_animation.value * itemWidth) + (itemWidth / 2);

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The bar with the smooth notch and shadow
                  PhysicalShape(
                    color: widget.backgroundColor,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    elevation: 10,
                    clipper: NotchClipper(notchX: notchX),
                    child: const SizedBox.expand(),
                  ),
                  
                  // The white circle for the active item
                  Positioned(
                    left: notchX - 22, // Center is notchX, width is 44, so offset is 22
                    top: -22, // Push circle HIGHER so its center aligns with the top edge (y=0)
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // The icons and labels
                  Row(
                    children: List.generate(widget.items.length, (index) {
                      bool isSelected = widget.selectedIndex == index;
                      final item = widget.items[index];

                      return Expanded(
                        child: GestureDetector(
                          onTap: () => widget.onItemSelected(index),
                          behavior: HitTestBehavior.opaque,
                          child: Stack(
                            clipBehavior: Clip.none,
                            alignment: Alignment.center,
                            children: [
                              // Icon
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                // Icon size is 24. If top is -12, center of icon is at y=0
                                top: isSelected ? -12 : 14,
                                left: 0,
                                right: 0,
                                child: Icon(
                                  item.icon,
                                  color: isSelected ? widget.backgroundColor : widget.inactiveColor,
                                  size: 24,
                                ),
                              ),
                              // Red dot
                              if (item.showBadge)
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                  top: isSelected ? -12 : 12,
                                  right: (itemWidth / 2) - 14,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFDC2626),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              // Label
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOutCubic,
                                // Enlarge text and give it more space
                                bottom: isSelected ? 8 : -24,
                                left: 0,
                                right: 0,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 200),
                                  opacity: isSelected ? 1.0 : 0.0,
                                  child: Text(
                                    item.label,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: widget.activeColor,
                                      fontSize: 10, // Smaller font size for better fit
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class NotchClipper extends CustomClipper<Path> {
  final double notchX;
  NotchClipper({required this.notchX});

  @override
  Path getClip(Size size) {
    // The base rounded rectangle
    Path hostPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
          Offset.zero & size, const Radius.circular(20)));

    // The mathematically perfect smooth notch path (on a sharp rectangle)
    Path notchPath = const CircularNotchedRectangle().getOuterPath(
      Offset.zero & size,
      // Guest rect: center is at (notchX, 0) because the circle is perfectly half-in, half-out!
      // Radius is 25, meaning the gap is 25 - 22 = 3px (very close to the circle)
      Rect.fromCircle(center: Offset(notchX, 0), radius: 25),
    );

    // Intersect them to get a rounded rectangle with the perfect notch
    return Path.combine(PathOperation.intersect, hostPath, notchPath);
  }

  @override
  bool shouldReclip(NotchClipper oldClipper) => oldClipper.notchX != notchX;
}
