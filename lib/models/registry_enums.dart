/// Registry-specific enum types.
///
/// Mirrors the Java enum definitions in CodeOps-Registry exactly.
/// Each enum provides JSON serialization (SCREAMING_SNAKE_CASE),
/// deserialization, a human-readable [displayName], and a
/// companion [JsonConverter] for use with json_serializable.
library;

import 'package:json_annotation/json_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ServiceType
// ─────────────────────────────────────────────────────────────────────────────

/// The technology type of a registered service.
enum ServiceType {
  /// Spring Boot REST API.
  springBootApi,

  /// Flutter web application.
  flutterWeb,

  /// Flutter desktop application.
  flutterDesktop,

  /// Flutter mobile application.
  flutterMobile,

  /// React single-page application.
  reactSpa,

  /// Vue single-page application.
  vueSpa,

  /// Next.js application.
  nextJs,

  /// Express.js API.
  expressApi,

  /// FastAPI (Python).
  fastapi,

  /// .NET API.
  dotnetApi,

  /// Go API.
  goApi,

  /// Shared library.
  library_,

  /// Background worker.
  worker,

  /// API gateway.
  gateway,

  /// Database service.
  databaseService,

  /// Message broker.
  messageBroker,

  /// Cache service.
  cacheService,

  /// Model Context Protocol server.
  mcpServer,

  /// Command-line tool.
  cliTool,

  /// Other service type.
  other;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        ServiceType.springBootApi => 'SPRING_BOOT_API',
        ServiceType.flutterWeb => 'FLUTTER_WEB',
        ServiceType.flutterDesktop => 'FLUTTER_DESKTOP',
        ServiceType.flutterMobile => 'FLUTTER_MOBILE',
        ServiceType.reactSpa => 'REACT_SPA',
        ServiceType.vueSpa => 'VUE_SPA',
        ServiceType.nextJs => 'NEXT_JS',
        ServiceType.expressApi => 'EXPRESS_API',
        ServiceType.fastapi => 'FASTAPI',
        ServiceType.dotnetApi => 'DOTNET_API',
        ServiceType.goApi => 'GO_API',
        ServiceType.library_ => 'LIBRARY',
        ServiceType.worker => 'WORKER',
        ServiceType.gateway => 'GATEWAY',
        ServiceType.databaseService => 'DATABASE_SERVICE',
        ServiceType.messageBroker => 'MESSAGE_BROKER',
        ServiceType.cacheService => 'CACHE_SERVICE',
        ServiceType.mcpServer => 'MCP_SERVER',
        ServiceType.cliTool => 'CLI_TOOL',
        ServiceType.other => 'OTHER',
      };

  /// Deserializes a JSON string to a [ServiceType] value.
  static ServiceType fromJson(String json) => switch (json) {
        'SPRING_BOOT_API' => ServiceType.springBootApi,
        'FLUTTER_WEB' => ServiceType.flutterWeb,
        'FLUTTER_DESKTOP' => ServiceType.flutterDesktop,
        'FLUTTER_MOBILE' => ServiceType.flutterMobile,
        'REACT_SPA' => ServiceType.reactSpa,
        'VUE_SPA' => ServiceType.vueSpa,
        'NEXT_JS' => ServiceType.nextJs,
        'EXPRESS_API' => ServiceType.expressApi,
        'FASTAPI' => ServiceType.fastapi,
        'DOTNET_API' => ServiceType.dotnetApi,
        'GO_API' => ServiceType.goApi,
        'LIBRARY' => ServiceType.library_,
        'WORKER' => ServiceType.worker,
        'GATEWAY' => ServiceType.gateway,
        'DATABASE_SERVICE' => ServiceType.databaseService,
        'MESSAGE_BROKER' => ServiceType.messageBroker,
        'CACHE_SERVICE' => ServiceType.cacheService,
        'MCP_SERVER' => ServiceType.mcpServer,
        'CLI_TOOL' => ServiceType.cliTool,
        'OTHER' => ServiceType.other,
        _ => throw ArgumentError('Unknown ServiceType: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        ServiceType.springBootApi => 'Spring Boot API',
        ServiceType.flutterWeb => 'Flutter Web',
        ServiceType.flutterDesktop => 'Flutter Desktop',
        ServiceType.flutterMobile => 'Flutter Mobile',
        ServiceType.reactSpa => 'React SPA',
        ServiceType.vueSpa => 'Vue SPA',
        ServiceType.nextJs => 'Next.js',
        ServiceType.expressApi => 'Express API',
        ServiceType.fastapi => 'FastAPI',
        ServiceType.dotnetApi => '.NET API',
        ServiceType.goApi => 'Go API',
        ServiceType.library_ => 'Library',
        ServiceType.worker => 'Worker',
        ServiceType.gateway => 'Gateway',
        ServiceType.databaseService => 'Database Service',
        ServiceType.messageBroker => 'Message Broker',
        ServiceType.cacheService => 'Cache Service',
        ServiceType.mcpServer => 'MCP Server',
        ServiceType.cliTool => 'CLI Tool',
        ServiceType.other => 'Other',
      };
}

