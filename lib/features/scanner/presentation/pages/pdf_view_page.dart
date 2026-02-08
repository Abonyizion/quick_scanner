import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/routing/app_route.dart';
import '../../../../core/utils/download_helper.dart';
import '../bloc/camera/scan_session_bloc.dart';
import '../widgets/app_button.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/file_name_dialog.dart';

class PDFViewPage extends StatefulWidget {
  final String pdfPath;

  const PDFViewPage({
    super.key,
    required this.pdfPath,
  });

  @override
  State<PDFViewPage> createState() => _PDFViewPageState();
}

class _PDFViewPageState extends State<PDFViewPage> {
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isLoading = true;


  @override
  Widget build(BuildContext context) {
    final file = File(widget.pdfPath);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('PDF File',
          style: TextStyle(
              fontSize: 16
          ),),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () async {
                // Show dialog to get filename
                final fileName = await FileNameDialog.show(context);

                if (fileName != null && context.mounted) {
                  final savedFile = await DownloadHelper.savePdf(
                    context: context,
                    file: file,
                    fileName: fileName,
                  );

                  if (savedFile != null && context.mounted) {
                    AppSnackBar.success(context, 'Saved to Downloads');
                  } else if (context.mounted) {
                    AppSnackBar.error(context, 'Failed to save PDF');
                  }
                }
              },
            ),
          ),


        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: PDFView(
                      filePath: widget.pdfPath,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: true,
                      pageSnap: true,
                      pageFling: true,
                      onRender: (pages) {
                        if (!mounted) return;
                        setState(() {
                          _totalPages = pages ?? 0;
                          _isLoading = false;
                        });
                      },
                      onPageChanged: (page, _) {
                        if (!mounted) return;
                        setState(() {
                          _currentPage = page ?? 0;
                        });
                      },
                      onError: (error) {
                        debugPrint(error.toString());
                      },
                    ),
                  ),
                ),
              ),

              if (_totalPages > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    'Page ${_currentPage + 1} of $_totalPages',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Done',
                        icon: Icons.check,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        foregroundColor: theme.colorScheme.onSurface,
                        onPressed: () {
                          // Clear the scan session before going back
                          context.read<ScanSessionBloc>().add(ClearScanSessionEvent());
                          context.go(AppRoutes.scanPage);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: 'Share',
                        icon: Icons.share,
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        onPressed: () async {
                          await Share.shareXFiles(
                            [XFile(file.path)],
                            text: 'Scanned with QuickScan PDF',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_isLoading)
            Container(
              color: theme.scaffoldBackgroundColor.withOpacity(0.6),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}