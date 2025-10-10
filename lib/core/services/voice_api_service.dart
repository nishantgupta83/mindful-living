import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../shared/models/life_situation.dart';
import 'voice_search_service.dart';

enum VoiceQuerySource { appleWatch, alexa, siri, generic }

class VoiceQuery {
  final String query;
  final VoiceQuerySource source;
  final String? userId;
  final DateTime timestamp;
  final Map<String, dynamic>? context;

  VoiceQuery({
    required this.query,
    required this.source,
    this.userId,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'source': source.toString(),
      'userId': userId,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }
}

class VoiceResponse {
  final String spokenResponse;
  final String? cardTitle;
  final String? cardContent;
  final LifeSituation? situation;
  final double confidence;
  final bool shouldEndSession;
  final Map<String, dynamic>? additionalData;

  VoiceResponse({
    required this.spokenResponse,
    this.cardTitle,
    this.cardContent,
    this.situation,
    this.confidence = 0.0,
    this.shouldEndSession = true,
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    return {
      'spokenResponse': spokenResponse,
      'cardTitle': cardTitle,
      'cardContent': cardContent,
      'situation': situation?.toJson(),
      'confidence': confidence,
      'shouldEndSession': shouldEndSession,
      'additionalData': additionalData,
    };
  }

  // Create Alexa-specific response format
  Map<String, dynamic> toAlexaResponse() {
    return {
      'version': '1.0',
      'response': {
        'outputSpeech': {
          'type': 'PlainText',
          'text': spokenResponse,
        },
        if (cardTitle != null && cardContent != null)
          'card': {
            'type': 'Standard',
            'title': cardTitle,
            'text': cardContent,
          },
        'shouldEndSession': shouldEndSession,
      },
    };
  }

  // Create Apple Watch / Siri response format
  Map<String, dynamic> toSiriResponse() {
    return {
      'speech': spokenResponse,
      if (situation != null) 'situationId': situation!.id,
      'confidence': confidence,
      'additionalData': additionalData,
    };
  }
}

class VoiceApiService {
  static final VoiceApiService _instance = VoiceApiService._internal();
  factory VoiceApiService() => _instance;
  VoiceApiService._internal();

  final VoiceSearchService _searchService = VoiceSearchService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Base URL for your Firebase Functions (will be set when deployed)
  static const String _baseUrl = 'https://us-central1-hub4apps-mindfulliving.cloudfunctions.net';

  /// Process a voice query and return an appropriate response
  Future<VoiceResponse> processVoiceQuery(VoiceQuery query) async {
    try {
      // Log the query for analytics
      await _logVoiceQuery(query);

      // Get life situations from Firestore
      final situations = await _getLifeSituations();

      // Search for matching situations
      final searchResults = await _searchService.searchSituations(
        query.query,
        situations,
        maxResults: 1, // Voice responses should be concise
        minConfidence: 0.3,
      );

      if (searchResults.isEmpty) {
        return _createNoResultsResponse(query);
      }

      final bestMatch = searchResults.first;
      
      // Update usage statistics
      await _updateUsageStats(bestMatch.situation);

      return _createSuccessResponse(bestMatch, query.source);

    } catch (e) {
      print('Error processing voice query: $e');
      return _createErrorResponse();
    }
  }

