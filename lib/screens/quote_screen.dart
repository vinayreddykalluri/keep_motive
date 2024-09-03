import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'quote_detail_screen.dart'; // Import the screen to display individual quotes
import 'package:shared_preferences/shared_preferences.dart'; // For adding quotes to favorites
import 'dart:math';
import 'home_screen.dart'; // Import HomeScreen for navigation
import 'authors_screen.dart'; // Import AuthorsScreen for navigation
import 'favorites_screen.dart'; // Import FavoritesScreen for navigation

class QuoteScreen extends StatefulWidget {
  final String? category;
  final String? author;

  const QuoteScreen({Key? key, this.category, this.author}) : super(key: key);

  @override
  _QuoteScreenState createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  late Future<List<Quote>> futureQuotes;
  List<Quote> displayedQuotes = [];
  List<Quote> allQuotes = [];
  TextEditingController searchController = TextEditingController();
  Set<String> favoriteQuotesSet =
      {}; // To track favorite quotes in the current session

  @override
  void initState() {
    super.initState();
    futureQuotes = QuoteService().loadQuotes();
    _loadFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshQuotes(); // Shuffle quotes whenever dependencies change
  }

  Future<void> _loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteQuotesSet = prefs.getStringList('favorites')?.toSet() ??
          {}; // Load favorites from SharedPreferences
    });
  }

  void _refreshQuotes() async {
    final quotes = await futureQuotes;
    setState(() {
      allQuotes = quotes.where((quote) {
        if (widget.category != null) {
          return quote.category.toLowerCase() == widget.category!.toLowerCase();
        } else if (widget.author != null) {
          return quote.author
              .toLowerCase()
              .contains(widget.author!.toLowerCase().trim());
        }
        return false;
      }).toList();
      allQuotes.shuffle(Random()); // Shuffle quotes randomly
      displayedQuotes = List.from(allQuotes);
    });
  }

  void _searchQuotes(String query) {
    setState(() {
      displayedQuotes = allQuotes
          .where((quote) =>
              quote.quote.toLowerCase().contains(query.toLowerCase()) ||
              quote.author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _toggleFavorite(Quote quote) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (favoriteQuotesSet.contains(quote.quote)) {
      favoriteQuotesSet.remove(quote.quote);
    } else {
      favoriteQuotesSet.add(quote.quote);
    }
    await prefs.setStringList('favorites', favoriteQuotesSet.toList());
    setState(() {}); // Trigger a rebuild to update the UI
  }

  void _copyQuote(String quote) {
    Clipboard.setData(ClipboardData(text: quote));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Quote copied to clipboard!')),
    );
  }

  void _shareQuote(String quote) {
    Share.share(quote); // Using the updated share method
  }

  void _onItemTapped(int index) {
    setState(() {
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
      } else if (index == 2) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category != null
            ? widget.category![0].toUpperCase() + widget.category!.substring(1)
            : widget.author != null
                ? widget.author![0].toUpperCase() + widget.author!.substring(1)
                : ''),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Quotes',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _searchQuotes,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Quote>>(
              future: futureQuotes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading quotes'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                      child: Text('No quotes available for this filter'));
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1, // Single column for full-width quotes
                      childAspectRatio:
                          4 / 2, // Adjusted ratio for better height
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: displayedQuotes.length,
                    itemBuilder: (context, index) {
                      final quote = displayedQuotes[index];
                      bool isFavorite = favoriteQuotesSet.contains(quote.quote);

                      return Card(
                        color: Colors.white, // Consistent card color
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            QuoteDetailScreen(quote: quote),
                                      ),
                                    );
                                  },
                                  child: SingleChildScrollView(
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
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: widget.category != null
            ? 0
            : 1, // Set default index based on category or author
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
