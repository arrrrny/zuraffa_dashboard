import 'package:zuraffa/zuraffa.dart';

/// Typed dashboard errors (FR-003 contracts): thin subclasses of
/// Zuraffa's platform exception carrying stable wire codes, so hosts can
/// catch either the typed class or match on `code`.

/// No dashboard matches the queried id.
class DashboardNotFoundException extends ZuraffaPlatformException {
  const DashboardNotFoundException(String id)
    : super(
        code: 'dashboard_not_found',
        message: 'No dashboard with id "$id" exists.',
      );
}

/// No tile matches the queried id within the dashboard.
class TileNotFoundException extends ZuraffaPlatformException {
  const TileNotFoundException(String dashboardId, String tileId)
    : super(
        code: 'tile_not_found',
        message: 'Dashboard "$dashboardId" has no tile with id "$tileId".',
      );
}

/// The dashboard already holds a tile with the incoming id.
class DuplicateTileException extends ZuraffaPlatformException {
  const DuplicateTileException(String dashboardId, String tileId)
    : super(
        code: 'duplicate_tile',
        message: 'Dashboard "$dashboardId" already has a tile "$tileId".',
      );
}

/// A dashboard with the incoming id already exists.
class DuplicateDashboardException extends ZuraffaPlatformException {
  const DuplicateDashboardException(String id)
    : super(
        code: 'duplicate_dashboard',
        message: 'A dashboard with id "$id" already exists.',
      );
}
