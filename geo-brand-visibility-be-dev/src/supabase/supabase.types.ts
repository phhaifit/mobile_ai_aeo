export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "12.2.12 (cd3cf9e)"
  }
  public: {
    Tables: {
      BlacklistedUrl: {
        Row: {
          createdAt: string
          id: string
          promptId: string
          reason: string | null
          url: string
        }
        Insert: {
          createdAt?: string
          id?: string
          promptId: string
          reason?: string | null
          url: string
        }
        Update: {
          createdAt?: string
          id?: string
          promptId?: string
          reason?: string | null
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "BlacklistedUrl_promptId_fkey"
            columns: ["promptId"]
            isOneToOne: false
            referencedRelation: "Prompt"
            referencedColumns: ["id"]
          },
        ]
      }
      Brand: {
        Row: {
          blogHotline: string | null
          blogTitle: string | null
          cloudflareHostnameId: string | null
          createdAt: string
          customDomain: string | null
          customerType: string | null
          defaultArticleImageUrl: string | null
          description: string
          domain: string
          domainConfigMethod: string | null
          footerHtml: string | null
          headerHtml: string | null
          id: string
          industry: string
          logoUrl: string | null
          mission: string
          name: string
          projectId: string
          revenueModel: string | null
          slug: string
          targetMarket: string
          theme: string | null
          updatedAt: string
        }
        Insert: {
          blogHotline?: string | null
          blogTitle?: string | null
          cloudflareHostnameId?: string | null
          createdAt?: string
          customDomain?: string | null
          customerType?: string | null
          defaultArticleImageUrl?: string | null
          description: string
          domain: string
          domainConfigMethod?: string | null
          footerHtml?: string | null
          headerHtml?: string | null
          id?: string
          industry: string
          logoUrl?: string | null
          mission: string
          name: string
          projectId: string
          revenueModel?: string | null
          slug: string
          targetMarket: string
          theme?: string | null
          updatedAt?: string
        }
        Update: {
          blogHotline?: string | null
          blogTitle?: string | null
          cloudflareHostnameId?: string | null
          createdAt?: string
          customDomain?: string | null
          customerType?: string | null
          defaultArticleImageUrl?: string | null
          description?: string
          domain?: string
          domainConfigMethod?: string | null
          footerHtml?: string | null
          headerHtml?: string | null
          id?: string
          industry?: string
          logoUrl?: string | null
          mission?: string
          name?: string
          projectId?: string
          revenueModel?: string | null
          slug?: string
          targetMarket?: string
          theme?: string | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "Brand_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: true
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      Citation: {
        Row: {
          domain: string
          responseId: string
          title: string | null
          url: string
        }
        Insert: {
          domain: string
          responseId: string
          title?: string | null
          url: string
        }
        Update: {
          domain?: string
          responseId?: string
          title?: string | null
          url?: string
        }
        Relationships: [
          {
            foreignKeyName: "Citation_responseId_fkey"
            columns: ["responseId"]
            isOneToOne: false
            referencedRelation: "Response"
            referencedColumns: ["id"]
          },
        ]
      }
      Competitor: {
        Row: {
          brandId: string
          createdAt: string
          description: string | null
          id: string
          isSelected: boolean
          name: string
          updatedAt: string
        }
        Insert: {
          brandId: string
          createdAt?: string
          description?: string | null
          id?: string
          isSelected?: boolean
          name: string
          updatedAt?: string
        }
        Update: {
          brandId?: string
          createdAt?: string
          description?: string | null
          id?: string
          isSelected?: boolean
          name?: string
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_Competitor_Brand"
            columns: ["brandId"]
            isOneToOne: false
            referencedRelation: "Brand"
            referencedColumns: ["id"]
          },
        ]
      }
      CompetitorAnalysisResult: {
        Row: {
          competitorId: string
          position: number
          responseId: string
          sentiment: Database["public"]["Enums"]["Sentiment"]
        }
        Insert: {
          competitorId: string
          position: number
          responseId: string
          sentiment: Database["public"]["Enums"]["Sentiment"]
        }
        Update: {
          competitorId?: string
          position?: number
          responseId?: string
          sentiment?: Database["public"]["Enums"]["Sentiment"]
        }
        Relationships: [
          {
            foreignKeyName: "CompetitorAnalysisResult_competitorId_fkey"
            columns: ["competitorId"]
            isOneToOne: false
            referencedRelation: "Competitor"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "CompetitorAnalysisResult_responseId_fkey"
            columns: ["responseId"]
            isOneToOne: false
            referencedRelation: "Response"
            referencedColumns: ["id"]
          },
        ]
      }
      Content: {
        Row: {
          body: string
          completionStatus: Database["public"]["Enums"]["CompletionStatus"]
          contentFormat: Database["public"]["Enums"]["ContentFormat"]
          contentStrategy: Database["public"]["Enums"]["ContentStrategy"]
          contentType: string
          createdAt: string
          featuredImageUrl: string | null
          id: string
          jobId: string | null
          platform: string | null
          profileId: string | null
          promptId: string | null
          publishedAt: string | null
          publishedBody: string | null
          retrievedPages: Json
          slug: string | null
          stepHistory: Json | null
          targetKeywords: Json
          thumbnailKey: string | null
          title: string | null
          topicId: string
        }
        Insert: {
          body: string
          completionStatus?: Database["public"]["Enums"]["CompletionStatus"]
          contentFormat?: Database["public"]["Enums"]["ContentFormat"]
          contentStrategy?: Database["public"]["Enums"]["ContentStrategy"]
          contentType?: string
          createdAt?: string
          featuredImageUrl?: string | null
          id?: string
          jobId?: string | null
          platform?: string | null
          profileId?: string | null
          promptId?: string | null
          publishedAt?: string | null
          publishedBody?: string | null
          retrievedPages: Json
          slug?: string | null
          stepHistory?: Json | null
          targetKeywords: Json
          thumbnailKey?: string | null
          title?: string | null
          topicId: string
        }
        Update: {
          body?: string
          completionStatus?: Database["public"]["Enums"]["CompletionStatus"]
          contentFormat?: Database["public"]["Enums"]["ContentFormat"]
          contentStrategy?: Database["public"]["Enums"]["ContentStrategy"]
          contentType?: string
          createdAt?: string
          featuredImageUrl?: string | null
          id?: string
          jobId?: string | null
          platform?: string | null
          profileId?: string | null
          promptId?: string | null
          publishedAt?: string | null
          publishedBody?: string | null
          retrievedPages?: Json
          slug?: string | null
          stepHistory?: Json | null
          targetKeywords?: Json
          thumbnailKey?: string | null
          title?: string | null
          topicId?: string
        }
        Relationships: [
          {
            foreignKeyName: "Content_profileId_fkey"
            columns: ["profileId"]
            isOneToOne: false
            referencedRelation: "ContentProfile"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_promptId_fkey"
            columns: ["promptId"]
            isOneToOne: false
            referencedRelation: "Prompt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_topicId_fkey"
            columns: ["topicId"]
            isOneToOne: false
            referencedRelation: "Topic"
            referencedColumns: ["id"]
          },
        ]
      }
      Content_KnowledgeSource: {
        Row: {
          addedAt: string
          contentId: string
          sourceId: string
        }
        Insert: {
          addedAt?: string
          contentId: string
          sourceId: string
        }
        Update: {
          addedAt?: string
          contentId?: string
          sourceId?: string
        }
        Relationships: [
          {
            foreignKeyName: "Content_KnowledgeSource_contentId_fkey"
            columns: ["contentId"]
            isOneToOne: false
            referencedRelation: "Content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_KnowledgeSource_contentId_fkey"
            columns: ["contentId"]
            isOneToOne: false
            referencedRelation: "latest_articles_by_topic_view"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_KnowledgeSource_sourceId_fkey"
            columns: ["sourceId"]
            isOneToOne: false
            referencedRelation: "KnowledgeSource"
            referencedColumns: ["id"]
          },
        ]
      }
      ContentAgent: {
        Row: {
          agentType: Database["public"]["Enums"]["AgentType"]
          contentProfileId: string | null
          createdAt: string | null
          id: string
          isActive: boolean
          lastRunAt: string | null
          postsPerDay: number
          projectId: string
        }
        Insert: {
          agentType: Database["public"]["Enums"]["AgentType"]
          contentProfileId?: string | null
          createdAt?: string | null
          id?: string
          isActive?: boolean
          lastRunAt?: string | null
          postsPerDay?: number
          projectId: string
        }
        Update: {
          agentType?: Database["public"]["Enums"]["AgentType"]
          contentProfileId?: string | null
          createdAt?: string | null
          id?: string
          isActive?: boolean
          lastRunAt?: string | null
          postsPerDay?: number
          projectId?: string
        }
        Relationships: [
          {
            foreignKeyName: "ContentAgent_contentProfileId_fkey"
            columns: ["contentProfileId"]
            isOneToOne: false
            referencedRelation: "ContentProfile"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ContentAgent_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      ContentInsight: {
        Row: {
          content: Json
          contentId: string
          createdAt: string
          id: string
          insightGroup: Database["public"]["Enums"]["InsightGroup"]
          type: Database["public"]["Enums"]["InsightType"]
        }
        Insert: {
          content: Json
          contentId: string
          createdAt?: string
          id?: string
          insightGroup: Database["public"]["Enums"]["InsightGroup"]
          type: Database["public"]["Enums"]["InsightType"]
        }
        Update: {
          content?: Json
          contentId?: string
          createdAt?: string
          id?: string
          insightGroup?: Database["public"]["Enums"]["InsightGroup"]
          type?: Database["public"]["Enums"]["InsightType"]
        }
        Relationships: [
          {
            foreignKeyName: "ContentInsight_contentId_fkey"
            columns: ["contentId"]
            isOneToOne: false
            referencedRelation: "Content"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "ContentInsight_contentId_fkey"
            columns: ["contentId"]
            isOneToOne: false
            referencedRelation: "latest_articles_by_topic_view"
            referencedColumns: ["id"]
          },
        ]
      }
      ContentProfile: {
        Row: {
          audience: string
          description: string | null
          id: string
          name: string
          projectId: string
          voiceAndTone: string
        }
        Insert: {
          audience: string
          description?: string | null
          id?: string
          name: string
          projectId: string
          voiceAndTone: string
        }
        Update: {
          audience?: string
          description?: string | null
          id?: string
          name?: string
          projectId?: string
          voiceAndTone?: string
        }
        Relationships: [
          {
            foreignKeyName: "ContentProfile_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      CustomerPersona: {
        Row: {
          brandId: string
          buyingBehavior: Json | null
          contentPreferences: Json | null
          createdAt: string
          demographics: Json | null
          description: string | null
          goalsAndMotivations: string | null
          id: string
          isPrimary: boolean
          name: string
          painPoints: string | null
          professional: Json | null
          updatedAt: string
        }
        Insert: {
          brandId: string
          buyingBehavior?: Json | null
          contentPreferences?: Json | null
          createdAt?: string
          demographics?: Json | null
          description?: string | null
          goalsAndMotivations?: string | null
          id?: string
          isPrimary?: boolean
          name: string
          painPoints?: string | null
          professional?: Json | null
          updatedAt?: string
        }
        Update: {
          brandId?: string
          buyingBehavior?: Json | null
          contentPreferences?: Json | null
          createdAt?: string
          demographics?: Json | null
          description?: string | null
          goalsAndMotivations?: string | null
          id?: string
          isPrimary?: boolean
          name?: string
          painPoints?: string | null
          professional?: Json | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "CustomerPersona_brandId_fkey"
            columns: ["brandId"]
            isOneToOne: false
            referencedRelation: "Brand"
            referencedColumns: ["id"]
          },
        ]
      }
      DefaultContentProfile: {
        Row: {
          audience: string
          createdAt: string
          description: string | null
          id: string
          language: string
          name: string
          updatedAt: string
          voiceAndTone: string
        }
        Insert: {
          audience: string
          createdAt?: string
          description?: string | null
          id?: string
          language?: string
          name: string
          updatedAt?: string
          voiceAndTone: string
        }
        Update: {
          audience?: string
          createdAt?: string
          description?: string | null
          id?: string
          language?: string
          name?: string
          updatedAt?: string
          voiceAndTone?: string
        }
        Relationships: []
      }
      GaProperty: {
        Row: {
          createdAt: string
          displayName: string | null
          id: string
          projectId: string
          propertyId: string
          updatedAt: string
          userId: string
        }
        Insert: {
          createdAt?: string
          displayName?: string | null
          id?: string
          projectId: string
          propertyId: string
          updatedAt?: string
          userId: string
        }
        Update: {
          createdAt?: string
          displayName?: string | null
          id?: string
          projectId?: string
          propertyId?: string
          updatedAt?: string
          userId?: string
        }
        Relationships: [
          {
            foreignKeyName: "GaProperty_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: true
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "GaProperty_userId_fkey"
            columns: ["userId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      GoogleOAuthCredential: {
        Row: {
          createdAt: string
          encryptedRefreshToken: string
          id: string
          isValid: boolean
          projectId: string
          scopes: string[]
          updatedAt: string
          userId: string
        }
        Insert: {
          createdAt?: string
          encryptedRefreshToken: string
          id?: string
          isValid?: boolean
          projectId: string
          scopes?: string[]
          updatedAt?: string
          userId: string
        }
        Update: {
          createdAt?: string
          encryptedRefreshToken?: string
          id?: string
          isValid?: boolean
          projectId?: string
          scopes?: string[]
          updatedAt?: string
          userId?: string
        }
        Relationships: [
          {
            foreignKeyName: "GoogleOAuthCredential_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: true
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "GoogleOAuthCredential_userId_fkey"
            columns: ["userId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      GscProperty: {
        Row: {
          createdAt: string
          id: string
          permissionLevel: string | null
          projectId: string
          siteUrl: string
          updatedAt: string
          userId: string
        }
        Insert: {
          createdAt?: string
          id?: string
          permissionLevel?: string | null
          projectId: string
          siteUrl: string
          updatedAt?: string
          userId: string
        }
        Update: {
          createdAt?: string
          id?: string
          permissionLevel?: string | null
          projectId?: string
          siteUrl?: string
          updatedAt?: string
          userId?: string
        }
        Relationships: [
          {
            foreignKeyName: "GscProperty_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: true
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "GscProperty_userId_fkey"
            columns: ["userId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      Keyword: {
        Row: {
          createdAt: string
          id: string
          keyword: string
          topicId: string
          updatedAt: string
        }
        Insert: {
          createdAt?: string
          id?: string
          keyword: string
          topicId: string
          updatedAt?: string
        }
        Update: {
          createdAt?: string
          id?: string
          keyword?: string
          topicId?: string
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "Keyword_topicId_fkey"
            columns: ["topicId"]
            isOneToOne: false
            referencedRelation: "Topic"
            referencedColumns: ["id"]
          },
        ]
      }
      KnowledgeSource: {
        Row: {
          embeddingStatus: Database["public"]["Enums"]["EmbeddingStatus"]
          id: string
          name: string
          projectId: string
          sourceType: Database["public"]["Enums"]["SourceType"]
          storagePath: string
          vectorStoreId: string
        }
        Insert: {
          embeddingStatus?: Database["public"]["Enums"]["EmbeddingStatus"]
          id?: string
          name: string
          projectId: string
          sourceType: Database["public"]["Enums"]["SourceType"]
          storagePath: string
          vectorStoreId: string
        }
        Update: {
          embeddingStatus?: Database["public"]["Enums"]["EmbeddingStatus"]
          id?: string
          name?: string
          projectId?: string
          sourceType?: Database["public"]["Enums"]["SourceType"]
          storagePath?: string
          vectorStoreId?: string
        }
        Relationships: [
          {
            foreignKeyName: "KnowledgeSource_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      Model: {
        Row: {
          description: string
          id: string
          name: string
        }
        Insert: {
          description: string
          id?: string
          name: string
        }
        Update: {
          description?: string
          id?: string
          name?: string
        }
        Relationships: []
      }
      Project: {
        Row: {
          autoAnalysis: boolean | null
          autoGenerate: boolean | null
          createdAt: string
          createdBy: string
          id: string
          language: string
          location: string
          monitoringFrequency: Database["public"]["Enums"]["monitoring_frequency"]
          name: string | null
          status: Database["public"]["Enums"]["ProjectStatus"]
          strategyReviewedAt: string | null
          strategyReviewedById: string | null
          strategyReviewedByName: string | null
          strategyReviewedPromptCount: number | null
          strategyReviewedScore: number | null
          strategyReviewedTopicCount: number | null
          stripeCustomerId: string | null
          updatedAt: string
        }
        Insert: {
          autoAnalysis?: boolean | null
          autoGenerate?: boolean | null
          createdAt?: string
          createdBy: string
          id?: string
          language?: string
          location?: string
          monitoringFrequency?: Database["public"]["Enums"]["monitoring_frequency"]
          name?: string | null
          status?: Database["public"]["Enums"]["ProjectStatus"]
          strategyReviewedAt?: string | null
          strategyReviewedById?: string | null
          strategyReviewedByName?: string | null
          strategyReviewedPromptCount?: number | null
          strategyReviewedScore?: number | null
          strategyReviewedTopicCount?: number | null
          stripeCustomerId?: string | null
          updatedAt?: string
        }
        Update: {
          autoAnalysis?: boolean | null
          autoGenerate?: boolean | null
          createdAt?: string
          createdBy?: string
          id?: string
          language?: string
          location?: string
          monitoringFrequency?: Database["public"]["Enums"]["monitoring_frequency"]
          name?: string | null
          status?: Database["public"]["Enums"]["ProjectStatus"]
          strategyReviewedAt?: string | null
          strategyReviewedById?: string | null
          strategyReviewedByName?: string | null
          strategyReviewedPromptCount?: number | null
          strategyReviewedScore?: number | null
          strategyReviewedTopicCount?: number | null
          stripeCustomerId?: string | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "Project_createdBy_fkey"
            columns: ["createdBy"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Project_strategyReviewedById_fkey"
            columns: ["strategyReviewedById"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      Project_Invitation: {
        Row: {
          createdAt: string | null
          expiresAt: string | null
          id: string
          inviteeEmail: string | null
          inviteeId: string | null
          inviterId: string | null
          projectId: string | null
          role: Database["public"]["Enums"]["ProjectRole"]
          status: Database["public"]["Enums"]["InvitationStatus"]
          token: string | null
        }
        Insert: {
          createdAt?: string | null
          expiresAt?: string | null
          id?: string
          inviteeEmail?: string | null
          inviteeId?: string | null
          inviterId?: string | null
          projectId?: string | null
          role?: Database["public"]["Enums"]["ProjectRole"]
          status?: Database["public"]["Enums"]["InvitationStatus"]
          token?: string | null
        }
        Update: {
          createdAt?: string | null
          expiresAt?: string | null
          id?: string
          inviteeEmail?: string | null
          inviteeId?: string | null
          inviterId?: string | null
          projectId?: string | null
          role?: Database["public"]["Enums"]["ProjectRole"]
          status?: Database["public"]["Enums"]["InvitationStatus"]
          token?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "Project_Invitation_inviteeId_fkey"
            columns: ["inviteeId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Project_Invitation_inviterId_fkey"
            columns: ["inviterId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Project_Invitation_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      Project_Member: {
        Row: {
          createdAt: string | null
          projectId: string
          role: Database["public"]["Enums"]["ProjectRole"]
          updatedAt: string | null
          userId: string
        }
        Insert: {
          createdAt?: string | null
          projectId: string
          role?: Database["public"]["Enums"]["ProjectRole"]
          updatedAt?: string | null
          userId: string
        }
        Update: {
          createdAt?: string | null
          projectId?: string
          role?: Database["public"]["Enums"]["ProjectRole"]
          updatedAt?: string | null
          userId?: string
        }
        Relationships: [
          {
            foreignKeyName: "Project_Member_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Project_Member_userId_fkey"
            columns: ["userId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      Project_Model: {
        Row: {
          addedAt: string
          modelId: string
          projectId: string
        }
        Insert: {
          addedAt?: string
          modelId: string
          projectId: string
        }
        Update: {
          addedAt?: string
          modelId?: string
          projectId?: string
        }
        Relationships: [
          {
            foreignKeyName: "Project_Model_modelId_fkey"
            columns: ["modelId"]
            isOneToOne: false
            referencedRelation: "Model"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Project_Model_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      ProjectSubscription: {
        Row: {
          cancelAtPeriodEnd: boolean
          canceledAt: string | null
          createdAt: string | null
          currentPeriodEnd: string | null
          currentPeriodStart: string | null
          id: string
          lastRenewalReminderSentAt: string | null
          priceId: string
          projectId: string
          status: string
          stripeCustomerId: string
          stripeSubscriptionId: string
          updatedAt: string | null
        }
        Insert: {
          cancelAtPeriodEnd?: boolean
          canceledAt?: string | null
          createdAt?: string | null
          currentPeriodEnd?: string | null
          currentPeriodStart?: string | null
          id?: string
          lastRenewalReminderSentAt?: string | null
          priceId: string
          projectId: string
          status?: string
          stripeCustomerId: string
          stripeSubscriptionId: string
          updatedAt?: string | null
        }
        Update: {
          cancelAtPeriodEnd?: boolean
          canceledAt?: string | null
          createdAt?: string | null
          currentPeriodEnd?: string | null
          currentPeriodStart?: string | null
          id?: string
          lastRenewalReminderSentAt?: string | null
          priceId?: string
          projectId?: string
          status?: string
          stripeCustomerId?: string
          stripeSubscriptionId?: string
          updatedAt?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "ProjectSubscription_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: true
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      Prompt: {
        Row: {
          content: string
          createdAt: string
          id: string
          isDeleted: boolean
          isExhausted: boolean
          isMonitored: boolean
          lastRun: string | null
          status: string | null
          topicId: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt: string
        }
        Insert: {
          content: string
          createdAt?: string
          id?: string
          isDeleted?: boolean
          isExhausted?: boolean
          isMonitored?: boolean
          lastRun?: string | null
          status?: string | null
          topicId: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt?: string
        }
        Update: {
          content?: string
          createdAt?: string
          id?: string
          isDeleted?: boolean
          isExhausted?: boolean
          isMonitored?: boolean
          lastRun?: string | null
          status?: string | null
          topicId?: string
          type?: Database["public"]["Enums"]["PromptType"]
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "Prompt_topicId_fkey"
            columns: ["topicId"]
            isOneToOne: false
            referencedRelation: "Topic"
            referencedColumns: ["id"]
          },
        ]
      }
      Prompt_Keyword: {
        Row: {
          createdAt: string
          id: string
          keywordId: string
          promptId: string
        }
        Insert: {
          createdAt?: string
          id?: string
          keywordId: string
          promptId: string
        }
        Update: {
          createdAt?: string
          id?: string
          keywordId?: string
          promptId?: string
        }
        Relationships: [
          {
            foreignKeyName: "Prompt_Keyword_keywordId_fkey"
            columns: ["keywordId"]
            isOneToOne: false
            referencedRelation: "Keyword"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Prompt_Keyword_promptId_fkey"
            columns: ["promptId"]
            isOneToOne: false
            referencedRelation: "Prompt"
            referencedColumns: ["id"]
          },
        ]
      }
      Response: {
        Row: {
          createdAt: string
          id: string
          isCited: boolean
          modelId: string
          position: number | null
          promptId: string
          relatedQuestions: string[]
          response: string
          sentiment: Database["public"]["Enums"]["Sentiment"] | null
        }
        Insert: {
          createdAt?: string
          id?: string
          isCited?: boolean
          modelId: string
          position?: number | null
          promptId: string
          relatedQuestions?: string[]
          response: string
          sentiment?: Database["public"]["Enums"]["Sentiment"] | null
        }
        Update: {
          createdAt?: string
          id?: string
          isCited?: boolean
          modelId?: string
          position?: number | null
          promptId?: string
          relatedQuestions?: string[]
          response?: string
          sentiment?: Database["public"]["Enums"]["Sentiment"] | null
        }
        Relationships: [
          {
            foreignKeyName: "Response_modelId_fkey"
            columns: ["modelId"]
            isOneToOne: false
            referencedRelation: "Model"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Response_promptId_fkey"
            columns: ["promptId"]
            isOneToOne: false
            referencedRelation: "Prompt"
            referencedColumns: ["id"]
          },
        ]
      }
      Service: {
        Row: {
          brandId: string
          categoryId: string | null
          createdAt: string
          description: string | null
          id: string
          name: string
          price: string | null
          updatedAt: string
        }
        Insert: {
          brandId: string
          categoryId?: string | null
          createdAt?: string
          description?: string | null
          id?: string
          name: string
          price?: string | null
          updatedAt?: string
        }
        Update: {
          brandId?: string
          categoryId?: string | null
          createdAt?: string
          description?: string | null
          id?: string
          name?: string
          price?: string | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_Service_Brand"
            columns: ["brandId"]
            isOneToOne: false
            referencedRelation: "Brand"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "fk_Service_ServiceCategory"
            columns: ["categoryId"]
            isOneToOne: false
            referencedRelation: "ServiceCategory"
            referencedColumns: ["id"]
          },
        ]
      }
      ServiceCategory: {
        Row: {
          brandId: string
          createdAt: string
          id: string
          name: string
          updatedAt: string
        }
        Insert: {
          brandId: string
          createdAt?: string
          id?: string
          name: string
          updatedAt?: string
        }
        Update: {
          brandId?: string
          createdAt?: string
          id?: string
          name?: string
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "fk_ServiceCategory_Brand"
            columns: ["brandId"]
            isOneToOne: false
            referencedRelation: "Brand"
            referencedColumns: ["id"]
          },
        ]
      }
      SocialAccount: {
        Row: {
          accountAvatar: string | null
          accountName: string
          autoPublish: boolean
          autoPublishSchedule: Json | null
          connectedByUserId: string
          connectionType: string
          consecutiveErrorCount: number
          cooldownReason: string | null
          createdAt: string
          credentials: Json
          id: string
          isActive: boolean
          lastPublishedAt: string | null
          metadata: Json | null
          pausedUntil: string | null
          platform: string
          platformAccountId: string
          projectId: string
          tokenExpiresAt: string | null
          updatedAt: string
        }
        Insert: {
          accountAvatar?: string | null
          accountName: string
          autoPublish?: boolean
          autoPublishSchedule?: Json | null
          connectedByUserId: string
          connectionType: string
          consecutiveErrorCount?: number
          cooldownReason?: string | null
          createdAt?: string
          credentials?: Json
          id?: string
          isActive?: boolean
          lastPublishedAt?: string | null
          metadata?: Json | null
          pausedUntil?: string | null
          platform: string
          platformAccountId: string
          projectId: string
          tokenExpiresAt?: string | null
          updatedAt?: string
        }
        Update: {
          accountAvatar?: string | null
          accountName?: string
          autoPublish?: boolean
          autoPublishSchedule?: Json | null
          connectedByUserId?: string
          connectionType?: string
          consecutiveErrorCount?: number
          cooldownReason?: string | null
          createdAt?: string
          credentials?: Json
          id?: string
          isActive?: boolean
          lastPublishedAt?: string | null
          metadata?: Json | null
          pausedUntil?: string | null
          platform?: string
          platformAccountId?: string
          projectId?: string
          tokenExpiresAt?: string | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "SocialAccount_connectedByUserId_fkey"
            columns: ["connectedByUserId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "SocialAccount_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      SocialPost: {
        Row: {
          contentId: string | null
          createdAt: string
          createdByUserId: string | null
          id: string
          linkUrl: string | null
          mediaUrls: Json | null
          message: string
          metadata: Json | null
          projectId: string
          scheduledAt: string | null
          source: string
          title: string | null
          updatedAt: string
        }
        Insert: {
          contentId?: string | null
          createdAt?: string
          createdByUserId?: string | null
          id?: string
          linkUrl?: string | null
          mediaUrls?: Json | null
          message: string
          metadata?: Json | null
          projectId: string
          scheduledAt?: string | null
          source?: string
          title?: string | null
          updatedAt?: string
        }
        Update: {
          contentId?: string | null
          createdAt?: string
          createdByUserId?: string | null
          id?: string
          linkUrl?: string | null
          mediaUrls?: Json | null
          message?: string
          metadata?: Json | null
          projectId?: string
          scheduledAt?: string | null
          source?: string
          title?: string | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "SocialPost_createdByUserId_fkey"
            columns: ["createdByUserId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "SocialPost_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      SocialPostRateLimitLog: {
        Row: {
          accountId: string
          attemptedAt: string
          createdAt: string
          errorCode: string
          id: string
          platform: string
          requestPayloadHash: string | null
          userId: string
        }
        Insert: {
          accountId: string
          attemptedAt?: string
          createdAt?: string
          errorCode: string
          id?: string
          platform: string
          requestPayloadHash?: string | null
          userId: string
        }
        Update: {
          accountId?: string
          attemptedAt?: string
          createdAt?: string
          errorCode?: string
          id?: string
          platform?: string
          requestPayloadHash?: string | null
          userId?: string
        }
        Relationships: [
          {
            foreignKeyName: "SocialPostRateLimitLog_accountId_fkey"
            columns: ["accountId"]
            isOneToOne: false
            referencedRelation: "SocialAccount"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "SocialPostRateLimitLog_userId_fkey"
            columns: ["userId"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
        ]
      }
      SocialPostTarget: {
        Row: {
          bullmqJobId: string | null
          createdAt: string
          errorMessage: string | null
          errorType: string | null
          id: string
          platformPayload: Json | null
          platformPostId: string | null
          platformPostUrl: string | null
          publishedAt: string | null
          socialAccountId: string
          socialPostId: string
          status: string
          updatedAt: string
        }
        Insert: {
          bullmqJobId?: string | null
          createdAt?: string
          errorMessage?: string | null
          errorType?: string | null
          id?: string
          platformPayload?: Json | null
          platformPostId?: string | null
          platformPostUrl?: string | null
          publishedAt?: string | null
          socialAccountId: string
          socialPostId: string
          status?: string
          updatedAt?: string
        }
        Update: {
          bullmqJobId?: string | null
          createdAt?: string
          errorMessage?: string | null
          errorType?: string | null
          id?: string
          platformPayload?: Json | null
          platformPostId?: string | null
          platformPostUrl?: string | null
          publishedAt?: string | null
          socialAccountId?: string
          socialPostId?: string
          status?: string
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "SocialPostTarget_socialAccountId_fkey"
            columns: ["socialAccountId"]
            isOneToOne: false
            referencedRelation: "SocialAccount"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "SocialPostTarget_socialPostId_fkey"
            columns: ["socialPostId"]
            isOneToOne: false
            referencedRelation: "SocialPost"
            referencedColumns: ["id"]
          },
        ]
      }
      StripeEvent: {
        Row: {
          data: Json | null
          errorMessage: string | null
          eventType: string
          id: string
          processedAt: string | null
          status: string
        }
        Insert: {
          data?: Json | null
          errorMessage?: string | null
          eventType: string
          id: string
          processedAt?: string | null
          status?: string
        }
        Update: {
          data?: Json | null
          errorMessage?: string | null
          eventType?: string
          id?: string
          processedAt?: string | null
          status?: string
        }
        Relationships: []
      }
      Task: {
        Row: {
          createdAt: string | null
          finishedAt: string | null
          id: string
          payload: Json
          projectId: string | null
          result: Json | null
          startedAt: string | null
          status: string | null
          taskType: string
        }
        Insert: {
          createdAt?: string | null
          finishedAt?: string | null
          id?: string
          payload: Json
          projectId?: string | null
          result?: Json | null
          startedAt?: string | null
          status?: string | null
          taskType: string
        }
        Update: {
          createdAt?: string | null
          finishedAt?: string | null
          id?: string
          payload?: Json
          projectId?: string | null
          result?: Json | null
          startedAt?: string | null
          status?: string | null
          taskType?: string
        }
        Relationships: [
          {
            foreignKeyName: "Task_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      Topic: {
        Row: {
          alias: string | null
          createdAt: string
          description: string | null
          id: string
          isDeleted: boolean
          isMonitored: boolean
          name: string
          projectId: string
          searchVolume: number | null
          updatedAt: string
        }
        Insert: {
          alias?: string | null
          createdAt?: string
          description?: string | null
          id?: string
          isDeleted?: boolean
          isMonitored?: boolean
          name: string
          projectId: string
          searchVolume?: number | null
          updatedAt?: string
        }
        Update: {
          alias?: string | null
          createdAt?: string
          description?: string | null
          id?: string
          isDeleted?: boolean
          isMonitored?: boolean
          name?: string
          projectId?: string
          searchVolume?: number | null
          updatedAt?: string
        }
        Relationships: [
          {
            foreignKeyName: "Topic_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      User: {
        Row: {
          avatar: string | null
          createdAt: string
          email: string
          fullname: string
          googleId: string | null
          hasSeenTour: boolean
          id: string
          isVerified: boolean
          passwordHash: string | null
          updatedAt: string
        }
        Insert: {
          avatar?: string | null
          createdAt?: string
          email: string
          fullname: string
          googleId?: string | null
          hasSeenTour?: boolean
          id?: string
          isVerified?: boolean
          passwordHash?: string | null
          updatedAt?: string
        }
        Update: {
          avatar?: string | null
          createdAt?: string
          email?: string
          fullname?: string
          googleId?: string | null
          hasSeenTour?: boolean
          id?: string
          isVerified?: boolean
          passwordHash?: string | null
          updatedAt?: string
        }
        Relationships: []
      }
    }
    Views: {
      latest_articles_by_topic_view: {
        Row: {
          articleRank: number | null
          body: string | null
          completionStatus:
            | Database["public"]["Enums"]["CompletionStatus"]
            | null
          contentFormat: Database["public"]["Enums"]["ContentFormat"] | null
          contentType: string | null
          createdAt: string | null
          id: string | null
          jobId: string | null
          platform: string | null
          profileId: string | null
          projectId: string | null
          promptId: string | null
          publishedAt: string | null
          retrievedPages: Json | null
          slug: string | null
          stepHistory: Json | null
          targetKeywords: Json | null
          thumbnailKey: string | null
          title: string | null
          topicAlias: string | null
          topicId: string | null
          topicName: string | null
        }
        Relationships: [
          {
            foreignKeyName: "Content_profileId_fkey"
            columns: ["profileId"]
            isOneToOne: false
            referencedRelation: "ContentProfile"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_promptId_fkey"
            columns: ["promptId"]
            isOneToOne: false
            referencedRelation: "Prompt"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Content_topicId_fkey"
            columns: ["topicId"]
            isOneToOne: false
            referencedRelation: "Topic"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Topic_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
      project_with_last_run: {
        Row: {
          createdBy: string | null
          lastRun: string | null
          projectId: string | null
        }
        Relationships: [
          {
            foreignKeyName: "Project_createdBy_fkey"
            columns: ["createdBy"]
            isOneToOne: false
            referencedRelation: "User"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "Topic_projectId_fkey"
            columns: ["projectId"]
            isOneToOne: false
            referencedRelation: "Project"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Functions: {
      active_prompt_count: {
        Args: { topic_row: Database["public"]["Tables"]["Topic"]["Row"] }
        Returns: number
      }
      content_count: {
        Args: { prompt_row: Database["public"]["Tables"]["Prompt"]["Row"] }
        Returns: number
      }
      generate_unique_slug: { Args: { base_name: string }; Returns: string }
      get_analytics: {
        Args: {
          p_end: string
          p_granularity?: string
          p_models?: string[]
          p_project_id: string
          p_prompt_types?: Database["public"]["Enums"]["PromptType"][]
          p_start: string
        }
        Returns: Json
      }
      get_prompts_for_blog_scheduler: {
        Args: { p_max_tasks?: number; p_project_id: string }
        Returns: {
          contentAgentId: string
          contentProfileId: string
          promptId: string
          referenceUrl: string
        }[]
      }
      get_prompts_for_social_media_scheduler: {
        Args: { p_max_tasks?: number; p_project_id: string }
        Returns: {
          contentAgentId: string
          contentProfileId: string
          platform: string
          promptId: string
          referenceUrl: string
        }[]
      }
      get_prompts_with_latest_analysis_result: {
        Args: { p_project_id: string; p_user_id: string }
        Returns: {
          content: string
          createdAt: string
          id: string
          isDeleted: boolean
          isExhausted: boolean
          isMonitored: boolean
          keywords: string[]
          lastRun: string
          latestResults: Json
          status: string
          topicId: string
          topicName: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt: string
        }[]
      }
      get_prompts_with_latest_analysis_result_by_topic: {
        Args: { p_topic_id: string; p_user_id: string }
        Returns: {
          content: string
          createdAt: string
          id: string
          isDeleted: boolean
          isExhausted: boolean
          isMonitored: boolean
          keywords: string[]
          lastRun: string
          latestResults: Json
          status: string
          topicId: string
          topicName: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt: string
        }[]
      }
      get_prompts_with_latest_analysis_result_by_topic_pagination: {
        Args: {
          p_is_monitored?: boolean
          p_limit?: number
          p_offset?: number
          p_search?: string
          p_topic_id: string
          p_type?: Database["public"]["Enums"]["PromptType"][]
          p_user_id: string
        }
        Returns: {
          content: string
          createdAt: string
          id: string
          isDeleted: boolean
          isExhausted: boolean
          isMonitored: boolean
          keywords: string[]
          lastRun: string
          latestResults: Json
          status: string
          topicId: string
          topicName: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt: string
        }[]
      }
      get_prompts_with_latest_analysis_result_pagination: {
        Args: {
          p_is_monitored?: boolean
          p_limit?: number
          p_offset?: number
          p_project_id: string
          p_search?: string
          p_type?: Database["public"]["Enums"]["PromptType"][]
          p_user_id: string
        }
        Returns: {
          content: string
          createdAt: string
          id: string
          isDeleted: boolean
          isExhausted: boolean
          isMonitored: boolean
          keywords: string[]
          lastRun: string
          latestResults: Json
          status: string
          topicId: string
          topicName: string
          type: Database["public"]["Enums"]["PromptType"]
          updatedAt: string
        }[]
      }
      insert_brand: {
        Args: {
          customerType?: string
          description: string
          domain: string
          footerHtml?: string
          headerHtml?: string
          industry: string
          mission: string
          name: string
          projectId: string
          revenueModel?: string
          services: Json
          targetMarket: string
          theme?: string
        }
        Returns: Json
      }
      insert_prompts: { Args: { data: Json; projectId: string }; Returns: Json }
      insert_response: {
        Args: {
          citations: Json
          competitors: Json
          isCited: boolean
          modelId: string
          position: number
          promptId: string
          relatedQuestions: string[]
          response: string
          sentiment: Database["public"]["Enums"]["Sentiment"]
        }
        Returns: string
      }
      unaccent: { Args: { "": string }; Returns: string }
      update_brand: {
        Args: {
          _blog_hotline?: string
          _blog_title?: string
          _cloudflare_hostname_id?: string
          _custom_domain?: string
          _customer_types?: string
          _default_article_image_url?: string
          _description?: string
          _domain?: string
          _domain_config_method?: string
          _id: string
          _industry?: string
          _logo_url?: string
          _mission?: string
          _name?: string
          _revenue_models?: string
          _services_to_insert?: Json
          _services_to_update?: Json
          _target_market?: string
        }
        Returns: Json
      }
      update_brand_default_article_image: {
        Args: { _brand_id: string; _default_article_image_url: string }
        Returns: Json
      }
      update_project: {
        Args: {
          _brand_name?: string
          _id: string
          _language?: string
          _location?: string
          _models?: Json
          _monitoring_frequency?: Database["public"]["Enums"]["monitoring_frequency"]
          _project_name?: string
        }
        Returns: Json
      }
    }
    Enums: {
      AgentType: "SOCIAL_MEDIA_GENERATOR" | "BLOG_GENERATOR"
      CompletionStatus: "DRAFTING" | "COMPLETE" | "FAILED" | "PUBLISHED"
      ContentFormat: "MARKDOWN" | "PLAIN_TEXT"
      ContentStrategy: "DEFAULT" | "CLUSTER"
      EmbeddingStatus: "PENDING" | "INDEXED" | "FAILED"
      InsightGroup: "INTENT" | "TOPIC_COVERAGE"
      InsightType:
        | "OBJECTIVE"
        | "USER_INTENT"
        | "QUESTION_COVERAGE"
        | "SUBTOPIC"
      InvitationStatus: "Pending" | "Accepted" | "Rejected"
      monitoring_frequency: "hourly" | "daily" | "weekly" | "monthly"
      ProjectRole: "Admin" | "Member"
      ProjectStatus: "DRAFT" | "ACTIVE"
      PromptType:
        | "AWARENESS"
        | "INTEREST"
        | "PURCHASE"
        | "LOYALTY"
        | "CONSIDERATION"
        | "Informational"
        | "Commercial"
        | "Transactional"
        | "Navigational"
      Sentiment: "Negative" | "Neutral" | "Positive"
      SourceType: "FILE" | "URL" | "NOTE"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      AgentType: ["SOCIAL_MEDIA_GENERATOR", "BLOG_GENERATOR"],
      CompletionStatus: ["DRAFTING", "COMPLETE", "FAILED", "PUBLISHED"],
      ContentFormat: ["MARKDOWN", "PLAIN_TEXT"],
      ContentStrategy: ["DEFAULT", "CLUSTER"],
      EmbeddingStatus: ["PENDING", "INDEXED", "FAILED"],
      InsightGroup: ["INTENT", "TOPIC_COVERAGE"],
      InsightType: [
        "OBJECTIVE",
        "USER_INTENT",
        "QUESTION_COVERAGE",
        "SUBTOPIC",
      ],
      InvitationStatus: ["Pending", "Accepted", "Rejected"],
      monitoring_frequency: ["hourly", "daily", "weekly", "monthly"],
      ProjectRole: ["Admin", "Member"],
      ProjectStatus: ["DRAFT", "ACTIVE"],
      PromptType: [
        "AWARENESS",
        "INTEREST",
        "PURCHASE",
        "LOYALTY",
        "CONSIDERATION",
        "Informational",
        "Commercial",
        "Transactional",
        "Navigational",
      ],
      Sentiment: ["Negative", "Neutral", "Positive"],
      SourceType: ["FILE", "URL", "NOTE"],
    },
  },
} as const
