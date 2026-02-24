// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'courier_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CollectionResponse _$CollectionResponseFromJson(Map<String, dynamic> json) =>
    CollectionResponse(
      id: json['id'] as String?,
      teamId: json['teamId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      preRequestScript: json['preRequestScript'] as String?,
      postResponseScript: json['postResponseScript'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      authConfig: json['authConfig'] as String?,
      isShared: json['isShared'] as bool?,
      createdBy: json['createdBy'] as String?,
      folderCount: (json['folderCount'] as num?)?.toInt(),
      requestCount: (json['requestCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CollectionResponseToJson(CollectionResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'description': instance.description,
      'preRequestScript': instance.preRequestScript,
      'postResponseScript': instance.postResponseScript,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'authConfig': instance.authConfig,
      'isShared': instance.isShared,
      'createdBy': instance.createdBy,
      'folderCount': instance.folderCount,
      'requestCount': instance.requestCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) =>
    json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) =>
    value == null ? null : toJson(value);

CollectionSummaryResponse _$CollectionSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    CollectionSummaryResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isShared: json['isShared'] as bool?,
      folderCount: (json['folderCount'] as num?)?.toInt(),
      requestCount: (json['requestCount'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$CollectionSummaryResponseToJson(
        CollectionSummaryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'isShared': instance.isShared,
      'folderCount': instance.folderCount,
      'requestCount': instance.requestCount,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreateCollectionRequest _$CreateCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    CreateCollectionRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      authConfig: json['authConfig'] as String?,
    );

Map<String, dynamic> _$CreateCollectionRequestToJson(
        CreateCollectionRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'authConfig': instance.authConfig,
    };

UpdateCollectionRequest _$UpdateCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateCollectionRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      preRequestScript: json['preRequestScript'] as String?,
      postResponseScript: json['postResponseScript'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      authConfig: json['authConfig'] as String?,
    );

Map<String, dynamic> _$UpdateCollectionRequestToJson(
        UpdateCollectionRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'preRequestScript': instance.preRequestScript,
      'postResponseScript': instance.postResponseScript,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'authConfig': instance.authConfig,
    };

FolderResponse _$FolderResponseFromJson(Map<String, dynamic> json) =>
    FolderResponse(
      id: json['id'] as String?,
      collectionId: json['collectionId'] as String?,
      parentFolderId: json['parentFolderId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      preRequestScript: json['preRequestScript'] as String?,
      postResponseScript: json['postResponseScript'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      authConfig: json['authConfig'] as String?,
      subFolderCount: (json['subFolderCount'] as num?)?.toInt(),
      requestCount: (json['requestCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$FolderResponseToJson(FolderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'parentFolderId': instance.parentFolderId,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'preRequestScript': instance.preRequestScript,
      'postResponseScript': instance.postResponseScript,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'authConfig': instance.authConfig,
      'subFolderCount': instance.subFolderCount,
      'requestCount': instance.requestCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

FolderTreeResponse _$FolderTreeResponseFromJson(Map<String, dynamic> json) =>
    FolderTreeResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      subFolders: (json['subFolders'] as List<dynamic>?)
          ?.map((e) => FolderTreeResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      requests: (json['requests'] as List<dynamic>?)
          ?.map(
              (e) => RequestSummaryResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$FolderTreeResponseToJson(FolderTreeResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sortOrder': instance.sortOrder,
      'subFolders': instance.subFolders?.map((e) => e.toJson()).toList(),
      'requests': instance.requests?.map((e) => e.toJson()).toList(),
    };

CreateFolderRequest _$CreateFolderRequestFromJson(Map<String, dynamic> json) =>
    CreateFolderRequest(
      collectionId: json['collectionId'] as String,
      parentFolderId: json['parentFolderId'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateFolderRequestToJson(
        CreateFolderRequest instance) =>
    <String, dynamic>{
      'collectionId': instance.collectionId,
      'parentFolderId': instance.parentFolderId,
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
    };

UpdateFolderRequest _$UpdateFolderRequestFromJson(Map<String, dynamic> json) =>
    UpdateFolderRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      parentFolderId: json['parentFolderId'] as String?,
      preRequestScript: json['preRequestScript'] as String?,
      postResponseScript: json['postResponseScript'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      authConfig: json['authConfig'] as String?,
    );

Map<String, dynamic> _$UpdateFolderRequestToJson(
        UpdateFolderRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'sortOrder': instance.sortOrder,
      'parentFolderId': instance.parentFolderId,
      'preRequestScript': instance.preRequestScript,
      'postResponseScript': instance.postResponseScript,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'authConfig': instance.authConfig,
    };

ReorderFolderRequest _$ReorderFolderRequestFromJson(
        Map<String, dynamic> json) =>
    ReorderFolderRequest(
      folderIds:
          (json['folderIds'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ReorderFolderRequestToJson(
        ReorderFolderRequest instance) =>
    <String, dynamic>{
      'folderIds': instance.folderIds,
    };

RequestResponse _$RequestResponseFromJson(Map<String, dynamic> json) =>
    RequestResponse(
      id: json['id'] as String?,
      folderId: json['folderId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      method: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['method'], const CourierHttpMethodConverter().fromJson),
      url: json['url'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
      headers: (json['headers'] as List<dynamic>?)
          ?.map(
              (e) => RequestHeaderResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      params: (json['params'] as List<dynamic>?)
          ?.map((e) => RequestParamResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      body: json['body'] == null
          ? null
          : RequestBodyResponse.fromJson(json['body'] as Map<String, dynamic>),
      auth: json['auth'] == null
          ? null
          : RequestAuthResponse.fromJson(json['auth'] as Map<String, dynamic>),
      scripts: (json['scripts'] as List<dynamic>?)
          ?.map(
              (e) => RequestScriptResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$RequestResponseToJson(RequestResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'folderId': instance.folderId,
      'name': instance.name,
      'description': instance.description,
      'method': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.method, const CourierHttpMethodConverter().toJson),
      'url': instance.url,
      'sortOrder': instance.sortOrder,
      'headers': instance.headers?.map((e) => e.toJson()).toList(),
      'params': instance.params?.map((e) => e.toJson()).toList(),
      'body': instance.body?.toJson(),
      'auth': instance.auth?.toJson(),
      'scripts': instance.scripts?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

RequestSummaryResponse _$RequestSummaryResponseFromJson(
        Map<String, dynamic> json) =>
    RequestSummaryResponse(
      id: json['id'] as String?,
      name: json['name'] as String?,
      method: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['method'], const CourierHttpMethodConverter().fromJson),
      url: json['url'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$RequestSummaryResponseToJson(
        RequestSummaryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'method': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.method, const CourierHttpMethodConverter().toJson),
      'url': instance.url,
      'sortOrder': instance.sortOrder,
    };

RequestHeaderResponse _$RequestHeaderResponseFromJson(
        Map<String, dynamic> json) =>
    RequestHeaderResponse(
      id: json['id'] as String?,
      headerKey: json['headerKey'] as String?,
      headerValue: json['headerValue'] as String?,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$RequestHeaderResponseToJson(
        RequestHeaderResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'headerKey': instance.headerKey,
      'headerValue': instance.headerValue,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
    };

RequestParamResponse _$RequestParamResponseFromJson(
        Map<String, dynamic> json) =>
    RequestParamResponse(
      id: json['id'] as String?,
      paramKey: json['paramKey'] as String?,
      paramValue: json['paramValue'] as String?,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$RequestParamResponseToJson(
        RequestParamResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'paramKey': instance.paramKey,
      'paramValue': instance.paramValue,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
    };

RequestBodyResponse _$RequestBodyResponseFromJson(Map<String, dynamic> json) =>
    RequestBodyResponse(
      id: json['id'] as String?,
      bodyType: _$JsonConverterFromJson<String, BodyType>(
          json['bodyType'], const BodyTypeConverter().fromJson),
      rawContent: json['rawContent'] as String?,
      formData: json['formData'] as String?,
      graphqlQuery: json['graphqlQuery'] as String?,
      graphqlVariables: json['graphqlVariables'] as String?,
      binaryFileName: json['binaryFileName'] as String?,
    );

Map<String, dynamic> _$RequestBodyResponseToJson(
        RequestBodyResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bodyType': _$JsonConverterToJson<String, BodyType>(
          instance.bodyType, const BodyTypeConverter().toJson),
      'rawContent': instance.rawContent,
      'formData': instance.formData,
      'graphqlQuery': instance.graphqlQuery,
      'graphqlVariables': instance.graphqlVariables,
      'binaryFileName': instance.binaryFileName,
    };

RequestAuthResponse _$RequestAuthResponseFromJson(Map<String, dynamic> json) =>
    RequestAuthResponse(
      id: json['id'] as String?,
      authType: _$JsonConverterFromJson<String, AuthType>(
          json['authType'], const AuthTypeConverter().fromJson),
      apiKeyHeader: json['apiKeyHeader'] as String?,
      apiKeyValue: json['apiKeyValue'] as String?,
      apiKeyAddTo: json['apiKeyAddTo'] as String?,
      bearerToken: json['bearerToken'] as String?,
      basicUsername: json['basicUsername'] as String?,
      basicPassword: json['basicPassword'] as String?,
      oauth2GrantType: json['oauth2GrantType'] as String?,
      oauth2AuthUrl: json['oauth2AuthUrl'] as String?,
      oauth2TokenUrl: json['oauth2TokenUrl'] as String?,
      oauth2ClientId: json['oauth2ClientId'] as String?,
      oauth2ClientSecret: json['oauth2ClientSecret'] as String?,
      oauth2Scope: json['oauth2Scope'] as String?,
      oauth2CallbackUrl: json['oauth2CallbackUrl'] as String?,
      oauth2AccessToken: json['oauth2AccessToken'] as String?,
      jwtSecret: json['jwtSecret'] as String?,
      jwtPayload: json['jwtPayload'] as String?,
      jwtAlgorithm: json['jwtAlgorithm'] as String?,
    );

Map<String, dynamic> _$RequestAuthResponseToJson(
        RequestAuthResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'authType': _$JsonConverterToJson<String, AuthType>(
          instance.authType, const AuthTypeConverter().toJson),
      'apiKeyHeader': instance.apiKeyHeader,
      'apiKeyValue': instance.apiKeyValue,
      'apiKeyAddTo': instance.apiKeyAddTo,
      'bearerToken': instance.bearerToken,
      'basicUsername': instance.basicUsername,
      'basicPassword': instance.basicPassword,
      'oauth2GrantType': instance.oauth2GrantType,
      'oauth2AuthUrl': instance.oauth2AuthUrl,
      'oauth2TokenUrl': instance.oauth2TokenUrl,
      'oauth2ClientId': instance.oauth2ClientId,
      'oauth2ClientSecret': instance.oauth2ClientSecret,
      'oauth2Scope': instance.oauth2Scope,
      'oauth2CallbackUrl': instance.oauth2CallbackUrl,
      'oauth2AccessToken': instance.oauth2AccessToken,
      'jwtSecret': instance.jwtSecret,
      'jwtPayload': instance.jwtPayload,
      'jwtAlgorithm': instance.jwtAlgorithm,
    };

RequestScriptResponse _$RequestScriptResponseFromJson(
        Map<String, dynamic> json) =>
    RequestScriptResponse(
      id: json['id'] as String?,
      scriptType: _$JsonConverterFromJson<String, ScriptType>(
          json['scriptType'], const ScriptTypeConverter().fromJson),
      content: json['content'] as String?,
    );

Map<String, dynamic> _$RequestScriptResponseToJson(
        RequestScriptResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'scriptType': _$JsonConverterToJson<String, ScriptType>(
          instance.scriptType, const ScriptTypeConverter().toJson),
      'content': instance.content,
    };

CreateRequestRequest _$CreateRequestRequestFromJson(
        Map<String, dynamic> json) =>
    CreateRequestRequest(
      folderId: json['folderId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      method:
          const CourierHttpMethodConverter().fromJson(json['method'] as String),
      url: json['url'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$CreateRequestRequestToJson(
        CreateRequestRequest instance) =>
    <String, dynamic>{
      'folderId': instance.folderId,
      'name': instance.name,
      'description': instance.description,
      'method': const CourierHttpMethodConverter().toJson(instance.method),
      'url': instance.url,
      'sortOrder': instance.sortOrder,
    };

UpdateRequestRequest _$UpdateRequestRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateRequestRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
      method: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['method'], const CourierHttpMethodConverter().fromJson),
      url: json['url'] as String?,
      sortOrder: (json['sortOrder'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UpdateRequestRequestToJson(
        UpdateRequestRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
      'method': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.method, const CourierHttpMethodConverter().toJson),
      'url': instance.url,
      'sortOrder': instance.sortOrder,
    };

SaveRequestHeadersRequest _$SaveRequestHeadersRequestFromJson(
        Map<String, dynamic> json) =>
    SaveRequestHeadersRequest(
      headers: (json['headers'] as List<dynamic>)
          .map((e) => RequestHeaderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaveRequestHeadersRequestToJson(
        SaveRequestHeadersRequest instance) =>
    <String, dynamic>{
      'headers': instance.headers.map((e) => e.toJson()).toList(),
    };

RequestHeaderEntry _$RequestHeaderEntryFromJson(Map<String, dynamic> json) =>
    RequestHeaderEntry(
      headerKey: json['headerKey'] as String,
      headerValue: json['headerValue'] as String?,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$RequestHeaderEntryToJson(RequestHeaderEntry instance) =>
    <String, dynamic>{
      'headerKey': instance.headerKey,
      'headerValue': instance.headerValue,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
    };

SaveRequestParamsRequest _$SaveRequestParamsRequestFromJson(
        Map<String, dynamic> json) =>
    SaveRequestParamsRequest(
      params: (json['params'] as List<dynamic>)
          .map((e) => RequestParamEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaveRequestParamsRequestToJson(
        SaveRequestParamsRequest instance) =>
    <String, dynamic>{
      'params': instance.params.map((e) => e.toJson()).toList(),
    };

RequestParamEntry _$RequestParamEntryFromJson(Map<String, dynamic> json) =>
    RequestParamEntry(
      paramKey: json['paramKey'] as String,
      paramValue: json['paramValue'] as String?,
      description: json['description'] as String?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$RequestParamEntryToJson(RequestParamEntry instance) =>
    <String, dynamic>{
      'paramKey': instance.paramKey,
      'paramValue': instance.paramValue,
      'description': instance.description,
      'isEnabled': instance.isEnabled,
    };

SaveRequestBodyRequest _$SaveRequestBodyRequestFromJson(
        Map<String, dynamic> json) =>
    SaveRequestBodyRequest(
      bodyType: const BodyTypeConverter().fromJson(json['bodyType'] as String),
      rawContent: json['rawContent'] as String?,
      formData: json['formData'] as String?,
      graphqlQuery: json['graphqlQuery'] as String?,
      graphqlVariables: json['graphqlVariables'] as String?,
      binaryFileName: json['binaryFileName'] as String?,
    );

Map<String, dynamic> _$SaveRequestBodyRequestToJson(
        SaveRequestBodyRequest instance) =>
    <String, dynamic>{
      'bodyType': const BodyTypeConverter().toJson(instance.bodyType),
      'rawContent': instance.rawContent,
      'formData': instance.formData,
      'graphqlQuery': instance.graphqlQuery,
      'graphqlVariables': instance.graphqlVariables,
      'binaryFileName': instance.binaryFileName,
    };

SaveRequestAuthRequest _$SaveRequestAuthRequestFromJson(
        Map<String, dynamic> json) =>
    SaveRequestAuthRequest(
      authType: const AuthTypeConverter().fromJson(json['authType'] as String),
      apiKeyHeader: json['apiKeyHeader'] as String?,
      apiKeyValue: json['apiKeyValue'] as String?,
      apiKeyAddTo: json['apiKeyAddTo'] as String?,
      bearerToken: json['bearerToken'] as String?,
      basicUsername: json['basicUsername'] as String?,
      basicPassword: json['basicPassword'] as String?,
      oauth2GrantType: json['oauth2GrantType'] as String?,
      oauth2AuthUrl: json['oauth2AuthUrl'] as String?,
      oauth2TokenUrl: json['oauth2TokenUrl'] as String?,
      oauth2ClientId: json['oauth2ClientId'] as String?,
      oauth2ClientSecret: json['oauth2ClientSecret'] as String?,
      oauth2Scope: json['oauth2Scope'] as String?,
      oauth2CallbackUrl: json['oauth2CallbackUrl'] as String?,
      oauth2AccessToken: json['oauth2AccessToken'] as String?,
      jwtSecret: json['jwtSecret'] as String?,
      jwtPayload: json['jwtPayload'] as String?,
      jwtAlgorithm: json['jwtAlgorithm'] as String?,
    );

Map<String, dynamic> _$SaveRequestAuthRequestToJson(
        SaveRequestAuthRequest instance) =>
    <String, dynamic>{
      'authType': const AuthTypeConverter().toJson(instance.authType),
      'apiKeyHeader': instance.apiKeyHeader,
      'apiKeyValue': instance.apiKeyValue,
      'apiKeyAddTo': instance.apiKeyAddTo,
      'bearerToken': instance.bearerToken,
      'basicUsername': instance.basicUsername,
      'basicPassword': instance.basicPassword,
      'oauth2GrantType': instance.oauth2GrantType,
      'oauth2AuthUrl': instance.oauth2AuthUrl,
      'oauth2TokenUrl': instance.oauth2TokenUrl,
      'oauth2ClientId': instance.oauth2ClientId,
      'oauth2ClientSecret': instance.oauth2ClientSecret,
      'oauth2Scope': instance.oauth2Scope,
      'oauth2CallbackUrl': instance.oauth2CallbackUrl,
      'oauth2AccessToken': instance.oauth2AccessToken,
      'jwtSecret': instance.jwtSecret,
      'jwtPayload': instance.jwtPayload,
      'jwtAlgorithm': instance.jwtAlgorithm,
    };

SaveRequestScriptRequest _$SaveRequestScriptRequestFromJson(
        Map<String, dynamic> json) =>
    SaveRequestScriptRequest(
      scriptType:
          const ScriptTypeConverter().fromJson(json['scriptType'] as String),
      content: json['content'] as String?,
    );

Map<String, dynamic> _$SaveRequestScriptRequestToJson(
        SaveRequestScriptRequest instance) =>
    <String, dynamic>{
      'scriptType': const ScriptTypeConverter().toJson(instance.scriptType),
      'content': instance.content,
    };

ReorderRequestRequest _$ReorderRequestRequestFromJson(
        Map<String, dynamic> json) =>
    ReorderRequestRequest(
      requestIds: (json['requestIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ReorderRequestRequestToJson(
        ReorderRequestRequest instance) =>
    <String, dynamic>{
      'requestIds': instance.requestIds,
    };

DuplicateRequestRequest _$DuplicateRequestRequestFromJson(
        Map<String, dynamic> json) =>
    DuplicateRequestRequest(
      targetFolderId: json['targetFolderId'] as String?,
    );

Map<String, dynamic> _$DuplicateRequestRequestToJson(
        DuplicateRequestRequest instance) =>
    <String, dynamic>{
      'targetFolderId': instance.targetFolderId,
    };

EnvironmentResponse _$EnvironmentResponseFromJson(Map<String, dynamic> json) =>
    EnvironmentResponse(
      id: json['id'] as String?,
      teamId: json['teamId'] as String?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool?,
      createdBy: json['createdBy'] as String?,
      variableCount: (json['variableCount'] as num?)?.toInt(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$EnvironmentResponseToJson(
        EnvironmentResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'name': instance.name,
      'description': instance.description,
      'isActive': instance.isActive,
      'createdBy': instance.createdBy,
      'variableCount': instance.variableCount,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

EnvironmentVariableResponse _$EnvironmentVariableResponseFromJson(
        Map<String, dynamic> json) =>
    EnvironmentVariableResponse(
      id: json['id'] as String?,
      variableKey: json['variableKey'] as String?,
      variableValue: json['variableValue'] as String?,
      isSecret: json['isSecret'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      scope: json['scope'] as String?,
    );

Map<String, dynamic> _$EnvironmentVariableResponseToJson(
        EnvironmentVariableResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'variableKey': instance.variableKey,
      'variableValue': instance.variableValue,
      'isSecret': instance.isSecret,
      'isEnabled': instance.isEnabled,
      'scope': instance.scope,
    };

GlobalVariableResponse _$GlobalVariableResponseFromJson(
        Map<String, dynamic> json) =>
    GlobalVariableResponse(
      id: json['id'] as String?,
      teamId: json['teamId'] as String?,
      variableKey: json['variableKey'] as String?,
      variableValue: json['variableValue'] as String?,
      isSecret: json['isSecret'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$GlobalVariableResponseToJson(
        GlobalVariableResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'variableKey': instance.variableKey,
      'variableValue': instance.variableValue,
      'isSecret': instance.isSecret,
      'isEnabled': instance.isEnabled,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreateEnvironmentRequest _$CreateEnvironmentRequestFromJson(
        Map<String, dynamic> json) =>
    CreateEnvironmentRequest(
      name: json['name'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$CreateEnvironmentRequestToJson(
        CreateEnvironmentRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

UpdateEnvironmentRequest _$UpdateEnvironmentRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateEnvironmentRequest(
      name: json['name'] as String?,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$UpdateEnvironmentRequestToJson(
        UpdateEnvironmentRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

SaveEnvironmentVariablesRequest _$SaveEnvironmentVariablesRequestFromJson(
        Map<String, dynamic> json) =>
    SaveEnvironmentVariablesRequest(
      variables: (json['variables'] as List<dynamic>)
          .map((e) => VariableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SaveEnvironmentVariablesRequestToJson(
        SaveEnvironmentVariablesRequest instance) =>
    <String, dynamic>{
      'variables': instance.variables.map((e) => e.toJson()).toList(),
    };

VariableEntry _$VariableEntryFromJson(Map<String, dynamic> json) =>
    VariableEntry(
      variableKey: json['variableKey'] as String,
      variableValue: json['variableValue'] as String?,
      isSecret: json['isSecret'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$VariableEntryToJson(VariableEntry instance) =>
    <String, dynamic>{
      'variableKey': instance.variableKey,
      'variableValue': instance.variableValue,
      'isSecret': instance.isSecret,
      'isEnabled': instance.isEnabled,
    };

CloneEnvironmentRequest _$CloneEnvironmentRequestFromJson(
        Map<String, dynamic> json) =>
    CloneEnvironmentRequest(
      newName: json['newName'] as String,
    );

Map<String, dynamic> _$CloneEnvironmentRequestToJson(
        CloneEnvironmentRequest instance) =>
    <String, dynamic>{
      'newName': instance.newName,
    };

SaveGlobalVariableRequest _$SaveGlobalVariableRequestFromJson(
        Map<String, dynamic> json) =>
    SaveGlobalVariableRequest(
      variableKey: json['variableKey'] as String,
      variableValue: json['variableValue'] as String?,
      isSecret: json['isSecret'] as bool?,
      isEnabled: json['isEnabled'] as bool?,
    );

Map<String, dynamic> _$SaveGlobalVariableRequestToJson(
        SaveGlobalVariableRequest instance) =>
    <String, dynamic>{
      'variableKey': instance.variableKey,
      'variableValue': instance.variableValue,
      'isSecret': instance.isSecret,
      'isEnabled': instance.isEnabled,
    };

BatchSaveGlobalVariablesRequest _$BatchSaveGlobalVariablesRequestFromJson(
        Map<String, dynamic> json) =>
    BatchSaveGlobalVariablesRequest(
      variables: (json['variables'] as List<dynamic>)
          .map((e) =>
              SaveGlobalVariableRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$BatchSaveGlobalVariablesRequestToJson(
        BatchSaveGlobalVariablesRequest instance) =>
    <String, dynamic>{
      'variables': instance.variables.map((e) => e.toJson()).toList(),
    };

CollectionShareResponse _$CollectionShareResponseFromJson(
        Map<String, dynamic> json) =>
    CollectionShareResponse(
      id: json['id'] as String?,
      collectionId: json['collectionId'] as String?,
      sharedWithUserId: json['sharedWithUserId'] as String?,
      sharedByUserId: json['sharedByUserId'] as String?,
      permission: _$JsonConverterFromJson<String, SharePermission>(
          json['permission'], const SharePermissionConverter().fromJson),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$CollectionShareResponseToJson(
        CollectionShareResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'collectionId': instance.collectionId,
      'sharedWithUserId': instance.sharedWithUserId,
      'sharedByUserId': instance.sharedByUserId,
      'permission': _$JsonConverterToJson<String, SharePermission>(
          instance.permission, const SharePermissionConverter().toJson),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ShareCollectionRequest _$ShareCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    ShareCollectionRequest(
      sharedWithUserId: json['sharedWithUserId'] as String,
      permission: const SharePermissionConverter()
          .fromJson(json['permission'] as String),
    );

Map<String, dynamic> _$ShareCollectionRequestToJson(
        ShareCollectionRequest instance) =>
    <String, dynamic>{
      'sharedWithUserId': instance.sharedWithUserId,
      'permission':
          const SharePermissionConverter().toJson(instance.permission),
    };

UpdateSharePermissionRequest _$UpdateSharePermissionRequestFromJson(
        Map<String, dynamic> json) =>
    UpdateSharePermissionRequest(
      permission: const SharePermissionConverter()
          .fromJson(json['permission'] as String),
    );

Map<String, dynamic> _$UpdateSharePermissionRequestToJson(
        UpdateSharePermissionRequest instance) =>
    <String, dynamic>{
      'permission':
          const SharePermissionConverter().toJson(instance.permission),
    };

ForkResponse _$ForkResponseFromJson(Map<String, dynamic> json) => ForkResponse(
      id: json['id'] as String?,
      sourceCollectionId: json['sourceCollectionId'] as String?,
      sourceCollectionName: json['sourceCollectionName'] as String?,
      forkedCollectionId: json['forkedCollectionId'] as String?,
      forkedByUserId: json['forkedByUserId'] as String?,
      label: json['label'] as String?,
      forkedAt: json['forkedAt'] == null
          ? null
          : DateTime.parse(json['forkedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$ForkResponseToJson(ForkResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceCollectionId': instance.sourceCollectionId,
      'sourceCollectionName': instance.sourceCollectionName,
      'forkedCollectionId': instance.forkedCollectionId,
      'forkedByUserId': instance.forkedByUserId,
      'label': instance.label,
      'forkedAt': instance.forkedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
    };

CreateForkRequest _$CreateForkRequestFromJson(Map<String, dynamic> json) =>
    CreateForkRequest(
      label: json['label'] as String?,
    );

Map<String, dynamic> _$CreateForkRequestToJson(CreateForkRequest instance) =>
    <String, dynamic>{
      'label': instance.label,
    };

ProxyResponse _$ProxyResponseFromJson(Map<String, dynamic> json) =>
    ProxyResponse(
      statusCode: (json['statusCode'] as num?)?.toInt(),
      statusText: json['statusText'] as String?,
      responseHeaders: (json['responseHeaders'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      responseBody: json['responseBody'] as String?,
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt(),
      responseSizeBytes: (json['responseSizeBytes'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      redirectChain: (json['redirectChain'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      historyId: json['historyId'] as String?,
    );

Map<String, dynamic> _$ProxyResponseToJson(ProxyResponse instance) =>
    <String, dynamic>{
      'statusCode': instance.statusCode,
      'statusText': instance.statusText,
      'responseHeaders': instance.responseHeaders,
      'responseBody': instance.responseBody,
      'responseTimeMs': instance.responseTimeMs,
      'responseSizeBytes': instance.responseSizeBytes,
      'contentType': instance.contentType,
      'redirectChain': instance.redirectChain,
      'historyId': instance.historyId,
    };

SendRequestProxyRequest _$SendRequestProxyRequestFromJson(
        Map<String, dynamic> json) =>
    SendRequestProxyRequest(
      method:
          const CourierHttpMethodConverter().fromJson(json['method'] as String),
      url: json['url'] as String,
      headers: (json['headers'] as List<dynamic>?)
          ?.map((e) => RequestHeaderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      body: json['body'] == null
          ? null
          : SaveRequestBodyRequest.fromJson(
              json['body'] as Map<String, dynamic>),
      auth: json['auth'] == null
          ? null
          : SaveRequestAuthRequest.fromJson(
              json['auth'] as Map<String, dynamic>),
      environmentId: json['environmentId'] as String?,
      collectionId: json['collectionId'] as String?,
      saveToHistory: json['saveToHistory'] as bool?,
      timeoutMs: (json['timeoutMs'] as num?)?.toInt(),
      followRedirects: json['followRedirects'] as bool?,
    );

Map<String, dynamic> _$SendRequestProxyRequestToJson(
        SendRequestProxyRequest instance) =>
    <String, dynamic>{
      'method': const CourierHttpMethodConverter().toJson(instance.method),
      'url': instance.url,
      'headers': instance.headers?.map((e) => e.toJson()).toList(),
      'body': instance.body?.toJson(),
      'auth': instance.auth?.toJson(),
      'environmentId': instance.environmentId,
      'collectionId': instance.collectionId,
      'saveToHistory': instance.saveToHistory,
      'timeoutMs': instance.timeoutMs,
      'followRedirects': instance.followRedirects,
    };

GraphQLResponse _$GraphQLResponseFromJson(Map<String, dynamic> json) =>
    GraphQLResponse(
      httpResponse: json['httpResponse'] == null
          ? null
          : ProxyResponse.fromJson(
              json['httpResponse'] as Map<String, dynamic>),
      schema: json['schema'] as String?,
    );

Map<String, dynamic> _$GraphQLResponseToJson(GraphQLResponse instance) =>
    <String, dynamic>{
      'httpResponse': instance.httpResponse?.toJson(),
      'schema': instance.schema,
    };

ExecuteGraphQLRequest _$ExecuteGraphQLRequestFromJson(
        Map<String, dynamic> json) =>
    ExecuteGraphQLRequest(
      url: json['url'] as String,
      query: json['query'] as String,
      variables: json['variables'] as String?,
      operationName: json['operationName'] as String?,
      headers: (json['headers'] as List<dynamic>?)
          ?.map((e) => RequestHeaderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      auth: json['auth'] == null
          ? null
          : SaveRequestAuthRequest.fromJson(
              json['auth'] as Map<String, dynamic>),
      environmentId: json['environmentId'] as String?,
    );

Map<String, dynamic> _$ExecuteGraphQLRequestToJson(
        ExecuteGraphQLRequest instance) =>
    <String, dynamic>{
      'url': instance.url,
      'query': instance.query,
      'variables': instance.variables,
      'operationName': instance.operationName,
      'headers': instance.headers?.map((e) => e.toJson()).toList(),
      'auth': instance.auth?.toJson(),
      'environmentId': instance.environmentId,
    };

IntrospectGraphQLRequest _$IntrospectGraphQLRequestFromJson(
        Map<String, dynamic> json) =>
    IntrospectGraphQLRequest(
      url: json['url'] as String,
      headers: (json['headers'] as List<dynamic>?)
          ?.map((e) => RequestHeaderEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      auth: json['auth'] == null
          ? null
          : SaveRequestAuthRequest.fromJson(
              json['auth'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$IntrospectGraphQLRequestToJson(
        IntrospectGraphQLRequest instance) =>
    <String, dynamic>{
      'url': instance.url,
      'headers': instance.headers?.map((e) => e.toJson()).toList(),
      'auth': instance.auth?.toJson(),
    };

RunResultResponse _$RunResultResponseFromJson(Map<String, dynamic> json) =>
    RunResultResponse(
      id: json['id'] as String?,
      teamId: json['teamId'] as String?,
      collectionId: json['collectionId'] as String?,
      environmentId: json['environmentId'] as String?,
      status: _$JsonConverterFromJson<String, RunStatus>(
          json['status'], const RunStatusConverter().fromJson),
      totalRequests: (json['totalRequests'] as num?)?.toInt(),
      passedRequests: (json['passedRequests'] as num?)?.toInt(),
      failedRequests: (json['failedRequests'] as num?)?.toInt(),
      totalAssertions: (json['totalAssertions'] as num?)?.toInt(),
      passedAssertions: (json['passedAssertions'] as num?)?.toInt(),
      failedAssertions: (json['failedAssertions'] as num?)?.toInt(),
      totalDurationMs: (json['totalDurationMs'] as num?)?.toInt(),
      iterationCount: (json['iterationCount'] as num?)?.toInt(),
      delayBetweenRequestsMs: (json['delayBetweenRequestsMs'] as num?)?.toInt(),
      dataFilename: json['dataFilename'] as String?,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      startedByUserId: json['startedByUserId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RunResultResponseToJson(RunResultResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teamId': instance.teamId,
      'collectionId': instance.collectionId,
      'environmentId': instance.environmentId,
      'status': _$JsonConverterToJson<String, RunStatus>(
          instance.status, const RunStatusConverter().toJson),
      'totalRequests': instance.totalRequests,
      'passedRequests': instance.passedRequests,
      'failedRequests': instance.failedRequests,
      'totalAssertions': instance.totalAssertions,
      'passedAssertions': instance.passedAssertions,
      'failedAssertions': instance.failedAssertions,
      'totalDurationMs': instance.totalDurationMs,
      'iterationCount': instance.iterationCount,
      'delayBetweenRequestsMs': instance.delayBetweenRequestsMs,
      'dataFilename': instance.dataFilename,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'startedByUserId': instance.startedByUserId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

RunResultDetailResponse _$RunResultDetailResponseFromJson(
        Map<String, dynamic> json) =>
    RunResultDetailResponse(
      summary: json['summary'] == null
          ? null
          : RunResultResponse.fromJson(json['summary'] as Map<String, dynamic>),
      iterations: (json['iterations'] as List<dynamic>?)
          ?.map((e) => RunIterationResponse.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RunResultDetailResponseToJson(
        RunResultDetailResponse instance) =>
    <String, dynamic>{
      'summary': instance.summary?.toJson(),
      'iterations': instance.iterations?.map((e) => e.toJson()).toList(),
    };

RunIterationResponse _$RunIterationResponseFromJson(
        Map<String, dynamic> json) =>
    RunIterationResponse(
      id: json['id'] as String?,
      iterationNumber: (json['iterationNumber'] as num?)?.toInt(),
      requestName: json['requestName'] as String?,
      requestMethod: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['requestMethod'], const CourierHttpMethodConverter().fromJson),
      requestUrl: json['requestUrl'] as String?,
      responseStatus: (json['responseStatus'] as num?)?.toInt(),
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt(),
      responseSizeBytes: (json['responseSizeBytes'] as num?)?.toInt(),
      passed: json['passed'] as bool?,
      assertionResults: json['assertionResults'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$RunIterationResponseToJson(
        RunIterationResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'iterationNumber': instance.iterationNumber,
      'requestName': instance.requestName,
      'requestMethod': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.requestMethod, const CourierHttpMethodConverter().toJson),
      'requestUrl': instance.requestUrl,
      'responseStatus': instance.responseStatus,
      'responseTimeMs': instance.responseTimeMs,
      'responseSizeBytes': instance.responseSizeBytes,
      'passed': instance.passed,
      'assertionResults': instance.assertionResults,
      'errorMessage': instance.errorMessage,
    };

StartCollectionRunRequest _$StartCollectionRunRequestFromJson(
        Map<String, dynamic> json) =>
    StartCollectionRunRequest(
      collectionId: json['collectionId'] as String,
      environmentId: json['environmentId'] as String?,
      iterationCount: (json['iterationCount'] as num?)?.toInt(),
      delayBetweenRequestsMs: (json['delayBetweenRequestsMs'] as num?)?.toInt(),
      dataFilename: json['dataFilename'] as String?,
      dataContent: json['dataContent'] as String?,
    );

Map<String, dynamic> _$StartCollectionRunRequestToJson(
        StartCollectionRunRequest instance) =>
    <String, dynamic>{
      'collectionId': instance.collectionId,
      'environmentId': instance.environmentId,
      'iterationCount': instance.iterationCount,
      'delayBetweenRequestsMs': instance.delayBetweenRequestsMs,
      'dataFilename': instance.dataFilename,
      'dataContent': instance.dataContent,
    };

RequestHistoryResponse _$RequestHistoryResponseFromJson(
        Map<String, dynamic> json) =>
    RequestHistoryResponse(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      requestMethod: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['requestMethod'], const CourierHttpMethodConverter().fromJson),
      requestUrl: json['requestUrl'] as String?,
      responseStatus: (json['responseStatus'] as num?)?.toInt(),
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt(),
      responseSizeBytes: (json['responseSizeBytes'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      collectionId: json['collectionId'] as String?,
      requestId: json['requestId'] as String?,
      environmentId: json['environmentId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RequestHistoryResponseToJson(
        RequestHistoryResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'requestMethod': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.requestMethod, const CourierHttpMethodConverter().toJson),
      'requestUrl': instance.requestUrl,
      'responseStatus': instance.responseStatus,
      'responseTimeMs': instance.responseTimeMs,
      'responseSizeBytes': instance.responseSizeBytes,
      'contentType': instance.contentType,
      'collectionId': instance.collectionId,
      'requestId': instance.requestId,
      'environmentId': instance.environmentId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

RequestHistoryDetailResponse _$RequestHistoryDetailResponseFromJson(
        Map<String, dynamic> json) =>
    RequestHistoryDetailResponse(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      requestMethod: _$JsonConverterFromJson<String, CourierHttpMethod>(
          json['requestMethod'], const CourierHttpMethodConverter().fromJson),
      requestUrl: json['requestUrl'] as String?,
      requestHeaders: json['requestHeaders'] as String?,
      requestBody: json['requestBody'] as String?,
      responseStatus: (json['responseStatus'] as num?)?.toInt(),
      responseHeaders: json['responseHeaders'] as String?,
      responseBody: json['responseBody'] as String?,
      responseSizeBytes: (json['responseSizeBytes'] as num?)?.toInt(),
      responseTimeMs: (json['responseTimeMs'] as num?)?.toInt(),
      contentType: json['contentType'] as String?,
      collectionId: json['collectionId'] as String?,
      requestId: json['requestId'] as String?,
      environmentId: json['environmentId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$RequestHistoryDetailResponseToJson(
        RequestHistoryDetailResponse instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'requestMethod': _$JsonConverterToJson<String, CourierHttpMethod>(
          instance.requestMethod, const CourierHttpMethodConverter().toJson),
      'requestUrl': instance.requestUrl,
      'requestHeaders': instance.requestHeaders,
      'requestBody': instance.requestBody,
      'responseStatus': instance.responseStatus,
      'responseHeaders': instance.responseHeaders,
      'responseBody': instance.responseBody,
      'responseSizeBytes': instance.responseSizeBytes,
      'responseTimeMs': instance.responseTimeMs,
      'contentType': instance.contentType,
      'collectionId': instance.collectionId,
      'requestId': instance.requestId,
      'environmentId': instance.environmentId,
      'createdAt': instance.createdAt?.toIso8601String(),
    };

ImportCollectionRequest _$ImportCollectionRequestFromJson(
        Map<String, dynamic> json) =>
    ImportCollectionRequest(
      format: json['format'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ImportCollectionRequestToJson(
        ImportCollectionRequest instance) =>
    <String, dynamic>{
      'format': instance.format,
      'content': instance.content,
    };

ImportResultResponse _$ImportResultResponseFromJson(
        Map<String, dynamic> json) =>
    ImportResultResponse(
      collectionId: json['collectionId'] as String?,
      collectionName: json['collectionName'] as String?,
      foldersImported: (json['foldersImported'] as num?)?.toInt(),
      requestsImported: (json['requestsImported'] as num?)?.toInt(),
      environmentsImported: (json['environmentsImported'] as num?)?.toInt(),
      warnings: (json['warnings'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$ImportResultResponseToJson(
        ImportResultResponse instance) =>
    <String, dynamic>{
      'collectionId': instance.collectionId,
      'collectionName': instance.collectionName,
      'foldersImported': instance.foldersImported,
      'requestsImported': instance.requestsImported,
      'environmentsImported': instance.environmentsImported,
      'warnings': instance.warnings,
    };

ExportCollectionResponse _$ExportCollectionResponseFromJson(
        Map<String, dynamic> json) =>
    ExportCollectionResponse(
      format: json['format'] as String?,
      content: json['content'] as String?,
      filename: json['filename'] as String?,
    );

Map<String, dynamic> _$ExportCollectionResponseToJson(
        ExportCollectionResponse instance) =>
    <String, dynamic>{
      'format': instance.format,
      'content': instance.content,
      'filename': instance.filename,
    };

CodeSnippetResponse _$CodeSnippetResponseFromJson(Map<String, dynamic> json) =>
    CodeSnippetResponse(
      language: _$JsonConverterFromJson<String, CodeLanguage>(
          json['language'], const CodeLanguageConverter().fromJson),
      displayName: json['displayName'] as String?,
      code: json['code'] as String?,
      fileExtension: json['fileExtension'] as String?,
      contentType: json['contentType'] as String?,
    );

Map<String, dynamic> _$CodeSnippetResponseToJson(
        CodeSnippetResponse instance) =>
    <String, dynamic>{
      'language': _$JsonConverterToJson<String, CodeLanguage>(
          instance.language, const CodeLanguageConverter().toJson),
      'displayName': instance.displayName,
      'code': instance.code,
      'fileExtension': instance.fileExtension,
      'contentType': instance.contentType,
    };

GenerateCodeRequest _$GenerateCodeRequestFromJson(Map<String, dynamic> json) =>
    GenerateCodeRequest(
      requestId: json['requestId'] as String,
      language:
          const CodeLanguageConverter().fromJson(json['language'] as String),
      environmentId: json['environmentId'] as String?,
    );

Map<String, dynamic> _$GenerateCodeRequestToJson(
        GenerateCodeRequest instance) =>
    <String, dynamic>{
      'requestId': instance.requestId,
      'language': const CodeLanguageConverter().toJson(instance.language),
      'environmentId': instance.environmentId,
    };
