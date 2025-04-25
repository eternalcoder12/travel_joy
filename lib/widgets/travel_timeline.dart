import 'package:flutter/material.dart';
import 'package:travel_joy/app_theme.dart';

class TravelEvent {
  final String location;
  final String date;
  final String description;
  final String? imageUrl;
  final Color dotColor;

  TravelEvent({
    required this.location,
    required this.date,
    required this.description,
    this.imageUrl,
    required this.dotColor,
  });
}

class TravelTimeline extends StatelessWidget {
  final List<TravelEvent> events;

  const TravelTimeline({Key? key, required this.events}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isLast = index == events.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: event.dotColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 70,
                      color: Colors.grey.withOpacity(0.3),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.location,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    event.date,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  if (event.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        event.imageUrl!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 150,
                            color: Colors.grey[200],
                            child: const Center(child: Text('图片加载失败')),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(event.description, style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class TravelTimelinePreview extends StatelessWidget {
  final List<TravelEvent> events;
  final VoidCallback onTap;

  const TravelTimelinePreview({
    Key? key,
    required this.events,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppTheme.getTheme().dividerColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.map, color: Colors.blue),
                    const SizedBox(width: 10),
                    Text(
                      '旅行足迹',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.getTheme().primaryColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  '已去过 ${events.length} 个城市',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.getTheme().disabledColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _buildLocationDots(),
            ),
            const SizedBox(height: 15),
            Center(
              child: Text(
                '查看全部足迹',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getTheme().primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildLocationDots() {
    final List<Widget> dots = [];
    final int maxDots = events.length > 4 ? 4 : events.length;

    for (int i = 0; i < maxDots; i++) {
      dots.add(
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: events[i].dotColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 24),
        ),
      );
    }

    return dots;
  }
}
