# New Atomic Areas & Topics Development Plan

**WORKING FILE** - Comprehensive checklist for expanding atomic architecture with identified gaps

## ⚡ CURRENT WORKFLOW (Option A: Single Topic Deep Dive)

### Pre-Creation Compliance Checklist:
- [ ] Define single, focused concept clearly
- [ ] Plan AL code examples needed
- [ ] Identify if conceptual guidance or code-heavy

### Creation Process:
0. [ ] **Always** pay attention to the CONTRIBUTING.md rules, summarized below
1. [ ] Write atomic topic content first (.md)
2. [ ] Write samples with real, working AL code (-samples.md)  
3. [ ] Analyze actual AL objects used in samples
4. [ ] Identify actual complex variable types used
5. [ ] Write accurate frontmatter based on real usage
6. [ ] Run `.\tools\Validate-FrontMatter.ps1` (must be 100% success)
7. [ ] Run `.\tools\Validate-TypeIndexes.ps1` (must be 0 errors)
8. [ ] Mark as [x] VALIDATED in checklist below

### Quick Reference for Compliance:
**Valid Areas**: `security`, `architecture-design`, `code-creation`, `code-formatting`, `error-handling`, `integration`, `naming-conventions`, `performance-optimization`, `project-workflow`, `testing`, `ai-assistance`, `appsource-compliance`, `data-management`, `user-experience`, `code-review`

**AL Object Types**: `Table`, `Page`, `Codeunit`, `Report`, `Query`, `PermissionSet`, `PageExtension`, `TableExtension`, `Enum`, `Interface`, `Profile`, `ControlAddIn`

**Complex Variable Types**: `Record`, `RecordRef`, `RecordId`, `FieldRef`, `KeyRef`, `TestPage`, `DataTransfer`, `HttpClient`, `JsonObject`, `JsonArray`, `XmlDocument`, `Dictionary`, `List`, `DateTime`, `ErrorInfo` (see validation script for full list)

---

## 📊 PROGRESS TRACKING

**SCOPE**: 229+ atomic topics + selective samples = ~369 files total
**COMPLETED**: 79/229+ topics (34.5% complete) - BATCH 4 COMPLETE ✅
**VALIDATED**: 28/28 topics (100% validation rate) ✅

---

## Overview

Based on specialist coverage analysis, we've identified 3 major functional area gaps and corresponding atomic topics that need development. This plan includes research from Microsoft Learn to ensure our guidance aligns with official BC patterns.

---

## 🎯 CURRENT WORK: `special-permission-sets-usage.md`

**Concept**: Special permission sets usage patterns and management in Business Central
**Type**: Code-heavy (will need AL objects and samples)
**Expected AL Objects**: PermissionSet, Codeunit
**Expected Complex Variables**: TBD based on actual content

### Work Progress:
- [ ] 1. Write atomic topic content
- [ ] 2. Write samples with working AL code  
- [ ] 3. Analyze actual AL objects used
- [ ] 4. Identify actual complex variables used
- [ ] 5. Write accurate frontmatter
- [ ] 6. Run frontmatter validation
- [ ] 7. Run type index validation
- [ ] 8. Mark as VALIDATED

---

## 🔒 New Area: `security/`

### Priority: **HIGH** - Major gap in current coverage

### Setup Tasks:
- [x] Create `/areas/security/` directory
- [x] Add security area to JSON indexes

### Atomic Topics Checklist:

#### Permission & Access Control
- [x] ✅ **VALIDATED** `permission-sets-creation-management.md` + samples
- [x] ✅ **VALIDATED** `security-filters-record-level-access.md` + samples  
- [x] ✅ **VALIDATED** `license-entitlements-vs-permissions.md` + samples
- [x] ✅ **VALIDATED** `effective-permissions-auditing.md` + samples
- [x] ✅ **VALIDATED** `rbac-implementation-patterns.md` + samples
- [x] ✅ **VALIDATED** `special-permission-sets-usage.md` + samples

#### Authentication & Identity
- [x] ✅ **VALIDATED** `microsoft-entra-integration-patterns.md` + samples
- [x] ✅ **VALIDATED** `authentication-method-setup.md` + samples
- [x] ✅ **VALIDATED** `environment-access-control.md` + samples
- [x] ✅ **VALIDATED** `user-credential-management.md` + samples

