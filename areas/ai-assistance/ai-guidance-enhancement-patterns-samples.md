# AI Guidance and Prompt Enhancement Patterns - Code Samples

## Basic Prompt Enhancement Examples

### Simple Prompt Enhancement Implementation

```al
// Basic prompt enhancement system
codeunit 50100 "Basic Prompt Enhancer"
{
    /// <summary>
    /// Enhances basic development prompts with context and standards
    /// </summary>
    procedure EnhancePrompt(OriginalPrompt: Text): Text
    var
        EnhancedPrompt: Text;
        MissingElements: List of [Text];
        StandardsReferences: List of [Text];
    begin
        // Analyze original prompt for missing elements
        AnalyzePromptCompleteness(OriginalPrompt, MissingElements);
        
        // Add missing standards references
        AddStandardsReferences(OriginalPrompt, MissingElements, StandardsReferences);
        
        // Build enhanced prompt
        EnhancedPrompt := BuildEnhancedPrompt(OriginalPrompt, StandardsReferences);
        
        exit(EnhancedPrompt);
    end;
    
    /// <summary>
    /// Analyzes prompt for missing quality elements
    /// </summary>
    local procedure AnalyzePromptCompleteness(Prompt: Text; var MissingElements: List of [Text])
    begin
        // Check for validation patterns
        if not Prompt.Contains('validation') and not Prompt.Contains('error') then
            MissingElements.Add('validation_patterns');
            
        // Check for testing considerations
        if not Prompt.Contains('test') and not Prompt.Contains('scenario') then
            MissingElements.Add('testing_strategy');
            
        // Check for naming conventions
        if not Prompt.Contains('naming') and not Prompt.Contains('convention') then
            MissingElements.Add('naming_standards');
            
        // Check for performance considerations
        if Prompt.Contains('large') or Prompt.Contains('many') then
            if not Prompt.Contains('performance') then
                MissingElements.Add('performance_optimization');
                
        // Check for accessibility requirements
        if Prompt.Contains('page') or Prompt.Contains('UI') then
            if not Prompt.Contains('accessibility') then
                MissingElements.Add('accessibility_compliance');
    end;
    
    /// <summary>
    /// Builds enhanced prompt with standards references
    /// </summary>
    local procedure BuildEnhancedPrompt(OriginalPrompt: Text; StandardsReferences: List of [Text]): Text
    var
        EnhancedPrompt: Text;
        Reference: Text;
    begin
        EnhancedPrompt := OriginalPrompt;
        
        if StandardsReferences.Count() > 0 then begin
            EnhancedPrompt += ' following standards from:';
            foreach Reference in StandardsReferences do
                EnhancedPrompt += ' ' + Reference + ',';
            EnhancedPrompt := EnhancedPrompt.TrimEnd(',');
        end;
        
        exit(EnhancedPrompt);
    end;
}
```

### Educational Trigger System

