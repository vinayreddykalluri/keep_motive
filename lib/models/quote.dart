import 'package:json_annotation/json_annotation.dart';

part 'quote.g.dart';

@JsonSerializable()
class Quote {
  @JsonKey(name: 'Quote')
  final String quote;

  @JsonKey(name: 'Author')
  final String author;

  @JsonKey(name: 'Tags')
  final List<String> tags;

  @JsonKey(name: 'Popularity')
  final double popularity;

  @JsonKey(name: 'Category')
  final String category;

  Quote({
    required this.quote,
    required this.author,
    required this.tags,
    required this.popularity,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) => _$QuoteFromJson(json);

  Map<String, dynamic> toJson() => _$QuoteToJson(this);
}