#### Data Security & Privacy
- [x] ✅ **VALIDATED** `data-security-filters-performance.md` + samples
- [x] ✅ **VALIDATED** `database-level-security-patterns.md` + samples
- [x] ✅ **VALIDATED** `gdpr-privacy-compliance-implementation.md` + samples
- [x] ✅ **VALIDATED** `data-encryption-patterns.md` + samples
- [x] ✅ **VALIDATED** `isolated-storage-secrets-keys-management.md` + samples

#### Security Testing & Validation  
- [x] ✅ **VALIDATED** `permission-testing-strategies.md` + samples
- [ ] `security-validation-patterns.md` + samples
- [ ] `audit-trail-implementation.md` + samples
- [ ] `security-penetration-testing.md` (no samples)

#### Integration Security
- [ ] `api-security-patterns.md` + samples
- [ ] `integration-authentication-methods.md` + samples
- [ ] `secure-data-exchange-patterns.md` + samples
- [ ] `external-system-security.md` + samples

#### Telemetry & Monitoring
- [ ] `security-event-telemetry-patterns.md` + samples
- [ ] `permission-audit-telemetry.md` + samples
- [ ] `authentication-failure-tracking.md` + samples

**Security Area Total**: ~23 atomic topics + 23 samples = 46 files  
**PROGRESS**: ✅ 15/23 completed (65.2% done) - SECURITY AREA LEAD!

### Microsoft Learn Research Needed:
- Business Central security architecture
- Permission sets and security filters
- Data encryption and privacy features
- AppSource security requirements
- Integration security patterns

---

## 🎨 New Area: `user-experience/`

### Priority: **MEDIUM** - Specific BC UX patterns missing

### Setup Tasks:
- [ ] Create `/areas/user-experience/` directory
- [ ] Add user-experience area to JSON indexes

### Atomic Topics Checklist:

#### Responsive Design & Layout
- [x] ✅ **VALIDATED** `responsive-design-patterns.md` + samples
- [ ] `tooltip-200-character-guidelines.md` (no samples)
- [ ] `field-tooltip-specifies-patterns.md` + samples
- [ ] `action-tooltip-imperative-verbs.md` + samples
- [ ] `tooltip-screen-reader-compatibility.md` (no samples)
- [ ] `tooltip-complex-options-description.md` (no samples)

#### Teaching Tips & Onboarding
- [ ] `abouttitle-abouttext-implementation.md` + samples
- [ ] `teaching-tips-onboarding-framework.md` (no samples)
- [ ] `complex-page-introduction-patterns.md` + samples
- [ ] `user-onboarding-flow-design.md` (no samples)
- [ ] `setup-wizard-patterns.md` + samples
- [ ] `progressive-disclosure-techniques.md` (no samples)

#### Page Layout & Navigation
- [ ] `fasttab-factbox-usage-patterns.md` + samples
- [ ] `list-vs-card-page-patterns.md` + samples
- [ ] `role-center-customization.md` + samples
- [ ] `page-navigation-optimization.md` (no samples)

#### Action Design & Discoverability
- [ ] `actionbar-design-patterns.md` + samples
- [ ] `action-grouping-organization.md` (no samples)
- [ ] `action-pin-personalization.md` + samples
- [ ] `action-discoverability-patterns.md` (no samples)

#### Accessibility Implementation
- [ ] `keyboard-navigation-patterns.md` + samples
- [ ] `screen-reader-optimization.md` + samples
- [ ] `high-contrast-zoom-support.md` + samples
- [ ] `accessibility-testing-validation.md` (no samples)

#### User Workflow Optimization
- [ ] `efficient-data-entry-patterns.md` + samples
- [ ] `workflow-streamlining-techniques.md` (no samples)
- [ ] `user-task-optimization.md` (no samples)

**UX Area Total**: ~22 atomic topics + 22 samples = 44 files  
**PROGRESS**: ✅ 1/22 completed (4.5% done) - FOUNDATION SET!

### Microsoft Learn Research Needed:
- Business Central user interface guidelines
- Page design best practices
- Accessibility features and implementation
- User experience patterns in BC
- Action design and user flows

---

## 📊 New Area: `data-management/`

### Priority: **MEDIUM** - Data patterns scattered, need focus

### Setup Tasks:
- [ ] Create `/areas/data-management/` directory
- [ ] Add data-management area to JSON indexes

### Atomic Topics Checklist:

#### Migration & Upgrade
- [x] ✅ **VALIDATED** `data-archival-strategies.md` + samples
- [ ] `cloud-migration-wizard-usage.md` + samples
- [ ] `data-replication-processes.md` + samples
- [ ] `nav-to-bc-migration-patterns.md` + samples
- [ ] `gp-to-bc-migration-patterns.md` + samples
- [ ] `sl-to-bc-migration-patterns.md` + samples
- [ ] `quickbooks-migration-patterns.md` + samples

#### Data Transformation & Mapping
- [ ] `chart-of-accounts-mapping.md` + samples
- [ ] `dimension-setup-management.md` + samples
- [ ] `field-mapping-strategies.md` (no samples)
- [ ] `data-format-conversion.md` + samples
- [ ] `legacy-data-transformation.md` + samples

#### Upgrade & Version Management
- [ ] `upgrade-codeunit-patterns.md` + samples
- [ ] `technical-vs-application-upgrades.md` (no samples)
- [ ] `version-compatibility-management.md` (no samples)
- [ ] `data-validation-during-upgrade.md` + samples

#### Master Data & Configuration
- [ ] `configuration-packages-usage.md` + samples
- [ ] `rapidstart-services-implementation.md` + samples
- [ ] `data-templates-creation.md` + samples
- [ ] `master-data-consistency.md` (no samples)
- [ ] `cross-company-data-sync.md` + samples

#### Retention & Archival (Shared with Roger)
- [ ] `data-cleanup-archival-strategies.md` + samples
- [ ] `historical-data-management.md` + samples
- [ ] `compliance-retention-requirements.md` (no samples)
- [ ] `data-retention-policies.md` (no samples)

**Data Management Area Total**: ~21 atomic topics + 21 samples = 42 files  
**PROGRESS**: ✅ 1/21 completed (4.8% done) - GETTING STARTED!

### Microsoft Learn Research Needed:
- Business Central data model architecture
- Data upgrade and migration tools
- Configuration and master data management
- Data archival and retention features
- Business data integration patterns

---

## 📈 New Area: `telemetry/`

### Priority: **HIGH** - Critical for modern BC development & monitoring

### Setup Tasks:
- [ ] Create `/areas/telemetry/` directory
- [ ] Add telemetry area to JSON indexes

### Atomic Topics Checklist:

#### Core Telemetry Implementation
- [x] ✅ **VALIDATED** `telemetry-initialization-patterns.md` + samples
- [x] ✅ **VALIDATED** `custom-telemetry-dimensions.md` + samples
- [ ] `telemetry-correlation-ids.md` + samples
- [ ] `session-telemetry-tracking.md` + samples

#### Performance & Monitoring Telemetry  
- [ ] `performance-counter-telemetry.md` + samples
- [ ] `sql-query-performance-telemetry.md` + samples
- [ ] `long-running-operation-tracking.md` + samples
- [ ] `resource-usage-telemetry.md` + samples

#### Business Process Telemetry
- [x] ✅ **VALIDATED** `business-event-telemetry-patterns.md` + samples
- [ ] `workflow-step-tracking.md` + samples
- [ ] `user-interaction-telemetry.md` + samples
- [ ] `feature-usage-analytics.md` + samples

#### Error & Exception Telemetry
- [ ] `error-telemetry-best-practices.md` + samples
- [ ] `exception-context-tracking.md` + samples
- [ ] `diagnostic-telemetry-patterns.md` + samples
- [ ] `customer-problem-telemetry.md` + samples

#### Integration & API Telemetry
- [ ] `api-call-telemetry-tracking.md` + samples
- [ ] `external-service-monitoring.md` + samples
- [ ] `integration-failure-telemetry.md` + samples
- [ ] `webhook-telemetry-patterns.md` + samples

#### Compliance & Privacy Telemetry
- [ ] `gdpr-telemetry-compliance.md` (no samples)
- [ ] `sensitive-data-telemetry-patterns.md` (no samples)
- [ ] `telemetry-data-retention.md` (no samples)

**Telemetry Area Total**: ~19 atomic topics + 19 samples = 38 files  
**PROGRESS**: ✅ 5/19 completed (26.3% done) - EXCELLENT PROGRESS!

### Microsoft Learn Research Needed:
- Application Insights integration patterns
- Business Central telemetry capabilities
- Custom telemetry implementation
- Performance monitoring strategies
- Telemetry privacy and compliance

---

