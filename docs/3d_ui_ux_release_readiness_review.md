# Property Tycoon 3D + UI/UX release-readiness review

**Baseline review:** August 20, 2026 · `7f498c7` (`main`) · **App version:** `2.0.1+12`
**Feature-branch follow-up:** August 21, 2026 · `codex/3d-ui-release-blockers` at `1ccbbf4`
**Decision:** **Hold release**

The 3D direction is worth continuing, and the newer city/navy/teal/gold screens establish a strong visual target. The reviewed `main` baseline was not ready to ship. Its most important problems were not subjective polish issues: a live game could become a corrupted hybrid after opening Help, the pawn was mathematically embedded in and offset from its road, several independent animation systems fought over the pawn transform, a reopened Android 3D board could wait forever, supported phone landscape layouts overflowed, and the release build needed remediation. The feature branch fixes those foundations; remaining device/performance breadth, special movement, character identity/rigging, small-phone 3D HUD, accessibility, localization, and release-engineering work still justify the Hold decision.

This document separates what was reproduced in a simulator from what was established through source, test, and build review. It also covers screens that cannot currently be reached through normal navigation.

## Feature-branch remediation update

**Branch:** `codex/3d-ui-release-blockers`

**Status:** Major correctness and build blockers are fixed; the release decision remains **Hold** until the physical-device gates below pass.

The rest of this document preserves the audit of `main` as the historical baseline. This update records what has changed on the feature branch and keeps unresolved findings visible instead of treating a successful desktop build as release approval.

### Pre-optimization physical iPad baseline — `8003401`

A signed profile build from feature-branch commit `8003401` was installed and exercised on a connected **iPad Air (5th generation)** running **iPadOS 27.0 beta**, at the native 2746 × 1908 landscape capture size. The live session used Atlantic City with four players (two humans and two AI players). The embedded iOS Godot runtime launched successfully, rendered the exported pack, survived both landscape orientations, and produced no Flutter/native console exception during the observed idle session. This closes the basic physical-launch compatibility question, but it does not approve the 3D experience for release.

The device pass on commit `8003401` confirmed the following issues in the
interaction rather than only in source review. They are the before-state for
the follow-up implementation described immediately below:

- Start Game appeared unresponsive for several seconds while content and the board were prepared; there was no immediate busy state or progress feedback.
- The visible help taught tap, one-finger drag, and pinch, but exposed no way to orbit/change the camera angle even though Godot supports orbit input.
- Every roll forced camera cuts between the board/player and dice, creating avoidable back-and-forth motion and overriding the user's chosen view.
- The human Roll surface remained visually actionable during AI turns; human input and scheduled AI authorization were not clearly separated.
- Default framing devoted too much of the screen to ocean/sky while property, landmark, ownership, and status text became unreadably small.
- Pawn ground contact is materially improved, but the plinth/ring footprint still exceeds the road width at outer tiles. Floating `SOLD`/`BUILDING` labels and decorative clouds can obscure playable content.
- The four-player HUD shows only the current-player pill. It omits opponent/AI identity, round, status, property context, and an explicit AI-thinking or human-handoff state.
- A short idle sequence showed stable pawn roots with no obvious residual bob/hop jitter. Boats and ambient elements continued animating as intended.

The current follow-up remediates the first four findings in code: Start Game
paints an immediate, blocking, accessible preparation state; one finger pans
while two fingers orbit and pinch simultaneously; roll, route, landing, and
restore camera cuts no longer override the player's view; and human dice
surfaces are disabled throughout every AI action while the AI scheduler retains
its own single-roll authorization. The default landscape framing is closer,
rotation recenters an off-board pan, embedded clouds and floating development
labels are hidden, and the pawn plinth is narrower. A localized status rail now
shows all players, Human/AI identity, cash, round, jail/skip/bankruptcy state,
AI phase, and human handoff; tapping an eligible player opens their portfolio.
Property count and current-location context remain absent from the rail.

An Instruments **Game Performance Overview** trace captured 20 seconds of the idle four-player board. It held approximately **60 FPS with zero skipped frames** and remained at a nominal thermal state during the short sample, but consumed approximately **79–83% GPU**, about **53% of one CPU core**, reached **1,355.9 MiB peak physical footprint**, and allocated **698.8 MiB through Metal**. Average GPU active time was about **13.6 ms** per 16.7 ms frame. This is inadequate headroom on an M1-class iPad for movement, long-session thermals, or older supported devices. Mobile render cost and memory are therefore measured release blockers, not merely a future optimization suggestion.

The same trace averaged approximately **53% of one CPU core**, issued **six
Metal command buffers per frame**, reached approximately **19.4 ms maximum GPU
active time**, and showed about **62 ms CPU-to-display latency**. The nominal
thermal state covers only this 20-second observation and is not long-session
thermal evidence.

The feature branch now applies a first conservative renderer budget: only the
embedded Godot surface renders at 75% native pixel density, its display link is
capped at 60 FPS, MSAA is reduced from 4x to 2x, shadow maps are reduced from
4096 to 2048/1024, the secondary fill light no longer casts shadows, and common
procedural cylinders use half as many radial segments. Identical immutable
primitive meshes now share buffers within one city, and tiny sphere details no
longer cast unreadable shadows. Flutter/UIKit remains at native Retina
resolution.

### Post-fix physical iPad validation — August 21, 2026

The signed profile app from the settled feature-branch source and iOS pack was
installed and launched on the same iPad Air. A temporary, uncommitted profile
QA entrypoint then opened the normal `AppNavigator` directly with Atlantic City,
four players, two consecutive AI turns, and two following human turns. It used
the same Flutter/game/native/Godot code and signed pack as the app; it bypassed
only the menu/setup taps so repeatable gameplay could be observed without a
provisionable physical-device UI-test runner.

The exact scene-generation acknowledgement completed, each AI player rolled
exactly once, both standard pawn moves and landings completed, and control
passed to the first human. During AI motion the roll surface remained visibly
disabled as `MOVING…`; after resolution it became `Roll for Human One`. The selected board
view did not cut to the dice or jump between turns. Captured motion and settled
frames showed attached bodies, tile-surface contact, road-centered anchors, and
matching player colors. The localized rail showed all four players, AI/Human
identity, active/waiting state, cash, round, AI motion, and the explicit human
handoff. Portrait, landscape-left, and landscape-right captures retained the
board, active pawn, rail, camera hint, and roll controls, with the view recentered
after rotation. No Flutter, native, or Godot exception appeared in the attached
console. Multi-touch orbit/pinch and the menu-to-setup preparation overlay still
require direct user touch on the final app; Xcode Device Hub exposes the
screen but its mirror is not available through the host automation accessibility
layer.

Two follow-up **Game Performance Overview** traces were recorded: one spanning
the AI-to-human handoff and one 20-second idle human turn. Both held 60 FPS with
zero skipped frames and stayed nominal during the short thermal sample. The
idle comparison is the fair pre/post renderer comparison:

| Metric | `8003401` baseline | Post-fix idle | Result |
|---|---:|---:|---|
| FPS / skipped frames | 60.00 / 0 | 60.00 / 0 | Stable |
| Average GPU usage | 81.24% | 85.62% | **4.38 percentage points worse** |
| Average / maximum GPU active time | 13.64 / 19.36 ms | 14.37 / 19.37 ms | No added GPU headroom |
| CPU use, one-core equivalent | 52.65% | 58.40% | **5.75 percentage points worse** |
| Peak physical footprint | 1,355.9 MiB | 870.4 MiB | **35.8% lower** |
| Metal device allocation | 698.8 MiB | 440.1 MiB | **37.0% lower** |
| CPU begin-to-display latency | 61.93 ms | 62.85 ms | Essentially flat |
| Command buffers per frame | 6.00 | 6.00 | Unchanged |
| Thermal state | Nominal | Nominal | Only a ~21-second sample |

The renderer changes materially reduce memory, but they do not reduce GPU or
CPU cost in this closer-framed four-player scene. The M1 iPad still maintains
60 FPS in the observed standard rolls, but the lack of GPU headroom makes
minimum-device, long-session, battery, and thermal validation a release gate.

Startup readiness is now end-to-end rather than inferred from a running native
engine. Every scene payload carries the game session and a monotonic state
generation; Godot acknowledges `stateApplied` only after the requested city,
tiles, players, pawn positions, active turn, and dice have been applied. The
opaque loading cover waits for the first exact token, a session/city change, or
a startup error; routine same-board synchronization keeps the applied scene
visible to avoid a full-screen flash. Both human/AI roll gates always wait for
the latest exact token.
iOS no longer manufactures `boardReady` from LibGodot `isStarted`; it can
replay only a readiness token observed from the connected GDScript scene. A
15-second watchdog exposes Retry 3D and a session-persistent Use 2D board
recovery. Atlantic City is now the bootstrap theme, avoiding the former New
York-to-Atlantic double build on the default setup path; other cities still
perform one initial procedural rebuild and should be profiled separately.
Ready-time state delivery is native-owned: Flutter sends each generation once,
the host caches it until the observed scene transition, and `boardReady` never
causes Flutter to send the same payload again. Retry deliberately replays the
cached generation once. The watchdog also bounds a platform view that never
reports creation, and an early `stateApplied` cannot dismiss recovery until the
view and scene are both ready.

This pass also exposed correctness work adjacent to the four reported
symptoms. The follow-up now advances the authoritative round number, expands
every logical move through all intervening positions on the 52-waypoint visual
road, starts new games with an explicit unrolled dice state, and schedules an
AI-first opening turn only after exact scene readiness. Non-dice
jail/card/teleport movement no longer snaps: the special-movement presentation
contract below now animates it, pending the same physical-device validation
as standard movement.

