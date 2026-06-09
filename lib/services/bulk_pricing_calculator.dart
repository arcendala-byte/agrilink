class BulkPricingCalculator {
  static const Map<int, double> bulkDiscounts = {
    10: 0.05,   // 5% off for 10+ units
    25: 0.10,   // 10% off for 25+ units
    50: 0.15,   // 15% off for 50+ units
    100: 0.20,  // 20% off for 100+ units
    250: 0.25,  // 25% off for 250+ units
    500: 0.30,  // 30% off for 500+ units
  };
  
  static double getBulkPrice(double unitPrice, int quantity) {
    double discount = 0;
    
    for (var entry in bulkDiscounts.entries) {
      if (quantity >= entry.key) {
        discount = entry.value;
      }
    }
    
    return unitPrice * (1 - discount);
  }
  
  static double getDiscountPercentage(int quantity) {
    double discount = 0;
    
    for (var entry in bulkDiscounts.entries) {
      if (quantity >= entry.key) {
        discount = entry.value;
      }
    }
    
    return discount * 100;
  }
  
  static String getDiscountText(int quantity) {
    final percentage = getDiscountPercentage(quantity);
    if (percentage > 0) {
      return '${percentage.toInt()}% off';
    }
    return 'No discount';
  }
  
  static int getNextBulkTier(int quantity) {
    int nextTier = 0;
    for (var entry in bulkDiscounts.entries) {
      if (entry.key > quantity) {
        if (nextTier == 0 || entry.key < nextTier) {
          nextTier = entry.key;
        }
      }
    }
    return nextTier;
  }
}
