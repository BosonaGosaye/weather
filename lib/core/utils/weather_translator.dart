import 'package:flutter/material.dart';

class WeatherTranslator {
  static String translateDescription(BuildContext? context, String description, int conditionId, Locale locale) {
    final lang = locale.languageCode;
    if (lang == 'am') {
      // Amharic Translations
      if (conditionId >= 200 && conditionId < 300) return "ነጎድጓድ";
      if (conditionId >= 300 && conditionId < 400) return "ካስማ";
      if (conditionId >= 500 && conditionId < 600) {
        if (conditionId == 500) return "ቀላል ዝናብ";
        if (conditionId == 501) return "መካከለኛ ዝናብ";
        if (conditionId == 502) return "ከባድ ዝናብ";
        if (conditionId == 511) return "ቀዝቃዛ ዝናብ";
        return "ዝናብ";
      }
      if (conditionId >= 600 && conditionId < 700) {
        if (conditionId == 600) return "ቀላል በረዶ";
        if (conditionId == 601) return "በረዶ";
        if (conditionId == 602) return "ከባድ በረዶ";
        return "በረዶ";
      }
      if (conditionId >= 700 && conditionId < 800) {
        if (conditionId == 701) return "ጭጋግ";
        if (conditionId == 711) return "ጢስ";
        if (conditionId == 721) return "ዱም";
        if (conditionId == 741) return "ከባድ ጭጋግ";
        return "ጭጋግ";
      }
      if (conditionId == 800) return "ጠራ ያለ ሰማይ";
      if (conditionId == 801) return "ጥቂት ደመና";
      if (conditionId == 802) return "የተበተነ ደመና";
      if (conditionId == 803) return "ደመናማ";
      if (conditionId == 804) return "ሙሉ በሙሉ ደመናማ";
      return description;
    }

    if (lang == 'om') {
      // Afaan Oromo Translations
      if (conditionId >= 200 && conditionId < 300) {
        if (conditionId == 211) return "Bakakkaa";
        return "Bakakkaa fi Rooba";
      } else if (conditionId >= 300 && conditionId < 400) {
        return "Tiifuu";
      } else if (conditionId >= 500 && conditionId < 600) {
        if (conditionId == 500) return "Rooba xiqqaa";
        if (conditionId == 501) return "Rooba madaalawaa";
        if (conditionId == 502) return "Rooba jabaa";
        if (conditionId == 511) return "Rooba qabbanaawaa";
        return "Rooba";
      } else if (conditionId >= 600 && conditionId < 700) {
        if (conditionId == 600) return "Cabbii xiqqaa";
        return "Cabbii";
      } else if (conditionId >= 700 && conditionId < 800) {
        if (conditionId == 701) return "Hurrii";
        if (conditionId == 711) return "Aarii";
        if (conditionId == 741) return "Hurrii jabaa";
        return "Hurrii";
      } else if (conditionId == 800) {
        return "Aduu qulqulluu";
      } else if (conditionId == 801) {
        return "Duumessa muraasa";
      } else if (conditionId == 802) {
        return "Duumessa faca'e";
      } else if (conditionId == 803) {
        return "Duumessa dammaqe";
      } else if (conditionId == 804) {
        return "Duumessa jabaa";
      }
    }

    return description;
  }

  static String getAllLanguagesDescription(String description, int conditionId) {
    String am = translateDescription(null, description, conditionId, const Locale('am'));
    String om = translateDescription(null, description, conditionId, const Locale('om'));
    
    // Fallback to original description if am or om didn't translate (returned original)
    if (am == description) am = '';
    if (om == description) om = '';

    List<String> parts = [description];
    if (am.isNotEmpty) parts.add(am);
    if (om.isNotEmpty) parts.add(om);

    return parts.join(' / ');
  }
}