| Original gate | Feature-branch status |
|---|---|
| Live-game state integrity | **Remediated.** A single `GameSessionController` now owns authoritative state. In-game Help preserves the board in an `IndexedStack`, and load/restart/quit invalidate delayed work. Regression tests cover Help round trips and stale AI callbacks. |
| Pawn placement and motion | **Standard dice movement validated on physical iPad; special movement animated in code, device validation open.** Pawn roots use tile-surface contact anchors. Visual bob, hop, landing, and model transforms have separate owners; a single cancellable sequence controls each move; landing completes before Flutter is notified. Two consecutive AI rolls showed attached bodies, stable contact, and completed landings. Jail, card, teleport, and reverse movement now reuse the same scoped movement contract with typed presentations (`standard`/`walk`/`reverse`/`teleport`/`jail`), covered by bridge smoke tests and still needing a physical-device pass. |
| Pawn/road alignment and occupancy | **Standard routes validated; occupancy breadth pending.** A lone pawn is centered, two to four occupants use deterministic slots, pawns/markers share anchors, the plinth is narrower, every intervening 52-position road waypoint is emitted, and duration scales with segment distance. The two physical AI routes and settled anchors remained on the road. One-to-four co-occupancy, a complete lap, reverse movement, and every corner angle remain device gates. |
| Repeat Android 3D sessions | **Remediated; device validation pending.** Reattached views receive a new native-view session, cached state, an observed scene-ready token, and an exact game-session/state-generation acknowledgement; detached rendering is lifecycle-paused; stale commands and callbacks are bounded and rejected. |
| Victory/restart/quit | **Remediated.** Navigation owns the result screen, so Replay and Home no longer call a disposed game-board owner. System Back now follows app-owned confirmation behavior. |
| Async turn safety | **Remediated.** AI timers are generation-scoped, auctions are awaited, unresolved turns disable modal-producing actions, pending card choices are cancelled on disposal, restart suspends the old session before asynchronous setup, and the delayed event dialog now uses the same player/session/generation-scoped timer registry. |
| Supported orientations | **Validated for the post-fix iPad board; broader layouts pending.** Portrait and both landscape orientations retained the 3D board, current pawn, player rail, camera hint, and roll controls, and rotation recentered the camera. Pause, buy, auction, card-pick, and spin dialogs constrain and scroll their content and have phone-landscape/large-text widget coverage; physical phone and split-view checks remain. |
| Duplicate actions and Start feedback | **Remediated in code; device validation pending.** Start Game, Lucky Spin, and prize collection use single-flight guards. Start now paints a blocking localized preparation overlay before localized tiles/native setup begin, so the guarded action no longer appears frozen. |
| 3D command recovery | **Remediated for automatic recovery.** Native rejection fails immediately; a failed, mismatched, or timed-out move switches to the visible 2D board before Flutter animates each fallback step. The movement watchdog follows Godot's 9.5-second deadline at 10 seconds, while command freshness, replay, explicit game session, player, and cancellation checks protect retained engines. Startup/state application has its own 15-second watchdog with Retry 3D and session-persistent Use 2D board actions. A saved cross-session 2D preference remains a follow-up. |
| Android release build | **Remediated.** The stale splash-plugin registration is removed by upgrading `flutter_native_splash`; runtime/pack availability is validated; local release artifacts are intentionally unsigned instead of using a debug key. Production signing secrets and CI remain required. |
| iOS dependency portability | **Remediated.** The seven tracked `.symlinks` entries that hard-coded another developer's home directory were removed and the generated directory is ignored. Running CocoaPods from `ios/` recreates the correct local links and the pinned simulator build passes. |
| Accessibility and localization | **Still open.** The branch adds semantics and localized progress/error text to touched controls, but the board-wide accessible equivalent, motion preferences, target sizing, contrast, and ID-based localization of events/spin/power-ups/achievements remain release work. |
| Physical-device 3D performance | **Remeasured; still not passing.** Godot-only render scale, 2x MSAA, smaller shadow maps, one shadow-casting light, primitive mesh reuse, tiny-detail shadow suppression, 24-segment cylinders, and a 60 FPS cap cut peak footprint from 1,355.9 to 870.4 MiB and Metal allocation from 698.8 to 440.1 MiB. The post-fix board held 60 FPS with zero skips, but GPU usage rose from 81.24% to 85.62% and one-core-equivalent CPU from 52.65% to 58.40%; minimum-device and long-session headroom remain blockers. |

### Feature-branch verification

- `flutter test --reporter expanded`: **132/132 passed**.
- Targeted analysis of all changed Dart source and tests: **no issues**. Repository-wide `flutter analyze` has **0 errors, 0 warnings**, and 238 remaining info diagnostics.
- Android bridge/session/runtime JVM tests: **debug and release passed**.
- `flutter build apk --debug --no-pub`: **passed**.
- `flutter build apk --release --no-pub`: **passed**; the local APK is deliberately unsigned until `android/key.properties` is supplied from protected credentials.
- Godot bridge smoke tests: **passed** on official Godot 4.7.1 and 4.6.3, including grounding, occupancy, color, marker alignment, wrong/expired/replayed commands, cancellation during a hop, completion only after landing, the mobile render budget, and neutral pre-roll dice presentation.
- Android and iOS Godot packs were regenerated and mounted successfully with their matching engine lines. SHA-256: Android `347d7132969f31f458540f0c6fa4779d3648c547ddaff8bf3717c21b6b09a619`; iOS `275d0811b6477c98ba3fbbe04da5530ffed9b9364009a6f1606f6e1c1be88ce3`.
- Architecture-pinned iOS Simulator `xcodebuild` (`arm64`, signing disabled): **passed**. iOS host tests: **4/4 passed**, covering observed-ready replay, cached-state Retry, 2x → 1.5x and 3x → 2x Godot-only content scale, and the 60 FPS cap. The generic `flutter build ios --simulator` path remains blocked by the current Flutter/Xcode 27 beta `undefined_arch` toolchain behavior.
- Signed physical-device `flutter build ios --profile --no-pub`: **passed** (`Runner.app`, 169.9 MB), with the expected iOS PCK hash embedded. It was installed and launched on the connected iPad Air. In the post-fix QA scenario, each AI player rolled exactly once, the Roll surface stayed locked during AI control, the camera did not cut between the board and dice, standard pawn motion remained grounded and road-centered, portrait and both landscape orientations retained all essential game controls, and the attached console showed no Flutter, native, or Godot error. Start Game feedback and two-finger orbit/pinch still require direct user-touch confirmation in the final app.
- CocoaPods regeneration from `ios/`: **passed** after removing machine-specific tracked plugin symlinks.
- No local Android emulator is configured, and the iOS bridge intentionally disables Godot in Simulator. The simulator build therefore validates host integration only, not the shipped 3D rendering path.
- `git diff --check`: **passed**.

### Special-movement follow-up — August 25, 2026

Finding 3D-07 is implemented on this branch. The `animate_roll` command now
carries a `presentation` field (`standard`/`walk`/`reverse`/`teleport`/`jail`)
that reuses the dice-roll scoped contract for every non-dice movement: jail
escorts, Chance/Community Chest relocations, and spin-prize teleports animate
with route walks or parabolic beacon flights instead of snapping during the
next state sync. Failure still degrades deterministically: a rejected,
expired, or timed-out presentation settles through a scene-state sync, and a
state sync cancels any in-flight presentation exactly as it cancels rolls.
Verification added: four new bridge smoke scenarios (walk, reverse, teleport
flight, jail flight, plus overlap/replay rejection and settled-dice
preservation), three new Dart tests for the typed contract and card-action
mapping, and `flutter test` now reports **135/135 passed** with the analyzer
still at 0 errors/0 warnings. The Android PCK was regenerated (Godot 4.7.2
exporter against the 4.7.1 vendor runtime — the same skew tracked by gate 3);
the iOS PCK still requires the local 4.6.3 exporter binary and must be
regenerated before the next physical-device build. Physical-device
validation of special movement on iPad/Android remains part of gate 1.

### Appearance contract follow-up — August 25, 2026

3D-05 first pass implemented: `GodotBoardPlayerState` now carries
`avatarId` and `avatarIsPhoto`, the controller maps them from the player's
effective avatar, and Godot stores the ids and derives a deterministic pawn
hair tint from them (stable across sessions, verified by a bridge smoke
assertion on the exact material color). The 3D status rail now renders the
effective avatar — a custom photo when chosen, otherwise the avatar emoji —
matching the portfolio, card, and victory identity surfaces instead of the
raw setup icon. Still open under 3D-05: a live pawn preview in setup, and
the deeper token-model decision tracked as 3D-04.

### Graphics quality tiers follow-up — August 25, 2026

3D-21 scaffolding implemented end to end: a persisted
`GraphicsQualityService` (high/medium/low, shared preferences, unknown
values fall back to high), a Settings selector in the Sound & Language
panel localized across the five ARB catalogs, a `graphics_quality` bridge
command through both native hosts, and runtime application in the native
scene (render-scale multiplier, MSAA, directional shadow atlas size; "high"
matches the shipped baseline exactly). The tier rides every board-ready
transition and is covered by bridge smoke assertions per tier plus service
and controller tests. Tuning the tier budgets — and promoting an automatic
mode — still requires the minimum-device Instruments profiling gate, which
needs physical-device captures.

### Token-follow camera follow-up — August 25, 2026

