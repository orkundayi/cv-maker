import 'cv_template.dart';
import 'modern_template.dart';
import 'minimal_template.dart';

/// Registry for managing available CV templates
class CVTemplateRegistry {
  // Private constructor for singleton
  CVTemplateRegistry._();

  // Singleton instance
  static final CVTemplateRegistry _instance = CVTemplateRegistry._();

  // Factory constructor returns singleton
  factory CVTemplateRegistry() => _instance;

  // Map of template ID to template instance
  final Map<String, CVTemplate> _templates = {};

  // Initialize with default templates
  void initialize() {
    // Register default templates
    registerTemplate(ModernTemplate());
    registerTemplate(MinimalTemplate());

    // Add more templates here in the future
    // registerTemplate(CreativeTemplate());
    // registerTemplate(ExecutiveTemplate());
    // registerTemplate(ProfessionalTemplate());
  }

  /// Register a new template
  void registerTemplate(CVTemplate template) {
    _templates[template.id] = template;
  }

  /// Get template by ID
  CVTemplate? getTemplate(String id) {
    return _templates[id];
  }

  /// Get all available templates
  List<CVTemplate> getAllTemplates() {
    return _templates.values.toList();
  }

  /// Get default template
  CVTemplate getDefaultTemplate() {
    return _templates.values.first;
  }

  /// Check if template exists
  bool hasTemplate(String id) {
    return _templates.containsKey(id);
  }
}
