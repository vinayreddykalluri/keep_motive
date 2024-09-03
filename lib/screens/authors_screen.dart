import 'dart:math'; // Import for shuffling
import 'package:flutter/material.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'quote_screen.dart'
    as quote_screen; // Import with prefix for quote screen
import 'favorites_screen.dart';
import 'home_screen.dart';

class AuthorsScreen extends StatefulWidget {
  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  int _selectedIndex = 1; // Set default index to Authors tab
  late Future<List<Quote>> futureQuotes;
  List<String> authors = [];
  List<String> filteredAuthors = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureQuotes = QuoteService().loadQuotes();
    loadAuthors();
  }

  void loadAuthors() async {
    final quotes = await futureQuotes;
    authors = quotes
        .map((quote) => quote.author.split(
            ',')[0]) // Split author names by comma and take the first part
        .where((author) => author.isNotEmpty)
        .toSet()
        .toList();
    authors.shuffle(Random()); // Shuffle authors
    setState(() {
      filteredAuthors = authors;
    });
  }

  void _filterAuthors(String query) {
    setState(() {
      filteredAuthors = authors
          .where((author) => author.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authors'),
        backgroundColor: Colors.blue, // Use consistent color theme for AppBar
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search Authors',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onChanged: _filterAuthors,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Quote>>(
              future: futureQuotes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading authors'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No authors available'));
                } else {
                  return GridView.builder(
                    padding: const EdgeInsets.all(8.0),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: filteredAuthors.length,
                    itemBuilder: (context, index) {
                      final author = filteredAuthors[index];
                      if (author.isEmpty) {
                        return SizedBox
                            .shrink(); // Return an empty widget if the author is empty
                      }
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => quote_screen.QuoteScreen(
                                  author: author), // Use prefix 'quote_screen'
                            ),
                          ).then((_) {
                            setState(() {
                              authors.shuffle(
                                  Random()); // Shuffle authors when returning to the screen
                              filteredAuthors = authors;
                            });
                          });
                        },
                        child: Card(
                          color: Colors.blueAccent, // Use consistent card color
                          child: Center(
                            child: Text(
                              author,
                              style: TextStyle(
                                fontSize: 18, // Set font size for authors
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
