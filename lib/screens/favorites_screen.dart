import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart'; // Import for sharing functionality
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'quote_detail_screen.dart'; // Import to navigate to quote detail screen
import 'home_screen.dart'; // Import HomeScreen for navigation
import 'authors_screen.dart'; // Import AuthorsScreen for navigation
import 'quote_screen.dart'; // Import QuoteScreen for navigation

class FavoritesScreen extends StatefulWidget {
  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 2; // Set default index to Favorites tab
  List<Quote> favoriteQuotes = [];
  List<Quote> filteredQuotes = []; // List for filtered quotes
  Set<String> favoriteQuotesSet =
      {}; // To track favorite quotes in the current session
  TextEditingController searchController =
      TextEditingController(); // Controller for search input

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedFavorites = prefs.getStringList('favorites') ?? [];
    List<Quote> quotes = await QuoteService().loadQuotes();
    setState(() {
      favoriteQuotesSet = savedFavorites.toSet();
      favoriteQuotes = quotes
          .where((quote) => favoriteQuotesSet.contains(quote.quote))
          .toList();
      filteredQuotes = List.from(
          favoriteQuotes); // Initialize filtered quotes with all favorites
    });
  }

  Future<void> _removeFavorite(Quote quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    favoriteQuotesSet.remove(quote.quote);
    await prefs.setStringList('favorites', favoriteQuotesSet.toList());
    setState(() {
      favoriteQuotes = favoriteQuotes
          .where((q) => favoriteQuotesSet.contains(q.quote))
          .toList();
      filteredQuotes =
          List.from(favoriteQuotes); // Update filtered quotes when removing
    });
  }

  void _filterQuotes(String query) {
    setState(() {
      filteredQuotes = favoriteQuotes
          .where((quote) =>
              quote.quote.toLowerCase().contains(query.toLowerCase()) ||
              quote.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _toggleFavorite(Quote quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (favoriteQuotesSet.contains(quote.quote)) {
      favoriteQuotesSet.remove(quote.quote);
    } else {
      favoriteQuotesSet.add(quote.quote);
    }
    await prefs.setStringList('favorites', favoriteQuotesSet.toList());
    setState(() {
      favoriteQuotes = favoriteQuotes
          .where((q) => favoriteQuotesSet.contains(q.quote))
          .toList();
      filteredQuotes = List.from(
          favoriteQuotes); // Update filtered quotes when toggling favorite
    });
  }

  void _copyQuote(String quote) {
    Clipboard.setData(ClipboardData(text: quote));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quote copied to clipboard!')),
    );
  }

  void _shareQuote(String quote) {
    Share.share(quote); // Using the share method from share_plus
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorsScreen()),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Quotes'),
        backgroundColor: Colors.blue, // Use consistent color theme for AppBar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Favorites',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterQuotes, // Update list as user types
            ),
          ),
          Expanded(
            child: filteredQuotes.isEmpty
                ? Center(child: Text('No favorite quotes added.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: filteredQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = filteredQuotes[index];
                      bool isFavorite = favoriteQuotesSet.contains(quote.quote);
                      return Dismissible(
                        key:
                            Key(quote.quote), // Unique key for each Dismissible
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Colors.red, // Background color when dismissing
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _removeFavorite(quote); // Remove quote from favorites
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Removed from favorites')),
                          );
                        },
                        child: Card(
                          color: Colors.white, // Consistent card color
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            QuoteDetailScreen(quote: quote),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    quote.quote,
                                    style: TextStyle(
                                      fontSize:
                                          18, // Adjusted font size for better readability
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Center(
                                  child: Text(
                                    '- ${quote.author}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorite
                                            ? Colors.red
                                            : Colors.black,
                                      ),
                                      iconSize: 20, // Reduced icon size
                                      onPressed: () => _toggleFavorite(quote),
                                    ),
                                    SizedBox(
                                        width:
                                            15), // Adjust spacing between icons
                                    IconButton(
                                      icon: Icon(Icons.copy),
                                      color: Colors.black,
                                      iconSize: 20, // Reduced icon size
                                      onPressed: () => _copyQuote(quote.quote),
                                    ),
                                    SizedBox(
                                        width:
                                            15), // Adjust spacing between icons
                                    IconButton(
                                      icon: Icon(Icons.share),
                                      color: Colors.black,
                                      iconSize: 20, // Reduced icon size
                                      onPressed: () => _shareQuote(quote.quote),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Authors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
