import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rental_service.dart';

class ReviewProvider with ChangeNotifier {
  int _pendingReviewCount = 0;

  int get pendingReviewCount => _pendingReviewCount;

  Future<void> fetchPendingReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewedIds = prefs.getStringList('reviewed_rental_ids') ?? [];

      final rentals = await RentalService.fetchRentalHistory();
      final reviewedRentalIds = reviewedIds.map(int.parse).toList();

      int count = 0;

      for (var r in rentals) {
        final rentalId = r['id'];
        final isCompleted = r['status'] == 'completed';
        final isAlreadyReviewed = reviewedRentalIds.contains(rentalId);

        if (isCompleted && !isAlreadyReviewed) {
          count++;
        }
      }

      _pendingReviewCount = count;
      notifyListeners();
    } catch (e) {
      _pendingReviewCount = 0;
      notifyListeners();
    }
  }

  void clear() {
    _pendingReviewCount = 0;
    notifyListeners();
  }
}
