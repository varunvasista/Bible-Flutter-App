# AI Bible Companion App

A Flutter-based, AI-powered Bible companion mobile application that combines daily scripture reading, journaling, and contextual spiritual guidance.

The app integrates a local Gemma language model to provide biblical encouragement and prayer suggestions while keeping core experiences available offline.

## Overview

The goal of this project is to provide a modern spiritual companion that helps users:

- read scripture daily
- reflect through journaling
- receive AI-guided prayer suggestions
- seek spiritual encouragement during difficult moments

## Main Features

### Home Dashboard

- Verse of the Day
- Reading streak tracking
- Prayer points generated from user context
- Continue Reading shortcut

### Bible Reader

- Browse Old and New Testament
- Read chapters and verses
- Bookmark and highlight passages

### Journal

- Write daily reflections
- AI analyzes journal entries and suggests prayer points

### Kyrie Assistant

- Previously called Panic Button
- Kyrie means Lord have mercy
- AI-guided spiritual support during difficult moments
- Uses a structured guidance dataset plus Gemma reasoning

### AI System

- Local Gemma language model
- Retrieval-Augmented Generation (RAG)
- Panic/Kyrie guidance dataset for biblical context

### Reading Plans

- Built-in and custom Bible reading plans
- Examples: 30 days, 90 days, 365 days
- Users can create their own custom duration plan

### Reminders

- Daily Bible reading reminder
- Daily prayer reminder
- Customizable times
- Default schedule:
	- Bible Reading: 7:00 AM
	- Prayer: 7:40 AM

### Offline Support

- Local AI model support
- Cached verses
- Offline journal and reading plans

## Tech Stack

- Flutter
- Dart
- Gemma LLM
- llama.cpp
- JSON datasets
- SharedPreferences
- Flutter Local Notifications

## Project Structure

```text
lib/
	ai/
	core/
	data/
	features/
		bible/
		home/
		journal/
		kyrie/     (implemented in the current codebase under features/panic/)
		settings/

assets/
	models/
	data/
	bible/
```

## Installation

1. Clone the repository
2. Install Flutter dependencies
3. Add the Gemma model file
4. Run the app

```bash
git clone <repo-url>
cd Bible-App
flutter pub get
flutter run
```

## Environment Variables

No environment variables are required. The app is designed to run fully offline using bundled local assets.

## AI Model Setup

The Gemma model file must be downloaded manually and placed in:

```text
assets/models/gemma-270m.gguf
```

The application can still run without the model, but AI generation quality and capabilities will be limited.

## Running and Development Commands

```bash
flutter pub get
flutter analyze --no-fatal-infos
flutter test
flutter run
```

## Roadmap

- Improved AI reasoning and response quality
- More personalized verse recommendations
- Cross-device syncing
- Continued UI and UX improvements
- Multilingual support

## Contributing

Contributions are welcome. Feel free to open issues, suggest improvements, and submit pull requests.

Recommended flow:

1. Create a feature branch
2. Implement and test your changes
3. Run analyzer and tests
4. Open a pull request with a clear description

## License

This project is licensed under the terms of the LICENSE file in this repository.
