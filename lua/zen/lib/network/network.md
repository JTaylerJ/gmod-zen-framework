## zen.nt — Network module documentation

This document describes the `nt` small networking layer used by the gmod-zen addon.
It explains how channels are registered and used, the type system for message payloads,
the client pull / ready flow, debug helpers, and common troubleshooting steps.

### Overview

`nt` provides a thin abstraction over Garry's Mod `net` system to:
- Register named channels with numeric ids.
- Provide typed serialization helpers (readers/writers) for many common types.
- Support simple and more advanced channel patterns (simple types, custom writers/readers, public channels that are pushed to clients on join).
- Offer debug logging and a small event system (ihook events like `nt.Receive`, `ReadyForNetwork`).

Core concepts:
- Channel: a named message endpoint. Channels have an id, name, flags and optional types or custom read/write functions.
- Types: an ordered list of human-friendly type names describing payload layout (e.g. `int8`, `string`, `player`, `steamid64`, `array:vector`).
- Public channels: flagged channels that the server will push to clients when they indicate they are ready.

### How it works (quick)

1. Modules register channels via `nt.RegisterChannel(name, flags, data)` or the convenience `nt.SimpleChannel(name, types, callback)`.
2. When sending, code calls `nt.Send(channel_name, types, data, target)` or `nt.SendToChannel(channel_name, target, ...)` which uses the registered types or custom writer to serialize.
3. On the recipient side, registered channels provide reader functions (or `nt` uses the declared `types`) to deserialize payloads and then `ihook.Run("nt.Receive", channel_name, ply, unpacked...)` is executed and the channel's `OnRead` (if present) is invoked.
4. Public channels (flags.PUBLIC) are discovered and pulled by clients when they call the ReadyForNetwork flow.

### Registering channels

nt.RegisterChannel(channel_name, flags, data)

- channel_name (string) — unique logical name.
- flags (number) — a bitfield, e.g. `nt.t_ChannelFlags.SIMPLE_NETWORK` (default) and `nt.t_ChannelFlags.PUBLIC` to mark channel as public.
- data (table) — optional. Typical keys:
	- id (number) — explicit id override (server-side).
	- priority (number) — for ordering public channel pulls.
	- types (string[]) — array of human-friendly type names, used by `nt.Write` / `nt.Read`.
	- fWriter (function) — custom write function for advanced serialization.
	- fReader (function) — custom read function for advanced deserialization.
	- OnWrite / OnRead / Init — lifecycle callbacks.

Return: channel id, channel table

When registering a public channel on the server, the server will announce the channel to clients (so clients can request the channel data via the pullChannels mechanism).

Example (server):

```lua
nt.RegisterChannel("example:announce", nt.t_ChannelFlags.PUBLIC, {
	id = 42,
	types = {"string", "int8"},
	Init = function(self) end,
	OnWrite = function(self, target, str, num) end,
	OnRead = function(self, ply, str, num) end
})
```

### Simple channel helper

`nt.SimpleChannel(name, types, callback)` is a convenience to register a simple channel that only needs types and a read callback.

### Sending messages

Use `nt.Send(channel_name, types, data, target)` when you already have types/data arrays. `nt.SendToChannel(channel_name, target, ...)` is a helper that uses the registered channel's types or fWriter.

Notes:
- `nt.Send` validates that the channel id exists and checks provided data against the declared types. If validation fails it will print predicted errors and abort the send.
- Message header includes the channel id (or a custom network string if `customNetworkString` is used by the channel).

Example (server -> clients):

```lua
local msg = {"Welcome", 10}
nt.SendToChannel("example:announce", nil, unpack(msg)) -- sends to all

-- send to single player
nt.SendToChannel("example:announce", somePlayer, "Private", 1)
```

Example (client -> server):

```lua
nt.SendToChannel("player:action", nil, someValue)
```

### Receiving messages

If you used `nt.RegisterChannel` with `types`, `nt` will automatically use `nt.Read(types)` to parse incoming payloads and then run the channel's `OnRead` if provided and will always run the `nt.Receive` hook:

`ihook.Run("nt.Receive", channel_name, ply, unpacked_values)`

This allows additional listeners to observe network traffic.

### Client ready / public channel pull flow