```al
// Educational trigger implementation
codeunit 50101 "Educational Trigger System"
{
    /// <summary>
    /// Provides educational guidance based on development patterns
    /// </summary>
    procedure TriggerEducationalGuidance(DevelopmentAction: Text; CodeContent: Text; SkillLevel: Option Beginner,Intermediate,Advanced,Expert): Text
    var
        TriggerAnalysis: Record "Educational Trigger Analysis" temporary;
        GuidanceContent: Text;
        LearningLevel: Text;
    begin
        // Analyze development action for educational opportunities
        AnalyzeDevelopmentAction(DevelopmentAction, CodeContent, TriggerAnalysis);
        
        // Generate skill-appropriate guidance
        LearningLevel := Format(SkillLevel);
        GuidanceContent := GenerateEducationalContent(TriggerAnalysis, LearningLevel);
        
        exit(GuidanceContent);
    end;
    
    /// <summary>
    /// Analyzes development action for educational triggers
    /// </summary>
    local procedure AnalyzeDevelopmentAction(Action: Text; Content: Text; var TriggerAnalysis: Record "Educational Trigger Analysis" temporary)
    begin
        // Table creation without validation
        if Action.Contains('table') and not Content.Contains('OnValidate') then
            CreateTriggerAnalysis(TriggerAnalysis, 'TABLE_NO_VALIDATION', 'Validation patterns missing', 'error-handling-principles.md');
            
        // Page creation without error handling
        if Action.Contains('page') and not Content.Contains('Error(') then
            CreateTriggerAnalysis(TriggerAnalysis, 'PAGE_NO_ERROR_HANDLING', 'Error handling missing', 'error-prevention-strategies.md');
            
        // Codeunit without tests
        if Action.Contains('codeunit') and not Content.Contains('test') then
            CreateTriggerAnalysis(TriggerAnalysis, 'CODEUNIT_NO_TESTS', 'Testing strategy missing', 'test-data-patterns.md');
            
        // Integration without monitoring
        if Action.Contains('integration') and not Content.Contains('monitor') then
            CreateTriggerAnalysis(TriggerAnalysis, 'INTEGRATION_NO_MONITORING', 'Monitoring missing', 'performance-optimization-guidelines.md');
    end;
    
    /// <summary>
    /// Generates educational content based on skill level
    /// </summary>
    local procedure GenerateEducationalContent(var TriggerAnalysis: Record "Educational Trigger Analysis" temporary; SkillLevel: Text): Text
    var
        GuidanceContent: Text;
        ContentBuilder: Text;
    begin
        if TriggerAnalysis.FindSet() then begin
            repeat
                case TriggerAnalysis."Trigger Type" of
                    'TABLE_NO_VALIDATION':
                        ContentBuilder += GetValidationGuidance(SkillLevel) + '\n\n';
                    'PAGE_NO_ERROR_HANDLING':
                        ContentBuilder += GetErrorHandlingGuidance(SkillLevel) + '\n\n';
                    'CODEUNIT_NO_TESTS':
                        ContentBuilder += GetTestingGuidance(SkillLevel) + '\n\n';
                    'INTEGRATION_NO_MONITORING':
                        ContentBuilder += GetMonitoringGuidance(SkillLevel) + '\n\n';
                end;
            until TriggerAnalysis.Next() = 0;
        end;
        
        exit(ContentBuilder.TrimEnd('\n'));
    end;
    
    /// <summary>
    /// Gets validation guidance based on skill level
    /// </summary>
    local procedure GetValidationGuidance(SkillLevel: Text): Text
    begin
        case SkillLevel of
            'Beginner':
                exit('💡 Consider adding OnValidate() triggers to your table fields for data validation. This ensures data integrity and provides immediate feedback to users when they enter invalid data.');
                
            'Intermediate':
                exit('💡 Implement comprehensive field validation using OnValidate() triggers. Consider cross-field validation, business rule enforcement, and user-friendly error messages. Reference error-handling-principles.md for validation patterns.');
                
            'Advanced':
                exit('💡 Design a validation architecture that separates validation concerns, uses reusable validation procedures, and integrates with your business process workflows. Consider validation events for extensibility.');
                
            'Expert':
                exit('💡 Consider validation within domain-driven design principles. Implement validation as part of bounded contexts with event sourcing for audit trails and extensible validation frameworks for future requirements.');
        end;
    end;
    
    /// <summary>
    /// Gets error handling guidance based on skill level
    /// </summary>
    local procedure GetErrorHandlingGuidance(SkillLevel: Text): Text
    begin
        case SkillLevel of
            'Beginner':
                exit('💡 Add error handling to your pages using Error() statements with clear, user-friendly messages. This helps users understand what went wrong and how to fix it.');
                
            'Intermediate':
                exit('💡 Implement comprehensive error handling with progressive disclosure. Use TestField() for required fields, validate user inputs, and provide suggested actions. See error-prevention-strategies.md for patterns.');
                
            'Advanced':
                exit('💡 Design error handling as part of your user experience strategy. Implement contextual help, suggested actions, and integration with your logging and monitoring systems.');
                
            'Expert':
                exit('💡 Consider error handling within the broader system architecture. Implement error boundaries, circuit breakers for integrations, and comprehensive error analytics for continuous improvement.');
        end;
    end;
}
```

## Intermediate Proactive Suggestion Examples

### Context-Aware Suggestion Engine

