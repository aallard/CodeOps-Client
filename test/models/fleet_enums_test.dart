// Tests for Fleet enum types.
//
// Verifies serialization (toJson), deserialization (fromJson),
// invalid value handling, and display names for all Fleet enums.
import 'package:flutter_test/flutter_test.dart';

import 'package:codeops/models/fleet_enums.dart';

void main() {
  // ---------------------------------------------------------------------------
  // ContainerStatus
  // ---------------------------------------------------------------------------
  group('ContainerStatus', () {
    group('toJson', () {
      test('maps created to CREATED', () {
        expect(ContainerStatus.created.toJson(), 'CREATED');
      });

      test('maps running to RUNNING', () {
        expect(ContainerStatus.running.toJson(), 'RUNNING');
      });

      test('maps paused to PAUSED', () {
        expect(ContainerStatus.paused.toJson(), 'PAUSED');
      });

      test('maps restarting to RESTARTING', () {
        expect(ContainerStatus.restarting.toJson(), 'RESTARTING');
      });

      test('maps removing to REMOVING', () {
        expect(ContainerStatus.removing.toJson(), 'REMOVING');
      });

      test('maps exited to EXITED', () {
        expect(ContainerStatus.exited.toJson(), 'EXITED');
      });

      test('maps dead to DEAD', () {
        expect(ContainerStatus.dead.toJson(), 'DEAD');
      });

      test('maps stopped to STOPPED', () {
        expect(ContainerStatus.stopped.toJson(), 'STOPPED');
      });
    });

    group('fromJson', () {
      test('maps CREATED to created', () {
        expect(ContainerStatus.fromJson('CREATED'), ContainerStatus.created);
      });

      test('maps RUNNING to running', () {
        expect(ContainerStatus.fromJson('RUNNING'), ContainerStatus.running);
      });

      test('maps PAUSED to paused', () {
        expect(ContainerStatus.fromJson('PAUSED'), ContainerStatus.paused);
      });

      test('maps RESTARTING to restarting', () {
        expect(
          ContainerStatus.fromJson('RESTARTING'),
          ContainerStatus.restarting,
        );
      });

      test('maps REMOVING to removing', () {
        expect(
          ContainerStatus.fromJson('REMOVING'),
          ContainerStatus.removing,
        );
      });

      test('maps EXITED to exited', () {
        expect(ContainerStatus.fromJson('EXITED'), ContainerStatus.exited);
      });

      test('maps DEAD to dead', () {
        expect(ContainerStatus.fromJson('DEAD'), ContainerStatus.dead);
      });

      test('maps STOPPED to stopped', () {
        expect(ContainerStatus.fromJson('STOPPED'), ContainerStatus.stopped);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => ContainerStatus.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('created returns Created', () {
        expect(ContainerStatus.created.displayName, 'Created');
      });

      test('running returns Running', () {
        expect(ContainerStatus.running.displayName, 'Running');
      });

      test('paused returns Paused', () {
        expect(ContainerStatus.paused.displayName, 'Paused');
      });

      test('restarting returns Restarting', () {
        expect(ContainerStatus.restarting.displayName, 'Restarting');
      });

      test('removing returns Removing', () {
        expect(ContainerStatus.removing.displayName, 'Removing');
      });

      test('exited returns Exited', () {
        expect(ContainerStatus.exited.displayName, 'Exited');
      });

      test('dead returns Dead', () {
        expect(ContainerStatus.dead.displayName, 'Dead');
      });

      test('stopped returns Stopped', () {
        expect(ContainerStatus.stopped.displayName, 'Stopped');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // HealthStatus
  // ---------------------------------------------------------------------------
  group('HealthStatus', () {
    group('toJson', () {
      test('maps healthy to HEALTHY', () {
        expect(HealthStatus.healthy.toJson(), 'HEALTHY');
      });

      test('maps unhealthy to UNHEALTHY', () {
        expect(HealthStatus.unhealthy.toJson(), 'UNHEALTHY');
      });

      test('maps starting to STARTING', () {
        expect(HealthStatus.starting.toJson(), 'STARTING');
      });

      test('maps none to NONE', () {
        expect(HealthStatus.none.toJson(), 'NONE');
      });
    });

    group('fromJson', () {
      test('maps HEALTHY to healthy', () {
        expect(HealthStatus.fromJson('HEALTHY'), HealthStatus.healthy);
      });

      test('maps UNHEALTHY to unhealthy', () {
        expect(HealthStatus.fromJson('UNHEALTHY'), HealthStatus.unhealthy);
      });

      test('maps STARTING to starting', () {
        expect(HealthStatus.fromJson('STARTING'), HealthStatus.starting);
      });

      test('maps NONE to none', () {
        expect(HealthStatus.fromJson('NONE'), HealthStatus.none);
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => HealthStatus.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('healthy returns Healthy', () {
        expect(HealthStatus.healthy.displayName, 'Healthy');
      });

      test('unhealthy returns Unhealthy', () {
        expect(HealthStatus.unhealthy.displayName, 'Unhealthy');
      });

      test('starting returns Starting', () {
        expect(HealthStatus.starting.displayName, 'Starting');
      });

      test('none returns None', () {
        expect(HealthStatus.none.displayName, 'None');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // RestartPolicy
  // ---------------------------------------------------------------------------
  group('RestartPolicy', () {
    group('toJson', () {
      test('maps no to NO', () {
        expect(RestartPolicy.no.toJson(), 'NO');
      });

      test('maps always to ALWAYS', () {
        expect(RestartPolicy.always.toJson(), 'ALWAYS');
      });

      test('maps onFailure to ON_FAILURE', () {
        expect(RestartPolicy.onFailure.toJson(), 'ON_FAILURE');
      });

      test('maps unlessStopped to UNLESS_STOPPED', () {
        expect(RestartPolicy.unlessStopped.toJson(), 'UNLESS_STOPPED');
      });
    });

    group('fromJson', () {
      test('maps NO to no', () {
        expect(RestartPolicy.fromJson('NO'), RestartPolicy.no);
      });

      test('maps ALWAYS to always', () {
        expect(RestartPolicy.fromJson('ALWAYS'), RestartPolicy.always);
      });

      test('maps ON_FAILURE to onFailure', () {
        expect(RestartPolicy.fromJson('ON_FAILURE'), RestartPolicy.onFailure);
      });

      test('maps UNLESS_STOPPED to unlessStopped', () {
        expect(
          RestartPolicy.fromJson('UNLESS_STOPPED'),
          RestartPolicy.unlessStopped,
        );
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => RestartPolicy.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('no returns No', () {
        expect(RestartPolicy.no.displayName, 'No');
      });

      test('always returns Always', () {
        expect(RestartPolicy.always.displayName, 'Always');
      });

      test('onFailure returns On Failure', () {
        expect(RestartPolicy.onFailure.displayName, 'On Failure');
      });

      test('unlessStopped returns Unless Stopped', () {
        expect(RestartPolicy.unlessStopped.displayName, 'Unless Stopped');
      });
    });
  });

  // ---------------------------------------------------------------------------
  // DeploymentAction
  // ---------------------------------------------------------------------------
  group('DeploymentAction', () {
    group('toJson', () {
      test('maps start to START', () {
        expect(DeploymentAction.start.toJson(), 'START');
      });

      test('maps stop to STOP', () {
        expect(DeploymentAction.stop.toJson(), 'STOP');
      });

      test('maps restart to RESTART', () {
        expect(DeploymentAction.restart.toJson(), 'RESTART');
      });

      test('maps destroy to DESTROY', () {
        expect(DeploymentAction.destroy.toJson(), 'DESTROY');
      });

      test('maps scaleUp to SCALE_UP', () {
        expect(DeploymentAction.scaleUp.toJson(), 'SCALE_UP');
      });

      test('maps scaleDown to SCALE_DOWN', () {
        expect(DeploymentAction.scaleDown.toJson(), 'SCALE_DOWN');
      });
    });

    group('fromJson', () {
      test('maps START to start', () {
        expect(DeploymentAction.fromJson('START'), DeploymentAction.start);
      });

      test('maps STOP to stop', () {
        expect(DeploymentAction.fromJson('STOP'), DeploymentAction.stop);
      });

      test('maps RESTART to restart', () {
        expect(
          DeploymentAction.fromJson('RESTART'),
          DeploymentAction.restart,
        );
      });

      test('maps DESTROY to destroy', () {
        expect(
          DeploymentAction.fromJson('DESTROY'),
          DeploymentAction.destroy,
        );
      });

      test('maps SCALE_UP to scaleUp', () {
        expect(
          DeploymentAction.fromJson('SCALE_UP'),
          DeploymentAction.scaleUp,
        );
      });

      test('maps SCALE_DOWN to scaleDown', () {
        expect(
          DeploymentAction.fromJson('SCALE_DOWN'),
          DeploymentAction.scaleDown,
        );
      });

      test('throws ArgumentError for invalid string', () {
        expect(
          () => DeploymentAction.fromJson('INVALID'),
          throwsArgumentError,
        );
      });
    });

    group('displayName', () {
      test('start returns Start', () {
        expect(DeploymentAction.start.displayName, 'Start');
      });

      test('stop returns Stop', () {
        expect(DeploymentAction.stop.displayName, 'Stop');
      });

      test('restart returns Restart', () {
        expect(DeploymentAction.restart.displayName, 'Restart');
      });

      test('destroy returns Destroy', () {
        expect(DeploymentAction.destroy.displayName, 'Destroy');
      });

      test('scaleUp returns Scale Up', () {
        expect(DeploymentAction.scaleUp.displayName, 'Scale Up');
      });

      test('scaleDown returns Scale Down', () {
        expect(DeploymentAction.scaleDown.displayName, 'Scale Down');
      });
    });
  });
}
