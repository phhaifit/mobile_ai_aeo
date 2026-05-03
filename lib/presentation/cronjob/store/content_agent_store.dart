import 'package:boilerplate/data/network/apis/content_agent/content_agent_api.dart';
import 'package:boilerplate/data/sharedpref/shared_preference_helper.dart';
import 'package:boilerplate/di/service_locator.dart';
import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';

part 'content_agent_store.g.dart';

class ContentAgentStore = _ContentAgentStore with _$ContentAgentStore;

abstract class _ContentAgentStore with Store {
  final ContentAgentApi _api;

  _ContentAgentStore(this._api);

  // ─── Agents ──────────────────────────────────────────────────────────────

  @observable
  ObservableList<Map<String, dynamic>> agents =
      ObservableList<Map<String, dynamic>>();

  @observable
  Map<String, dynamic>? stats;

  @observable
  int availableBlogPromptCount = 0;

  @observable
  bool isLoadingAgents = false;

  @observable
  String? agentsError;

  @observable
  String? togglingAgentId;

  // ─── Content Profiles ──────────────────────────────────────────────────────

  @observable
  ObservableList<Map<String, dynamic>> contentProfiles =
      ObservableList<Map<String, dynamic>>();

  @observable
  bool isLoadingProfiles = false;

  @action
  Future<void> loadContentProfiles() async {
    final projectId = await _resolveProjectId();
    isLoadingProfiles = true;
    try {
      final list = await _api.getContentProfiles(projectId);
      contentProfiles = ObservableList<Map<String, dynamic>>.of(list);
    } catch (e) {
      // ignore: avoid_print
      print('[ContentAgentStore] loadContentProfiles error: $e');
    } finally {
      isLoadingProfiles = false;
    }
  }

  // ─── Executions ──────────────────────────────────────────────────────────

  @observable
  ObservableList<Map<String, dynamic>> executions =
      ObservableList<Map<String, dynamic>>();

  @observable
  int totalExecutions = 0;

  @observable
  bool isLoadingExecutions = false;

  @observable
  String? executionsError;

  // ─── Computed ─────────────────────────────────────────────────────────────

  @computed
  double get successRate {
    final s = stats;
    if (s == null) return 0;
    return (s['successRate'] as num?)?.toDouble() ?? 0;
  }

  @computed
  int get successCount => (stats?['successCount'] as num?)?.toInt() ?? 0;

  @computed
  int get failCount => (stats?['failCount'] as num?)?.toInt() ?? 0;

  @computed
  int get activeAgentCount => agents.where((a) => a['isActive'] == true).length;

  // ─── Actions ──────────────────────────────────────────────────────────────

  @action
  Future<void> loadAgents() async {
    final projectId = await _resolveProjectId();
    isLoadingAgents = true;
    agentsError = null;
    try {
      final data = await _api.getAgents(projectId);
      final rawAgents = data['agents'];
      agents = ObservableList<Map<String, dynamic>>.of(
        (rawAgents as List<dynamic>)
            .map((e) => Map<String, dynamic>.from(e as Map)),
      );
      stats = data['stats'] != null
          ? Map<String, dynamic>.from(data['stats'] as Map)
          : null;
      availableBlogPromptCount =
          (data['availableBlogPromptCount'] as num?)?.toInt() ?? 0;
    } catch (e, st) {
      agentsError = _friendlyError(e);
      // ignore: avoid_print
      print('[ContentAgentStore] loadAgents error: $e\n$st');
    } finally {
      isLoadingAgents = false;
    }
  }

  @action
  Future<void> loadExecutions(
    String projectId, {
    int page = 1,
    int limit = 10,
    List<String>? statuses,
    List<String>? agentTypes,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    isLoadingExecutions = true;
    executionsError = null;
    try {
      final data = await _api.getExecutions(
        projectId,
        page: page,
        limit: limit,
        statuses: statuses,
        agentTypes: agentTypes,
        startDate: startDate,
        endDate: endDate,
      );
      final items = data['data'] as List<dynamic>? ?? [];
      executions = ObservableList<Map<String, dynamic>>.of(
        items.map((e) => Map<String, dynamic>.from(e as Map)),
      );
      totalExecutions = (data['total'] as num?)?.toInt() ??
          (data['count'] as num?)?.toInt() ??
          items.length;
    } catch (e) {
      executionsError = _friendlyError(e);
    } finally {
      isLoadingExecutions = false;
    }
  }

  @action
  Future<bool> configureAgent(String agentId, {
    String? contentProfileId,
    int? postsPerDay,
  }) async {
    try {
      await _api.updateAgent(
        agentId,
        contentProfileId: contentProfileId,
        postsPerDay: postsPerDay,
      );
      await loadAgents();
      return true;
    } catch (e) {
      agentsError = _friendlyError(e);
      return false;
    }
  }

  @action
  Future<bool> toggleAgent(String agentId, bool isActive) async {
    togglingAgentId = agentId;
    try {
      await _api.updateAgent(agentId, isActive: isActive);
      // Refresh agents list after toggle
      await loadAgents();
      return true;
    } catch (e) {
      agentsError = _friendlyError(e);
      return false;
    } finally {
      togglingAgentId = null;
    }
  }

  @action
  void clearAgentsError() => agentsError = null;

  @action
  void clearExecutionsError() => executionsError = null;

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Future<String> _resolveProjectId() async {
    final prefs = getIt<SharedPreferenceHelper>();
    final saved = (await prefs.currentProjectId)?.trim();
    if (saved != null && saved.isNotEmpty) return saved;
    throw Exception('No project selected');
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final msg = e.response?.data?['message'];
      if (msg != null) return msg.toString();
      return 'Network error: ${e.message}';
    }
    return e.toString();
  }
}
