import {
  Html,
  Head,
  Body,
  Container,
  Section,
  Row,
  Column,
  Text,
  Button,
  Hr,
  Link,
} from '@react-email/components';
import * as React from 'react';
import type { ReportData } from '../types/report-data.type';

/* ------------------------------------------------------------------ */
/*  Helper: trend arrow + delta text                                   */
/* ------------------------------------------------------------------ */
function TrendBadge({ delta }: { delta: number | null }) {
  if (delta === null || delta === undefined) {
    return <Text style={trendNeutral}>N/A</Text>;
  }

  const isUp = delta >= 0;
  const arrow = isUp ? '↗' : '↘';
  const bgColor = isUp ? '#dcfce7' : '#fee2e2';
  const color = isUp ? '#16a34a' : '#dc2626';
  const sign = isUp ? '+' : '';
  const label = `${arrow} ${sign}${delta.toFixed(1)}%`;

  return (
    <Text style={{ ...trendBase, color: '#6b7280' }}>
      <span
        style={{
          backgroundColor: bgColor,
          color,
          borderRadius: '12px',
          padding: '2px 10px',
          fontSize: '12px',
          fontWeight: 700,
          display: 'inline-block',
          marginRight: '6px',
        }}
      >
        {label}
      </span>
      <span style={trendMuted}>vs. last month</span>
    </Text>
  );
}

