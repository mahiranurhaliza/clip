import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Impor file service yang terpisah dari folder services/
import 'services/api_books.dart';
import 'services/omdb_service.dart';

const _supabaseStorageBaseUrl =
    'https://okezfbrczzfprowtjobe.supabase.co/storage/v1/object/public';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ReciteApp());
}

// ==========================================
// SUPABASE STORAGE HELPER & WIDGET
// ==========================================

String getStorageUrl({
  required String bucket,
  required String fileName,
}) {
  return '$_supabaseStorageBaseUrl/$bucket/$fileName';
}

class SupabaseIcon extends StatelessWidget {
  const SupabaseIcon({
    required this.fileName,
    this.size = 24.0,
    this.color,
    super.key,
  });

  final String fileName;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      getStorageUrl(
        bucket: 'icon-asset',
        fileName: fileName,
      ),
      width: size,
      height: size,
      color: color,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported_outlined,
        size: size,
        color: color,
      ),
    );
  }
}

// ==========================================
// COLOR
// ==========================================

const _paper = Color(0xFFFDF8E2);
const _ink = Color(0xFF4B587A);
const _accent = Color(0xFFF1642E);
const _olive = Color(0xFFC9CE67);
const _sage = Color(0xFFA3B565);
const _gridCard = Color(0x7FFCDD9D);
const _gridCardLight = Color(0x4CFCDD9D);
const _cardBlue = Color(0xFFBFD1FA);

// ==========================================
// APP
// ==========================================

class ReciteApp extends StatelessWidget {
  const ReciteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recite',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _accent,
          brightness: Brightness.light,
          surface: _paper,
        ),
        textTheme: GoogleFonts.bricolageGrotesqueTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const ReciteHome(),
    );
  }
}

// ==========================================
// BOOK MODEL & DATA (LOKAL)
// ==========================================

class Book {
  const Book({
    required this.title,
    required this.author,
    required this.category,
    required this.progress,
    required this.colors,
    required this.coverText,
    required this.coverUrl,
    this.comments = 10,
    this.likes = 8,
    this.date = 'Sep 28',
  });

  final String title;
  final String author;
  final String category;
  final double progress;
  final List<Color> colors;
  final String coverText;
  final String coverUrl;
  final int comments;
  final int likes;
  final String date;
}

final _books = [
  const Book(
    title: 'Pos Terakhir: 3 Hari Untuk Selamanya',
    author: 'Aruna Tisha',
    category: 'FICTION',
    progress: 0.62,
    colors: [Color(0x00D1A4A1), Color(0xFFD1A4A1)],
    coverText: 'POS TERAKHIR',
    coverUrl: 'assets/covers/pos-terakhir.jpg',
    comments: 10,
    likes: 8,
    date: 'Sep 28',
  ),
  const Book(
    title: 'The Old Me; Age, Wealth, True Love',
    author: 'Aruna Tisha',
    category: 'FICTION',
    progress: 0.84,
    colors: [Color(0x00259067), Color(0xFF259067)],
    coverText: 'THE SEVEN HUSBANDS',
    coverUrl: 'assets/covers/old-me.jpg',
    comments: 10,
    likes: 8,
    date: 'Aug 31',
  ),
  const Book(
    title: 'Before the Coffee Gets Cold',
    author: 'Toshikazu Kawaguchi',
    category: 'FICTION',
    progress: 0.45,
    colors: [Color(0xFF98A7AD), Color(0xFF536A70)],
    coverText: 'BEFORE THE COFFEE',
    coverUrl: 'assets/covers/before-coffee.jpg',
    comments: 5,
    likes: 12,
    date: 'Aug 15',
  ),
];

// ==========================================
// HOME
// ==========================================

class ReciteHome extends StatefulWidget {
  const ReciteHome({super.key});

  @override
  State<ReciteHome> createState() => _ReciteHomeState();
}

class _ReciteHomeState extends State<ReciteHome> {
  int _selectedTab = 0;

