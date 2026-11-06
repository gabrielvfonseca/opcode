Opcode — Developer Voice Platform
Product, Architecture & End-to-End Engineering Specification

Document type: Product Requirements + Technical Architecture + Engineering Execution Plan
Project: Developer-first fork of anomalyco/opcode
Codename: Opcode
Starting repository: https://github.com/anomalyco/opcode
Product direction: Unified Developer Voice Platform
Architecture strategy: Local-first, Rust-centered, modular monolith
Delivery strategy: Incremental implementation with testable milestones
Target platforms: macOS, Windows, Linux
Primary users: Software developers and AI-assisted developers
Status: Implementation specification
Audience: Autonomous coding agents, engineering agents, reviewers and maintainers

0. Instructions to All Coding Agents

This document is the product and engineering source of truth.

Your responsibility is to transform the existing Opcode fork into a polished, reliable, developer-first voice platform.

You are not being asked to produce a mockup, a proof of concept, or a collection of disconnected features.

You are building a complete, installable, production-quality application.

0.1 Mandatory working principles
Inspect the existing repository before modifying it.
Preserve existing working functionality unless a documented decision justifies changing it.
Do not rewrite working subsystems simply to match the proposed directory structure.
Reuse existing Rust infrastructure, audio capture, speech recognition, native integrations and desktop functionality.
Do not introduce unnecessary dependencies.
Do not create placeholder implementations that report success without performing the advertised operation.
Do not leave critical features as TODOs while marking milestones complete.
Write tests alongside implementation.
Run relevant tests after every meaningful change.
Maintain compatibility with macOS, Windows and Linux.
Keep local speech recognition functional without an internet connection after model installation.
Never transmit audio, source code, transcripts or project context to external services without explicit user authorization.
Document architecture decisions in ADRs.
Never claim hardware verification based solely on mocked tests.
Update documentation, feature maps and the roadmap whenever behavior changes.
0.2 Agent execution protocol

Work in the following order:

Inspect.
Document.
Plan.
Implement.
Test.
Review.
Integrate.
Verify.
Update documentation.

Before starting each milestone:

Identify affected modules.
Identify existing implementations that can be reused.
Identify migration risks.
Identify platform-specific implications.
Define acceptance criteria.

After completing each milestone:

Run formatting and lint checks.
Run unit tests.
Run relevant integration tests.
Run cross-platform compilation checks.
Inspect the actual diff.
Update the milestone report.
Record anything not physically verified.

Never silently skip a failed test.

0.3 Parallel agent coordination

Multiple coding agents may work simultaneously, but they must not independently change shared architectural contracts.

Suggested responsibilities:

Agent	Responsibility
Lead architect	Repository analysis, architecture, ADRs, integration
Core agent	Runtime, lifecycle, session management
Speech agent	Audio, transcription, models, vocabulary
Developer workflow agent	Profiles, formatting, transformations
CLI/API agent	CLI, SDK, runtime interfaces
Desktop agent	UX, settings, HUD, history
Platform agent	macOS, Windows, Linux reliability
QA agent	Tests, benchmarks, release verification
Documentation agent	Developer documentation and user guides

The lead architect owns shared interfaces and integration.

Agents must communicate contract changes before implementing dependent functionality.

1. Product Definition
1.1 Vision

Make voice a first-class way to work with software.

Opcode is a local-first developer voice platform that converts natural speech into accurate, contextually appropriate text and delivers it to the applications and tools developers already use.

It should make speaking a natural alternative to typing.

It is not primarily:

A chatbot.
A replacement for coding agents.
An autonomous software engineer.
A generic meeting application.
A cloud transcription service.

It is a voice input and workflow layer that connects developers to their existing environment.

1.2 Core value proposition

Speak what you are thinking. Get accurate, usable output wherever you are working.

The product must deliver four primary advantages:

Accuracy: understand technical vocabulary, identifiers, code terminology and developer instructions.
Integration: work with editors, terminals, documentation tools and AI coding agents.
Control: allow users to decide how speech is transformed and where it goes.
Privacy: local-first processing and explicit control over external services.
1.3 Primary audience
Audience A: Software developers

Developers working with:

TypeScript and JavaScript.
Python.
Rust.
Go.
Java.
C#.
SQL.
Shell scripting.
Markdown and documentation.

Typical tasks:

Writing code explanations.
Dictating technical requirements.
Writing tests.
Writing documentation.
Producing Git commit messages.
Explaining bugs.
Writing issue descriptions.
Audience B: AI-assisted developers

Users of:

Claude Code.
Cursor.
OpenCode.
Codex.
Other terminal-based and IDE-based coding agents.

Typical tasks:

Writing detailed agent instructions.
Describing implementation requirements.
Explaining bugs.
Reviewing proposed changes.
Asking agents to investigate code.
Refining implementation plans.
Audience C: Technical professionals
Engineering managers.
Technical writers.
Architects.
DevOps engineers.
QA engineers.
Product engineers.

Typical tasks:

Documentation.
Architecture decisions.
Meeting notes.
Technical reports.
Incident reports.
Code review explanations.
2. Product Principles

These principles govern every architectural and UX decision.

P1. Local-first

Local speech recognition is the default.

The application must remain usable without an internet connection after model installation.

External services are optional and explicitly configured.

P2. Voice is an input method, not an AI gimmick

The application should be extremely fast to activate.

The main workflow should require minimal interaction.

Users should not need to open a large interface every time they dictate.

