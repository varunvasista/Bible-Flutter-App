# Architecture

The app follows a modular Flutter architecture optimized for offline execution.

## Layers

- `lib/core/`: shared utilities, constants, and cross-cutting services.
- `lib/data/`: models, repositories, and data loaders.
- `lib/features/`: user-facing modules (`bible`, `panic`, `journal`, `home`).
- `lib/ai/`: local model integration and prompt/guidance pipeline.

## Principles

- Keep UI concerns inside `features/*/screens` and `features/*/widgets`.
- Keep retrieval and persistence in repositories/services.
- Keep local AI orchestration isolated in `lib/ai/`.
- Keep app boot wiring centralized in `lib/main.dart` and `lib/core/service_locator.dart`.
