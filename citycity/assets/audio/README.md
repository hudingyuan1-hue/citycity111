# Audio Placeholder

If these files are missing, the demo uses generated in-engine tones so the loop remains runnable.

Long theme background music:

- `memory_background.mp3`
- `theme_bgm/desire_background.mp3`
- `theme_bgm/signs_background.mp3`

Playback rule:

- Plays on the main menu as the global pre-game background.
- Switches to the selected theme background after choosing a theme, during the mechanic prompt before entering the grey domain.
- Keeps playing in the grey domain at a lower level on the `MemoryZone` bus so environmental SFX remain clear.
- Fades back up as the selected theme city music when the city manifests.
- Volume is controlled by the options menu BGM slider.

Theme short SFX:

Place short one-shot files under:

`assets/audio/theme_sfx/`

Memory theme:

- `memory_rooster.wav`
- `memory_horse.wav`
- `memory_infant_cry.mp3`
- `memory_wind.wav`

Memory seek rule:

- These four one-shots are randomly selected after entering the grey domain.
- Only one memory seek sound plays at a time; the next one waits for the current clip plus a 3-5 second random gap.
- Their volume grows as the player approaches the selected memory theme zone.
- Away from the selected zone, each clip can show its matching text at the top center.
- Near or inside the selected zone, the original selected-theme hint text takes priority over the clip-specific text.

Desire theme:

- `desire_wind_chime.mp3`
- `desire_water.wav`

Desire seek rule:

- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, the wind chime and water clips show short desire text.
- Near or inside the selected desire zone, the original selected-theme hint text takes priority.

Signs theme:

- `signs_sweeping.wav`
- `signs_keyboard.mp3`

Signs seek rule:

- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, sweeping and keyboard clips show short signs text.
- Near or inside the selected signs zone, the original selected-theme hint text takes priority.

Other theme placeholders:

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