P3. Predictable output

Speech should not unexpectedly become executable code or a command.

Every output transformation must be explicit, configurable and inspectable.

P4. Context-aware, not invasive

The application may use the foreground application and explicitly permitted project context.

It must not silently read arbitrary files, inspect source code or capture screen contents.

P5. No mandatory AI post-processing

Basic dictation should use a deterministic pipeline.

LLM transformations are optional.

P6. Reliability before feature count

A dictation that loses text is worse than a dictation that takes an additional 200 milliseconds.

Preserve accepted recordings and recover from failures.

P7. Platform parity

macOS, Windows and Linux are first-class platforms.

Platform-specific limitations must be documented.

P8. Extensibility without premature complexity

Build stable interfaces before building a marketplace or arbitrary third-party plugin system.

3. Product Scope
3.1 Product capabilities

The platform consists of the following capabilities.

Capability	Description	Priority
Global dictation	Push-to-talk voice input	P0
Local transcription	On-device speech recognition	P0
Developer profiles	Code-aware formatting and vocabulary	P0
Technical vocabulary	Project-specific names and terminology	P0
Output transports	Paste, type, clipboard, file, stdout	P0
CLI	Scriptable runtime access	P0
History	Search and reuse transcripts	P0
Runtime API	Shared interface for clients	P0
Pipeline inspection	Inspect transformations	P1
MCP	Agent interoperability	P1
IDE integration	Editor-aware workflows	P1
Project context	Explicit project-aware vocabulary	P1
Benchmarking	Developer transcription quality	P1
Meeting intelligence	Long-form transcription	P2
Plugin SDK	Third-party extensions	P2
Team features	Shared profiles and configuration	P3
3.2 Explicit exclusions for initial release

Do not implement the following in the initial MVP:

Autonomous code execution.
Automatic shell command execution.
Automatic source file modification.
An agent orchestration engine.
A cloud account system.
Mandatory cloud transcription.
A plugin marketplace.
Team collaboration infrastructure.
Complex OCR workflows.

These may be considered later through separate product proposals.

4. Core User Experience
4.1 Main interaction

The primary interaction is global push-to-talk.

Expected flow:

User presses a configurable global shortcut.
Recording indicator appears.
Microphone captures audio.
User speaks.
User releases the shortcut.
Speech is transcribed.
Active profile applies formatting and vocabulary rules.
Result is delivered to the configured output transport.
Transcript is saved in History according to user settings.
User can inspect or edit the result.

The experience must remain responsive while transcription is running.

4.2 Interaction modes

Implement these modes as separate, understandable concepts.

Standard dictation

Natural language transcription.

Developer mode

Technical terminology, identifier preservation and developer-friendly punctuation.

Code mode

Generate code-oriented text from explicit speech instructions.

Initial supported languages:

TypeScript.
JavaScript.
Python.
Rust.
Go.
SQL.
Terminal mode

Produce shell-oriented commands and scripts as text.

Do not execute generated commands automatically.

Documentation mode

Generate Markdown-friendly output.

AI prompt mode

Produce structured, coherent instructions for coding agents.

Do not automatically submit the prompt unless the user explicitly enables an authorized integration.

Raw transcription mode

Deliver the speech model's transcription without transformations.

This is essential for debugging and user trust.

4.3 Global shortcut behavior

Retain the existing Opcode shortcut system where possible.

Requirements:

Configurable push-to-talk.
Toggle mode where supported.
Shortcut conflict detection.
Platform-specific shortcut registration.
Recording ownership and cancellation semantics.
Clear feedback when a shortcut cannot be registered.
No silent loss of active recordings.
4.4 User interface

Main application sections:

Home.
Profiles.
Vocabulary.
History.
Models.
Integrations.
Settings.

The recording HUD should remain small and unobtrusive.

Provide:

Listening indicator.
Recording duration.
Transcription state.
Success/failure feedback.
Optional live transcript preview.
Cancel action where supported.
5. Target Architecture
5.1 Architectural strategy

Use a Rust-centered modular monolith.

Do not introduce distributed services or microservices.

The desktop application, CLI, SDK and MCP server should communicate with the same runtime implementation.

The runtime owns business logic.

The UI is a client.

5.2 Logical architecture
text
                   USER
                    |
          Global shortcut / CLI
                    |
                    v
              CLIENT LAYER
          +---------+---------+
          |         |         |
        Desktop    CLI       SDK
          |         |         |
          +---------+---------+
                    |
                    v
              RUNTIME API
                    |
          +---------+---------+
          |                   |
      Session Manager     Event Bus
          |                   |
          v                   v
       PIPELINE            Observers
          |
    +-----+------------------------+
    |             |                |
  Audio         Speech           Context
  Capture       Engine            Engine
    |             |                |
    +-------------+----------------+
                  |
            Normalization
                  |
            Vocabulary
                  |
           Output Profiles
                  |
        Optional AI Processing
                  |
             Validation
                  |
           Output Transport
                  |
              History

5.3 Proposed source organization

The actual existing source tree must be inspected before implementing this structure.

This is a logical target, not an instruction to move every existing module immediately.

