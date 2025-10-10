import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../shared/widgets/pastel_card.dart';
import '../../../../shared/widgets/pastel_button.dart';
import '../../../../shared/widgets/audio_player_card.dart';

class DilemmaPage extends StatefulWidget {
  const DilemmaPage({super.key});

  @override
  State<DilemmaPage> createState() => _DilemmaPageState();
}

class _DilemmaPageState extends State<DilemmaPage> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> _dilemmas = [];
  List<Map<String, dynamic>> _filteredDilemmas = [];
  bool _isLoading = true;
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadDilemmas();
  }

  Future<void> _loadDilemmas() async {
    setState(() => _isLoading = true);
    try {
      final dilemmas = await _firebaseService.getDilemmas();
      setState(() {
        _dilemmas = dilemmas;
        _filteredDilemmas = dilemmas;
        _isLoading = false;
      });
      _firebaseService.logEvent('dilemma_page_viewed', null);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading dilemmas: $e')),
        );
      }
    }
  }

  void _filterDilemmas() {
    setState(() {
      _filteredDilemmas = _dilemmas.where((dilemma) {
        final matchesCategory = _selectedCategory == 'All' || 
            dilemma['category'] == _selectedCategory;
        final matchesSearch = _searchController.text.isEmpty ||
            dilemma['title'].toString().toLowerCase().contains(_searchController.text.toLowerCase()) ||
            dilemma['description'].toString().toLowerCase().contains(_searchController.text.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.createGradient(AppColors.oceanGradient),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: AppColors.deepLavender,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Life Dilemmas',
                            style: AppTypography.headlineMedium.copyWith(
                              color: AppColors.deepLavender,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Find wisdom for every situation',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.softCharcoal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.withOpacity(AppColors.mistyWhite, 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.withOpacity(AppColors.paleGray, 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowLight,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => _filterDilemmas(),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.deepCharcoal,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search life situations...',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: AppColors.lightGray,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.deepLavender,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: _firebaseService.getCategories().map((category) {
                    final isSelected = category == _selectedCategory;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                            _filterDilemmas();
                          });
                          _firebaseService.logEvent('category_selected', {'category': category});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppColors.createGradient(AppColors.primaryGradient)
                                : null,
                            color: isSelected
                                ? null
                                : AppColors.withOpacity(AppColors.mistyWhite, 0.7),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.transparent
                                  : AppColors.withOpacity(AppColors.paleGray, 0.3),
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.withOpacity(AppColors.deepLavender, 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            category,
                            style: AppTypography.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.mistyWhite
                                  : AppColors.deepLavender,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Dilemmas List
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(AppColors.deepLavender),
                        ),
                      )
                    : _filteredDilemmas.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: AppColors.withOpacity(AppColors.mistyWhite, 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Icon(
                                    Icons.psychology_outlined,
                                    size: 64,
                                    color: AppColors.lightGray,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No dilemmas found',
                                  style: AppTypography.headlineSmall.copyWith(
                                    color: AppColors.deepLavender,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try adjusting your search or category',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.softCharcoal,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadDilemmas,
                            color: AppColors.deepLavender,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              itemCount: _filteredDilemmas.length,
                              itemBuilder: (context, index) {
                                final dilemma = _filteredDilemmas[index];
                                return _PastelDilemmaCard(
                                  dilemma: dilemma,
                                  onTap: () {
                                    _firebaseService.logEvent('dilemma_opened', {
                                      'dilemma_id': dilemma['id'],
                                      'category': dilemma['category'],
                                    });
                                    _showDilemmaDetails(dilemma);
                                  },
                                );
                              },
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDilemmaDetails(Map<String, dynamic> dilemma) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.softGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dilemma['category'],
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.primaryBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(dilemma['difficulty']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              dilemma['difficulty'],
                              style: AppTypography.labelMedium.copyWith(
                                color: _getDifficultyColor(dilemma['difficulty']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        dilemma['title'],
                        style: AppTypography.h5.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        dilemma['description'],
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Mindful Approach
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryBlue.withValues(alpha: 0.05),
                              AppColors.growthGreen.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.spa, color: AppColors.primaryBlue, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Mindful Approach',
                                  style: AppTypography.h6.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              dilemma['mindfulApproach'],
                              style: AppTypography.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Practical Steps
                      Text(
                        'Practical Steps',
                        style: AppTypography.h6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        (dilemma['practicalSteps'] as List).length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 6),
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: AppColors.growthGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  dilemma['practicalSteps'][index],
                                  style: AppTypography.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Added to favorites!')),
                                );
                                _firebaseService.logEvent('dilemma_favorited', {
                                  'dilemma_id': dilemma['id'],
                                });
                              },
                              icon: const Icon(Icons.favorite_outline),
                              label: const Text('Save'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mindfulOrange,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Shared successfully!')),
                                );
                                _firebaseService.logEvent('dilemma_shared', {
                                  'dilemma_id': dilemma['id'],
                                });
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return AppColors.growthGreen;
      case 'medium':
        return AppColors.mindfulOrange;
      case 'high':
        return const Color(0xFFFF6B6B);
      default:
        return AppColors.textSecondary;
    }
  }

  Color _getPastelDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return AppColors.mintGreen;
      case 'medium':
        return AppColors.peach;
      case 'high':
        return AppColors.softPurple;
      default:
        return AppColors.deepLavender;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class _PastelDilemmaCard extends StatelessWidget {
  final Map<String, dynamic> dilemma;
  final VoidCallback onTap;

  const _PastelDilemmaCard({
    required this.dilemma,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficultyColor = _getDifficultyColor(dilemma['difficulty']);
    final categoryColors = _getCategoryGradient(dilemma['category']);
    
    return PastelCard.interactive(
      onTap: onTap,
      gradientColors: categoryColors,
      style: PastelCardStyle.gradient,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.withOpacity(AppColors.mistyWhite, 0.8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.withOpacity(AppColors.deepLavender, 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.psychology,
                  color: AppColors.deepLavender,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dilemma['title'],
                      style: AppTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepLavender,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dilemma['category'],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.softCharcoal,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.withOpacity(difficultyColor, 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.withOpacity(difficultyColor, 0.3),
                  ),
                ),
                child: Text(
                  dilemma['difficulty'],
                  style: AppTypography.labelSmall.copyWith(
                    color: difficultyColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.withOpacity(AppColors.mistyWhite, 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              dilemma['description'],
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.deepCharcoal,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.withOpacity(AppColors.mintGreen, 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.spa,
                      size: 14,
                      color: AppColors.deepLavender,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dilemma['wellnessFocus'],
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.deepLavender,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 14,
                    color: AppColors.lightGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dilemma['views']}',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.lightGray,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.deepLavender,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
        return AppColors.mintGreen;
      case 'medium':
        return AppColors.peach;
      case 'high':
        return AppColors.softPurple;
      default:
        return AppColors.deepLavender;
    }
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'relationship':
        return AppColors.dreamGradient;
      case 'career':
        return AppColors.oceanGradient;
      case 'family':
        return AppColors.primaryGradient;
      case 'personal':
        return AppColors.sunsetGradient;
      default:
        return AppColors.dreamGradient;
    }
  }
}