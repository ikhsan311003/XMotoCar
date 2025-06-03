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

      _pendingReviewCount = rentals.where((r) {
        return r['status'] == 'completed' &&
            !reviewedRentalIds.contains(r['id']);
      }).length;

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
