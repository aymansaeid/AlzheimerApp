import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/care_network_bloc.dart';
import '../bloc/care_network_event.dart';
import '../bloc/care_network_state.dart';
import '../widgets/patient_section_card.dart';
import '../../../caregiver/presentation/bloc/dashboard_bloc.dart';
import 'package:mobile/features/medication/presentation/bloc/medication_bloc.dart';
import 'package:mobile/features/medication/presentation/bloc/medication_event.dart';


class CareNetworkScreen extends StatelessWidget {
  const CareNetworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<CareNetworkBloc>()..add(FetchCareNetwork()),
      child: const CareNetworkView(),
    );
  }
}

class CareNetworkView extends StatelessWidget {
  const CareNetworkView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = context.read<AuthBloc>().state;
    final String? currentUserId = authState is AuthAuthenticated
        ? authState.user.id
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bağlantılar Ağı'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_link),
            tooltip: 'Yeni Hastaya Bağlan',
            onPressed: () => _showJoinPatientDialog(context, context.read<CareNetworkBloc>()),
          ),
        ],
      ),
      body: BlocListener<CareNetworkBloc, CareNetworkState>(
        listener: (context, state) {
          if (state is CareNetworkActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            // Sync DashboardBloc to reload the followed patients list
            context.read<DashboardBloc>().add(const LoadDashboard(null));
          } else if (state is CareNetworkJoinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Yeni hastaya başarıyla bağlandınız.'),
                backgroundColor: Colors.green,
              ),
            );
            // Sync DashboardBloc to reload the followed patients list
            context.read<DashboardBloc>().add(const LoadDashboard(null));
          } else if (state is CareNetworkEmpty) {
            context.read<DashboardBloc>().add(ResetDashboard());
            context.read<MedicationBloc>().add(ResetMedications());
            context.goNamed('caregiver_setup');
          }
        },
        child: BlocBuilder<CareNetworkBloc, CareNetworkState>(
          builder: (context, state) {
            if (state is CareNetworkLoading || state is CareNetworkInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CareNetworkError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Hata: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<CareNetworkBloc>().add(FetchCareNetwork());
                      },
                      child: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            } else if (state is CareNetworkLoaded) {
              if (state.patients.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'Takip ettiğiniz herhangi bir hasta bulunmamaktadır.',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<CareNetworkBloc>().add(FetchCareNetwork());
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: state.patients.length,
                  itemBuilder: (context, index) {
                    final patient = state.patients[index];
                    final team = state.patientTeams[patient.patientId] ?? [];
                    final isAdmin = state.isAdminForPatient[patient.patientId] ?? false;

                    return PatientSectionCard(
                      patient: patient,
                      team: team,
                      isAdmin: isAdmin,
                      currentUserId: currentUserId,
                      onInvitePressed: () => _showInviteDialog(
                        context,
                        patient.patientId,
                        context.read<CareNetworkBloc>(),
                      ),
                      onLeavePressed: () => _showLeaveConfirmDialog(
                        context,
                        patient.patientId,
                        patient.fullName,
                      ),
                      onRemoveMemberPressed: (member) => _showRemoveConfirmDialog(
                        context,
                        patient.patientId,
                        member.id,
                        member.fullName,
                      ),
                      onMemberTapped: (member) {
                        context.pushNamed(
                          'user_detail',
                          pathParameters: {'id': member.id},
                          extra: context.read<CareNetworkBloc>(),
                        );
                      },
                    );
                  },
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  void _showInviteDialog(
    BuildContext context,
    String patientId,
    CareNetworkBloc bloc,
  ) {
    bloc.add(ClearGeneratedInvite());
    bloc.add(GenerateInviteClicked(patientId));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: bloc,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: BlocBuilder<CareNetworkBloc, CareNetworkState>(
                builder: (context, state) {
                  if (state is CareNetworkLoaded) {
                    if (state.isGeneratingCode) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          const Text(
                            'Davet kodu oluşturuluyor...',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    } else if (state.generatedCode != null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Aile Üyesi Daveti',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bu 6 haneli davet kodunu kopyalayıp davet etmek istediğiniz aile üyesiyle paylaşın.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                state.generatedCode!,
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 4,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Kapat'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(text: state.generatedCode!),
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Davet kodu kopyalandı!'),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.copy),
                                  label: const Text('Kopyala'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }
                  } else if (state is CareNetworkError) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          'Hata oluştu: ${state.message}',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Kapat'),
                        ),
                      ],
                    );
                  }

                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLeaveConfirmDialog(BuildContext context, String patientId, String patientName) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Takımdan Ayrıl'),
          content: Text('$patientName adlı hastanın takip ekibinden ayrılmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<CareNetworkBloc>().add(LeaveTeamClicked(patientId));
              },
              child: const Text('Evet, Ayrıl'),
            ),
          ],
        );
      },
    );
  }

  void _showRemoveConfirmDialog(
    BuildContext context,
    String patientId,
    String followerId,
    String followerName,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Kişiyi Çıkar'),
          content: Text('$followerName adlı üyeyi takip ekibinden çıkarmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<CareNetworkBloc>().add(
                  RemoveMemberClicked(
                    patientId: patientId,
                    followerId: followerId,
                  ),
                );
              },
              child: const Text('Evet, Çıkar'),
            ),
          ],
        );
      },
    );
  }

  void _showJoinPatientDialog(BuildContext context, CareNetworkBloc bloc) {
    final formKey = GlobalKey<FormState>();
    final codeController = TextEditingController();
    String selectedRelationship = 'Oğlu';

    final List<String> relationships = [
      'Oğlu',
      'Kızı',
      'Eşi',
      'Kardeşi',
      'Torunu',
      'Bakıcısı',
      'Hemşiresi',
      'Doktoru',
      'Diğer',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final theme = Theme.of(context);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text('Yeni Hastaya Bağlan'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Hastanın oluşturduğu 6 haneli davet kodunu girerek onun takip ekibine katılın.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: codeController,
                        maxLength: 6,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                          color: theme.colorScheme.primary,
                        ),
                        textAlign: TextAlign.center,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          TextInputFormatter.withFunction(
                            (oldVal, newVal) =>
                                newVal.copyWith(text: newVal.text.toUpperCase()),
                          ),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Davet Kodu',
                          counterText: '',
                          prefixIcon: const Icon(Icons.vpn_key),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().length != 6) {
                            return 'Lütfen 6 haneli davet kodunu girin';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: selectedRelationship,
                        items: relationships.map((relation) {
                          return DropdownMenuItem<String>(
                            value: relation,
                            child: Text(relation),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              selectedRelationship = val;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Yakınlık Derecesi',
                          prefixIcon: const Icon(Icons.people),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('İptal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext);
                      bloc.add(AcceptInviteClicked(
                        inviteCode: codeController.text.trim(),
                        relationship: selectedRelationship,
                      ));
                    }
                  },
                  child: const Text('Bağlan'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