  void _openBook(Book book) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => ReaderScreen(book: book),
      ),
    );
  }

  void _openLibrary() {
    setState(() => _selectedTab = 1);
  }

  void _showAddOverlay(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const _AddOverlaySheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _selectedTab,
          children: [
            FeedScreen(
              onBookTap: _openBook,
              onSeeAll: _openLibrary,
            ),
            LibraryScreen(
              onBookTap: _openBook,
            ),
            ProfileScreen(
              onBookTap: _openBook,
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 85,
        color: _paper,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  color: _olive.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(
                      index: 0,
                      label: 'Home',
                      iconFileName: 'home.png',
                    ),
                    _buildNavItem(
                      index: 1,
                      label: 'Library',
                      iconFileName: 'library.png',
                    ),
                    _buildNavItem(
                      index: 2,
                      label: 'Profile',
                      iconFileName: 'profile.png',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showAddOverlay(context),
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _olive.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SupabaseIcon(
                      fileName: 'add.png',
                      size: 26,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required String iconFileName,
  }) {
    final isSelected = _selectedTab == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: isSelected
            ? BoxDecoration(
                color: const Color(0xFFFDFBE2).withOpacity(0.6),
                borderRadius: BorderRadius.circular(50),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SupabaseIcon(
              fileName: iconFileName,
              size: 20,
              color: isSelected ? _accent : _ink,
            ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? _accent : _ink,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// ADD OVERLAY SHEET
// ==========================================

class _AddOverlaySheet extends StatelessWidget {
  const _AddOverlaySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 15, bottom: 35),
      decoration: const BoxDecoration(
        color: Color(0xFFFCDD9D),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 5,
            decoration: BoxDecoration(
              color: _sage,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildCategoryOption(
                context: context,
                label: 'Buku',
                iconFileName: 'book.png',
              ),
              _buildCategoryOption(
                context: context,
                label: 'Film',
                iconFileName: 'movie.png',
              ),
              _buildCategoryOption(
                context: context,
                label: 'Serial',
                iconFileName: 'series.png',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryOption({
    required BuildContext context,
    required String label,
    required String iconFileName,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: _cardBlue,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: _ink,
                width: 2,
              ),
            ),
            child: Center(
              child: SupabaseIcon(
                fileName: iconFileName,
                size: 55,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HEADER WITH INTERACTIVE SEARCH
// ==========================================

class _HeaderWithClip extends StatelessWidget {
  const _HeaderWithClip({
    required this.title,
    this.showClip = true,
  });

  final String title;
  final bool showClip;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBE2),
        border: Border(
          bottom: BorderSide(
            width: 1,
            color: _accent,
          ),
        ),
      ),
      child: Row(
        children: [
          if (showClip) ...[
            Transform.rotate(
              angle: -0.2,
              child: const SupabaseIcon(
                fileName: 'clip.png',
                color: _accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ApiSearchScreen(),
                ),
              );
            },
            child: const SupabaseIcon(
              fileName: 'search.png',
              size: 25,
              color: _ink,
            ),
          ),
          const SizedBox(width: 12),
          const SupabaseIcon(
            fileName: 'notif.png',
            size: 25,
            color: _ink,
          ),
        ],
      ),
    );
  }
}

// ==========================================
// API SEARCH SCREEN (MENGGUNAKAN SERVICE TERPISAH)
// ==========================================

class ApiSearchScreen extends StatefulWidget {
  const ApiSearchScreen({super.key});

  @override
  State<ApiSearchScreen> createState() => _ApiSearchScreenState();
}

class _ApiSearchScreenState extends State<ApiSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  bool _isLoading = false;
  List<Map<String, dynamic>> _results = [];
  String _selectedCategory = 'Semua';

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      setState(() => _isLoading = true);
      List<Map<String, dynamic>> temp = [];

      // Memanggil fungsi dari kelas terpisah (GoogleBooksService & OmdbService)
      if (_selectedCategory == 'Buku') {
        temp = await GoogleBooksService.searchBooks(query);
      } else if (_selectedCategory == 'Film') {
        temp = await OmdbService.searchMedia(query, type: 'movie');
      } else if (_selectedCategory == 'Serial') {
        temp = await OmdbService.searchMedia(query, type: 'series');
      } else {
        final books = await GoogleBooksService.searchBooks(query);
        final omdb = await OmdbService.searchMedia(query);
        temp = [...books, ...omdb];
      }

      if (mounted) {
        setState(() {
          _results = temp;
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _paper,
        foregroundColor: _ink,
        elevation: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          onChanged: _onSearchChanged,
          style: const TextStyle(color: _ink),
          decoration: const InputDecoration(
            hintText: 'Cari buku, film, serial...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: ['Semua', 'Buku', 'Film', 'Serial'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: _sage.withOpacity(0.4),
                    onSelected: (val) {
                      setState(() => _selectedCategory = cat);
                      _onSearchChanged(_controller.text);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text('Tidak ada hasil.'))
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final item = _results[index];
                          final cover = item['coverUrl'] as String;

                          return ListTile(
                            leading: cover.isNotEmpty
                                ? Image.network(
                                    cover,
                                    width: 45,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  )
                                : const Icon(Icons.movie),
                            title: Text(item['title'] ?? ''),
                            subtitle: Text(
                                '${item['type']} • ${item['subtitle'] ?? item['authors']}'),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// FEED SCREEN
// ==========================================

class FeedScreen extends StatefulWidget {
  const FeedScreen({
    required this.onBookTap,
    required this.onSeeAll,
    super.key,
  });

  final ValueChanged<Book> onBookTap;
  final VoidCallback onSeeAll;

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedFilter = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const PageStorageKey<String>('feed'),
      children: [
        const _HeaderWithClip(title: 'Feed'),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 21),
          child: Row(
            children: [
              _buildFilterChip('For you', 0),
              const SizedBox(width: 10),
              _buildFilterChip('Following', 1),
            ],
          ),
        ),
        const SizedBox(height: 18),
        for (final book in _books) ...[
          _FeedCard(
            book: book,
            onTap: () => widget.onBookTap(book),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final isSelected = _selectedFilter == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? _sage.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: _sage, width: 2),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _FeedCard extends StatelessWidget {
  const _FeedCard({required this.book, required this.onTap});

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 21),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 1),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                book.author,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                book.date,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                image: DecorationImage(
                  image: AssetImage(book.coverUrl),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: book.colors,
                  ),
                ),
                alignment: Alignment.bottomLeft,
                child: Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const SupabaseIcon(
                fileName: 'comment.png',
                size: 20,
                color: _sage,
              ),
              const SizedBox(width: 5),
              Text('${book.comments}'),
              const SizedBox(width: 20),
              const SupabaseIcon(
                fileName: 'star.png',
                size: 20,
                color: _sage,
              ),
              const SizedBox(width: 5),
              Text('${book.likes}'),
              const Spacer(),
              const SupabaseIcon(
                fileName: 'clip.png',
                size: 20,
                color: _sage,
              ),
              const SizedBox(width: 15),
              const SupabaseIcon(
                fileName: 'share.png',
                size: 20,
                color: _sage,
              ),
            ],
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.black, thickness: 1),
        ],
      ),
    );
  }
}

// ==========================================
// LIBRARY SCREEN
// ==========================================

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({required this.onBookTap, super.key});
  final ValueChanged<Book> onBookTap;

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDate = DateTime(today.year, today.month, today.day);
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth =
          DateTime(_visibleMonth.year, _visibleMonth.month + offset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthName = _monthName(_visibleMonth.month);

    return ListView(
      key: const PageStorageKey<String>('library'),
      padding: const EdgeInsets.only(bottom: 20),
      children: [
        const _HeaderWithClip(title: 'Library', showClip: false),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () => _changeMonth(-1),
                icon: const Icon(Icons.arrow_left, color: _sage, size: 36),
              ),
              Text(
                '${monthName.substring(0, 3)} ${_visibleMonth.year}',
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              IconButton(
                onPressed: () => _changeMonth(1),
                icon: const Icon(Icons.arrow_right, color: _sage, size: 36),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: _CalendarGrid(
            month: _visibleMonth,
            selectedDate: _selectedDate,
            onDateSelected: (date) => setState(() => _selectedDate = date),
          ),
        ),
      ],
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.month,
    required this.selectedDate,
    required this.onDateSelected,
  });

  final DateTime month;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month);
    final offset = (firstDay.weekday + 6) % 7;
    final dayCount = DateTime(month.year, month.month + 1, 0).day;

    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: List.generate(35, (index) {
        final dayNumber = index - offset + 1;

        if (dayNumber < 1 || dayNumber > dayCount) {
          return Container(
            width: 45,
            height: 90,
            decoration: BoxDecoration(
              color: _gridCardLight,
              borderRadius: BorderRadius.circular(5),
            ),
          );
        }

        final date = DateTime(month.year, month.month, dayNumber);
        final isSelected = date.year == selectedDate.year &&
            date.month == selectedDate.month &&
            date.day == selectedDate.day;

        return GestureDetector(
          onTap: () => onDateSelected(date),
          child: Container(
            width: 45,
            height: 90,
            decoration: BoxDecoration(
              color: isSelected ? _accent.withOpacity(0.8) : _gridCard,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: isSelected ? Colors.white : _ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ==========================================
// PROFILE SCREEN
// ==========================================

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.onBookTap, super.key});
  final ValueChanged<Book> onBookTap;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final books = _books
        .where(
          (b) =>
              b.title.toLowerCase().contains(_query.toLowerCase()) ||
              b.author.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return CustomScrollView(
      key: const PageStorageKey<String>('profile'),
      slivers: [
        const SliverToBoxAdapter(
          child: _HeaderWithClip(title: 'Profile'),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _sage.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const SupabaseIcon(
                    fileName: 'search.png',
                    size: 20,
                    color: _ink,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        setState(() => _query = value.trim());
                      },
                      style: const TextStyle(color: _ink),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search your books',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => GestureDetector(
                onTap: () => widget.onBookTap(books[index]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          image: DecorationImage(
                            image: AssetImage(books[index].coverUrl),
                            fit: BoxFit.cover,
                            onError: (exception, stackTrace) {},
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      books[index].title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              childCount: books.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 0.7,
            ),
          ),
        ),
      ],
    );
  }
}

// ==========================================
// READER SCREEN
// ==========================================

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({required this.book, super.key});
  final Book book;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  int _page = 34;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _paper,
      appBar: AppBar(
        backgroundColor: _paper,
        foregroundColor: _ink,
        elevation: 0,
        title: Text(widget.book.title, style: const TextStyle(fontSize: 16)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    'Chapter Four\n\n${widget.book.title} continuation reading content...',
                    style: const TextStyle(fontSize: 18, height: 1.6),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _page > 1 ? () => setState(() => _page--) : null,
                    icon: const Icon(Icons.chevron_left_rounded),
                  ),
                  Text('Page $_page'),
                  IconButton(
                    onPressed: () => setState(() => _page++),
                    icon: const Icon(Icons.chevron_right_rounded),
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

// ==========================================
// MONTH HELPER
// ==========================================

String _monthName(int month) {
  const names = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return names[month - 1];
}