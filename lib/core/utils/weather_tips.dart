import 'package:flutter/material.dart';

class WeatherTips {
  static String getTip(int conditionId, double temp, Locale locale) {
    final lang = locale.languageCode;

    // Severe Weather - Thunderstorms
    if (conditionId >= 200 && conditionId < 300) {
      if (conditionId >= 210 && conditionId <= 212) {
        if (lang == 'am') return "ከባድ የነጎድጓድ ዝናብ! የኤሌክትሪክ እቃዎችን ያላቅቁ፣ ከመስኮት ይራቁ እና ደህንነቱ በተጠበቀ መጠለያ ውስጥ ይቆዩ። ⚡⛈️🛑";
        if (lang == 'om') return "Babbakakkaa jabaa! Meeshaalee elektirooniksii irraa of eeggadhaa, foddaa irraa fagaadhaa fi iddoo nageenya qabu turaa. ⚡⛈️🛑";
        return "Severe thunderstorm! Disconnect appliances, stay away from windows, and remain in a safe shelter. ⚡⛈️🛑";
      }
      if (conditionId >= 230 && conditionId <= 232) {
        if (lang == 'am') return "ከባድ ነጎድጓድ ከካፊያ ጋር። ምንም እንኳን ቀላል ዝናብ ቢሆንም በመብረቅ ምክንያት ጥንቃቄ ያድርጉ። ⛈️⚡";
        if (lang == 'om') return "Babbakakkaa fi bifa tifii. Roobni salphaa ta'us balaa babbakakkaa irraa of eeggadhaa. ⛈️⚡";
        return "Thunderstorm with drizzle. Even if rain is light, be cautious of lightning strikes. ⛈️⚡";
      }
      if (lang == 'am') return "የነጎድጓድ ማስጠንቀቂያ! ቤት ውስጥ ይቆዩ፣ የኤሌክትሮኒክስ መሳሪያዎችን ከመጠቀም ይቆጠቡ እና የብረት እቃዎችን አይንኩ። ⚡🏠";
      if (lang == 'om') return "Akeekkachiisa babbakakkaa! Mana keessa turaa, meeshaalee elektirooniksii fayyadamuu dhiisaa. ⚡🏠";
      return "Thunderstorm warning! Stay indoors, avoid using electronic devices, and keep away from metal objects. ⚡🏠";
    }

    // Rain & Drizzle
    if (conditionId >= 300 && conditionId < 600) {
      if (conditionId >= 300 && conditionId < 400) {
        if (lang == 'am') return "ቀላል ካፊያ። ለእግር ጉዞ ጥሩ ቢሆንም ቀለል ያለ ጃኬት ወይም ጃንጥላ ይያዙ። 🌦️🚶";
        if (lang == 'om') return "Tifii salphaa. Miillaan deemuuf gaariidha garuu jaakkeetii salphaa qabadhaa. 🌦️🚶";
        return "Light drizzle. Good for a walk but keep a light jacket or umbrella handy. 🌦️🚶";
      }
      if (conditionId >= 500 && conditionId <= 501) {
        if (lang == 'am') return "ቀላል ዝናብ! አዝመራ ለሚሰበስቡ አርሶ አደሮች መልካም አጋጣሚ ሊሆን ይችላል። 🌦️🌾";
        if (lang == 'om') return "Rooba salphaa! Qonnaan bultootaaf yeroo gaarii ta'uu danda'a. 🌦️🌾";
        return "Light rain! It could be a good opportunity for farmers and crops. 🌦️🌾";
      }
      if (conditionId >= 502 && conditionId <= 504) {
        if (lang == 'am') return "በጣም ከባድ ዝናብ! የጎርፍ መጥለቅለቅ አደጋ ስላለ ከወንዞች ይራቁ እና በጥንቃቄ ያሽከርክሩ። 🌊☔🚫";
        if (lang == 'om') return "Rooba baay'ee jabaa! Balaa lolaa irraa of eeggadhaa, laggeen irraa fagaadhaa. 🌊☔🚫";
        return "Extremely heavy rain! High flood risk—stay away from riverbanks and drive with extreme caution. 🌊☔🚫";
      }
      if (conditionId == 511) {
        if (lang == 'am') return "ቀዝቃዛ እና የሚያቀዘቅዝ ዝናብ! መንገዶች በጣም የሚያዳልጡ እና አደገኛ ስለሚሆኑ አይጓዙ። 🧊🧥⚠️";
        if (lang == 'om') return "Rooba qabbanaawaa fi mucucaatu! Daandiin baay'ee balaa qaba, of eeggannoo guddaa godhaa. 🧊🧥⚠️";
        return "Freezing rain! Roads are extremely slippery and dangerous. Avoid unnecessary travel. 🧊🧥⚠️";
      }
      if (conditionId >= 520 && conditionId <= 531) {
        if (lang == 'am') return "ኃይለኛ የዝናብ ናዳ! በፍጥነት የሚመጣ ዝናብ ስለሆነ መጠለያ ይፈልጉ። 🌧️🏃";
        if (lang == 'om') return "Rooba ariitii jabaa! Daafannoo barbaaddadhaa. 🌧️🏃";
        return "Heavy shower rain! Sudden downpours expected—find shelter quickly. 🌧️🏃";
      }
      if (lang == 'am') return "ዝናባማ የአየር ሁኔታ! ጃንጥላዎን አይርሱ፣ ውሃ የማይገባ ጫማ ያድርጉ እና ጉዞዎን አስቀድመው ያቅዱ። ☔🚗";
      if (lang == 'om') return "Haala qilleensa roobaa! Dibbee keessan hin dagatinaa, kophee bishaan hin galchine uffadhaa. ☔🚗";
      return "Rainy weather! Don't forget your umbrella, wear waterproof shoes, and plan your commute ahead. ☔🚗";
    }

    // Snow & Hail
    if (conditionId >= 600 && conditionId < 700) {
      if (conditionId >= 611 && conditionId <= 616) {
        if (lang == 'am') return "የበረዶ ዝናብ (Sleet)! መንገዶች ላይ ዝልግልግ በረዶ ስለሚኖር ጥንቃቄ ያድርጉ። 🌨️🧊";
        if (lang == 'om') return "Rooba cabbii maku! Daandiin mucucaachuu danda'a, of eeggadhaa. 🌨️🧊";
        return "Sleet! Slushy conditions on roads—be careful while walking or driving. 🌨️🧊";
      }
      if (conditionId == 602 || conditionId == 622) {
        if (lang == 'am') return "በጣም ከባድ በረዶ! የኤሌክትሪክ መቆራረጥ ሊኖር ስለሚችል ዝግጁ ይሁኑ እና ቤት ውስጥ ይቆዩ። ❄️🏠🕯️";
        if (lang == 'om') return "Cabbii baay'ee jabaa! Mana keessa turaa, ibsaan baduu danda'a waan ta'eef of qopheessaa. ❄️🏠🕯️";
        return "Heavy snow/hail! Prepare for possible power outages and stay safely indoors. ❄️🏠🕯️";
      }
      if (lang == 'am') return "በረዶ ሊኖር ይችላል! ቅዝቃዜው ስለሚበረታ የሱፍ ልብሶችን ይልበሱ እና ትኩስ መጠጥ ይውሰዱ። ❄️🧣☕";
      if (lang == 'om') return "Cabbii ta'uu danda'a! Uffata ho'aa uffadhaa, dhugaatii ho'aa dhugaa. ❄️🧣☕";
      return "Snow or Hail possible! Wear woolens to stay warm and enjoy a hot beverage. ❄️🧣☕";
    }

    // Atmosphere (Mist, Fog, Dust)
    if (conditionId >= 700 && conditionId < 800) {
      if (conditionId == 701 || conditionId == 741) {
        if (lang == 'am') return "ከባድ ጭጋግ! ታይነቱ በጣም አነስተኛ ስለሆነ ፍጥነትዎን ይቀንሱ እና የጭጋግ መብራት ያብሩ። 🌫️🚗🔦";
        if (lang == 'om') return "Hurrii jabaa! Arguun baay'ee rakkisaadha, suuta jedhaa ibsaa fayyadamaa. 🌫️🚗🔦";
        return "Dense fog! Visibility is very low—reduce speed and use fog lights. 🌫️🚗🔦";
      }
      if (conditionId == 711) {
        if (lang == 'am') return "ጢስ በአካባቢው አለ። የመተንፈሻ ችግር ካለብዎ ቤት ውስጥ ይቆዩ እና መስኮቶችን ይዝጉ። 💨🏠";
        if (lang == 'om') return "Aariin naannoo jira. Rakkoo hafuuraa yoo qabaattan mana keessa turaa. 💨🏠";
        return "Smoke in the air. If you have respiratory issues, stay indoors and keep windows closed. 💨🏠";
      }
      if (conditionId == 721) {
        if (lang == 'am') return "ዱም (Haze) አለ። ፀሐይ ብሩህ ላይመስል ይችላል፤ ለዓይን ጥንቃቄ ያድርጉ። 🌫️🕶️";
        if (lang == 'om') return "Duumessa gadi bu'aa (Haze). Aduun baay'ee hin mul'attu, ija keessan eeggadhaa. 🌫️🕶️";
        return "Haze. The sun might look dim; consider wearing sunglasses for eye protection. 🌫️�️";
      }
      if (conditionId == 731 || conditionId == 751 || conditionId == 761) {
        if (lang == 'am') return "አቧራማ ነፋስ! ዓይንዎን እና ሳንባዎን ለመጠበቅ ማስክ እና መነጽር ያድርጉ። 😷🌪️🕶️";
        if (lang == 'om') return "Bubbee awwaaraa! Maaskii fi madiitii fayyadamaa ija keessan eeggachuuf. 😷🌪️🕶️";
        return "Dust or sand storm! Wear a mask and goggles to protect your eyes and lungs. 😷🌪️🕶️";
      }
      if (conditionId == 781) {
        if (lang == 'am') return "አውሎ ነፋስ (Tornado) ማስጠንቀቂያ! በአስቸኳይ ወደ አስተማማኝ መጠለያ ይሂዱ። 🌪️🚨";
        if (lang == 'om') return "Akeekkachiisa Obomboleettii! Hatattamaan bakka nagaa barbaaddadhaa. 🌪️🚨";
        return "Tornado warning! Seek underground or reinforced shelter immediately. 🌪️🚨";
      }
      if (lang == 'am') return "የአየር ሁኔታ እይታ ላይ ተጽዕኖ ሊያሳድር ይችላል። በሚያሽከረክሩበት ጊዜ ከፍተኛ ጥንቃቄ ያድርጉ። 🌫️🚨";
      if (lang == 'om') return "Haalli qilleensaa arguu irratti dhiibbaa qabaachuu danda'a. Of eeggannoo guddaa godhaa. 🌫️🚨";
      return "Atmospheric conditions may affect visibility. Use extreme caution while traveling. 🌫️🚨";
    }

    // Clear & Cloudy
    if (conditionId == 800) {
      if (temp > 38) {
        if (lang == 'am') return "ከፍተኛ የሙቀት ማዕበል! ከቤት አይውጡ፣ በቂ ውሃ ይጠጡ እና ቀዝቃዛ ቦታ ይቆዩ። ☀️🔥🆘";
        if (lang == 'om') return "Ho'a guddaa addaa! Mana keessa turaa, bishaan baay'ee dhugaa. ☀️🔥🆘";
        return "Extreme Heat Wave! Stay indoors, hydrate constantly, and use fans/cooling. ☀️🔥🆘";
      }
      if (temp > 32) {
        if (lang == 'am') return "በጣም ሞቃታማ ፀሐይ! ለረጅም ጊዜ ለፀሐይ አይጋለጡ እና ጥላ ይፈልጉ። ☀️👒💦";
        if (lang == 'om') return "Aduu jabaa! Aduu jala hin turinaa, gaaddisa barbaaddadhaa. ☀️👒💦";
        return "Very hot sun! Avoid prolonged sun exposure and seek shade. ☀️👒💦";
      }
      if (temp > 25) {
        if (lang == 'am') return "ሙቅ እና ፀሐያማ! ለልብስ ማጠብ ወይም ለቤት ውጭ ስራዎች በጣም አመቺ ነው። 👕🌞🧺";
        if (lang == 'om') return "Ho'aa fi aduu! Hojii alaa ykn uffata miiccuuf guyyaa baay'ee gaariidha. 👕🌞🧺";
        return "Warm and sunny! Excellent for laundry, gardening, or outdoor chores. 👕🌞🧺";
      }
      if (temp > 20) {
        if (lang == 'am') return "በጣም ደስ የሚል የአየር ሁኔታ! ከቤተሰብ ወይም ከጓደኛ ጋር ለሽርሽር ይውጡ። ☀️🧺🌳";
        if (lang == 'om') return "Haala qilleensaa baay'ee namatti tolu! Maatii fi michoota waliin bashannanuuf gaariidha. ☀️🧺🌳";
        return "Perfect mild weather! Great for a picnic or a stroll with friends. ☀️🧺🌳";
      }
      if (temp > 15) {
        if (lang == 'am') return "ደስ የሚል አየር። ለእግር ጉዞ ወይም ለስፖርት ተስማሚ ጊዜ ነው። ☀️🏃‍♂️";
        if (lang == 'om') return "Qilleensa gaarii. Sosso'uuf ykn ispoortii hojjechuuf yeroo gaariidha. ☀️🏃‍♂️";
        return "Pleasant air. Ideal for a walk or outdoor exercise. ☀️🏃‍♂️";
      }
      if (temp > 10) {
        if (lang == 'am') return "አሪፍ አየር። ለመጓዝ ወይም ለቀላል እንቅስቃሴዎች ጥሩ ነው። ☀️👟";
        if (lang == 'om') return "Qilleensa madaalawaa. Deemsaaf ykn socho'uuf gaariidha. ☀️👟";
        return "Cool air. Good for traveling or light activities. ☀️👟";
      }
      if (temp < 0) {
        if (lang == 'am') return "ከዜሮ በታች ቅዝቃዜ! የውሃ ቧንቧዎች እንዳይቀዘቅዙ ጥንቃቄ ያድርጉ እና ይሞቁ። 🥶🧤❄️";
        if (lang == 'om') return "Qabbana digrii zeeroo gadii! Of ho'isaa, akka hin qabbanoofne of eeggadhaa. 🥶🧤❄️";
        return "Freezing below zero! Protect water pipes and keep yourself bundled up. 🥶🧤❄️";
      }
      if (temp < 10) {
        if (lang == 'am') return "በጣም ቅዝቃዜ! ወፍራም ጃኬት፣ ጓንት እና ካልሲ መጠቀምዎን አይርሱ። 🧣🧥☕";
        if (lang == 'om') return "Baay'ee qabbanaawaa! Jaakkeetii furdaa, kofiyaa fi uffata ho'aa fayyadamaa. 🧣🧥☕";
        return "Very cold! Don't forget your heavy jacket, gloves, and warm socks. 🧣🧥☕";
      }
      if (lang == 'am') return "ጠራ ያለ ሰማይ! ለጉዞ፣ ለፎቶግራፍ ወይም ለቤት ውጭ ስፖርት ተስማሚ ቀን ነው። 🌳📸🏃";
      if (lang == 'om') return "Samii qulqulluu! Adeemsa fagoo ykn ispoortii alaa hojjechuuf guyyaa gaariidha. 🌳📸🏃";
      return "Clear skies! Perfect day for travel, photography, or outdoor sports. 🌳📸🏃";
    }

    if (conditionId == 801 || conditionId == 802) {
      if (temp > 30) {
        if (lang == 'am') return "በከፊል ደመናማ እና በጣም ሞቃት። ፈሳሽ በብዛት ይጠጡ። ⛅🥤";
        if (lang == 'om') return "Duumessa muraasaa fi ho'aa jabaa. Bishaan baay'ee dhugaa. ⛅🥤";
        return "Partly cloudy and very hot. Keep yourself hydrated. ⛅🥤";
      }
      if (temp > 25) {
        if (lang == 'am') return "በከፊል ደመናማ እና ሙቅ። ለመጓዝ ወይም ለገበያ ለመውጣት ጥሩ ነው። ⛅🛍️";
        if (lang == 'om') return "Duumessa muraasaa fi ho'aa. Deemsaaf ykn gabaa deemuuf gaariidha. ⛅🛍️";
        return "Partly cloudy and warm. Good for traveling or going shopping. ⛅🛍️";
      }
      if (temp > 20) {
        if (lang == 'am') return "በከፊል ደመናማ እና ደስ የሚል አየር። ለቤት ውጭ ስራዎች ምቹ ነው። ⛅🛠️";
        if (lang == 'om') return "Duumessa muraasaa fi qilleensa gaarii. Hojii alaaf mijataadha. ⛅🛠️";
        return "Partly cloudy and pleasant air. Suitable for outdoor tasks. ⛅🛠️";
      }
      if (temp < 18) {
        if (lang == 'am') return "ቀዝቃዛ ነፋሻማ እና በከፊል ደመናማ። ሻይ ወይም ቡና እየጠጡ ስራዎን ያከናውኑ። ⛅🧥☕";
        if (lang == 'om') return "Qabbanaawaa fi duumessa muraasa. Shaayii ykn buna dhugaa hojii keessan hojjedhaa. ⛅🧥☕";
        return "Cool and partly cloudy. Enjoy your work with a cup of tea or coffee. ⛅🧥☕";
      }
      if (lang == 'am') return "በከፊል ደመናማ። ለስራ እና ለእንገስቃሴ የሚሆን ቆንጆ እና መካከለኛ የአየር ሁኔታ። ⛅✨";
      if (lang == 'om') return "Duumessa muraasa. Hojii fi socho'uuf guyyaa madaalawaa fi gaariidha. ⛅✨";
      return "Partly cloudy. A pleasant and moderate day for work and movement. ⛅✨";
    }

    if (conditionId > 802) {
      if (temp > 30) {
        if (lang == 'am') return "ደመናማ እና በጣም ሞቃት። ከቤት ውጭ ከባድ ስራ አይስሩ። ☁️🥵";
        if (lang == 'om') return "Duumessaa fi ho'aa jabaa. Hojii alaa jabaa hin hojjetinaa. ☁️🥵";
        return "Cloudy and very hot. Avoid heavy outdoor physical work. ☁️🥵";
      }
      if (temp > 25) {
        if (lang == 'am') return "ደመናማ እና ሙቅ። በቂ አየር ወዳለበት ቦታ ይሂዱ። ☁️💨";
        if (lang == 'om') return "Duumessaa fi ho'aa. Bakka qilleensa gaarii qabu turaa. ☁️💨";
        return "Cloudy and warm. Stay in a well-ventilated area. ☁️💨";
      }
      if (temp > 20) {
        if (lang == 'am') return "ደመናማ እና መካከለኛ አየር። ለቤት ውስጥ ስራዎች ምቹ ነው። ☁️🏠";
        if (lang == 'om') return "Duumessaa fi qilleensa madaalawaa. Hojii mana keessaaf mijataadha. ☁️🏠";
        return "Cloudy and moderate air. Comfortable for indoor chores. ☁️🏠";
      }
      if (temp < 15) {
        if (lang == 'am') return "ቀዝቃዛ እና ደመናማ። ለቆንጆ የኢትዮጵያ ቡና ስርዓት እና ለቤት ውስጥ ጨዋታ ተስማሚ ጊዜ ነው። ☕🇪🇹🎲";
        if (lang == 'om') return "Qabbanaawaa fi duumessa. Sirna Buna Itoophiyaa fi taphoota mana keessaaf yeroo gaariidha. ☕🇪🇹🎲";
        return "Chilly and cloudy. Ideal for a traditional Ethiopian coffee ceremony and indoor games. ☕🇪🇹🎲";
      }
      if (lang == 'am') return "ደመናማ ቀን። ለንባብ ወይም ለቤት ውስጥ ስራዎች ምቹ የአየር ሁኔታ ነው። ☁️📚";
      if (lang == 'om') return "Guyyaa duumessaa. Kitaaba dubbisuuf ykn hojii mana keessaaf haala gaariidha. ☁️📚";
      return "Cloudy day. Comfortable weather for reading or indoor activities. ☁️📚";
    }

    if (lang == 'am') return "መልካም ቀን ይሁንልዎ! በቆንጆዋ ኢትዮጵያ በሰላም ይቆዩ! 🇪🇹";
    if (lang == 'om') return "Guyyaa gaarii isiniif haa ta'u! Itoophiyaa miidhagduu keessatti nagaaan turaa! 🇪🇹";
    return "Enjoy your day and stay safe in beautiful Ethiopia! 🇪🇹";
  }
}