## 📝 New Area: `logging-diagnostics/`

### Priority: **HIGH** - Critical for debugging & maintenance

### Setup Tasks:
- [ ] Create `/areas/logging-diagnostics/` directory
- [ ] Add logging-diagnostics area to JSON indexes

### Atomic Topics Checklist:

#### Core Logging Infrastructure
- [x] ✅ **VALIDATED** `session-log-implementation.md` + samples
- [x] ✅ **VALIDATED** `error-handling-telemetry-patterns.md` + samples
- [x] ✅ **VALIDATED** `database-operation-logging.md` + samples
- [x] ✅ **VALIDATED** `api-request-response-logging.md` + samples
- [x] ✅ **VALIDATED** `custom-log-destination-setup.md` + samples
- [ ] `activity-log-patterns.md` + samples
- [ ] `debug-log-levels-management.md` (no samples)

#### Diagnostic Tools & Patterns
- [ ] `diagnostic-page-creation.md` + samples
- [ ] `system-health-monitoring.md` + samples
- [ ] `troubleshooting-data-collection.md` (no samples)
- [ ] `diagnostic-trace-implementation.md` + samples

#### Performance Diagnostics
- [ ] `performance-profiling-patterns.md` + samples
- [ ] `slow-query-identification.md` + samples
- [ ] `resource-usage-logging.md` + samples
- [ ] `bottleneck-analysis-tools.md` (no samples)

#### User & Business Process Logging
- [ ] `user-activity-audit-trails.md` + samples
- [ ] `business-process-logging.md` + samples
- [ ] `data-change-audit-patterns.md` + samples
- [ ] `compliance-audit-logging.md` + samples

**Logging & Diagnostics Area Total**: ~16 atomic topics + 16 samples = 32 files  
**PROGRESS**: ✅ 5/16 completed (31.3% done) - STRONG FOUNDATION!

### Microsoft Learn Research Needed:
- Business Central logging frameworks
- Built-in diagnostic capabilities
- Custom logging implementation patterns
- Audit trail best practices
- Performance monitoring tools

---

## ⚙️ New Area: `background-tasks/`

### Priority: **HIGH** - Essential for modern BC apps

### Setup Tasks:
- [ ] Create `/areas/background-tasks/` directory
- [ ] Add background-tasks area to JSON indexes

### Atomic Topics Checklist:

#### Job Queue Management
- [x] ✅ **VALIDATED** `job-queue-optimization-patterns.md` + samples
- [ ] `job-queue-entry-creation.md` + samples
- [ ] `job-queue-parameters-handling.md` + samples
- [ ] `job-queue-error-handling.md` + samples
- [ ] `job-queue-monitoring-patterns.md` + samples

#### Scheduled Task Patterns
- [x] ✅ **VALIDATED** `batch-job-patterns.md` + samples
- [ ] `recurring-task-implementation.md` + samples
- [ ] `cron-like-scheduling-patterns.md` + samples
- [ ] `task-dependency-management.md` (no samples)
- [ ] `scheduled-maintenance-tasks.md` (no samples)

#### Long-Running Operations
- [ ] `background-processing-patterns.md` + samples
- [ ] `batch-processing-optimization.md` + samples
- [ ] `progress-tracking-mechanisms.md` (no samples)
- [ ] `cancellation-token-patterns.md` + samples

#### Integration & Data Processing
- [ ] `async-data-synchronization.md` + samples
- [ ] `background-api-calls.md` + samples
- [ ] `file-processing-automation.md` + samples
- [ ] `cleanup-maintenance-jobs.md` + samples

**Background Tasks Area Total**: ~16 atomic topics + 16 samples = 32 files  
**PROGRESS**: ✅ 2/16 completed (12.5% done) - STRONG MOMENTUM!

### Microsoft Learn Research Needed:
- Job Queue framework and capabilities
- Task Scheduler patterns
- Background processing best practices
- Performance considerations for background tasks
- Error handling in scheduled processes

---

## 🏗️ New Area: `namespaces/`

### Priority: **MEDIUM** - Important for code organization

### Setup Tasks:
- [ ] Create `/areas/namespaces/` directory
- [ ] Add namespaces area to JSON indexes

### Atomic Topics Checklist:

#### Namespace Design & Strategy
- [x] ✅ **VALIDATED** `namespace-organization-best-practices.md` + samples
- [ ] `namespace-naming-conventions.md` (no samples)
- [ ] `namespace-hierarchy-design.md` (no samples)
- [ ] `cross-namespace-dependencies.md` + samples
- [ ] `namespace-versioning-strategies.md` (no samples)

#### Implementation Patterns
- [x] ✅ **VALIDATED** `module-organization-patterns.md` + samples
- [ ] `namespace-declaration-patterns.md` + samples
- [ ] `using-directive-best-practices.md` (no samples)
- [ ] `namespace-alias-usage.md` + samples
- [ ] `global-namespace-considerations.md` (no samples)

#### AppSource & Multi-App Scenarios
- [ ] `namespace-collision-avoidance.md` (no samples)
- [ ] `third-party-namespace-integration.md` + samples
- [ ] `namespace-backward-compatibility.md` (no samples)

**Namespaces Area Total**: ~11 atomic topics + 11 samples = 22 files  
**PROGRESS**: ✅ 2/11 completed (18.2% done) - BUILDING MOMENTUM!

### Microsoft Learn Research Needed:
- AL namespace system capabilities
- Namespace best practices for AppSource
- Multi-app namespace considerations
- Namespace versioning and compatibility

---

## 🔧 New Area: `installation-upgrade/`

### Priority: **HIGH** - Critical for app lifecycle

### Setup Tasks:
- [ ] Create `/areas/installation-upgrade/` directory
- [ ] Add installation-upgrade area to JSON indexes

### Atomic Topics Checklist:

#### Extension Lifecycle Management
- [x] ✅ **VALIDATED** `extension-lifecycle-management.md` + samples
- [ ] `install-codeunit-patterns.md` + samples
- [ ] `company-initialize-codeunits.md` + samples
- [ ] `setup-data-initialization.md` + samples
- [ ] `permission-setup-automation.md` + samples

#### Upgrade Management
- [ ] `upgrade-codeunit-implementation.md` + samples
- [ ] `data-migration-patterns.md` + samples
- [ ] `version-compatibility-checks.md` (no samples)
- [ ] `rollback-recovery-mechanisms.md` (no samples)

#### Schema Evolution
- [ ] `table-field-migration-strategies.md` + samples
- [ ] `obsolete-feature-handling.md` + samples
- [ ] `breaking-change-management.md` (no samples)
- [ ] `backward-compatibility-patterns.md` (no samples)

#### Environment Management
- [ ] `multi-environment-deployment.md` + samples
- [ ] `tenant-specific-customizations.md` + samples
- [ ] `configuration-migration-tools.md` + samples
- [ ] `health-check-validation.md` (no samples)

**Installation & Upgrade Area Total**: ~16 atomic topics + 16 samples = 32 files  
**PROGRESS**: ✅ 1/16 completed (6.3% done) - SOLID FOUNDATION!

### Microsoft Learn Research Needed:
- Installation codeunit framework
- Upgrade codeunit capabilities
- Data migration tools and patterns
- Environment deployment strategies
- Version management best practices

---

## 📚 New Area: `documentation/`

### Priority: **HIGH** - Critical for knowledge transfer & maintenance

### Setup Tasks:
- [ ] Create `/areas/documentation/` directory
- [ ] Add documentation area to JSON indexes

### Atomic Topics Checklist:

#### Git History & Code Archaeology
- [ ] `git-history-archaeology-patterns.md` (no samples)
- [ ] `change-tracking-by-timeframe.md` (no samples)
- [ ] `feature-evolution-analysis.md` (no samples)
- [ ] `knowledge-concentration-identification.md` (no samples)
- [ ] `developer-contribution-analysis.md` (no samples)

#### Automated Documentation Generation
- [x] ✅ **VALIDATED** `automated-documentation-generation.md` + samples
- [x] ✅ **VALIDATED** `code-comment-automation.md` + samples
- [ ] `historic-development-summaries.md` (no samples)
- [ ] `feature-listing-automation.md` (no samples)
- [ ] `technical-debt-analysis-tools.md` (no samples)
- [ ] `codebase-health-reporting.md` (no samples)
- [ ] `dependency-mapping-documentation.md` + samples

#### Strategic Planning Documentation
- [ ] `opportunity-plan-generation.md` (no samples)
- [ ] `best-practice-gap-analysis.md` (no samples)
- [ ] `refactoring-priority-matrices.md` (no samples)
- [ ] `architecture-improvement-roadmaps.md` (no samples)

