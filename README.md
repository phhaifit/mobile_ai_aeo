# AI-AEO (Jarvis AEO) Brainstorming

*Created: 2026-02-16*
*Updated: 2026-03-04*

## Project Vision

Jarvis AEO is an **Ask Engine Optimization** platform that helps businesses manage and improve their brand visibility across AI chat engines (ChatGPT, Gemini, Google AI Overviews, etc.) — the AI-era equivalent of traditional SEO.

**Core problems solved:**
- Businesses have no visibility into how AI engines mention or cite them
- No tools exist to systematically optimize for AI answer engine presence
- Content creation for AEO requires specialized workflows (search-grounded writing, prompt-driven generation)
- Competitors' AI presence is invisible without active monitoring

**End goal:** A single platform where businesses can monitor AI brand presence, generate AI-optimized content, and track their "share of voice" across all major AI engines.

---

## Key Features (Built)

### 0. Authentication & Authorization — `High`
- Login / Register / Logout
- Google OAuth login
- Session persistence via refresh token

### 1. Brand Presence Tracking — `High`
- **Brand Visibility** — How often the brand appears in AI responses
- **Brand Mentions** — Raw mention count across engines
- **Link Visibility** — How often brand URLs are cited
- **Link References** — Which sources AI engines use to reference the brand
- **Mention Sentiment Tracking** — Positive / neutral / negative tone when brand is mentioned
- **Share of Voice across LLMs** — Brand's proportional presence vs. competitors per model
- **Brand recognition performance tracking**
- **AI Traffic Analysis** *(Low priority)* — Traffic attribution from AI engine referrals

### 2. Competitor Intelligence — `Medium`
- Competitor management (add/track competitors)
- **Prompt Gap Analysis** — Prompts where competitors appear but you don't
- Competitor website change monitoring (UI + content)
- Competitor rank change tracking
- Competitor web source tracking

### 3. Topic / Keyword / Prompt Management — `High`
- Topic management
- Keyword management per topic
- Prompt management per topic
- AI-suggested prompts for users
- Prompt rank analysis *(Low)*
- Prompt response tracking
- Prompt analytics
- AI Topic Visibility Leaderboard *(Low)*

### 4. Article Management & Creation — `High`
- Writing style management
- Blog / social post generation (Google Search-grounded content)
- Content generation from a given URL
- Article management (CRUD, versioning)

### 5. Brand Setup & Configuration — `High`
- Brand profile setup
- Knowledge base management
- URL link management
- URL rewrite configuration
- Enable/disable LLMs for monitoring
- LLM polling frequency configuration
- Brand positioning page
- Project management

### 6. Cronjob Automation — `Medium`
- Scheduled article generation from prompt library
- Scheduled article generation from a website source
- Cronjob history & run results
- Auto-post to website (CMS integration)
- Auto-post to social networks (Facebook, LinkedIn, etc.)
- Post to AI training data feeds / knowledge sources (Wikipedia, etc.)

### 7. Template Library — `Medium`
- Industry-specific writing style initialization + brand identity
- Brand voice generation from user's website
- Templates for: Technology/SaaS, E-commerce, Healthcare, Marketing

### 8. Content Enhancement — `Medium`
- Content refinement & enhancement
- Rewrite / paraphrase
- AI humanization (make AI text sound natural)
- Content summarization

### 9. SEO-driven Content Optimization — `Medium`
- On-page SEO checker
- AI topic clustering
- Automatic internal linking
- SEO content structure optimization

### 10. Planning & Action Recommendations — `Low`
- Gap analysis (content / citations / coverage)
- AI suggestions for content, social engagement, partnership opportunities
- Priority action classification
- Impact assessment
- Content strategy development

### 11. Performance Monitoring & Reporting — `Low`
- Weekly trend analysis
- Performance improvement monitoring & iteration

### 12. Technical & Foundational SEO — `Low`
- Website audit
- Schema markup optimization
- Mobile & speed checks
- Real-time crawler monitoring


---

## Target Users

- **Marketing teams** at SMBs and mid-market companies wanting AI engine visibility
- **Content managers** who need to produce AEO-optimized content at scale
- **SEO agencies** expanding into AEO services for clients
- **Brand managers** monitoring brand perception across AI tools
- **SaaS companies** competing for visibility in AI-generated recommendations

---

## Technical Considerations

- **AI engine integrations:** ChatGPT (OpenAI API), Gemini (Google AI), Perplexity, Claude — need to query these programmatically or via browser automation for prompt tracking
- **Content generation:** LLM-based writing pipeline with Google Search grounding for citations
- **Cronjob system:** Background job queue (e.g., Bull/BullMQ, Celery) for scheduled content tasks
- **CMS integrations:** WordPress REST API, Webflow, Ghost, etc. for auto-posting
- **Social integrations:** Facebook Graph API, LinkedIn API
- **Image generation:** AI image generation integrated into article creation pipeline
- **Brand voice extraction:** Scrape + analyze user's existing website to derive writing style/tone
- **Scalability:** Multi-tenant architecture with project-level isolation

---

## Success Metrics

- **Brand Visibility Score** — % of tracked prompts where brand appears in AI responses
- **Share of Voice** — Brand mentions vs. competitor mentions per AI engine
- **Content output volume** — Articles generated and published per period
- **Rank improvement** — Prompt ranking changes over time
- **Sentiment score** — Positive mention ratio trending upward
- **User engagement** — Active cronjobs, prompts tracked, articles published per account

---

## Open Questions

- How do we reliably query AI engines at scale without violating ToS? (API vs. browser automation vs. official APIs)
- What's the right polling frequency for prompt rank tracking across engines?
- How do we handle AI engine responses that change non-deterministically (same prompt, different answer)?
- Should brand voice extraction be a one-time setup or continuously updated?
- What Wikipedia/knowledge feed ingestion looks like for AI training data posting — is this feasible at all?
- How do we define and score "link visibility" in AI responses that don't always cite sources?
- Multi-language support — should AEO tracking support prompts in multiple languages per market?
- What's the monetization model? (Per seat, per project, per query volume?)

---

## Notes

*(Add brainstorming notes below)*

