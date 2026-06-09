import 'package:flutter/material.dart';

class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final bool interactive;
  final Function(double)? onRatingChanged;
  final Color activeColor;
  final Color inactiveColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 20,
    this.interactive = false,
    this.onRatingChanged,
    this.activeColor = Colors.amber,
    this.inactiveColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1.0;
        final isFullStar = rating >= starValue;
        final isHalfStar = !isFullStar && rating > index;
        
        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Icon(
            isFullStar ? Icons.star : (isHalfStar ? Icons.star_half : Icons.star_border),
            color: isFullStar || isHalfStar ? activeColor : inactiveColor,
            size: size,
          ),
        );
      }),
    );
  }
}