3D-09 first pass implemented as an opt-in mode: the action bar gains a
follow toggle that sends `camera_follow` through both native hosts, and the
native scene damps its ground target toward the active pawn with
frame-rate-independent easing inside the existing target bounds. Manual
pan/orbit suppresses the chase until the next accepted movement command,
Reset View holds suppression, and disabling follow restores the free camera
— preserving the earlier remediation that a roll never overrides the
player's chosen view. Covered by a bridge smoke suite (damping, bounds,
suppression, re-engagement, disable) and a Flutter controller test for the
gated toggle. Reduced-motion handling rides on the toggle: following is
entirely off unless requested. Remaining 3D-09 polish (full path-bounds
framing and HUD safe-frame offsets inside the follow mode) rides with the
pawn-identity work.

### Experience polish follow-up — August 25, 2026

Physical iPad QA surfaced two confirmed experience defects, both fixed and
re-verified on device. (1) Overview labels were a few pixels tall; world-space
text now uses distance-adaptive semantic zoom — tile and landmark labels
compensate for camera distance, and overview framing abbreviates tile labels
to the name alone (prices return on zoom-in and remain on the detail sheet),
with the abbreviation surviving every state resync (3D-15 first pass).
(2) Harbor boats hovered roughly 0.3 units above the water plane; lanes,
piers, and buoys now sit at the measured water surface, hulls carry a real
draft, and a gentle bob/sway keeps craft alive without lifting them clear
(3D-26 partial elevation-contract fix). New bridge smoke coverage asserts the
waterline and the semantic-zoom behavior including the resync regression, and
both packs were regenerated — the iOS pack now uses a downloaded Godot 4.6.3
exporter at `.tools/Godot.app`, removing the earlier iOS pack staleness.
Remaining experience findings recorded during the same review were then
implemented in the same pass and re-verified on device: 3D walks now emit
`movementStep` progress events through both native hosts so the Flutter board
plays per-waypoint footstep audio exactly like the 2D hop rhythm (Android
peeks the command session without consuming it; the iOS host forwards host
events generically; Flutter dedupes retries, out-of-order waypoints, and
events trailing a completion); the active-event badge now stacks above the
3D gesture-hint slot instead of colliding with it (UI-03 scoped fix); the
destination beacon label scales down at close camera range; and settled dice
gained per-roll landing variety (slot swap, small position jitter, and
variable whole-revolution spins that preserve the settled face). Full UI-03
overlay slots, the damped token-follow camera, rigged pawn identity, and the
GPU-headroom release gate remain open.

### Remaining release gates

1. Complete the remaining physical interaction matrix. On iOS, manually verify the menu-to-setup preparation overlay, one-finger pan, two-finger orbit/pinch, Reset View, low/high road contact, 1–4 pawn co-occupancy, a complete lap, special movement, first-session → menu → second-session reattachment, background/resume, and native-failure recovery. Repeat the full standard-roll/orientation/performance pass on Android.
2. Measure frame time, memory, battery, and thermal behavior during a long game on the minimum supported devices; then set and enforce quality/FPS budgets.
3. Pin exporter/runtime to one exact supported iOS build, or document and continuously test the currently observed 4.6.4-vendor-runtime/4.6.3-exporter compatibility. The physical iPad standard-roll pass worked, but the version skew should not remain implicit.
4. Finish the accessibility, localization, permission-timing, visual-system, camera/input, and remaining 3D readability work documented below.
5. Add CI for Flutter tests/analysis, both release compiles, Godot smoke/export freshness, artifact size, protected production signing, and device-lab smoke tests.
6. Recheck the generic iOS build on a stable Xcode/Flutter pairing; do not treat the architecture-pinned workaround as the final CI configuration.

## 1. Scope and method

### Runtime coverage

The Flutter app was run in debug mode on:

- iPhone 17 Pro simulator, iOS 27.0, portrait and landscape.
- iPad Pro 13-inch simulator, iOS 27.0, portrait.

Runtime flows exercised included splash, main menu, both setup steps, How to Play, Settings, a live two-player game, rolling and turn changes, the city guide, tile/player information, portfolio, Pause, Save, Quit, Buy Property, Lucky Spin, and Jail presentation. A live-game state corruption was reproduced, as were landscape overflows and Flutter runtime assertions.

### Baseline 3D limitation

The shipped iOS bridge deliberately reports 3D as unavailable in Simulator (`ios/Runner/GodotBoardIOSPlugin.swift:45-54`). The simulator therefore displayed the 2D fallback; it could not render or record the embedded Godot board. No Android virtual device is installed in this workspace, and the documented local Godot executable is absent, so the GDScript smoke suite could not be run here. The 3D review consequently combines:

- code-level geometry and animation measurements;
- Flutter-to-Godot protocol and lifecycle review;
- Godot scene, camera, picking, and performance review;
- the Flutter HUD and failure/fallback behavior in Simulator.

This was itself a release-process gap in the baseline review. The feature-branch update above now supplies one physical iPad standard-roll/orientation/performance pass and dual-engine headless Godot smoke coverage. Android, minimum hardware, direct multi-touch, special movement, reattachment/backgrounding, recovery, and long-session coverage remain, and the project still needs a simulator/emulator-capable 3D harness so normal regression QA can see the shipped experience.

### Coverage labels used below

- **Runtime:** directly exercised in Simulator.
- **Static:** all relevant UI/state/layout code reviewed, but the state was not naturally reached during the session.
- **Blocked:** the current product or environment makes the experience unreachable.

### Severity

- **P0 — blocker:** can corrupt a game, make a supported build or primary flow unusable, or invalidates release confidence.
- **P1 — high:** materially damages gameplay, comprehension, accessibility, reliability, or device performance.
- **P2 — medium:** visible inconsistency or friction that should be addressed for a polished release.
- **P3 — low:** cleanup or refinement after the release gates are satisfied.

## 2. Main-baseline executive release gates

| Gate | Status | Why it is not passing |
|---|---|---|
| Live-game state integrity | **Fail** | Opening How to Play from a game disposes the board and rebuilds it from stale parent state. This was reproduced. |
| Pawn placement and motion | **Fail** | Grounding, lane offset, footprint, and competing transform writers directly cause the reported misalignment/disjoint motion. |
| Repeat 3D sessions | **Fail** | Android retains one Godot engine but does not reannounce `boardReady`; uncancelled native roll retries can also leak into a later session. |
| Supported orientations | **Fail** | Phone landscape board overflowed; Pause overflowed by 364 px and became unusable. |
| Victory/restart/quit | **Fail** | Victory replaces the navigation owner, then calls callbacks tied to that disposed owner. |
| 3D recovery | **Fail** | A native timeout can stall for 12 seconds and then visually teleport the token; no user-selectable 2D fallback exists. |
| Release build | **Fail** | Android release compilation currently fails in generated plugin registration; see section 12. |
| Accessibility | **Fail** | Key custom controls lack labels/roles, color is used alone, targets are undersized, and the board has no accessible equivalent. |
| Localization | **Fail** | Large gameplay surfaces bypass the five ARB catalogs, including 3D HUD/actions, events, spin, power-ups, and achievements. |
| Physical-device 3D performance | **Not tested** | iOS Simulator disables 3D and there is no Android AVD. Minimum-device FPS, memory, and thermal evidence is absent. |

## 3. Reproduced simulator defects

### SIM-01 — P0 — leaving a live game through Help corrupts turn state

Reproduction on iPad:

1. Start a two-player game.
2. Roll `5 + 5`; Player 1 moves from GO to Jail and the turn advances to Player 2.
3. Open Pause → How to Play.
4. Return to the game.

Observed result:

- the active player reverted from Player 2 to Player 1;
- dice reverted to the earlier `6 + 6` values;
- Player 1's mutable token position remained at Jail.

The result is a hybrid of old scalar state and newer mutable player state. The cause is visible in code: `AppNavigator` owns the original `_gameState` (`lib/app.dart:55-64`, `126-165`), while `GameBoardScreen` takes a local reference and repeatedly replaces only that reference with `copyWith` (`lib/screens/game_board_screen.dart:118-123`, `1828-1837`, `1892-1907`, `1979-1987`). Switching the `AnimatedSwitcher` to How to Play disposes the board (`lib/app.dart:265-270`, `301-310`, `330-342`), then recreates it from the stale parent.

**Required change:** introduce one authoritative `GameSession`/controller above navigation. Every transition must update that owner. Present Help over the current session or serialize the entire session before disposal. Add a regression test that compares every game-state field before and after Help, backgrounding, and route changes.

### SIM-02 — P0 — Pause is unusable in supported phone landscape

On iPhone 17 Pro landscape:

- the compact Roll control threw `A RenderFlex overflowed by 16 pixels on the right` at `lib/screens/game_board_screen.dart:1554`;
- opening Game Menu displayed `BOTTOM OVERFLOWED BY 364 PIXELS`;
- only the top menu actions remained visible and the rest could not be reached;
- a property-information dialog fit its shell, but most fact content began below the fold with no visible scroll cue.

The app permits landscape, while major dialogs use fixed, non-scrollable content. Representative sources are `lib/widgets/dialogs/game_menu_dialog.dart:24-402`, `card_pick_dialog.dart:123-368`, `auction_dialog.dart:148-267`, `spin_wheel_dialog.dart:59`, and `buy_property_dialog.dart:49`.

**Required change:** create one adaptive modal shell with `SafeArea`, `LayoutBuilder`, a maximum available height, scrollable content, and pinned actions. Verify every modal at phone landscape, split view, and text scales 1.0, 1.3, and 2.0.

