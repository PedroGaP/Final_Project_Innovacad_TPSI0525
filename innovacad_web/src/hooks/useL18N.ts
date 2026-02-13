import { createSignal } from "solid-js";
import i18next from "@/utils/i18n";

const [currentLang, setCurrentLang] = createSignal(i18next.language);

i18next.on("languageChanged", (l) => {
  console.log(`i18next changed to: ${l}`);
  setCurrentLang(l);
});

export const useI18n = () => {
  const t = (key: string, options?: any): string => {
    currentLang();
    return i18next.t(key, options).toString();
  };

  return { t, i18next, currentLang };
};

export default useI18n;
