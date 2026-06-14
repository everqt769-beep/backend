import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:developer' as developer;

import '../../models/adjunto.dart';
import '../../core/constants/app_colors.dart';

class AdjuntosWidget extends StatefulWidget {
  final List<Adjunto> adjuntos;
  const AdjuntosWidget({super.key, required this.adjuntos});

  @override
  State<AdjuntosWidget> createState() => _AdjuntosWidgetState();
}

class _AdjuntosWidgetState extends State<AdjuntosWidget> {
  @override
  void didUpdateWidget(covariant AdjuntosWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adjuntos.isNotEmpty) {
      _logAdjuntos();
    }
  }

  void _logAdjuntos() {
    developer.log(
      '========== ADJUNTOS WIDGET ==========',
      name: 'AdjuntosWidget',
    );
    developer.log(
      'TOTAL ADJUNTOS: ${widget.adjuntos.length}',
      name: 'AdjuntosWidget',
    );
    for (var adjunto in widget.adjuntos) {
      developer.log('------------------------------', name: 'AdjuntosWidget');
      developer.log('ID: ${adjunto.idAdjunto}', name: 'AdjuntosWidget');
      developer.log('URL: ${adjunto.url}', name: 'AdjuntosWidget');
      developer.log('TIPO: ${adjunto.tipo}', name: 'AdjuntosWidget');
      developer.log('NOMBRE: ${adjunto.nombreArchivo}', name: 'AdjuntosWidget');
      developer.log('ES IMAGEN: ${adjunto.esImagen}', name: 'AdjuntosWidget');
      developer.log('ES VIDEO: ${adjunto.esVideo}', name: 'AdjuntosWidget');
    }
    developer.log(
      '====================================',
      name: 'AdjuntosWidget',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.adjuntos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Archivos Adjuntos',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.adjuntos.length,
            itemBuilder: (context, index) {
              final adjunto = widget.adjuntos[index];
              return GestureDetector(
                onTap: () => _mostrarVisor(context, adjunto),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.surfaceLight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: adjunto.esImagen
                        ? Image.network(adjunto.url, fit: BoxFit.cover)
                        : _VideoThumbnail(adjunto: adjunto),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _mostrarVisor(BuildContext context, Adjunto adjunto) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(10),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              adjunto.esImagen
                  ? PhotoView(imageProvider: NetworkImage(adjunto.url))
                  : _VisorVideo(url: adjunto.url),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VideoThumbnail extends StatelessWidget {
  final Adjunto adjunto;
  const _VideoThumbnail({required this.adjunto});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: Colors.black87),
        const Center(
          child: Icon(Icons.play_circle_outline, color: Colors.white, size: 50),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          right: 8,
          child: Text(
            adjunto.nombreArchivo ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 10),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _VisorVideo extends StatefulWidget {
  final String url;
  const _VisorVideo({required this.url});

  @override
  __VisorVideoState createState() => __VisorVideoState();
}

class __VisorVideoState extends State<_VisorVideo> {
  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.url);
    _chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: false,
      showControlsOnInitialize: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    _videoController.initialize().then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Chewie(controller: _chewieController);
  }
}