text
/
├── apps/
│   ├── desktop/
│   ├── cli/
│   └── benchmark/
│
├── crates/
│   ├── runtime/
│   ├── api/
│   ├── core/
│   ├── audio/
│   ├── speech/
│   ├── models/
│   ├── pipeline/
│   ├── vocabulary/
│   ├── profiles/
│   ├── context/
│   ├── output/
│   ├── storage/
│   ├── sessions/
│   ├── privacy/
│   ├── events/
│   └── platform/
│
├── integrations/
│   ├── mcp/
│   ├── vscode/
│   ├── cursor/
│   └── terminal/
│
├── sdk/
│   ├── typescript/
│   └── rust/
│
├── profiles/
│   ├── general/
│   ├── developer/
│   ├── typescript/
│   ├── javascript/
│   ├── python/
│   ├── rust/
│   ├── go/
│   ├── shell/
│   ├── sql/
│   ├── markdown/
│   └── ai-prompt/
│
├── benchmarks/
├── fixtures/
├── docs/
│   ├── architecture/
│   ├── api/
│   ├── testing/
│   ├── security/
│   └── contributing/
│
├── scripts/
├── tests/
├── Cargo.toml
├── README.md
├── AGENTS.md
├── ROADMAP.md
├── CONTRIBUTING.md
└── SECURITY.md

5.4 Dependency rules

Enforce the following direction:

core must not depend on desktop UI.
runtime may orchestrate core capabilities.
audio must not depend on output transports.
speech must not depend on application-specific UI.
profiles must not directly manipulate the clipboard.
output must receive validated text and explicit destinations.
storage must not make network requests.
platform may implement OS-specific behavior behind stable interfaces.
CLI and desktop must not implement their own transcription pipelines.

Use dependency inversion where appropriate.

Avoid introducing abstraction layers for functionality that only has one implementation and no credible extension requirement.

6. Core Domain Model

Create explicit types rather than passing loosely structured strings between components.

Suggested Rust domain models:

rust
pub struct DictationSession {
    pub id: SessionId,
    pub started_at: DateTime<Utc>,
    pub finished_at: Option<DateTime<Utc>>,
    pub profile_id: ProfileId,
    pub state: SessionState,
    pub source: CaptureSource,
}

pub enum SessionState {
    Idle,
    Recording,
    Processing,
    AwaitingConfirmation,
    Delivering,
    Completed,
    Failed,
    Cancelled,
}

pub enum CaptureSource {
    GlobalShortcut,
    Cli,
    Api,
    Integration,
}

pub struct Transcript {
    pub id: TranscriptId,
    pub session_id: SessionId,
    pub raw_text: String,
    pub final_text: Option<String>,
    pub language: Option<String>,
    pub created_at: DateTime<Utc>,
}

pub struct ProcessingResult {
    pub raw: String,
    pub normalized: String,
    pub final_text: String,
    pub transformations: Vec<TransformationRecord>,
}

pub struct TransformationRecord {
    pub stage: String,
    pub changed: bool,
    pub description: Option<String>,
}


Use typed identifiers and timestamps consistently.

Avoid making the entire application depend on one shared mutable global settings object.

6.1 Session lifecycle

The session lifecycle must be deterministic.

text
IDLE
  |
  | Start
  v
RECORDING
  |
  | Stop
  v
PROCESSING
  |
  | Recognition completed
  v
TRANSFORMING
  |
  +------> REVIEW REQUIRED
  |             |
  |             | Accept
  |             v
  +--------> DELIVERING
                |
          +-----+-----+
          |           |
        Success      Failure
          |           |
          v           v
      COMPLETED    RECOVERABLE


Required guarantees:

Accepted audio must not disappear when a second recording starts.
Processing failure must preserve the recording or recoverable transcript.
Output failure must not erase the transcript.
Cancellation must have explicit semantics.
Shutdown during recording must follow a documented recovery policy.
A completed transcript must not be delivered twice accidentally.
Every session must have a stable identifier.
7. Audio and Speech Architecture
7.1 Audio capture

Reuse the existing Opcode audio implementation.

Responsibilities:

Microphone enumeration.
Input selection.
Audio capture.
Device changes.
Sample rate conversion.
Channel handling.
Buffer management.
Silence detection.
Voice activity detection.
Recovery after device disconnection.

Use bounded queues and explicit backpressure.

Avoid unbounded audio buffering.

7.2 Speech engine

Create a stable speech engine interface.

rust
pub trait SpeechEngine: Send + Sync {
    fn metadata(&self) -> ModelMetadata;

    async fn transcribe(
        &self,
        input: AudioInput,
        options: TranscriptionOptions,
    ) -> Result<TranscriptResult, SpeechError>;
}


Adapt this interface to existing synchronous and streaming implementations rather than forcing unnecessary rewrites.

Support:

Existing local Opcode speech models.
Streaming inference where available.
Whole-clip inference.
Language selection.
Configurable vocabulary hints.
Model warm-up.
Memory management.
Graceful fallback.
7.3 Model management

The model manager must provide:

Model discovery.
Download.
Integrity verification.
Installation.
Activation.
Removal.
Version tracking.
Hardware compatibility information.
Memory estimates.
Model-specific configuration.

Downloads must use trusted sources and verify checksums or signatures where available.

Do not silently download large models without explaining the operation.

7.4 Workload-specific models

Support different model selections for:

Interactive dictation.
Developer dictation.
Meeting transcription.

Do not require all users to install all models.

7.5 Speech benchmarks

Build a reproducible benchmark suite.

Measure:

Word error rate.
Character error rate.
Technical term accuracy.
Identifier accuracy.
Code-symbol accuracy.
Finalization latency.
Streaming latency.
CPU consumption.
Memory consumption.
GPU memory.
Model loading time.

