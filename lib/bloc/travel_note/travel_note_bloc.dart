import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:travel_joy/bloc/travel_note/travel_note_event.dart';
import 'package:travel_joy/bloc/travel_note/travel_note_state.dart';
import 'package:travel_joy/models/travel_note.dart';
import 'package:travel_joy/models/comment.dart';
import 'package:travel_joy/data/repositories/travel_note_repository.dart';

class TravelNoteBloc extends Bloc<TravelNoteEvent, TravelNoteState> {
  final TravelNoteRepository _travelNoteRepository;
  
  TravelNoteBloc({
    required TravelNoteRepository travelNoteRepository,
  }) : _travelNoteRepository = travelNoteRepository,
       super(TravelNoteInitial()) {
    on<LoadTravelNotes>(_onLoadTravelNotes);
    on<LoadTravelNoteDetail>(_onLoadTravelNoteDetail);
    on<AddTravelNoteComment>(_onAddTravelNoteComment);
    on<ReplyToComment>(_onReplyToComment);
    on<ToggleLikeTravelNote>(_onToggleLikeTravelNote);
    on<ToggleFavoriteTravelNote>(_onToggleFavoriteTravelNote);
    on<CreateTravelNote>(_onCreateTravelNote);
    on<UpdateTravelNote>(_onUpdateTravelNote);
    on<DeleteTravelNote>(_onDeleteTravelNote);
  }
  
