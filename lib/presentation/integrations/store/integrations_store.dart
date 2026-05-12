import 'package:mobx/mobx.dart';
import 'package:boilerplate/data/network/apis/gsc/gsc_api.dart';
import 'package:boilerplate/data/network/apis/performance/performance_api.dart';
import 'package:boilerplate/data/service/google_auth_service.dart';
import 'package:boilerplate/di/service_locator.dart';

part 'integrations_store.g.dart';

class IntegrationsStore = _IntegrationsStore with _$IntegrationsStore;

abstract class _IntegrationsStore with Store {
  final GscApi _gscApi = getIt<GscApi>();
  final PerformanceApi _performanceApi = getIt<PerformanceApi>();
  final GoogleAuthService _googleAuthService = getIt<GoogleAuthService>();

  @observable
  bool isLoading = false;

  @observable
  String? currentProjectId;

  @observable
  bool isConnecting = false;

  @observable
  bool isConnected = false;

  @observable
  bool hasError = false;

  @observable
  String? errorMessage;

  @observable
  ObservableList<String> gscProperties = ObservableList<String>();

  @observable
  String? selectedGscProperty;

  // Mock Data GA4
  final List<String> ga4Streams = [
    'GA4 - Main Site',
    'GA4 - App',
    'GA4 - Blog'
  ];


  @observable
  String? selectedGa4Stream;

  // GSC Metrics
  final int gscImpressions = 12450;
  final int gscClicks = 3200;
  final double gscAveragePosition = 4.5;

  // GA4 Metrics
  final int ga4Sessions = 8900;
  final String ga4BounceRate = '45%';
  final int ga4KeyConversions = 150;

  @action
  Future<void> init() async {
    isLoading = true;
    hasError = false;
    errorMessage = null;

    try {
      currentProjectId = await _performanceApi.resolveProjectId();
      if (currentProjectId == null) {
        hasError = true;
        errorMessage = "No active project found. Cannot load Google Search Console integrations.";
        return;
      }

      final status = await _gscApi.getStatus(currentProjectId!);
      isConnected = status['connected'] == true;

      if (isConnected) {
        if (status['isValid'] == false) {
            hasError = true;
            errorMessage = "Google token is expired or revoked. Please reconnect.";
        } else {
            await _fetchSites(currentProjectId!);
            final linkedSite = await _gscApi.getLinkedSite(currentProjectId!);
            if (linkedSite != null && linkedSite['siteUrl'] != null) {
              final siteUrl = linkedSite['siteUrl'] as String;
              if (gscProperties.contains(siteUrl)) {
                selectedGscProperty = siteUrl;
              }
            }
        }
      }
    } catch (e) {
       hasError = true;
       errorMessage = e.toString();
    } finally {
      isLoading = false;
    }
  }

  Future<void> _fetchSites(String projectId) async {
    try {
      final sites = await _gscApi.getSites(projectId);
      gscProperties.clear();
      for (var site in sites) {
         if (site['siteUrl'] != null) {
           gscProperties.add(site['siteUrl'] as String);
         }
      }
      if (gscProperties.isNotEmpty && selectedGscProperty == null) {
        selectedGscProperty = gscProperties.first;
      }
    } catch (e) {
      hasError = true;
      errorMessage = "Failed to load GSC properties: ${e.toString()}";
    }
  }

  @action
  Future<void> connectGoogle() async {
    isConnecting = true;
    hasError = false;
    errorMessage = null;

    try {
      if (currentProjectId == null) {
        throw Exception("Project ID not found. Cannot connect GSC.");
      }

      final authResult = await _googleAuthService.signIn(
        scopes: ['openid', 'email', 'profile', 'https://www.googleapis.com/auth/webmasters.readonly'],
        offlineAccess: true,
      );

      await _gscApi.connectGsc({
        'projectId': currentProjectId,
        'code': authResult.code,
        'codeVerifier': authResult.codeVerifier,
        'redirectUri': authResult.redirectUri,
      });

      isConnected = true;
      await _fetchSites(currentProjectId!);

      selectedGa4Stream = ga4Streams.first; // Mock GA4
    } catch (e) {
      hasError = true;
      errorMessage = "Failed to connect Google: ${e.toString()}";
    } finally {
      isConnecting = false;
    }
  }

  @action
  Future<void> linkSelectedSite() async {
    if (selectedGscProperty == null || currentProjectId == null) return;
    try {
       await _gscApi.linkSite({
          'projectId': currentProjectId,
          'siteUrl': selectedGscProperty
       });
    } catch (e) {
       hasError = true;
       errorMessage = "Failed to link site: ${e.toString()}";
    }
  }

  @action
  Future<void> disconnect() async {
    if (currentProjectId == null) return;
    try {
      await _gscApi.disconnect(currentProjectId!);
      isConnected = false;
      selectedGscProperty = null;
      selectedGa4Stream = null;
      gscProperties.clear();
      hasError = false;
      errorMessage = null;
    } catch (e) {
      hasError = true;
      errorMessage = "Failed to disconnect: ${e.toString()}";
    }
  }

  @action
  void simulateError() {
    hasError = true;
    errorMessage = "Simulated error occurred.";
  }
}