### SIM-03 — P1 — the fallback board is too small to read or target on a phone

The complete approximately 1,100 × 1,100 logical-pixel board is fitted into a phone-width square (`lib/screens/game_board_screen.dart:1376`). Property names, prices, ownership marks, and tap targets become extremely small. Portrait also leaves a large unused band between the player cards and board, while the board remains width-limited.

**Required change:** define a phone board mode: automatic pawn following with zoomed local context, semantic zoom, or a tile-strip/list companion. Keep the full-board overview available as a secondary view.

### SIM-04 — P1 — city guide triggers Flutter material assertions

Opening the city guide on iPad logged the ListTile assertion three times:

> ListTile background color or ink splashes may be invisible.

The guide wraps `ListTile` in its own decorated background (`lib/screens/game_board_screen.dart:339-479`, particularly around `:425`). The assertion itself is debug-only; the shipping defect is incorrect Material ancestry that can suppress ink/press feedback.

**Required change:** put background/shape on `ListTile.tileColor`/`Material`, preserve visible ink, and add a widget test that pumps the sheet with no framework exceptions.

### SIM-05 — P1 — notification permission arrives without context

The iOS notification prompt appeared shortly after launch while navigating into Settings, before the app explained what notifications would contain or offered a setting. Initialization and scheduling happen at startup (`lib/main.dart:19-25`; `lib/services/notification_service.dart:85-180`).

**Required change:** show a localized pre-permission explanation at a relevant moment, request only after explicit opt-in, expose a Settings toggle, and remove unneeded exact-alarm permission on Android.

### SIM-06 — P2 — compact headers truncate on a flagship phone

Observed examples:

- setup title: `Create Your G...`;
- setup subtitle: `Choose a city, game size, an...`;
- Player Setup subtitle truncates;
- Settings subtitle truncates.

The information is not essential to completing the flow, but flagship-width truncation indicates the header needs compact typography or responsive content priority before testing 320/360 dp devices and translations.

### SIM-07 — P2 — selected city text and claims are internally inconsistent

The city guide displayed `New York City • United States • New York City`, repeating the localized/native name when both strings are identical (`lib/screens/game_board_screen.dart:385-387`). It also described a “living 3D theme park” while the current runtime was visibly using the 2D fallback.

**Required change:** deduplicate equal location names and make rendering-mode claims conditional on actual 3D readiness.

### SIM-08 — P2 — visual language fractures inside the game

The main/setup/help/settings surfaces use a cohesive photographic city, navy, teal, and gold system. Runtime game dialogs switch among several unrelated themes:

- Pause and confirmations: purple/pink gradients;
- tile and portfolio sheets: bright green, brown, or coral;
- Lucky Spin: green/orange;
- Jail: gray/orange;
- Victory: black/generic presentation in source.

This makes the product feel like multiple generations of UI layered together. Consolidate dialogs, typography, spacing, buttons, surfaces, icon treatment, and motion under the newer design system.

### SIM-09 — P2 — game copy and feedback are misleading or redundant

- After a saved game existed, Quit still warned that “All progress will be lost,” although Continue remained available. Say “unsaved progress” and state the save time.
- Lucky Spin reported both `You won $100!` and `Win $100!` in the same result state.
- The last tutorial CTA says `Let's Play!`, but it only invokes `onBack` and returns to the menu (`lib/screens/how_to_play_screen.dart:964-1044`). Use `Done` or actually enter setup.
- The 2D hint says “drag to explore”; the 3D implementation uses drag to pan the camera. Use explicit mode-aware instructions such as “Drag to move the camera.”

## 4. The reported pawn problem: direct causes and required redesign

### 3D-01 — P0 — token ground contact is wrong by construction

The geometry explains the reported “not aligned with the board road” appearance:

| Measurement | Current value |
|---|---:|
| Tile center Y | `1.34` |
| Tile height | `0.20` |
| Tile top surface | approximately `1.44` |
| Pawn plinth bottom at root Y = 0 | approximately `1.10` |
| Active ring Y | `1.08` |
| Root Y during create/sync/move | forced to `0.0` |

Evidence: `godot_3d/scripts/main.gd:8`, `520-538`, `1960-2017`, `2073-2084`, `4389-4393`, and `4502-4507`.

The plinth, shoes, and ring are embedded below the road surface. Raising the existing root by roughly `0.34` would reduce the immediate defect, but it is not the robust fix.

**Required change:** define the token root as the exact ground-contact anchor. Author the sole/plinth bottom at local `y=0`; put visual bob/hop/squash on a child node; obtain elevation from the route/tile surface rather than forcing world Y to zero.

**Acceptance:** no clipping or visible gap at any tile/corner, with idle, hop, landing, 2-player, and 4-player captures viewed from low and high camera angles.

### 3D-02 — P0 — a lone pawn is deliberately placed off the road center

Normal tiles are `0.88` wide and route connectors `0.68` wide, while the pawn plinth is about `0.94` in diameter (`main.gd:499-524`, `1989-1996`). `_token_offset_for_tile()` adds about `0.30` of combined lateral/longitudinal offset for every player, including Player 1 when alone (`:5410-5420`). Route markers and destination beacons use the tile center, so the pawn does not line up with the UI's own route highlight (`:4550-4663`).

Four centers are only `0.36-0.48` apart, less than the pawn diameter, so co-located pawns must interpenetrate and can collide visually with buildings/flags.

**Required change:** calculate formation from actual co-occupants, center a lone pawn, use smaller tokens or explicit landing pads, and share a single `lane_anchor(tile, occupantSlot)` function across tokens, route markers, beacon, camera, picking, and properties.

### 3D-03 — P0 — multiple animation systems fight over the same transform

The body technically shares one root, but that root's Y value has several owners:

1. horizontal x/z tween advances a step and schedules recursion (`main.gd:4487-4500`);
2. a separate hop tween writes Y but is not awaited by recursion (`:4502-4507`);
3. `_process()` resumes idle bob writes as soon as the horizontal tween ends (`:238-252`);
4. a landing reaction starts another Y tween (`:4675-4689`);
5. `movementComplete` is emitted immediately, before landing completes (`:4510-4547`);
6. Flutter then syncs state, forcing root Y back to zero (`:4389-4393`; `lib/screens/game_board_screen.dart:1950-1987`).

The beacon has a similar scale conflict between continuous pulse and finish animation. These races explain jitter, truncated hops, weak landings, and the impression that the face/body are not moving as one.

**Required change:** use one token movement state machine/timeline. It owns path distance, arc height, facing, and completion. Idle motion lives on a visual child and is disabled/blended during movement. Emit completion only after the final landing pose and only once for the active command generation.

### 3D-04 — P1 — this is a static primitive pawn pretending to be a character

`_make_character_piece()` creates independent cylinders, capsules, spheres, hair, and surface-mounted eyes (`main.gd:1976-2085`). There is no skeleton, `AnimationPlayer`, gait, foot planting, arm swing, hip/shoulder relationship, or facial rig. Facing snaps at each route segment (`:4484-4485`). The simplified geometry can work as a board token, but a human silhouette and face raise the expectation of coherent character animation it cannot meet.

Choose one clear direction:

- **Recommended:** an authored, low-poly rig with `Anchor → Facing → Rig → Cosmetics`, plus idle/walk/hop/land clips and an `AnimationTree`.
- **Lower-cost alternative:** embrace a single-piece toy pawn with no pseudo-human face/limbs, then use squash, tilt, and bounce as a coherent object.

Do not continue adding more independent primitives to the existing pseudo-character.

### 3D-05 — P1 — selected avatar, HUD identity, and pawn identity disagree

Setup makes portraits/custom photos a primary choice (`lib/screens/game_setup_screen.dart:1270-1334`). The bridge sends only id, name, ARGB color, cash, position, and active status (`lib/integration/godot_board_contract.dart:64-91`); it sends no avatar, model, skin, or accessory id. Godot ignores even the transmitted color and builds from fixed palettes (`main.gd:46-64`, `1960-1968`, `4370-4393`). The Flutter 3D HUD uses `player.icon`, not `effectiveAvatar` (`lib/screens/game_board_screen.dart:915-980`).

**Required change:** define one stable appearance contract, for example `portraitId`, `tokenModelId`, `skinId`, `accessoryIds`, and authoritative color. Preview that exact pawn in setup and reuse the same identity in HUD, 3D, portfolio, owner flags, results, and Victory. Custom photos should remain portraits unless an explicit safe/avatar-generation flow exists.

### 3D-06 — P1 — logical-to-visual path mapping creates uneven speed

Forty logical spaces map to 52 visual endpoints (`lib/integration/godot_board_contract.dart:32-60`). A logical step therefore sometimes traverses one visual segment and sometimes two, but every command segment lasts `0.22s` (`main.gd:4491-4492`). Longer segments move nearly twice as fast and the 12 scenic positions are visually skipped.

**Required change:** expand every logical move into all intermediate visual waypoints and use distance-proportional duration/easing. Add a speed-continuity test over the complete 40-space lap.

### 3D-07 — P1 — special movement types snap instead of animate

State synchronization directly assigns token position (`main.gd:4384-4393`). Jail, teleport, backward, and card moves are updated outside the normal dice animation protocol (`lib/engine/game_engine.dart:375-378`; `lib/screens/game_board_screen.dart:2541-2571`).

**Required change:** generalize the movement command to path, reverse, teleport, and jail presentation types, with cancel/complete IDs and equivalent sound/haptics.

