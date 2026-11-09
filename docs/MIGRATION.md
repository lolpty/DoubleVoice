# Migrating from the earlier PXXVoice builds

1. Stop the server. Back up the old plugin folder and JAR.
2. Remove the old PXXVoice JAR from `plugins/`; install only `DoubleVoice-1.0.0-beta.1-universal.jar`.
3. Create `plugins/DoubleVoice/`. Copy the old `config.yml` and `state.yml` there if you want to preserve ports, server identity and player mute/deaf/block preferences. These files remain compatible; missing language settings use their defaults. The old folder can remain as a backup.
4. To get all new English configuration comments, use the included template and transfer your network values. Preserve `state.yml`.
5. Replace permissions `pxxvoice.*` with `doublevoice.*` in your permission manager. The main command is `/doublevoice`, alias `/dv`; the previous `/pxv` alias is not registered.
6. Keep the original server-side SVC and Plasmo Voice JARs removed. Players keep the appropriate client voice mod for their Minecraft version.
7. Restart the server and check `/dv status`, `/dv group` and `/dv language`.

Groups have always been temporary and are not imported across server restarts. New language files are generated under `DoubleVoice/lang`. The plugin does not overwrite or delete the old plugin folder automatically.
