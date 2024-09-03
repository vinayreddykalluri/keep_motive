// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Quote _$QuoteFromJson(Map<String, dynamic> json) => Quote(
      quote: json['Quote'] as String,
      author: json['Author'] as String,
      tags: (json['Tags'] as List<dynamic>).map((e) => e as String).toList(),
      popularity: (json['Popularity'] as num).toDouble(),
      category: json['Category'] as String,
    );

Map<String, dynamic> _$QuoteToJson(Quote instance) => <String, dynamic>{
      'Quote': instance.quote,
      'Author': instance.author,
      'Tags': instance.tags,
      'Popularity': instance.popularity,
      'Category': instance.category,
    };
