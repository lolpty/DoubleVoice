# Compatibility and validation

DoubleVoice 1.0.0-beta.1 targets 35 Minecraft release versions from **1.16.5 through 26.3**. The exact list and published Folia subset are in [compatibility.json](../modrinth/compatibility.json), fetched from official version services. Snapshots and pre-releases are not included.

One universal JAR serves Bukkit plugin servers. The Bukkit API baseline is Spigot 1.16.5; every production class targets Java 8 class format 52. New inventory-view APIs and Paper/Folia entity scheduling are resolved at runtime. There are no NMS or CraftBukkit package references, bundled voice plugins, or native audio binaries.

| Server family | Download / routing | Scope |
| --- | --- | --- |
| CraftBukkit / Spigot | Bukkit release entry | Minecraft 1.16.5–26.3 where this server exists |
| Paper / Purpur | Paper/Purpur release entry | Same universal JAR |
| Pufferfish | Paper release entry | Same universal JAR; no separate Modrinth tag |
| Folia | Folia release entry | Only published Folia Minecraft versions, starting at 1.19.4 |
| Canvas | Paper or Folia entry | Bukkit-compatible Canvas; scheduling selected by available API |

This does not promise compatibility with every unknown or privately modified fork. Fabric, Forge, NeoForge, Sponge and proxy-only platforms are outside this plugin's scope.

## Checks performed

The API checker resolves the plugin's **118 Bukkit method/field references** against isolated real API JARs, including exact return descriptors and whether a type is a class or interface. It also checks Java 8 class versions. This catches the `InventoryView` class-to-interface change that a lower `api-version` alone would not solve.

| Checked API | Scope |
| --- | --- |
| Spigot 1.16.5 | Baseline / legacy inventories |
| Spigot 1.17.1 | Java-era boundary |
| Spigot 1.18.2 | Legacy Bukkit family |
| Spigot 1.19.4 | Pre-modern baseline |
| Paper 1.19.4 | First Folia-era API boundary |
| Paper 1.20.4 | Entity scheduler API |
| Paper 1.21.1 | InventoryView interface / AnvilView |
| Paper 1.21.11 | Late 1.21 API |
| Paper 26.3 build 244 | Latest target / Java 25 API |

The platform probe uses each API's actual interfaces with simulated callbacks to verify scheduling, deferred execution, cancellation and anvil property availability. Unit tests also cover old/new anvil-property paths and locale fallback/persistence. Real UDP socket tests use the original clients' protocol serializers for cross-mod forwarding, authentication, groups, passwords, privacy, mute/deaf, blocking and replay handling.

Machine-readable API results are included in [verification/api-results.json](verification/api-results.json).

## Validation limits

These are API and automated protocol tests. No claim is made of live Minecraft playback, successful client GUI operation, or exhaustive execution of every Minecraft/core combination. There are no real gameplay screenshots in this package. Keep the release marked **beta** until the intended live-server combinations are checked.

Before production use, run two real clients with different voice mods and check speech in both directions, same-mod speech, whisper/range, group isolation with a third player nearby, passwords/invitations, group deletion, mute/deaf/block, world changes and reconnects. On Folia/Canvas, check logs for region-thread violations while players are in different regions. Check that anvil input never consumes XP or leaks synthetic items when closed or disconnected. Use full server restarts, not plugin hot reload.

## Java

The plugin's Java 8 bytecode does **not** make a newer Minecraft server run on Java 8. Follow your server's requirements. [Paper's current recommendations](https://docs.papermc.io/paper/getting-started/) are Java 16 for 1.16.5, Java 17 for 1.17–1.19, Java 21 for 1.20–1.21.11 and Java 25 for 26.x. Other cores may differ.

## Client protocols

The supported client wire formats are SVC 20/21 and Plasmo Voice v2. Reference versions are SVC 2.6.27 and PV 2.1.17 / 2.2.0-beta.2. Install the corresponding client mod build for the player's Minecraft version. A Minecraft version label alone is not evidence of support for a different voice protocol generation.
