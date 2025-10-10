import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestScreen extends StatefulWidget {
  const FirebaseTestScreen({Key? key}) : super(key: key);

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> {
  bool _isLoading = true;
  String _status = 'Testing Firebase connection...';
  List<Map<String, dynamic>> _situations = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _testFirestore();
  }

  Future<void> _testFirestore() async {
    setState(() {
      _isLoading = true;
      _status = 'Connecting to Firestore...';
    });

    try {
      // Test 1: Check metadata
      final metadataDoc = await FirebaseFirestore.instance
          .collection('metadata')
          .doc('content_stats')
          .get();

      if (metadataDoc.exists) {
        final data = metadataDoc.data()!;
        setState(() {
          _status = 'Connected! Found ${data['totalSituations']} situations in database';
        });
      }

      // Test 2: Query life_situations
      final querySnapshot = await FirebaseFirestore.instance
          .collection('life_situations')
          .where('isActive', isEqualTo: true)
          .limit(10)
          .get();

      setState(() {
        _situations = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _isLoading = false;
        _status = '✅ Success! Loaded ${_situations.length} situations';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
        _status = '❌ Error connecting to Firestore';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Test'),
        backgroundColor: Colors.blue,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(_status),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: _error == null ? Colors.green[50] : Colors.red[50],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _status,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _error == null ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Error: $_error',
                              style: TextStyle(color: Colors.red[700]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Situations List
                  if (_situations.isNotEmpty) ...[
                    Text(
                      'Sample Situations (First 10):',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _situations.length,
                      itemBuilder: (context, index) {
                        final situation = _situations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getLifeAreaColor(situation['lifeArea']),
                              child: Text(
                                situation['lifeArea']?[0]?.toUpperCase() ?? '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              situation['title'] ?? 'No title',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  situation['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    Chip(
                                      label: Text(
                                        situation['lifeArea'] ?? 'unknown',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Chip(
                                      label: Text(
                                        situation['difficulty'] ?? 'unknown',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
                          ),
                        );
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Test different queries
                  ElevatedButton(
                    onPressed: _testWellnessQuery,
                    child: const Text('Test: Query Wellness Situations'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testVoiceKeywords,
                    child: const Text('Test: Search by Voice Keywords'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _testDifficulty,
                    child: const Text('Test: Filter by Difficulty'),
                  ),
                ],
              ),
            ),
    );
  }

  Color _getLifeAreaColor(String? lifeArea) {
    switch (lifeArea) {
      case 'wellness':
        return Colors.green;
      case 'relationships':
        return Colors.pink;
      case 'career':
        return Colors.blue;
      case 'growth':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _testWellnessQuery() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('life_situations')
          .where('lifeArea', isEqualTo: 'wellness')
          .limit(5)
          .get();

      _showResultDialog('Wellness Query', '${result.docs.length} wellness situations found');
    } catch (e) {
      _showResultDialog('Error', e.toString());
    }
  }

  Future<void> _testVoiceKeywords() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('life_situations')
          .where('voiceKeywords', arrayContains: 'stress')
          .limit(5)
          .get();

      _showResultDialog('Voice Keywords', '${result.docs.length} situations with "stress" keyword');
    } catch (e) {
      _showResultDialog('Error', e.toString());
    }
  }

  Future<void> _testDifficulty() async {
    try {
      final result = await FirebaseFirestore.instance
          .collection('life_situations')
          .where('difficulty', isEqualTo: 'beginner')
          .limit(5)
          .get();

      _showResultDialog('Difficulty Filter', '${result.docs.length} beginner situations found');
    } catch (e) {
      _showResultDialog('Error', e.toString());
    }
  }

  void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
