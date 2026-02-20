import 'package:flutter/material.dart';

class Videos {
  final String idVideo;
  final String videoName;
  final String category;
  final String level;
  final String description;
  final String credits;
  final String videoFile;
  final String status;
  final String createdAt;
  final String updatedAt;

  Videos({
    required this.idVideo,
    required this.videoName,
    required this.category,
    required this.level,
    required this.description,
    required this.credits,
    required this.videoFile,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert JSON to Videos object with null safety
  factory Videos.fromJson(Map<String, dynamic> json) {
    return Videos(
      idVideo: json['id_video']?.toString() ?? '',  
      videoName: json['video_name']?.toString() ?? 'Untitled',
      category: json['category']?.toString() ?? 'Unknown',
      level: json['level']?.toString() ?? 'BEGINNER', // Default to 'BEGINNER' if null
      description: json['description']?.toString() ?? 'No description available',
      credits: json['credits']?.toString() ?? '0',  
      videoFile: json['video_file']?.toString() ?? '',  
      status: json['status']?.toString() ?? 'Inactive',  
      createdAt: json['created_at']?.toString() ?? '',  
      updatedAt: json['updated_at']?.toString() ?? '',  
    );
  }

  // Convert Videos object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id_video': idVideo,
      'video_name': videoName,
      'category': category,
      'level': level,
      'description': description,
      'credits': credits,
      'video_file': videoFile,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
