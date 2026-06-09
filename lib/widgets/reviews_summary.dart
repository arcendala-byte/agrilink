import 'package:flutter/material.dart';
import 'rating_stars.dart';
import '../models/review/review_models.dart';

class ReviewsSummary extends StatelessWidget {
  final List<ProductReview> reviews;
  final RatingDistribution distribution;

  const ReviewsSummary({
    super.key,
    required this.reviews,
    required this.distribution,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Average Rating
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        distribution.averageRating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      RatingStars(rating: distribution.averageRating, size: 20),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${distribution.total} reviews',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                
                // Rating Distribution
                Expanded(
                  child: Column(
                    children: [
                      _buildDistributionBar('5', distribution.fiveStar, distribution.total),
                      _buildDistributionBar('4', distribution.fourStar, distribution.total),
                      _buildDistributionBar('3', distribution.threeStar, distribution.total),
                      _buildDistributionBar('2', distribution.twoStar, distribution.total),
                      _buildDistributionBar('1', distribution.oneStar, distribution.total),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionBar(String stars, int count, int total) {
    final percentage = total > 0 ? (count / total) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$stars ★', style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              color: Colors.amber,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              ' $count',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }
}
