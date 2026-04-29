import 'package:boilerplate/core/stores/error/error_store.dart';
import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';

part 'ai_writer_store.g.dart';

class AiWriterStore = _AiWriterStore with _$AiWriterStore;

abstract class _AiWriterStore with Store {
  // constructor:---------------------------------------------------------------
  _AiWriterStore(this.errorStore);

  // store variables:-----------------------------------------------------------
  final ErrorStore errorStore;

  @observable
  bool isLoadingMetaData = false;

  @observable
  bool isSearching = false;

  @observable
  bool isGeneratingContent = false;

  @observable
  List<dynamic> prompts = [];

  @observable
  List<dynamic> contentProfiles = [];

  @observable
  List<dynamic> personas = [];

  @observable
  List<dynamic> topPages = [];

  @observable
  String? selectedPromptId;

  @observable
  String referenceType = 'search';

  @observable
  String? selectedTopPageUrl;

  @observable
  String? selectedSearchUrl;

  @observable
  String? selectedProfileId;

  @observable
  String? selectedPersonaId;

  @observable
  String selectedContentType = 'blog_post';

  @observable
  String? selectedPlatform;

  @observable
  String? errorMessage;

  final TextEditingController customReferenceUrlController =
      TextEditingController();
  final TextEditingController customUrlController = TextEditingController();
  final TextEditingController keywordsController = TextEditingController();
  final TextEditingController improvementController = TextEditingController();
  final TextEditingController modificationInstructionController =
      TextEditingController();

  // actions:-------------------------------------------------------------------
  @action
  Future<void> generateContent() async {
    isGeneratingContent = true;
    try {
      // TODO: Implement generate content logic
      await Future.delayed(Duration(seconds: 2));
    } catch (e) {
      errorStore.errorMessage = e.toString();
    } finally {
      isGeneratingContent = false;
    }
  }

  // disposers:-----------------------------------------------------------------
  void dispose() {
    customReferenceUrlController.dispose();
    customUrlController.dispose();
    keywordsController.dispose();
    improvementController.dispose();
    modificationInstructionController.dispose();
  }
}
