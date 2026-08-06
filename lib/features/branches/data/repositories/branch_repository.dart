import '../../../../database/database_service.dart';
import '../../../audit/data/repositories/audit_repository.dart';
import '../../models/branch_model.dart';

class BranchRepository {
  BranchRepository._();

  static final BranchRepository instance = BranchRepository._();

  static const String _table = 'branches';

  final DatabaseService _database = DatabaseService.instance;

  Future<int> createBranch(BranchModel branch) async {
    final id = await _database.insert(_table, branch.toMap());

    AuditRepository.instance.logAction(
      module: 'Branches',
      action: 'Create',
      description: 'Added branch ${branch.name}',
    );

    return id;
  }

  Future<List<BranchModel>> getAllBranches() async {
    final result = await _database.rawQuery('SELECT * FROM $_table ORDER BY name');
    return result.map(BranchModel.fromMap).toList();
  }

  Future<List<BranchModel>> getActiveBranches() async {
    final result = await _database.rawQuery(
      'SELECT * FROM $_table WHERE is_active = 1 ORDER BY name',
    );
    return result.map(BranchModel.fromMap).toList();
  }

  Future<int> updateBranch(BranchModel branch) async {
    if (branch.id == null) throw Exception('Branch ID cannot be null.');

    final rows = await _database.update(_table, branch.toMap(), 'id = ?', [branch.id]);

    if (rows > 0) {
      AuditRepository.instance.logAction(
        module: 'Branches',
        action: 'Update',
        description: 'Updated branch ${branch.name}',
      );
    }

    return rows;
  }

  Future<int> deleteBranch(int id) async {
    final rows = await _database.delete(_table, 'id = ?', [id]);

    if (rows > 0) {
      AuditRepository.instance.logAction(
        module: 'Branches',
        action: 'Delete',
        description: 'Deleted branch (id: $id)',
      );
    }

    return rows;
  }
}
