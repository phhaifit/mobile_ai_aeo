import 'package:mobx/mobx.dart';

part 'integrations_store.g.dart';

class IntegrationsStore = _IntegrationsStore with _$IntegrationsStore;

abstract class _IntegrationsStore with Store {
  @observable
  bool isConnecting = false;

  @observable
  bool isConnected = false;

  @observable
  bool hasError = false;

  // Mock Data
  final List<String> gscProperties = [
    'example.com',
    'shop.example.com',
    'blog.example.com'
  ];

  final List<String> ga4Streams = [
    'GA4 - Main Site',
    'GA4 - App',
    'GA4 - Blog'
  ];

  @observable
  String? selectedGscProperty;

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
  Future<void> connectGoogle() async {
    isConnecting = true;
    hasError = false;

    // Simulate delay
    await Future.delayed(const Duration(seconds: 2));

    isConnecting = false;
    isConnected = true;
    selectedGscProperty = gscProperties.first;
    selectedGa4Stream = ga4Streams.first;
  }

  @action
  void disconnect() {
    isConnected = false;
    selectedGscProperty = null;
    selectedGa4Stream = null;
    hasError = false;
  }

  @action
  void simulateError() {
    hasError = true;
  }
}
