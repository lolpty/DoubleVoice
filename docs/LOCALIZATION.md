# Localization

Bundled catalogs: **English (`en`)**, **Russian (`ru`)** and **Spanish (`es`)**. They cover command replies, group errors, menu titles/buttons/tooltips and input guidance.

`language: auto` follows the Minecraft client language; unsupported languages fall back to `fallback-language: en`. A player can override the server default with `/dv language en`, `/dv language ru`, `/dv language es`, or return to automatic selection with `/dv language auto`. The override is saved in `state.yml`.

On first startup, catalogs are copied to `plugins/DoubleVoice/lang/`. Edit values in these YAML files, keeping their keys. Missing keys use the bundled English fallback. Do not delete the English catalog. Restart after changes.

To add another language, copy `en.yml` to a two-letter code such as `de.yml`, translate its values, set `language.name`, and restart. The new code is added to language Tab completion. Minecraft regional tags such as `ru_ru` or `es_es` select the two-letter catalog. Group names and player names remain unchanged.

Messages use internal tokens instead of translating user-provided text. This allows different regions/players to render their own language concurrently without a global mutable language setting. Native mod settings that belong to SVC/PV remain controlled by those clients.

The protocol source-line brand name “DoubleVoice Groups” is an identifier/display name rather than the plugin command language. It does not translate the voice mods' entire UI.