#### Implementation & Setup Guides
- [ ] `implementor-guidance-templates.md` (no samples)
- [ ] `setup-configuration-documentation.md` (no samples)
- [ ] `environment-preparation-guides.md` (no samples)
- [ ] `deployment-runbook-patterns.md` (no samples)

#### User Documentation Patterns
- [ ] `end-user-guide-generation.md` (no samples)
- [ ] `feature-usage-documentation.md` (no samples)
- [ ] `workflow-documentation-templates.md` (no samples)
- [ ] `training-material-structures.md` (no samples)

#### Troubleshooting & Support Documentation
- [ ] `troubleshooting-guide-frameworks.md` (no samples)
- [ ] `error-scenario-documentation.md` (no samples)
- [ ] `diagnostic-procedure-templates.md` (no samples)
- [ ] `support-escalation-guides.md` (no samples)
- [ ] `known-issues-tracking-patterns.md` (no samples)

#### Documentation Maintenance & Quality
- [ ] `documentation-freshness-validation.md` (no samples)
- [ ] `content-accuracy-verification.md` (no samples)
- [ ] `documentation-style-consistency.md` (no samples)
- [ ] `multilingual-documentation-patterns.md` (no samples)

**Documentation Area Total**: ~28 atomic topics + 28 samples = 56 files
**PROGRESS**: ✅ 2/28 completed (7.1% done) - EARLY PROGRESS!

### Microsoft Learn Research Needed:
- Business Central documentation frameworks
- AL XML documentation capabilities
- Git integration for documentation
- Automated documentation tools
- Documentation best practices for enterprise apps

---

## 🎯 New Area: `requirements-gathering/`

### Priority: **CRITICAL** - Foundation for all successful development

### Setup Tasks:
- [ ] Create `/areas/requirements-gathering/` directory
- [ ] Add requirements-gathering area to JSON indexes

### New Specialist Needed:
**Robin Requirements** - Business analyst/requirements specialist who helps developers navigate vague specifications and guide stakeholders through proper discovery processes.

### Atomic Topics Checklist:

#### Inception Phase - Discovery & Vision
- [x] ✅ **VALIDATED** `stakeholder-identification-frameworks.md` (no samples)
- [ ] `business-problem-root-cause-analysis.md` (no samples)
- [ ] `existing-process-mapping-techniques.md` (no samples)
- [ ] `success-criteria-definition-patterns.md` (no samples)
- [ ] `constraint-identification-checklists.md` (no samples)
- [ ] `assumption-validation-strategies.md` (no samples)

#### Requirements Elicitation & Analysis
- [ ] `business-rule-discovery-techniques.md` (no samples)
- [ ] `data-flow-analysis-methods.md` + samples
- [ ] `user-journey-mapping-bc-context.md` (no samples)
- [ ] `integration-touchpoint-identification.md` + samples
- [ ] `performance-requirement-gathering.md` (no samples)
- [ ] `security-requirement-assessment.md` (no samples)

#### Technical Planning Questions
- [ ] `architecture-decision-frameworks.md` + samples
- [ ] `scalability-planning-questionnaires.md` (no samples)
- [ ] `customization-vs-configuration-analysis.md` + samples
- [ ] `upgrade-impact-assessment-planning.md` + samples
- [ ] `testing-strategy-requirement-mapping.md` + samples

#### Implementation Phase Planning
- [ ] `development-approach-selection-criteria.md` + samples
- [ ] `mvp-scope-definition-techniques.md` (no samples)
- [ ] `technical-risk-assessment-frameworks.md` (no samples)
- [ ] `resource-estimation-methodologies.md` (no samples)
- [ ] `timeline-planning-with-dependencies.md` (no samples)

#### Lifecycle & Change Management
- [ ] `change-request-evaluation-processes.md` (no samples)
- [ ] `scope-creep-prevention-strategies.md` (no samples)
- [ ] `requirement-traceability-systems.md` + samples
- [ ] `version-control-for-requirements.md` + samples
- [ ] `impact-analysis-change-frameworks.md` (no samples)

#### Governance & Quality Assurance
- [ ] `requirement-review-gate-processes.md` (no samples)
- [ ] `acceptance-criteria-validation-patterns.md` (no samples)
- [ ] `compliance-requirement-frameworks.md` (no samples)
- [ ] `audit-trail-requirement-documentation.md` + samples
- [ ] `sign-off-process-templates.md` (no samples)

