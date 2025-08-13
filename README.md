# EchoScribe - Premium macOS Audio Recording & AI Transcription App

A beautiful, professional macOS application that records audio from system audio and/or microphone, provides real-time AI transcription, and generates intelligent notes with local privacy-first processing.

## 🎯 Project Overview

EchoScribe is designed to rival the design quality of Notion, Obsidian, and Notability with modern SwiftUI architecture. It combines powerful audio recording capabilities with AI-powered transcription to help you capture, organize, and extract insights from your conversations, meetings, and ideas.

### Key Features

- **High-Quality Audio Recording**: Record from microphone, system audio, or both simultaneously
- **Real-Time AI Transcription**: Live transcription with multiple note format options
- **Privacy-First Processing**: All AI processing happens locally on your device
- **Multiple Export Formats**: Export in Markdown, PDF, Plain Text, Rich Text, JSON, and CSV
- **Professional UI**: Beautiful, modern interface with smooth animations
- **Comprehensive Settings**: Extensive customization options for all aspects of the app
- **CoreData Integration**: Robust local database for notes and metadata
- **System Integration**: Native macOS integration with proper permissions

## 🏗 Architecture

### Project Structure

```
EchoScribe/
├── App/
│   ├── EchoScribeApp.swift          # Main app entry point
│   ├── ContentView.swift            # Main content view with three-panel layout
│   └── Info.plist                   # App configuration
├── Core/
│   ├── Audio/
│   │   ├── AudioRecordingManager.swift  # Audio recording and processing
│   │   └── PermissionManager.swift      # Permission handling
│   ├── AI/
│   │   └── TranscriptionManager.swift   # AI transcription and processing
│   ├── Database/
│   │   ├── NotesManager.swift           # CoreData integration
│   │   └── EchoScribeDataModel.xcdatamodeld/  # CoreData model
│   └── Export/
│       └── (Export functionality)
├── UI/
│   ├── Components/                  # Reusable UI components
│   ├── Views/
│   │   ├── OnboardingView.swift     # First-time setup
│   │   ├── SettingsView.swift       # Comprehensive settings
│   │   └── SetupView.swift          # Permission setup
│   ├── Styles/                      # Design system
│   └── Extensions/                  # SwiftUI extensions
├── Models/                          # Data models
├── Utils/                           # Utility functions
└── Resources/                       # Assets and resources
```

### Core Components

#### AudioRecordingManager
- Handles audio recording from microphone and system audio
- Supports multiple recording modes and quality settings
- Real-time audio level monitoring
- Integration with ScreenCaptureKit for system audio

#### TranscriptionManager
- AI-powered transcription using CoreML
- Multiple note formatting options
- Language detection and support
- Local processing for privacy

#### NotesManager
- CoreData integration for persistent storage
- Advanced search and filtering
- Export functionality in multiple formats
- Metadata management

#### PermissionManager
- Comprehensive permission handling
- System preferences integration
- User-friendly permission requests

#### SettingsManager
- Extensive app customization
- Persistent settings storage
- Import/export settings functionality

