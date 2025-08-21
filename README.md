# CV Maker - Professional Resume Builder

A modern, responsive Flutter web application for creating professional resumes and CVs. Built with clean architecture principles and optimized for both desktop and mobile web browsers.

## ✨ Features

### 🎯 Core Functionality
- **Personal Information Management** - Contact details, social links, profile image
- **Professional Summary** - Write compelling professional summaries
- **Work Experience** - Add detailed work history with responsibilities
- **Education** - Academic background and qualifications
- **Skills Management** - Technical and soft skills with proficiency levels
- **Languages** - Language proficiency with standardized levels
- **Certificates** - Professional certifications and licenses
- **Projects Portfolio** - Showcase personal and professional projects

### 🚀 Export Options
- **PDF Export** - Professional PDF format for printing and sharing
- **JSON Export** - Data backup and transfer
- **HTML Export** - Web-friendly format with styling

### 📱 Responsive Design
- **Mobile-First Approach** - Optimized for mobile devices
- **Desktop Experience** - Full-featured desktop interface
- **Tablet Support** - Adaptive layouts for all screen sizes
- **Touch-Friendly** - Optimized for touch interactions

### 💾 Data Management
- **Auto-Save** - Automatic data persistence
- **Local Storage** - Secure local data storage
- **Data Backup** - Automatic backup creation
- **Import/Export** - Easy data transfer between devices

## 🛠️ Technology Stack

- **Frontend**: Flutter Web
- **State Management**: Riverpod
- **PDF Generation**: pdf package
- **Responsive Design**: Responsive Framework
- **Icons**: Phosphor Icons
- **Architecture**: Clean Architecture

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.9.0 or higher)
- Dart SDK
- Web browser (Chrome, Firefox, Safari, Edge)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/cv_maker.git
   cd cv_maker
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome
   ```

4. **Build for production**
   ```bash
   flutter build web
   ```

## 📁 Project Structure

```
lib/
├── core/                    # Core application code
│   ├── constants/          # App constants and configuration
│   ├── theme/              # App theme and styling
│   └── utils/              # Utility functions
├── features/               # Feature modules
│   └── cv_builder/        # CV building feature
│       ├── data/          # Data layer
│       │   └── services/  # External services
│       ├── domain/        # Business logic and models
│       └── presentation/  # UI components
│           ├── pages/     # Screen implementations
│           ├── providers/ # State management
│           └── widgets/   # Reusable UI components
└── shared/                # Shared components
    └── widgets/           # Common UI widgets
```

## 🎨 Design System

### Color Palette
- **Primary**: #2563EB (Professional Blue)
- **Secondary**: #64748B (Neutral Gray)
- **Success**: #10B981 (Green)
- **Warning**: #F59E0B (Orange)
- **Error**: #EF4444 (Red)

### Typography
- **Headings**: Bold, professional fonts
- **Body Text**: Readable, clean typography
- **Responsive**: Adaptive font sizes for different screen sizes

### Spacing
- **Consistent**: 8px base unit system
- **Responsive**: Adaptive spacing for different screen sizes
- **Accessible**: Proper spacing for touch targets

## 📱 Responsive Breakpoints

- **Mobile**: < 600px
- **Tablet**: 600px - 1024px
- **Desktop**: > 1024px

## 🔧 Configuration

### Environment Variables
The application uses default configurations that can be customized:

- **PDF Settings**: Font family, sizes, and formatting
- **Image Settings**: Supported formats and size limits
- **Storage Settings**: Local storage configuration

### Customization
- **Theme**: Modify colors, typography, and spacing
- **Layout**: Adjust responsive breakpoints
- **Export**: Customize PDF and HTML templates

## 📊 Performance Features

- **Lazy Loading** - Components load as needed
- **Optimized Images** - Automatic image compression
- **Efficient State Management** - Minimal rebuilds
- **Web Optimization** - Flutter web best practices

## 🔒 Security Features

- **Local Storage Only** - No external data transmission
- **Input Validation** - Secure form handling
- **File Type Validation** - Safe file uploads
- **Data Sanitization** - XSS prevention

## 🌐 Browser Support

- **Chrome** (Recommended)
- **Firefox**
- **Safari**
- **Edge**
- **Mobile Browsers**

## 📈 Roadmap

### Phase 1 (Current)
- ✅ Basic CV building functionality
- ✅ Responsive design
- ✅ PDF export
- ✅ Local storage

### Phase 2 (Planned)
- 🔄 Multiple CV templates
- 🔄 Cloud storage integration
- 🔄 Collaboration features
- 🔄 Advanced formatting options

### Phase 3 (Future)
- 📋 AI-powered content suggestions
- 📋 Integration with job platforms
- 📋 Analytics and insights
- 📋 Multi-language support

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Riverpod for state management
- Phosphor Icons for beautiful icons
- The open-source community

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/cv_maker/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/cv_maker/discussions)
- **Email**: support@cvmaker.com

## 🔗 Links

- **Live Demo**: [https://cvmaker.com](https://cvmaker.com)
- **Documentation**: [https://docs.cvmaker.com](https://docs.cvmaker.com)
- **API Reference**: [https://api.cvmaker.com](https://api.cvmaker.com)

---

**Made with ❤️ using Flutter Web**