Store benchmark metadata, including:

Model version.
Hardware.
OS.
Language.
Recording identifier.
Test dataset version.

Do not publish a single accuracy score without its dataset and methodology.

8. Developer Vocabulary System

This is a core differentiator.

8.1 Requirements

Users must be able to:

Add technical terms.
Add aliases.
Edit pronunciations.
Import vocabulary.
Export vocabulary.
Assign vocabulary to profiles.
Assign vocabulary to projects.
Disable individual terms.
Inspect corrections.

Example:

yaml
version: 1

terms:
  - canonical: TanStack Query
    aliases:
      - tan stack query

  - canonical: useMutation
    aliases:
      - use mutation

  - canonical: PostgreSQL
    aliases:
      - postgres

  - canonical: Drizzle ORM
    aliases:
      - drizzle

8.2 Vocabulary processing

Implement conservative corrections.

Never globally replace ambiguous words without context.

Each correction should include:

Original text.
Corrected text.
Matching rule.
Confidence or certainty.
Applicable profile.
8.3 Project vocabulary import

Optional import sources:

package.json.
Cargo manifests.
Python project metadata.
Go module declarations.
Java build metadata.
User-provided dictionaries.

Importing project data must be explicit.

Do not recursively scan the entire repository by default.

9. Output Profile System
9.1 Purpose

A profile defines how transcription becomes usable output.

Profiles are configuration-driven.

Do not hardcode individual languages and output modes throughout the runtime.

9.2 Profile schema

Proposed initial format:

yaml
schema_version: 1

id: typescript
name: TypeScript
description: Developer-friendly TypeScript output

mode: code

language:
  preferred: en
  allowed:
    - en

vocabulary:
  inherit: developer
  terms:
    - useEffect
    - useMemo
    - useCallback

formatting:
  preserve_identifiers: true
  punctuation: code
  code_blocks: true
  preserve_explicit_symbols: true

processing:
  normalization: conservative
  ai_rewrite: disabled
  preview: optional

output:
  default_transport: paste

9.3 Built-in profiles

Implement:

Profile	Expected behavior
General	Natural language
Developer	Technical prose
TypeScript	TypeScript-oriented output
JavaScript	JavaScript-oriented output
Python	Python-oriented output
Rust	Rust-oriented output
Go	Go-oriented output
SQL	SQL-oriented output
Shell	Shell command text
Markdown	Documentation
AI Prompt	Structured instructions

Profiles must remain editable.

9.4 Transformation architecture

Each processing stage should be independent.

text
RAW TRANSCRIPT
     |
     v
Normalization
     |
     v
Vocabulary corrections
     |
     v
Profile formatting
     |
     v
Optional contextual transformation
     |
     v
Optional AI rewrite
     |
     v
Validation
     |
     v
FINAL OUTPUT


Rules:

Preserve raw transcript.
Preserve transformation history.
Make each transformation inspectable.
Allow transformations to be disabled.
Allow raw mode.
Never make network-dependent AI rewriting mandatory.
10. Output Transport Architecture

Create an output transport abstraction.

rust
pub trait OutputTransport: Send + Sync {
    fn capabilities(&self) -> TransportCapabilities;

    async fn deliver(
        &self,
        request: DeliveryRequest,
    ) -> Result<DeliveryReceipt, DeliveryError>;
}


Initial transports:

Transport	Purpose
Paste	Insert into focused application
Type	Simulated typing
Clipboard	Copy result
Stdout	CLI output
File	Save transcript
API	Deliver to registered clients

MCP should expose the same runtime capabilities through a separate integration adapter.

10.1 Delivery guarantees

Delivery must distinguish:

Accepted.
Attempted.
Confirmed.
Failed.
Unknown.

Do not report that text was successfully inserted simply because a paste command was sent.

Where the operating system cannot verify target consumption, explicitly document the limitation.

Preserve clipboard contents safely where the platform permits.

Do not silently overwrite clipboard data.

11. Context Engine
11.1 Purpose

Determine how speech should be processed based on explicitly permitted context.

11.2 Initial context sources
Active application.
Active application bundle/package identity.
User-selected profile.
User-selected language.
Optional active project metadata.
Explicitly selected text.
Explicitly selected project vocabulary.
11.3 Context priority

Resolve profile selection in this order:

Explicit profile selected for the current session.
Explicit per-application user rule.
Explicit project rule.
Global default.
General profile.

Conflicts must be observable.

11.4 Privacy boundaries

Do not silently:

Read editor buffers.
Capture screen contents.
Read terminal history.
Inspect source files.
Upload project metadata.
Send context to external AI models.

Project context is opt-in.

The context engine must expose which information was used to process a session.

12. Runtime API

The runtime API is the most important architectural component.

It provides one stable interface to:

Desktop UI.
CLI.
TypeScript SDK.
Rust SDK.
MCP.
Future integrations.
12.1 API requirements

Support:

Runtime status.
Dictation start.
Dictation stop.
Dictation cancellation.
Session retrieval.
Transcript retrieval.
Profile management.
Vocabulary management.
Model management.
History search.
Output delivery.
Event subscription.
12.2 Transport

Prefer an existing in-process API where appropriate.

For cross-process access, use a local IPC mechanism appropriate to each platform.

Possible transports:

Unix domain sockets.
Windows named pipes.
An existing desktop-framework IPC mechanism.

Do not expose an unauthenticated network listener on 0.0.0.0.

For local IPC:

Restrict access to the current user.
Validate all messages.
Set message-size limits.
Authenticate clients where appropriate.
Prevent path traversal.
Apply explicit permissions to sensitive operations.

Do not introduce WebSockets simply because they are fashionable. Use them only if there is a concrete streaming integration requirement.

12.3 API versioning

Every public API must have a version.

Breaking changes require:

Version increment.
Migration documentation.
Compatibility tests.
Deprecation period where practical.
12.4 Example request
json
{
  "version": 1,
  "command": "dictation.start",
  "profile": "typescript",
  "source": "cli"
}

12.5 Example event
json
{
  "version": 1,
  "event": "transcription.completed",
  "session_id": "session_example",
  "profile": "typescript",
  "duration_ms": 1840,
  "text": "Create a retry mechanism",
  "output_status": "pending"
}


These examples are illustrative contracts. Agents must finalize serialization and error semantics in an ADR before implementation.

13. CLI Specification

The CLI must be a first-class product, not a thin collection of desktop commands.

Proposed executable: opcode.

Preserve the existing opcode command during migration if necessary.

13.1 Commands
bash
opcode status

opcode listen

opcode dictate

opcode dictate --profile developer

opcode dictate --profile typescript

opcode dictate --stdout

opcode dictate --transport clipboard

opcode dictate --raw

opcode transcribe recording.wav

opcode profiles list

opcode profiles show typescript

opcode profiles validate ./profile.yaml

opcode vocabulary list

opcode vocabulary add "TanStack Query"

opcode models list

opcode models benchmark

opcode history list

opcode history search "authentication"

opcode history export --format markdown

opcode config show

opcode config edit

opcode doctor

opcode version

13.2 CLI behavior
Human-readable output by default.
--json for machine-readable output.
Meaningful exit codes.
No accidental duplicate listeners.
Clear errors when runtime is unavailable.
Proper signal handling.
Ctrl+C cleanup.
Configurable microphone selection.
No GUI requirement for basic transcription.
13.3 CLI output contract

Example:

bash
opcode dictate --profile typescript --stdout


Expected:

Captures speech.
Transcribes.
Applies selected profile.
Writes final text to stdout.
Sends diagnostics only to stderr.
Returns a nonzero exit code on failure.
Never prints UI or progress text into stdout in machine mode.

Support shell pipelines.

14. MCP and AI Agent Integration
14.1 Goal

Allow AI agents to interact with Opcode without making Opcode an agent orchestrator.

14.2 Initial MCP tools

Implement the minimum useful tools:

opcode_status
opcode_list_profiles
opcode_get_profile
opcode_list_models
opcode_get_recent_transcripts
opcode_search_history
opcode_get_transcript

Optional later:

opcode_start_dictation
opcode_stop_dictation

Starting or stopping microphone capture through an agent must require explicit user authorization and clear UI feedback.

Do not expose arbitrary microphone recording to remote or untrusted MCP clients.

14.3 MCP security
Prefer stdio transport initially.
Read-only tools by default.
Explicit authorization for state-changing tools.
No arbitrary shell execution.
No unrestricted file access.
No arbitrary transcript export without permission.
Document sensitive data exposure.
14.4 Agent workflow

The initial supported workflow is:

text
Developer speaks
       |
       v
      Opcode
       |
       v
Transcription + formatting
       |
       v
IDE / Agent input
       |
       v
Agent processes request
       |
       v
Developer reviews response


Do not automatically approve agent changes or execute generated commands.

15. History and Storage
15.1 Storage strategy

Reuse the existing Opcode storage system where practical.

If a schema migration is needed, implement it incrementally.

Prefer SQLite if consistent with existing architecture.

15.2 Data model

Suggested entities:

Sessions
id
started_at
finished_at
status
profile_id
capture_source
model_id
error_code
Transcripts
id
session_id
raw_text
final_text
language
created_at
Transformations
id
transcript_id
stage
before_text
after_text
metadata
Profiles
id
name
configuration
created_at
updated_at
Vocabulary
id
canonical_term
aliases
scope
profile_id
enabled
Delivery records
id
transcript_id
transport
destination
status
attempted_at
completed_at

Use appropriate indexes.

Avoid storing full audio recordings by default.

15.3 Retention

Provide user-configurable retention:

No transcript history.
Keep transcripts.
Keep transcripts for a configured period.
Explicitly retain selected recordings.

Deletion must remove associated records and audio artifacts according to the configured policy.

16. Desktop Application
16.1 Product UX

Maintain a lightweight desktop experience.

Required sections:

Home
Current status.
Start dictation.
Active profile.
Recent sessions.
Model status.
Profiles
List profiles.
Create profile.
Edit profile.
Import/export.
Validate configuration.
Test transformations.
Vocabulary
Add terms.
Edit aliases.
Search terms.
Import project vocabulary.
Preview corrections.
History
Search transcripts.
Filter by profile.
Inspect raw output.
Inspect final output.
Inspect transformations.
Copy transcript.
Export transcript.
Delete transcript.
Models
Installed models.
Available models.
Download status.
Memory requirements.
Model activation.
Model deletion.
Benchmark results.
Integrations
CLI status.
MCP configuration.
IDE integrations.
Permissions.
Settings
Microphone.
Shortcuts.
Output behavior.
Language.
Privacy.
Storage.
Startup.
Theme.
Updates.
16.2 UI requirements
Consistent visual hierarchy.
Keyboard navigation.
Accessible controls.
No excessive modal dialogs.
Responsive settings layouts.
Clear error messages.
Reduced-motion support.
Cross-platform design consistency.

