---
title: "Microsoft Entra Integration Patterns - Samples"
description: "Working AL code samples for Microsoft Entra ID integration with OAuth authentication and Graph API access"
area: "security"
difficulty: "advanced"
object_types: ["Codeunit", "Page", "Table", "Interface"]
variable_types: ["Text", "Boolean", "Guid", "JsonObject", "HttpClient", "HttpHeaders", "HttpContent", "HttpResponseMessage"]
tags: ["authentication", "entra-id", "oauth", "security", "integration", "azure-ad", "samples"]
---

# Microsoft Entra Integration Patterns - Samples

## OAuth 2.0 Token Manager Implementation

```al
codeunit 50100 "OAuth Token Manager" implements ITokenManager
{
    var
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpContent: HttpContent;
        HttpResponse: HttpResponseMessage;

    procedure GetAccessToken(ResourceUrl: Text): Text
    var
        AuthUrl: Text;
        ClientId: Text;
        ClientSecret: Text;
        TokenResponse: JsonObject;
        AccessToken: Text;
    begin
        ClientId := GetClientId();
        ClientSecret := GetClientSecret();
        AuthUrl := 'https://login.microsoftonline.com/' + GetTenantId() + '/oauth2/v2.0/token';

        Clear(HttpContent);
        HttpContent.WriteFrom(BuildTokenRequestBody(ResourceUrl, ClientId, ClientSecret));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        if HttpClient.Post(AuthUrl, HttpContent, HttpResponse) then
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(AccessToken);
                TokenResponse.ReadFrom(AccessToken);
                exit(GetJsonToken(TokenResponse, 'access_token').AsValue().AsText());
            end else
                Error('Failed to obtain access token. Status: %1', HttpResponse.HttpStatusCode);

        Error('Authentication request failed');
    end;

    procedure RefreshToken(RefreshToken: Text): Text
    var
        AuthUrl: Text;
        TokenResponse: JsonObject;
        NewAccessToken: Text;
    begin
        AuthUrl := 'https://login.microsoftonline.com/' + GetTenantId() + '/oauth2/v2.0/token';

        Clear(HttpContent);
        HttpContent.WriteFrom(BuildRefreshTokenRequestBody(RefreshToken));
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        if HttpClient.Post(AuthUrl, HttpContent, HttpResponse) then
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(NewAccessToken);
                TokenResponse.ReadFrom(NewAccessToken);
                exit(GetJsonToken(TokenResponse, 'access_token').AsValue().AsText());
            end;

        Error('Failed to refresh access token');
    end;

    procedure ValidateToken(AccessToken: Text): Boolean
    var
        ValidationUrl: Text;
        ValidationResponse: Text;
        ValidationObject: JsonObject;
    begin
        ValidationUrl := 'https://graph.microsoft.com/v1.0/me';

        Clear(HttpClient);
        HttpClient.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if HttpClient.Get(ValidationUrl, HttpResponse) then
            exit(HttpResponse.IsSuccessStatusCode);

        exit(false);
    end;

    procedure RevokeToken(AccessToken: Text)
    var
        RevokeUrl: Text;
    begin
        RevokeUrl := 'https://login.microsoftonline.com/' + GetTenantId() + '/oauth2/v2.0/logout';
        
        Clear(HttpContent);
        HttpContent.WriteFrom('token=' + AccessToken);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Remove('Content-Type');
        HttpHeaders.Add('Content-Type', 'application/x-www-form-urlencoded');

        HttpClient.Post(RevokeUrl, HttpContent, HttpResponse);
    end;

    local procedure BuildTokenRequestBody(ResourceUrl: Text; ClientId: Text; ClientSecret: Text): Text
    begin
        exit('grant_type=client_credentials' +
             '&client_id=' + ClientId +
             '&client_secret=' + ClientSecret +
             '&scope=' + ResourceUrl + '/.default');
    end;

    local procedure BuildRefreshTokenRequestBody(RefreshToken: Text): Text
    begin
        exit('grant_type=refresh_token' +
             '&refresh_token=' + RefreshToken +
             '&client_id=' + GetClientId() +
             '&client_secret=' + GetClientSecret());
    end;

    local procedure GetClientId(): Text
    var
        EntraConfig: Record "Entra Auth Configuration";
    begin
        EntraConfig.Get();
        exit(EntraConfig."Client ID");
    end;

    local procedure GetClientSecret(): Text
    var
        EntraConfig: Record "Entra Auth Configuration";
    begin
        EntraConfig.Get();
        exit(EntraConfig."Client Secret");
    end;

    local procedure GetTenantId(): Text
    var
        EntraConfig: Record "Entra Auth Configuration";
    begin
        EntraConfig.Get();
        exit(EntraConfig."Tenant ID");
    end;

    local procedure GetJsonToken(JObject: JsonObject; TokenName: Text): JsonToken
    var
        JToken: JsonToken;
    begin
        if JObject.Get(TokenName, JToken) then
            exit(JToken);
        
        Error('Token %1 not found in response', TokenName);
    end;
}
```