```al
// Proactive suggestion system with context awareness
codeunit 50200 "Context Aware Suggestion Engine"
{
    /// <summary>
    /// Analyzes code context and provides targeted suggestions
    /// </summary>
    procedure AnalyzeAndSuggest(ObjectType: Text; ObjectCode: Text; DeveloperProfile: Text): Text
    var
        SuggestionEngine: Record "Suggestion Analysis" temporary;
        QualityMetrics: Record "Code Quality Metrics" temporary;
        SuggestionList: List of [Text];
        PrioritizedSuggestions: Text;
    begin
        // Analyze code quality
        AnalyzeCodeQuality(ObjectCode, QualityMetrics);
        
        // Generate context-specific suggestions
        GenerateContextualSuggestions(ObjectType, ObjectCode, DeveloperProfile, SuggestionList);
        
        // Prioritize suggestions based on impact and developer level
        PrioritizedSuggestions := PrioritizeSuggestions(SuggestionList, QualityMetrics, DeveloperProfile);
        
        exit(PrioritizedSuggestions);
    end;
    
    /// <summary>
    /// Analyzes code quality against established metrics
    /// </summary>
    local procedure AnalyzeCodeQuality(Code: Text; var QualityMetrics: Record "Code Quality Metrics" temporary)
    var
        ValidationScore: Integer;
        ErrorHandlingScore: Integer;
        DocumentationScore: Integer;
        TestingScore: Integer;
        PerformanceScore: Integer;
    begin
        // Score validation implementation
        ValidationScore := ScoreValidationImplementation(Code);
        CreateQualityMetric(QualityMetrics, 'VALIDATION', ValidationScore, 25);
        
        // Score error handling
        ErrorHandlingScore := ScoreErrorHandling(Code);
        CreateQualityMetric(QualityMetrics, 'ERROR_HANDLING', ErrorHandlingScore, 25);
        
        // Score documentation
        DocumentationScore := ScoreDocumentation(Code);
        CreateQualityMetric(QualityMetrics, 'DOCUMENTATION', DocumentationScore, 20);
        
        // Score testing approach
        TestingScore := ScoreTestingApproach(Code);
        CreateQualityMetric(QualityMetrics, 'TESTING', TestingScore, 20);
        
        // Score performance considerations
        PerformanceScore := ScorePerformanceConsiderations(Code);
        CreateQualityMetric(QualityMetrics, 'PERFORMANCE', PerformanceScore, 10);
    end;
    
    /// <summary>
    /// Generates targeted suggestions based on code analysis
    /// </summary>
    local procedure GenerateContextualSuggestions(ObjectType: Text; Code: Text; DeveloperProfile: Text; var SuggestionList: List of [Text])
    begin
        case ObjectType of
            'table':
                GenerateTableSuggestions(Code, DeveloperProfile, SuggestionList);
            'page':
                GeneratePageSuggestions(Code, DeveloperProfile, SuggestionList);
            'codeunit':
                GenerateCodeunitSuggestions(Code, DeveloperProfile, SuggestionList);
            'integration':
                GenerateIntegrationSuggestions(Code, DeveloperProfile, SuggestionList);
        end;
    end;
    
    /// <summary>
    /// Generates table-specific suggestions
    /// </summary>
    local procedure GenerateTableSuggestions(Code: Text; DeveloperProfile: Text; var SuggestionList: List of [Text])
    var
        Suggestion: Text;
    begin
        // Check for validation patterns
        if not Code.Contains('OnValidate') then begin
            Suggestion := '🔧 Add field validation triggers for data integrity. Reference: error-handling-principles.md';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for proper indexing
        if Code.Contains('FlowField') and not Code.Contains('SumIndexFields') then begin
            Suggestion := '⚡ Optimize FlowField performance by adding SumIndexFields to relevant keys';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for data classification
        if not Code.Contains('DataClassification') then begin
            Suggestion := '🔒 Add DataClassification to all fields for compliance and data privacy';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for ToolTip documentation
        if not Code.Contains('ToolTip') then begin
            Suggestion := '📝 Add ToolTip properties to fields for better user experience';
            SuggestionList.Add(Suggestion);
        end;
        
        // Developer-specific suggestions
        if DeveloperProfile.Contains('beginner') then begin
            Suggestion := '📚 Consider creating a test codeunit using test-data-patterns.md to validate your table logic';
            SuggestionList.Add(Suggestion);
        end else if DeveloperProfile.Contains('intermediate') then begin
            Suggestion := '🏗️ Document table business rules in your Azure DevOps work item for team reference';
            SuggestionList.Add(Suggestion);
        end;
    end;
    
    /// <summary>
    /// Generates page-specific suggestions
    /// </summary>
    local procedure GeneratePageSuggestions(Code: Text; DeveloperProfile: Text; var SuggestionList: List of [Text])
    var
        Suggestion: Text;
    begin
        // Check for error handling
        if not Code.Contains('Error(') and not Code.Contains('Message(') then begin
            Suggestion := '❌ Implement user-friendly error handling with clear messages and suggested actions';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for accessibility
        if not Code.Contains('AccessByPermission') and not Code.Contains('ShowCaption') then begin
            Suggestion := '♿ Review accessibility requirements from accessibility-standards.md for inclusive design';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for performance optimization
        if Code.Contains('SetRange') and not Code.Contains('SetLoadFields') then begin
            Suggestion := '⚡ Consider using SetLoadFields for better performance when loading records';
            SuggestionList.Add(Suggestion);
        end;
        
        // Check for actions and navigation
        if not Code.Contains('action(') then begin
            Suggestion := '🎯 Add relevant actions for common user tasks to improve user experience';
            SuggestionList.Add(Suggestion);
        end;
        
        // Developer-level specific suggestions
        if DeveloperProfile.Contains('advanced') then begin
            Suggestion := '🔄 Consider implementing refresh patterns for data consistency in multi-user scenarios';
            SuggestionList.Add(Suggestion);
        end;
    end;
    
    /// <summary>
    /// Scores validation implementation quality
    /// </summary>
    local procedure ScoreValidationImplementation(Code: Text): Integer
    var
        Score: Integer;
    begin
        Score := 0;
        
        // Basic validation triggers
        if Code.Contains('OnValidate') then Score += 30;
        
        // Error handling in validation
        if Code.Contains('Error(') then Score += 20;
        
        // TestField usage
        if Code.Contains('TestField') then Score += 20;
        
        // Business rule validation
        if Code.Contains('ValidateCustomer') or Code.Contains('ValidateItem') then Score += 20;
        
        // Cross-field validation
        if Code.Contains('xRec.') then Score += 10;
        
        exit(Score);
    end;
}
```

