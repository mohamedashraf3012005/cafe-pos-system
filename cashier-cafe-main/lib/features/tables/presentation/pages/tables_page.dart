import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../injection_container.dart' as di;
import '../cubit/tables_cubit.dart';
import '../cubit/tables_state.dart';
import '../../../orders/presentation/pages/order_details_page.dart';

class TablesPage extends StatefulWidget {
  const TablesPage({super.key});

  @override
  State<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends State<TablesPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => di.sl<TablesCubit>()..loadTables(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إدارة الطاولات'),
        ),
        floatingActionButton: Builder(
          builder: (innerContext) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton(
                heroTag: 'remove',
                onPressed: () {
                  innerContext.read<TablesCubit>().removeLatestTable();
                },
                backgroundColor: AppColors.error,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(width: 16),
              FloatingActionButton(
                heroTag: 'add',
                onPressed: () {
                  innerContext.read<TablesCubit>().addTable();
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TablesCubit, TablesState>(
            builder: (context, state) {
              if (state is TablesLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TablesError) {
                return Center(child: Text('خطأ: ${state.message}', style: const TextStyle(color: AppColors.error)));
              } else if (state is TablesLoaded) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: state.tables.length,
                  itemBuilder: (context, index) {
                    final table = state.tables[index];
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderDetailsPage(
                              tableId: table.id,
                              tableNumber: table.tableNumber,
                            ),
                          ),
                        ).then((_) {
                           // Refresh tables state when returning from details
                           if (!context.mounted) return;
                           context.read<TablesCubit>().loadTables();
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: table.isFree ? AppColors.tableFree : AppColors.tableBusy,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, offset: Offset(2, 4), blurRadius: 4),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.table_bar, size: 48, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              'طاولة ${table.tableNumber}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              table.isFree ? 'متاح' : 'مشغول',
                              style: const TextStyle(fontSize: 14, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(child: Text('لا توجد طاولات'));
            },
          ),
        ),
      ),
    );
  }
}