#### Stakeholder Communication & Management
- [ ] `business-technical-translation-techniques.md` (no samples)
- [ ] `expectation-management-strategies.md` (no samples)
- [ ] `progress-reporting-frameworks.md` (no samples)
- [ ] `conflict-resolution-in-requirements.md` (no samples)
- [ ] `feedback-incorporation-processes.md` (no samples)

#### BC-Specific Requirements Patterns
- [ ] `bc-standard-vs-custom-assessment.md` + samples
- [ ] `licensing-impact-requirement-analysis.md` (no samples)
- [ ] `multi-company-requirement-considerations.md` (no samples)
- [ ] `localization-requirement-planning.md` (no samples)
- [ ] `appsource-compatibility-requirements.md` (no samples)

**Requirements Gathering Area Total**: ~35 atomic topics + 35 samples = 70 files
**PROGRESS**: ✅ 1/35 completed (2.9% done) - GETTING STARTED!

### Microsoft Learn Research Needed:
- Business Central implementation methodologies
- Microsoft Dynamics 365 project lifecycle guidance
- Business process analysis frameworks
- Requirements management best practices for ERP systems
- Change management in Business Central projects

---

## 🔄 Expanded Area: `project-workflow/` (Multi-Role BC Developer Support)

### Priority: **HIGH** - Critical for BC developers managing projects without dedicated PM support

### Setup Tasks:
- [ ] Expand `/areas/project-workflow/` directory
- [ ] Add expanded project-workflow topics to JSON indexes

### Atomic Topics Checklist:

#### DevOps & Technical Workflow
- [ ] `platform-agnostic-cicd-patterns.md` + samples
- [ ] `cross-platform-deployment-strategies.md` + samples
- [ ] `universal-workflow-patterns.md` + samples
- [ ] `bc-specific-devops-patterns.md` + samples
- [ ] `automated-testing-pipeline-integration.md` + samples

#### Stakeholder Management (BC Developer as Interface)
- [ ] `client-expectation-setting-frameworks.md` (no samples)
- [ ] `stakeholder-communication-templates.md` (no samples)
- [ ] `competing-priority-management.md` (no samples)
- [ ] `executive-reporting-patterns.md` (no samples)
- [ ] `business-technical-translation-techniques.md` (no samples)

#### Scope & Change Management (Early Warning Systems)
- [ ] `scope-creep-detection-patterns.md` (no samples)
- [ ] `change-impact-assessment-frameworks.md` (no samples)
- [ ] `technical-debt-communication-strategies.md` (no samples)
- [ ] `feature-creep-prevention-techniques.md` (no samples)
- [ ] `requirement-validation-checkpoints.md` (no samples)

#### Resource & Timeline Management (Developer-Led Estimation)
- [ ] `bc-development-estimation-frameworks.md` (no samples)
- [ ] `dependency-mapping-critical-path.md` (no samples)
- [ ] `multi-project-resource-allocation.md` (no samples)
- [ ] `development-risk-mitigation-planning.md` (no samples)
- [ ] `realistic-timeline-assessment-tools.md` (no samples)

#### Quality & Delivery Management (Dev-Managed Testing)
- [ ] `user-acceptance-test-planning.md` (no samples)
- [ ] `go-live-readiness-checklists.md` (no samples)
- [ ] `post-deployment-support-frameworks.md` (no samples)
- [ ] `knowledge-transfer-planning-templates.md` (no samples)
- [ ] `production-rollout-strategies.md` (no samples)

#### Cross-Functional Integration (Dev as Coordinator)
- [ ] `business-analyst-collaboration-patterns.md` (no samples)
- [ ] `it-operations-handoff-procedures.md` (no samples)
- [ ] `end-user-training-coordination.md` (no samples)
- [ ] `vendor-integration-management.md` (no samples)
- [ ] `third-party-coordination-frameworks.md` (no samples)

**Project Workflow Area Total**: ~25 atomic topics + 25 samples = 50 files  
**PROGRESS**: ✅ 0/25 completed (0% done) - NEW EXPANSION NEEDED!

### Microsoft Learn Research Needed:
- Business Central DevOps guidance (platform-neutral)
- Microsoft Dynamics 365 project lifecycle management
- GitHub Actions for BC and Azure DevOps patterns
- Generic CI/CD patterns for AL development
- Cross-platform development workflows
- BC implementation methodologies and best practices