### DevOps Workflow Integration

```al
// DevOps workflow integration for AI guidance
codeunit 50201 "DevOps AI Integration"
{
    /// <summary>
    /// Integrates AI suggestions with Azure DevOps workflows
    /// </summary>
    procedure IntegrateWithDevOpsWorkflow(WorkItemId: Integer; CodeContent: Text; DevelopmentPhase: Text)
    var
        QualityGateResults: Text;
        AIRecommendations: Text;
        WorkItemUpdate: Text;
        QualityScore: Integer;
    begin
        // Analyze code against quality gates
        QualityGateResults := AnalyzeQualityGates(CodeContent, DevelopmentPhase);
        
        // Generate AI recommendations
        AIRecommendations := GenerateAIRecommendations(CodeContent, DevelopmentPhase);
        
        // Calculate overall quality score
        QualityScore := CalculateOverallQualityScore(CodeContent);
        
        // Build comprehensive work item update
        WorkItemUpdate := BuildWorkItemUpdate(QualityGateResults, AIRecommendations, QualityScore);
        
        // Update work item with AI guidance
        UpdateWorkItemWithAIGuidance(WorkItemId, WorkItemUpdate, DevelopmentPhase);
        
        // Set up follow-up actions if needed
        if QualityScore < 70 then
            ScheduleQualityReviewFollowUp(WorkItemId, QualityScore);
    end;
    
    /// <summary>
    /// Analyzes code against defined quality gates
    /// </summary>
    local procedure AnalyzeQualityGates(CodeContent: Text; DevelopmentPhase: Text): Text
    var
        QualityGate: Record "Development Quality Gate";
        GateResults: List of [Text];
        PassedGates: Integer;
        TotalGates: Integer;
        ResultText: Text;
    begin
        // Get quality gates for the development phase
        QualityGate.SetRange("Development Phase", DevelopmentPhase);
        QualityGate.SetRange(Active, true);
        
        if QualityGate.FindSet() then begin
            repeat
                TotalGates += 1;
                
                if EvaluateQualityGate(QualityGate, CodeContent) then begin
                    PassedGates += 1;
                    GateResults.Add('✅ ' + QualityGate."Gate Name" + ': PASSED');
                end else begin
                    GateResults.Add('❌ ' + QualityGate."Gate Name" + ': FAILED - ' + QualityGate."Failure Guidance");
                end;
            until QualityGate.Next() = 0;
        end;
        
        // Build results summary
        ResultText := StrSubstNo('## Quality Gate Analysis\n**Results: %1/%2 Gates Passed**\n\n', PassedGates, TotalGates);
        ResultText += JoinListWithNewlines(GateResults);
        
        exit(ResultText);
    end;
    
    /// <summary>
    /// Evaluates individual quality gate against code content
    /// </summary>
    local procedure EvaluateQualityGate(QualityGate: Record "Development Quality Gate"; CodeContent: Text): Boolean
    begin
        case QualityGate."Gate Type" of
            QualityGate."Gate Type"::"Validation Required":
                exit(CodeContent.Contains('OnValidate') or CodeContent.Contains('TestField'));
            QualityGate."Gate Type"::"Error Handling Required":
                exit(CodeContent.Contains('Error(') or CodeContent.Contains('Message('));
            QualityGate."Gate Type"::"Documentation Required":
                exit(CodeContent.Contains('ToolTip') or CodeContent.Contains('Caption'));
            QualityGate."Gate Type"::"Data Classification Required":
                exit(CodeContent.Contains('DataClassification'));
            QualityGate."Gate Type"::"Performance Consideration":
                exit(CodeContent.Contains('SetLoadFields') or CodeContent.Contains('SetRange'));
            else
                exit(true); // Unknown gate type passes by default
        end;
    end;
    
    /// <summary>
    /// Builds comprehensive work item update with AI guidance
    /// </summary>
    local procedure BuildWorkItemUpdate(QualityResults: Text; Recommendations: Text; QualityScore: Integer): Text
    var
        UpdateContent: Text;
        QualityLevel: Text;
    begin
        // Determine quality level description
        case true of
            QualityScore >= 90: QualityLevel := '🟢 Excellent';
            QualityScore >= 80: QualityLevel := '🟡 Good';
            QualityScore >= 70: QualityLevel := '🟠 Needs Improvement';
            else QualityLevel := '🔴 Requires Attention';
        end;
        
        // Build update content
        UpdateContent := '# AI Code Quality Analysis\n\n';
        UpdateContent += StrSubstNo('**Overall Quality Score: %1 (%2)**\n\n', QualityScore, QualityLevel);
        UpdateContent += QualityResults + '\n\n';
        UpdateContent += '## AI Recommendations\n\n';
        UpdateContent += Recommendations + '\n\n';
        UpdateContent += '## Next Steps\n\n';
        
        if QualityScore < 70 then begin
            UpdateContent += '- Address failed quality gates before proceeding\n';
            UpdateContent += '- Schedule code review with senior team member\n';
            UpdateContent += '- Consider refactoring for better maintainability\n';
        end else if QualityScore < 90 then begin
            UpdateContent += '- Address minor quality improvements\n';
            UpdateContent += '- Consider additional testing scenarios\n';
        end else begin
            UpdateContent += '- Code meets quality standards\n';
            UpdateContent += '- Ready for peer review and testing\n';
        end;
        
        UpdateContent += '\n---\n*Generated by AI Code Quality Assistant*';
        
        exit(UpdateContent);
    end;
}
```

