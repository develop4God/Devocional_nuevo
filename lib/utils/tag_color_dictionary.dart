import 'package:flutter/material.dart';

/// Diccionario centralizado de tags y gradientes de color para todos los idiomas usando claves de traducción
class TagColorDictionary {
  static const Map<String, List<Color>> tagGradients = {
    // Faith: Purple to Deep Purple
    'tag.faith': [Color(0xFF9C27B0), Color(0xFF673AB7)],
    // Purple, Deep Purple
    // Love: Pink to Red
    'tag.love': [Color(0xFFE91E63), Color(0xFFF44336)],
    // Pink, Red
    // Hope: Teal to Cyan
    'tag.hope': [Color(0xFF009688), Color(0xFF00BCD4)],
    // Teal, Cyan
    // Salvation: Gold to Cyan
    'tag.salvation': [Color(0xFFFFD700), Color(0xFF00BCD4)],
    // Gold, Cyan
    // Grace: Light Blue to Lavender
    'tag.grace': [Color(0xFF81D4FA), Color(0xFFE1BEE7)],
    // Light Blue, Lavender
    // Obedience: Orange to Yellow
    'tag.obedience': [Color(0xFFFF9800), Color(0xFFFFF176)],
    // Orange, Yellow
    // Sacrifice: Dark Red to Orange
    'tag.sacrifice': [Color(0xFFD32F2F), Color(0xFFFF5722)],
    // Dark Red, Orange
    // Humility: Brown to Dark Brown
    'tag.humility': [Color(0xFFA188FF), Color(0xFF7955F8)],
    // Brown, Dark Brown
    // Prayer: Blue to Indigo
    'tag.prayer': [Color(0xFF2196F3), Color(0xFF3F51B5)],
    // Blue, Indigo
    // Service: Teal to Green
    'tag.service': [Color(0xFF009688), Color(0xFF388E3C)],
    // Teal, Green
    // Forgiveness: Light Green to Green
    'tag.forgiveness': [Color(0xFF8BC34A), Color(0xFF388E3C)],
    // Light Green, Green
    // Holiness: Blue Grey to Dark Blue Grey
    'tag.holiness': [Color(0xFF607D8B), Color(0xFF455A64)],
    // Blue Grey, Dark Blue Grey
    // Glory: Gold to Purple
    'tag.glory': [Color(0xFFFFD700), Color(0xFF9C27B0)],
    // Gold, Purple
    // Patience: Blue Grey to Light Blue
    'tag.patience': [Color(0xFF607D8B), Color(0xFF81D4FA)],
    // Blue Grey, Light Blue
    // Peace: Blue to Indigo
    'tag.peace': [Color(0xFF2196F3), Color(0xFF3F51B5)],
    // Blue, Indigo
    // Thankfulness: Gold to Yellow
    'tag.thankfulness': [Color(0xFFFFD700), Color(0xFFFFF176)],
    // Gold, Yellow
    // Family: Orange to Amber
    'tag.family': [Color(0xFFFF5722), Color(0xFFFFC107)],
    // Orange, Amber
    // Trust: Blue to Teal
    'tag.trust': [Color(0xFF2196F3), Color(0xFF009688)],
    // Blue, Teal
    // Mercy: Pink to Light Blue
    'tag.mercy': [Color(0xFFE91E63), Color(0xFF81D4FA)],
    // Pink, Light Blue
    // Wisdom: Indigo to Blue Grey
    'tag.wisdom': [Color(0xFF3F51B5), Color(0xFF607D8B)],
    // Indigo, Blue Grey
    // Unity: Green to Light Blue
    'tag.unity': [Color(0xFF388E3C), Color(0xFF81D4FA)],
    // Green, Light Blue
    // Compassion: Orange to Light Blue
    'tag.compassion': [Color(0xFFFF9800), Color(0xFF81D4FA)],
    // Orange, Light Blue
    // Generosity: Amber to Green
    'tag.generosity': [Color(0xFFFFC107), Color(0xFF388E3C)],
    // Amber, Green
    // Victory: Gold to Green
    'tag.victory': [Color(0xFFFFD700), Color(0xFF388E3C)],
    // Gold, Green
    // Light: Yellow to White
    'tag.light': [Color(0xFFFFF176), Color(0xFFFFFFFF)],
    // Yellow, White
    // Purpose: Teal to Amber
    'tag.purpose': [Color(0xFF009688), Color(0xFFFFC107)],
    // Teal, Amber
    // Joy: Orange to Red
    'tag.joy': [Color(0xFFFF9800), Color(0xFFFF5722)],
    // Orange, Red
    // ...add more tags as needed...
  };