**Remediation (in code, device validation pending):** the `animate_roll` command now carries a `presentation` field — `standard` (unchanged dice staging), `walk` (dice-less route walk for forward card moves), `reverse` (back-N card moves), `teleport` (parabolic flight with a destination beacon for teleport prizes and advance-to-GO), and `jail` (the same flight staged as an escort). Godot stages every presentation under the existing generation/session/cancellation contract, shows intentional turn labels, and emits the same `movementComplete`. Flutter applies the logical move first, sends one typed command from the jail handler, card-draw paths, and spin-prize teleport, and on native rejection, staleness, or timeout settles with a scene-state sync instead of leaving the pawn stranded. Card actions map to presentations through `GodotMovementPresentation.forCardAction`, and the bridge smoke suite covers walk, reverse, teleport, and jail completion, label staging, dice preservation, route/beacon correctness, overlapping-command rejection, and replay rejection.

### 3D-08 — P1 — destination is revealed before dice settle

Godot draws the route before dice animation (`main.gd:4428-4430`, `4550-4626`), while Flutter exposes final die numbers during the rolling state (`lib/screens/game_board_screen.dart:1157-1176`, `1892-1934`). Repeated die results target fixed absolute rotations and can barely spin after the first roll (`main.gd:2473-2488`).

**Required change:** keep die faces indeterminate during roll, animate relative rotations with minimum full revolutions, settle, then reveal route and movement.

## 5. 3D camera, input, and board readability

### 3D-09 — P1 — camera choreography can finish after short moves

Route camera travel takes `0.55s`; two token steps take only `0.44s` (`main.gd:4450-4454`, `4751-4762`). The route frame uses only the midpoint of start/end rather than full path bounds (`:4738-4748`), and landing focus targets below the tile surface (`:4768-4770`). Dice, route, landing, and restore shots are forced on every roll.

**Improve:** use a damped token-follow camera that fits the complete route bounds, observes Flutter HUD safe frames, avoids center-city occlusion, and offers reduced/cinematic motion. Short moves should not complete off-camera.

### 3D-10 — P1 — orbit exists in Godot but is inaccessible

Flutter's opaque gesture layer forwards pan and zoom only (`lib/screens/game_board_screen.dart:823-898`), although the controller and Godot support orbit (`lib/integration/godot_board_controller.dart:237-264`; `main.gd:4119-4125`). The 3D gesture hint is hidden below 700 px width.

**Improve:** define and teach a consistent one-/two-finger gesture model, expose Reset Camera and optional orbit buttons, retain a replayable coach mark on phones, and provide an accessible non-gesture alternative.

### 3D-11 — P1 — gesture traffic can flood the native channel

Every scale-update callback immediately JSON-encodes and sends pan/zoom over `MethodChannel` (`lib/screens/game_board_screen.dart:875-898`; `lib/integration/godot_board_controller.dart:237-264`). That can generate 60-120 cross-runtime calls per second.

**Improve:** accumulate deltas and send at most once per Flutter frame; measure latency and dropped frames while moving the camera.

### 3D-12 — P1 — picking ignores occlusion/depth

`_pick_projected_board_object()` chooses the nearest projected screen point within a radius, without physics raycasting, colliders, visibility filtering, or occlusion (`main.gd:4194-4299`). A hidden landmark or adjacent tile can win.

**Improve:** use `project_ray_origin/normal` and collision layers, filter noninteractive/hidden objects, and show deterministic hover/tap feedback plus a Flutter detail sheet.

### 3D-13 — P1 — the 3D HUD omits other players and important status

The 3D layout shows the active-player pill, actions, and roll control, but not the 2D player strip (`lib/screens/game_board_screen.dart:815-864`, `1428-1509`). Opponent balance, property count, status, order, and round are not quickly visible.

**Improve:** add a compact/collapsible player rail designed around board safe areas. Never cover the active pawn or destination during camera following.

### 3D-14 — P1 — roll controls are too wide for common phones

The 3D controller combines fixed 82, 190, and 58 px components plus margins—roughly 366 dp (`lib/screens/game_board_screen.dart:1182-1325`). It is unsafe at 320/360 dp and at large text sizes.

**Improve:** use compact/stacked variants or `Wrap`; test 320, 360, 390, tablet, landscape, and text scale 2.0.

### 3D-15 — P2 — overview labels cannot be legible at mobile scale

Fifty-two perimeter spaces are rendered at the default portrait camera distance/FOV while each tile carries world-space labels (`main.gd:554-580`, `2497-2511`, `5337-5342`). Full names/prices become a few pixels wide.

**Improve:** use semantic zoom: overview colors/icons, abbreviated labels at middle distance, and full screen-space details only for focused/selected tiles.

### 3D-16 — P2 — scenic spaces look like properties

The 12 visual-only indices reuse property-card geometry/color fallbacks and scenic names are assigned with index modulo before logical overrides (`main.gd:629-638`, `2712-2733`). This can duplicate/omit names and imply that scenery is purchasable.

**Improve:** make scenic waypoint a distinct data type with explicit unique ids, non-property art, and no price/color-group affordance.

## 6. 3D lifecycle, recovery, and performance

### 3D-17 — P0 — a second Android game can wait forever

Android keeps one `GodotFragment`/engine and moves its view into the next platform view (`android/app/src/main/kotlin/com/hyu/properotyTycoon/MainActivity.kt:105-131`, `184-188`). `boardReady` is emitted only from the Godot plugin's one-time `ready()` (`:251-260`). A new Dart controller starts with `_isBoardReady=false` and waits for the callback (`lib/integration/godot_board_controller.dart:12-27`, `318-324`). Reattaching the already-ready fragment does not produce it.

**Required change:** reannounce readiness on every attachment, resend cached state, acknowledge state application, and include a timeout with Retry/Use 2D. Test first game → menu → second game, same/different city, and 2 → 4 players.

### 3D-18 — P1 — retained engines keep processing behind Flutter screens

Android explicitly preserves the engine, and iOS retains the hosted engine/view. Neither bridge sends an explicit deactivate/pause. Godot continuously updates water, clouds, boats, camera, and idle pieces in `_process()`.

**Required change:** implement attach/activate/deactivate/background lifecycle messages that pause rendering and scene processing, then resync on resume. Profile battery and thermals when sitting on Menu after a game.

### 3D-19 — P1 — retained sessions can have missing players/stale camera

When an existing board is reused, `_apply_scene_state()` rebuilds only when board id changes and clamps players to the existing token array (`main.gd:4353-4363`). A 2-player session reopened as 4-player can lack Players 3/4. Camera state is not consistently reset by board rebuild (`:2667-2709`).

**Required change:** reconcile token count and appearance on every complete state, and explicitly reset or restore camera per session.

### 3D-20 — P1 — startup builds the wrong city first

`current_board_id` defaults to New York and `_ready()` synchronously builds the complete board/city before Flutter state arrives (`main.gd:195`, `217-235`). Seventeen of the 18 city choices then free that content and build another city (`:2667-2709`, `4353-4356`).

**Required change:** provide initial board id before scene construction, show a controlled loading stage, cache shared resources, and stage/async-load the chosen city only.

### 3D-21 — P1 — likely excessive mobile rendering cost

The reviewed `main` baseline uses 4096 shadow atlases and 4× MSAA (the project value `2` is the `MSAA_4X` enum); directional and omni lights cast shadows; many tiny procedural meshes also cast shadows; cylinders commonly use 48 segments; meshes/materials are recreated instead of cached/instanced. iOS renders at full `UIScreen.main.scale` and enables high refresh (`ios/Runner/GodotBoardIOSPlugin.swift`; `ios/Runner/Info.plist:5-6`). The feature-branch budget documented above remediates the largest attachment, shadow, tessellation, and refresh costs; caching/instancing, quality tiers, and minimum-device profiling remain follow-up work.

**Required change:** profile on the minimum supported iPhone/Android. Cache meshes/materials, use `MultiMesh` or combined static meshes, disable shadows on small props/pips/labels, add LOD/visibility ranges, reduce shadow atlas/render scale, and ship quality/FPS tiers.

### 3D-22 — P1 — 3D bootstrap has no health/recovery UX

If native 3D is available but readiness never arrives, the UI can remain on `Preparing 3D board...` with Roll disabled (`lib/widgets/board/godot_board_host.dart:45-57`; `lib/integration/godot_board_controller.dart:318-324`; `lib/screens/game_board_screen.dart:1157`).

**Required change:** add a readiness watchdog (roughly 8-12 seconds), diagnostic state, Retry, and Use 2D. Persist an Auto/3D/2D preference plus graphics quality and reduced-camera-motion settings.

### 3D-23 — P1 — native movement failure becomes a stall then teleport

`animateRoll` waits up to 12 seconds (`lib/integration/godot_board_controller.dart:223-234`). Failure is silently reduced to `movedInGodot=false`; Flutter performs an internal token-hop loop while the 3D surface remains visible, then syncs only at the end (`lib/screens/game_board_screen.dart:1916-1987`). The player can see a stationary pawn under a MOVING state, followed by a snap.

**Required change:** require quick native acknowledgement and progress, surface recovery, switch immediately to the visible 2D animation or animate each fallback waypoint in Godot, and log command id/reason.

### 3D-24 — P0 — a timed-out or previous-session roll can execute later

When a roll arrives while `active_tween` is running, Godot reschedules the same JSON command every 50 ms with no cancellation or session generation (`main.gd:4408-4421`). Flutter abandons its waiter after 12 seconds (`lib/integration/godot_board_controller.dart:223-234`), but that does not cancel the native retry. Because Android retains the engine across screens, an abandoned command can run after Flutter has fallen back—or even after a new session attaches—and move the wrong session's pawn.