  void _onLoadTravelNotes(
    LoadTravelNotes event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      // 如果是刷新或初始状态，显示加载状态
      if (event.refresh || state is TravelNoteInitial) {
        emit(TravelNoteLoading());
      }
      
      // 如果不是刷新且已经加载了笔记，则获取当前列表继续追加
      final currentNotes = state is TravelNotesLoaded && !event.refresh
          ? (state as TravelNotesLoaded).travelNotes
          : <TravelNote>[];
      
      // 获取笔记列表
      final result = await _travelNoteRepository.getTravelNotes(
        categoryId: event.categoryId,
        offset: event.refresh ? 0 : currentNotes.length,
        limit: 10,
      );
      
      // 如果是刷新或首次加载，则替换列表；否则追加到现有列表
      final notes = event.refresh ? result.notes : [...currentNotes, ...result.notes];
      
      emit(TravelNotesLoaded(
        travelNotes: notes,
        hasReachedMax: result.notes.length < 10, // 如果返回的数量少于请求的数量，表示已到达最大值
      ));
    } catch (e) {
      emit(TravelNoteError('加载游记列表失败: ${e.toString()}'));
    }
  }
  
  void _onLoadTravelNoteDetail(
    LoadTravelNoteDetail event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      emit(TravelNoteLoading());
      
      // 获取游记详情
      final travelNote = await _travelNoteRepository.getTravelNoteDetail(event.noteId);
      
      emit(TravelNoteDetailLoaded(travelNote));
    } catch (e) {
      emit(TravelNoteError('加载游记详情失败: ${e.toString()}'));
    }
  }
  
  void _onAddTravelNoteComment(
    AddTravelNoteComment event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      // 添加评论
      final commentId = await _travelNoteRepository.addComment(
        event.noteId,
        event.content,
      );
      
      emit(TravelNoteCommentAdded(
        noteId: event.noteId,
        commentId: commentId,
      ));
      
      // 重新加载游记详情以更新评论
      add(LoadTravelNoteDetail(noteId: event.noteId));
    } catch (e) {
      emit(TravelNoteError('添加评论失败: ${e.toString()}'));
    }
  }
  
  void _onReplyToComment(
    ReplyToComment event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      // 回复评论
      await _travelNoteRepository.replyToComment(
        event.noteId,
        event.commentId,
        event.content,
      );
      
      emit(TravelNoteActionSuccess(
        message: '回复已发布',
        action: 'reply_comment',
      ));
      
      // 重新加载游记详情以更新评论
      add(LoadTravelNoteDetail(noteId: event.noteId));
    } catch (e) {
      emit(TravelNoteError('回复评论失败: ${e.toString()}'));
    }
  }
  
  void _onToggleLikeTravelNote(
    ToggleLikeTravelNote event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      if (state is TravelNoteDetailLoaded) {
        final currentState = state as TravelNoteDetailLoaded;
        final currentNote = currentState.travelNote;
        
        // 乐观更新，立即反馈给用户界面
        final updatedNote = currentNote.copyWith(
          isLiked: !currentNote.isLiked,
          likeCount: currentNote.isLiked 
              ? currentNote.likeCount - 1 
              : currentNote.likeCount + 1,
        );
        
        emit(TravelNoteDetailLoaded(updatedNote));
        
        // 调用API更新点赞状态
        await _travelNoteRepository.toggleLike(event.noteId);
      }
    } catch (e) {
      // 如果API调用失败，恢复原状态
      if (state is TravelNoteDetailLoaded) {
        final currentState = state as TravelNoteDetailLoaded;
        emit(TravelNoteDetailLoaded(currentState.travelNote));
      }
      emit(TravelNoteError('更新点赞状态失败: ${e.toString()}'));
    }
  }
  
  void _onToggleFavoriteTravelNote(
    ToggleFavoriteTravelNote event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      if (state is TravelNoteDetailLoaded) {
        final currentState = state as TravelNoteDetailLoaded;
        final currentNote = currentState.travelNote;
        
        // 乐观更新，立即反馈给用户界面
        final updatedNote = currentNote.copyWith(
          isFavorited: !currentNote.isFavorited,
          favoriteCount: currentNote.isFavorited 
              ? currentNote.favoriteCount - 1 
              : currentNote.favoriteCount + 1,
        );
        
        emit(TravelNoteDetailLoaded(updatedNote));
        
        // 调用API更新收藏状态
        await _travelNoteRepository.toggleFavorite(event.noteId);
      }
    } catch (e) {
      // 如果API调用失败，恢复原状态
      if (state is TravelNoteDetailLoaded) {
        final currentState = state as TravelNoteDetailLoaded;
        emit(TravelNoteDetailLoaded(currentState.travelNote));
      }
      emit(TravelNoteError('更新收藏状态失败: ${e.toString()}'));
    }
  }
  
  void _onCreateTravelNote(
    CreateTravelNote event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      emit(TravelNoteLoading());
      
      // 创建游记
      final noteId = await _travelNoteRepository.createTravelNote(event.travelNoteData);
      
      emit(TravelNoteActionSuccess(
        message: '游记创建成功',
        action: 'create_note',
      ));
      
      // 加载新创建的游记详情
      add(LoadTravelNoteDetail(noteId: noteId));
    } catch (e) {
      emit(TravelNoteError('创建游记失败: ${e.toString()}'));
    }
  }
  
  void _onUpdateTravelNote(
    UpdateTravelNote event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      emit(TravelNoteLoading());
      
      // 更新游记
      await _travelNoteRepository.updateTravelNote(
        event.noteId,
        event.travelNoteData,
      );
      
      emit(TravelNoteActionSuccess(
        message: '游记更新成功',
        action: 'update_note',
      ));
      
      // 重新加载游记详情
      add(LoadTravelNoteDetail(noteId: event.noteId));
    } catch (e) {
      emit(TravelNoteError('更新游记失败: ${e.toString()}'));
    }
  }
  
  void _onDeleteTravelNote(
    DeleteTravelNote event,
    Emitter<TravelNoteState> emit,
  ) async {
    try {
      // 删除游记
      await _travelNoteRepository.deleteTravelNote(event.noteId);
      
      emit(TravelNoteActionSuccess(
        message: '游记已删除',
        action: 'delete_note',
      ));
      
      // 重新加载游记列表
      add(const LoadTravelNotes(refresh: true));
    } catch (e) {
      emit(TravelNoteError('删除游记失败: ${e.toString()}'));
    }
  }
} 