/* ------------------------------------------------------------------ */
/*  Main template                                                      */
/* ------------------------------------------------------------------ */
export function VisibilityReportEmail(props: ReportData) {
  const {
    projectName,
    brandName,
    executionDate,
    summary,
    competitorRanks,
    platformBreakdown,
    promptsMentioningBrand,
    topReferencedDomains,
    overviewUrl,
  } = props;

  return (
    <Html>
      <Head />
      <Body style={body}>
        <Container style={container}>
          {/* ========== HEADER ========== */}
          <Section style={headerSection}>
            <Row>
              <Column>
                <Text style={logoText}>
                  <span style={logoIcon}>◉</span> AEO Platform
                </Text>
              </Column>
              <Column align="right">
                <Text style={badge}>Monthly Visibility Report</Text>
              </Column>
            </Row>

            <Text style={h1}>Brand Visibility Report</Text>

            <Text style={subtitle}>
              Project:{' '}
              <span style={subtitleHighlight}>{projectName}</span>
              <span style={{ marginLeft: '32px' }}>
                Execution date:{' '}
                <strong>{executionDate}</strong>
              </span>
            </Text>
          </Section>

          <Hr style={hr} />

          {/* ========== SUMMARY ========== */}
          <Section style={sectionBlock}>
            <Text style={h2}>Summary</Text>

            <Row>
              {/* Brand Visibility Score */}
              <Column style={metricCol}>
                <Section style={metricCardInner}>
                  <Text style={metricLabel}>BRAND VISIBILITY SCORE</Text>
                  <Text style={{
                    ...metricValue,
                    color: summary.brandVisibilityScore < 40 ? '#dc2626' : summary.brandVisibilityScore < 70 ? '#ca8a04' : '#16a34a',
                  }}>
                    {summary.brandVisibilityScore.toFixed(1)}
                    <span style={metricUnit}> /100</span>
                  </Text>
                  <Text style={metricHint}>Suggested: 85+</Text>
                </Section>
              </Column>

              {/* Brand Mentions */}
              <Column style={metricColMiddle}>
                <Section style={metricCardInner}>
                  <Text style={metricLabel}>BRAND MENTIONS</Text>
                  <Text style={metricValue}>
                    {summary.brandMentionsRate.toFixed(1)}%
                  </Text>
                  <TrendBadge delta={summary.brandMentionsRateDelta} />
                </Section>
              </Column>

              {/* Link References */}
              <Column style={metricCol}>
                <Section style={metricCardInner}>
                  <Text style={metricLabel}>LINK REFERENCES</Text>
                  <Text style={metricValue}>
                    {summary.linkReferencesRate.toFixed(1)}%
                  </Text>
                  <TrendBadge delta={summary.linkReferencesRateDelta} />
                </Section>
              </Column>
            </Row>

            <Section style={generationMetricsSection}>
              <Row>
                <Column style={halfColumn}>
                  <Text style={h3}>
                    <span style={accentBar}>|</span> Prompt generation
                  </Text>
                  <Section style={listCard}>
                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          New prompts created:
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {summary.promptGeneration.newPromptsCreated}
                        </Text>
                      </Column>
                    </Row>

                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          New prompts mentioning your brand:
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {summary.promptGeneration.newPromptsMentioningBrand}
                        </Text>
                      </Column>
                    </Row>
                  </Section>
                </Column>

                <Column style={halfColumn}>
                  <Text style={h3}>
                    <span style={accentBar}>|</span> Content generation
                  </Text>
                  <Section style={listCard}>
                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          New content created:
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {summary.contentGeneration.newContentCreated}
                        </Text>
                      </Column>
                    </Row>

                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          <span style={subMetricLabel}>• System-generated content:</span>
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {summary.contentGeneration.systemGeneratedContent}
                        </Text>
                      </Column>
                    </Row>

                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          <span style={subMetricLabel}>• User-created content:</span>
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {summary.contentGeneration.userCreatedContent}
                        </Text>
                      </Column>
                    </Row>

                    <Row style={listRow}>
                      <Column>
                        <Text style={listName}>
                          Content published to social media:
                        </Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {
                            summary.contentGeneration
                              .socialMediaPublishedContent
                          }
                        </Text>
                      </Column>
                    </Row>
                  </Section>
                </Column>
              </Row>
            </Section>
          </Section>

          {/* ========== COMPETITOR RANKS & PLATFORM BREAKDOWN ========== */}
          <Section style={sectionBlock}>
            <Row>
              {/* Competitor Ranks */}
              <Column style={halfColumn}>
                <Text style={h3}>
                  <span style={accentBar}>|</span> Competitor Mention Rate
                </Text>
                <Section style={listCard}>
                  {competitorRanks.map((c, i) => (
                    <Row key={i} style={listRow}>
                      <Column>
                        <Text style={listName}>{c.name}</Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {c.mentionRate.toFixed(0)}%
                        </Text>
                      </Column>
                    </Row>
                  ))}
                  {competitorRanks.length === 0 && (
                    <Text style={emptyText}>No competitor data</Text>
                  )}
                </Section>
              </Column>

              {/* Platform Breakdown */}
              <Column style={halfColumn}>
                <Text style={h3}>
                  <span style={accentBar}>|</span> Platform Breakdown
                </Text>
                <Section style={listCard}>
                  {platformBreakdown.map((p, i) => (
                    <Row key={i} style={listRow}>
                      <Column>
                        <Text style={listName}>{p.name}</Text>
                      </Column>
                      <Column align="right">
                        <Text style={listRate}>
                          {p.mentionRate.toFixed(0)}%
                        </Text>
                      </Column>
                    </Row>
                  ))}
                  {platformBreakdown.length === 0 && (
                    <Text style={emptyText}>No platform data</Text>
                  )}
                </Section>
              </Column>
            </Row>
          </Section>

          {/* ========== PROMPTS MENTIONING YOUR BRAND ========== */}
          <Section style={sectionBlock}>
            <Text style={h2}>Prompts mentioning your brand</Text>

            <Section style={tableCard}>
              {/* Header row */}
              <Row style={tableHeaderRow}>
                <Column>
                  <Text style={tableHeader}>PROMPT DESCRIPTION</Text>
                </Column>
                <Column align="right" style={rankingCol}>
                  <Text style={tableHeader}>RANKING</Text>
                </Column>
              </Row>

              {promptsMentioningBrand.map((p, i) => (
                <Row key={i} style={tableRow}>
                  <Column>
                    <Text style={promptText}>
                      <Link href={`${p.url}`} style={{ color: '#374151', textDecoration: 'none' }}>
                        {p.content}
                      </Link>
                    </Text>
                  </Column>
                  <Column align="right" style={rankingCol}>
                    <Text style={rankingBadge}>{p.ranking}</Text>
                  </Column>
                </Row>
              ))}
              {promptsMentioningBrand.length === 0 && (
                <Row>
                  <Column>
                    <Text style={emptyText}>
                      No prompts mentioning {brandName}
                    </Text>
                  </Column>
                </Row>
              )}
            </Section>
          </Section>

          {/* ========== TOP REFERENCE DOMAIN ========== */}
          <Section style={sectionBlock}>
            <Text style={h2}>Top reference domain</Text>

            <Section style={tableCard}>
              {/* Header row */}
              <Row style={tableHeaderRow}>
                <Column style={noCol}>
                  <Text style={tableHeader}>NO.</Text>
                </Column>
                <Column>
                  <Text style={tableHeader}>DOMAIN SOURCE</Text>
                </Column>
                <Column align="right" style={freqCol}>
                  <Text style={tableHeader}>FREQUENCY</Text>
                </Column>
              </Row>

              {topReferencedDomains.map((d, i) => (
                <Row key={i} style={tableRow}>
                  <Column style={noCol}>
                    <Text style={domainNo}>#{i + 1}</Text>
                  </Column>
                  <Column>
                    <Text style={domainName}>
                      <Link
                        href={`https://${d.domain}`}
                        style={domainLink}
                      >
                        {d.domain}
                      </Link>
                    </Text>
                  </Column>
                  <Column align="right" style={freqCol}>
                    <Text style={freqValue}>{d.frequency}</Text>
                  </Column>
                </Row>
              ))}
              {topReferencedDomains.length === 0 && (
                <Row>
                  <Column>
                    <Text style={emptyText}>No domain data</Text>
                  </Column>
                </Row>
              )}
            </Section>
          </Section>

          <Hr style={hr} />

          {/* ========== FOOTER ========== */}
          <Section style={footerSection}>
            <Text style={footerNote}>
              Please click below to access the interactive dashboard and full
              historical trends.
            </Text>
            <Button href={overviewUrl} style={ctaButton}>
              View full report &nbsp;→
            </Button>
            <Text style={footerCopy}>© 2026 AEO Platform</Text>
          </Section>
        </Container>
      </Body>
    </Html>
  );
}

