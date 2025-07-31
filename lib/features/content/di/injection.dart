import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:pocket_plus/core/network/network_info.dart';
import 'package:pocket_plus/core/auth/user_session_manager.dart'; // Importa UserSessionManager
import 'package:pocket_plus/features/content/data/datasources/content_remote_data_source.dart';
import 'package:pocket_plus/features/content/data/repositories/content_repository_impl.dart';
import 'package:pocket_plus/features/content/domain/repositories/content_repository.dart';
import 'package:pocket_plus/features/content/domain/usecases/add_content_item.dart';
import 'package:pocket_plus/features/content/domain/usecases/create_tag.dart';
import 'package:pocket_plus/features/content/domain/usecases/delete_content_item.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_all_content_items.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_content_item_by_id.dart';
import 'package:pocket_plus/features/content/domain/usecases/get_user_tags.dart';
import 'package:pocket_plus/features/content/domain/usecases/update_content_item.dart';
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para inyectar a ContentCubit
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart';
import 'package:pocket_plus/features/content/presentation/cubit/add_content_cubit.dart';

void initContentFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<ContentRemoteDataSource>(
    () => ContentRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  // Repository
  sl.registerLazySingleton<ContentRepository>(
    () => ContentRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl<NetworkInfo>(),
      sessionManager: sl<UserSessionManager>(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllContentItems(sl()));
  sl.registerLazySingleton(() => GetContentItemById(sl()));
  sl.registerLazySingleton(() => AddContentItem(sl()));
  sl.registerLazySingleton(() => UpdateContentItem(sl()));
  sl.registerLazySingleton(() => DeleteContentItem(sl()));
  sl.registerLazySingleton(() => GetUserTags(sl()));
  sl.registerLazySingleton(() => CreateTag(sl()));

  // Cubit
  sl.registerLazySingleton(
    // Singleton porque queremos que mantenga su estado entre pantallas del feature
    () => ContentCubit(
      getAllContentItemsUseCase: sl(),
      getContentItemByIdUseCase: sl(),
      addContentItemUseCase: sl(),
      updateContentItemUseCase: sl(),
      deleteContentItemUseCase: sl(),
      getUserTagsUseCase: sl(),
      createTagUseCase: sl(),
      authCubit: sl<AuthCubit>(), // Inyectar el AuthCubit
    ),
  );

  sl.registerFactoryParam<AddContentCubit, String?, void>(
    (itemIdToEdit, _) => AddContentCubit(
      contentCubit: sl<ContentCubit>(),
      getUserTagsUseCase: sl(), // Add this line
      itemIdToEdit: itemIdToEdit,
    ),
  );
}
