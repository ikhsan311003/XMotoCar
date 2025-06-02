import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/rental_service.dart';

class ReviewProvider with ChangeNotifier {
  int _pendingReviewCount = 0;

  int get pendingReviewCount => _pendingReviewCount;

  Future<void> fetchPendingReviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final reviewedIds = prefs.getStringList('reviewed_vehicle_ids') ?? [];

      final rentals = await RentalService.fetchRentalHistory();
      _pendingReviewCount = rentals.where((r) {
        return r['status'] == 'completed' &&
            !reviewedIds.contains(r['vehicle']['id'].toString());
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