Use the existing desktop UI framework unless a documented technical reason requires a change.

17. Privacy and Security Architecture

Privacy is a core product feature.

17.1 Default guarantees
Local inference by default.
No account required.
No automatic cloud fallback.
No automatic audio upload.
No automatic source-code upload.
No arbitrary remote telemetry.
No hidden recording.
Explicit recording indicator.
17.2 External processing

If optional AI transformations use an external provider:

Identify the provider.
Show what data will be transmitted.
Obtain consent.
Allow the user to disable the provider.
Never use external processing as a silent fallback.
Keep API credentials out of logs.
17.3 Security testing

Test:

IPC authorization.
Invalid messages.
Oversized messages.
Path traversal.
Symlink handling.
Malformed profile files.
Malicious vocabulary imports.
Invalid model manifests.
Secret leakage in logs.
Unauthorized transcript access.
Unsafe external URLs.
Dependency vulnerabilities.

Use platform-native permission systems.

18. Testing Strategy

Testing is mandatory throughout development.

18.1 Unit tests

Required coverage:

Runtime
Session creation.
Session state transitions.
Concurrent sessions.
Cancellation.
Shutdown.
Error recovery.
Event ordering.
Audio
Device selection.
Device disconnection.
Empty audio.
Silence.
Sample conversion.
Buffer overflow.
Audio stream termination.
Speech
Model initialization.
Model loading failures.
Invalid audio.
Streaming transcription.
Whole-clip transcription.
Language selection.
Model fallback.
Vocabulary
Canonical terms.
Aliases.
Ambiguous terms.
Case handling.
Unicode.
Disabled terms.
Profile-specific vocabulary.
Profiles
Valid configurations.
Invalid configurations.
Missing fields.
Version migration.
Inheritance.
Conflict resolution.
Output
Clipboard delivery.
Paste failure.
Type failure.
Stdout behavior.
File output.
Duplicate delivery prevention.
Storage
Insert.
Update.
Search.
Delete.
Migration.
Retention.
Corrupt database recovery.
18.2 Integration tests

Required scenarios:

Start recording and stop recording.
Transcribe a fixture recording.
Apply a developer profile.
Apply vocabulary corrections.
Deliver text to a mock transport.
Save transcript.
Retrieve transcript.
Search history.
Export transcript.
Restart runtime and recover state.
Run CLI without desktop UI.
Connect an MCP client.
Recover from transcription failure.
Recover from delivery failure.
Process a second recording while an earlier one is finishing.
18.3 End-to-end tests

Build complete user journeys.

E2E-001: Basic dictation
Launch application.
Select model.
Grant microphone permission.
Press shortcut.
Play fixture audio or speak into microphone.
Release shortcut.
Verify transcript.
Verify delivery.
Verify history.
E2E-002: Developer dictation
Activate TypeScript profile.
Dictate a technical instruction.
Verify terminology.
Verify formatting.
Verify final output.
E2E-003: Terminal workflow
Run CLI.
Capture speech.
Emit text to stdout.
Verify stderr remains separate.
Verify exit status.
E2E-004: Agent prompt workflow
Select AI Prompt profile.
Dictate an instruction.
Verify output.
Insert into a test agent input.
Confirm no unintended execution.
E2E-005: Offline operation
Install model.
Disconnect network.
Start application.
Dictate.
Verify local transcription.
Verify no external service is contacted.
E2E-006: Failure recovery
Begin recording.
Interrupt audio device.
Verify failure feedback.
Verify recording recovery behavior.
Confirm no accepted transcript disappears.
18.4 Hardware verification

Mocked tests are insufficient for:

Physical global shortcuts.
Microphone permissions.
Native audio capture.
Clipboard behavior.
Actual typing.
Wayland portals.
macOS accessibility permissions.
Windows input handling.
GPU inference.

Maintain a manual hardware test matrix.

Record:

OS version.
Hardware.
Audio device.
Model.
Permission state.
Test procedure.
Result.
Evidence.
Known limitations.
18.5 CI matrix

Required CI:

Platform	Build	Unit	Integration
macOS ARM64	Yes	Yes	Yes
Windows x64	Yes	Yes	Yes
Windows ARM64	If supported by dependencies	Yes	Targeted
Linux x64	Yes	Yes	Yes
Linux ARM64	Yes	Yes	Targeted

Hardware-specific tests may run on dedicated self-hosted runners.

Do not label cross-compilation as native runtime verification.

18.6 Quality gates

Before release:

Formatting passes.
Lint passes.
Unit tests pass.
Integration tests pass.
No critical known data-loss defects.
No unresolved critical security issues.
Installer builds.
Upgrade behavior verified.
Model downloads verified.
Privacy documentation reviewed.
Release notes published.
19. Performance Goals

These are initial engineering targets, not established measurements.

Measure the existing fork first, then compare.

Metric	Target
Shortcut-to-recording feedback	Under 100 ms
Recording start reliability	At least 99.9% in controlled tests
Streaming display latency	Under 300 ms where supported
Finalization latency	Under 250 ms after inference completes
Idle CPU	Establish and improve platform baseline
Memory usage	Benchmark by model and hardware
Offline dictation	Fully supported
Transcript recovery	No loss of accepted sessions
Duplicate delivery	Zero in tested retry scenarios

Distinguish recognition latency from finalization and insertion latency.

