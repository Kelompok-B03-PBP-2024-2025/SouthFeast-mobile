import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/qna_page.dart';
import 'qna_form.dart';

String fixUtf8(String text) {
  try {
    return utf8.decode(text.runes.toList());
  } catch (e) {
    return text;
  }
}

class QuestionDetailPage extends StatefulWidget {
  final Result question;
  final Function? onUpdate; 

  const QuestionDetailPage({
    super.key,
    required this.question,
    this.onUpdate,
  });

  @override
  State<QuestionDetailPage> createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {
  late Result currentQuestion; 
  final _formKey = GlobalKey<FormState>();
  final _answerController = TextEditingController();
  bool isUpdated = false;

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }
  
  @override
  void initState() {
    super.initState();
    currentQuestion = widget.question;  // Inisialisasi current question
  }

  Future<void> _deleteQuestion(CookieRequest request) async {
    final bool? confirm = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Question'),
          content: const Text('Are you sure you want to delete this question?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.black),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        final response = await request.get(
          'https://southfeast-production.up.railway.app/forum/api/question/delete-flutter/${widget.question.pk}/',
        );

        if (!mounted) return;

        if (response != null && response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Question deleted successfully')),
          );
          // Pass back deletion status AND the question ID
          Navigator.pop(context, {
            'deleted': true,
            'questionId': widget.question.pk
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? 'Failed to delete question'),
              backgroundColor: Colors.black,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.black,
          ),
        );
      }
    }
  }

  Future<void> _deleteAnswer(CookieRequest request, Answer answer) async {
  final bool? confirm = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Delete Answer'),
        content: const Text('Are you sure you want to delete this answer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  if (confirm == true) {
    try {
      // Gunakan parameter `action: delete` sesuai backend
      final response = await request.post(
        'https://southfeast-production.up.railway.app/forum/api/answer/delete/${answer.pk}/',
        {'action': 'delete'},
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          widget.question.fields.answers.removeWhere((a) => a.pk == answer.pk);
          widget.question.fields.answerCount--;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Answer deleted successfully'),
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Failed to delete answer'),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.black,
        ),
      );
    }
  }
}

  Future<void> _postAnswer(CookieRequest request) async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    if (!request.loggedIn) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final requestData = {
        'question_id': widget.question.pk.toString(),
        'content': _answerController.text,
      };

      final response = await request.postJson(
        'https://southfeast-production.up.railway.app/forum/api/answer/create/',
        jsonEncode(requestData),
      );

      if (!mounted) return;

      if (response != null && response['success'] == true && response['answer'] != null) {
        final answerData = response['answer'];
        final newAnswer = Answer(
          pk: answerData['id'].toString(),
          model: 'answer',
          fields: AnswerFields(
            content: answerData['content'],
            author: answerData['author'],
            createdAt: answerData['created_at'],
            canEdit: true,
            isStaff: answerData['is_staff'] ?? false,
          ),
        );

        setState(() {
          widget.question.fields.answers.add(newAnswer);
          widget.question.fields.answerCount++;
          _answerController.clear();
        });

        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Answer posted successfully'),
            backgroundColor: Color.fromARGB(255, 0, 0, 0),
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to post answer'),
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        ),
      );
    }
  }

    @override
    Widget build(BuildContext context) {
      final request = context.watch<CookieRequest>();

      return Scaffold(
        appBar: AppBar(
          title: const Text('Question Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, {
                'updated': isUpdated,
                'deleted': false,
                'question': currentQuestion,
              });
            },
          ),
          actions: [
          if (currentQuestion.fields.canEdit || currentQuestion.fields.isStaff) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                // Perbaiki pemanggilan Navigator
                final result = await Navigator.of(context).push(  // Tambahkan of(context)
                  MaterialPageRoute(
                    builder: (context) => QuestionFormPage(question: currentQuestion),
                  ),
                );

                if (!mounted) return;

                if (result != null && result is Map<String, dynamic>) {
                  setState(() {
                    currentQuestion.fields.title = result['title'] ?? currentQuestion.fields.title;
                    currentQuestion.fields.question = result['question'] ?? currentQuestion.fields.question;
                    isUpdated = true;
                  });

                  // Panggil callback onUpdate jika ada
                  if (widget.onUpdate != null) {
                    widget.onUpdate!();
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Question updated successfully')),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteQuestion(request),
            ),
          ],
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fixUtf8(currentQuestion.fields.title),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          fixUtf8(currentQuestion.fields.author),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.question.fields.createdAt,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        fixUtf8(currentQuestion.fields.question),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        const Text(
                          'Answers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${currentQuestion.fields.answerCount})',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    if (widget.question.fields.answers.isEmpty)
                      const Text('No answers yet')
                    else
                      ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentQuestion.fields.answers.length,
                      itemBuilder: (context, index) {
                        final answer = currentQuestion.fields.answers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Colors.blue[100],
                                      child: Text(
                                        fixUtf8(answer.fields.author)[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.blue[900],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            fixUtf8(answer.fields.author),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            answer.fields.createdAt,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (answer.fields.canEdit || answer.fields.isStaff)
                                      IconButton(
                                        icon: const Icon(Icons.delete, size: 20),
                                        color: const Color.fromARGB(255, 0, 0, 0),
                                        onPressed: () => _deleteAnswer(
                                          request,
                                          answer,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  fixUtf8(answer.fields.content),
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: 'Write an answer...',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your answer';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: const Color.fromARGB(255, 0, 0, 0),
                    onPressed: () {
                      if (!request.loggedIn) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login first')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                        return;
                      }
                      _postAnswer(request);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
