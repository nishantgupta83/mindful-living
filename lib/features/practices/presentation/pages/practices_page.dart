import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/firebase_service.dart';

class PracticesPage extends StatefulWidget {
  const PracticesPage({super.key});

  @override
  State<PracticesPage> createState() => _PracticesPageState();
}

class _PracticesPageState extends State<PracticesPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _practices = [];
  List<Map<String, dynamic>> _filteredPractices = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedType = 'All';
  String _selectedDifficulty = 'All';

  final List<String> _practiceTypes = ['All', 'Breathing', 'Meditation', 'Movement', 'Reflection'];
  final List<String> _difficulties = ['All', 'Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadPractices();
    _firebaseService.logEvent('practices_page_viewed', {});
  }

  Future<void> _loadPractices() async {
    try {
      final practices = await _firebaseService.getPractices();
      setState(() {
        _practices = practices;
        _filteredPractices = practices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading practices: $e')),
        );
      }
    }
  }

  void _filterPractices() {
    setState(() {
      _filteredPractices = _practices.where((practice) {
        final matchesSearch = practice['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
                            practice['description'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _selectedType == 'All' || practice['type'] == _selectedType;
        final matchesDifficulty = _selectedDifficulty == 'All' || practice['difficulty'] == _selectedDifficulty;
        return matchesSearch && matchesType && matchesDifficulty;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Mindful Practices',
          style: AppTypography.h4.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Favorites coming soon!')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filters
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                      _filterPractices();
                    },
                    decoration: InputDecoration(
                      hintText: 'Search practices...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Combined Filter Chips
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Type',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _practiceTypes.length,
                        itemBuilder: (context, index) {
                          final type = _practiceTypes[index];
                          final isSelected = _selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(type),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = type;
                                });
                                _filterPractices();
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                              checkmarkColor: AppColors.primaryBlue,
                              labelStyle: AppTypography.labelSmall.copyWith(
                                color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      'Difficulty',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _difficulties.length,
                        itemBuilder: (context, index) {
                          final difficulty = _difficulties[index];
                          final isSelected = _selectedDifficulty == difficulty;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(difficulty),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedDifficulty = difficulty;
                                });
                                _filterPractices();
                              },
                              backgroundColor: Colors.white,
                              selectedColor: AppColors.growthGreen.withValues(alpha: 0.1),
                              checkmarkColor: AppColors.growthGreen,
                              labelStyle: AppTypography.labelSmall.copyWith(
                                color: isSelected ? AppColors.growthGreen : AppColors.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Practices List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredPractices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.self_improvement_outlined,
                              size: 64,
                              color: AppColors.textSecondary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No practices found',
                              style: AppTypography.h6.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredPractices.length,
                        itemBuilder: (context, index) {
                          final practice = _filteredPractices[index];
                          return _PracticeCard(
                            practice: practice,
                            onTap: () => _showPracticeDetail(practice),
                          );
                        },
                      ),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'practicesFAB', // Unique hero tag
        onPressed: () {
          _showCreatePracticeDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Custom Practice'),
        backgroundColor: AppColors.primaryBlue,
      ),
    );
  }

  void _showPracticeDetail(Map<String, dynamic> practice) {
    _firebaseService.logEvent('practice_detail_viewed', {'practice_id': practice['id']});
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.softGray,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                practice['icon'] ?? '🧘',
                                style: const TextStyle(fontSize: 32),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    practice['title'] ?? 'Practice',
                                    style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.growthGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          practice['duration'] ?? '5 min',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.growthGreen,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          practice['difficulty'] ?? 'Beginner',
                                          style: AppTypography.labelSmall.copyWith(
                                            color: AppColors.primaryBlue,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Description
                        Text(
                          'About This Practice',
                          style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          practice['description'] ?? 'A mindful practice to enhance well-being.',
                          style: AppTypography.bodyMedium.copyWith(height: 1.5),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Benefits
                        if (practice['benefits'] != null) ...[
                          Text(
                            'Benefits',
                            style: AppTypography.h6.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ...List.generate(
                            (practice['benefits'] as List).length,
                            (index) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(top: 8, right: 12),
                                    decoration: const BoxDecoration(
                                      color: AppColors.growthGreen,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      practice['benefits'][index],
                                      style: AppTypography.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 32),
                        
                        // Start Practice Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _startPractice(practice);
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Start Practice'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Save to Favorites Button
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to favorites!')),
                              );
                            },
                            icon: const Icon(Icons.favorite_outline),
                            label: const Text('Add to Favorites'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _startPractice(Map<String, dynamic> practice) {
    _firebaseService.logEvent('practice_started', {'practice_id': practice['id']});
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(practice['title']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(practice['icon'] ?? '🧘', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Ready to begin ${practice['title']}?'),
            const SizedBox(height: 8),
            Text(
              'Duration: ${practice['duration']}',
              style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // In a real app, this would navigate to a practice session screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Starting ${practice['title']}... (Practice session coming soon!)')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
            child: const Text('Begin'),
          ),
        ],
      ),
    );
  }

  void _showCreatePracticeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Create Custom Practice'),
        content: const Text('Custom practice creation coming soon! You\'ll be able to create your own mindful practices tailored to your needs.'),
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

class _PracticeCard extends StatelessWidget {
  final Map<String, dynamic> practice;
  final VoidCallback onTap;

  const _PracticeCard({
    required this.practice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryBlue.withValues(alpha: 0.1),
                        AppColors.primaryBlue.withValues(alpha: 0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      practice['icon'] ?? '🧘',
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              practice['title'] ?? 'Practice',
                              style: AppTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.growthGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              practice['duration'] ?? '5 min',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.growthGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 6),
                      
                      Text(
                        practice['description'] ?? 'A mindful practice',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              practice['type'] ?? 'Practice',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mindfulOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              practice['difficulty'] ?? 'Beginner',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.mindfulOrange,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(width: 8),
                
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}