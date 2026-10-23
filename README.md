# Frappe Juste

Entraîneur de frappe multi-claviers (Suisse DE/FR, Allemagne, AZERTY, US) et Compagnon portable pour Windows.

- `app/frappe-juste.html` : l'application (entraînement, caractères cachés, abréviations, progrès), à ouvrir dans un navigateur.
- `companion/FrappeJuste.ahk` : le Compagnon (abréviations, Quick Accent, palette flottante), en AutoHotkey v2, généré depuis l'onglet Abréviations → Exporter.
- `.github/workflows/build.yml` : à chaque push sur `main`, une machine Windows vérifie la syntaxe du script, le compile en `FrappeJuste.exe` et publie une release avec l'exe et la page.

Téléchargement : onglet **Releases**, fichier `FrappeJuste.zip`.
