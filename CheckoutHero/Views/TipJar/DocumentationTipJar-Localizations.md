# Tip Jar Localizations

Add these strings to your `Localizable.strings` file or String Catalog:

## English (en)

```
/* Tip Jar - Headers and General */
"support_checkout_hero" = "Support CheckoutHero";
"tip_jar_header" = "Buy Me a Coffee ☕";
"tip_jar_description" = "CheckoutHero is free and ad-free. If you find it helpful, consider leaving a tip!";
"tip_jar_footer" = "Tips help fund ongoing development and keep the app free for everyone. Thank you for your support! 💙";

/* Tip Labels */
"tip_small_label" = "Small Tip 🙏";
"tip_medium_label" = "Medium Tip 💙";
"tip_large_label" = "Large Tip 🌟";

/* Tip Descriptions */
"tip_small_description" = "Buy me a coffee";
"tip_medium_description" = "Buy me lunch";
"tip_large_description" = "You're amazing!";

/* Loading and Errors */
"loading_products" = "Loading products...";
"tips_unavailable" = "Tips Unavailable";
"tips_unavailable_description" = "Unable to load tip options. Please check your internet connection and try again.";

/* Thank You Screen */
"thank_you_title" = "Thank You!";
"thank_you_message" = "Your support means the world and helps keep CheckoutHero free and improving. You're awesome! 💙";
"done" = "Done";
```

## Spanish (es) - Optional

```
/* Tip Jar - Headers and General */
"support_checkout_hero" = "Apoyar CheckoutHero";
"tip_jar_header" = "Invítame un Café ☕";
"tip_jar_description" = "CheckoutHero es gratis y sin anuncios. Si te resulta útil, ¡considera dejar una propina!";
"tip_jar_footer" = "Las propinas ayudan a financiar el desarrollo continuo y mantener la aplicación gratis para todos. ¡Gracias por tu apoyo! 💙";

/* Tip Labels */
"tip_small_label" = "Propina Pequeña 🙏";
"tip_medium_label" = "Propina Mediana 💙";
"tip_large_label" = "Propina Grande 🌟";

/* Tip Descriptions */
"tip_small_description" = "Invítame un café";
"tip_medium_description" = "Invítame un almuerzo";
"tip_large_description" = "¡Eres increíble!";

/* Loading and Errors */
"loading_products" = "Cargando productos...";
"tips_unavailable" = "Propinas No Disponibles";
"tips_unavailable_description" = "No se pueden cargar las opciones de propinas. Por favor verifica tu conexión a internet e intenta de nuevo.";

/* Thank You Screen */
"thank_you_title" = "¡Gracias!";
"thank_you_message" = "Tu apoyo significa mucho y ayuda a mantener CheckoutHero gratis y mejorando. ¡Eres genial! 💙";
"done" = "Listo";
```

## French (fr) - Optional

```
/* Tip Jar - Headers and General */
"support_checkout_hero" = "Soutenir CheckoutHero";
"tip_jar_header" = "Offrez-moi un Café ☕";
"tip_jar_description" = "CheckoutHero est gratuit et sans publicité. Si vous le trouvez utile, pensez à laisser un pourboire!";
"tip_jar_footer" = "Les pourboires aident à financer le développement continu et à garder l'application gratuite pour tous. Merci pour votre soutien! 💙";

/* Tip Labels */
"tip_small_label" = "Petit Pourboire 🙏";
"tip_medium_label" = "Pourboire Moyen 💙";
"tip_large_label" = "Grand Pourboire 🌟";

/* Tip Descriptions */
"tip_small_description" = "Offrez-moi un café";
"tip_medium_description" = "Offrez-moi un déjeuner";
"tip_large_description" = "Vous êtes incroyable!";

/* Loading and Errors */
"loading_products" = "Chargement des produits...";
"tips_unavailable" = "Pourboires Indisponibles";
"tips_unavailable_description" = "Impossible de charger les options de pourboire. Veuillez vérifier votre connexion Internet et réessayer.";

/* Thank You Screen */
"thank_you_title" = "Merci!";
"thank_you_message" = "Votre soutien compte énormément et aide à garder CheckoutHero gratuit et en amélioration. Vous êtes génial! 💙";
"done" = "Terminé";
```

---

## How to Add These Strings

### Option 1: Using String Catalog (Recommended for iOS 17+)

1. In Xcode, select your project
2. Go to your app target → Info tab
3. Find "Localizations" and add languages
4. Xcode will create/update a `.xcstrings` file
5. Add the keys and values directly in the String Catalog editor

### Option 2: Using Localizable.strings

1. Create `Localizable.strings` if it doesn't exist:
   - File → New → File → Strings File
   - Name it `Localizable.strings`

2. Add localization:
   - Select the file in Project Navigator
   - Open File Inspector (⌥⌘1)
   - Click "Localize..."
   - Select languages to support

3. Copy the strings for each language into the appropriate file
