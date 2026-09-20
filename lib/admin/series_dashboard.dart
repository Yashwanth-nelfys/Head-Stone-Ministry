import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/messages_data.dart';
import '../services/message_service.dart';
import 'add_edit_series.dart';

class SeriesDashboard extends StatefulWidget {
  const SeriesDashboard({super.key});

  @override
  State<SeriesDashboard> createState() => _SeriesDashboardState();
}

class _SeriesDashboardState extends State<SeriesDashboard> {
  List<SeriesModel> _series = [];

  String _searchQuery = '';

  bool _loading = true;

  StreamSubscription<List<SeriesModel>>? _subscription;

  @override
  void initState() {
    super.initState();

    _listenToSeries();
  }

  void _listenToSeries() {
    _subscription = MessageService.instance.seriesStream().listen(
      (series) {
        if (!mounted) {
          return;
        }

        setState(() {
          _series = series;
          _loading = false;
        });
      },
      onError: (error) {
        debugPrint('Series stream error: $error');

        if (!mounted) {
          return;
        }

        setState(() {
          _loading = false;
        });

        Get.snackbar(
          'Error',
          'Unable to load series.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
        );
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();

    super.dispose();
  }

  List<SeriesModel> get _filteredSeries {
    if (_searchQuery.trim().isEmpty) {
      return _series;
    }

    final query = _searchQuery.toLowerCase().trim();

    return _series.where((series) {
      return series.seriesTitle.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _addSeries() async {
    await Get.to<SeriesModel>(() => const AddEditSeries());
  }

  Future<void> _editSeries(SeriesModel series) async {
    await Get.to<SeriesModel>(() => AddEditSeries(series: series));
  }

  Future<void> _deleteSeries(SeriesModel series) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text(
          'Delete Series?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to delete "${series.seriesTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await MessageService.instance.deleteSeries(series);

      Get.snackbar(
        'Deleted',
        'Series removed successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e, stackTrace) {
      debugPrint('Delete series error: $e');
      debugPrint('$stackTrace');

      Get.snackbar(
        'Error',
        'Unable to delete series.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredSeries = _filteredSeries;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF171717),
        title: const Text(
          'Series',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addSeries,
        backgroundColor: const Color(0xFF3157D5),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Series',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_series.length} Series',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  'Manage your message series.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 16),

                TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search series...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    filled: true,
                    fillColor: const Color(0xFFF5F6FA),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF3157D5)),
                  )
                : filteredSeries.isEmpty
                ? _emptyState()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: filteredSeries.length,
                    itemBuilder: (context, index) {
                      return _seriesCard(filteredSeries[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFEFF2FF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_collection_outlined,
              size: 34,
              color: Color(0xFF3157D5),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'No series found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            'Try another search or add a new series.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _seriesCard(SeriesModel series) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _seriesImage(series),

            const SizedBox(width: 13),

            Expanded(
              child: Text(
                series.seriesTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 8),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _editSeries(series);
                } else if (value == 'delete') {
                  _deleteSeries(series);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red),
                      SizedBox(width: 10),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _seriesImage(SeriesModel series) {
    if (series.seriesImage.trim().isEmpty) {
      return _imagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        series.seriesImage,
        width: 70,
        height: 70,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _imagePlaceholder();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return _imagePlaceholder(loading: true);
        },
      ),
    );
  }

  Widget _imagePlaceholder({bool loading = false}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: loading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF3157D5),
                ),
              ),
            )
          : const Icon(
              Icons.video_collection_outlined,
              color: Color(0xFF3157D5),
              size: 30,
            ),
    );
  }
}
