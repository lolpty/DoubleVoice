# Protocol implementation notes

DoubleVoice 1.0 beta contains independent Java implementations of the wire formats below. It does not load the original plugins, their Java APIs, extracted JARs, Kotlin, Netty, Guava or a native Opus library at runtime. The only production compile dependency is the Spigot 1.16.5 API, targeting Java 8 bytecode.

## Simple Voice Chat

- Supported compatibility numbers: **20** (released SVC 2.6.27) and **21** (upstream 2.7.0-pre1 branch for Minecraft 26.3).
- Minecraft channels: `voicechat:request_secret`, `secret`, `states`, `state`, `remove_state`, group channels; client status uses `update_state` for 20 and `client_state` for 21.
- Control strings and byte arrays use Minecraft VarInt lengths and UTF-8.
- UDP starts with `FF`. Server-bound messages include the player UUID (20) or random connection UUID (21), followed by a VarInt-length encrypted payload. Client-bound messages omit that UUID.
- Encryption: AES-128-GCM, a fresh 12-byte IV preceding ciphertext and a 128-bit authentication tag.
- Protocol 20 authenticates with player UUID and session secret, acknowledges, then validates the connection-check exchange from the same endpoint.
- Protocol 21 gives the client a random connection identity, acknowledges authentication with a 16-byte address-bound HMAC cookie, and activates the connection only when that cookie is returned correctly.
- Microphone, positional sound and static group sound preserve Opus bytes and source sequence numbers. Player-state encoding differs between 20 and 21.

Reference implementation inspected for interoperability: [Simple Voice Chat](https://github.com/henkelmax/simple-voice-chat), especially its Bukkit network classes. Tests decode emitted secret/state/audio packets and generate microphone packets using the released **bukkit-2.6.27** binary from [Modrinth](https://modrinth.com/plugin/simple-voice-chat). Those classes are test dependencies only and are not copied into DoubleVoice.

## Plasmo Voice

- Minecraft channel: `plasmo:voice/v2`, with the installed flag channel advertised for client discovery.
- Control payloads use the v2 packet IDs and Java DataInput/DataOutput modified UTF encoding.
- The client supplies an RSA public key. The server sends a random UDP identity and, after UDP establishment, capture settings plus an AES session key encrypted with RSA/PKCS#1 v1.5, as required by the client protocol.
- UDP header: `4E 90 04 E9`, packet type, session secret UUID and timestamp. Ping establishes the endpoint; an existing connection is pinned to that endpoint until timeout/reconnect.
- Audio encryption: AES-CBC/PKCS5Padding, fresh 16-byte IV prefix. DoubleVoice uses a separate AES key for each PV session and re-encrypts forwarded audio for the recipient.
- Capture is 48 kHz / mono / 20 ms Opus; stereo capture is not advertised. Native proximity activation UUID and line UUID derivation are preserved. Shared groups use non-positional `DIRECT` sources and a separate source line.
- Empty/ended streams use the native source-audio-end control packet. Server pings are periodic; client ping replies are not echoed recursively.

Reference sources: [Plasmo Voice protocol module](https://github.com/plasmoapp/plasmo-voice/tree/main/protocol) and [encoding/encryption documentation](https://plasmovoice.com/docs/api/encoding-and-encryption.html). The official **protocol 2.2.0-beta.2** artifact is used only to generate and decode interoperability test traffic; no Plasmo code is present in the runtime JAR.

## Shared server behavior

Group membership, hashed passwords, invitation checks, permissions, mute/deaf, per-player blocks, visibility and proximity are owned by DoubleVoice. The original server APIs are not emulated. Minecraft player identity comes only from the authenticated game connection; public UDP packets cannot create player sessions. Sessions are removed on logout and invalidated when replaced by a new control handshake. Token buckets, sequence windows and bounded IV caches reject recent duplicate audio traffic. Capture counter resets after a quiet gap create a fresh playback source, allowing device changes without breaking audio. This bounded replay protection does not change the security properties of the original client wire formats.

Unit and real-socket tests run on Java 21 against the Bukkit/Spigot 1.16.5 API and exercise protocol-level interoperability. The same suite passes with both Plasmo protocol 2.1.17 and 2.2.0-beta.2 (select with `-PtestPlasmoVersion=2.1.17`). They do not constitute a Minecraft client playback or live Paper integration test. Protocol upgrades outside these formats need a corresponding implementation and test update.
