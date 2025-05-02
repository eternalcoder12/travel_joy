import 'package:equatable/equatable.dart';
import 'package:travel_joy/models/travel_note.dart';

abstract class TravelNoteState extends Equatable {
  const TravelNoteState();
  
  @override
  List<Object?> get props => [];
}

class TravelNoteInitial extends TravelNoteState {}

class TravelNoteLoading extends TravelNoteState {}

class TravelNoteError extends TravelNoteState {
  final String message;
  
  const TravelNoteError(this.message);
  
  @override
  List<Object> get props => [message];
}

class TravelNotesLoaded extends TravelNoteState {
  final List<TravelNote> travelNotes;
  final bool hasReachedMax;
  
  const TravelNotesLoaded({
    required this.travelNotes,
    this.hasReachedMax = false,
  });
  
  @override
  List<Object> get props => [travelNotes, hasReachedMax];
  
  TravelNotesLoaded copyWith({
    List<TravelNote>? travelNotes,
    bool? hasReachedMax,
  }) {
    return TravelNotesLoaded(
      travelNotes: travelNotes ?? this.travelNotes,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class TravelNoteDetailLoaded extends TravelNoteState {
  final TravelNote travelNote;
  
  const TravelNoteDetailLoaded(this.travelNote);
  
  @override
  List<Object> get props => [travelNote];
}

class TravelNoteCommentAdded extends TravelNoteState {
  final String noteId;
  final String commentId;
  
  const TravelNoteCommentAdded({
    required this.noteId,
    required this.commentId,
  });
  
  @override
  List<Object> get props => [noteId, commentId];
}

class TravelNoteActionSuccess extends TravelNoteState {
  final String message;
  final String action;
  
  const TravelNoteActionSuccess({
    required this.message,
    required this.action,
  });
  
  @override
  List<Object> get props => [message, action];
} 