## Advanced Adaptive Learning Examples

### Learning Progression Tracking System

```al
// Advanced learning progression and adaptation system
codeunit 50300 "Learning Progression Manager"
{
    /// <summary>
    /// Tracks and adapts to developer learning progression
    /// </summary>
    procedure TrackLearningProgression(DeveloperUserId: Code[50]; TaskContext: Text; CodeQuality: Integer; CompletionTime: Integer)
    var
        LearningProfile: Record "Developer Learning Profile";
        ProgressionAnalysis: Record "Learning Progression Analysis" temporary;
        AdaptationSuggestions: Text;
        NextLearningObjectives: List of [Text];
    begin
        // Get or create learning profile
        if not LearningProfile.Get(DeveloperUserId) then
            CreateInitialLearningProfile(LearningProfile, DeveloperUserId);
        
        // Analyze current task performance
        AnalyzeTaskPerformance(TaskContext, CodeQuality, CompletionTime, ProgressionAnalysis);
        
        // Update learning profile based on performance
        UpdateLearningProfile(LearningProfile, ProgressionAnalysis, TaskContext);
        
        // Generate adaptive suggestions for improvement
        AdaptationSuggestions := GenerateAdaptiveSuggestions(LearningProfile, ProgressionAnalysis);
        
        // Identify next learning objectives
        IdentifyNextLearningObjectives(LearningProfile, TaskContext, NextLearningObjectives);
        
        // Create personalized learning plan
        CreatePersonalizedLearningPlan(LearningProfile, NextLearningObjectives);
        
        // Send progress update to developer
        SendLearningProgressUpdate(DeveloperUserId, LearningProfile, AdaptationSuggestions, NextLearningObjectives);
    end;
    
    /// <summary>
    /// Provides personalized mentoring based on learning profile
    /// </summary>
    procedure ProvidePersonalizedMentoring(DeveloperUserId: Code[50]; CurrentChallenge: Text; RequestedGuidanceLevel: Integer): Text
    var
        LearningProfile: Record "Developer Learning Profile";
        MentoringContent: Text;
        LearningResources: List of [Text];
        PracticalExamples: List of [Text];
        FollowUpActions: List of [Text];
    begin
        // Get developer's learning profile
        LearningProfile.Get(DeveloperUserId);
        
        // Generate personalized mentoring content
        MentoringContent := GeneratePersonalizedContent(LearningProfile, CurrentChallenge, RequestedGuidanceLevel);
        
        // Provide relevant learning resources
        GetPersonalizedLearningResources(LearningProfile, CurrentChallenge, LearningResources);
        
        // Create practical examples based on learning style
        CreatePersonalizedExamples(LearningProfile, CurrentChallenge, PracticalExamples);
        
        // Suggest follow-up actions for continued learning
        SuggestFollowUpActions(LearningProfile, CurrentChallenge, FollowUpActions);
        
        // Track mentoring interaction
        TrackMentoringInteraction(LearningProfile, CurrentChallenge, RequestedGuidanceLevel);
        
        exit(BuildMentoringResponse(MentoringContent, LearningResources, PracticalExamples, FollowUpActions));
    end;
    
    /// <summary>
    /// Analyzes task performance against learning objectives
    /// </summary>
    local procedure AnalyzeTaskPerformance(TaskContext: Text; CodeQuality: Integer; CompletionTime: Integer; var ProgressionAnalysis: Record "Learning Progression Analysis" temporary)
    var
        ExpectedQuality: Integer;
        ExpectedTime: Integer;
        QualityDelta: Integer;
        TimeDelta: Integer;
    begin
        // Get expected performance baselines
        ExpectedQuality := GetExpectedQualityForTask(TaskContext);
        ExpectedTime := GetExpectedTimeForTask(TaskContext);
        
        // Calculate performance deltas
        QualityDelta := CodeQuality - ExpectedQuality;
        TimeDelta := ExpectedTime - CompletionTime; // Positive means faster than expected
        
        // Create performance analysis
        ProgressionAnalysis.Init();
        ProgressionAnalysis."Task Context" := CopyStr(TaskContext, 1, MaxStrLen(ProgressionAnalysis."Task Context"));
        ProgressionAnalysis."Actual Quality" := CodeQuality;
        ProgressionAnalysis."Expected Quality" := ExpectedQuality;
        ProgressionAnalysis."Quality Delta" := QualityDelta;
        ProgressionAnalysis."Actual Time" := CompletionTime;
        ProgressionAnalysis."Expected Time" := ExpectedTime;
        ProgressionAnalysis."Time Delta" := TimeDelta;
        ProgressionAnalysis."Performance Level" := DeterminePerformanceLevel(QualityDelta, TimeDelta);
        ProgressionAnalysis.Insert();
    end;
    
    /// <summary>
    /// Updates learning profile based on performance analysis
    /// </summary>
    local procedure UpdateLearningProfile(var LearningProfile: Record "Developer Learning Profile"; var ProgressionAnalysis: Record "Learning Progression Analysis" temporary; TaskContext: Text)
    var
        SkillArea: Text;
        PerformanceImprovement: Boolean;
        LearningVelocity: Decimal;
    begin
        // Determine skill area being practiced
        SkillArea := DetermineSkillArea(TaskContext);
        
        // Check if performance improved from last similar task
        PerformanceImprovement := CheckPerformanceImprovement(LearningProfile."User ID", SkillArea, ProgressionAnalysis."Performance Level");
        
        // Calculate learning velocity
        LearningVelocity := CalculateLearningVelocity(LearningProfile, SkillArea, PerformanceImprovement);
        
        // Update profile based on analysis
        case SkillArea of
            'Validation':
                UpdateValidationSkills(LearningProfile, ProgressionAnalysis, LearningVelocity);
            'Error Handling':
                UpdateErrorHandlingSkills(LearningProfile, ProgressionAnalysis, LearningVelocity);
            'Testing':
                UpdateTestingSkills(LearningProfile, ProgressionAnalysis, LearningVelocity);
            'Integration':
                UpdateIntegrationSkills(LearningProfile, ProgressionAnalysis, LearningVelocity);
            'Performance':
                UpdatePerformanceSkills(LearningProfile, ProgressionAnalysis, LearningVelocity);
        end;
        
        // Update overall learning metrics
        LearningProfile."Total Tasks Completed" += 1;
        LearningProfile."Last Activity Date" := Today();
        LearningProfile."Learning Velocity" := LearningVelocity;
        LearningProfile."Performance Trend" := DeterminePerformanceTrend(LearningProfile);
        
        LearningProfile.Modify(true);
    end;
    
    /// <summary>
    /// Generates adaptive suggestions based on learning profile
    /// </summary>
    local procedure GenerateAdaptiveSuggestions(var LearningProfile: Record "Developer Learning Profile"; var ProgressionAnalysis: Record "Learning Progression Analysis" temporary): Text
    var
        SuggestionBuilder: Text;
        StrengthAreas: List of [Text];
        ImprovementAreas: List of [Text];
        LearningRecommendations: List of [Text];
    begin
        // Identify strength and improvement areas
        IdentifyStrengthAreas(LearningProfile, StrengthAreas);
        IdentifyImprovementAreas(LearningProfile, ImprovementAreas);
        
        // Generate learning recommendations
        GenerateLearningRecommendations(LearningProfile, ProgressionAnalysis, LearningRecommendations);
        
        // Build adaptive suggestions
        SuggestionBuilder := '## Your Learning Progress\n\n';
        
        if StrengthAreas.Count() > 0 then begin
            SuggestionBuilder += '### 💪 Your Strengths\n';
            SuggestionBuilder += '- ' + JoinList(StrengthAreas, '\n- ') + '\n\n';
        end;
        
        if ImprovementAreas.Count() > 0 then begin
            SuggestionBuilder += '### 🎯 Areas for Growth\n';
            SuggestionBuilder += '- ' + JoinList(ImprovementAreas, '\n- ') + '\n\n';
        end;
        
        if LearningRecommendations.Count() > 0 then begin
            SuggestionBuilder += '### 📚 Personalized Recommendations\n';
            SuggestionBuilder += '- ' + JoinList(LearningRecommendations, '\n- ') + '\n\n';
        end;
        
        SuggestionBuilder += '### 📈 Next Steps\n';
        SuggestionBuilder += GenerateNextSteps(LearningProfile, ProgressionAnalysis);
        
        exit(SuggestionBuilder);
    end;
}
```

