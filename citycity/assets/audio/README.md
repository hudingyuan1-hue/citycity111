# Audio Placeholder

If these files are missing, the demo uses generated in-engine tones so the loop remains runnable.

Long theme background music:

- `memory_background.mp3`
- `theme_bgm/desire_background.mp3`
- `theme_bgm/signs_background.mp3`
- `theme_bgm/trade_background.wav`

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

Thin theme:

- `thin_bird.wav`
- `thin_bubble.wav`
- `thin_waterdrop.wav`

Thin seek rule:

- These three one-shots follow the same grey-domain random seek rule as memory.
- Lightness currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- Away from the selected zone, bird, bubble, and water-drop clips show short thin-city text.
- Near or inside the selected thin zone, the original selected-theme hint text takes priority.

Trade theme:

- `trade_drum_hit.wav`
- `trade_laughter.wav`

Trade seek rule:

- `trade_background.wav` is the long tribal-drum background layer for the selected trade theme.
- If the trade background is missing later, the game randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, drum and laughter clips show short trade-city text.
- Near or inside the selected trade zone, the original selected-theme hint text takes priority.

Eyes theme:

- `eyes_glass.wav`
- `eyes_beep.wav`

Eyes seek rule:

- Eyes currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, glass and observation-beep clips show short eyes-city text.
- Near or inside the selected eyes zone, the original selected-theme hint text takes priority.

Names theme:

- `names_key.wav`
- `names_war.wav`

Names seek rule:

- Names currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, key and distant-war clips show short names-city text.
- Near or inside the selected names zone, the original selected-theme hint text takes priority.

Dead theme:

- `dead_shovel.mp3`
- `dead_wood_door.wav`

Dead seek rule:

- Dead currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, shovel and wooden-door clips show short dead-city text.
- Near or inside the selected dead zone, the original selected-theme hint text takes priority.

Sky theme:

- `sky_magic.wav`
- `sky_rotor.wav`

Sky seek rule:

- Sky currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, magic and rotor clips show short sky-city text.
- Near or inside the selected sky zone, the original selected-theme hint text takes priority.

Continuous theme:

- `continuous_page.wav`
- `continuous_dog.wav`

Continuous seek rule:

- Continuous currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, page and dog clips show short continuous-city text.
- Near or inside the selected continuous zone, the original selected-theme hint text takes priority.

Hidden theme:

- `hidden_wolf.wav`
- `hidden_rat.mp3`

Hidden seek rule:

- Hidden currently has no dedicated long BGM; it randomly reuses one existing background from memory, desire, signs, or trade.
- These two one-shots follow the same grey-domain random seek rule as memory.
- Away from the selected zone, wolf and rat clips show short hidden-city text.
- Near or inside the selected hidden zone, the original selected-theme hint text takes priority.

Current grey-domain rule:

- Non-selected theme zones play their own short SFX randomly only while the player is inside that zone.
- The selected theme SFX play as a distance-based seeking layer from the selected theme center.
- When the player is near or inside the selected theme zone, the matching SFX text can fade in at the top center.

Legacy fallback still supported:

- `memory_theme_loop.ogg`
- `city_memory_loop.ogg`
