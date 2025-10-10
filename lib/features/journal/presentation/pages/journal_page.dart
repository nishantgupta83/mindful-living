import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/emoji_rating.dart';
import '../../../../shared/widgets/gradient_button.dart';
import '../../../../shared/widgets/radial_gradient_background.dart';

/// Journal entry model
class JournalEntry {
  final String id;
  final String content;
  final int rating;
  final DateTime createdAt;
  final List<String> tags;

  JournalEntry({
    required this.id,
    required this.content,
    required this.rating,
    required this.createdAt,
    this.tags = const [],
  });
}

/// Journal page with emoji rating and swipe-to-dismiss
class JournalPage extends StatefulWidget {
  const JournalPage({super.key});

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final List<JournalEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadMockEntries();
  }

  void _loadMockEntries() {
    setState(() {
      _entries.addAll([
        JournalEntry(
          id: '1',
          content: 'Great day! Practiced meditation for 20 minutes.',
          rating: 4,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          tags: ['meditation'],
        ),
        JournalEntry(
          id: '2',
          content: 'Stressed about work but breathing helped.',
          rating: 3,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['stress'],
        ),
      ]);
    });
  }

  void _createEntry() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const JournalEditorPage()),
    );
  }

  void _deleteEntry(JournalEntry entry) {
    setState(() => _entries.remove(entry));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Entry deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => setState(() => _entries.insert(0, entry)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Journal'),
        backgroundColor: AppColors.lavender.withValues(alpha: 0.1),
      ),
      body: _entries.isEmpty
          ? const Center(child: Text('No entries yet'))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: _entries.length,
              itemBuilder: (context, index) {
                final entry = _entries[index];
                return Dismissible(
                  key: ValueKey(entry.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red.withValues(alpha: 0.2),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  onDismissed: (_) => _deleteEntry(entry),
                  child: Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CompactEmojiRating(rating: entry.rating),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(entry.createdAt),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(entry.content),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createEntry,
        backgroundColor: AppColors.deepLavender,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.day == now.day) return 'Today';
    if (date.day == now.day - 1) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}

/// Journal editor page
class JournalEditorPage extends StatefulWidget {
  const JournalEditorPage({super.key});

  @override
  State<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends State<JournalEditorPage> {
  final TextEditingController _controller = TextEditingController();
  int? _rating;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_controller.text.isEmpty || _rating == null) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RadialGradientPresets.journal(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'New Entry',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text(
                        'How was your day?',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),
                      EmojiRating(
                        initialRating: _rating,
                        onRatingChanged: (r) => setState(() => _rating = r),
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind?',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        maxLines: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: GradientButton(
                  label: 'Save',
                  onPressed: _save,
                  isLoading: _saving,
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
