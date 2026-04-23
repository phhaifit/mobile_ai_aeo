# PRD: Prompts Generation Endpoint

## 1. Product overview

### 1.1 Document title and version

- PRD: Prompts Generation Endpoint
- Version: 1.0.0

### 1.2 Product summary

The Prompts Generation Endpoint is a core component of the Generative Engine Optimization (GEO) Platform that automatically generates contextually relevant prompts for brand monitoring across four key customer journey stages: Awareness, Interest, Purchase, and Loyalty. This system leverages the existing Brand Context Initialization API infrastructure to create prompts that incorporate brand-specific attributes such as company name, services, competitors, and market positioning.

The feature provides a single REST API endpoint that automatically generates and categorizes prompts using AI, ensuring each prompt is contextually relevant to the specific brand and properly categorized for monitoring purposes. While manual prompt creation capabilities are planned for future phases, this initial implementation focuses on AI-powered generation to establish the foundation for consistent and relevant prompt creation across all monitoring categories.

## 2. Goals

### 2.1 Business goals

- Automate prompt generation to reduce manual content creation effort by 80%
- Increase prompt relevance through brand-specific context integration
- Standardize prompt quality across all monitoring categories
- Enable scalable brand monitoring without proportional increase in content creation resources
- Improve monitoring effectiveness through contextually relevant prompt generation
- Reduce time-to-market for new brand monitoring campaigns

### 2.2 User goals

- Generate high-quality prompts automatically without manual writing
- Ensure prompts are relevant to specific brand context and market positioning
- Create consistent prompt structure across all monitoring categories
- Save time previously spent on manual prompt creation and customization
- Access brand-specific prompts that incorporate company details and competitive landscape
- Maintain prompt quality standards while scaling monitoring operations

### 2.3 Non-goals

- Scheduling or executing prompt monitoring campaigns
- Managing monitoring frequency or timing
- Providing prompt performance analytics or optimization
- Supporting custom prompt templates or user-defined prompt structures
- Generating prompts for languages other than English in the initial version
- Creating visual or multimedia prompt content
- Manual prompt creation or management (planned for future phases)
- Prompt editing or customization after generation (planned for future phases)

## 3. User personas

### 3.1 Key user types

- Marketing professionals
- Brand managers
- Content strategists
- SEO specialists
- Marketing platform users

### 3.2 Basic persona details

- **Marketing Professionals**: Users who need to monitor brand visibility across different customer journey stages and require relevant prompts for each category.
- **Brand Managers**: Users responsible for tracking brand mentions and sentiment across various online channels and need consistent prompt generation.
- **Content Strategists**: Users who leverage brand monitoring insights to inform content creation and require prompts that align with brand positioning.
- **SEO Specialists**: Users who monitor brand visibility in search results and need prompts that capture relevant search intent and brand-specific queries.
- **Marketing Platform Users**: External customers who integrate with the GEO platform to automate their brand monitoring processes.

### 3.3 Role-based access

- **Authenticated Users**: Can generate prompts for brands they have access to through their projects.
- **Project Owners**: Can generate prompts for all brands within their projects.
- **Brand Managers**: Can generate prompts for specific brands they are assigned to monitor.

## 4. Functional requirements

- **AI-Powered Prompt Generation** (Priority: High)
  - Generate prompts using AI/LLM technology for contextual relevance
  - Ensure each generated prompt incorporates at least one brand attribute
  - Generate prompts that reflect the brand's industry and market positioning
  - Use brand name, services, competitors, and mission statement to create relevant prompts

- **Automatic Category Assignment** (Priority: High)
  - Automatically categorize generated prompts into one of the four categories: Awareness, Interest, Purchase, or Loyalty
  - Ensure every prompt belongs to exactly one category
  - Validate prompt categorization before storage
  - Maintain clear separation between different customer journey stages

- **Project-Based Prompt Management** (Priority: High)
  - Store prompts at the project level for proper access control
  - Associate prompts with the project that owns them
  - Ensure prompts are accessible only to project members
  - Each project has exactly one associated brand for prompt generation

