import 'package:flutter/foundation.dart';

import '../models/hero_model.dart';
import '../services/prefs_service.dart';
import '../services/superhero_api_service.dart';

class HeroSearchProvider extends ChangeNotifier {
	final PrefsService _prefs = PrefsService();

	String _query = '';
	bool _isLoading = false;
	String? _error;
	List<HeroModel> _results = <HeroModel>[];
	int _searchToken = 0;

	String get query => _query;
	bool get isLoading => _isLoading;
	String? get error => _error;
	List<HeroModel> get results => List.unmodifiable(_results);

	Future<void> hydrateLastSearch() async {
		_query = await _prefs.loadLastSearch() ?? '';
		notifyListeners();
	}

	Future<void> setQuery(String value, SuperheroApiService api) async {
		final token = ++_searchToken;
		_query = value.trim();
		await _prefs.saveLastSearch(_query);

		if (_query.isEmpty) {
			_isLoading = false;
			_error = null;
			_results = <HeroModel>[];
			notifyListeners();
			return;
		}

		_isLoading = true;
		_error = null;
		notifyListeners();

		try {
			final result = await api.searchHeroes(_query);
			if (token != _searchToken) {
				return;
			}
			_results = result;
			_error = null;
		} catch (e) {
			if (token != _searchToken) {
				return;
			}
			_error = 'Failed to search heroes';
			_results = <HeroModel>[];
		} finally {
			if (token == _searchToken) {
				_isLoading = false;
				notifyListeners();
			}
		}
	}

	void clear() {
		_query = '';
		_results = <HeroModel>[];
		_error = null;
		_isLoading = false;
		notifyListeners();
	}
}

