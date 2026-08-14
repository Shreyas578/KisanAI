/// Text-Based Translation System for Kisan AI
///
/// This provides offline translations for all agricultural terms
/// in: English, Hindi, Tamil, Marathi
///
/// No API calls needed - completely offline!

class Translations {
  static const Map<String, Map<String, String>> _translations = {
    // ========== DISEASE NAMES ==========
    'leaf_blight': {
      'en': 'Leaf Blight',
      'hi': 'पत्ती झुलसा',
      'ta': 'இலை நோய்',
      'mr': 'पान खवळ',
    },
    'rust': {'en': 'Rust', 'hi': 'रस्ट', 'ta': 'தகரம்', 'mr': 'गंज'},
    'powdery_mildew': {
      'en': 'Powdery Mildew',
      'hi': 'चूर्णी फफूंद',
      'ta': 'தூள் பூஞ்சனம்',
      'mr': 'चूर्ण भूद',
    },
    'anthracnose': {
      'en': 'Anthracnose',
      'hi': 'एन्थ्राक्नोज़',
      'ta': 'அந்த்ரக்னோஸ்',
      'mr': 'अँथ्रॅक्नोज',
    },
    'downy_mildew': {
      'en': 'Downy Mildew',
      'hi': 'डाउनी मिल्ड्यू',
      'ta': 'இறக்க பூஞ்சனம்',
      'mr': 'डाउनी मिल्ड्यू',
    },
    'early_blight': {
      'en': 'Early Blight',
      'hi': 'प्रारंभिक झुलसा',
      'ta': 'முதல் தகராய்',
      'mr': 'सुरुवातीचा खवळ',
    },
    'late_blight': {
      'en': 'Late Blight',
      'hi': 'देर से झुलसा',
      'ta': 'தாமத பூஞ்சனம்',
      'mr': 'उशीरा खवळ',
    },
    'septoria_leaf_blotch': {
      'en': 'Septoria Leaf Blotch',
      'hi': 'सेप्टोरिया पत्ती धब्बा',
      'ta': 'செப்டோரியா இலை பятผnา',
      'mr': 'सेप्टोरिया पान डाग',
    },
    'healthy': {
      'en': 'Healthy',
      'hi': 'स्वस्थ',
      'ta': 'ஆரோக்கியமான',
      'mr': 'आरोग्य',
    },

    // ========== DISEASE SEVERITY ==========
    'severity_low': {'en': 'Low', 'hi': 'कम', 'ta': 'குறைந்த', 'mr': 'कमी'},
    'severity_medium': {
      'en': 'Medium',
      'hi': 'मध्यम',
      'ta': 'நடுத்தர',
      'mr': 'मध्यम',
    },
    'severity_high': {'en': 'High', 'hi': 'अधिक', 'ta': 'அதிக', 'mr': 'जास्त'},

    // ========== TREATMENTS ==========
    'treatment_water': {
      'en': 'Reduce watering',
      'hi': 'सिंचाई कम करें',
      'ta': 'நீர் ஊற்றுதல் குறைக்கவும்',
      'mr': 'पाणी देणे कमी करा',
    },
    'treatment_fungicide': {
      'en': 'Apply fungicide',
      'hi': 'कवकनाशी लगाएं',
      'ta': 'பூஞ்சன மருந்து தடவவும்',
      'mr': 'बुरशिक लागू करा',
    },
    'treatment_pesticide': {
      'en': 'Use pesticide',
      'hi': 'कीटनाशक का उपयोग करें',
      'ta': 'பூச்சி மருந்து பயன்படுத்தவும்',
      'mr': 'कीटकनाशकाचा वापर करा',
    },
    'treatment_pruning': {
      'en': 'Prune affected leaves',
      'hi': 'प्रभावित पत्तियों को काटें',
      'ta': 'பாதிக்கப்பட்ட இலைகளை வெட்டவும்',
      'mr': 'प्रभावित पान कापून टाका',
    },
    'treatment_ventilation': {
      'en': 'Improve air circulation',
      'hi': 'हवा का संचार बढ़ाएं',
      'ta': 'காற்று சுழற்சியை மேம்படுத்தவும்',
      'mr': 'हवेचा संचार सुधारा',
    },
    'treatment_rotation': {
      'en': 'Practice crop rotation',
      'hi': 'फसल चक्र अपनाएं',
      'ta': 'பயிர் சுழற்சி பயிற்சி செய்யவும்',
      'mr': 'पिक रोटेशन अभ्यास करा',
    },

    // ========== RECOMMENDATIONS ==========
    'recommendation_isolate': {
      'en': 'Isolate infected plants',
      'hi': 'संक्रमित पौधों को अलग करें',
      'ta': 'பாதிக்கப்பட்ட தாவரங்களை தனிமைப்படுத்தவும்',
      'mr': 'संक्रमित वनस्पती वेगळे करा',
    },
    'recommendation_monitor': {
      'en': 'Monitor daily',
      'hi': 'रोज़ निगरानी करें',
      'ta': 'தினமும் கண்காணிக்கவும்',
      'mr': 'दररोज नियंत्रण करा',
    },
    'recommendation_drainage': {
      'en': 'Improve drainage',
      'hi': 'जल निकासी में सुधार करें',
      'ta': 'வடிகால் மேம்படுத்தவும்',
      'mr': 'ड्रेनेज सुधारा',
    },

    // ========== CROPS ==========
    'rice': {'en': 'Rice', 'hi': 'चावल', 'ta': 'அரிசி', 'mr': 'तांदूळ'},
    'wheat': {'en': 'Wheat', 'hi': 'गेहूं', 'ta': 'கோதுமை', 'mr': 'गहू'},
    'maize': {'en': 'Maize', 'hi': 'मक्का', 'ta': '玉米', 'mr': 'मक्का'},
    'cotton': {'en': 'Cotton', 'hi': 'कपास', 'ta': 'பருத்தி', 'mr': 'कपूस'},
    'potato': {
      'en': 'Potato',
      'hi': 'आलू',
      'ta': 'உருளைக்கிழங்கு',
      'mr': 'बटाटा',
    },
    'tomato': {'en': 'Tomato', 'hi': 'टमाटर', 'ta': 'தக்காளி', 'mr': 'टोमॅटो'},
    'onion': {'en': 'Onion', 'hi': 'प्याज़', 'ta': 'வெங்காயம்', 'mr': 'कांदा'},

    // ========== WEATHER ==========
    'weather_sunny': {'en': 'Sunny', 'hi': 'धूप', 'ta': 'வெயிலான', 'mr': 'धूप'},
    'weather_rainy': {'en': 'Rainy', 'hi': 'बारिश', 'ta': 'மழை', 'mr': 'पाऊस'},
    'weather_cloudy': {
      'en': 'Cloudy',
      'hi': 'बादल',
      'ta': 'மேகமூட்டம்',
      'mr': 'ढग',
    },
    'weather_humidity_high': {
      'en': 'High humidity',
      'hi': 'अधिक नमी',
      'ta': 'அதிக ஈரப்பதம்',
      'mr': 'जास्त दमछत्र',
    },

    // ========== ACTIONS ==========
    'action_water': {
      'en': 'Water your fields',
      'hi': 'अपने खेतों को पानी दें',
      'ta': 'உங்கள் வயல்களுக்கு நீர் ஊற்றவும்',
      'mr': 'आपल्या शेतांना पाणी द्या',
    },
    'action_check': {
      'en': 'Check for diseases',
      'hi': 'रोगों की जांच करें',
      'ta': 'நோய்களைப் பরிசோதிக்கவும்',
      'mr': 'रोगांची तपासणी करा',
    },
    'action_fertilize': {
      'en': 'Apply fertilizer',
      'hi': 'खाद डालें',
      'ta': 'உரத்தைப் பயன்படுத்தவும்',
      'mr': 'खत लागू करा',
    },
    'action_harvest': {
      'en': 'Ready to harvest',
      'hi': 'कटाई के लिए तैयार',
      'ta': 'அறுவடைக்கு தயாராக',
      'mr': 'कापणीसाठी तयार',
    },

    // ========== STATUS ==========
    'status_online': {
      'en': 'Online',
      'hi': 'ऑनलाइन',
      'ta': 'இணையத்தில்',
      'mr': 'ऑनलाइन',
    },
    'status_offline': {
      'en': 'Offline',
      'hi': 'ऑफलाइन',
      'ta': 'இணையத்திற்கு வெளியே',
      'mr': 'ऑफलाइन',
    },
    'status_syncing': {
      'en': 'Syncing...',
      'hi': 'सिंक हो रहा है...',
      'ta': 'ஒத்திசைக்கிறது...',
      'mr': 'सिंक होत आहे...',
    },
    'status_sync_complete': {
      'en': 'Sync complete',
      'hi': 'सिंक पूर्ण',
      'ta': 'ஒத்திசை முடிந்துவிட்டது',
      'mr': 'सिंक पूर्ण',
    },

    // ========== TIME ==========
    'time_updated': {
      'en': 'Last updated',
      'hi': 'अंतिम अपडेट',
      'ta': 'கடைசி புதுப்பிக்கப்பட்டது',
      'mr': 'शेवटचा अपडेट',
    },
    'time_hours_ago': {
      'en': 'hours ago',
      'hi': 'घंटे पहले',
      'ta': 'மணிநேரம் முன்',
      'mr': 'तास पूर्वी',
    },
    'time_days_ago': {
      'en': 'days ago',
      'hi': 'दिन पहले',
      'ta': 'நாட்கள் முன்',
      'mr': 'दिवस पूर्वी',
    },

    // ========== ERRORS ==========
    'error_no_internet': {
      'en': 'No internet connection',
      'hi': 'कोई इंटरनेट कनेक्शन नहीं',
      'ta': 'இணையத்துக்கான இணைப்பு இல்லை',
      'mr': 'इंटरनेट जोडणी नाही',
    },
    'error_offline_mode': {
      'en': 'Using cached data',
      'hi': 'कैश्ड डेटा का उपयोग कर रहे हैं',
      'ta': 'தற்காலிக சேமிப்பு தரவுப் பயன்படுத்துகிறது',
      'mr': 'कॅश केलेला डेटा वापरत आहे',
    },
    'error_data_stale': {
      'en': 'Data is outdated',
      'hi': 'डेटा पुराना है',
      'ta': 'தரவு பழைமையாக உள்ளது',
      'mr': 'डेटा जुना आहे',
    },
  };

  /// Translate a key to specified language
  /// Returns the key if translation not found (fallback)
  static String translate(String key, String language) {
    try {
      // Default to English if language not available
      if (!['en', 'hi', 'ta', 'mr'].contains(language)) {
        language = 'en';
      }

      // Get translation or fallback to key
      return _translations[key]?[language] ?? key;
    } catch (e) {
      return key; // Fallback to key if error
    }
  }

  /// Get all translations for a key (for UI language selector)
  static Map<String, String>? getAll(String key) {
    return _translations[key];
  }

  /// Get available languages
  static List<String> getAvailableLanguages() => ['en', 'hi', 'ta', 'mr'];

  /// Get language names
  static Map<String, String> getLanguageNames() => {
    'en': 'English',
    'hi': 'हिंदी',
    'ta': 'தமிழ்',
    'mr': 'मराठी',
  };
}
