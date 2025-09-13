import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiChatService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  late final GenerativeModel _model;
  
  GeminiChatService() {
    // Configure generation settings for optimal biblical responses
    final generationConfig = GenerationConfig(
      temperature: 0.7,
      topK: 40,
      topP: 0.95,
      maxOutputTokens: 1024,
    );
    
    // Safety settings to allow religious content
    final safetySettings = [
      SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
      SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
    ];
    
    _model = GenerativeModel(
      model: 'gemini-2.0-flash-lite',
      apiKey: _apiKey,
      generationConfig: generationConfig,
      safetySettings: safetySettings,
    );
  }
  
  Future<String> sendMessage(String userMessage, String language) async {
    try {
      final prompt = _buildPrompt(userMessage, language);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? _getErrorMessage(language);
    } catch (e) {
      throw Exception('Error communicating with Gemini: $e');
    }
  }
  
  String _buildPrompt(String userMessage, String language) {
    final prompts = {
      'es': '''Eres un asistente bíblico cristiano sabio y pastoral. Responde en español de manera clara, amorosa y edificante.
      
Directrices:
- Usa un tono cálido y pastoral
- Incluye referencias bíblicas relevantes cuando sea apropiado
- Mantén respuestas concisas pero completas
- Enfócate en aplicación práctica de la fe

Usuario: $userMessage

Responde de manera que edifique espiritualmente al usuario.''',

      'en': '''You are a wise and pastoral Christian biblical assistant. Respond in English clearly, lovingly and edifyingly.

Guidelines:
- Use a warm and pastoral tone
- Include relevant biblical references when appropriate
- Keep responses concise but complete
- Focus on practical faith application

User: $userMessage

Respond in a way that spiritually edifies the user.''',

      'pt': '''Você é um assistente bíblico cristão sábio e pastoral. Responda em português de forma clara, amorosa e edificante.

Diretrizes:
- Use um tom caloroso e pastoral
- Inclua referências bíblicas relevantes quando apropriado
- Mantenha as respostas concisas mas completas
- Foque na aplicação prática da fé

Usuário: $userMessage

Responda de forma que edifique espiritualmente o usuário.''',

      'fr': '''Tu es un assistant biblique chrétien sage et pastoral. Réponds en français de manière claire, aimante et édifiante.

Directives:
- Utilise un ton chaleureux et pastoral
- Inclus des références bibliques pertinentes quand approprié
- Garde les réponses concises mais complètes
- Concentre-toi sur l'application pratique de la foi

Utilisateur: $userMessage

Réponds d'une manière qui édifie spirituellement l'utilisateur.''',
    };
    
    return prompts[language] ?? prompts['es']!;
  }
  
  String _getErrorMessage(String language) {
    final messages = {
      'es': 'Lo siento, no pude procesar tu pregunta en este momento.',
      'en': 'Sorry, I couldn\'t process your question right now.',
      'pt': 'Desculpe, não consegui processar sua pergunta no momento.',
      'fr': 'Désolé, je n\'ai pas pu traiter votre question pour le moment.',
    };
    return messages[language] ?? messages['es']!;
  }
}