/* ------------------------------------------------------------------ */
/*  Styles                                                             */
/* ------------------------------------------------------------------ */

const body: React.CSSProperties = {
  backgroundColor: '#f8f9fa',
  fontFamily:
    '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif',
  margin: 0,
  padding: 0,
};

const container: React.CSSProperties = {
  maxWidth: '680px',
  margin: '0 auto',
  backgroundColor: '#ffffff',
  borderRadius: '8px',
  overflow: 'hidden',
  padding: '40px 32px',
};

const headerSection: React.CSSProperties = {
  marginBottom: '8px',
};

const logoText: React.CSSProperties = {
  fontSize: '16px',
  fontWeight: 700,
  color: '#ea580c',
  margin: 0,
};

const logoIcon: React.CSSProperties = {
  color: '#ea580c',
};

const badge: React.CSSProperties = {
  fontSize: '12px',
  color: '#ea580c',
  border: '1px solid #ea580c',
  borderRadius: '20px',
  padding: '4px 14px',
  display: 'inline-block',
  margin: 0,
};

const h1: React.CSSProperties = {
  fontSize: '28px',
  fontWeight: 800,
  color: '#1a1a2e',
  margin: '12px 0 4px',
};

const subtitle: React.CSSProperties = {
  fontSize: '13px',
  color: '#6b7280',
  margin: '0 0 4px',
};

const subtitleIcon: React.CSSProperties = {
  marginRight: '4px',
};

const subtitleHighlight: React.CSSProperties = {
  color: '#ea580c',
  fontWeight: 600,
};

const hr: React.CSSProperties = {
  borderColor: '#e5e7eb',
  margin: '20px 0',
};

const sectionBlock: React.CSSProperties = {
  marginBottom: '24px',
};

const h2: React.CSSProperties = {
  fontSize: '20px',
  fontWeight: 700,
  color: '#1a1a2e',
  margin: '0 0 16px',
};

const h3: React.CSSProperties = {
  fontSize: '16px',
  fontWeight: 700,
  color: '#1a1a2e',
  margin: '0 0 12px',
};

const accentBar: React.CSSProperties = {
  color: '#ea580c',
  fontWeight: 800,
  marginRight: '6px',
};

/* ---------- Metric cards ---------- */

const metricCol: React.CSSProperties = {
  width: '33.33%',
  verticalAlign: 'top',
};

const metricColMiddle: React.CSSProperties = {
  width: '33.33%',
  verticalAlign: 'top',
  paddingLeft: '8px',
  paddingRight: '8px',
};

const metricCardInner: React.CSSProperties = {
  border: '1px solid #e5e7eb',
  borderRadius: '8px',
  padding: '16px',
  textAlign: 'left' as const,
};

const metricLabel: React.CSSProperties = {
  fontSize: '11px',
  fontWeight: 600,
  color: '#6b7280',
  textTransform: 'uppercase' as const,
  letterSpacing: '0.5px',
  margin: '0 0 4px',
};

const metricValue: React.CSSProperties = {
  fontSize: '32px',
  fontWeight: 700,
  color: '#1a1a2e',
  margin: '0 0 4px',
  lineHeight: '1.1',
};