  // Traducción de tags por clave para cada idioma
  static const Map<String, Map<String, String>> tagTranslations = {
    'es': {
      'tag.faith': 'Fe',
      'tag.love': 'Amor',
      'tag.hope': 'Esperanza',
      'tag.salvation': 'Salvación',
      'tag.grace': 'Gracia',
      'tag.obedience': 'Obediencia',
      'tag.sacrifice': 'Sacrificio',
      'tag.humility': 'Humildad',
      'tag.prayer': 'Oración',
      'tag.service': 'Servicio',
      'tag.forgiveness': 'Perdón',
      'tag.holiness': 'Santidad',
      'tag.glory': 'Gloria',
      'tag.patience': 'Paciencia',
      'tag.peace': 'Paz',
      'tag.thankfulness': 'Gratitud',
      'tag.family': 'Familia',
      'tag.trust': 'Confianza',
      'tag.mercy': 'Misericordia',
      'tag.wisdom': 'Sabiduría',
      'tag.unity': 'Unidad',
      'tag.compassion': 'Compasión',
      'tag.generosity': 'Generosidad',
      'tag.victory': 'Victoria',
      'tag.light': 'Luz',
      'tag.purpose': 'Propósito',
      'tag.joy': 'Gozo',
    },
    'en': {
      'tag.faith': 'Faith',
      'tag.love': 'Love',
      'tag.hope': 'Hope',
      'tag.salvation': 'Salvation',
      'tag.grace': 'Grace',
      'tag.obedience': 'Obedience',
      'tag.sacrifice': 'Sacrifice',
      'tag.humility': 'Humility',
      'tag.prayer': 'Prayer',
      'tag.service': 'Service',
      'tag.forgiveness': 'Forgiveness',
      'tag.holiness': 'Holiness',
      'tag.glory': 'Glory',
      'tag.patience': 'Patience',
      'tag.peace': 'Peace',
      'tag.thankfulness': 'Thankfulness',
      'tag.family': 'Family',
      'tag.trust': 'Trust',
      'tag.mercy': 'Mercy',
      'tag.wisdom': 'Wisdom',
      'tag.unity': 'Unity',
      'tag.compassion': 'Compassion',
      'tag.generosity': 'Generosity',
      'tag.victory': 'Victory',
      'tag.light': 'Light',
      'tag.purpose': 'Purpose',
      'tag.joy': 'Joy',
    },
    'pt': {
      'tag.faith': 'Fé',
      'tag.love': 'Amor',
      'tag.hope': 'Esperança',
      'tag.salvation': 'Salvação',
      'tag.grace': 'Graça',
      'tag.obedience': 'Obediência',
      'tag.sacrifice': 'Sacrifício',
      'tag.humility': 'Humildade',
      'tag.prayer': 'Oração',
      'tag.service': 'Serviço',
      'tag.forgiveness': 'Perdão',
      'tag.holiness': 'Santidade',
      'tag.glory': 'Glória',
      'tag.patience': 'Paciência',
      'tag.peace': 'Paz',
      'tag.thankfulness': 'Gratidão',
      'tag.family': 'Família',
      'tag.trust': 'Confiança',
      'tag.mercy': 'Misericórdia',
      'tag.wisdom': 'Sabedoria',
      'tag.unity': 'Unidade',
      'tag.compassion': 'Compaixão',
      'tag.generosity': 'Generosidade',
      'tag.victory': 'Vitória',
      'tag.light': 'Luz',
      'tag.purpose': 'Propósito',
      'tag.joy': 'Alegria',
    },
    'fr': {
      'tag.faith': 'Foi',
      'tag.love': 'Amour',
      'tag.hope': 'Espoir',
      'tag.salvation': 'Salut',
      'tag.grace': 'Grâce',
      'tag.obedience': 'Obéissance',
      'tag.sacrifice': 'Sacrifice',
      'tag.humility': 'Humilité',
      'tag.prayer': 'Prière',
      'tag.service': 'Service',
      'tag.forgiveness': 'Pardon',
      'tag.holiness': 'Sainteté',
      'tag.glory': 'Gloire',
      'tag.patience': 'Patience',
      'tag.peace': 'Paix',
      'tag.thankfulness': 'Reconnaissance',
      'tag.family': 'Famille',
      'tag.trust': 'Confiance',
      'tag.mercy': 'Miséricorde',
      'tag.wisdom': 'Sagesse',
      'tag.unity': 'Unité',
      'tag.compassion': 'Compassion',
      'tag.generosity': 'Générosité',
      'tag.victory': 'Victoire',
      'tag.light': 'Lumière',
      'tag.purpose': 'But',
      'tag.joy': 'Joie',
    },
    'ja': {
      'tag.faith': '信仰',
      'tag.love': '愛',
      'tag.hope': '希望',
      'tag.salvation': '救い',
      'tag.grace': '恵み',
      'tag.obedience': '従順',
      'tag.sacrifice': '犠牲',
      'tag.humility': '謙遜',
      'tag.prayer': '祈り',
      'tag.service': '奉仕',
      'tag.forgiveness': '赦し',
      'tag.holiness': '聖さ',
      'tag.glory': '栄光',
      'tag.patience': '忍耐',
      'tag.peace': '平和',
      'tag.thankfulness': '感謝',
      'tag.family': '家族',
      'tag.trust': '信頼',
      'tag.mercy': '慈悲',
      'tag.wisdom': '知恵',
      'tag.unity': '一致',
      'tag.compassion': '思いやり',
      'tag.generosity': '寛大さ',
      'tag.victory': '勝利',
      'tag.light': '光',
      'tag.purpose': '目的',
      'tag.joy': '喜び',
    },
    'zh': {
      'tag.faith': '信仰',
      'tag.love': '爱',
      'tag.hope': '希望',
      'tag.salvation': '救赎',
      'tag.grace': '恩典',
      'tag.obedience': '顺服',
      'tag.sacrifice': '牺牲',
      'tag.humility': '谦卑',
      'tag.prayer': '祷告',
      'tag.service': '服侍',
      'tag.forgiveness': '宽恕',
      'tag.holiness': '圣洁',
      'tag.glory': '荣耀',
      'tag.patience': '耐心',
      'tag.peace': '和平',
      'tag.thankfulness': '感恩',
      'tag.family': '家庭',
      'tag.trust': '信任',
      'tag.mercy': '怜悯',
      'tag.wisdom': '智慧',
      'tag.unity': '合一',
      'tag.compassion': '同情',
      'tag.generosity': '慷慨',
      'tag.victory': '胜利',
      'tag.light': '光',
      'tag.purpose': '目的',
      'tag.joy': '喜乐',
    },
  };

