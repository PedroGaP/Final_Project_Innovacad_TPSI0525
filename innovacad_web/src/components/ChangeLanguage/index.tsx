import useI18n from "@/hooks/useL18N";
import i18next from "i18next";

const ChangeLanguage = () => {
  const { currentLang } = useI18n();

  const toggleLanguage = () => {
    const newLang = currentLang() === "en-EN" ? "pt-PT" : "en-EN";
    i18next.changeLanguage(newLang);
  };

  return (
    <label class="btn btn-ghost btn-circle swap swap-rotate">
      <input
        type="checkbox"
        onChange={() => toggleLanguage()}
        checked={currentLang() === "en-EN"}
      />

      <div class="swap-on">Portugal</div>

      <div class="swap-off">EUA</div>
    </label>
  );
};

export default ChangeLanguage;
