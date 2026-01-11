// Redesigned PhotoCard preserving all original logic
// Focus: cleaner layout, softer shadows, modern Material 3 look

import 'dart:convert';
import 'package:flutter/material.dart';

class PhotoCard extends StatelessWidget {
  final String photoId;
  final Map<String, dynamic> photoData;
  final bool isOwner;
  final String currentUserId;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onShare;
  final VoidCallback onComment;
  final VoidCallback onEditDescription;

  const PhotoCard({
    super.key,
    required this.photoId,
    required this.photoData,
    required this.isOwner,
    required this.currentUserId,
    required this.onDelete,
    required this.onLike,
    required this.onShare,
    required this.onComment,
    required this.onEditDescription,
  });

  @override
  Widget build(BuildContext context) {
    final imageData = photoData['imageData'] as String?;
    final descricao = photoData['descricao'] as String? ?? '';
    final likes = List<String>.from(photoData['likes'] ?? []);
    final comentarios = List.from(photoData['comentarios'] ?? []);
    final isLiked = likes.contains(currentUserId);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: GestureDetector(
                onLongPress: isOwner ? onEditDescription : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageData != null
                        ? Image.memory(
                            base64Decode(imageData),
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, size: 50),
                          ),

                    // gradient + text label
                    if (descricao.isNotEmpty)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Text(
                            descricao,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Like
                  Row(
                    children: [
                      IconButton(
                        onPressed: onLike,
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 22,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text('${likes.length}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),

                  // Comment
                  Row(
                    children: [
                      IconButton(
                        onPressed: onComment,
                        icon: const Icon(Icons.mode_comment_rounded, size: 22),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Text('${comentarios.length}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),

                  // Share + Delete (owner only)
                  if (isOwner)
                    Row(
                      children: [
                        IconButton(
                          onPressed: onShare,
                          icon: const Icon(Icons.ios_share, size: 20),
                          color: Colors.blueAccent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.redAccent,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
