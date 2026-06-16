# Audio Placeholder

If these files are missing, the demo uses generated in-engine tones so the loop remains runnable.

Long memory background music:

- `memory_long_bgm.ogg`

Playback rule:

- Plays after choosing the memory theme, during the introduction / mechanic prompt before entering the grey domain.
- Stops when entering the grey domain.
- Fades back in as the global city music when the memory city manifests.

Theme short SFX:

Place short one-shot files under:

`assets/audio/theme_sfx/`

Memory theme:

- `memory_a.ogg`
- `memory_b.ogg`
- `memory_c.ogg`
- `memory_d.ogg`

Other theme placeholders:

- `desire_a.ogg`, `desire_b.ogg`, `desire_c.ogg`
- `signs_a.ogg`, `signs_b.ogg`, `signs_c.ogg`
- `thin_a.ogg`, `thin_b.ogg`, `thin_c.ogg`
- `trading_a.ogg`, `trading_b.ogg`, `trading_c.ogg`
- `eyes_a.ogg`, `eyes_b.ogg`, `eyes_c.ogg`
- `names_a.ogg`, `names_b.ogg`, `names_c.ogg`
- `dead_a.ogg`, `dead_b.ogg`, `dead_c.ogg`
- `sky_a.ogg`, `sky_b.ogg`, `sky_c.ogg`
- `continuous_a.ogg`, `continuous_b.ogg`, `continuous_c.ogg`
- `hidden_a.ogg`, `hidden_b.ogg`, `hidden_c.ogg`

Current grey-domain rule:

- Non-selected theme zones play their own short SFX randomly only while the player is inside that zone.
- The selected theme SFX play as a distance-based seeking layer from the selected theme center.
- When the player is near or inside the selected theme zone, the matching SFX text can fade in at the top center.

Legacy fallback still supported:

- `memory_theme_loop.ogg`
- `city_memory_loop.ogg`
