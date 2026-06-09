class FilterOptions {
  String? category;
  String? priceRange;
  bool? organicOnly;
  String? sortBy;
  double? minPrice;
  double? maxPrice;
  
  FilterOptions({
    this.category,
    this.priceRange,
    this.organicOnly,
    this.sortBy,
    this.minPrice,
    this.maxPrice,
  });
  
  void clear() {
    category = null;
    priceRange = null;
    organicOnly = null;
    sortBy = null;
    minPrice = null;
    maxPrice = null;
  }
  
  bool get isActive => category != null || 
                       priceRange != null || 
                       organicOnly == true || 
                       sortBy != null;
  
  Map<String, dynamic> toJson() => {
    'category': category,
    'priceRange': priceRange,
    'organicOnly': organicOnly,
    'sortBy': sortBy,
    'minPrice': minPrice,
    'maxPrice': maxPrice,
  };
  
  factory FilterOptions.fromJson(Map<String, dynamic> json) {
    return FilterOptions(
      category: json['category'],
      priceRange: json['priceRange'],
      organicOnly: json['organicOnly'],
      sortBy: json['sortBy'],
      minPrice: json['minPrice'],
      maxPrice: json['maxPrice'],
    );
  }
}
