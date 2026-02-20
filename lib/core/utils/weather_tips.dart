import 'package:flutter/material.dart';

class WeatherTips {
  static String getTip(int conditionId, double temp, Locale locale) {
    final lang = locale.languageCode;

    if (lang == 'am') {
      return _getAmharicTip(conditionId, temp);
    } else if (lang == 'om') {
      return _getOromoTip(conditionId, temp);
    } else {
      return _getEnglishTip(conditionId, temp);
    }
  }

  static String _getEnglishTip(int conditionId, double temp) {
    if (conditionId >= 200 && conditionId < 300) {
      return "Thunderstorm warning! Stay indoors and avoid using electronic devices. ⚡";
    }
    if (conditionId >= 500 && conditionId < 600) {
      return "Rainy weather! Don't forget your umbrella and wear waterproof shoes. ☔";
    }
    if (conditionId >= 600 && conditionId < 700) {
      return "Snow/Hail possible! Drive carefully and stay warm. ❄️";
    }
    if (temp > 32) {
      return "Extreme heat! Stay hydrated, wear light clothing, and avoid direct sun. ☀️";
    }
    if (temp > 28) {
      return "It's getting warm. Drink plenty of water and seek shade when possible. 💧";
    }
    if (temp < 12) {
      return "Very cold! Wear a heavy jacket, scarf, and gloves to stay warm. 🧣";
    }
    if (temp < 18) {
      return "Cool breeze. A light sweater or jacket would be perfect. 🧥";
    }
    if (conditionId == 800) {
      return "Clear skies! Great day for outdoor activities. 🌳";
    }
    if (conditionId > 800) {
      return "Cloudy day. Good weather for a nice cup of Ethiopian coffee. ☕";
    }
    return "Enjoy your day and stay safe in beautiful Ethiopia! 🇪🇹";
  }

  static String _getAmharicTip(int conditionId, double temp) {
    if (conditionId >= 200 && conditionId < 300) {
      return "የነጎድጓድ ማስጠንቀቂያ! ቤት ውስጥ ይቆዩ እና የኤሌክትሮኒክስ መሳሪያዎችን ከመጠቀም ይቆጠቡ። ⚡";
    }
    if (conditionId >= 500 && conditionId < 600) {
      return "ዝናባማ የአየር ሁኔታ! ጃንጥላዎን አይርሱ እና ውሃ የማይገባ ጫማ ያድርጉ። ☔";
    }
    if (conditionId >= 600 && conditionId < 700) {
      return "በረዶ ሊኖር ይችላል! በጥንቃቄ ያሽከርክሩ እና ይሞቁ። ❄️";
    }
    if (temp > 32) {
      return "ከፍተኛ ሙቀት! በቂ ውሃ ይጠጡ፣ ቀላል ልብስ ይልበሱ እና በቀጥታ ከፀሐይ ብርሃን ይራቁ። ☀️";
    }
    if (temp > 28) {
      return "አየሩ እየሞቀ ነው። በቂ ውሃ ይጠጡ እና በሚቻልበት ጊዜ በጥላ ስር ይሁኑ። 💧";
    }
    if (temp < 12) {
      return "በጣም ቀዝቃዛ! ለመሞቅ ወፍራም ጃኬት፣ ሻርፕ እና ጓንት ያድርጉ። 🧣";
    }
    if (temp < 18) {
      return "ቀዝቃዛ ነፋስ። ቀላል ሹራብ ወይም ጃኬት ቢለብሱ ይመረጣል። 🧥";
    }
    if (conditionId == 800) {
      return "ጠራ ያለ ሰማይ! ለውጭ እንቅስቃሴዎች ጥሩ ቀን ነው። 🌳";
    }
    if (conditionId > 800) {
      return "ደመናማ ቀን። ለቆንጆ የኢትዮጵያ ቡና ተስማሚ የአየር ሁኔታ ነው። ☕";
    }
    return "መልካም ቀን ይሁንልዎ! በቆንጆዋ ኢትዮጵያ በሰላም ይቆዩ! 🇪🇹";
  }

  static String _getOromoTip(int conditionId, double temp) {
    if (conditionId >= 200 && conditionId < 300) {
      return "Akeekkachiisa babbakakkaa! Mana keessa turaa, meeshaalee elektirooniksii fayyadamuu dhiisaa. ⚡";
    }
    if (conditionId >= 500 && conditionId < 600) {
      return "Haala qilleensa roobaa! Dibbee keessan hin dagatinaa, kophee bishaan hin galchine uffadhaa. ☔";
    }
    if (conditionId >= 600 && conditionId < 700) {
      return "Cabbii ta'uu danda'a! Of-eeggannoon konkolaachisaa, ho'ifadhaa. ❄️";
    }
    if (temp > 32) {
      return "Ho'a guddaa! Bishaan gahaa dhugaa, uffata salphaa uffadhaa, aduu irraa fagaadhaa. ☀️";
    }
    if (temp > 28) {
      return "Qilleensi ho'aa jira. Bishaan baay'ee dhugaa, gaaddisa barbaadaa. 💧";
    }
    if (temp < 12) {
      return "Baay'ee qabbanaawaa! Jaakkeetii furdaa, kaalsii fi kofiyaa uffadhaa. 🧣";
    }
    if (temp < 18) {
      return "Bubbee qabbanaawaa. Shuraaba salphaa ykn jaakkeetii uffachuun gaariidha. 🧥";
    }
    if (conditionId == 800) {
      return "Samii qulqulluu! Iddoowwan bashannanaa deemuf guyyaa gaariidha. 🌳";
    }
    if (conditionId > 800) {
      return "Guyyaa duumessaa. Buna Itoophiyaa mi'aawaa dhuguuf haala qilleensa gaariidha. ☕";
    }
    return "Guyyaa gaarii isiniif haa ta'u! Itoophiyaa miidhagduu keessatti nagaaan turaa! 🇪🇹";
  }
}
