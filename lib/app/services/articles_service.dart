import 'dart:convert';
import 'dart:math';

import 'package:meta/meta.dart';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import 'package:getx_hacker_news_api/app/core/models/article.dart';
import 'package:getx_hacker_news_api/app/core/models/failure.dart';
import 'package:getx_hacker_news_api/app/data/local_database.dart';
import 'package:getx_hacker_news_api/private/keys.dart';

class ArticlesService {
  ArticlesService({@required this.localDatabase});
  // local database
  final LocalDatabase localDatabase;

  /// return either failure or list of articles
  Future<Either<Failure, List<Article>>> fetchArticles() async {
    try {
      var response = await http.get(endpoint);
      if (response.statusCode != 200) {
        var error =
            json.decode(response.body)['message'] as String ?? 'API error';
        return Left(Failure(error));
      }
      var data = extractData(response);
      if (data == null) return Left(Failure('Something went wrong'));
      return Right(data);
    } catch (e) {
      print(e);
      return Left(Failure('Something went wrong'));
    }
  }

  /// return either failure or list of articles from saved local database
  Future<Either<Failure, List<Article>>> fetchLocalSavedArticles() async {
    await Future.delayed(Duration(seconds: 1));
    var random = Random();
    var generatedData = List<Article>.generate(
        random.nextInt(10), (index) => Article(title: index.toString()));
    if (generatedData.length < 1) {
      return Left(Failure('some database error error'));
    }
    return Right(generatedData);
  }

  /// extract data from http api response
  List<Article> extractData(http.Response response) {
    try {
      var rawData = json.decode(response.body) as Map<String, dynamic>;
      var articlesLength = rawData['articles'].length;
      if (articlesLength == 0) {
        return null;
      }
      List<Article> articles = [];
      for (int i = 0; i < articlesLength; i++) {
        var article = Article.fromJsonMap(rawData['articles'][i]);
        articles.add(article);
      }
      return articles;
    } catch (e) {
      print(e);
      return null;
    }
  }
}