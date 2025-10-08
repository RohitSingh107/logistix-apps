/// base_repository.dart - Base Repository Interface
/// 
/// Purpose:
/// - Defines common repository interface for CRUD operations
/// - Provides consistent data access patterns across all repositories
/// - Enforces standard repository method signatures
/// 
/// Key Logic:
/// - Generic interface that can be extended by specific repositories
/// - Defines standard CRUD operations (getAll, getById, create, update, delete)
/// - Returns Futures for asynchronous data operations
/// - Provides nullable getById for handling missing records
/// - Serves as contract for repository implementations
library;

abstract class BaseRepository<T> {
  Future<List<T>> getAll();
  Future<T?> getById(String id);
  Future<T> create(T item);
  Future<T> update(T item);
  Future<void> delete(String id);
} 