  /// Get life situations from Firestore
  Future<List<LifeSituation>> _getLifeSituations() async {
    try {
      final snapshot = await _firestore
          .collection('life_situations')
          .where('isVoiceOptimized', isEqualTo: true)
          .get();

      return snapshot.docs
          .map((doc) => LifeSituation.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error fetching life situations: $e');
      return [];
    }
  }

  /// Log voice query for analytics and improvement
  Future<void> _logVoiceQuery(VoiceQuery query) async {
    try {
      await _firestore.collection('voice_queries').add(query.toJson());
    } catch (e) {
      print('Error logging voice query: $e');
    }
  }

  /// Update usage statistics for the matched situation
  Future<void> _updateUsageStats(LifeSituation situation) async {
    try {
      await _firestore
          .collection('life_situations')
          .doc(situation.id)
          .update({
        'voicePopularity': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating usage stats: $e');
    }
  }

  /// Create a successful response with situation guidance
  VoiceResponse _createSuccessResponse(
    VoiceSearchResult searchResult, 
    VoiceQuerySource source,
  ) {
    final situation = searchResult.situation;
    
    // Create spoken response based on the platform
    String spokenResponse;
    if (source == VoiceQuerySource.alexa) {
      spokenResponse = _createAlexaResponse(situation);
    } else {
      spokenResponse = _createWatchResponse(situation);
    }

    return VoiceResponse(
      spokenResponse: spokenResponse,
      cardTitle: situation.spokenTitle,
      cardContent: _createCardContent(situation),
      situation: situation,
      confidence: searchResult.confidence,
      shouldEndSession: true,
      additionalData: {
        'matchedTerms': searchResult.matchedTerms,
        'lifeArea': situation.lifeArea,
        'estimatedReadTime': situation.estimatedReadTime,
      },
    );
  }

  /// Create Alexa-optimized spoken response
  String _createAlexaResponse(LifeSituation situation) {
    // Alexa responses should be more conversational and detailed
    final spokenSteps = situation.spokenActionSteps;
    
    return "Here's what I found for ${situation.spokenTitle.toLowerCase()}. "
           "$spokenSteps "
           "Would you like me to send the full guidance to your phone?";
  }

  /// Create Apple Watch-optimized spoken response  
  String _createWatchResponse(LifeSituation situation) {
    // Watch responses should be concise due to context and battery
    final steps = situation.spokenActionSteps;
    final shortSteps = steps.length > 150 
        ? steps.substring(0, 147) + '...' 
        : steps;
    
    return "For ${situation.spokenTitle.toLowerCase()}: $shortSteps";
  }

  /// Create card content for visual display
  String _createCardContent(LifeSituation situation) {
    return "${situation.description}\n\n"
           "Mindful Approach:\n${situation.mindfulApproach}\n\n"
           "Practical Steps:\n${situation.practicalSteps}";
  }

  /// Create response when no situations match the query
  VoiceResponse _createNoResultsResponse(VoiceQuery query) {
    final responses = [
      "I couldn't find specific guidance for that. Could you try rephrasing your question?",
      "I don't have advice for that exact situation. Try asking about work stress, relationships, or parenting challenges.",
      "I'm not sure about that one. I can help with common life situations like stress management, relationship issues, or workplace challenges.",
    ];
    
    final randomResponse = responses[DateTime.now().millisecond % responses.length];
    
    return VoiceResponse(
      spokenResponse: randomResponse,
      confidence: 0.0,
      shouldEndSession: false, // Allow user to try again
    );
  }

  /// Create error response for system failures
  VoiceResponse _createErrorResponse() {
    return VoiceResponse(
      spokenResponse: "I'm having trouble right now. Please try again in a moment.",
      confidence: 0.0,
      shouldEndSession: true,
    );
  }

  /// Handle Alexa skill requests
  Future<Map<String, dynamic>> handleAlexaRequest(Map<String, dynamic> request) async {
    try {
      final requestType = request['request']['type'] as String;
      
      if (requestType == 'IntentRequest') {
        final intentName = request['request']['intent']['name'] as String;
        
        if (intentName == 'GetLifeAdviceIntent') {
          final query = request['request']['intent']['slots']['situation']['value'] as String? ?? '';
          
          final voiceQuery = VoiceQuery(
            query: query,
            source: VoiceQuerySource.alexa,
            userId: request['session']['user']['userId'] as String?,
            context: request,
          );
          
          final response = await processVoiceQuery(voiceQuery);
          return response.toAlexaResponse();
        }
      }
      
      // Handle launch request, session end, etc.
      return _getDefaultAlexaResponse(requestType);
      
    } catch (e) {
      print('Error handling Alexa request: $e');
      return VoiceResponse(
        spokenResponse: "Sorry, I'm having trouble right now. Please try again later.",
        shouldEndSession: true,
      ).toAlexaResponse();
    }
  }

  /// Get default responses for different Alexa request types
  Map<String, dynamic> _getDefaultAlexaResponse(String requestType) {
    String response;
    bool shouldEndSession;
    
    switch (requestType) {
      case 'LaunchRequest':
        response = "Welcome to Mindful Living! Ask me about any life situation you're facing, like 'how do I handle work stress' or 'what should I do about a toddler tantrum'?";
        shouldEndSession = false;
        break;
      case 'SessionEndedRequest':
        response = "Thanks for using Mindful Living. Take care!";
        shouldEndSession = true;
        break;
      default:
        response = "I can help you with life situations. Just ask me something like 'how do I deal with stress'?";
        shouldEndSession = false;
    }
    
    return VoiceResponse(
      spokenResponse: response,
      shouldEndSession: shouldEndSession,
    ).toAlexaResponse();
  }

  /// Handle Apple Watch / Siri requests
  Future<Map<String, dynamic>> handleSiriRequest(Map<String, dynamic> request) async {
    try {
      final query = request['query'] as String? ?? '';
      final userId = request['userId'] as String?;
      
      final voiceQuery = VoiceQuery(
        query: query,
        source: VoiceQuerySource.siri,
        userId: userId,
        context: request,
      );
      
      final response = await processVoiceQuery(voiceQuery);
      return response.toSiriResponse();
      
    } catch (e) {
      print('Error handling Siri request: $e');
      return {
        'speech': "I'm having trouble right now. Please try again.",
        'confidence': 0.0,
      };
    }
  }

  /// Get analytics data for voice usage
  Future<Map<String, dynamic>> getVoiceAnalytics() async {
    try {
      final now = DateTime.now();
      final lastWeek = now.subtract(const Duration(days: 7));
      
      final querySnapshot = await _firestore
          .collection('voice_queries')
          .where('timestamp', isGreaterThan: lastWeek)
          .get();
      
      final queries = querySnapshot.docs.map((doc) => doc.data()).toList();
      
      // Aggregate statistics
      final totalQueries = queries.length;
      final sourceBreakdown = <String, int>{};
      final popularQueries = <String, int>{};
      
      for (final query in queries) {
        final source = query['source'] as String;
        sourceBreakdown[source] = (sourceBreakdown[source] ?? 0) + 1;
        
        final queryText = query['query'] as String;
        popularQueries[queryText] = (popularQueries[queryText] ?? 0) + 1;
      }
      
      return {
        'totalQueries': totalQueries,
        'sourceBreakdown': sourceBreakdown,
        'popularQueries': popularQueries,
        'period': 'last_7_days',
      };
      
    } catch (e) {
      print('Error getting voice analytics: $e');
      return {'error': 'Failed to fetch analytics'};
    }
  }
}