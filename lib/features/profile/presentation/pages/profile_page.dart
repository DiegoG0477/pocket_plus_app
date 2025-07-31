import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:pocket_plus/core/router/app_routes.dart'; // Para navegación post-logout
import 'package:pocket_plus/features/auth/presentation/cubit/auth_cubit.dart'; // Para el tipo de usuario
import 'package:pocket_plus/features/auth/domain/entities/user.dart'; // Importa la entidad User
import 'package:pocket_plus/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:pocket_plus/features/profile/presentation/widgets/statistic_item.dart';
import 'package:get_it/get_it.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ProfileCubit>()..loadUserProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  // TODO: Manejar estado de los switches de preferencias
  bool _notificationsEnabled = false; // Placeholder
  bool _darkModeEnabled = false; // Placeholder

  Widget _buildProfileHeader(BuildContext context, User user) {
    final theme = Theme.of(context);
    final Color headerColor =
        theme.colorScheme.primary; // Reutilizar color de Overview

    String initials = "U";
    if (user.nombre.isNotEmpty) {
      final names = user.nombre.split(' ');
      initials = names.first.substring(0, 1).toUpperCase();
      if (names.length > 1) {
        initials += names.last.substring(0, 1).toUpperCase();
      } else if (names.first.length > 1) {
        initials = names.first.substring(0, 2).toUpperCase();
      }
    }

    ImageProvider? avatarImage;
    if (user.fotoPerfil != null) {
      try {
        avatarImage = CachedNetworkImageProvider(user.fotoPerfil!);
      } catch (e) {
        print('Error loading profile image: $e');
        avatarImage = null;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      color: headerColor,
      child: Column(
        children: [
          CircleAvatar(
            radius: 45,
            backgroundColor: Colors.white.withOpacity(0.3),
            backgroundImage:
                avatarImage, // Use the safely created ImageProvider
            child: avatarImage == null
                ? Text(
                    initials,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            user.nombre,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // AppBar no es necesario según el maquetado, el header lo reemplaza
      // appBar: AppBar(title: const Text('Perfil')),
      backgroundColor:
          theme.colorScheme.background, // O un gris claro theme.canvasColor
      body: BlocListener<AuthCubit, AuthState>(
        // Escuchar a AuthCubit para redirección post-logout
        listener: (context, authState) {
          if (authState is! AuthSuccess) {
            // Si ya no está logueado
            context.go(AppRoutes.overview); // O login
          }
        },
        child: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ProfileLoaded) {
              final user = state.user;
              final stats = state.statistics;

              // Calculando pendientes para la estadística del maquetado
              // Total - (Completados + Descartados) = Pendientes (aproximado si hay otros estados)
              // Mejor usar los datos de ContentCubit si es posible, o ajustar UserStatistics
              // Por ahora, asumamos que UserStatistics ya tiene el dato de "pendientes"
              // Si no, lo calculamos:
              int pendientes =
                  stats.totalItemsSaved -
                  (stats.itemsCompleted + stats.itemsDiscarded);

              return ListView(
                // Usar ListView en lugar de SingleChildScrollView para el efecto del header
                padding:
                    EdgeInsets.zero, // Quitar padding por defecto de ListView
                children: [
                  _buildProfileHeader(context, user),
                  const SizedBox(
                    height: 8,
                  ), // Espacio entre header y primera card

                  _buildSectionCard(
                    context: context,
                    title: 'Estadísticas',
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          StatisticItem(
                            icon: Icons.bookmark_border,
                            iconColor: theme.colorScheme.primary,
                            value: stats.totalItemsSaved.toString(),
                            label: 'Guardados',
                          ),
                          StatisticItem(
                            icon: Icons.hourglass_empty_outlined,
                            iconColor: Colors.orange.shade600,
                            value: pendientes
                                .toString(), // Asumiendo que 'pendientes' está en UserStatistics o se calcula
                            label: 'Pendientes',
                          ),
                          StatisticItem(
                            icon: Icons.check_circle_outline,
                            iconColor: Colors.green.shade600,
                            value: stats.itemsCompleted.toString(),
                            label: 'Completados',
                          ),
                        ],
                      ),
                      // TODO: Añadir "Porcentaje de contenido multimedia vs físico" y "Lista de tus tags más usados"
                      // Esto podría requerir más espacio o un diseño diferente para las estadísticas.
                    ],
                  ),

                  _buildSectionCard(
                    context: context,
                    title: 'Preferencias',
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Notificaciones',
                          style: theme.textTheme.titleMedium,
                        ),
                        trailing: Switch(
                          value: _notificationsEnabled,
                          onChanged: (value) {
                            setState(() => _notificationsEnabled = value);
                            // context.read<ProfileCubit>().toggleNotifications(value); // TODO
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Preferencias de notificación (TODO)',
                                ),
                              ),
                            );
                          },
                          activeColor: theme.colorScheme.primary, // Amarillo
                        ),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Tema oscuro',
                          style: theme.textTheme.titleMedium,
                        ),
                        trailing: Switch(
                          value: _darkModeEnabled,
                          onChanged: (value) {
                            setState(() => _darkModeEnabled = value);
                            // context.read<ProfileCubit>().toggleDarkMode(value); // TODO
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cambio de tema (TODO)'),
                              ),
                            );
                          },
                          activeColor: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  _buildSectionCard(
                    context: context,
                    title:
                        'Cuenta', // O 'Configuración' si solo tiene esa opción
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.settings_outlined,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                        title: Text(
                          'Configuración',
                          style: theme.textTheme.titleMedium,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navegar a una pantalla de configuración si existe
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pantalla de configuración (TODO)'),
                            ),
                          );
                        },
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.logout,
                          color: theme.colorScheme.error,
                        ),
                        title: Text(
                          'Cerrar sesión',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Cerrar Sesión'),
                              content: const Text(
                                '¿Estás seguro de que deseas cerrar sesión?',
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('Cancelar'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                                TextButton(
                                  child: Text(
                                    'Cerrar Sesión',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                    context.read<ProfileCubit>().logout();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ), // Espacio al final antes de la BottomNav (si la hubiera)
                ],
              );
            } else if (state is ProfileFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: TextStyle(color: Colors.red[700]),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () =>
                          context.read<ProfileCubit>().loadUserProfile(),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
