/// Enum types for the CodeOps-Fleet module.
///
/// Each enum provides SCREAMING_SNAKE_CASE serialization matching the Server's
/// Java enums, plus a companion [JsonConverter] for use with `json_serializable`.
library;

import 'package:json_annotation/json_annotation.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContainerStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Lifecycle state of a Docker container managed by Fleet.
enum ContainerStatus {
  /// Container has been created but not started.
  created,

  /// Container is running.
  running,

  /// Container is paused.
  paused,

  /// Container is restarting.
  restarting,

  /// Container is being removed.
  removing,

  /// Container has exited.
  exited,

  /// Container is dead.
  dead,

  /// Container has been stopped.
  stopped;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        ContainerStatus.created => 'CREATED',
        ContainerStatus.running => 'RUNNING',
        ContainerStatus.paused => 'PAUSED',
        ContainerStatus.restarting => 'RESTARTING',
        ContainerStatus.removing => 'REMOVING',
        ContainerStatus.exited => 'EXITED',
        ContainerStatus.dead => 'DEAD',
        ContainerStatus.stopped => 'STOPPED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static ContainerStatus fromJson(String json) => switch (json) {
        'CREATED' => ContainerStatus.created,
        'RUNNING' => ContainerStatus.running,
        'PAUSED' => ContainerStatus.paused,
        'RESTARTING' => ContainerStatus.restarting,
        'REMOVING' => ContainerStatus.removing,
        'EXITED' => ContainerStatus.exited,
        'DEAD' => ContainerStatus.dead,
        'STOPPED' => ContainerStatus.stopped,
        _ => throw ArgumentError('Unknown ContainerStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        ContainerStatus.created => 'Created',
        ContainerStatus.running => 'Running',
        ContainerStatus.paused => 'Paused',
        ContainerStatus.restarting => 'Restarting',
        ContainerStatus.removing => 'Removing',
        ContainerStatus.exited => 'Exited',
        ContainerStatus.dead => 'Dead',
        ContainerStatus.stopped => 'Stopped',
      };
}

/// JSON converter for [ContainerStatus].
class ContainerStatusConverter
    extends JsonConverter<ContainerStatus, String> {
  /// Creates a [ContainerStatusConverter].
  const ContainerStatusConverter();

  @override
  ContainerStatus fromJson(String json) => ContainerStatus.fromJson(json);

  @override
  String toJson(ContainerStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// HealthStatus
// ─────────────────────────────────────────────────────────────────────────────

/// Health check result status for a container.
enum HealthStatus {
  /// Container health check passed.
  healthy,

  /// Container health check failed.
  unhealthy,

  /// Container health check is starting up.
  starting,

  /// No health check configured.
  none;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        HealthStatus.healthy => 'HEALTHY',
        HealthStatus.unhealthy => 'UNHEALTHY',
        HealthStatus.starting => 'STARTING',
        HealthStatus.none => 'NONE',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static HealthStatus fromJson(String json) => switch (json) {
        'HEALTHY' => HealthStatus.healthy,
        'UNHEALTHY' => HealthStatus.unhealthy,
        'STARTING' => HealthStatus.starting,
        'NONE' => HealthStatus.none,
        _ => throw ArgumentError('Unknown HealthStatus: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        HealthStatus.healthy => 'Healthy',
        HealthStatus.unhealthy => 'Unhealthy',
        HealthStatus.starting => 'Starting',
        HealthStatus.none => 'None',
      };
}

/// JSON converter for [HealthStatus].
class HealthStatusConverter extends JsonConverter<HealthStatus, String> {
  /// Creates a [HealthStatusConverter].
  const HealthStatusConverter();

  @override
  HealthStatus fromJson(String json) => HealthStatus.fromJson(json);

  @override
  String toJson(HealthStatus object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// RestartPolicy
// ─────────────────────────────────────────────────────────────────────────────

/// Docker restart policy for a container.
enum RestartPolicy {
  /// Never restart automatically.
  no,

  /// Always restart regardless of exit code.
  always,

  /// Restart only on non-zero exit code.
  onFailure,

  /// Restart unless explicitly stopped.
  unlessStopped;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        RestartPolicy.no => 'NO',
        RestartPolicy.always => 'ALWAYS',
        RestartPolicy.onFailure => 'ON_FAILURE',
        RestartPolicy.unlessStopped => 'UNLESS_STOPPED',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static RestartPolicy fromJson(String json) => switch (json) {
        'NO' => RestartPolicy.no,
        'ALWAYS' => RestartPolicy.always,
        'ON_FAILURE' => RestartPolicy.onFailure,
        'UNLESS_STOPPED' => RestartPolicy.unlessStopped,
        _ => throw ArgumentError('Unknown RestartPolicy: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        RestartPolicy.no => 'No',
        RestartPolicy.always => 'Always',
        RestartPolicy.onFailure => 'On Failure',
        RestartPolicy.unlessStopped => 'Unless Stopped',
      };
}

/// JSON converter for [RestartPolicy].
class RestartPolicyConverter extends JsonConverter<RestartPolicy, String> {
  /// Creates a [RestartPolicyConverter].
  const RestartPolicyConverter();

  @override
  RestartPolicy fromJson(String json) => RestartPolicy.fromJson(json);

  @override
  String toJson(RestartPolicy object) => object.toJson();
}

// ─────────────────────────────────────────────────────────────────────────────
// DeploymentAction
// ─────────────────────────────────────────────────────────────────────────────

/// Type of deployment lifecycle action.
enum DeploymentAction {
  /// Start a container or solution.
  start,

  /// Stop a container or solution.
  stop,

  /// Restart a container or solution.
  restart,

  /// Destroy a container or solution.
  destroy,

  /// Scale up (add instances).
  scaleUp,

  /// Scale down (remove instances).
  scaleDown;

  /// Serializes to the server's SCREAMING_SNAKE_CASE representation.
  String toJson() => switch (this) {
        DeploymentAction.start => 'START',
        DeploymentAction.stop => 'STOP',
        DeploymentAction.restart => 'RESTART',
        DeploymentAction.destroy => 'DESTROY',
        DeploymentAction.scaleUp => 'SCALE_UP',
        DeploymentAction.scaleDown => 'SCALE_DOWN',
      };

  /// Deserializes from the server's SCREAMING_SNAKE_CASE representation.
  static DeploymentAction fromJson(String json) => switch (json) {
        'START' => DeploymentAction.start,
        'STOP' => DeploymentAction.stop,
        'RESTART' => DeploymentAction.restart,
        'DESTROY' => DeploymentAction.destroy,
        'SCALE_UP' => DeploymentAction.scaleUp,
        'SCALE_DOWN' => DeploymentAction.scaleDown,
        _ => throw ArgumentError('Unknown DeploymentAction: $json'),
      };

  /// Human-readable display label.
  String get displayName => switch (this) {
        DeploymentAction.start => 'Start',
        DeploymentAction.stop => 'Stop',
        DeploymentAction.restart => 'Restart',
        DeploymentAction.destroy => 'Destroy',
        DeploymentAction.scaleUp => 'Scale Up',
        DeploymentAction.scaleDown => 'Scale Down',
      };
}

/// JSON converter for [DeploymentAction].
class DeploymentActionConverter
    extends JsonConverter<DeploymentAction, String> {
  /// Creates a [DeploymentActionConverter].
  const DeploymentActionConverter();

  @override
  DeploymentAction fromJson(String json) => DeploymentAction.fromJson(json);

  @override
  String toJson(DeploymentAction object) => object.toJson();
}