- **Brand Context Integration** (Priority: High)
  - Retrieve brand data directly from the Supabase Brand table through database queries
  - Automatically extract relevant brand attributes from stored brand profiles for prompt generation
  - Incorporate brand name, description, services, competitors, and mission statement into prompt content
  - Use industry and target market information to enhance prompt relevance

- **REST API Endpoint** (Priority: High)
  - Provide a single endpoint for prompt generation
  - Support prompt generation with automatic brand context integration
  - Return generated prompts with proper categorization and metadata
  - Implement proper error handling and validation

- **Prompt Quality Assurance** (Priority: Medium)
  - Implement validation to ensure AI-generated prompts meet minimum quality standards
  - Check for appropriate length and clarity of generated prompts
  - Validate that prompts contain relevant brand-specific information
  - Ensure prompts are actionable and monitorable

## 5. API specifications

### 5.1 Core endpoints

- POST /api/prompts/generate: Generate prompts for brand monitoring

### 5.2 Data models

#### Prompt Generation Request

The request payload should include a required project identifier and optional parameters for controlling the generation process. The system must validate that the project ID exists and that the user has authorization to access it.

#### Prompt Response

The response structure should provide clear success/error indicators along with the generated prompts and relevant metadata. The response must include comprehensive information about the generation process, including timing, categories generated, and brand context used. All timestamps should be in ISO format for consistency.

#### Generated Prompt Structure

Each generated prompt must contain all required fields including content text, category assignment, project reference, and metadata. The system should track which brand attributes were utilized during generation to provide transparency about the prompt's context. Unique identifier and timestamps for creation and updates should be automatically managed by the system.

**Required Fields:**

- `id`: Unique identifier (UUID, auto-generated)
- `project_id`: Foreign key reference to project
- `content`: The actual prompt text
- `type`: Prompt category (Awareness, Interest, Purchase, Loyalty)
- `is_monitored`: Whether prompt is actively monitored (default: false)
- `is_deleted`: Soft delete flag (default: false)
- `created_at`: Creation timestamp (auto-generated)
- `updated_at`: Last modification timestamp (auto-updated)

#### Brand Summary Information

The response should include essential brand information that provides context for the generated prompts. This should cover core brand attributes such as name, domain, industry, and target market without exposing sensitive or internal data. Since each project has exactly one associated brand, the system retrieves brand information from the project's brand to provide context for prompt generation.

#### Prompt Categories

The system must support exactly four predefined categories that align with standard customer journey stages. Each prompt must be assigned to exactly one category, and the categorization should be consistent and accurate across different brands and industries.

### 5.3 Error handling

#### Error Response Format

The error response structure must provide clear error identification and debugging information. Each error should include a standardized error code, human-readable message, and optional details for troubleshooting. All error responses should include timestamps for logging and debugging purposes.

#### Error Codes

The system must implement comprehensive error handling with standardized error codes that cover all potential failure scenarios. Error codes should distinguish between client errors (invalid requests, unauthorized access), server errors (generation failures, internal issues), and business logic errors (insufficient data, rate limiting). Each error code should provide actionable information for users and developers.

#### HTTP Status Codes

The API must follow standard HTTP status code conventions to indicate the success or failure of requests. The system should use appropriate status codes for different types of responses, including success responses, client errors, server errors, and rate limiting scenarios. Status codes should align with REST API best practices and provide clear indication of request outcomes.

### 5.4 Rate limiting & throttling

The system must implement appropriate rate limiting to prevent abuse and ensure fair resource allocation. Rate limits should be configurable and consider both per-user and system-wide constraints. The API should provide clear feedback about rate limits through response headers and graceful error handling. Users should receive helpful information about when they can retry their requests.

## 6. User experience

### 6.1. Entry points & first-time user flow

- Users access the prompt generation through API integration
- First-time users receive clear documentation on request format and response structure
- Users can test the endpoint with sample brand IDs
- API users receive immediate feedback on generation success or failure

### 6.2. Core experience