**Required change:** every command must carry session and generation ids; native work must acknowledge, cancel, expire, and reject stale commands. Clearing/rebuilding/detaching a board must invalidate timers and queued commands. Add a test that times out a roll, starts another session, and proves no old animation or completion can run.

### 3D-25 — P2 — most cities are palette variants of one diorama

New York is the only hand-authored board; most other boards share center streets/building arrangements and primitive landmark recipes. A water ring even surrounds landlocked themes (`godot_3d/README.md:47-50`; `main.gd:899-1223`).

**Improve:** release a smaller number of genuinely finished cities first, or establish city-specific terrain, silhouette, landmark composition, materials, ambient life, and scale QA before claiming all 18 as equal-quality 3D destinations.

### 3D-26 — P1 — elevation conventions are inconsistent beyond pawns

Land, routes, tiles, buildings, and “recessed” water use conflicting top elevations (`main.gd:934-1003`, `1056-1095`). Raised water, floating building bases, and contact-shadow gaps are likely across cities.

**Required change:** document a world elevation system and enforce asset ground anchors/sockets or bounds-based placement for every city asset.

## 7. Game flow, state, and navigation

### FLOW-01 — P0 — Victory actions target a disposed navigation owner

Game Over uses `Navigator.pushReplacement` to replace the route that contains `AppNavigator`, then passes `widget.onRestart`/`widget.onQuit` closures owned by that replaced state (`lib/screens/game_board_screen.dart:2958-2972`; `lib/app.dart:171-213`). Replay/Home can call `setState` on a disposed state or fail to navigate.

**Required change:** make Victory an explicit primary app state or use navigator-owned result routes. Test Replay, Home, system Back, restored sessions, and multiple victories.

### FLOW-02 — P1 — Pause is not a real pause

An active roll/movement sequence does not consult `_isPaused` across awaits (`lib/screens/game_board_screen.dart:497`, `1828-1993`). The pause dialog pops before nested Restart/Quit/Load/Support confirmation completes, so its `.then(onClose)` unpauses gameplay behind the child dialog (`lib/widgets/dialogs/game_menu_dialog.dart:97-160`, `388-402`).

**Required change:** put turn execution behind a cancellable state machine/pause token. Pause timers, AI, native animation progression, modal scheduling, and mini-games on Pause and app background.

### FLOW-03 — P1 — gameplay remains interactive while movement resolves

3D tile/player/landmark taps and Trade, Bank, Power-up, and Menu remain enabled while `_isProcessingTurn` is true (`lib/screens/game_board_screen.dart:239-308`, `905-913`, `991-1118`). Landing can then open another modal on top; Restart/Quit can dispose the screen while `_rollDice` later runs unguarded `setState`.

**Required change:** central phases such as `idle → rolling → moving → resolving → modal → endTurn`, one serialized modal queue, cancellable operations, and mounted/generation checks after every await. Only a true Pause control should remain during resolution.

### FLOW-04 — P1 — Jail resolution is not awaited

`TileActionType.goToJail` calls `_handleGoToJail(player)` without `await`, then can continue to win checking and end-turn delay (`lib/screens/game_board_screen.dart:2021-2056`). The Jail dialog/animation can overlap the next phase.

**Required change:** await the complete presentation/state transition and include it in the same turn state machine.

### FLOW-05 — P1 — system Back bypasses app navigation and confirmations

There is no `PopScope` or `WillPopScope`. Android Back on setup/settings/help/game can exit the app or bypass the visible Quit behavior, and mini-games can return a zero result without confirmation.

**Required change:** define system-back semantics for every primary screen/modal and add integration tests.

### FLOW-06 — P1 — app lifecycle pauses audio, not gameplay

`AppNavigator` responds to lifecycle for audio, but in-flight gameplay and mini-game timers continue (`lib/app.dart:85` and mini-game sources). Backgrounding during movement, auctions, or a timed mini-game can resolve unseen.

**Required change:** central lifecycle pause for Flutter turn execution, timers, modal queue, and Godot processing; resume with an explicit state reconciliation.

### FLOW-07 — P1 — no autosave or robust Continue recovery

Continue has no save preview, timestamp, load state, retry, or corrupt-save recovery despite available metadata (`lib/app.dart:215`; `lib/services/save_service.dart:102`). There is no lifecycle autosave.

**Required change:** autosave only at stable turn boundaries; show city/players/round/time, validate schema, support migration/corrupt recovery, and make Quit copy accurately describe saved vs unsaved progress.

### FLOW-08 — P2 — Start Game can be submitted repeatedly

Board data loads asynchronously but Start has no busy/disabled state or double-tap guard (`lib/app.dart:126-165`; `lib/screens/game_setup_screen.dart:110`, `1621`).

**Improve:** single-flight creation, progress state, cancellation/error UX, and a repeated-tap test.

## 8. Screen-by-screen UI/UX review

| Screen or surface | Coverage | What works | Updates required before release |
|---|---|---|---|
| Native + Flutter splash | Runtime/source | Flutter art establishes the modern city tone. | Native purple and Flutter navy/city splashes mismatch; services block startup and Flutter adds another 1.5 s delay (`pubspec.yaml:123`, `lib/screens/splash_screen.dart:60-75`, `lib/main.dart:19`). Use one branded launch transition and measure time-to-interactive. |
| Main menu | Runtime | Clear hierarchy, strong visual identity, good phone safe-area fit. | Shop callback exists but no Shop control is rendered. Continue needs save metadata/error UX. Many custom items expose text rather than button semantics. |
| Setup — Choose Board | Runtime | Country/city/player/dice grouping is understandable; scroll works on phone. | Header truncation; city carousel clips without a strong continuation cue; color/city states need semantics; the footer hides much of the second panel until scroll. Add loading/error state and double-submit guard. |
| Setup — Player Setup | Runtime | Two-player portrait layout is visually clear. | Avatar takes large empty space on tablet; compact phone cards are dense; fixed grid is not keyboard-aware; AI controls and swatches are small; color is the only signal; avatar choice does not preview/control the 3D pawn. |
| Avatar picker/custom photo | Static | Multiple identity choices. | Tiles lack useful labels/selected state; deletion is long-press only; clarify portrait versus 3D token identity and privacy/storage behavior for custom photos (`lib/widgets/avatar/avatar_selector.dart:300-410`). |
| How to Play | Runtime | Phone portrait and landscape layouts are polished and understandable. | Tablet visual panel wastes space; top lesson tabs need stronger small-phone discoverability; content omits 3D camera/reset/inspection, Save/Pause, cards, and mini-games; final CTA does not do what it says. |
| Settings | Runtime | Tablet two-column organization is a good reference for other screens. | Phone header truncates and requires dense scrolling; language popup can cover support content; non-audio settings do not persist; Reset does not reset the persisted audio service; no board mode/quality/reduced-motion/notification controls. |
| Game — 2D fallback | Runtime | Core roll loop is visible and Roll is prominent on phone. | Board text/targets are tiny; supported landscape overflows; large screen space is unused; provide phone navigation/semantic zoom and eliminate debug overflows. |
| Game — 3D host/HUD | Flutter runtime + static 3D | Native host is integrated and the concept is strong. | Simulator cannot render it; loading starts with 2D then swaps; no permanent fallback; HUD lacks opponents; roll controls are width-unsafe; phone 3D gestures are not taught; many strings/currency are hardcoded. |
| City guide | Runtime | City storytelling/facts add personality. | Duplicate city name, false 3D claim in fallback, three ListTile assertions, unlabeled Close, and material/ink misuse. |
| Tile/property info | Runtime | Price/rent/history/tips are useful and the body can scroll. | Legacy palette, duplicate emoji/icon treatment, small/low-contrast copy, weak landscape scroll affordance, and mismatch with the selected city design system. |
| Player card/portfolio | Runtime | Key money/property concept is present. | Legacy coral/green style, low-contrast empty-state text, and identity mismatch with chosen avatar/pawn. |
| Pause menu | Runtime | Actions are recognizable in portrait. | 364 px landscape overflow; Pause does not pause; confirmation nesting resumes the game; support/donation is misplaced in a frequent gameplay menu; style conflicts with the app. |
| Save/Load/Restart/Quit confirms | Runtime/source | Explicit destructive confirmation exists. | Misleading progress-loss copy; nested lifecycle race; no save preview/error; adaptive scroll needed; serialization required. |
| Buy/Upgrade/Rent/Tax/Jail | Runtime/source | The individual decisions are understandable. | Multiple unrelated visual themes; fixed dialogs fail landscape/large text; Jail is not awaited; all need shared modal structure, localization, and phase locking. |
| Auction | Static | Feature is implemented. | Fixed non-scrollable layout, untranslated copy, background/pause safety, accessibility and narrow/landscape coverage required. |
| Card Pick/Event | Static | Adds game variety. | Outer-surface tap is required to continue, copy can be as small as 8 px/ellipsized, English model strings bypass localization, modal races possible. Add explicit Continue and readable reveal. |
| Lucky Spin | Runtime/source | Reward state is clear enough to complete. | Redundant reward copy, low contrast, hardcoded `SPIN`, English prize models, legacy color system, adaptive dialog needed. |
| Power-ups | Static | Inventory/action concept exists. | Name, description, rarity, and `USE` bypass localization; actions remain usable during movement; clarify targeting/undo and add semantics. |
| Active events/achievements | Static | Feedback systems exist. | Fixed overlay positions can collide with roll/card/HUD; English content; achievements delay Victory by about four seconds each (`lib/screens/game_board_screen.dart:2937-2955`). Use one responsive overlay queue and show results immediately. |
| Memory Match | Static | Complete mini-game loop. | Timer starts immediately/no countdown, continues in background, grid is always four columns, targets lack semantic identity, Back returns zero without confirmation (`lib/screens/mini_games/memory_match_game.dart:33`, `220-278`). |
| Quick Tap | Static | Complete mini-game loop. | Timer starts immediately, target positions use full `MediaQuery` rather than actual playfield, can overlap HUD/insets or become stale after rotation (`lib/screens/mini_games/quick_tap_game.dart:38`, `70`, `223`). |
| Victory | Static | Dedicated results screen exists. | Navigation callbacks can target disposed owner; generic/black styling; currency hardcoded; confetti/shine ignore reduced motion; achievements delay entry. |
| Shop | **Blocked/unreachable** | UI exists in code. | `AppScreen.shop` and `onShop` are wired, but Main Menu never calls it (`lib/app.dart:291`; `lib/screens/main_menu_screen.dart:278`). It also simulates ads/purchases and reports equip success with TODO integration. Keep it out of release or complete product/economy/legal flows. |
| Leaderboard | **Blocked/unreachable** | Empty state exists. | No callers, no loading/error, sort chips may overflow and lack semantic selection (`lib/screens/leaderboard_screen.dart:90`, `254`). Remove dormant entry points or finish and test it. |

