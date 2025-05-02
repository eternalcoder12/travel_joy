import 'package:flutter/material.dart';
import 'package:travel_joy/models/travel_note.dart';
import 'package:travel_joy/models/comment.dart';
import 'package:travel_joy/models/content_item.dart';
import 'package:travel_joy/data/services/api_service.dart';

class TravelNoteListResult {
  final List<TravelNote> notes;
  final int total;
  
  TravelNoteListResult({
    required this.notes,
    required this.total,
  });
}

class TravelNoteRepository {
  final ApiService _apiService;
  
  TravelNoteRepository({
    required ApiService apiService,
  }) : _apiService = apiService;
  
  Future<TravelNoteListResult> getTravelNotes({
    String? categoryId,
    int offset = 0,
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        'travel-notes',
        queryParameters: {
          'offset': offset,
          'limit': limit,
          if (categoryId != null) 'categoryId': categoryId,
        },
      );
      
      final List<dynamic> notesData = response['notes'];
      final notes = notesData
          .map((data) => TravelNote.fromJson(data))
          .toList();
      
      return TravelNoteListResult(
        notes: notes,
        total: response['total'],
      );
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return TravelNoteListResult(
          notes: _getMockTravelNotes(),
          total: 20,
        );
      }
      rethrow;
    }
  }
  
  Future<TravelNote> getTravelNoteDetail(String noteId) async {
    try {
      final response = await _apiService.get('travel-notes/$noteId');
      return TravelNote.fromJson(response);
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        final mockNotes = _getMockTravelNotes();
        final note = mockNotes.firstWhere(
          (note) => note.id == noteId,
          orElse: () => mockNotes.first,
        );
        return note;
      }
      rethrow;
    }
  }
  
  Future<String> addComment(String noteId, String content) async {
    try {
      final response = await _apiService.post(
        'travel-notes/$noteId/comments',
        data: {'content': content},
      );
      return response['commentId'];
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return 'comment-${DateTime.now().millisecondsSinceEpoch}';
      }
      rethrow;
    }
  }
  
  Future<void> replyToComment(String noteId, String commentId, String content) async {
    try {
      await _apiService.post(
        'travel-notes/$noteId/comments/$commentId/replies',
        data: {'content': content},
      );
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return;
      }
      rethrow;
    }
  }
  
  Future<void> toggleLike(String noteId) async {
    try {
      await _apiService.post('travel-notes/$noteId/toggle-like');
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return;
      }
      rethrow;
    }
  }
  
  Future<void> toggleFavorite(String noteId) async {
    try {
      await _apiService.post('travel-notes/$noteId/toggle-favorite');
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return;
      }
      rethrow;
    }
  }
  
  Future<String> createTravelNote(Map<String, dynamic> travelNoteData) async {
    try {
      final response = await _apiService.post(
        'travel-notes',
        data: travelNoteData,
      );
      return response['noteId'];
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return 'note-${DateTime.now().millisecondsSinceEpoch}';
      }
      rethrow;
    }
  }
  
  Future<void> updateTravelNote(String noteId, Map<String, dynamic> travelNoteData) async {
    try {
      await _apiService.put(
        'travel-notes/$noteId',
        data: travelNoteData,
      );
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return;
      }
      rethrow;
    }
  }
  
  Future<void> deleteTravelNote(String noteId) async {
    try {
      await _apiService.delete('travel-notes/$noteId');
    } catch (e) {
      // 模拟数据，实际应用中应删除此处代码
      if (true) {
        return;
      }
      rethrow;
    }
  }
  
  // 模拟数据，实际应用中应删除此方法
  List<TravelNote> _getMockTravelNotes() {
    return [
      TravelNote(
        id: 'note-1',
        title: '探索京都的古老寺庙',
        authorId: 'user-1',
        authorName: '旅行家小明',
        authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
        location: '日本京都',
        status: TravelStatus.completed,
        summary: '京都，这座日本古都，保存着数百座寺庙和神社。本次旅行我走访了几处知名的寺庙，感受古老文化的魅力。',
        coverImage: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        likeCount: 286,
        commentCount: 42,
        viewCount: 1254,
        favoriteCount: 76,
        isLiked: false,
        isFavorited: true,
        tags: [
          TravelTag(name: '寺庙', color: const Color(0xFF4CAF50)),
          TravelTag(name: '日本', color: const Color(0xFFE91E63)),
          TravelTag(name: '文化遗产', color: const Color(0xFF9C27B0)),
        ],
        contentItems: [
          ContentItem(
            id: 'content-1',
            type: ContentType.text,
            content: '京都是日本最著名的旅游城市之一，拥有超过1600座寺庙和400座神社。我在这次旅行中决定探访几座最具代表性的寺庙，体验日本传统文化的精髓。',
          ),
          ContentItem(
            id: 'content-2',
            type: ContentType.image,
            content: 'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e',
            caption: '金阁寺外观，阳光照射下金碧辉煌',
          ),
          ContentItem(
            id: 'content-3',
            type: ContentType.text,
            content: '第一站是金阁寺，这座被列为世界文化遗产的寺庙以其金箔覆盖的外观而闻名。站在镜湖池旁，看着金阁寺在水中的倒影，仿佛进入了一个超然的世界。',
          ),
          ContentItem(
            id: 'content-4',
            type: ContentType.image,
            content: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186',
            caption: '伏见稻荷大社的千本鸟居',
          ),
          ContentItem(
            id: 'content-5',
            type: ContentType.text,
            content: '接下来是伏见稻荷大社，这里最著名的是绵延不绝的千本鸟居。走在橙红色的鸟居隧道中，感受着神秘的氛围，不禁让人思考日本人对神灵的崇敬。',
          ),
          ContentItem(
            id: 'content-6',
            type: ContentType.video,
            content: 'https://example.com/videos/kyoto-temples.mp4',
            caption: '清水寺的樱花季视频，美不胜收',
          ),
          ContentItem(
            id: 'content-7',
            type: ContentType.text,
            content: '最后一站是清水寺，这座建于高台之上的寺庙以其木质结构和不使用一钉的建筑工艺而著称。从清水舞台可以俯瞰整个京都市区，特别是在樱花季或红叶季，景色令人叹为观止。',
          ),
          ContentItem(
            id: 'content-8',
            type: ContentType.location,
            content: '清水寺',
            caption: '京都府京都市东山区清水1-294',
          ),
        ],
        comments: [
          Comment(
            id: 'comment-1',
            authorId: 'user-2',
            authorName: '日本旅行爱好者',
            authorAvatar: 'https://randomuser.me/api/portraits/women/44.jpg',
            content: '太棒了！我也去过金阁寺，确实很美。你有去银阁寺吗？虽然没有金阁寺那么华丽，但同样值得一看。',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
            likeCount: 15,
            isLiked: true,
            replies: [
              CommentReply(
                id: 'reply-1',
                authorId: 'user-1',
                authorName: '旅行家小明',
                authorAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
                content: '是的，我有去银阁寺！你说得对，它有一种低调的优雅，与金阁寺形成了有趣的对比。',
                createdAt: DateTime.now().subtract(const Duration(days: 9)),
              ),
            ],
          ),
          Comment(
            id: 'comment-2',
            authorId: 'user-3',
            authorName: '摄影达人',
            authorAvatar: 'https://randomuser.me/api/portraits/men/68.jpg',
            content: '你的照片拍得真好！用的什么相机？伏见稻荷那张特别棒，光线把鸟居照得很梦幻。',
            createdAt: DateTime.now().subtract(const Duration(days: 7)),
            likeCount: 8,
            isLiked: false,
            replies: [],
          ),
        ],
        type: TravelNoteType.normal,
        isPrivate: false,
      ),
      TravelNote(
        id: 'note-2',
        title: '探索塞尔维亚的隐藏美食',
        authorId: 'user-4',
        authorName: '美食探险家',
        authorAvatar: 'https://randomuser.me/api/portraits/women/22.jpg',
        location: '塞尔维亚贝尔格莱德',
        status: TravelStatus.completed,
        summary: '贝尔格莱德是一座充满历史与美食的城市，我在这里发现了很多当地特色美食，从传统的Ćevapi烤肉到甜点Baklava，每一种都让人回味无穷。',
        coverImage: 'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        likeCount: 178,
        commentCount: 28,
        viewCount: 892,
        favoriteCount: 53,
        isLiked: true,
        isFavorited: false,
        tags: [
          TravelTag(name: '美食', color: const Color(0xFFFF9800)),
          TravelTag(name: '欧洲', color: const Color(0xFF2196F3)),
          TravelTag(name: '小众目的地', color: const Color(0xFF607D8B)),
        ],
        contentItems: [
          ContentItem(
            id: 'content-9',
            type: ContentType.text,
            content: '塞尔维亚可能不是最热门的旅游目的地，但它绝对是美食爱好者的天堂。贝尔格莱德作为首都，融合了巴尔干半岛各地的美食精华。',
          ),
          ContentItem(
            id: 'content-10',
            type: ContentType.image,
            content: 'https://images.unsplash.com/photo-1529692236671-f1f6cf9683ba',
            caption: '传统塞尔维亚烤肉Ćevapi，配以洋葱和面包',
          ),
        ],
        comments: [],
        type: TravelNoteType.normal,
        isPrivate: false,
      ),
    ];
  }
} 