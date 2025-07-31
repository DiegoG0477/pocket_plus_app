import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Para CachedNetworkImageProvider
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para obtener el User
import 'package:pocket_plus/features/content/domain/entities/content_item.dart'; // Para ContentStatus y ContentPriority
import 'package:pocket_plus/features/content/presentation/cubit/content_cubit.dart';
import 'package:pocket_plus/features/content/presentation/widgets/content_card.dart';
import 'package:pocket_plus/features/content/presentation/widgets/type_filter_chips.dart'; // Importar el nuevo widget
// Importar el futuro widget de filtros
// import 'package:pocket_plus/features/content/presentation/widgets/status_filter_bar.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  TabController? _tabController; // Para los filtros de estado  @override
  void initState() {
    super.initState();
    // Inicialmente, el ContentCubit ya carga el contenido si el usuario está autenticado
    // (ver constructor de ContentCubit)
    // _tabController podría inicializarse aquí si los estados son fijos
    // O basarse en los filtros del Cubit
    _tabController = TabController(
      length: 4,
      vsync: this,
    ); // Todos, Pendientes, Completados, Descartados
    _tabController?.addListener(_handleTabSelection);

    _searchController.addListener(() {
      context.read<ContentCubit>().applyFilters(
        searchQuery: _searchController.text,
      );
    });
  }

  void _handleTabSelection() {
    if (_tabController != null && _tabController!.indexIsChanging) {
      ContentStatus? statusFilter;
      switch (_tabController!.index) {
        case 0: // Todos
          statusFilter =
              null; // O un valor especial si tu lógica de filtro lo requiere
          break;
        case 1: // Pendientes
          statusFilter = ContentStatus.pendiente;
          break;
        case 2: // Completados
          statusFilter = ContentStatus.completado;
          break;
        case 3: // Descartados
          statusFilter = ContentStatus.descartado;
          break;
      }
      context.read<ContentCubit>().applyFilters(
        statusFilter: statusFilter,
        clearStatusFilter: statusFilter == null,
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.removeListener(_handleTabSelection);
    _tabController?.dispose();
    super.dispose();
  }

  Widget _buildAvatar(BuildContext context, AuthState authState) {
    String initials = "U";
    String? imageUrl;

    if (authState is AuthSuccess) {
      final user = authState.user;
      if (user.nombre.isNotEmpty) {
        final names = user.nombre.split(' ');
        initials = names.first.substring(0, 1).toUpperCase();
        if (names.length > 1) {
          initials += names.last.substring(0, 1).toUpperCase();
        } else if (names.first.length > 1) {
          initials = names.first.substring(0, 2).toUpperCase();
        }
      }
      imageUrl = user.fotoPerfil;
    }

    ImageProvider? avatarImage;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        avatarImage = CachedNetworkImageProvider(imageUrl);
      } catch (e) {
        // Handle error if URL is malformed or other issues with image provider
        // For now, just log and fall back to initials
        print('Error loading image: $e');
        avatarImage = null;
      }
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      backgroundImage: avatarImage, // Use the safely created ImageProvider
      child: avatarImage == null
          ? Text(
              initials,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context
        .watch<AuthCubit>()
        .state; // Para el nombre y avatar

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Fixed Header (Greeting, Name, Search Bar)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '¡Hola! 👋',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                          if (authState is AuthSuccess)
                            Text(
                              authState.user.nombre.split(' ').first,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push(AppRoutes.profile),
                        child: _buildAvatar(context, authState),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar contenido...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      filled: true,
                      fillColor:
                          theme.inputDecorationTheme.fillColor ??
                          Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Scrollable Content Area
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        const TypeFilterChips(),
                        const SizedBox(height: 4),
                        TabBar(
                          controller: _tabController,
                          isScrollable: false,
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor:
                              theme.colorScheme.onSurfaceVariant,
                          indicatorColor: theme.colorScheme.primary,
                          indicatorWeight: 2.0,
                          indicatorSize: TabBarIndicatorSize.label,
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          padding: EdgeInsets.zero,
                          labelPadding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                          ),
                          tabs: const [
                            Tab(text: 'Todos'),
                            Tab(text: 'Pendientes'),
                            Tab(text: 'Completados'),
                            Tab(text: 'Descartados'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<ContentCubit, ContentState>(
                    builder: (context, state) {
                      print(
                        '🏠 Dashboard BlocBuilder - State: ${state.runtimeType}',
                      );
                      if (state is ContentLoading) {
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is ContentLoaded) {
                        if (state.filteredItems.isEmpty) {
                          return SliverFillRemaining(
                            child: Center(
                              child: Text(
                                _searchController.text.isNotEmpty ||
                                        state.activeStatusFilter != null
                                    ? 'No hay contenido que coincida con tus filtros.'
                                    : 'Aún no has guardado nada.\n¡Toca el "+" para empezar!',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }
                        return SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final item = state.filteredItems[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 4.0,
                              ),
                              child: ContentCard(
                                item: item,
                                onRefresh:
                                    _refreshDashboardContent, // Pass the callback
                              ),
                            );
                          }, childCount: state.filteredItems.length),
                        );
                      } else if (state is ContentDetailLoaded) {
                        // Si estamos en detalle pero accedimos al dashboard, volver a la lista
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          context.read<ContentCubit>().backToList();
                        });
                        return const SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state is ContentFailure) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 64,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Error: ${state.message}',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<ContentCubit>()
                                      .loadContent(),
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      // Caso por defecto para ContentInitial u otros estados
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push(AppRoutes.addContent);
          // Después de regresar de la página de añadir contenido, recargar el dashboard
          _refreshDashboardContent(); // Use the new method
        },
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: theme.colorScheme.onPrimary),
        tooltip: 'Añadir contenido',
      ),
    );
  }

  // New method to refresh content
  void _refreshDashboardContent() {
    print('DEBUG: _refreshDashboardContent called'); // Added debug print
    context.read<ContentCubit>().loadContent();
  }
}
