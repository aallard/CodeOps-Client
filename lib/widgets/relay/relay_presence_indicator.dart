/// Presence status indicator dot for the Relay module.
///
/// Displays a small colored circle representing a user's online
/// status: green for ONLINE, amber for AWAY, red for DND, and
/// grey for OFFLINE.
library;

import 'package:flutter/material.dart';

import '../../models/relay_enums.dart';

/// A small colored dot indicating a user's presence status.
///
/// Used in DM list tiles and channel member lists to provide
/// at-a-glance availability information.
class RelayPresenceIndicator extends StatelessWidget {
  /// The presence status to display.
  final PresenceStatus status;

  /// Diameter of the dot in logical pixels. Defaults to 8.
  final double size;

  /// Creates a [RelayPresenceIndicator].
  const RelayPresenceIndicator({
    required this.status,
    this.size = 8,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colorForStatus(status),
        shape: BoxShape.circle,
      ),
    );
  }

  /// Returns the dot color for a given [PresenceStatus].
  static Color colorForStatus(PresenceStatus status) {
    return switch (status) {
      PresenceStatus.online => Colors.green,
      PresenceStatus.away => Colors.amber,
      PresenceStatus.dnd => Colors.red,
      PresenceStatus.offline => Colors.grey,
    };
  }
}