- **Prompt Generation**: Users send POST request with project ID to generate prompts
  - The system validates project access and retrieves the associated brand
  - The system retrieves brand data directly from the Supabase Brand table through database queries
  - AI generates contextually relevant prompts using the brand's attributes
  - Prompts are automatically categorized into appropriate customer journey stages
  - Prompts are stored with project association for proper access control
  - Users receive comprehensive response with generated prompts and metadata
- **Response Handling**: Users receive structured response with all required information
  - Generated prompts with proper categorization
  - Generation metadata and timing
  - Clear success/error indicators

### 6.3. Advanced features & edge cases

- **Category Filtering**: Users can specify which categories to focus on
- **Prompt Count Control**: Users can control how many prompts to generate
- **Brand Data Validation**: System validates brand data completeness before generation
- **Fallback Generation**: System handles cases with limited brand information

### 6.4. UI/UX highlights

- Clear API documentation with examples
- Consistent response format for easy integration
- Comprehensive error messages for debugging
- Rate limiting information in response headers

## 7. Narrative

Sarah is a marketing director at a digital marketing agency who needs to monitor multiple client brands across different online channels. She discovers the GEO platform's Prompts Generation Endpoint and integrates it into her monitoring workflow. By simply sending a POST request with a brand ID, Sarah receives contextually relevant prompts that incorporate the client's company name, services, and competitive landscape, with each prompt automatically categorized by AI into the appropriate customer journey stage (Awareness, Interest, Purchase, or Loyalty). This allows Sarah to quickly set up comprehensive monitoring campaigns without spending hours manually crafting prompts, while ensuring each prompt is perfectly aligned with the client's brand positioning and market context.

## 8. Success metrics

### 8.1. User-centric metrics

- Time saved in prompt creation compared to manual methods (>80% reduction)
- User satisfaction with generated prompt quality (>4.0/5 rating)
- Percentage of users who use generated prompts without modification (>90%)
- API adoption rate among eligible users (>70%)

### 8.2. Business metrics

- Number of prompts generated per week across all users
- Reduction in customer support tickets related to prompt creation
- Increase in user engagement with the brand monitoring platform
- Customer retention rate improvement for users utilizing prompt generation

### 8.3. Technical metrics

- Prompt generation success rate (>95% successful generations)
- Average time to generate prompts (<3 seconds per request)
- API response time for prompt generation endpoint (<200ms)
- System uptime and reliability for prompt generation services
- Error rate for prompt generation and storage operations

## 9. Technical considerations

### 9.1. Integration points

- Integration with existing Brand model and Supabase database schema (already populated with brand information)
- Integration with Project model for user access control
- Integration with existing authentication and authorization systems
- Integration with AI/LLM services for prompt generation and categorization
- Integration with existing Prisma ORM and database infrastructure
- Future integration points for manual prompt creation and management capabilities

**Database Relationship Clarification:**

- Each USER can have multiple PROJECTS (1:N relationship)
- Each PROJECT has exactly one BRAND (1:1 relationship)
- Each PROJECT can have multiple PROMPTS (1:N relationship)
- Each BRAND can have multiple EMBEDDINGS (1:N relationship)
- Prompts are generated using the brand data from the project's associated brand
- All data is stored in Supabase (PostgreSQL) and accessed through Prisma ORM

### 9.2. Data storage & privacy

- Secure storage of generated prompts with appropriate access controls
- Compliance with data privacy regulations for stored prompt content
- Implementation of data retention policies for prompt history
- Encryption of sensitive prompt content and brand information
- User consent requirements for storing and processing prompt data

### 9.3. Scalability & performance

- Efficient prompt generation algorithms that scale with brand complexity
- Database optimization for prompt storage and retrieval operations
- Caching strategies for frequently accessed brand profiles
- Horizontal scaling capabilities for high-volume prompt generation
- Resource allocation based on prompt complexity and generation volume

### 9.4. Potential challenges

- Ensuring AI prompt quality and relevance across diverse industries and brand types
- Handling brands with limited or incomplete information in the database
- Managing prompt generation for brands with complex or ambiguous market positioning
- Maintaining consistency in prompt structure while allowing for brand-specific variations
- Ensuring AI categorization accuracy and consistency across different customer journey stages
- Managing AI response variations and maintaining prompt quality standards