Publish benchmark methodology.

20. Repository and Documentation Deliverables

Create and maintain:

text
AGENTS.md
README.md
ROADMAP.md
CONTRIBUTING.md
SECURITY.md
CHANGELOG.md

docs/
  PRODUCT.md
  ARCHITECTURE.md
  PRIVACY.md
  SECURITY.md
  TESTING.md
  PERFORMANCE.md

  architecture/
    runtime.md
    audio.md
    speech.md
    profiles.md
    context.md
    output.md
    storage.md
    ipc.md

  api/
    runtime-api.md
    events.md
    cli.md
    mcp.md
    sdk.md

  decisions/
    0001-modular-monolith.md
    0002-runtime-ownership.md
    0003-local-first-processing.md
    0004-profile-schema.md
    0005-output-transports.md
    0006-ipc-security.md

  testing/
    test-matrix.md
    hardware-verification.md
    benchmark-methodology.md

  releases/
    release-checklist.md


Update the actual file structure to match the existing repository where practical.

Do not duplicate existing documentation unnecessarily.

21. Implementation Milestones

Milestones are sequential delivery gates. Calendar estimates are planning assumptions and must be adjusted after repository reconnaissance.

M0 — Repository reconnaissance

Goal: Understand the actual Opcode implementation.

Tasks:

Clone and build the fork.
Inspect Cargo workspace.
Inspect desktop framework.
Inspect Rust module structure.
Inspect audio pipeline.
Inspect speech models.
Inspect configuration.
Inspect storage and history.
Inspect CLI.
Inspect SDK.
Inspect MCP.
Inspect platform adapters.
Inspect existing tests.
Identify technical debt.
Identify existing feature requests.
Map all reusable capabilities.

Deliverables:

docs/REPOSITORY_AUDIT.md
Existing architecture diagram.
Existing dependency map.
Existing feature inventory.
Test coverage report.
Migration and risk assessment.
Proposed ADRs.

Acceptance: No implementation redesign begins before the audit is complete.

M1 — Stabilize foundation

Goal: Establish a reliable fork and development workflow.

Tasks:

Fork identity and metadata.
License and attribution.
CI setup.
Build reproducibility.
Development instructions.
Agent instructions.
Release pipeline.
Baseline benchmarks.
Regression test inventory.

Deliverable: A buildable fork with repeatable tests and releases.

M2 — Runtime architecture

Goal: Make the runtime the shared source of truth.

Tasks:

Define domain models.
Define session lifecycle.
Define event model.
Define runtime API.
Define IPC boundaries.
Define error taxonomy.
Add runtime tests.
Preserve desktop compatibility.

Deliverable: Desktop functionality runs through the documented runtime contracts.

M3 — Developer profiles

Goal: Enable developer-specific transcription.

Tasks:

Profile schema.
Profile parser.
Validation.
Built-in profiles.
Profile inheritance.
Vocabulary integration.
Transformation history.
Raw transcription mode.
Profile tests.

Deliverable: Working developer profiles in the desktop application and runtime.

M4 — Output transports

Goal: Deliver text reliably across applications.

Tasks:

Transport interface.
Paste adapter.
Type adapter.
Clipboard adapter.
Stdout adapter.
File adapter.
Delivery status.
Retry behavior.
Duplicate prevention.
Platform verification.

Deliverable: The same transcript can be delivered through multiple transports.

M5 — Developer vocabulary

Goal: Improve technical transcription.

Tasks:

Canonical terms.
Aliases.
Profile-scoped vocabulary.
Project-scoped vocabulary.
Import/export.
Conservative corrections.
Preview and edit.
Accuracy benchmark.

Deliverable: Developers can configure and verify technical terminology.

M6 — CLI

Goal: Enable fully scriptable workflows.

Tasks:

Runtime connection.
Dictation commands.
Transcription commands.
Profile commands.
Model commands.
History commands.
JSON output.
stdout/stderr contract.
Exit codes.
Signal handling.
Documentation.

Deliverable: Useful dictation without launching the desktop UI.

M7 — Developer context

Goal: Adapt output to the working environment.

Tasks:

Foreground application detection.
Per-application rules.
Explicit project context.
Profile selection precedence.
Context visibility.
Permission controls.
Context tests.

Deliverable: Predictable context-aware profile selection.

M8 — MCP and SDK

Goal: Connect Opcode to developer tools and agents.

Tasks:

MCP stdio server.
Read-only tools.
Permission model.
TypeScript SDK.
Rust API documentation.
Integration examples.
Contract tests.

Deliverable: An external agent can retrieve permitted transcripts and interact with documented runtime capabilities.

M9 — Desktop UX

Goal: Integrate all developer functionality into a polished application.

Tasks:

Home.
Profiles.
Vocabulary.
History.
Models.
Integrations.
Settings.
Processing inspection.
Recording HUD.
Accessibility.
Cross-platform verification.

Deliverable: Complete desktop workflow.

M10 — Quality and performance

Goal: Establish product reliability.

Tasks:

Benchmark dataset.
Performance profiling.
Regression testing.
Hardware testing.
Audio device recovery.
Memory optimization.
Offline verification.
Security review.
Installer verification.

Deliverable: Reproducible release candidate.

M11 — Public beta

Goal: Validate with real developers.

Recruit users who regularly work with:

VS Code.
Cursor.
Terminal.
Claude Code.
Codex.
OpenCode.

Collect structured feedback about:

