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
    // Severe Weather - Thunderstorms
    if (conditionId >= 200 && conditionId < 300) {
      if (conditionId == 211 || conditionId == 212) {
        return "Severe thunderstorm! Disconnect appliances and stay away from windows. ⚡⛈️";
      }
      return "Thunderstorm warning! Stay indoors and avoid using electronic devices. ⚡";
    }

    // Rain & Drizzle
    if (conditionId >= 300 && conditionId < 600) {
      if (conditionId >= 502 && conditionId <= 504) {
        return "Heavy rain! Possible flooding in low-lying areas. Drive with extreme caution. 🌊☔";
      }
      if (conditionId == 511) {
        return "Freezing rain! Roads will be extremely slippery. Stay safe! 🧊🧥";
      }
      return "Rainy weather! Don't forget your umbrella and wear waterproof shoes. ☔";
    }

    // Snow & Hail
    if (conditionId >= 600 && conditionId < 700) {
      if (conditionId == 602 || conditionId == 622) {
        return "Heavy snow/hail! Stay indoors if possible and keep warm. ❄️🏠";
      }
      return "Snow or Hail possible! Drive carefully and wear layered clothing. ❄️🧣";
    }

    // Atmosphere (Mist, Fog, Dust)
    if (conditionId >= 700 && conditionId < 800) {
      if (conditionId == 701 || conditionId == 741) {
        return "Low visibility due to fog/mist. Use fog lights while driving. 🌫️🚗";
      }
      if (conditionId == 731 || conditionId == 751 || conditionId == 761) {
        return "Dust or sand in the air. Consider wearing a mask outdoors. 😷🌪️";
      }
      return "Atmospheric conditions may affect visibility. Stay alert. 🌫️";
    }

    // Temperature based tips (Dynamic with Conditions)
    if (temp > 35) {
      return "Dangerously high heat! Drink water every hour and stay in the shade. ☀️🔥";
    }
    if (temp > 30) {
      return "Extreme heat! Wear light linen/cotton clothing and a hat. ☀️🧢";
    }
    if (temp > 25 && conditionId == 800) {
      return "Warm and sunny! Perfect for laundry or a walk in the park. 👕🌳";
    }
    if (temp < 5) {
      return "Freezing temperatures! Protect your plants and stay bundled up. 🥶🧤";
    }
    if (temp < 12) {
      return "Very cold! A heavy jacket and a warm drink are recommended. 🧣☕";
    }
    if (temp < 18) {
      if (conditionId >= 801) {
        return "Cool and cloudy. A light jacket and some hot tea would be nice. 🧥🍵";
      }
      return "Cool breeze. A sweater or light jacket would be perfect. 🧥";
    }

    // Clear & Cloudy
    if (conditionId == 800) {
      return "Clear skies! Great day for outdoor activities or travel. 🌳🚗";
    }
    if (conditionId == 801 || conditionId == 802) {
      return "Partly cloudy. Pleasant weather for a productive day. ⛅✨";
    }
    if (conditionId > 802) {
      return "Cloudy day. Perfect time for a traditional Ethiopian coffee ceremony. ☕🇪🇹";
    }

    return "Enjoy your day and stay safe in beautiful Ethiopia! 🇪🇹";
  }

  static String _getAmharicTip(int conditionId, double temp) {
    // Severe Weather - Thunderstorms
    if (conditionId >= 200 && conditionId < 300) {
      if (conditionId == 211 || conditionId == 212) {
        return "ከባድ የነጎድጓድ ዝናብ! የኤሌክትሪክ እቃዎችን ያላቅቁ እና ከመስኮት ይራቁ። ⚡⛈️";
      }
      return "የነጎድጓድ ማስጠንቀቂያ! ቤት ውስጥ ይቆዩ እና የኤሌክትሮኒክስ መሳሪያዎችን ከመጠቀም ይቆጠቡ። ⚡";
    }

    // Rain & Drizzle
    if (conditionId >= 300 && conditionId < 600) {
      if (conditionId >= 502 && conditionId <= 504) {
        return "ከባድ ዝናብ! የጎርፍ መጥለቅለቅ ሊኖር ስለሚችል በጥንቃቄ ያሽከርክሩ። 🌊☔";
      }
      return "ዝናባማ የአየር ሁኔታ! ጃንጥላዎን አይርሱ እና ውሃ የማይገባ ጫማ ያድርጉ። ☔";
    }

    // Snow & Hail
    if (conditionId >= 600 && conditionId < 700) {
      return "በረዶ ሊኖር ይችላል! በጥንቃቄ ያሽከርክሩ እና ይሞቁ። ❄️🧣";
    }

    // Atmosphere
    if (conditionId >= 700 && conditionId < 800) {
      return "ጭጋጋማ የአየር ሁኔታ። በሚያሽከረክሩበት ጊዜ ጥንቃቄ ያድርጉ። 🌫️🚗";
    }

    // Temperature
    if (temp > 35) {
      return "አደገኛ ከፍተኛ ሙቀት! በየሰዓቱ ውሃ ይጠጡ እና ጥላ ስር ይቆዩ። ☀️🔥";
    }
    if (temp > 30) {
      return "ከፍተኛ ሙቀት! ቀለል ያሉ ልብሶችን ይልበሱ እና ባርኔጣ ያድርጉ። ☀️🧢";
    }
    if (temp < 10) {
      return "በጣም ቅዝቃዜ! ወፍራም ጃኬት ይልበሱ እና ትኩስ ነገር ይጠጡ። 🧣☕";
    }
    if (temp < 18) {
      return "ቀዝቃዛ ነፋስ። ቀለል ያለ ሹራብ ወይም ጃኬት ቢለብሱ ይመረጣል። 🧥";
    }

    // Clear & Cloudy
    if (conditionId == 800) {
      return "ጠራ ያለ ሰማይ! ለውጭ እንቅስቃሴዎች በጣም ጥሩ ቀን ነው። 🌳🚗";
    }
    if (conditionId > 800) {
      return "ደመናማ ቀን። ለቆንጆ የኢትዮጵያ ቡና ተስማሚ የአየር ሁኔታ ነው። ☕🇪🇹";
    }

    return "መልካም ቀን ይሁንልዎ! በቆንጆዋ ኢትዮጵያ በሰላም ይቆዩ! 🇪🇹";
  }

  static String _getOromoTip(int conditionId, double temp) {
    // Severe Weather - Thunderstorms
    if (conditionId >= 200 && conditionId < 300) {
      return "Akeekkachiisa babbakakkaa! Mana keessa turaa, meeshaalee elektirooniksii fayyadamuu dhiisaa. ⚡";
    }

    // Rain & Drizzle
    if (conditionId >= 300 && conditionId < 600) {
      if (conditionId >= 502 && conditionId <= 504) {
        return "Rooba jabaa! Lolaa irraa of eeggadhaa, konkolaachisa keessan suuta jedhaa. 🌊☔";
      }
      return "Haala qilleensa roobaa! Dibbee keessan hin dagatinaa, kophee bishaan hin galchine uffadhaa. ☔";
    }

    // Temperature
    if (temp > 28) {
      return "Ho'a guddaa! Bishaan gahaa dhugaa, uffata salphaa uffadhaa, aduu irraa fagaadhaa. ☀️�";
    }
    if (temp < 12) {
      return "Baay'ee qabbanaawaa! Jaakkeetii furdaa uffadhaa, dhugaatii ho'aa dhugaa. 🧣☕";
    }

    // Clear & Cloudy
    if (conditionId == 800) {
      return "Samii qulqulluu! Iddoowwan bashannanaa deemuf guyyaa gaariidha. 🌳🚗";
    }
    if (conditionId > 800) {
      return "Guyyaa duumessaa. Buna Itoophiyaa mi'aawaa dhuguuf haala qilleensa gaariidha. ☕🇪🇹";
    }

    return "Guyyaa gaarii isiniif haa ta'u! Itoophiyaa miidhagduu keessatti nagaaan turaa! 🇪🇹";
  }
}
