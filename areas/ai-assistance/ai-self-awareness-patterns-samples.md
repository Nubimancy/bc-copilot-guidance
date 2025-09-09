```al
// ✅ AI Self-Awareness Framework Implementation
codeunit 50140 "AI Self-Awareness Controller"
{
    procedure EvaluateSuggestionReliability(SuggestionType: Text; Context: Text): Integer
    var
        ReliabilityScore: Integer;
        ContextQuality: Integer;
        SuggestionComplexity: Integer;
    begin
        // Evaluate different factors that affect reliability
        ContextQuality := EvaluateContextQuality(Context);
        SuggestionComplexity := EvaluateSuggestionComplexity(SuggestionType);
        
        // Calculate overall reliability score (0-100)
        ReliabilityScore := CalculateReliabilityScore(ContextQuality, SuggestionComplexity);
        
        // Generate self-awareness recommendations
        GenerateSelfAwarenessGuidance(SuggestionType, ReliabilityScore);
        
        exit(ReliabilityScore);
    end;

    local procedure EvaluateContextQuality(Context: Text): Integer
    var
        ContextScore: Integer;
    begin
        ContextScore := 50; // Base score
        
        // Check for business requirements
        if StrPos(Context, 'business requirement') > 0 then
            ContextScore += 15;
            
        // Check for technical specifications
        if StrPos(Context, 'technical specification') > 0 then
            ContextScore += 15;
            
        // Check for Business Central version
        if (StrPos(Context, 'BC') > 0) or (StrPos(Context, 'Business Central') > 0) then
            ContextScore += 10;
            
        // Check for existing codebase reference
        if StrPos(Context, 'existing pattern') > 0 then
            ContextScore += 10;

        exit(ContextScore);
    end;

    local procedure EvaluateSuggestionComplexity(SuggestionType: Text): Integer
    var
        ComplexityPenalty: Integer;
    begin
        // Higher complexity = lower reliability score
        case SuggestionType of
            'BASIC_SYNTAX':
                ComplexityPenalty := 0;
            'API_CALL':
                ComplexityPenalty := 20;
            'BUSINESS_LOGIC':
                ComplexityPenalty := 30;
            'INTEGRATION':
                ComplexityPenalty := 40;
            'PERFORMANCE_OPTIMIZATION':
                ComplexityPenalty := 35;
            else
                ComplexityPenalty := 25;
        end;

        exit(100 - ComplexityPenalty);
    end;

    local procedure CalculateReliabilityScore(ContextQuality: Integer; ComplexityScore: Integer): Integer
    var
        ReliabilityScore: Integer;
    begin
        // Weighted combination of factors
        ReliabilityScore := Round((ContextQuality * 0.4) + (ComplexityScore * 0.6), 1);
        
        // Ensure score stays within bounds
        if ReliabilityScore > 100 then
            ReliabilityScore := 100;
        if ReliabilityScore < 0 then
            ReliabilityScore := 0;

        exit(ReliabilityScore);
    end;

    local procedure GenerateSelfAwarenessGuidance(SuggestionType: Text; ReliabilityScore: Integer)
    var
        GuidanceMessage: Text;
        ValidationLevel: Text;
    begin
        // Determine appropriate validation level
        case true of
            ReliabilityScore >= 85:
                ValidationLevel := 'Basic validation recommended';
            ReliabilityScore >= 70:
                ValidationLevel := 'Moderate validation required';
            ReliabilityScore >= 50:
                ValidationLevel := 'Comprehensive validation essential';
            else
                ValidationLevel := 'Deep validation and expert review required';
        end;

        // Generate context-aware guidance
        GuidanceMessage := StrSubstNo('AI Self-Awareness: Reliability score %1/100. %2. Consider %3.',
            ReliabilityScore,
            GetReliabilityExplanation(ReliabilityScore),
            GetValidationRecommendation(SuggestionType, ReliabilityScore));

        // Store guidance for reference
        LogSelfAwarenessGuidance(SuggestionType, ReliabilityScore, GuidanceMessage);
    end;

    local procedure GetReliabilityExplanation(Score: Integer): Text
    begin
        case true of
            Score >= 85:
                exit('High confidence in suggestion accuracy');
            Score >= 70:
                exit('Good confidence with minor validation needed');
            Score >= 50:
                exit('Moderate confidence - validation important');
            else
                exit('Low confidence - extensive validation critical');
        end;
    end;

    local procedure GetValidationRecommendation(SuggestionType: Text; Score: Integer): Text
    var
        Recommendation: Text;
    begin
        // Tailor recommendations based on type and score
        case SuggestionType of
            'API_CALL':
                if Score < 70 then
                    Recommendation := 'Verify API exists in Business Central documentation'
                else
                    Recommendation := 'Quick IntelliSense verification';
            'BUSINESS_LOGIC':
                if Score < 60 then
                    Recommendation := 'Business expert review and comprehensive testing'
                else
                    Recommendation := 'Business rule validation and unit testing';
            'INTEGRATION':
                if Score < 65 then
                    Recommendation := 'Integration testing in development environment'
                else
                    Recommendation := 'Basic integration validation';
            else
                if Score < 70 then
                    Recommendation := 'Code review and testing'
                else
                    Recommendation := 'Standard quality checks';
        end;

        exit(Recommendation);
    end;

    local procedure LogSelfAwarenessGuidance(SuggestionType: Text; Score: Integer; Guidance: Text)
    var
        SelfAwarenessLog: Record "AI Self-Awareness Log";
    begin
        SelfAwarenessLog.Init();
        SelfAwarenessLog."Entry No." := GetNextLogEntry();
        SelfAwarenessLog."Log Date" := Today;
        SelfAwarenessLog."Log Time" := Time;
        SelfAwarenessLog."Suggestion Type" := SuggestionType;
        SelfAwarenessLog."Reliability Score" := Score;
        SelfAwarenessLog."Guidance Message" := Guidance;
        SelfAwarenessLog.Insert(true);
    end;
}

// ✅ Meta-Prompting Pattern Implementation
codeunit 50141 "Meta-Prompting Controller"
{
    procedure OptimizePromptStrategy(OriginalPrompt: Text; DesiredOutcome: Text): Text
    var
        AnalyzedPrompt: Record "Prompt Analysis";
        OptimizedPrompt: Text;
    begin
        // Analyze original prompt effectiveness
        AnalyzedPrompt := AnalyzePromptStructure(OriginalPrompt);
        
        // Generate optimization recommendations
        OptimizedPrompt := GenerateOptimizedPrompt(AnalyzedPrompt, DesiredOutcome);
        
        // Store optimization patterns for learning
        StoreOptimizationPattern(OriginalPrompt, OptimizedPrompt, DesiredOutcome);
        
        exit(OptimizedPrompt);
    end;

    local procedure AnalyzePromptStructure(Prompt: Text): Record "Prompt Analysis"
    var
        Analysis: Record "Prompt Analysis";
    begin
        Analysis.Init();
        Analysis."Original Prompt" := Prompt;
        Analysis."Context Quality" := EvaluateContextInPrompt(Prompt);
        Analysis."Specificity Level" := EvaluatePromptSpecificity(Prompt);
        Analysis."Constraint Clarity" := EvaluateConstraintClarity(Prompt);
        Analysis."Expected Output Definition" := EvaluateOutputDefinition(Prompt);
        
        exit(Analysis);
    end;

    local procedure EvaluateContextInPrompt(Prompt: Text): Integer
    var
        ContextScore: Integer;
    begin
        ContextScore := 0;
        
        // Check for business context
        if (StrPos(Prompt, 'business') > 0) or (StrPos(Prompt, 'requirement') > 0) then
            ContextScore += 25;
            
        // Check for technical context
        if (StrPos(Prompt, 'AL') > 0) or (StrPos(Prompt, 'Business Central') > 0) then
            ContextScore += 25;
            
        // Check for constraints
        if (StrPos(Prompt, 'following') > 0) or (StrPos(Prompt, 'using') > 0) then
            ContextScore += 25;
            
        // Check for examples
        if StrPos(Prompt, 'example') > 0 then
            ContextScore += 25;

        exit(ContextScore);
    end;

    local procedure GenerateOptimizedPrompt(Analysis: Record "Prompt Analysis"; Outcome: Text): Text
    var
        OptimizedPrompt: TextBuilder;
    begin
        // Start with enhanced context
        OptimizedPrompt.Append('Create a Business Central AL solution that ');
        
        // Add specific outcome
        OptimizedPrompt.Append(Outcome);
        OptimizedPrompt.AppendLine('');
        
        // Add context improvements based on analysis
        if Analysis."Context Quality" < 50 then begin
            OptimizedPrompt.AppendLine('Context: Business Central extension development');
            OptimizedPrompt.AppendLine('Target Version: Business Central 2023 or later');
        end;
        
        // Add specificity improvements
        if Analysis."Specificity Level" < 60 then begin
            OptimizedPrompt.AppendLine('Requirements:');
            OptimizedPrompt.AppendLine('- Follow AL development best practices');
            OptimizedPrompt.AppendLine('- Include proper error handling');
            OptimizedPrompt.AppendLine('- Use appropriate object naming conventions');
        end;
        
        // Add constraint clarity
        if Analysis."Constraint Clarity" < 50 then begin
            OptimizedPrompt.AppendLine('Constraints:');
            OptimizedPrompt.AppendLine('- Object numbers in range 50000-99999');
            OptimizedPrompt.AppendLine('- Follow standard AL coding patterns');
            OptimizedPrompt.AppendLine('- Include XML documentation comments');
        end;
        
        // Add output definition
        if Analysis."Expected Output Definition" < 60 then begin
            OptimizedPrompt.AppendLine('Expected Output:');
            OptimizedPrompt.AppendLine('- Complete AL code implementation');
            OptimizedPrompt.AppendLine('- Explanation of design decisions');
            OptimizedPrompt.AppendLine('- Testing recommendations');
        end;

        exit(OptimizedPrompt.ToText());
    end;

    local procedure StoreOptimizationPattern(Original: Text; Optimized: Text; Outcome: Text)
    var
        OptimizationPattern: Record "Prompt Optimization Pattern";
    begin
        OptimizationPattern.Init();
        OptimizationPattern."Entry No." := GetNextOptimizationEntry();
        OptimizationPattern."Original Prompt" := Original;
        OptimizationPattern."Optimized Prompt" := Optimized;
        OptimizationPattern."Desired Outcome" := Outcome;
        OptimizationPattern."Creation Date" := Today;
        OptimizationPattern."Optimization Type" := DetermineOptimizationType(Original, Optimized);
        OptimizationPattern.Insert(true);
    end;

    local procedure DetermineOptimizationType(Original: Text; Optimized: Text): Text
    begin
        if StrLen(Optimized) > (StrLen(Original) * 1.5) then
            exit('Context Enhancement')
        else if StrPos(Optimized, 'Requirements:') > 0 then
            exit('Specificity Improvement')
        else if StrPos(Optimized, 'Constraints:') > 0 then
            exit('Constraint Clarification')
        else
            exit('Structure Optimization');
    end;
}

// ✅ Context-Aware Validation Patterns
codeunit 50142 "Context-Aware Validator"
{
    procedure ValidateWithContextAwareness(Code: Text; BusinessContext: Text; TechnicalContext: Text): Record "Validation Result"
    var
        ValidationResult: Record "Validation Result";
        ValidationLevel: Integer;
    begin
        // Determine appropriate validation level based on context
        ValidationLevel := DetermineValidationLevel(BusinessContext, TechnicalContext);
        
        // Execute context-appropriate validation
        ValidationResult := ExecuteContextualValidation(Code, ValidationLevel, BusinessContext, TechnicalContext);
        
        // Generate context-aware recommendations
        GenerateContextualRecommendations(ValidationResult, BusinessContext, TechnicalContext);
        
        exit(ValidationResult);
    end;

    local procedure DetermineValidationLevel(BusinessContext: Text; TechnicalContext: Text): Integer
    var
        ValidationLevel: Integer;
    begin
        ValidationLevel := 1; // Base level
        
        // Increase level based on business criticality
        if (StrPos(BusinessContext, 'financial') > 0) or (StrPos(BusinessContext, 'posting') > 0) then
            ValidationLevel := 3;
        else if StrPos(BusinessContext, 'customer') > 0 then
            ValidationLevel := 2;
            
        // Increase level based on technical complexity
        if (StrPos(TechnicalContext, 'integration') > 0) or (StrPos(TechnicalContext, 'API') > 0) then
            ValidationLevel := MaxValue(ValidationLevel, 3);
        else if StrPos(TechnicalContext, 'performance') > 0 then
            ValidationLevel := MaxValue(ValidationLevel, 2);

        exit(ValidationLevel);
    end;

    local procedure ExecuteContextualValidation(Code: Text; Level: Integer; BusinessCtx: Text; TechnicalCtx: Text): Record "Validation Result"
    var
        ValidationResult: Record "Validation Result";
        BasicValidator: Codeunit "Basic Code Validator";
        AdvancedValidator: Codeunit "Advanced Code Validator";
        ExpertValidator: Codeunit "Expert Code Validator";
    begin
        ValidationResult.Init();
        ValidationResult."Validation Level" := Level;
        ValidationResult."Business Context" := BusinessCtx;
        ValidationResult."Technical Context" := TechnicalCtx;
        
        // Execute appropriate level of validation
        case Level of
            1:
                ValidationResult := BasicValidator.ValidateCode(Code);
            2:
                ValidationResult := AdvancedValidator.ValidateCode(Code, BusinessCtx, TechnicalCtx);
            3:
                ValidationResult := ExpertValidator.ValidateCode(Code, BusinessCtx, TechnicalCtx);
        end;

        exit(ValidationResult);
    end;

    local procedure GenerateContextualRecommendations(var ValidationResult: Record "Validation Result"; BusinessCtx: Text; TechnicalCtx: Text)
    var
        Recommendations: List of [Text];
    begin
        // Generate business context recommendations
        if StrPos(BusinessCtx, 'financial') > 0 then
            Recommendations.Add('Ensure proper audit trail implementation');
            
        if StrPos(BusinessCtx, 'customer') > 0 then
            Recommendations.Add('Validate customer data privacy compliance');
            
        // Generate technical context recommendations
        if StrPos(TechnicalCtx, 'integration') > 0 then
            Recommendations.Add('Test integration error scenarios thoroughly');
            
        if StrPos(TechnicalCtx, 'performance') > 0 then
            Recommendations.Add('Include performance testing in validation');

        // Store recommendations
        ValidationResult."Contextual Recommendations" := JoinRecommendations(Recommendations);
        ValidationResult.Modify(true);
    end;

    local procedure JoinRecommendations(Recommendations: List of [Text]): Text
    var
        RecommendationText: TextBuilder;
        Recommendation: Text;
    begin
        foreach Recommendation in Recommendations do begin
            if RecommendationText.Length > 0 then
                RecommendationText.Append(' | ');
            RecommendationText.Append(Recommendation);
        end;
        
        exit(RecommendationText.ToText());
    end;

    local procedure GetNextLogEntry(): Integer
    var
        SelfAwarenessLog: Record "AI Self-Awareness Log";
    begin
        SelfAwarenessLog.SetCurrentKey("Entry No.");
        if SelfAwarenessLog.FindLast() then
            exit(SelfAwarenessLog."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure GetNextOptimizationEntry(): Integer
    var
        OptimizationPattern: Record "Prompt Optimization Pattern";
    begin
        OptimizationPattern.SetCurrentKey("Entry No.");
        if OptimizationPattern.FindLast() then
            exit(OptimizationPattern."Entry No." + 1)
        else
            exit(1);
    end;

    local procedure MaxValue(Value1: Integer; Value2: Integer): Integer
    begin
        if Value1 > Value2 then
            exit(Value1)
        else
            exit(Value2);
    end;
}
```