## 🚀 Getting Started

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/EchoScribe-Premium.git
   cd EchoScribe-Premium
   ```

2. **Generate Xcode project**
   ```bash
   # Install XcodeGen if you haven't already
   brew install xcodegen
   
   # Generate the Xcode project
   xcodegen generate
   ```

3. **Open in Xcode**
   ```bash
   open EchoScribe.xcodeproj
   ```

4. **Build and Run**
   - Select the EchoScribe target
   - Choose your development team for code signing
   - Build and run the project

### Required Permissions

The app requires the following permissions:

- **Microphone Access**: For audio recording
- **Screen Recording**: For system audio capture
- **Speech Recognition**: For real-time transcription
- **File Access**: For saving recordings and notes

These permissions are requested during the onboarding process.

## 🎨 Design System

### Color Palette

**Light Mode:**
- Background: `Color(.systemBackground)`
- Secondary: `Color(.systemGray6)`
- Accent: `Color(.systemBlue)`
- Text: `Color(.label)`

**Dark Mode:**
- Background: `Color(.systemBackground)`
- Secondary: `Color(.systemGray5)`
- Accent: `Color(.systemBlue)`
- Text: `Color(.label)`

### Typography Scale

- **Headlines**: SF Pro Display, Bold, 28pt
- **Subheadings**: SF Pro Display, Semibold, 22pt
- **Body**: SF Pro Text, Regular, 17pt
- **Captions**: SF Pro Text, Regular, 13pt
- **Live Transcription**: SF Mono, Regular, 16pt

### Layout

The app uses a three-panel layout:

1. **Left Sidebar** (280px): Navigation and quick actions
2. **Main Content** (flexible): Recording interface and notes
3. **Right Sidebar** (320px): Key points and live transcription

## 🔧 Configuration

### Project Settings

The project is configured with:

- **Deployment Target**: macOS 13.0
- **Swift Version**: 5.9
- **Code Signing**: Required for distribution
- **Hardened Runtime**: Enabled for security
- **Sandbox**: Enabled with necessary entitlements

### Entitlements

```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.device.microphone</key>
<true/>
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
<key>com.apple.security.files.documents.read-write</key>
<true/>
```

## 📱 Features

### Recording Capabilities

- **Multiple Sources**: Microphone, system audio, or both
- **Quality Settings**: Low, Medium, High, and Lossless
- **Real-time Monitoring**: Audio levels and duration
- **Pause/Resume**: Full recording control

### AI Transcription

- **Real-time Processing**: Live transcription as you record
- **Multiple Formats**: Detailed notes, summaries, bullet points, outlines, Q&A, timelines, action items, key points
- **Language Detection**: Automatic language detection and support
- **Confidence Scoring**: Quality indicators for transcriptions

### Note Management

- **Advanced Search**: Search across titles, content, and transcriptions
- **Filtering**: By date, starred status, audio presence
- **Sorting**: Multiple sort options
- **Export**: Multiple format support

### Export Options

- **Markdown**: Perfect for documentation
- **Plain Text**: Universal compatibility
- **Rich Text**: Formatted text with styling
- **JSON**: Structured data export
- **CSV**: Spreadsheet compatibility

## 🛠 Development

### Building

```bash
# Build for development
xcodebuild -project EchoScribe.xcodeproj -scheme EchoScribe -configuration Debug

# Build for release
xcodebuild -project EchoScribe.xcodeproj -scheme EchoScribe -configuration Release
```

### Testing

The project includes unit tests for critical functionality:

```bash
# Run tests
xcodebuild test -project EchoScribe.xcodeproj -scheme EchoScribe
```

### Code Style

- Follow Swift API Design Guidelines
- Use SwiftUI best practices
- Implement proper error handling
- Add comprehensive documentation

## 📦 Distribution

### App Store Distribution

1. **Archive the app**
   ```bash
   xcodebuild archive -project EchoScribe.xcodeproj -scheme EchoScribe -archivePath EchoScribe.xcarchive
   ```

2. **Export for App Store**
   - Use Xcode's Organizer
   - Select "App Store Connect" distribution
   - Upload to App Store Connect

### Direct Distribution

1. **Create DMG**
   ```bash
   # Use create-dmg tool
   create-dmg EchoScribe.dmg EchoScribe.app
   ```

2. **Code Sign**
   ```bash
   codesign --deep --force --verify --verbose --sign "Developer ID Application: Your Name" EchoScribe.app
   ```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Guidelines

- Follow the existing code style
- Add tests for new functionality
- Update documentation as needed
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Apple for SwiftUI and macOS frameworks
- The Swift community for inspiration and best practices
- Design inspiration from Notion, Obsidian, and Notability

## 📞 Support

For support and questions:

- Create an issue on GitHub
- Check the documentation
- Review the code comments

## 🔮 Roadmap

### Phase 1: Foundation ✅
- [x] Project structure and setup
- [x] Basic audio recording
- [x] Permission handling
- [x] CoreData integration

### Phase 2: Core Features 🚧
- [ ] Enhanced recording interface
- [ ] Real-time transcription
- [ ] Note management
- [ ] Export functionality

### Phase 3: AI Integration 📋
- [ ] CoreML Whisper integration
- [ ] Advanced note formatting
- [ ] Language detection
- [ ] Confidence scoring

### Phase 4: Polish & Performance 📋
- [ ] Performance optimization
- [ ] UI/UX improvements
- [ ] Accessibility features
- [ ] Comprehensive testing

### Phase 5: Advanced Features 📋
- [ ] Cloud sync
- [ ] Collaboration features
- [ ] Advanced export options
- [ ] Plugin system

---

**EchoScribe** - Transform your audio into intelligent notes with the power of AI.
