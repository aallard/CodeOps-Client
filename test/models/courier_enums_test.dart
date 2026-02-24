import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/courier_enums.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────────────
  // CourierHttpMethod
  // ─────────────────────────────────────────────────────────────────────────

  group('CourierHttpMethod', () {
    test('has 7 values', () {
      expect(CourierHttpMethod.values, hasLength(7));
    });

    test('toJson returns correct server strings', () {
      expect(CourierHttpMethod.get.toJson(), 'GET');
      expect(CourierHttpMethod.post.toJson(), 'POST');
      expect(CourierHttpMethod.put.toJson(), 'PUT');
      expect(CourierHttpMethod.patch.toJson(), 'PATCH');
      expect(CourierHttpMethod.delete.toJson(), 'DELETE');
      expect(CourierHttpMethod.head.toJson(), 'HEAD');
      expect(CourierHttpMethod.options.toJson(), 'OPTIONS');
    });

    test('fromJson round-trips all values', () {
      for (final v in CourierHttpMethod.values) {
        expect(CourierHttpMethod.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(CourierHttpMethod.get.displayName, 'GET');
      expect(CourierHttpMethod.post.displayName, 'POST');
      expect(CourierHttpMethod.options.displayName, 'OPTIONS');
    });

    test('fromJson throws on invalid input', () {
      expect(
          () => CourierHttpMethod.fromJson('INVALID'), throwsArgumentError);
    });

    test('CourierHttpMethodConverter round-trips all values', () {
      const converter = CourierHttpMethodConverter();
      for (final v in CourierHttpMethod.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // AuthType
  // ─────────────────────────────────────────────────────────────────────────

  group('AuthType', () {
    test('has 10 values', () {
      expect(AuthType.values, hasLength(10));
    });

    test('toJson returns correct server strings', () {
      expect(AuthType.noAuth.toJson(), 'NO_AUTH');
      expect(AuthType.apiKey.toJson(), 'API_KEY');
      expect(AuthType.bearerToken.toJson(), 'BEARER_TOKEN');
      expect(AuthType.basicAuth.toJson(), 'BASIC_AUTH');
      expect(AuthType.oauth2AuthorizationCode.toJson(),
          'OAUTH2_AUTHORIZATION_CODE');
      expect(AuthType.oauth2ClientCredentials.toJson(),
          'OAUTH2_CLIENT_CREDENTIALS');
      expect(AuthType.oauth2Implicit.toJson(), 'OAUTH2_IMPLICIT');
      expect(AuthType.oauth2Password.toJson(), 'OAUTH2_PASSWORD');
      expect(AuthType.jwtBearer.toJson(), 'JWT_BEARER');
      expect(AuthType.inheritFromParent.toJson(), 'INHERIT_FROM_PARENT');
    });

    test('fromJson round-trips all values', () {
      for (final v in AuthType.values) {
        expect(AuthType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(AuthType.noAuth.displayName, 'No Auth');
      expect(AuthType.bearerToken.displayName, 'Bearer Token');
      expect(AuthType.inheritFromParent.displayName, 'Inherit from Parent');
    });

    test('fromJson throws on invalid input', () {
      expect(() => AuthType.fromJson('INVALID'), throwsArgumentError);
    });

    test('AuthTypeConverter round-trips all values', () {
      const converter = AuthTypeConverter();
      for (final v in AuthType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // BodyType
  // ─────────────────────────────────────────────────────────────────────────

  group('BodyType', () {
    test('has 10 values', () {
      expect(BodyType.values, hasLength(10));
    });

    test('toJson returns correct server strings', () {
      expect(BodyType.none.toJson(), 'NONE');
      expect(BodyType.formData.toJson(), 'FORM_DATA');
      expect(BodyType.xWwwFormUrlEncoded.toJson(), 'X_WWW_FORM_URLENCODED');
      expect(BodyType.rawJson.toJson(), 'RAW_JSON');
      expect(BodyType.rawXml.toJson(), 'RAW_XML');
      expect(BodyType.rawHtml.toJson(), 'RAW_HTML');
      expect(BodyType.rawText.toJson(), 'RAW_TEXT');
      expect(BodyType.rawYaml.toJson(), 'RAW_YAML');
      expect(BodyType.binary.toJson(), 'BINARY');
      expect(BodyType.graphql.toJson(), 'GRAPHQL');
    });

    test('fromJson round-trips all values', () {
      for (final v in BodyType.values) {
        expect(BodyType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(BodyType.none.displayName, 'None');
      expect(BodyType.formData.displayName, 'Form Data');
      expect(BodyType.rawJson.displayName, 'JSON');
      expect(BodyType.graphql.displayName, 'GraphQL');
    });

    test('fromJson throws on invalid input', () {
      expect(() => BodyType.fromJson('INVALID'), throwsArgumentError);
    });

    test('BodyTypeConverter round-trips all values', () {
      const converter = BodyTypeConverter();
      for (final v in BodyType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // CodeLanguage
  // ─────────────────────────────────────────────────────────────────────────

  group('CodeLanguage', () {
    test('has 12 values', () {
      expect(CodeLanguage.values, hasLength(12));
    });

    test('toJson returns correct server strings', () {
      expect(CodeLanguage.curl.toJson(), 'CURL');
      expect(CodeLanguage.pythonRequests.toJson(), 'PYTHON_REQUESTS');
      expect(CodeLanguage.javascriptFetch.toJson(), 'JAVASCRIPT_FETCH');
      expect(CodeLanguage.javascriptAxios.toJson(), 'JAVASCRIPT_AXIOS');
      expect(CodeLanguage.javaHttpClient.toJson(), 'JAVA_HTTP_CLIENT');
      expect(CodeLanguage.javaOkhttp.toJson(), 'JAVA_OKHTTP');
      expect(CodeLanguage.csharpHttpClient.toJson(), 'CSHARP_HTTP_CLIENT');
      expect(CodeLanguage.go.toJson(), 'GO');
      expect(CodeLanguage.ruby.toJson(), 'RUBY');
      expect(CodeLanguage.php.toJson(), 'PHP');
      expect(CodeLanguage.swift.toJson(), 'SWIFT');
      expect(CodeLanguage.kotlin.toJson(), 'KOTLIN');
    });

    test('fromJson round-trips all values', () {
      for (final v in CodeLanguage.values) {
        expect(CodeLanguage.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(CodeLanguage.curl.displayName, 'cURL');
      expect(CodeLanguage.pythonRequests.displayName, 'Python (Requests)');
      expect(CodeLanguage.go.displayName, 'Go');
      expect(CodeLanguage.kotlin.displayName, 'Kotlin');
    });

    test('fromJson throws on invalid input', () {
      expect(() => CodeLanguage.fromJson('INVALID'), throwsArgumentError);
    });

    test('CodeLanguageConverter round-trips all values', () {
      const converter = CodeLanguageConverter();
      for (final v in CodeLanguage.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // RunStatus
  // ─────────────────────────────────────────────────────────────────────────

  group('RunStatus', () {
    test('has 5 values', () {
      expect(RunStatus.values, hasLength(5));
    });

    test('toJson returns correct server strings', () {
      expect(RunStatus.pending.toJson(), 'PENDING');
      expect(RunStatus.running.toJson(), 'RUNNING');
      expect(RunStatus.completed.toJson(), 'COMPLETED');
      expect(RunStatus.failed.toJson(), 'FAILED');
      expect(RunStatus.cancelled.toJson(), 'CANCELLED');
    });

    test('fromJson round-trips all values', () {
      for (final v in RunStatus.values) {
        expect(RunStatus.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(RunStatus.pending.displayName, 'Pending');
      expect(RunStatus.running.displayName, 'Running');
      expect(RunStatus.cancelled.displayName, 'Cancelled');
    });

    test('fromJson throws on invalid input', () {
      expect(() => RunStatus.fromJson('INVALID'), throwsArgumentError);
    });

    test('RunStatusConverter round-trips all values', () {
      const converter = RunStatusConverter();
      for (final v in RunStatus.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // ScriptType
  // ─────────────────────────────────────────────────────────────────────────

  group('ScriptType', () {
    test('has 2 values', () {
      expect(ScriptType.values, hasLength(2));
    });

    test('toJson returns correct server strings', () {
      expect(ScriptType.preRequest.toJson(), 'PRE_REQUEST');
      expect(ScriptType.postResponse.toJson(), 'POST_RESPONSE');
    });

    test('fromJson round-trips all values', () {
      for (final v in ScriptType.values) {
        expect(ScriptType.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(ScriptType.preRequest.displayName, 'Pre-Request');
      expect(ScriptType.postResponse.displayName, 'Post-Response');
    });

    test('fromJson throws on invalid input', () {
      expect(() => ScriptType.fromJson('INVALID'), throwsArgumentError);
    });

    test('ScriptTypeConverter round-trips all values', () {
      const converter = ScriptTypeConverter();
      for (final v in ScriptType.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  // SharePermission
  // ─────────────────────────────────────────────────────────────────────────

  group('SharePermission', () {
    test('has 3 values', () {
      expect(SharePermission.values, hasLength(3));
    });

    test('toJson returns correct server strings', () {
      expect(SharePermission.viewer.toJson(), 'VIEWER');
      expect(SharePermission.editor.toJson(), 'EDITOR');
      expect(SharePermission.admin.toJson(), 'ADMIN');
    });

    test('fromJson round-trips all values', () {
      for (final v in SharePermission.values) {
        expect(SharePermission.fromJson(v.toJson()), v);
      }
    });

    test('displayName returns human label', () {
      expect(SharePermission.viewer.displayName, 'Viewer');
      expect(SharePermission.editor.displayName, 'Editor');
      expect(SharePermission.admin.displayName, 'Admin');
    });

    test('fromJson throws on invalid input', () {
      expect(
          () => SharePermission.fromJson('INVALID'), throwsArgumentError);
    });

    test('SharePermissionConverter round-trips all values', () {
      const converter = SharePermissionConverter();
      for (final v in SharePermission.values) {
        expect(converter.fromJson(converter.toJson(v)), v);
      }
    });
  });
}