## 9. Visual-system and responsive recommendations

### UI-01 — P1 — build one design system, not one theme per dialog

Use the main/setup/settings system as the base and define reusable tokens for:

- background/scrim/surface/elevated surface;
- teal primary, gold reward, red danger, player identity colors;
- title/body/label/numeric typography;
- 48 dp minimum touch targets;
- primary/secondary/danger buttons;
- adaptive dialog/sheet shells;
- consistent icon container, corner radius, border, shadow, and motion duration.

Then migrate every game dialog. Avoid combining player color with semantic danger/success color.

### UI-02 — P1 — define responsive modes explicitly

At minimum:

- compact portrait: 320-389 dp;
- standard portrait: 390-599 dp;
- tablet portrait/split view: 600+ dp;
- compact landscape: height below 500 dp;
- large text: 1.3 and 2.0.

Do not treat landscape as a rotated portrait. The board, player rail, roll/action region, and dialogs each need a height-aware layout.

### UI-03 — P1 — one overlay-slot and modal queue system

Active event, achievement, card prompt, current-player pill, route state, and roll controller currently use independent fixed positions (`lib/screens/game_board_screen.dart:727-855`; `lib/widgets/achievements/achievement_notification.dart:338`). Define named safe slots per responsive mode and serialize high-priority overlays. Nothing should cover the active pawn, dice, destination, or primary action.

**Remediation (board overlay slots, in code):** `BoardOverlaySlots` is now the single source of truth for board chrome placement — the left edge serializes one column (gesture hint at the base, active-event indicators above it capped at two inline with a localized overflow chip, action-critical card-deck prompt above those), the right edge stays reserved for the roll control, and compact landscape tightens margins instead of overflowing. Covered by dedicated slot-math and rendering tests. Modal serialization inside dialogs (the modal-queue half of this finding) and achievement-notification routing remain open.

### UI-04 — P2 — scope immersive mode to gameplay

Immersive sticky is app-wide (`lib/main.dart:15`). Menu/setup/settings should use predictable system chrome/safe-area behavior; enter immersive only for the board and reliably restore it on every exit/error/background transition.

### UI-05 — P2 — remove dormant/parallel components from release surface

Shop, Leaderboard, legacy avatar/theme selectors, and parallel generic dialog implementations increase inconsistency and test scope. Either connect and finish them or remove them from the release target until they have a real product flow.

## 10. Accessibility release work

This needs a deliberate end-to-end pass; scattered fixes will not be enough.

### A11Y-01 — P1 — controls lack meaningful roles, labels, values, and state

Simulator accessibility exposed many custom InkWell/GestureDetector controls as text or generic elements. Dice/decks/tiles/player cards/mini-game targets lack game-specific labels. The visible game menu/music controls were better in landscape after Flutter aggregation, but setup and navigation remain inconsistent.

Add semantics for:

- `Roll dice; current result 4 and 3; double-tap to roll`;
- current player/turn/status and live roll/move/cash announcements;
- property name, type, price, owner, houses, selected state, and action;
- camera pan/zoom/reset buttons and an accessible board list;
- avatar identity, AI/human value, color name, selected/unavailable state;
- mini-game card identity and target actions.

### A11Y-02 — P1 — color-only choices and undersized targets

Setup color swatches are small and color-only (`lib/screens/game_setup_screen.dart:1386`). AI switches and several Back controls fall below common 44/48 dp targets (`:289`, `1235`; `lib/screens/settings_screen.dart:225`). Add shape/check/text state and expand hit areas.

### A11Y-03 — P1 — no accessible equivalent to the 3D board

Gestures and small world labels cannot be the only way to understand or inspect the board. Provide a screen-reader-friendly ordered tile list with current pawn positions, ownership, and `Inspect`/camera focus actions.

### A11Y-04 — P1 — motion preferences are ignored

Victory confetti/shine and cinematic camera/board animation do not honor reduced motion (`lib/screens/victory_screen.dart:41`, `401`). Add reduced motion, disable/shorten camera cuts and continuous decorative animation, and avoid blocking gameplay on motion completion.

### A11Y-05 — P1 — text scaling and contrast need measured verification

Small/ellipsized card copy, low-contrast subtitles, fixed dialogs, and truncated headers will worsen at 1.3-2.0 text scale. Run automated contrast checks and manual VoiceOver/TalkBack tests in all five locales.

## 11. Localization and content consistency

All five ARB files have the same 516-message structure, which is a good base. The feature branch localizes the new player-status rail, camera hints/actions, Start preparation state, and 3D readiness/recovery UI. Major enabled systems still bypass those catalogs:

- event category/title/body (`lib/widgets/dialogs/event_dialog.dart:119-232`; `lib/models/event_card.dart:37-247`);
- spin prize copy and hardcoded `SPIN` (`lib/widgets/spin_wheel/spin_wheel_widget.dart:164-205`; `lib/models/spin_prize.dart:54-138`);
- power-up name/description/rarity/`USE` (`lib/widgets/cards/power_up_card_widget.dart:148-229`; `lib/models/power_up_card.dart:25-225`);
- achievements (`lib/models/player_stats.dart:198-267`; `lib/widgets/achievements/achievement_notification.dart:161-194`);
- the city guide, card-deck prompt, and dice-selection SnackBar;
- Godot tile prices/world labels and compact 2D player pills use raw `$`; the new 3D status rail uses `CurrencyUtils`;
- Victory also uses raw currency.

`eventLastsRounds` manually appends an English `s`, which is incorrect for Japanese/Chinese and other plural systems (`lib/widgets/dialogs/event_dialog.dart:228-232`). Use ICU plural/select messages and stable content IDs.

Saved games serialize presentation-heavy tile data; changing language before loading can restore old-language tile names (`lib/models/game_state.dart:431`; `lib/app.dart:215`). Persist stable tile/content ids and rehydrate localized display data.

Also reconcile product metadata: README claims 17 languages while the runtime supports five, and product naming differs between UI/native labels.

## 12. Main-baseline build, test, and diagnostics status (`7f498c7`)

This section preserves the commands and failures from the original `main` review. The current feature-branch results are in **Feature-branch verification** above.

| Check | Result |
|---|---|
| `flutter test --reporter expanded` | **Pass:** 88/88 tests in approximately 7.8 s. |
| `flutter analyze` | **Fail:** 353 issues: 333 deprecated `withOpacity` calls, 7 async `BuildContext` hazards, 2 unused imports, and 11 other style/lint issues. The context hazards deserve correctness review; the deprecations can be a mechanical cleanup after blockers. |
| `flutter build apk --debug --no-pub` | **Pass:** approximately 130.5 s. Universal debug APK is 408,147,832 bytes (about 389 MiB); debug size is not a store-size measurement, but it reinforces the need to measure per-ABI release artifacts and Godot pack size. |
| `flutter build apk --release --no-pub` | **Fail:** `:app:compileReleaseJavaWithJavac` cannot resolve `net.jonhanson.flutter_native_splash` from `GeneratedPluginRegistrant.java:29`. The registrant references the dev dependency (`pubspec.yaml:66`), but whether the underlying cause is dependency classification, stale generation, or Flutter toolchain behavior still needs isolation. |
| iOS debug on iPad simulator | Built and ran. Xcode build completed in approximately 120 s. 3D intentionally fell back to 2D. |
| iOS debug on iPhone simulator | Built and ran. Xcode build completed in approximately 83 s. 3D intentionally fell back to 2D. |
| Targeted iOS Simulator `xcodebuild` | **Pass** with code signing disabled for the selected simulator. |
| Generic Flutter iOS Simulator build | **Blocked/toolchain:** Flutter/Xcode 27 beta architecture validation failed even though the framework contains `x86_64` and `arm64`. |
| iOS release, no code signing | **Unverified:** after approximately 344 s, Xcode failed with build-database I/O and SwiftGodot protocol-extraction errors. Re-run from a controlled clean CI/toolchain before attributing the I/O failure to product code. |
| Android emulator | Blocked: no AVD is installed. |
| 3D on iOS Simulator | Blocked by `targetEnvironment(simulator)` availability check. |
| Flutter runtime diagnostics | Failed clean-run expectation: three ListTile material assertions; compact landscape Roll overflowed 16 px to the right; Game Menu overflowed 364 px at the bottom. |

