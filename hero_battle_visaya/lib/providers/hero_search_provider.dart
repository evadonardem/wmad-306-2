import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/prefs_service.dart';

class HeroSearchProvider extends ChangeNotifier {
	final PrefsService _prefs = PrefsService();

	String _query = '';
	List<HeroModel> _results = [];
	bool _isLoading = false;
	String? _errorMessage;

	String get query => _query;
	List<HeroModel> get results => List.unmodifiable(_results);
	bool get isLoading => _isLoading;
	bool get hasResults => _results.isNotEmpty;
	String? get errorMessage => _errorMessage;

	Future<void> loadLastSearch() async {
		_query = await _prefs.loadLastSearch() ?? '';
		notifyListeners();
	}

	Future<void> updateQuery(String value, {bool persist = true}) async {
		_query = value;
		if (persist) {
			await _prefs.saveLastSearch(value);
		}
		notifyListeners();
	}

	void setLoading(bool value) {
		_isLoading = value;
		notifyListeners();
	}

	void setResults(List<HeroModel> heroes) {
		_results = List.unmodifiable(heroes);
		_errorMessage = null;
		_isLoading = false;
		notifyListeners();
	}

	void setError(String? message) {
		_errorMessage = message;
		_isLoading = false;
		notifyListeners();
	}

	void clearResults() {
		_results = [];
		_errorMessage = null;
		notifyListeners();
	}
}