1. Client triggers `RequestInit()` (on `InitPostEntity`) which sends the `nt.channels.clientReady` message to the server.
2. Server receives the `clientReady` message and runs the `ReadyForNetwork.Pre` and `ReadyForNetwork` hooks for the player.
3. Server iterates `nt.mt_ChannelsPublicPriority` and for each public channel sends a `pullChannels` message to the client with the channel id. The client receives the `pullChannels` net message and reads channel-specific data using the server-provided pull writer.

This pattern allows the server to push initial state for public channels when a client connects or signals readiness.

### Type system

nt ships a collection of readers and writers named by human-friendly names. Common types include:

- Primitives: `string`, `table`, `vector`, `angle`, `color`, `float`, `double`, `bool` (or `boolean`), `entity`, `player`.
- Integers: `int`, `uint` (aliases for 32-bit). Also `int1`..`int32`, `uint1`..`uint32` for bit-length specific variants.
- Steam IDs: `steamid`, `steamid64` (`sid`, `sid64` aliases).
- `any` — net.ReadType / net.WriteType convenience.
- Special container: `array:<type>` — encoded with a count (8 bits) followed by repeated items.

Custom special types can be registered via the `mt_listWriter_Special`/`mt_listReader_Special` mechanism.

When sending, `nt.funcValidCustomType` and internal validators confirm that the provided Lua values match declared types when possible.

### Custom writer / reader functions

Channels can use `fWriter` and/or `fReader` to totally control serialization and deserialization.
Use this when default type names can't express the layout or when packing complex state efficiently.

Example:

```lua
nt.RegisterChannel("complex", nil, {
	fWriter = function(self, target, data)
		net.WriteString(data.label)
		net.WriteUInt(#data.items, 8)
		for _, it in ipairs(data.items) do net.WriteVector(it) end
	end,
	fReader = function(self, readFunc)
		local label = net.ReadString()
		local count = net.ReadUInt(8)
		local items = {}
		for i = 1, count do items[i] = net.ReadVector() end
		return label, items
	end,
	OnRead = function(self, ply, label, items) end
})
```

### Debugging and cvars

- `zen_network_debug` (convar) — controls logging level. Values:
	- 0: off
	- 1: basic logs (sent/received messages)
	- 2: verbose (start/end messages and payload debug)

Set it with `zen_network_debug 2` (server or client) to get more information in the console. When enabled the module prints helpful messages such as which player pulled which channels or errors during message validation.

### Common errors & troubleshooting

- "Received unknown message name" — usually a channel id was sent that the receiver hasn't registered. Ensure both server and client register channels with matching ids (or let server assign and publish public channels via pullChannels).
- "Chanell not exists" / assertion failures — ensure the channel name you call exists in `nt.mt_Channels` and was registered before first use.
- Type mismatch / validation failure — check your registered `types` and the data you pass when calling `nt.Send` / `nt.SendToChannel`. Use `zen_network_debug 2` to see validation logs.
- Pull flow failures — confirm the client triggers the `clientReady` message (client runs `RequestInit()` on `InitPostEntity`) and the server responds by sending `pullChannels` messages for public channels.

### Best practices

- Keep `types` simple and explicit where possible — it's easier to maintain than custom writers.
- Use `public` flag for channels that must be initialized on client join and implement idempotent pull handlers.
- Prefer `nt.SimpleChannel` for straightforward event-style messages.
- Use `OnWrite` and `OnRead` hooks only for side-effects/logging — keep serialization logic in `types`/`fWriter`/`fReader`.

### Example: full flow

Server:

```lua
nt.SimpleChannel("greeting", {"string"}, function(ply, msg)
	print("Server got greeting: ", msg)
end)

-- send greeting to a player
nt.SendToChannel("greeting", somePlayer, "Hello from server!")
```

Client:

```lua
nt.SimpleChannel("greeting", {"string"}, function(_, msg)
	chat.AddText(Color(0,255,0), "Greeting: ", msg)
end)

-- when ready, ask server for public channels and server may push data
-- the client RequestInit() call is handled by the module automatically on InitPostEntity
```

### Where to look in code

- `sh_nt.lua` — core shared implementation, types and Read/Write helpers.
- `sv_nt.lua`, `cl_nt.lua` — server and client glue for the ReadyForNetwork and pullChannels flow.

If you need extra examples or a new helper (e.g. a typed response pattern), add a short request and I can add code snippets or tests.

---

Document created and maintained as part of the `gmod-zen` `nt` networking subsystem.
