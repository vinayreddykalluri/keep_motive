import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quote.dart';
import '../services/quote_service.dart';
import 'favorites_screen.dart';
import 'quote_screen.dart'
    as quote_screen; // Import with prefix for quote screen
import 'authors_screen.dart'; // Direct import for AuthorsScreen
import '../main.dart'; // Import ThemeProvider to access theme functionality

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late Future<List<Quote>> futureQuotes;
  List<String> categories = [];
  List<String> filteredCategories = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureQuotes = QuoteService().loadQuotes();
    loadCategories();
  }

  void loadCategories() async {
    final quotes = await futureQuotes;
    categories = quotes
        .map((quote) => quote.category)
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
    categories.sort(); // Sort categories alphabetically
    setState(() {
      filteredCategories = categories;
    });
  }

  void _filterCategories(String query) {
    setState(() {
      filteredCategories = categories
          .where((category) =>
              category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      // Navigate to AuthorsScreen when the authors tab is clicked
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AuthorsScreen()), // Direct reference
      );
    } else if (index == 2) {
      // Navigate to FavoritesScreen when the favorites tab is clicked
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => FavoritesScreen()),
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: [
          Switch(
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (value) {
              themeProvider.toggleTheme(value);
            },
          ),
        ],
        backgroundColor: themeProvider.themeMode == ThemeMode.dark
            ? Colors.black
            : Colors.blue, // Adjust background color based on theme
      ),
      body: _buildCategoriesView(),
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

  Widget _buildCategoriesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Search Categories',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            onChanged: _filterCategories,
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Quote>>(
            future: futureQuotes,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading categories'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No categories available'));
              } else {
                return GridView.builder(
                  padding: const EdgeInsets.all(8.0),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: filteredCategories.length,
                  itemBuilder: (context, index) {
                    final category = filteredCategories[index];
                    if (category.isEmpty) {
                      return SizedBox
                          .shrink(); // Return an empty widget if the category is empty
                    }
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => quote_screen.QuoteScreen(
                                category:
                                    category), // Use the prefix 'quote_screen'
                          ),
                        );
                      },
                      child: Card(
                        color: Colors.blueAccent,
                        child: Center(
                          child: Text(
                            category[0].toUpperCase() +
                                category
                                    .substring(1), // Capitalize first letter
                            style: TextStyle(
                              fontSize: 20, // Increased font size
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
    );
  }
}
