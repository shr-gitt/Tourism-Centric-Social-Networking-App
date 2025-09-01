import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/pages/detailpages.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<String> recentSearches = [];

  static const String searchHistoryKey = 'searchHistory';

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentSearches = prefs.getStringList(searchHistoryKey) ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(searchHistoryKey, recentSearches);
  }

  void _addSearchTerm(String term) {
    if (term.isEmpty) return;

    setState(() {
      recentSearches.remove(term); // Remove duplicates
      recentSearches.insert(0, term); // Insert at the front
      if (recentSearches.length > 10) {
        recentSearches = recentSearches.sublist(0, 10); // Limit to 10
      }
    });
    _saveSearchHistory();
  }

  void _deleteSearchTerm(String term) {
    setState(() {
      recentSearches.remove(term);
    });
    _saveSearchHistory();
  }

  void _clearSearchHistory() {
    setState(() {
      recentSearches.clear();
    });
    _saveSearchHistory();
  }

  void performSearch(String query) {
    if (query.trim().isEmpty) return;
    _addSearchTerm(query.trim());

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(searchQuery: query.trim())),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false, toolbarHeight: 15),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: performSearch,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => performSearch(_searchController.text),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (recentSearches.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextButton(
                    onPressed: _clearSearchHistory,
                    child: const Text('Clear All'),
                  ),
                ],
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: recentSearches.length,
                  itemBuilder: (context, index) {
                    final term = recentSearches[index];
                    return ListTile(
                      title: Text(term),
                      leading: const Icon(Icons.history),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _deleteSearchTerm(term),
                      ),
                      onTap: () {
                        _searchController.text = term;
                        performSearch(term);
                      },
                    );
                  },
                ),
              ),
            ] else
              const Text('No recent searches'),
          ],
        ),
      ),
    );
  }
}
