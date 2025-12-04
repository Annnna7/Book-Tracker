import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'book_search_page.dart';


/// Модель данных для заметки
class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? bookTitle;
  final int? pageNumber;
  final bool isQuote;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.bookTitle,
    this.pageNumber,
    this.isQuote = false,
  });

  // Конструктор для создания новой заметки
  Note.create({
    required this.title,
    required this.content,
    this.bookTitle,
    this.pageNumber,
    this.isQuote = false,
  }) : 
        id = DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now();

  Note copyWith({
    String? title,
    String? content,
    DateTime? updatedAt,
    int? pageNumber,
    bool? isQuote,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      bookTitle: bookTitle,
      pageNumber: pageNumber ?? this.pageNumber,
      isQuote: isQuote ?? this.isQuote,
    );
  }
}

/// Провайдер для управления заметками
class NotesProvider with ChangeNotifier {
  List<Note> _notes = [];
  
  List<Note> get notes => _notes;
  
  List<Note> get quotes => _notes.where((note) => note.isQuote).toList();
  
  List<Note> get regularNotes => _notes.where((note) => !note.isQuote).toList();
  
  void addNote(Note note) {
    _notes.insert(0, note);
    notifyListeners();
  }
  
  void removeNote(String id) {
    _notes.removeWhere((note) => note.id == id);
    notifyListeners();
  }
  
  void updateNote(Note updatedNote) {
    final index = _notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      _notes[index] = updatedNote;
      notifyListeners();
    }
  }
}

