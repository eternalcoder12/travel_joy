import 'package:equatable/equatable.dart';

abstract class TravelNoteEvent extends Equatable {
  const TravelNoteEvent();
  
  @override
  List<Object?> get props => [];
}

class LoadTravelNotes extends TravelNoteEvent {
  final String? categoryId;
  final bool refresh;
  
  const LoadTravelNotes({
    this.categoryId,
    this.refresh = false,
  });
  
  @override
  List<Object?> get props => [categoryId, refresh];
}

class LoadTravelNoteDetail extends TravelNoteEvent {
  final String noteId;
  
  const LoadTravelNoteDetail({
    required this.noteId,
  });
  
  @override
  List<Object> get props => [noteId];
}

class AddTravelNoteComment extends TravelNoteEvent {
  final String noteId;
  final String content;
  
  const AddTravelNoteComment({
    required this.noteId,
    required this.content,
  });
  
  @override
  List<Object> get props => [noteId, content];
}

class ReplyToComment extends TravelNoteEvent {
  final String noteId;
  final String commentId;
  final String content;
  
  const ReplyToComment({
    required this.noteId,
    required this.commentId,
    required this.content,
  });
  
  @override
  List<Object> get props => [noteId, commentId, content];
}

class ToggleLikeTravelNote extends TravelNoteEvent {
  final String noteId;
  
  const ToggleLikeTravelNote({
    required this.noteId,
  });
  
  @override
  List<Object> get props => [noteId];
}

class ToggleFavoriteTravelNote extends TravelNoteEvent {
  final String noteId;
  
  const ToggleFavoriteTravelNote({
    required this.noteId,
  });
  
  @override
  List<Object> get props => [noteId];
}

class CreateTravelNote extends TravelNoteEvent {
  final Map<String, dynamic> travelNoteData;
  
  const CreateTravelNote({
    required this.travelNoteData,
  });
  
  @override
  List<Object> get props => [travelNoteData];
}

class UpdateTravelNote extends TravelNoteEvent {
  final String noteId;
  final Map<String, dynamic> travelNoteData;
  
  const UpdateTravelNote({
    required this.noteId,
    required this.travelNoteData,
  });
  
  @override
  List<Object> get props => [noteId, travelNoteData];
}

class DeleteTravelNote extends TravelNoteEvent {
  final String noteId;
  
  const DeleteTravelNote({
    required this.noteId,
  });
  
  @override
  List<Object> get props => [noteId];
} 