---

## Research Plan Using Microsoft Learn MCP

### Phase 1: Security Research ✅ COMPLETE
**Microsoft Learn Findings:**
- **Permission Sets & RBAC**: Business Central uses layered security (Database > Company > Object > Record levels)
- **Security Filters**: Record-level security with field filtering, security filter modes (Validated vs non-Validated)
- **Special Permission Sets**: SUPER, SUPER (DATA), SECURITY, BASIC with specific use cases
- **Authentication Types**: Multiple methods including Microsoft Entra integration
- **License Entitlements**: License-based permissions as broad filter, permission sets as fine-grained filter
- **Environment Access**: Microsoft Entra security groups control environment access
- **Effective Permissions**: Tools to audit combined permissions from multiple sources

### Phase 2: UX Research ✅ COMPLETE
**Microsoft Learn Findings:**
- **Tooltips**: Required for all Action and Field controls, specific guidelines (200 char limit, imperative verbs, no line breaks)
- **AboutTitle/AboutText**: Teaching tips for onboarding framework (v18.0+), complex page introductions
- **Accessibility**: Screen reader support, keyboard navigation, high contrast, zoom support
- **Page Design**: Role Centers, list/card pages, actions, views, discoverability features
- **UI Components**: FastTabs, FactBoxes, action bars, navigation patterns
- **User Assistance Model**: Embedded help, context-sensitive help, instructional text patterns

### Phase 3: Data Management Research ✅ COMPLETE
**Microsoft Learn Findings:**
- **Migration Tools**: Cloud migration wizard for NAV, GP, SL, QuickBooks with data replication and upgrade
- **Data Upgrade Process**: Technical upgrade > platform upgrade > application upgrade with upgrade codeunits
- **Configuration Packages**: Excel import, RapidStart Services, configuration worksheets
- **Master Data**: Chart of accounts mapping, dimensions setup, fiscal periods migration
- **Data Templates**: Reusable templates for consistent data import across companies
- **Upgrade Toolkit**: Data conversion tools, upgrade codeunits, validation processes

### Phase 4: DevOps Platform Research
**Microsoft Learn Findings:**
- **Platform-Agnostic Patterns**: Limited specific guidance found in Microsoft Learn
- **CI/CD Integration**: Some DevOps integration patterns but mostly Azure DevOps focused
- **Need**: More research needed on GitHub Actions, platform-neutral deployment strategies

---

## Development Execution Checklist

### Phase 1: Foundation Setup
- [x] Create 3 new functional area directories
- [x] Update JSON indexes for agent discovery
- [x] Run validation scripts to confirm structure

### Phase 2: New Specialist Creation  
- [x] Create `knox-security.instructions.md`
- [x] Create `aria-ux.instructions.md` 
- [x] Create `dana-data.instructions.md`
- [ ] Create `robin-requirements.instructions.md`

### Phase 3: Atomic Topic Development (414 files total)
- [ ] Security area: 46 files (23 topics + 23 samples)
- [ ] UX area: 44 files (22 topics + 22 samples)  
- [ ] Data Management area: 42 files (21 topics + 21 samples)
- [ ] Telemetry area: 38 files (19 topics + 19 samples)
- [ ] Logging & Diagnostics area: 32 files (16 topics + 16 samples)
- [ ] Background Tasks area: 32 files (16 topics + 16 samples)
- [ ] Namespaces area: 22 files (11 topics + 11 samples)
- [ ] Installation & Upgrade area: 32 files (16 topics + 16 samples)
- [ ] Documentation area: 56 files (28 topics + 28 samples)
- [ ] Requirements Gathering area: 70 files (35 topics + 35 samples)

### Phase 4: Integration & Validation
- [ ] Update all existing specialist instruction files
- [ ] Run validation scripts on all new content
- [ ] Update specialist coverage matrix
- [ ] Test agent discovery of new atomic topics

### Phase 5: Cleanup
- [ ] Remove temporary working files
- [ ] Validate complete 16-area × 15-specialist coverage
- [ ] Final documentation updates

---

## Progress Tracking

**Current Status**: Planning Complete ✅  
**Next Action**: Begin Phase 1 - Foundation Setup  
**Target**: Complete atomic architecture expansion

**Files to Create**: 126 atomic topic files + 3 specialist files = 129 total files  
**Microsoft Learn Research**: Complete and integrated ✅