## Entra Security Context Provider

```al
codeunit 50101 "Entra Security Context"
{
    var
        TokenManager: Codeunit "OAuth Token Manager";
        HttpClient: HttpClient;
        HttpHeaders: HttpHeaders;
        HttpResponse: HttpResponseMessage;

    procedure GetUserClaims(): JsonObject
    var
        AccessToken: Text;
        GraphUrl: Text;
        UserResponse: Text;
        UserClaims: JsonObject;
    begin
        AccessToken := TokenManager.GetAccessToken('https://graph.microsoft.com');
        GraphUrl := 'https://graph.microsoft.com/v1.0/me';

        Clear(HttpClient);
        HttpClient.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if HttpClient.Get(GraphUrl, HttpResponse) then
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(UserResponse);
                UserClaims.ReadFrom(UserResponse);
                exit(UserClaims);
            end;

        Error('Failed to retrieve user claims');
    end;

    procedure ValidateUserPermissions(RequiredRoles: List of [Text]): Boolean
    var
        UserGroups: List of [Text];
        RequiredRole: Text;
    begin
        UserGroups := GetGroupMemberships();

        foreach RequiredRole in RequiredRoles do
            if not UserGroups.Contains(RequiredRole) then
                exit(false);

        exit(true);
    end;

    procedure GetGroupMemberships(): List of [Text]
    var
        AccessToken: Text;
        GraphUrl: Text;
        GroupResponse: Text;
        GroupsObject: JsonObject;
        GroupsArray: JsonArray;
        GroupToken: JsonToken;
        GroupObject: JsonObject;
        GroupNames: List of [Text];
        i: Integer;
    begin
        AccessToken := TokenManager.GetAccessToken('https://graph.microsoft.com');
        GraphUrl := 'https://graph.microsoft.com/v1.0/me/memberOf';

        Clear(HttpClient);
        HttpClient.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if HttpClient.Get(GraphUrl, HttpResponse) then
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(GroupResponse);
                GroupsObject.ReadFrom(GroupResponse);
                
                if GroupsObject.Get('value', GroupToken) then begin
                    GroupsArray := GroupToken.AsArray();
                    for i := 0 to GroupsArray.Count - 1 do begin
                        GroupsArray.Get(i, GroupToken);
                        GroupObject := GroupToken.AsObject();
                        if GroupObject.Get('displayName', GroupToken) then
                            GroupNames.Add(GroupToken.AsValue().AsText());
                    end;
                end;
            end;

        exit(GroupNames);
    end;
}
```

## Conditional Access Policy Validator

```al
codeunit 50102 "Conditional Access Validator"
{
    procedure ValidateDeviceCompliance(UserId: Text): Boolean
    var
        AccessToken: Text;
        GraphUrl: Text;
        DeviceResponse: Text;
        DeviceObject: JsonObject;
        ComplianceToken: JsonToken;
        TokenManager: Codeunit "OAuth Token Manager";
        HttpClient: HttpClient;
        HttpResponse: HttpResponseMessage;
    begin
        AccessToken := TokenManager.GetAccessToken('https://graph.microsoft.com');
        GraphUrl := 'https://graph.microsoft.com/v1.0/users/' + UserId + '/managedDevices';

        Clear(HttpClient);
        HttpClient.DefaultRequestHeaders.Add('Authorization', 'Bearer ' + AccessToken);

        if HttpClient.Get(GraphUrl, HttpResponse) then
            if HttpResponse.IsSuccessStatusCode then begin
                HttpResponse.Content.ReadAs(DeviceResponse);
                DeviceObject.ReadFrom(DeviceResponse);
                
                // Check device compliance status
                if DeviceObject.Get('complianceState', ComplianceToken) then
                    exit(ComplianceToken.AsValue().AsText() = 'compliant');
            end;

        exit(false); // Default to not compliant if unable to verify
    end;

    procedure ValidateLocationAccess(UserLocation: Text; AllowedLocations: List of [Text]): Boolean
    begin
        // Implement location-based validation logic
        exit(AllowedLocations.Contains(UserLocation));
    end;

    procedure RequiresMFA(UserId: Text): Boolean
    var
        UserRisk: Text;
        SecurityContext: Codeunit "Entra Security Context";
        UserClaims: JsonObject;
        RiskToken: JsonToken;
    begin
        UserClaims := SecurityContext.GetUserClaims();
        
        if UserClaims.Get('userRiskLevel', RiskToken) then begin
            UserRisk := RiskToken.AsValue().AsText();
            exit(UserRisk in ['medium', 'high']);
        end;

        exit(true); // Default to requiring MFA
    end;
}
```

