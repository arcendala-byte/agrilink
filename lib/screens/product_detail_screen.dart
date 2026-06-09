import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/rating_stars.dart';
import '../widgets/review_dialog.dart';
import '../services/review_service.dart';
import '../models/review/review_models.dart';
import '../screens/bulk_order/bulk_order_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productName;
  final String productPrice;
  final String productUnit;
  final String productRating;
  final String farmerName;
  final String? productId;
  final String? farmerId;
  final String? productImage;
  final String? description;

  const ProductDetailScreen({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productUnit,
    required this.productRating,
    required this.farmerName,
    this.productId,
    this.farmerId,
    this.productImage,
    this.description,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  bool _hasReviewed = false;
  int _quantity = 1;
  List<ProductReview> _reviews = [];
  bool _isLoadingReviews = true;
  bool _isWishlisted = false;
  int _selectedImageIndex = 0;

  // Sample product images (replace with actual images from Firestore)
  final List<String> _productImages = [
    'assets/images/product_placeholder.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _checkIfReviewed();
    _loadReviews();
    _checkWishlistStatus();
  }

  Future<void> _checkIfReviewed() async {
    final hasReviewed = await _reviewService.hasUserReviewed(widget.productId ?? 'product_1');
    setState(() => _hasReviewed = hasReviewed);
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    final reviews = await _reviewService.getProductReviews(widget.productId ?? 'product_1').first;
    setState(() {
      _reviews = reviews;
      _isLoadingReviews = false;
    });
  }

  Future<void> _checkWishlistStatus() async {
    // Check if product is in user's wishlist
    // This would query Firestore
    setState(() => _isWishlisted = false);
  }

  Future<void> _toggleWishlist() async {
    setState(() => _isWishlisted = !_isWishlisted);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isWishlisted ? 'Added to wishlist!' : 'Removed from wishlist'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _onReviewSubmitted() async {
    await _checkIfReviewed();
    await _loadReviews();
    setState(() {});
  }

  void _addToCart() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity ${widget.productName} to cart!'),
        backgroundColor: const Color(0xFF2E7D32),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _shareProduct() {
    // Share product details
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final regularPrice = double.parse(widget.productPrice);
    final bulkPrice = regularPrice * 0.85; // 15% bulk discount
    final savings = regularPrice * _quantity - bulkPrice * _quantity;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productName),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Share Button
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareProduct,
          ),
          // Wishlist Button
          IconButton(
            icon: Icon(
              _isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: _isWishlisted ? Colors.red : Colors.white,
            ),
            onPressed: _toggleWishlist,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Gallery
            Container(
              height: 350,
              color: Colors.green.shade50,
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 120,
                      color: Colors.green.shade200,
                    ),
                  ),
                  // Organic Badge
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.eco, size: 16, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Organic', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  // Image Gallery Indicators
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _productImages.length,
                        (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _selectedImageIndex == index
                                ? const Color(0xFF2E7D32)
                                : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                RatingStars(rating: double.parse(widget.productRating), size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  '(${widget.productRating}) • ${_reviews.length} reviews',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Stock Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'In Stock',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Pricing Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Regular Price:',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              'KSh ${widget.productPrice}/${widget.productUnit}',
                              style: const TextStyle(
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Bulk Price:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'KSh ${(regularPrice * 0.85).toStringAsFixed(0)}/${widget.productUnit}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Save 15% on bulk orders (10+ units)',
                            style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Quantity Selector
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.light
                          ? Colors.grey.shade50
                          : Colors.grey.shade800,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'Quantity:',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                onPressed: () {
                                  if (_quantity > 1) {
                                    setState(() => _quantity--);
                                  }
                                },
                              ),
                              Container(
                                width: 40,
                                child: Text(
                                  '$_quantity',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                onPressed: () {
                                  setState(() => _quantity++);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_quantity >= 10) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.savings, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You save KSh ${savings.toStringAsFixed(0)} on this order!',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                Text(
                                  'Bulk discount applied (15% off)',
                                  style: TextStyle(fontSize: 12, color: Colors.green.shade700),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  
                  // Action Buttons
                  Row(
                    children: [
                      // Add to Cart Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Add to Cart'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA726),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Bulk Order Button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BulkOrderScreen(
                                  productId: widget.productId ?? '1',
                                  productName: widget.productName,
                                  unitPrice: double.parse(widget.productPrice),
                                  unit: widget.productUnit,
                                  farmerId: widget.farmerId ?? 'farmer1',
                                  farmerName: widget.farmerName,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.inventory, size: 18),
                          label: const Text('Bulk Order'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Farmer Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF2E7D32),
                            child: Icon(Icons.person, size: 28, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.farmerName,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const Text('Verified Farmer', style: TextStyle(fontSize: 12)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star, size: 12, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    const Text('4.9'),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.verified, size: 12, color: Colors.blue),
                                    const SizedBox(width: 2),
                                    const Text('Verified'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.chat, size: 18),
                            label: const Text('Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Description Section
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description ??
                    'Fresh ${widget.productName} sourced directly from local farms. '
                    'These premium quality products are grown without harmful pesticides. '
                    'Perfect for your family\'s daily meals. Harvested at peak ripeness and delivered fresh to your doorstep.',
                    style: TextStyle(color: Colors.grey.shade600, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  
                  // Delivery Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.local_shipping, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Free Delivery',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'On orders above KSh 1000',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Reviews Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Customer Reviews',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (user != null && !_hasReviewed)
                        TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => ReviewDialog(
                                productId: widget.productId ?? 'product_1',
                                productName: widget.productName,
                                onReviewSubmitted: _onReviewSubmitted,
                              ),
                            );
                          },
                          icon: const Icon(Icons.rate_review),
                          label: const Text('Write a Review'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Reviews Summary
                  if (_reviews.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                _reviews.isEmpty ? '0.0' : 
                                (_reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length)
                                    .toStringAsFixed(1),
                                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                              ),
                              RatingStars(
                                rating: _reviews.isEmpty ? 0 : 
                                (_reviews.map((r) => r.rating).reduce((a, b) => a + b) / _reviews.length),
                                size: 16,
                              ),
                              Text(
                                '${_reviews.length} reviews',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingBar(5, _reviews.where((r) => r.rating.toInt() == 5).length, _reviews.length),
                                _buildRatingBar(4, _reviews.where((r) => r.rating.toInt() == 4).length, _reviews.length),
                                _buildRatingBar(3, _reviews.where((r) => r.rating.toInt() == 3).length, _reviews.length),
                                _buildRatingBar(2, _reviews.where((r) => r.rating.toInt() == 2).length, _reviews.length),
                                _buildRatingBar(1, _reviews.where((r) => r.rating.toInt() == 1).length, _reviews.length),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // Reviews List
                  _isLoadingReviews
                      ? const Center(child: CircularProgressIndicator())
                      : _reviews.isEmpty
                          ? _buildEmptyReviews()
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              itemBuilder: (context, index) {
                                final review = _reviews[index];
                                return _buildReviewCard(review);
                              },
                            ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text('$stars ★', style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey.shade200,
              color: Colors.amber,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              ' $count',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.rate_review, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'No reviews yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to review this product',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(ProductReview review) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    review.userName[0].toUpperCase(),
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RatingStars(rating: review.rating, size: 14),
                    ],
                  ),
                ),
                Text(
                  _formatDate(review.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review.comment),
            if (review.images.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: review.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