Accuracy.
Latency.
Usability.
Workflow integration.
Privacy.
Reliability.
Missing features.

Do not assume adoption from GitHub stars.

Deliverable: Beta feedback report and prioritized follow-up roadmap.

22. GitHub Epic and Issue Structure

Create GitHub milestones matching M0–M11.

Create these epics:

Epic	Suggested issue prefix
Repository audit	AUDIT
Runtime architecture	RUNTIME
Speech and audio	SPEECH
Profiles	PROFILE
Vocabulary	VOCAB
Output transports	OUTPUT
Context	CONTEXT
CLI	CLI
MCP and SDK	INTEGRATION
Desktop	UI
Storage	STORAGE
Security	SECURITY
Performance	PERF
Testing	QA
Documentation	DOCS
Release	RELEASE

Every issue must contain:

markdown
## Problem

What user or engineering problem does this solve?

## Scope

What is included?

## Out of scope

What must not be implemented?

## Existing code to inspect

Which modules and APIs should be reused?

## Implementation requirements

Specific expected behavior.

## Platform implications

macOS, Windows, Linux.

## Tests

Unit, integration, E2E and hardware requirements.

## Acceptance criteria

Observable conditions that establish completion.

## Documentation

Files that must be updated.


Do not create vague tickets such as "Improve developer experience."

Create small, independently testable issues.

23. Definition of Done

A feature is complete only when all applicable conditions are satisfied:

Implementation exists.
No placeholder behavior remains.
Existing functionality is preserved.
Error states are handled.
Unit tests pass.
Integration tests pass.
Platform implications are addressed.
User-visible behavior is documented.
API changes are documented.
Security implications are reviewed.
Performance implications are measured.
Relevant CI passes.
Actual hardware limitations are recorded.

A feature is not complete because the code compiles.

A feature is not complete because an agent says it is complete.

A feature is complete when its acceptance criteria are demonstrably satisfied.

24. Release Strategy
Alpha

Requirements:

Basic dictation.
Developer profiles.
Technical vocabulary.
Multiple output transports.
CLI.
Local inference.
Core automated tests.
Beta

Additional requirements:

Runtime API.
History.
MCP.
Context engine.
Improved desktop UX.
Benchmark suite.
Cross-platform hardware verification.
Stable 1.0

Requirements:

All P0 functionality.
Documented public API.
Supported migration path.
Reliable installers.
Offline operation.
Security review.
Performance report.
User documentation.
Release verification.

Do not attach a 1.0 version number to an incomplete product simply to meet a calendar target.

25. Product Success Metrics

Measure actual utility.

Primary metric

Successful developer voice sessions per active user.

A successful session is a session where the user obtains and delivers usable output.

Secondary metrics
Sessions per day.
Median transcription latency.
Technical vocabulary accuracy.
Percentage of transcripts edited before delivery.
Delivery failure rate.
Model loading time.
CLI usage.
Profile usage.
Retention of active users.
Offline usage.
Crash-free sessions.

Do not collect sensitive transcript content for product analytics.

Make any optional telemetry transparent and opt-in.

26. Product Expansion Roadmap

After the core platform is stable, consider the following.

Developer intelligence
Project-aware vocabulary.
Better identifier recognition.
Language-specific formatting.
Optional code-aware transformations.
Technical prompt templates.
Agent integrations
Cursor.
Claude Code.
OpenCode.
Codex.
Other agent interfaces.

Integrations should initially deliver text rather than control agent execution.

Meeting intelligence
Long-form transcription.
Speaker identification.
Technical meeting summaries.
Searchable decisions.
Action items linked to transcript evidence.
Extension ecosystem
Third-party profiles.
Model adapters.
Custom transformation plugins.
Integration SDK.

Only build third-party executable plugins once sandboxing and permissions are mature.

27. First Assignment to the Coding Agents

Do not start by implementing every feature in this specification.

Start with M0.

The first agent task is:

Perform a complete technical audit of the existing Opcode fork and produce an implementation map for this specification.

The audit must answer:

What already works?
What is experimental?
What is incomplete?
Which modules can be reused?
Which modules should be refactored?
Which existing user-requested features align with this product?
Which proposed capabilities already exist in some form?
What are the actual build and test commands?
What platform-specific limitations exist?
What are the highest-risk architectural changes?

Produce:

Repository audit.
Current architecture diagram.
Dependency graph.
Feature-to-module mapping.
Test coverage inventory.
Platform capability matrix.
Migration plan.
Initial ADRs.
Milestone issue backlog.

Then submit the proposed implementation plan for review before making broad architectural changes.

28. Final Instruction: What We Are Building

Every engineering decision must support this product:

Opcode is a local-first voice platform that allows developers to speak naturally and produce accurate, immediately usable text across their development environment.

Its first job is excellent dictation.

Its second job is developer-aware output.

Its third job is connecting that output to terminals, IDEs and AI coding agents.

Its long-term opportunity is becoming a universal voice interface for developer workflows.

Build the foundation first.

Preserve the working Opcode functionality.

Make the runtime reliable.

Make the output accurate.

Make the integrations useful.

Make the application delightful.

Do not optimize for the number of features. Optimize for the amount of friction removed from a developer's working day.

The final acceptance test for the product is simple:

A developer opens their IDE, holds a shortcut, explains a technical task in natural language, and gets accurate, correctly formatted output into their workflow in seconds — privately, reliably and without changing the tools they already love.

That is the product.

That is what we are building.