/// JSON converter for [ServiceType].
class ServiceTypeConverter extends JsonConverter<ServiceType, String> {
  /// Creates a const [ServiceTypeConverter].
  const ServiceTypeConverter();

  @override
  ServiceType fromJson(String json) => ServiceType.fromJson(json);

  @override
  String toJson(ServiceType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ServiceStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle status of a registered service.
enum ServiceStatus {
  /// Service is actively running.
  active,

  /// Service is not currently running.
  inactive,

  /// Service is deprecated and should not be used.
  deprecated,

  /// Service is archived and read-only.
  archived;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        ServiceStatus.active => 'ACTIVE',
        ServiceStatus.inactive => 'INACTIVE',
        ServiceStatus.deprecated => 'DEPRECATED',
        ServiceStatus.archived => 'ARCHIVED',
      };

  /// Deserializes a JSON string to a [ServiceStatus] value.
  static ServiceStatus fromJson(String json) => switch (json) {
        'ACTIVE' => ServiceStatus.active,
        'INACTIVE' => ServiceStatus.inactive,
        'DEPRECATED' => ServiceStatus.deprecated,
        'ARCHIVED' => ServiceStatus.archived,
        _ => throw ArgumentError('Unknown ServiceStatus: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        ServiceStatus.active => 'Active',
        ServiceStatus.inactive => 'Inactive',
        ServiceStatus.deprecated => 'Deprecated',
        ServiceStatus.archived => 'Archived',
      };
}

/// JSON converter for [ServiceStatus].
class ServiceStatusConverter extends JsonConverter<ServiceStatus, String> {
  /// Creates a const [ServiceStatusConverter].
  const ServiceStatusConverter();

  @override
  ServiceStatus fromJson(String json) => ServiceStatus.fromJson(json);

  @override
  String toJson(ServiceStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// HealthStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Health status of a service.
enum HealthStatus {
  /// Service is healthy.
  up,

  /// Service is down.
  down,

  /// Service is partially healthy.
  degraded,

  /// Health status is unknown.
  unknown;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        HealthStatus.up => 'UP',
        HealthStatus.down => 'DOWN',
        HealthStatus.degraded => 'DEGRADED',
        HealthStatus.unknown => 'UNKNOWN',
      };

  /// Deserializes a JSON string to a [HealthStatus] value.
  static HealthStatus fromJson(String json) => switch (json) {
        'UP' => HealthStatus.up,
        'DOWN' => HealthStatus.down,
        'DEGRADED' => HealthStatus.degraded,
        'UNKNOWN' => HealthStatus.unknown,
        _ => throw ArgumentError('Unknown HealthStatus: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        HealthStatus.up => 'Up',
        HealthStatus.down => 'Down',
        HealthStatus.degraded => 'Degraded',
        HealthStatus.unknown => 'Unknown',
      };
}

/// JSON converter for [HealthStatus].
class HealthStatusConverter extends JsonConverter<HealthStatus, String> {
  /// Creates a const [HealthStatusConverter].
  const HealthStatusConverter();

  @override
  HealthStatus fromJson(String json) => HealthStatus.fromJson(json);

  @override
  String toJson(HealthStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// SolutionCategory
// ─────────────────────────────────────────────────────────────────────────────

/// Category of a solution grouping.
enum SolutionCategory {
  /// Platform-level solution.
  platform,

  /// Application-level solution.
  application,

  /// Library suite.
  librarySuite,

  /// Infrastructure solution.
  infrastructure,

  /// Tooling solution.
  tooling,

  /// Other category.
  other;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        SolutionCategory.platform => 'PLATFORM',
        SolutionCategory.application => 'APPLICATION',
        SolutionCategory.librarySuite => 'LIBRARY_SUITE',
        SolutionCategory.infrastructure => 'INFRASTRUCTURE',
        SolutionCategory.tooling => 'TOOLING',
        SolutionCategory.other => 'OTHER',
      };

  /// Deserializes a JSON string to a [SolutionCategory] value.
  static SolutionCategory fromJson(String json) => switch (json) {
        'PLATFORM' => SolutionCategory.platform,
        'APPLICATION' => SolutionCategory.application,
        'LIBRARY_SUITE' => SolutionCategory.librarySuite,
        'INFRASTRUCTURE' => SolutionCategory.infrastructure,
        'TOOLING' => SolutionCategory.tooling,
        'OTHER' => SolutionCategory.other,
        _ => throw ArgumentError('Unknown SolutionCategory: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        SolutionCategory.platform => 'Platform',
        SolutionCategory.application => 'Application',
        SolutionCategory.librarySuite => 'Library Suite',
        SolutionCategory.infrastructure => 'Infrastructure',
        SolutionCategory.tooling => 'Tooling',
        SolutionCategory.other => 'Other',
      };
}

/// JSON converter for [SolutionCategory].
class SolutionCategoryConverter
    extends JsonConverter<SolutionCategory, String> {
  /// Creates a const [SolutionCategoryConverter].
  const SolutionCategoryConverter();

  @override
  SolutionCategory fromJson(String json) => SolutionCategory.fromJson(json);

  @override
  String toJson(SolutionCategory object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// SolutionStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle status of a solution.
enum SolutionStatus {
  /// Solution is active and in use.
  active,

  /// Solution is under active development.
  inDevelopment,

  /// Solution is deprecated.
  deprecated,

  /// Solution is archived.
  archived;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        SolutionStatus.active => 'ACTIVE',
        SolutionStatus.inDevelopment => 'IN_DEVELOPMENT',
        SolutionStatus.deprecated => 'DEPRECATED',
        SolutionStatus.archived => 'ARCHIVED',
      };

  /// Deserializes a JSON string to a [SolutionStatus] value.
  static SolutionStatus fromJson(String json) => switch (json) {
        'ACTIVE' => SolutionStatus.active,
        'IN_DEVELOPMENT' => SolutionStatus.inDevelopment,
        'DEPRECATED' => SolutionStatus.deprecated,
        'ARCHIVED' => SolutionStatus.archived,
        _ => throw ArgumentError('Unknown SolutionStatus: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        SolutionStatus.active => 'Active',
        SolutionStatus.inDevelopment => 'In Development',
        SolutionStatus.deprecated => 'Deprecated',
        SolutionStatus.archived => 'Archived',
      };
}

/// JSON converter for [SolutionStatus].
class SolutionStatusConverter extends JsonConverter<SolutionStatus, String> {
  /// Creates a const [SolutionStatusConverter].
  const SolutionStatusConverter();

  @override
  SolutionStatus fromJson(String json) => SolutionStatus.fromJson(json);

  @override
  String toJson(SolutionStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// SolutionMemberRole
// ─────────────────────────────────────────────────────────────────────────────

/// Role of a service within a solution.
enum SolutionMemberRole {
  /// Core service of the solution.
  core,

  /// Supporting service.
  supporting,

  /// Infrastructure service.
  infrastructure,

  /// External dependency.
  externalDependency;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        SolutionMemberRole.core => 'CORE',
        SolutionMemberRole.supporting => 'SUPPORTING',
        SolutionMemberRole.infrastructure => 'INFRASTRUCTURE',
        SolutionMemberRole.externalDependency => 'EXTERNAL_DEPENDENCY',
      };

  /// Deserializes a JSON string to a [SolutionMemberRole] value.
  static SolutionMemberRole fromJson(String json) => switch (json) {
        'CORE' => SolutionMemberRole.core,
        'SUPPORTING' => SolutionMemberRole.supporting,
        'INFRASTRUCTURE' => SolutionMemberRole.infrastructure,
        'EXTERNAL_DEPENDENCY' => SolutionMemberRole.externalDependency,
        _ => throw ArgumentError('Unknown SolutionMemberRole: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        SolutionMemberRole.core => 'Core',
        SolutionMemberRole.supporting => 'Supporting',
        SolutionMemberRole.infrastructure => 'Infrastructure',
        SolutionMemberRole.externalDependency => 'External Dependency',
      };
}

/// JSON converter for [SolutionMemberRole].
class SolutionMemberRoleConverter
    extends JsonConverter<SolutionMemberRole, String> {
  /// Creates a const [SolutionMemberRoleConverter].
  const SolutionMemberRoleConverter();

  @override
  SolutionMemberRole fromJson(String json) =>
      SolutionMemberRole.fromJson(json);

  @override
  String toJson(SolutionMemberRole object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// PortType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of port allocation.
enum PortType {
  /// HTTP API port.
  httpApi,

  /// Frontend development server port.
  frontendDev,

  /// Database port.
  database,

  /// Redis port.
  redis,

  /// Kafka port.
  kafka,

  /// Kafka internal port.
  kafkaInternal,

  /// Zookeeper port.
  zookeeper,

  /// gRPC port.
  grpc,

  /// WebSocket port.
  websocket,

  /// Debug port.
  debug,

  /// Actuator/management port.
  actuator,

  /// Custom port type.
  custom;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        PortType.httpApi => 'HTTP_API',
        PortType.frontendDev => 'FRONTEND_DEV',
        PortType.database => 'DATABASE',
        PortType.redis => 'REDIS',
        PortType.kafka => 'KAFKA',
        PortType.kafkaInternal => 'KAFKA_INTERNAL',
        PortType.zookeeper => 'ZOOKEEPER',
        PortType.grpc => 'GRPC',
        PortType.websocket => 'WEBSOCKET',
        PortType.debug => 'DEBUG',
        PortType.actuator => 'ACTUATOR',
        PortType.custom => 'CUSTOM',
      };

  /// Deserializes a JSON string to a [PortType] value.
  static PortType fromJson(String json) => switch (json) {
        'HTTP_API' => PortType.httpApi,
        'FRONTEND_DEV' => PortType.frontendDev,
        'DATABASE' => PortType.database,
        'REDIS' => PortType.redis,
        'KAFKA' => PortType.kafka,
        'KAFKA_INTERNAL' => PortType.kafkaInternal,
        'ZOOKEEPER' => PortType.zookeeper,
        'GRPC' => PortType.grpc,
        'WEBSOCKET' => PortType.websocket,
        'DEBUG' => PortType.debug,
        'ACTUATOR' => PortType.actuator,
        'CUSTOM' => PortType.custom,
        _ => throw ArgumentError('Unknown PortType: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        PortType.httpApi => 'HTTP API',
        PortType.frontendDev => 'Frontend Dev',
        PortType.database => 'Database',
        PortType.redis => 'Redis',
        PortType.kafka => 'Kafka',
        PortType.kafkaInternal => 'Kafka Internal',
        PortType.zookeeper => 'Zookeeper',
        PortType.grpc => 'gRPC',
        PortType.websocket => 'WebSocket',
        PortType.debug => 'Debug',
        PortType.actuator => 'Actuator',
        PortType.custom => 'Custom',
      };
}

/// JSON converter for [PortType].
class PortTypeConverter extends JsonConverter<PortType, String> {
  /// Creates a const [PortTypeConverter].
  const PortTypeConverter();

  @override
  PortType fromJson(String json) => PortType.fromJson(json);

  @override
  String toJson(PortType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// DependencyType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of dependency between services.
enum DependencyType {
  /// HTTP REST dependency.
  httpRest,

  /// gRPC dependency.
  grpc,

  /// Kafka topic dependency.
  kafkaTopic,

  /// Shared database dependency.
  databaseShared,

  /// Shared Redis dependency.
  redisShared,

  /// Library dependency.
  library_,

  /// Gateway route dependency.
  gatewayRoute,

  /// WebSocket dependency.
  websocket,

  /// File system dependency.
  fileSystem,

  /// Other dependency type.
  other;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        DependencyType.httpRest => 'HTTP_REST',
        DependencyType.grpc => 'GRPC',
        DependencyType.kafkaTopic => 'KAFKA_TOPIC',
        DependencyType.databaseShared => 'DATABASE_SHARED',
        DependencyType.redisShared => 'REDIS_SHARED',
        DependencyType.library_ => 'LIBRARY',
        DependencyType.gatewayRoute => 'GATEWAY_ROUTE',
        DependencyType.websocket => 'WEBSOCKET',
        DependencyType.fileSystem => 'FILE_SYSTEM',
        DependencyType.other => 'OTHER',
      };

  /// Deserializes a JSON string to a [DependencyType] value.
  static DependencyType fromJson(String json) => switch (json) {
        'HTTP_REST' => DependencyType.httpRest,
        'GRPC' => DependencyType.grpc,
        'KAFKA_TOPIC' => DependencyType.kafkaTopic,
        'DATABASE_SHARED' => DependencyType.databaseShared,
        'REDIS_SHARED' => DependencyType.redisShared,
        'LIBRARY' => DependencyType.library_,
        'GATEWAY_ROUTE' => DependencyType.gatewayRoute,
        'WEBSOCKET' => DependencyType.websocket,
        'FILE_SYSTEM' => DependencyType.fileSystem,
        'OTHER' => DependencyType.other,
        _ => throw ArgumentError('Unknown DependencyType: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        DependencyType.httpRest => 'HTTP REST',
        DependencyType.grpc => 'gRPC',
        DependencyType.kafkaTopic => 'Kafka Topic',
        DependencyType.databaseShared => 'Database Shared',
        DependencyType.redisShared => 'Redis Shared',
        DependencyType.library_ => 'Library',
        DependencyType.gatewayRoute => 'Gateway Route',
        DependencyType.websocket => 'WebSocket',
        DependencyType.fileSystem => 'File System',
        DependencyType.other => 'Other',
      };
}

/// JSON converter for [DependencyType].
class DependencyTypeConverter extends JsonConverter<DependencyType, String> {
  /// Creates a const [DependencyTypeConverter].
  const DependencyTypeConverter();

  @override
  DependencyType fromJson(String json) => DependencyType.fromJson(json);

  @override
  String toJson(DependencyType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ConfigTemplateType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of configuration template.
enum ConfigTemplateType {
  /// Docker Compose file.
  dockerCompose,

  /// Spring application.yml.
  applicationYml,

  /// Spring application.properties.
  applicationProperties,

  /// Environment file (.env).
  envFile,

  /// Terraform module.
  terraformModule,

  /// Claude Code header.
  claudeCodeHeader,

  /// Conventions markdown file.
  conventionsMd,

  /// Nginx configuration.
  nginxConf,

  /// GitHub Actions workflow.
  githubActions,

  /// Dockerfile.
  dockerfile,

  /// Makefile.
  makefile,

  /// README section.
  readmeSection;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        ConfigTemplateType.dockerCompose => 'DOCKER_COMPOSE',
        ConfigTemplateType.applicationYml => 'APPLICATION_YML',
        ConfigTemplateType.applicationProperties => 'APPLICATION_PROPERTIES',
        ConfigTemplateType.envFile => 'ENV_FILE',
        ConfigTemplateType.terraformModule => 'TERRAFORM_MODULE',
        ConfigTemplateType.claudeCodeHeader => 'CLAUDE_CODE_HEADER',
        ConfigTemplateType.conventionsMd => 'CONVENTIONS_MD',
        ConfigTemplateType.nginxConf => 'NGINX_CONF',
        ConfigTemplateType.githubActions => 'GITHUB_ACTIONS',
        ConfigTemplateType.dockerfile => 'DOCKERFILE',
        ConfigTemplateType.makefile => 'MAKEFILE',
        ConfigTemplateType.readmeSection => 'README_SECTION',
      };

  /// Deserializes a JSON string to a [ConfigTemplateType] value.
  static ConfigTemplateType fromJson(String json) => switch (json) {
        'DOCKER_COMPOSE' => ConfigTemplateType.dockerCompose,
        'APPLICATION_YML' => ConfigTemplateType.applicationYml,
        'APPLICATION_PROPERTIES' => ConfigTemplateType.applicationProperties,
        'ENV_FILE' => ConfigTemplateType.envFile,
        'TERRAFORM_MODULE' => ConfigTemplateType.terraformModule,
        'CLAUDE_CODE_HEADER' => ConfigTemplateType.claudeCodeHeader,
        'CONVENTIONS_MD' => ConfigTemplateType.conventionsMd,
        'NGINX_CONF' => ConfigTemplateType.nginxConf,
        'GITHUB_ACTIONS' => ConfigTemplateType.githubActions,
        'DOCKERFILE' => ConfigTemplateType.dockerfile,
        'MAKEFILE' => ConfigTemplateType.makefile,
        'README_SECTION' => ConfigTemplateType.readmeSection,
        _ => throw ArgumentError('Unknown ConfigTemplateType: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        ConfigTemplateType.dockerCompose => 'Docker Compose',
        ConfigTemplateType.applicationYml => 'application.yml',
        ConfigTemplateType.applicationProperties => 'application.properties',
        ConfigTemplateType.envFile => '.env File',
        ConfigTemplateType.terraformModule => 'Terraform Module',
        ConfigTemplateType.claudeCodeHeader => 'Claude Code Header',
        ConfigTemplateType.conventionsMd => 'CONVENTIONS.md',
        ConfigTemplateType.nginxConf => 'Nginx Config',
        ConfigTemplateType.githubActions => 'GitHub Actions',
        ConfigTemplateType.dockerfile => 'Dockerfile',
        ConfigTemplateType.makefile => 'Makefile',
        ConfigTemplateType.readmeSection => 'README Section',
      };
}

/// JSON converter for [ConfigTemplateType].
class ConfigTemplateTypeConverter
    extends JsonConverter<ConfigTemplateType, String> {
  /// Creates a const [ConfigTemplateTypeConverter].
  const ConfigTemplateTypeConverter();

  @override
  ConfigTemplateType fromJson(String json) =>
      ConfigTemplateType.fromJson(json);

  @override
  String toJson(ConfigTemplateType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// InfraResourceType
// ─────────────────────────────────────────────────────────────────────────────

/// Type of infrastructure resource.
enum InfraResourceType {
  /// AWS S3 bucket.
  s3Bucket,

  /// AWS SQS queue.
  sqsQueue,

  /// AWS SNS topic.
  snsTopic,

  /// AWS CloudWatch log group.
  cloudwatchLogGroup,

  /// AWS IAM role.
  iamRole,

  /// AWS Secrets Manager path.
  secretsManagerPath,

  /// AWS SSM parameter.
  ssmParameter,

  /// AWS RDS instance.
  rdsInstance,

  /// AWS ElastiCache cluster.
  elasticacheCluster,

  /// AWS ECR repository.
  ecrRepository,

  /// AWS Cloud Map namespace.
  cloudMapNamespace,

  /// AWS Route 53 record.
  route53Record,

  /// AWS ACM certificate.
  acmCertificate,

  /// AWS ALB target group.
  albTargetGroup,

  /// AWS ECS service.
  ecsService,

  /// AWS Lambda function.
  lambdaFunction,

  /// AWS DynamoDB table.
  dynamodbTable,

  /// Docker network.
  dockerNetwork,

  /// Docker volume.
  dockerVolume,

  /// Other infrastructure resource.
  other;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        InfraResourceType.s3Bucket => 'S3_BUCKET',
        InfraResourceType.sqsQueue => 'SQS_QUEUE',
        InfraResourceType.snsTopic => 'SNS_TOPIC',
        InfraResourceType.cloudwatchLogGroup => 'CLOUDWATCH_LOG_GROUP',
        InfraResourceType.iamRole => 'IAM_ROLE',
        InfraResourceType.secretsManagerPath => 'SECRETS_MANAGER_PATH',
        InfraResourceType.ssmParameter => 'SSM_PARAMETER',
        InfraResourceType.rdsInstance => 'RDS_INSTANCE',
        InfraResourceType.elasticacheCluster => 'ELASTICACHE_CLUSTER',
        InfraResourceType.ecrRepository => 'ECR_REPOSITORY',
        InfraResourceType.cloudMapNamespace => 'CLOUD_MAP_NAMESPACE',
        InfraResourceType.route53Record => 'ROUTE53_RECORD',
        InfraResourceType.acmCertificate => 'ACM_CERTIFICATE',
        InfraResourceType.albTargetGroup => 'ALB_TARGET_GROUP',
        InfraResourceType.ecsService => 'ECS_SERVICE',
        InfraResourceType.lambdaFunction => 'LAMBDA_FUNCTION',
        InfraResourceType.dynamodbTable => 'DYNAMODB_TABLE',
        InfraResourceType.dockerNetwork => 'DOCKER_NETWORK',
        InfraResourceType.dockerVolume => 'DOCKER_VOLUME',
        InfraResourceType.other => 'OTHER',
      };

  /// Deserializes a JSON string to an [InfraResourceType] value.
  static InfraResourceType fromJson(String json) => switch (json) {
        'S3_BUCKET' => InfraResourceType.s3Bucket,
        'SQS_QUEUE' => InfraResourceType.sqsQueue,
        'SNS_TOPIC' => InfraResourceType.snsTopic,
        'CLOUDWATCH_LOG_GROUP' => InfraResourceType.cloudwatchLogGroup,
        'IAM_ROLE' => InfraResourceType.iamRole,
        'SECRETS_MANAGER_PATH' => InfraResourceType.secretsManagerPath,
        'SSM_PARAMETER' => InfraResourceType.ssmParameter,
        'RDS_INSTANCE' => InfraResourceType.rdsInstance,
        'ELASTICACHE_CLUSTER' => InfraResourceType.elasticacheCluster,
        'ECR_REPOSITORY' => InfraResourceType.ecrRepository,
        'CLOUD_MAP_NAMESPACE' => InfraResourceType.cloudMapNamespace,
        'ROUTE53_RECORD' => InfraResourceType.route53Record,
        'ACM_CERTIFICATE' => InfraResourceType.acmCertificate,
        'ALB_TARGET_GROUP' => InfraResourceType.albTargetGroup,
        'ECS_SERVICE' => InfraResourceType.ecsService,
        'LAMBDA_FUNCTION' => InfraResourceType.lambdaFunction,
        'DYNAMODB_TABLE' => InfraResourceType.dynamodbTable,
        'DOCKER_NETWORK' => InfraResourceType.dockerNetwork,
        'DOCKER_VOLUME' => InfraResourceType.dockerVolume,
        'OTHER' => InfraResourceType.other,
        _ => throw ArgumentError('Unknown InfraResourceType: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        InfraResourceType.s3Bucket => 'S3 Bucket',
        InfraResourceType.sqsQueue => 'SQS Queue',
        InfraResourceType.snsTopic => 'SNS Topic',
        InfraResourceType.cloudwatchLogGroup => 'CloudWatch Log Group',
        InfraResourceType.iamRole => 'IAM Role',
        InfraResourceType.secretsManagerPath => 'Secrets Manager Path',
        InfraResourceType.ssmParameter => 'SSM Parameter',
        InfraResourceType.rdsInstance => 'RDS Instance',
        InfraResourceType.elasticacheCluster => 'ElastiCache Cluster',
        InfraResourceType.ecrRepository => 'ECR Repository',
        InfraResourceType.cloudMapNamespace => 'Cloud Map Namespace',
        InfraResourceType.route53Record => 'Route 53 Record',
        InfraResourceType.acmCertificate => 'ACM Certificate',
        InfraResourceType.albTargetGroup => 'ALB Target Group',
        InfraResourceType.ecsService => 'ECS Service',
        InfraResourceType.lambdaFunction => 'Lambda Function',
        InfraResourceType.dynamodbTable => 'DynamoDB Table',
        InfraResourceType.dockerNetwork => 'Docker Network',
        InfraResourceType.dockerVolume => 'Docker Volume',
        InfraResourceType.other => 'Other',
      };
}

/// JSON converter for [InfraResourceType].
class InfraResourceTypeConverter
    extends JsonConverter<InfraResourceType, String> {
  /// Creates a const [InfraResourceTypeConverter].
  const InfraResourceTypeConverter();

  @override
  InfraResourceType fromJson(String json) => InfraResourceType.fromJson(json);

  @override
  String toJson(InfraResourceType object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// ConfigSource
// ─────────────────────────────────────────────────────────────────────────────

/// Source of a configuration value.
enum ConfigSource {
  /// Auto-generated by the Registry.
  autoGenerated,

  /// Manually entered.
  manual,

  /// Inherited from a parent.
  inherited,

  /// Derived from registry data.
  registryDerived;

  /// Serializes this value to its JSON (SCREAMING_SNAKE_CASE) representation.
  String toJson() => switch (this) {
        ConfigSource.autoGenerated => 'AUTO_GENERATED',
        ConfigSource.manual => 'MANUAL',
        ConfigSource.inherited => 'INHERITED',
        ConfigSource.registryDerived => 'REGISTRY_DERIVED',
      };

  /// Deserializes a JSON string to a [ConfigSource] value.
  static ConfigSource fromJson(String json) => switch (json) {
        'AUTO_GENERATED' => ConfigSource.autoGenerated,
        'MANUAL' => ConfigSource.manual,
        'INHERITED' => ConfigSource.inherited,
        'REGISTRY_DERIVED' => ConfigSource.registryDerived,
        _ => throw ArgumentError('Unknown ConfigSource: $json'),
      };

  /// Human-readable display name.
  String get displayName => switch (this) {
        ConfigSource.autoGenerated => 'Auto-Generated',
        ConfigSource.manual => 'Manual',
        ConfigSource.inherited => 'Inherited',
        ConfigSource.registryDerived => 'Registry Derived',
      };
}

/// JSON converter for [ConfigSource].
class ConfigSourceConverter extends JsonConverter<ConfigSource, String> {
  /// Creates a const [ConfigSourceConverter].
  const ConfigSourceConverter();

  @override
  ConfigSource fromJson(String json) => ConfigSource.fromJson(json);

  @override
  String toJson(ConfigSource object) => object.toJson();
}
