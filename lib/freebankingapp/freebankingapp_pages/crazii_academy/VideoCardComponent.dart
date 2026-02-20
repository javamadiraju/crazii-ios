import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';  
import 'videoapi.dart';
import 'package:get/get.dart';


class VideoCardComponent extends StatefulWidget {
  final String id;
  final String level;
  final String title;
  final String description;
  final String videoFile;
  final String category;
  const VideoCardComponent({
    Key? key,    
    this.id = "0",
    this.level = 'Beginner',
    this.title = 'Default Title',
    this.description = 'Default description.',
    this.videoFile = 'https://cgmember.com/system/writable/uploads/videos/1740493847_10bde36ee973ad6243a1.mp4',
    this.category='P',
  }) : super(key: key);

  @override
  _VideoCardComponentState createState() => _VideoCardComponentState();
}

class _VideoCardComponentState extends State<VideoCardComponent> {
  String? _thumbnailPath;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
    print('** widget video file is ${widget.videoFile}');
  }

  Future<void> _generateThumbnail() async {
    final tempDir = await getTemporaryDirectory();
    final thumbnailPath = await VideoThumbnail.thumbnailFile(
      video: widget.videoFile,
      thumbnailPath: tempDir.path,
      imageFormat: ImageFormat.PNG,
      maxHeight: 100,
      quality: 50,
    );
    print('thumbnailPath in generatetumbnail : $thumbnailPath ');
    if (mounted) {
      setState(() {
        _thumbnailPath = thumbnailPath;
      });
    }
  }

 @override
Widget build(BuildContext context) {
  // Determine background color based on the level
  Color labelColor = Colors.grey; // Default color
  if (widget.level == 'Beginner') {
    labelColor = Colors.green; // Example color for Beginner
  } else if (widget.level == 'Intermediate') {
    labelColor = Colors.blue; // Example color for Intermediate
  } else {
    labelColor = Colors.orange; // Default for other categories
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    child: Row(
      children: [
        // 50% of the width for the video thumbnail
        Expanded(
          flex: 1,
          child: InkWell(
           onTap: () async {
               print('** widget.category ${widget.category}');
             // Check if the video category is 'p'
              if (widget.category != 'P') {
                // If not 'p', simply proceed with navigating to the video
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoApp(
                      videoUrl: widget.videoFile,
                      videoId: widget.id,
                    ),
                  ),
                );
                return;  // Stop further processing
              }


             

              
              // Show a confirmation dialog before making the API call
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('confirm_purchase_title'.tr),
                    content: Text('confirm_video_purchase'.tr),
                    actions: [
                      TextButton(
                        child: Text('cancel'.tr),
                        onPressed: () => Navigator.of(context).pop(false),
                      ),
                      ElevatedButton(
                        child: Text('proceed'.tr),
                        onPressed: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  );
                },
              );

              // If user doesn't confirm, stop further execution
              if (confirmed != true) {
                return;
              }
              
              VideoApi videoapi = VideoApi();
              final result = await videoapi.deductVideoCredit(videoId: widget.id);
              
              final int status = result['status'];
              final String message = result['message'];
              
              print('Status: $status');
              print('Message: $message');

              // Show a dialog with the message
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('info'.tr),
                      content: Text(message),
                      actions: [
                        TextButton(
                          child: Text('ok'.tr),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                );

              if (status == 200) {
                // Only navigate if credit was successfully deducted
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoApp(videoUrl: widget.videoFile, videoId: widget.id),
                  ),
                );
              } else {
                // Show a message if deduction failed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message)),
                );
              }
            },

            child: Stack(
              alignment: Alignment.center,
              children: [
                // Video thumbnail
                _thumbnailPath != null
                    ? Image.file(File(_thumbnailPath!), width: 150, height: 100, fit: BoxFit.cover)
                    : Container(width: 100, height: 100, color: Colors.grey),

                // Play icon in the center of the thumbnail
                const Icon(Icons.play_circle_fill, size: 40, color: Colors.white),

                // Positioned label at the top-left
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: labelColor, // Background color based on level
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      widget.level,
                      style: const TextStyle(color: Colors.white, fontSize: 8,),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // 50% of the width for the text (title and description)
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(
                widget.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

}



 
class VideoApp extends StatefulWidget {
  final String videoUrl;
  final String videoId;
  const VideoApp({super.key, required this.videoUrl, required this.videoId});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoApp> {
  late VideoPlayerController _controller;
  Duration lastWatchedPosition = Duration.zero; // Track the last watched position

  @override
  void initState() {
    super.initState();
    print('&&&&&& before calling network * ${widget.videoUrl}');
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {}); // Update UI when the video is initialized
      });
  }

  @override
  void dispose() {    
    lastWatchedPosition = _controller.value.position; // Capture last watched position 
    _sendWatchDetailsToAPI(widget.videoId,lastWatchedPosition); // Send details to API
    _controller.dispose();
    super.dispose();
  }

// Sends watch details to API and saves progress in SharedPreferences
Future<void> _sendWatchDetailsToAPI(String videoId, Duration lastWatchedPosition) async {
  print('&&&&&&&& Sending notification to video watch API');

  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Save last watched position in seconds
  await prefs.setInt('video_progress_$videoId', lastWatchedPosition.inSeconds);

  // Ensure videoId is stored in savedVideoIds list
  List<String> savedVideoIds = prefs.getStringList('savedVideoIds') ?? [];
  if (!savedVideoIds.contains(videoId)) {
    savedVideoIds.add(videoId);
    await prefs.setStringList('savedVideoIds', savedVideoIds);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Video Player"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_controller.value.isPlaying) {
              lastWatchedPosition = _controller.value.position; // Capture paused position
              print('lastWatchedPosition=$lastWatchedPosition');
              _controller.pause();
            } else {
              _controller.play();
            }
          });
        },
        child: Icon(
          _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}