  // Mapeo de tags externos (como vienen en los JSON) a claves internas estándar
  static const Map<String, String> externalTagToInternalKey = {
    // Francés
    'foi': 'tag.faith',
    'amour': 'tag.love',
    'espérance': 'tag.hope',
    'salut': 'tag.salvation',
    'grâce': 'tag.grace',
    'obéissance': 'tag.obedience',
    'sacrifice': 'tag.sacrifice',
    'humilité': 'tag.humility',
    'prière': 'tag.prayer',
    'service': 'tag.service',
    'pardon': 'tag.forgiveness',
    'sainteté': 'tag.holiness',
    'gloire': 'tag.glory',
    'patience': 'tag.patience',
    'paix': 'tag.peace',
    'reconnaissance': 'tag.thankfulness',
    'famille': 'tag.family',
    'confiance': 'tag.trust',
    'miséricorde': 'tag.mercy',
    'sagesse': 'tag.wisdom',
    'unité': 'tag.unity',
    'compassion': 'tag.compassion',
    'générosité': 'tag.generosity',
    'victoire': 'tag.victory',
    'lumière': 'tag.light',
    'but': 'tag.purpose',
    'joie': 'tag.joy',
    // Español y Portugués (solo una vez por clave)
    'fe': 'tag.faith',
    'esperanza': 'tag.hope',
    'salvación': 'tag.salvation',
    'gracia': 'tag.grace',
    'obediencia': 'tag.obedience',
    'sacrificio': 'tag.sacrifice',
    'humildad': 'tag.humility',
    'oración': 'tag.prayer',
    'servicio': 'tag.service',
    'perdón': 'tag.forgiveness',
    'santidad': 'tag.holiness',
    'gloria': 'tag.glory',
    'paciencia': 'tag.patience',
    'paz': 'tag.peace',
    'gratitud': 'tag.thankfulness',
    'familia': 'tag.family',
    'confianza': 'tag.trust',
    'misericordia': 'tag.mercy',
    'sabiduría': 'tag.wisdom',
    'unidad': 'tag.unity',
    'compasión': 'tag.compassion',
    'generosidad': 'tag.generosity',
    'victoria': 'tag.victory',
    'luz': 'tag.light',
    'propósito': 'tag.purpose',
    'gozo': 'tag.joy',
    'fé': 'tag.faith',
    'esperança': 'tag.hope',
    'salvação': 'tag.salvation',
    'graça': 'tag.grace',
    'obediência': 'tag.obedience',
    'sacrifício': 'tag.sacrifice',
    'humildade': 'tag.humility',
    'oração': 'tag.prayer',
    'serviço': 'tag.service',
    'perdão': 'tag.forgiveness',
    'santidade': 'tag.holiness',
    'glória': 'tag.glory',
    'paciência': 'tag.patience',
    'gratidão': 'tag.thankfulness',
    'família': 'tag.family',
    'misericórdia': 'tag.mercy',
    'sabedoria': 'tag.wisdom',
    'unidade': 'tag.unity',
    'compaixão': 'tag.compassion',
    'generosidade': 'tag.generosity',
    'vitória': 'tag.victory',
    'alegria': 'tag.joy',
    // Inglés (por si acaso, solo las que no estén arriba)
    'faith': 'tag.faith',
    'love': 'tag.love',
    'hope': 'tag.hope',
    'salvation': 'tag.salvation',
    'grace': 'tag.grace',
    'obedience': 'tag.obedience',
    'humility': 'tag.humility',
    'prayer': 'tag.prayer',
    'forgiveness': 'tag.forgiveness',
    'holiness': 'tag.holiness',
    'glory': 'tag.glory',
    'peace': 'tag.peace',
    'thankfulness': 'tag.thankfulness',
    'family': 'tag.family',
    'trust': 'tag.trust',
    'mercy': 'tag.mercy',
    'wisdom': 'tag.wisdom',
    'unity': 'tag.unity',
    'generosity': 'tag.generosity',
    'victory': 'tag.victory',
    'light': 'tag.light',
    'purpose': 'tag.purpose',
    'joy': 'tag.joy',
  };

  static String normalizeTagKey(String tagKey) {
    if (tagGradients.containsKey(tagKey)) return tagKey;
    return externalTagToInternalKey[tagKey.toLowerCase()] ?? tagKey;
  }

  static List<Color> getGradientForTag(String tagKey) {
    final normalized = normalizeTagKey(tagKey);
    final gradient =
        tagGradients[normalized] ?? [Color(0xFF607D8B), Color(0xFF455A64)];
    debugPrint(
        '[TagColorDictionary] Tag recibido: "$tagKey" | Normalizado: "$normalized" | Gradient: $gradient');
    return gradient;
  }

  static String getTagTranslation(String tagKey, String languageCode) {
    final normalized = normalizeTagKey(tagKey);
    return tagTranslations[languageCode]?[normalized] ?? normalized;
  }
}
