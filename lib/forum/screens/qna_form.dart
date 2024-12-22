import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'dart:convert';
import '../models/qna_page.dart'; // Mengimpor model QnA Page

class QuestionFormPage extends StatefulWidget {
  final Result? question; // Data pertanyaan jika dalam mode edit

  const QuestionFormPage({super.key, this.question});

  @override
  State<QuestionFormPage> createState() => _QuestionFormPageState();
}

class _QuestionFormPageState extends State<QuestionFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _questionController;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data (jika mode edit)
    _titleController = TextEditingController(
      text: widget.question?.fields.title ?? '',
    );
    _questionController = TextEditingController(
      text: widget.question?.fields.question ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Create New Question' : 'Edit Question'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Question Field
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: 'Question Content',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    if (!request.loggedIn) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login first')),
                        );
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                      return;
                    }

                    try {
                      // Data yang akan dikirim ke API
                      final requestData = {
                        'title': _titleController.text,
                        'question': _questionController.text,
                      };

                      // URL untuk API Create atau Edit
                      final String url = widget.question == null
                          ? 'https://southfeast-production.up.railway.app/forum/api/question/create/'
                          : 'https://southfeast-production.up.railway.app/forum/api/question/edit/${widget.question!.pk}/';

                      // Kirim POST request
                      final response = await request.postJson(
                        url,
                        jsonEncode(requestData),
                      );

                      if (context.mounted) {
                        if (response['success'] == true) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response['message']),
                              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          );
                            Navigator.pop(context, {
                            'title': _titleController.text,
                            'question': _questionController.text,
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${response['message']}'),
                              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                            ),
                          );
                        }
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(
                  widget.question == null ? 'Submit' : 'Save Changes',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
