import 'package:flutter/material.dart';
import '../data/articles.dart';
import 'article_view_screen.dart';

class ArticleListScreen extends StatelessWidget {
  const ArticleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài viết')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: sampleArticles.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, i) {
          final a = sampleArticles[i];
          return Card(
            child: ListTile(
              title: Text(a.title),
              subtitle: Text(a.summary),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ArticleViewScreen(article: a)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