## Authentication Configuration Table

```al
table 50100 "Entra Auth Configuration"
{
    DataClassification = SystemMetadata;
    Caption = 'Entra Auth Configuration';
    
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(2; "Tenant ID"; Text[100])
        {
            Caption = 'Tenant ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(3; "Client ID"; Text[100])
        {
            Caption = 'Client ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(4; "Client Secret"; Text[250])
        {
            Caption = 'Client Secret';
            DataClassification = EndUserPseudonymousIdentifiers;
            ExtendedDatatype = Masked;
        }
        field(5; "Authority URL"; Text[250])
        {
            Caption = 'Authority URL';
            DataClassification = SystemMetadata;
            InitValue = 'https://login.microsoftonline.com/';
        }
        field(6; "Graph API URL"; Text[250])
        {
            Caption = 'Graph API URL';
            DataClassification = SystemMetadata;
            InitValue = 'https://graph.microsoft.com/';
        }
        field(7; "Token Cache Enabled"; Boolean)
        {
            Caption = 'Token Cache Enabled';
            DataClassification = SystemMetadata;
            InitValue = true;
        }
        field(8; "Cache Expiry Minutes"; Integer)
        {
            Caption = 'Cache Expiry Minutes';
            DataClassification = SystemMetadata;
            InitValue = 55; // Default to 55 minutes (tokens usually expire in 60)
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
```

## Secure Page Extension with Entra Integration

```al
pageextension 50100 "Customer List Entra Auth" extends "Customer List"
{
    trigger OnOpenPage()
    var
        SecurityContext: Codeunit "Entra Security Context";
        RequiredRoles: List of [Text];
    begin
        // Validate user has required permissions
        RequiredRoles.Add('Customer_Read');
        RequiredRoles.Add('Sales_User');

        if not SecurityContext.ValidateUserPermissions(RequiredRoles) then
            Error('Insufficient permissions to access customer data');

        // Log access attempt
        LogSecurityEvent('Customer List Accessed', UserSecurityId());
    end;

    local procedure LogSecurityEvent(EventType: Text; UserId: Guid)
    var
        SecurityLog: Record "Security Log Entry";
    begin
        if not SecurityLog.WritePermission then
            exit;

        SecurityLog.Init();
        SecurityLog."Entry No." := GetNextEntryNo();
        SecurityLog."Event Type" := EventType;
        SecurityLog."User ID" := UserId;
        SecurityLog."Event DateTime" := CurrentDateTime;
        SecurityLog."Additional Info" := 'Entra ID authenticated access';
        SecurityLog.Insert();
    end;

    local procedure GetNextEntryNo(): Integer
    var
        SecurityLog: Record "Security Log Entry";
    begin
        if SecurityLog.FindLast() then
            exit(SecurityLog."Entry No." + 1);
        exit(1);
    end;
}
```

## Security Log Entry Table

```al
table 50101 "Security Log Entry"
{
    DataClassification = CustomerContent;
    Caption = 'Security Log Entry';
    
    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
            AutoIncrement = true;
        }
        field(2; "Event Type"; Text[50])
        {
            Caption = 'Event Type';
            DataClassification = CustomerContent;
        }
        field(3; "User ID"; Guid)
        {
            Caption = 'User ID';
            DataClassification = EndUserPseudonymousIdentifiers;
        }
        field(4; "Event DateTime"; DateTime)
        {
            Caption = 'Event Date/Time';
            DataClassification = CustomerContent;
        }
        field(5; "Additional Info"; Text[250])
        {
            Caption = 'Additional Information';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(DateTime; "Event DateTime")
        {
        }
    }
}
```