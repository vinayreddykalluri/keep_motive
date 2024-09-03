import 'package:flutter/material.dart';

class CategoriesScreen extends StatelessWidget {
  final List<String> categories = [
    'Motivation',
    'Life',
    'Success'
  ]; // Example categories

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              // Navigate to Quote Screen with selected category
            },
          );
        },
      ),
    );
  }
}