## Expert-Level Mentoring System Examples

### Comprehensive Knowledge Transfer System

```al
// Expert-level comprehensive mentoring and knowledge transfer system
codeunit 50400 "Expert Mentoring System"
{
    /// <summary>
    /// Orchestrates comprehensive knowledge transfer between team members
    /// </summary>
    procedure OrchestateKnowledgeTransfer(MentorUserId: Code[50]; MenteeUserId: Code[50]; KnowledgeArea: Text[100]; TransferObjectives: Text)
    var
        KnowledgeTransferPlan: Record "Knowledge Transfer Plan";
        LearningModules: List of [Text];
        ValidationCriteria: List of [Text];
        MilestoneSchedule: Record "Transfer Milestone" temporary;
        SuccessMetrics: Record "Transfer Success Metrics";
    begin
        // Create comprehensive transfer plan
        CreateKnowledgeTransferPlan(KnowledgeTransferPlan, MentorUserId, MenteeUserId, KnowledgeArea, TransferObjectives);
        
        // Design structured learning modules
        DesignLearningModules(KnowledgeArea, TransferObjectives, LearningModules);
        
        // Establish validation criteria for knowledge acquisition
        EstablishValidationCriteria(KnowledgeArea, LearningModules, ValidationCriteria);
        
        // Create milestone schedule with checkpoints
        CreateMilestoneSchedule(KnowledgeTransferPlan, LearningModules, ValidationCriteria, MilestoneSchedule);
        
        // Set up success metrics and tracking
        EstablishSuccessMetrics(KnowledgeTransferPlan, SuccessMetrics);
        
        // Initiate transfer process
        InitiateKnowledgeTransferProcess(KnowledgeTransferPlan, MilestoneSchedule);
        
        // Set up monitoring and feedback loops
        EstablishTransferMonitoring(KnowledgeTransferPlan, SuccessMetrics);
    end;
    
    /// <summary>
    /// Provides architectural decision support with comprehensive analysis
    /// </summary>
    procedure ProvideArchitecturalDecisionSupport(DecisionContext: Text; RequirementsAnalysis: Text; ConstraintsAnalysis: Text; StakeholderContext: Text): Text
    var
        ArchitecturalOptions: List of [Text];
        DecisionMatrix: Record "Architectural Decision Matrix" temporary;
        RiskAnalysis: Record "Decision Risk Analysis" temporary;
        RecommendedApproach: Text;
        ComprehensiveGuidance: Text;
        ImplementationRoadmap: Text;
        StakeholderCommunication: Text;
    begin
        // Analyze all architectural options
        AnalyzeArchitecturalOptions(DecisionContext, RequirementsAnalysis, ConstraintsAnalysis, ArchitecturalOptions);
        
        // Create comprehensive decision matrix
        CreateArchitecturalDecisionMatrix(DecisionMatrix, ArchitecturalOptions, RequirementsAnalysis, ConstraintsAnalysis);
        
        // Conduct risk analysis for each option
        ConductRiskAnalysis(ArchitecturalOptions, ConstraintsAnalysis, RiskAnalysis);
        
        // Determine recommended approach with rationale
        RecommendedApproach := DetermineRecommendedApproach(DecisionMatrix, RiskAnalysis);
        
        // Generate comprehensive guidance
        ComprehensiveGuidance := GenerateArchitecturalGuidance(RecommendedApproach, DecisionMatrix, RiskAnalysis);
        
        // Create implementation roadmap
        ImplementationRoadmap := CreateImplementationRoadmap(RecommendedApproach, RequirementsAnalysis, ConstraintsAnalysis);
        
        // Generate stakeholder communication plan
        StakeholderCommunication := GenerateStakeholderCommunication(RecommendedApproach, DecisionMatrix, StakeholderContext);
        
        // Document decision for organizational learning
        DocumentArchitecturalDecision(DecisionContext, RecommendedApproach, ComprehensiveGuidance, RiskAnalysis);
        
        // Build comprehensive response
        exit(BuildArchitecturalDecisionResponse(RecommendedApproach, ComprehensiveGuidance, ImplementationRoadmap, StakeholderCommunication));
    end;
    
    /// <summary>
    /// Creates organizational learning systems from development experiences
    /// </summary>
    procedure CreateOrganizationalLearningSystem(DevelopmentExperiences: Text; TeamLearnings: Text; ProjectOutcomes: Text; OrganizationalContext: Text)
    var
        OrganizationalKnowledge: Record "Organizational Knowledge Base";
        LearningPatterns: List of [Text];
        BestPractices: List of [Text];
        LessonsLearned: List of [Text];
        KnowledgeArtifacts: Record "Knowledge Artifact" temporary;
        LearningFramework: Record "Organizational Learning Framework";
    begin
        // Extract and categorize learning patterns
        ExtractLearningPatterns(DevelopmentExperiences, TeamLearnings, ProjectOutcomes, LearningPatterns);
        
        // Identify emergent best practices
        IdentifyBestPractices(LearningPatterns, OrganizationalContext, BestPractices);
        
        // Capture contextual lessons learned
        CaptureLessonsLearned(DevelopmentExperiences, TeamLearnings, ProjectOutcomes, LessonsLearned);
        
        // Create reusable knowledge artifacts
        CreateKnowledgeArtifacts(LearningPatterns, BestPractices, LessonsLearned, KnowledgeArtifacts);
        
        // Establish knowledge validation processes
        EstablishKnowledgeValidation(OrganizationalKnowledge, KnowledgeArtifacts);
        
        // Implement knowledge discovery system
        ImplementKnowledgeDiscovery(OrganizationalKnowledge, KnowledgeArtifacts);
        
        // Create feedback loops for continuous improvement
        CreateKnowledgeRefinementSystem(OrganizationalKnowledge, LearningFramework);
        
        // Establish metrics for learning effectiveness
        EstablishLearningEffectivenessMetrics(LearningFramework);
        
        // Document organizational learning system
        DocumentOrganizationalLearningSystem(LearningFramework, OrganizationalKnowledge, KnowledgeArtifacts);
    end;
    
    /// <summary>
    /// Designs learning modules for knowledge transfer
    /// </summary>
    local procedure DesignLearningModules(KnowledgeArea: Text[100]; TransferObjectives: Text; var LearningModules: List of [Text])
    var
        Module: Text;
        ObjectiveLines: List of [Text];
        Objective: Text;
        ModuleBuilder: Text;
    begin
        // Split objectives into individual learning goals
        SplitTextIntoLines(TransferObjectives, ObjectiveLines);
        
        // Create modules based on knowledge area
        case KnowledgeArea of
            'AL Development Patterns':
                begin
                    LearningModules.Add('Module 1: Foundation Patterns - Table and Page Design');
                    LearningModules.Add('Module 2: Business Logic Patterns - Codeunit Design and Validation');
                    LearningModules.Add('Module 3: Integration Patterns - API Design and Error Handling');
                    LearningModules.Add('Module 4: Performance Patterns - Optimization and Monitoring');
                    LearningModules.Add('Module 5: Testing Patterns - Comprehensive Test Strategy');
                end;
                
            'System Architecture':
                begin
                    LearningModules.Add('Module 1: Architectural Principles and Decision Making');
                    LearningModules.Add('Module 2: Design Patterns and Implementation Strategies');
                    LearningModules.Add('Module 3: Integration Architecture and API Design');
                    LearningModules.Add('Module 4: Scalability and Performance Architecture');
                    LearningModules.Add('Module 5: Security and Compliance Architecture');
                end;
                
            'DevOps Integration':
                begin
                    LearningModules.Add('Module 1: CI/CD Pipeline Design and Implementation');
                    LearningModules.Add('Module 2: Quality Gates and Automated Testing');
                    LearningModules.Add('Module 3: Deployment Strategies and Environment Management');
                    LearningModules.Add('Module 4: Monitoring and Observability');
                    LearningModules.Add('Module 5: Security and Compliance in DevOps');
                end;
        end;
        
        // Customize modules based on specific objectives
        foreach Objective in ObjectiveLines do begin
            if not IsModuleCovered(Objective, LearningModules) then begin
                ModuleBuilder := 'Custom Module: ' + Objective;
                LearningModules.Add(ModuleBuilder);
            end;
        end;
    end;
    
    /// <summary>
    /// Establishes validation criteria for knowledge transfer
    /// </summary>
    local procedure EstablishValidationCriteria(KnowledgeArea: Text[100]; LearningModules: List of [Text]; var ValidationCriteria: List of [Text])
    var
        Module: Text;
        Criteria: Text;
    begin
        // Create validation criteria for each module
        foreach Module in LearningModules do begin
            if Module.Contains('Foundation Patterns') then begin
                Criteria := 'Demonstrate table design with proper validation and error handling';
                ValidationCriteria.Add(Criteria);
                Criteria := 'Create page with user-friendly interface and accessibility compliance';
                ValidationCriteria.Add(Criteria);
            end;
            
            if Module.Contains('Business Logic Patterns') then begin
                Criteria := 'Implement codeunit with comprehensive business validation';
                ValidationCriteria.Add(Criteria);
                Criteria := 'Design error handling with user guidance and recovery options';
                ValidationCriteria.Add(Criteria);
            end;
            
            if Module.Contains('Integration Patterns') then begin
                Criteria := 'Create robust API integration with retry logic and monitoring';
                ValidationCriteria.Add(Criteria);
                Criteria := 'Implement comprehensive error handling for external system failures';
                ValidationCriteria.Add(Criteria);
            end;
            
            if Module.Contains('Performance Patterns') then begin
                Criteria := 'Demonstrate performance optimization techniques with measurable results';
                ValidationCriteria.Add(Criteria);
                Criteria := 'Implement monitoring and alerting for performance metrics';
                ValidationCriteria.Add(Criteria);
            end;
            
            if Module.Contains('Testing Patterns') then begin
                Criteria := 'Create comprehensive test suite with boundary and integration tests';
                ValidationCriteria.Add(Criteria);
                Criteria := 'Demonstrate test data management and cleanup strategies';
                ValidationCriteria.Add(Criteria);
            end;
        end;
    end;
}
```
