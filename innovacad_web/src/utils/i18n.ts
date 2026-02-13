import i18next from "i18next"
import englishTranslation from "../locale/en-EN.json"
import portugueseTranslation from "../locale/pt-PT.json"

i18next.init({
  lng: "pt-PT",
  fallbackLng: "en-EN",
  resources: {
    "en-EN": { translation: englishTranslation },
    "pt-PT": { translation: portugueseTranslation },
  },
  interpolation: {
    escapeValue: false,
  },
});

export default i18next;
