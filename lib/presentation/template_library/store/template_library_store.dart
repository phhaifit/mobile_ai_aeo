import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/presentation/template_library/models/writing_style_model.dart';

part 'template_library_store.g.dart';

class TemplateLibraryStore = _TemplateLibraryStore with _$TemplateLibraryStore;

abstract class _TemplateLibraryStore with Store {
  final String TAG = "_TemplateLibraryStore";
  final ErrorStore errorStore;

  // Observable variables
  @observable
  bool isLoading = false;

  @observable
  String inputUrl = '';

  @observable
  List<WritingStyleModel> industryTemplates = [];

  @observable
  WebsiteAnalysisResult? analysisResult;

  @observable
  bool isAnalyzing = false;

  @observable
  WritingStyleModel? selectedTemplate;

  // Constructor
  _TemplateLibraryStore(this.errorStore);

  // Actions
  @action
  Future<void> fetchIndustryTemplates() async {
    isLoading = true;
    try {
      await Future.delayed(Duration(milliseconds: 600));

      industryTemplates = [
        // Technology/SaaS Templates
        WritingStyleModel(
          id: 'tech_startup',
          name: 'Tech Innovator',
          description:
              'Forward-thinking, cutting-edge communication style for emerging tech companies.',
          voice:
              'Visionary, dynamic, approachable. Uses contemporary language and industry jargon naturally. Balances technical depth with accessibility. Emphasizes innovation and future possibilities. Conversational yet authoritative.',
          tone:
              'Energetic, optimistic, slightly rebellious. Challenges conventional thinking while maintaining credibility. Quick-paced and forward-looking. Occasionally uses humor and wit to engage. Confident without being arrogant.',
          audience:
              'Tech-savvy entrepreneurs, venture capitalists, early adopters (ages 25-45). Decision-makers in the SaaS space who value innovation and ROI. CTOs, product managers, and growth-focused leaders.',
          industry: 'Technology/SaaS',
          color: '#007AFF',
        ),
        WritingStyleModel(
          id: 'enterprise_solution',
          name: 'Enterprise Authority',
          description:
              'Comprehensive, data-driven approach for enterprise software and infrastructure.',
          voice:
              'Authoritative, precise, reliability-focused. Uses structured, professional language with technical accuracy. Emphasizes security, scalability, and measurable outcomes. Demonstrates deep industry expertise through detailed explanations.',
          tone:
              'Professional, methodical, trustworthy. Serious and solution-oriented. Uses evidence-based reasoning. Avoids hyperbole; instead focuses on verifiable benefits. Inspires confidence through competence.',
          audience:
              'CIOs, CTOs, IT directors, enterprise architects (ages 40-60). Organizations prioritizing stability, compliance, and long-term ROI. Risk-conscious decision-makers from finance and operations.',
          industry: 'Technology/SaaS',
          color: '#0051BA',
        ),

        // E-commerce Templates
        WritingStyleModel(
          id: 'ecommerce_lifestyle',
          name: 'Lifestyle Ambassador',
          description:
              'Aspirational, lifestyle-driven language for premium e-commerce and fashion brands.',
          voice:
              'Inspirational, curated, exclusive. Creates desire through storytelling and experience-focused narratives. Uses lifestyle language and trend awareness. Connects products to identity and self-expression. Warmly personal but stylishly refined.',
          tone:
              'Sophisticated, aspirational, engaging. Celebratory and inviting. Creates FOMO thoughtfully through scarcity and exclusivity. Empowers rather than pressures. Feels like advice from a trusted friend with great taste.',
          audience:
              'Fashion-conscious consumers, trend followers (ages 18-40). Urban professionals seeking quality and status. Individuals who view shopping as self-expression and lifestyle choice.',
          industry: 'E-commerce',
          color: '#FF2D55',
        ),
        WritingStyleModel(
          id: 'ecommerce_value',
          name: 'Value Hunter',
          description:
              'Deal-focused, value-conscious messaging for budget-friendly retail.',
          voice:
              'Friendly, clear, no-nonsense. Celebrates savings with genuine enthusiasm. Uses plain language and straightforward comparisons. Emphasizes quality-to-price ratio tirelessly. Feels like a savvy shopper sharing tips.',
          tone:
              'Enthusiastic about deals, practical, encouraging. Casual and authentic. Celebrates wins with customers. Transparent about savings and benefits. Creates urgency around limited deals without manipulation.',
          audience:
              'Budget-conscious shoppers, families, value-seekers (ages 25-55). Smart buyers who research prices and compare. Individuals who take pride in finding great deals and smart purchases.',
          industry: 'E-commerce',
          color: '#FFA500',
        ),

        // Healthcare Templates
        WritingStyleModel(
          id: 'healthcare_empathy',
          name: 'Patient-Centric Care',
          description:
              'Compassionate, accessible communication for patient-facing healthcare services.',
          voice:
              'Warm, empathetic, reassuring. Uses plain English avoiding unnecessary medical jargon. Acknowledges patient concerns and fears respectfully. Provides clear, actionable guidance. Demonstrates genuine care through attentive language.',
          tone:
              'Comforting, trustworthy, patient-focused. Calm and confident. Never dismissive of concerns. Explains complex topics in understandable terms. Balances professionalism with human warmth.',
          audience:
              'Patients seeking health information, caregivers (ages 18-75). Individuals managing health concerns who need clear guidance. People building relationships with healthcare providers.',
          industry: 'Healthcare',
          color: '#00B050',
        ),
        WritingStyleModel(
          id: 'healthcare_clinical',
          name: 'Clinical Precision',
          description:
              'Evidence-based, technically rigorous communication for medical professionals.',
          voice:
              'Scientific, precise, formally authoritative. Grounded in research and clinical evidence. Uses appropriate medical terminology accurately. Acknowledges complexity and nuance in treatment decisions. Respects practitioner expertise.',
          tone:
              'Professional, objective, carefully measured. Absent of marketing language. Substantive and detailed. Respects intelligence and experience of medical professionals. Open to ongoing evidence evolution.',
          audience:
              'Healthcare professionals, medical researchers, institutional administrators. Clinicians seeking evidence-based information. Organizations focused on clinical excellence and compliance.',
          industry: 'Healthcare',
          color: '#0078D4',
        ),

        // Marketing Templates
        WritingStyleModel(
          id: 'marketing_narrative',
          name: 'Brand Storyteller',
          description:
              'Narrative-driven, emotional connection-building for content marketing strategies.',
          voice:
              'Narrative-focused, emotionally intelligent, human-centered. Tells compelling stories that resonate beyond superficial benefits. Weaves brand values into relatable experiences. Authentic and genuine without manufactured emotion.',
          tone:
              'Warm, reflective, inspiring. Invites reflection and emotional connection. Celebrates customer stories and experiences. Thoughtful and unhurried. Builds community rather than just audiences.',
          audience:
              'Values-driven consumers, conscious shoppers (ages 25-50). Individuals seeking brands aligned with their beliefs. People who build loyalty around shared stories and values.',
          industry: 'Marketing',
          color: '#E61E24',
        ),
        WritingStyleModel(
          id: 'marketing_performance',
          name: 'Growth Catalyst',
          description:
              'Data-driven, conversion-focused messaging for performance marketing campaigns.',
          voice:
              'Clear, results-oriented, persuasive. Uses data and social proof confidently. Direct and benefit-focused. Speaks in terms of transformation and measurable outcomes. Energetic and action-oriented.',
          tone:
              'Confident, motivating, results-driven. Urgent without being pushy. Optimistic about possibilities. Uses power words strategically. Focuses on forward momentum and winning.',
          audience:
              'Results-conscious professionals, ambitious entrepreneurs (ages 25-55). Growth-minded individuals seeking competitive advantage. Decision-makers focused on ROI and KPIs.',
          industry: 'Marketing',
          color: '#FF6B35',
        ),
      ];

      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(error.toString());
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<void> generateFromWebsite(String url) async {
    isAnalyzing = true;
    inputUrl = url;
    try {
      // Simulate API call to analyze website
      await Future.delayed(Duration(seconds: 2));

      // Create realistic mock analysis results
      final recommendations = [
        WebsiteAnalysisResult(
          targetAudience:
              'Tech entrepreneurs and venture investors seeking innovative solutions',
          contentTone:
              'Forward-thinking and dynamic with technical credibility',
          recommendedTemplate: 'Tech Innovator',
          analysisDetails:
              'Website demonstrates cutting-edge technology positioning. Content emphasizes innovation, scalability, and future-focused messaging. Target audience appears to be early adopters and tech decision-makers.',
          analyzedAt: DateTime.now(),
        ),
        WebsiteAnalysisResult(
          targetAudience:
              'Enterprise clients prioritizing reliability and compliance',
          contentTone: 'Professional and methodical with emphasis on security',
          recommendedTemplate: 'Enterprise Authority',
          analysisDetails:
              'Analysis reveals focus on enterprise solutions with extensive documentation. Language emphasizes compliance, security, and measurable ROI. Audience consists of risk-conscious organizational leaders.',
          analyzedAt: DateTime.now(),
        ),
        WebsiteAnalysisResult(
          targetAudience:
              'Fashion-conscious consumers and lifestyle enthusiasts',
          contentTone: 'Aspirational and curated with lifestyle narratives',
          recommendedTemplate: 'Lifestyle Ambassador',
          analysisDetails:
              'Content uses imagery and narrative to create aspirational brand identity. Messaging connects products to lifestyle and personal expression. Strong social proof through influencer partnerships and user-generated content.',
          analyzedAt: DateTime.now(),
        ),
        WebsiteAnalysisResult(
          targetAudience: 'Value-conscious shoppers seeking quality deals',
          contentTone: 'Enthusiastic about savings with practical guidance',
          recommendedTemplate: 'Value Hunter',
          analysisDetails:
              'Website emphasizes competitive pricing and transparent value propositions. Frequently highlights deals and savings. Target customers appreciate straightforward information and clear ROI.',
          analyzedAt: DateTime.now(),
        ),
      ];

      // Simulate random recommendation based on URL analysis
      analysisResult = recommendations[url.length % recommendations.length];
      errorStore.setErrorMessage('');
    } catch (error) {
      errorStore.setErrorMessage(error.toString());
    } finally {
      isAnalyzing = false;
    }
  }

  @action
  void selectTemplate(WritingStyleModel template) {
    selectedTemplate = template;
  }

  @action
  void clearAnalysisResult() {
    analysisResult = null;
    inputUrl = '';
  }

  @action
  void dispose() {
    // Cleanup
  }
}

/// Data model representing analysis results from website
class WebsiteAnalysisResult {
  final String targetAudience;
  final String contentTone;
  final String recommendedTemplate;
  final String analysisDetails;
  final DateTime analyzedAt;

  WebsiteAnalysisResult({
    required this.targetAudience,
    required this.contentTone,
    required this.recommendedTemplate,
    required this.analysisDetails,
    required this.analyzedAt,
  });
}
