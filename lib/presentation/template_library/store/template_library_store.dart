import 'package:mobx/mobx.dart';
import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:boilerplate/domain/entity/content/content_profile.dart';
import 'package:boilerplate/domain/usecase/content/get_content_profiles_usecase.dart';
import 'package:boilerplate/domain/usecase/content/create_content_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/content/update_content_profile_usecase.dart';
import 'package:boilerplate/domain/usecase/content/delete_content_profile_usecase.dart';

part 'template_library_store.g.dart';

class TemplateLibraryStore = _TemplateLibraryStore with _$TemplateLibraryStore;

abstract class _TemplateLibraryStore with Store {
  final String TAG = "_TemplateLibraryStore";
  final ErrorStore errorStore;
  final GetContentProfilesUseCase _getContentProfilesUseCase;
  final CreateContentProfileUseCase _createContentProfileUseCase;
  final UpdateContentProfileUseCase _updateContentProfileUseCase;
  final DeleteContentProfileUseCase _deleteContentProfileUseCase;

  // Observable variables
  @observable
  bool isLoading = false;

  @observable
  String inputUrl = '';

  @observable
  List<ContentProfile> contentProfiles = [];

  @observable
  WebsiteAnalysisResult? analysisResult;

  @observable
  bool isAnalyzing = false;

  @observable
  ContentProfile? selectedContentProfile;

  @observable
  bool isSavingProfile = false;

  @observable
  bool isDeletingProfile = false;

  // Constructor
  _TemplateLibraryStore(
    this.errorStore,
    this._getContentProfilesUseCase,
    this._createContentProfileUseCase,
    this._updateContentProfileUseCase,
    this._deleteContentProfileUseCase,
  );

  // Actions
  @action
  Future<void> fetchIndustryTemplates({String? projectId}) async {
    isLoading = true;
    try {
      // Use provided projectId or fallback to default
      final id = projectId ?? '9022c9d7-7443-4a33-96aa-56628ba81220';
      
      final profiles = await _getContentProfilesUseCase(params: id);
      contentProfiles = profiles;
      
      print('$TAG fetchIndustryTemplates: Loaded ${profiles.length} content profiles');
      
      errorStore.setErrorMessage('');
    } catch (error) {
      print('$TAG fetchIndustryTemplates error: $error');
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
  void selectContentProfile(ContentProfile profile) {
    selectedContentProfile = profile;
  }

  @action
  Future<void> createContentProfile({
    required String projectId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    isSavingProfile = true;
    try {
      final params = CreateContentProfileParams(
        projectId: projectId,
        name: name,
        description: description,
        voiceAndTone: voiceAndTone,
        audience: audience,
      );
      
      final newProfile = await _createContentProfileUseCase(params: params);
      contentProfiles = [...contentProfiles, newProfile];
      
      print('$TAG createContentProfile: Profile created successfully');
      errorStore.setErrorMessage('');
    } catch (error) {
      print('$TAG createContentProfile error: $error');
      errorStore.setErrorMessage(error.toString());
      rethrow;
    } finally {
      isSavingProfile = false;
    }
  }

  @action
  Future<void> updateContentProfile({
    required String projectId,
    required String contentProfileId,
    required String name,
    required String description,
    required String voiceAndTone,
    required String audience,
  }) async {
    isSavingProfile = true;
    try {
      final params = UpdateContentProfileParams(
        projectId: projectId,
        contentProfileId: contentProfileId,
        name: name,
        description: description,
        voiceAndTone: voiceAndTone,
        audience: audience,
      );
      
      final updatedProfile = await _updateContentProfileUseCase(params: params);

      final index = contentProfiles.indexWhere((p) => p.id == contentProfileId);
      if (index != -1) {
        contentProfiles = [
          for (var i = 0; i < contentProfiles.length; i++)
            if (i == index) updatedProfile else contentProfiles[i],
        ];
      }
      
      print('$TAG updateContentProfile: Profile updated successfully');
      errorStore.setErrorMessage('');
    } catch (error) {
      print('$TAG updateContentProfile error: $error');
      errorStore.setErrorMessage(error.toString());
      rethrow;
    } finally {
      isSavingProfile = false;
    }
  }

  @action
  Future<void> deleteContentProfile({
    required String projectId,
    required String contentProfileId,
  }) async {
    isDeletingProfile = true;
    try {
      final params = DeleteContentProfileParams(
        projectId: projectId,
        contentProfileId: contentProfileId,
      );
      
      await _deleteContentProfileUseCase(params: params);

      contentProfiles =
          contentProfiles.where((p) => p.id != contentProfileId).toList();
      
      if (selectedContentProfile?.id == contentProfileId) {
        selectedContentProfile = null;
      }
      
      print('$TAG deleteContentProfile: Profile deleted successfully');
      errorStore.setErrorMessage('');
    } catch (error) {
      print('$TAG deleteContentProfile error: $error');
      errorStore.setErrorMessage(error.toString());
      rethrow;
    } finally {
      isDeletingProfile = false;
    }
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
