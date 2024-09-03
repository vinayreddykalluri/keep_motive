import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quote.dart';

class QuoteService {
  Future<List<Quote>> loadQuotes() async {
    final String response = await rootBundle.loadString('assets/quotes.json');
    final List<dynamic> data = jsonDecode(response);
    return data.map((quote) => Quote.fromJson(quote)).toList();
  }
}