## 10. Milestones & sequencing

### 10.1. Project estimate

- Small: 1-2 weeks

### 10.2. Team size & composition

- Small Team: 2-3 total people
  - 1 Product manager
  - 1-2 Backend engineers
  - 1 QA specialist (part-time)

### 10.3. Suggested phases

- **Phase 1**: Core Prompt Generation Infrastructure (1 week)
  - Key deliverables: Prompt model schema, AI integration service, API endpoint
- **Phase 2**: AI Categorization and Brand Context Integration (1 week)
  - Key deliverables: AI prompt categorization, brand attribute integration, prompt validation, comprehensive testing
- **Future Phases**: Manual prompt creation and management capabilities
  - Key deliverables: Manual prompt creation interface, prompt editing, prompt management dashboard

## 11. User stories

### 11.1. Generate prompts automatically for brand monitoring

- **ID**: US-001
- **Description**: As a marketing user, I want to automatically generate prompts for brand monitoring so that I can quickly set up comprehensive monitoring campaigns.
- **Acceptance criteria**:
  - The system generates prompts using stored brand information from the Supabase Brand table
  - Each prompt incorporates at least one brand attribute
  - AI automatically categorizes prompts into Awareness, Interest, Purchase, or Loyalty
  - Users receive immediate feedback on prompt generation success
  - Generated prompts are stored with proper metadata, timestamps, and AI-assigned categories
  - Prompts are associated with the project for proper access control

### 11.2. Ensure proper prompt categorization

- **ID**: US-002
- **Description**: As a marketing user, I want prompts to be automatically categorized by customer journey stage so that I can organize monitoring efforts effectively.
- **Acceptance criteria**:
  - Each prompt belongs to exactly one category (Awareness, Interest, Purchase, or Loyalty)
  - AI automatically assigns categories based on prompt content and customer journey stage definitions
  - Category assignment is accurate and consistent with standard customer journey definitions
  - Users can filter and view prompts by AI-assigned category
  - Category information is clearly displayed in the API response

### 11.3. Access prompts through REST API

- **ID**: US-003
- **Description**: As an API user, I want to access prompt generation through REST endpoints so that I can integrate with external systems.
- **Acceptance criteria**:
  - REST API provides endpoint for prompt generation
  - API supports filtering prompts by category and project
  - API responses include all required prompt fields and metadata
  - API maintains proper authentication and authorization
  - API documentation is comprehensive and up-to-date
  - Users can only access prompts for projects they are authorized to view

### 11.4. Ensure prompt quality and relevance

- **ID**: US-004
- **Description**: As a marketing user, I want generated prompts to be high-quality and relevant so that my monitoring efforts are effective.
- **Acceptance criteria**:
  - AI-generated prompts meet minimum quality standards
  - Prompts are contextually relevant to the specific brand
  - System validates both prompt content and AI categorization before storage
  - Users can report low-quality prompts or incorrect categorizations for improvement
  - AI prompt generation and categorization algorithms improve over time based on user feedback

### 11.5. Secure access to prompt generation

- **ID**: US-005
- **Description**: As a system administrator, I want to ensure secure access to prompt generation so that sensitive brand information remains protected.
- **Acceptance criteria**:
  - All prompt generation endpoints require proper authentication
  - Users can only generate prompts for projects they are authorized to access
  - System logs all prompt generation attempts for security auditing
  - API responses don't expose sensitive system information
  - Prompt data is encrypted in transit and at rest
  - Project-based access control ensures proper data isolation

### 11.6. Manage prompts at project level

- **ID**: US-006
- **Description**: As a project owner, I want to manage prompts within my project scope so that I can maintain proper organization and access control.
- **Acceptance criteria**:
  - Prompts are stored with project_id association
  - Users can only view prompts for projects they have access to
  - Project owners can manage all prompts within their projects
  - System maintains proper data isolation between projects
  - Prompt generation uses the single brand associated with each project