/// Главная страница заметок
class NotesPage extends StatelessWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Рассчитываем пропорции относительно Figma (375×812)
    // Эллипс в Figma: 583×994 на экране 375×812
    
    // Ширина эллипса относительно ширины экрана
    final ellipseWidth = screenWidth * (450 / 375);
    
    // Высота эллипса сохраняя пропорции
    final ellipseHeight = ellipseWidth * (994 / 583);
    
    // В Figma эллипс занимает 3/4 экрана по высоте
    final visibleHeight = screenHeight * 0.8; // 3/4 экрана
    final hiddenHeight = ellipseHeight - visibleHeight;

    return ChangeNotifierProvider(
      create: (context) => NotesProvider(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4ECE1),
        body: SafeArea(
          child: Stack(
            children: [
              // ОВАЛ (эллипс) с правильными пропорциями
              Positioned(
                top: -hiddenHeight,
                left: (screenWidth - ellipseWidth) / 2,
                child: Container(
                  width: ellipseWidth,
                  height: ellipseHeight,
                  decoration: BoxDecoration(
                    color: const Color(0xFF765745),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(ellipseWidth * 1.3, ellipseHeight * 1.1),
                      bottom: Radius.elliptical(ellipseWidth * 1.3, ellipseHeight * 1.1),
                    ),
                  ),
                ),
              ),
              // Основной контент
              Column(
                children: [
                  const NotesHeader(),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: const NotesContent(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шапка страницы с заголовком и поиском
class NotesHeader extends StatelessWidget {
  const NotesHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 40.0, bottom: 16), // 👈 Увеличили top до 40
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок и иконка поиска в одной строке
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ваши заметки\nи цитаты',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 30,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: Добавить функционал поиска
                },
                icon: SvgPicture.asset(
                  'assets/icons/loupe.svg',
                  width: 24,
                  height: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Проверяем есть ли книги
          const BooksEmptyState(),
        ],
      ),
    );
  }
}

/// Состояние когда книг нет
class BooksEmptyState extends StatelessWidget {
  const BooksEmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TODO: Заменить на реальную проверку наличия книг
    final bool hasBooks = false; // Временно false для демонстрации

    if (hasBooks) {
      return const SizedBox(); // Если книги есть, не показываем этот блок
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Текст под заголовком
        const Text(
          'Все заметки и цитаты по книге,\nкоторые вы хотите отметить,\nможно сделать и сохранить здесь!',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            color: Colors.white,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        
        // Прямоугольник с предложением добавить книгу - теперь кликабельный
        GestureDetector(
          onTap: () {
            // Переходим на страницу добавления книги
            _navigateToAddBookPage(context);
          },
          child: Center(
            child: Container(
              width: 310,
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFF4ECE1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(25),
                ),
                border: Border.all(
                  color: const Color.fromRGBO(107, 79, 57, 1.0),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Добавьте книгу',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Чтобы создать заметку',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      'assets/icons/search.svg',
                      width: 32,
                      height: 32,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

void _navigateToAddBookPage(BuildContext context) {
  // Навигация на страницу поиска книг
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const BookSearchPage(),
    ),
  );
}
}

/// Содержимое страницы заметок
class NotesContent extends StatelessWidget {
  const NotesContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notesProvider = Provider.of<NotesProvider>(context);
    final notes = notesProvider.notes;

    // TODO: Заменить на реальную проверку наличия книг
    final bool hasBooks = false; // Временно false для демонстрации

    if (!hasBooks) {
      // Если книг нет, показываем только заголовок и блок добавления книги
      return const SizedBox();
    }

    if (notes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: Colors.white, // Белый цвет для видимости на эллипсе
            ),
            SizedBox(height: 16),
            Text(
              'Пока нет заметок',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white, // Белый цвет
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Нажмите на кнопку "Добавьте книгу" выше,\nчтобы добавить первую книгу и создать заметку',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70, // Светло-белый
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return NoteCard(note: note);
        },
      ),
    );
  }
}

/// Состояние пустого списка заметок (когда книги есть, но заметок нет)
class EmptyNotesState extends StatelessWidget {
  const EmptyNotesState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Пока нет заметок',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Нажмите на кнопку ниже, чтобы добавить первую заметку или цитату',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Карточка отдельной заметки
class NoteCard extends StatelessWidget {
  final Note note;

  const NoteCard({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с иконкой
          Row(
            children: [
              Icon(
                note.isQuote ? Icons.format_quote : Icons.note_outlined,
                size: 18,
                color: const Color.fromRGBO(107, 79, 57, 1.0),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Содержание заметки
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          
          // Мета-информация
          _buildNoteMetaInfo(note),
        ],
      ),
    );
  }

  Widget _buildNoteMetaInfo(Note note) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (note.bookTitle != null) ...[
          Text(
            'Из книги: ${note.bookTitle}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 4),
        ],
        if (note.pageNumber != null) ...[
          Text(
            'Страница: ${note.pageNumber}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          _formatDate(note.updatedAt),
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Сегодня';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дня назад';
    } else {
      return '${date.day}.${date.month}.${date.year}';
    }
  }
}

/// Диалог добавления новой заметки
class AddNoteDialog extends StatefulWidget {
  const AddNoteDialog({Key? key}) : super(key: key);

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isQuote = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFF4ECE1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        _isQuote ? 'Новая цитата' : 'Новая заметка',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: _isQuote ? 'Заголовок цитаты' : 'Заголовок заметки',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: _isQuote ? 'Текст цитаты' : 'Текст заметки',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.white,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: _isQuote,
                  onChanged: (value) {
                    setState(() {
                      _isQuote = value ?? false;
                    });
                  },
                  activeColor: const Color.fromRGBO(107, 79, 57, 1.0),
                ),
                const Text(
                  'Это цитата из книги',
                  style: TextStyle(color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Отмена',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: _canSave() ? _saveNote : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromRGBO(107, 79, 57, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Сохранить',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  bool _canSave() {
    return _titleController.text.trim().isNotEmpty && 
           _contentController.text.trim().isNotEmpty;
  }

  void _saveNote() {
    if (_canSave()) {
      final newNote = Note.create(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        isQuote: _isQuote,
      );
      
      Provider.of<NotesProvider>(context, listen: false).addNote(newNote);
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
}