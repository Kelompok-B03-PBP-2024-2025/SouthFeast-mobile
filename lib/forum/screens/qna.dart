import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/qna_page.dart';
import 'qna_detail.dart';
import 'qna_form.dart';


class QnaListPage extends StatefulWidget {
  const QnaListPage({super.key});

  @override
  State<QnaListPage> createState() => _QnaListPageState();
}

class _QnaListPageState extends State<QnaListPage> {
  List<Result> questions = [];
  bool isLoading = true;
  String? error;
  String selectedTab = 'Public QnA';

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
  
  if (!mounted) return;
  
  setState(() {
    isLoading = true;
    error = null;
  });

  final request = context.read<CookieRequest>();
  try {
    // Tambahkan timestamp untuk menghindari cache
    final response = await request.get(
      'https://southfeast-production.up.railway.app/forum/json/qna/?filter=${selectedTab == 'Public QnA' ? 'public_qna' : 'your_qna'}&t=${DateTime.now().millisecondsSinceEpoch}',
    );

    if (!mounted) return;

    final QnaPage qnaPage = QnaPage.fromJson(response);

    setState(() {
      questions = qnaPage.results;
      isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      error = e.toString();
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error fetching questions: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _handleTabChange(String title) {
    final request = context.read<CookieRequest>();
    if (title == 'Your QnA' && !request.loggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    setState(() {
      selectedTab = title;
      isLoading = true;
    });

    fetchQuestions();
  }

  Future<void> _handleAddQuestion() async {
    final request = context.read<CookieRequest>();
    if (!request.loggedIn) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const QuestionFormPage(),
      ),
    ).then((_) {
      // Refresh questions after returning from add question page
      if (!mounted) return;
      fetchQuestions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => _handleTabChange('Public QnA'),
                  child: Text(
                    'Public QnA',
                    style: TextStyle(
                      color: selectedTab == 'Public QnA'
                          ? const Color.fromARGB(255, 13, 72, 119)
                          : Colors.grey,
                      fontSize: 16,
                      fontWeight: selectedTab == 'Public QnA'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                TextButton(
                  onPressed: () => _handleTabChange('Your QnA'),
                  child: Text(
                    'Your QnA',
                    style: TextStyle(
                      color: selectedTab == 'Your QnA'
                          ? const Color.fromARGB(255, 13, 72, 119)
                          : Colors.grey,
                      fontSize: 16,
                      fontWeight: selectedTab == 'Your QnA'
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
      floatingActionButton: Padding(
      padding: const EdgeInsets.only(bottom: 80.0),
      child: FloatingActionButton(
        onPressed: _handleAddQuestion,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ),
    floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }

  Widget _buildMainContent() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  error = null;
                });
                fetchQuestions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return _buildQuestionList();
  }

  Widget _buildQuestionList() {
    if (questions.isEmpty) {
      return const Center(
        child: Text('No questions found'),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await fetchQuestions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return QuestionCard(
            title: utf8.decode(question.fields.title.runes.toList()),
            author: utf8.decode(question.fields.author.runes.toList()),
            createdAt: question.fields.createdAt,
            question: utf8.decode(question.fields.question.runes.toList()),
            answerCount: question.fields.answerCount,
            onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionDetailPage(question: question),
              ),
            );

            if (result != null) {
              if (result['deleted'] == true) {
                setState(() {
                  questions.removeWhere((q) => q.pk == result['questionId']);
                });
              } else if (result['updated'] == true) {
                setState(() {
                  final index = questions.indexWhere((q) => q.pk == question.pk);
                  if (index != -1) {
                    questions[index] = result['question'];
                  }
                });
              }
            }
          },
        );
        },
      ),
    );
  }
}

class QuestionCard extends StatelessWidget {
  final String title;
  final String author;
  final String createdAt;
  final String question;
  final int answerCount;
  final VoidCallback onTap;

  const QuestionCard({
    super.key,
    required this.title,
    required this.author,
    required this.createdAt,
    required this.question,
    required this.answerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'by $author',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    createdAt,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                question,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.question_answer, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '$answerCount Answers',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