Existing responsive tests mainly exercise initial screens and the 2D fallback (`test/screens/game_board_responsive_test.dart:14-84`). Godot smoke tests use a synthetic sequential route and do not expose real 40→52 path-speed behavior (`godot_3d/tests/bridge_smoke.gd:94-117`). Static preview tests do not verify contact, overlap, color identity, occlusion, concurrent tweens, repeat sessions, mobile safe areas, or frame/thermal performance.

### Release-engineering blockers and gaps

- **P0:** Android release compilation fails as described above.
- **P0:** Android `release` currently uses the debug signing configuration (`android/app/build.gradle.kts:40`). Configure protected release signing in local/CI secrets and verify the store artifact.
- **P1:** Android reports the 3D renderer available unconditionally (`android/app/src/main/kotlin/com/hyu/properotyTycoon/MainActivity.kt:45`), even if the Godot pack is absent or invalid. Availability must validate the asset and version.
- **P1:** Godot packs are produced manually and have no CI freshness/smoke gate. Android expects Godot 4.7.1 while iOS tooling/package artifacts span 4.6.x/4.6.4. Pin one supported version and reject stale/mismatched packs.
- **P1:** no CI configuration was found. Add format/analyze/test, Android/iOS release compilation, Godot export/smoke, artifact-size budget, and device-lab smoke stages.
- **P1:** seven committed `ios/.symlinks` entries point to another developer's `/Users/maxwellreid/.pub-cache`. Generated absolute symlinks should not be source-controlled; recreate them per machine.
- **P1:** bundle identifiers contain `Properoty`/`properoty` (`android/app/build.gradle.kts:9`; `ios/Runner.xcodeproj/project.pbxproj:507`). Confirm whether these are already published identities before changing them; otherwise correct them before store provisioning and deep-link/service setup.
- **P1:** `debugPrint` can expose custom-avatar paths, raw JSON, ids, and filenames (`lib/services/custom_avatar_service.dart:92`). Remove/redact release logging and define retention/deletion behavior for user images.
- **P1:** the manifest requests exact-alarm permissions although scheduling uses inexact alarms (`android/app/src/main/AndroidManifest.xml:12`; `lib/services/notification_service.dart:319`); iOS declares background fetch/remote notifications for a local-notification implementation (`ios/Runner/Info.plist:61`). Minimize permissions/background modes before store review.
- **P2:** no Android adaptive launcher icon was found.
- **P2:** six bundled music tracks lack documented provenance; `assets/audio/MUSIC_LICENSES.md:3` covers only four city tracks. Complete license evidence before distribution.
- **P2:** README screenshots remain `Coming soon`, and its 17-language claim conflicts with the five supported locales (`README.md:18-21`; `lib/l10n/app_localizations.dart:99`).
- **P2:** Gradle 8.12, AGP 8.9.1, and Kotlin 2.1.0 already produce upcoming Flutter-support warnings. Schedule a controlled toolchain upgrade after the release build is reproducible.

## 13. Original recommended implementation sequence

### Phase 0 — restore correctness and build confidence

1. Fix Android release compilation and make CI run release builds.
2. Replace split/stale game ownership with one authoritative `GameSession`.
3. Repair Victory routing and define system Back behavior.
4. Introduce a cancellable turn state machine, real Pause, lifecycle pause, and one modal queue.
5. Fix Android Godot reattachment/readiness and add 3D timeout/Retry/Use 2D.
6. Build an adaptive modal shell; eliminate all landscape/debug overflows.
7. Add a standalone or native 3D mobile-aspect harness so QA can see 3D without a production device flow.

### Phase 1 — rebuild pawn placement and movement

1. Re-author ground anchors and central elevation sampling.
2. Implement occupancy-aware lane placement shared by pawn/marker/beacon/camera/picking.
3. Replace competing tweens with one movement director and command generation IDs.
4. Choose rigged low-poly character or coherent toy pawn; do not extend the current primitive pseudo-human.
5. Bridge authoritative appearance and preview it in setup.
6. Expand all intermediate waypoints and all special movement types.
7. Add deterministic motion capture tests for a complete lap and co-located players.

### Phase 2 — make 3D usable and performant on phones

1. Token-follow/path-bounds camera with safe frames and reduced-motion mode.
2. Coalesced gestures, accessible controls, proper raycast picking, and Reset Camera.
3. Compact player rail and responsive roll/actions.
4. Semantic zoom and a screen-space property detail system.
5. Resource caching/instancing, shadow/LOD/render-scale tiers.
6. Lifecycle deactivation and minimum-device performance/thermal profiling.

### Phase 3 — unify product UI and content

1. Move all dialogs to the modern design system.
2. Complete localization by stable ids and centralized currency formatting.
3. Add full VoiceOver/TalkBack, focus, large-text, contrast, and reduced-motion support.
4. Persist all settings atomically; add contextual notification consent.
5. Improve autosave/Continue/corrupt-save UX.
6. Remove or finish Shop, Leaderboard, and dormant/parallel components.

### Phase 4 — city/content polish

1. Select a smaller launch-quality city set or make every advertised city materially distinct.
2. Standardize city elevation/asset anchors and verify every landmark.
3. Replace misleading/redundant copy and finish 3D onboarding.
4. Run locale, orientation, save/load, mini-game, and long-session polish sweeps.

## 14. Release acceptance checklist

Do not call the 3D release ready until all of the following are demonstrated:

### State and navigation

- [ ] A game survives Help, Settings/backgrounding, Pause, Save/Load, rotation, and native view detach with a byte-for-byte equivalent authoritative state.
- [ ] Victory Replay/Home and system Back work repeatedly without disposed-state exceptions.
- [ ] Turn input is locked by phase and every modal is serialized/cancellable.
- [ ] Jail, cards, mini-games, teleport, backward moves, bankruptcy, and achievements cannot overlap/end a turn early.
- [ ] Autosave and corrupt-save recovery are covered.

### 3D motion and identity

- [ ] Soles/plinth sit exactly on every route surface; no clipping/floating at any camera angle.
- [ ] One player is centered; 2-4 co-located players do not overlap one another, houses, flags, or labels.
- [ ] Pawn, marker, beacon, picking, and camera share the same route anchor.
- [ ] No jitter or snap across idle → roll → move → land → idle.
- [ ] Speed is consistent across all 40 logical and 52 visual spaces.
- [ ] All dice, jail, card, reverse, and teleport movement modes animate intentionally.
- [ ] Setup preview, HUD, pawn, property flags, portfolio, and Victory identity match.

### Devices and performance

- [ ] Portrait and landscape captured at 320, 360, 390, large phone, and tablet/split-view sizes.
- [ ] Every dialog passes at text scales 1.0, 1.3, and 2.0 without clipping/overflow.
- [ ] First and second 3D sessions work, including same/different city and 2 → 4 players.
- [ ] All 18 advertised boards complete a load/move/pick/save/reopen smoke test—or unfinished boards are removed from launch.
- [ ] Minimum supported iOS and Android devices meet an explicit frame-time target with documented memory and thermal results over a long game.
- [ ] Godot stops rendering/processing when not visible.
- [ ] Release builds pass in CI for both platforms.

### Accessibility, localization, and UX

- [ ] VoiceOver/TalkBack can start a game, roll, inspect the board, make every decision, pause/save/quit, and understand Victory.
- [ ] Every control has role, label, value/state, logical order, and at least a 44/48 dp target.
- [ ] Turn, roll, movement, payment, card, and result changes are announced without duplicate noise.
- [ ] Reduced motion and 2D/3D/Auto controls are persisted and honored.
- [ ] English, Chinese, Japanese, Spanish, and French pass gameplay and long-text review; no raw model English or hardcoded currency remains.
- [ ] Notification permission is contextual and optional.
- [ ] Visual language is consistent across main screens, gameplay, dialogs, mini-games, and Victory.

## 15. Suggested regression suite

Add automated tests for:

1. Help round-trip preserves the complete active session.
2. Victory Replay/Home and repeated victories.
3. Android Back on every primary screen and modal.
4. Pause/background during dice, movement, property resolution, AI, auction, and mini-games.
5. Widget disposal during every awaited turn phase.
6. Modal queue collision cases: event + jail, achievement + card, tile tap + landing.
7. 3D unavailable/loading/ready/timeout/error/mismatched completion and visible fallback.
8. Reattached engine readiness, cached state, player-count change, and camera reset.
9. Ground-contact/occupancy snapshot tests and command-level movement timing.
10. Every dialog at compact landscape and text scale 2.0.
11. Semantics snapshots and live announcements.
12. Locale switching before/after save/load.
13. Setup keyboard, validation, async error, and repeated Start taps.
14. Mini-game countdown, background pause, rotation, constrained targets, and leave confirmation.
15. Release compilation and a physical-device 3D smoke run in CI/device lab.

## 16. Bottom line

The feature branch now implements the session/build, pawn-grounding, standard-route, readiness/recovery, AI authorization, camera, multi-player HUD, and typed special-movement foundations. The remaining path to a credible release is device breadth and sustained performance first, followed by coherent authored/rigged token identity, a small-phone 3D HUD, board-wide accessibility and localization, visual-system consolidation, protected signing/CI, and repeatable physical-device regression coverage — including a physical pass of the new special-movement presentations. More scenery should wait until those gates pass.
