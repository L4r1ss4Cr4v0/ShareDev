import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sharedev/screens/profile_screen.dart';
import 'package:sharedev/widgets/photo_card.dart';

enum Filtro { todas, minhasFotos, compartilhadas }

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final _imagePicker = ImagePicker();
  Filtro _filtroAtual = Filtro.todas;

  String get _currentUserId => FirebaseAuth.instance.currentUser!.uid;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image == null) return;

      final descricao = await _showDescriptionDialog();
      if (descricao == null) return;

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      await FirebaseFirestore.instance.collection('fotos').add({
        'userId': _currentUserId,
        'imageData': base64Image,
        'descricao': descricao,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': [],
        'sharedWith': [],
        'comentarios': [],
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto publicada com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao publicar foto: $e')),
        );
      }
    }
  }

  Future<String?> _showDescriptionDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Adicionar descrição'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Digite uma legenda...',
            border: OutlineInputBorder(),
          ),
          maxLength: 200,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePhoto(String photoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir esta foto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('fotos')
          .doc(photoId)
          .delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto excluída com sucesso!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao excluir: $e')),
        );
      }
    }
  }

  Future<void> _toggleLike(String photoId, List<dynamic> currentLikes) async {
    try {
      if (currentLikes.contains(_currentUserId)) {
        await FirebaseFirestore.instance
            .collection('fotos')
            .doc(photoId)
            .update({
          'likes': FieldValue.arrayRemove([_currentUserId])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('fotos')
            .doc(photoId)
            .update({
          'likes': FieldValue.arrayUnion([_currentUserId])
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao curtir: $e')),
        );
      }
    }
  }

  Future<void> _sharePhoto(String photoId) async {
    final controller = TextEditingController();

    final uid = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Compartilhar Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Digite o UID do usuário:'),
            const SizedBox(height: 8),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Cole o UID aqui',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Compartilhar'),
          ),
        ],
      ),
    );

    if (uid == null || uid.isEmpty) return;

    try {
      await FirebaseFirestore.instance.collection('fotos').doc(photoId).update({
        'sharedWith': FieldValue.arrayUnion([uid])
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto compartilhada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao compartilhar: $e')),
        );
      }
    }
  }

  Future<void> _editDescription(String photoId, String currentDesc) async {
    final controller = TextEditingController(text: currentDesc);

    final newDesc = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Descrição'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          maxLength: 200,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    if (newDesc == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('fotos')
          .doc(photoId)
          .update({'descricao': newDesc});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Descrição atualizada!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar: $e')),
        );
      }
    }
  }

  void _showComments(String photoId, Map<String, dynamic> photoData) {
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final comentarios = List<Map<String, dynamic>>.from(
              photoData['comentarios'] ?? [],
            );

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Comentários',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: comentarios.isEmpty
                          ? const Center(
                              child: Text('Nenhum comentário ainda'),
                            )
                          : ListView.builder(
                              itemCount: comentarios.length,
                              itemBuilder: (context, index) {
                                final comentario = comentarios[index];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.person),
                                  ),
                                  title: Text(comentario['texto'] ?? ''),
                                  subtitle: Text(
                                    comentario['userId'] ?? 'Anônimo',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: commentController,
                            decoration: const InputDecoration(
                              hintText: 'Escreva um comentário...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: () async {
                            final texto = commentController.text.trim();
                            if (texto.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Comentário não pode ser vazio'),
                                ),
                              );
                              return;
                            }

                            try {
                              await FirebaseFirestore.instance
                                  .collection('fotos')
                                  .doc(photoId)
                                  .update({
                                'comentarios': FieldValue.arrayUnion([
                                  {
                                    'userId': _currentUserId,
                                    'texto': texto,
                                    'timestamp':
                                        DateTime.now().millisecondsSinceEpoch,
                                  }
                                ])
                              });

                              commentController.clear();
                              Navigator.pop(ctx);

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Comentário adicionado!'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Erro: $e')),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Stream<QuerySnapshot> _getPhotosStream() {
    switch (_filtroAtual) {
      case Filtro.minhasFotos:
        return FirebaseFirestore.instance
            .collection('fotos')
            .where('userId', isEqualTo: _currentUserId)
            .snapshots();

      case Filtro.compartilhadas:
        return FirebaseFirestore.instance
            .collection('fotos')
            .where('sharedWith', arrayContains: _currentUserId)
            .snapshots();

      case Filtro.todas:
        return FirebaseFirestore.instance
            .collection('fotos')
            .where('userId', isEqualTo: _currentUserId)
            .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f6fa),
      appBar: AppBar(
        title: const Text('ShareDev',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _buildChip('Todas', Filtro.todas),
                _buildChip('Minhas', Filtro.minhasFotos),
                _buildChip('Compartilhadas', Filtro.compartilhadas),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getPhotosStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhuma foto ainda.\nClique no botão abaixo!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  );
                }

                final photos = snapshot.data!.docs;

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    final data = photo.data() as Map<String, dynamic>;
                    final photoId = photo.id;
                    final isOwner = data['userId'] == _currentUserId;

                    return PhotoCard(
                      photoId: photoId,
                      photoData: data,
                      isOwner: isOwner,
                      currentUserId: _currentUserId,
                      onDelete: () => _deletePhoto(photoId),
                      onLike: () => _toggleLike(photoId, data['likes'] ?? []),
                      onShare: () => _sharePhoto(photoId),
                      onComment: () => _showComments(photoId, data),
                      onEditDescription: () => _editDescription(
                        photoId,
                        data['descricao'] ?? '',
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndUploadImage,
        backgroundColor: Colors.black,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }

  Widget _buildChip(String label, Filtro filtro) {
    final bool ativo = _filtroAtual == filtro;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: ativo,
        onSelected: (_) => setState(() => _filtroAtual = filtro),
        selectedColor: Colors.black,
        labelStyle: TextStyle(
          color: ativo ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