const metricUnit: React.CSSProperties = {
  fontSize: '16px',
  fontWeight: 400,
  color: '#6b7280',
};

const metricHint: React.CSSProperties = {
  fontSize: '12px',
  color: '#9ca3af',
  margin: 0,
};

const trendBase: React.CSSProperties = {
  fontSize: '12px',
  fontWeight: 600,
  margin: 0,
};

const trendNeutral: React.CSSProperties = {
  ...trendBase,
  color: '#9ca3af',
};

const trendMuted: React.CSSProperties = {
  fontWeight: 400,
  color: '#9ca3af',
};

/* ---------- Lists (Competitors / Platforms) ---------- */

const halfColumn: React.CSSProperties = {
  width: '50%',
  verticalAlign: 'top',
  paddingRight: '12px',
};

const generationMetricsSection: React.CSSProperties = {
  marginTop: '20px',
};

const listCard: React.CSSProperties = {
  border: '1px solid #e5e7eb',
  borderRadius: '8px',
  padding: '8px 12px',
};

const listRow: React.CSSProperties = {
  borderBottom: '1px solid #f3f4f6',
  padding: '6px 0',
};

const listIconCol: React.CSSProperties = {
  width: '28px',
};

const listIcon: React.CSSProperties = {
  fontSize: '14px',
  margin: 0,
};

const listName: React.CSSProperties = {
  fontSize: '13px',
  color: '#374151',
  margin: 0,
};

const subMetricLabel: React.CSSProperties = {
  opacity: 0.68,
};

const listRate: React.CSSProperties = {
  fontSize: '13px',
  fontWeight: 700,
  color: '#1a1a2e',
  margin: 0,
};

const emptyText: React.CSSProperties = {
  fontSize: '13px',
  color: '#9ca3af',
  fontStyle: 'italic',
  textAlign: 'center' as const,
  padding: '12px 0',
  margin: 0,
};

/* ---------- Tables ---------- */

const tableCard: React.CSSProperties = {
  border: '1px solid #e5e7eb',
  borderRadius: '8px',
  padding: '0 16px',
};

const tableHeaderRow: React.CSSProperties = {
  borderBottom: '1px solid #e5e7eb',
  padding: '10px 0',
};

const tableHeader: React.CSSProperties = {
  fontSize: '11px',
  fontWeight: 600,
  color: '#6b7280',
  textTransform: 'uppercase' as const,
  letterSpacing: '0.5px',
  margin: 0,
};

const tableRow: React.CSSProperties = {
  borderBottom: '1px solid #f3f4f6',
  padding: '10px 0',
};

const rankingCol: React.CSSProperties = {
  width: '80px',
};

const promptText: React.CSSProperties = {
  fontSize: '13px',
  color: '#374151',
  fontStyle: 'italic',
  margin: 0,
};

const rankingBadge: React.CSSProperties = {
  fontSize: '13px',
  fontWeight: 700,
  color: '#ea580c',
  backgroundColor: '#fff7ed',
  borderRadius: '6px',
  padding: '4px 10px',
  display: 'inline-block',
  margin: 0,
  textAlign: 'center' as const,
};

/* ---------- Domain table ---------- */

const noCol: React.CSSProperties = {
  width: '50px',
};

const freqCol: React.CSSProperties = {
  width: '90px',
};

const domainNo: React.CSSProperties = {
  fontSize: '13px',
  color: '#ea580c',
  fontWeight: 600,
  margin: 0,
};

const domainName: React.CSSProperties = {
  fontSize: '13px',
  color: '#374151',
  margin: 0,
};

const domainLink: React.CSSProperties = {
  color: '#1a1a2e',
  fontWeight: 600,
  textDecoration: 'underline',
};

const freqValue: React.CSSProperties = {
  fontSize: '13px',
  fontWeight: 700,
  color: '#1a1a2e',
  margin: 0,
};

/* ---------- Footer ---------- */

const footerSection: React.CSSProperties = {
  textAlign: 'center' as const,
};

const footerNote: React.CSSProperties = {
  fontSize: '13px',
  color: '#6b7280',
  margin: '0 0 16px',
};

const ctaButton: React.CSSProperties = {
  backgroundColor: '#ea580c',
  color: '#ffffff',
  fontSize: '14px',
  fontWeight: 700,
  padding: '12px 32px',
  borderRadius: '24px',
  textDecoration: 'none',
  display: 'inline-block',
};

const footerCopy: React.CSSProperties = {
  fontSize: '12px',
  color: '#9ca3af',
  marginTop: '24px',
};
