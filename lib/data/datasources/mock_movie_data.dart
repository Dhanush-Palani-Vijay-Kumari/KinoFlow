import '../../domain/entities/movie.dart';

class MockMovieData {
  static List<Movie> get movies => [
        // ─── GERMAN FILMS ───────────────────────────────────────────────
        Movie(
          id: 'de_001',
          title: 'The Lives of Others',
          titleDe: 'Das Leben der Anderen',
          synopsis:
              'In 1984 East Berlin, an agent of the secret police conducting surveillance on a writer and his lover finds himself becoming increasingly absorbed by their lives.',
          synopsisDe:
              'Im Jahr 1984 in Ost-Berlin überwacht ein Stasi-Offizier einen Dramatiker und seine Geliebte – und wird dabei zunehmend von ihrem Leben in den Bann gezogen.',
          posterUrl:
              'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1518676590629-3dcbd9c5a5c9?w=1280&h=720&fit=crop',
          director: 'Florian Henckel von Donnersmarck',
          cast: ['Ulrich Mühe', 'Martina Gedeck', 'Sebastian Koch'],
          genres: ['Drama', 'Thriller'],
          language: 'Deutsch',
          durationMinutes: 137,
          rating: 8.5,
          releaseDate: '2006',
          isGerman: true,
          isFeatured: true,
          showtimes: _generateShowtimes('de_001', 13.50),
        ),
        Movie(
          id: 'de_002',
          title: 'Run Lola Run',
          titleDe: 'Lola rennt',
          synopsis:
              'A young woman has 20 minutes to find and bring 100,000 Deutsche Marks to her boyfriend before his mobster boss kills him.',
          synopsisDe:
              'Lola hat 20 Minuten, um 100.000 Mark aufzutreiben und damit ihrem Freund Manni das Leben zu retten.',
          posterUrl:
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=1280&h=720&fit=crop',
          director: 'Tom Tykwer',
          cast: ['Franka Potente', 'Moritz Bleibtreu'],
          genres: ['Thriller', 'Action'],
          language: 'Deutsch',
          durationMinutes: 81,
          rating: 7.6,
          releaseDate: '1998',
          isGerman: true,
          showtimes: _generateShowtimes('de_002', 11.50),
        ),
        Movie(
          id: 'de_003',
          title: 'Goodbye Lenin!',
          titleDe: 'Good Bye, Lenin!',
          synopsis:
              'To protect his fragile mother from a fatal shock after a long coma, a young man tries to hide the fact that the Berlin Wall has fallen and Germany has been reunified.',
          synopsisDe:
              'Um seine schwache Mutter nach einem langen Koma zu schützen, versucht ein junger Mann zu verheimlichen, dass die Mauer gefallen ist.',
          posterUrl:
              'https://images.unsplash.com/photo-1599639957043-f3aa5c986398?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1599639957043-f3aa5c986398?w=1280&h=720&fit=crop',
          director: 'Wolfgang Becker',
          cast: ['Daniel Brühl', 'Katrin Saß', 'Chulpan Khamatova'],
          genres: ['Komödie', 'Drama'],
          language: 'Deutsch',
          durationMinutes: 121,
          rating: 8.0,
          releaseDate: '2003',
          isGerman: true,
          showtimes: _generateShowtimes('de_003', 12.00),
        ),
        Movie(
          id: 'de_004',
          title: 'Downfall',
          titleDe: 'Der Untergang',
          synopsis:
              'Traudl Junge, the final secretary for Adolf Hitler, tells of the Nazi dictator\'s final days in his Berlin bunker at the end of WWII.',
          synopsisDe:
              'Traudl Junge, Hitlers letzte Sekretärin, erlebt die letzten Tage des Diktators im Berliner Führerbunker.',
          posterUrl:
              'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1553356084-58ef4a67b2a7?w=1280&h=720&fit=crop',
          director: 'Oliver Hirschbiegel',
          cast: ['Bruno Ganz', 'Alexandra Maria Lara', 'Corinna Harfouch'],
          genres: ['Drama', 'Geschichte'],
          language: 'Deutsch',
          durationMinutes: 156,
          rating: 8.2,
          releaseDate: '2004',
          isGerman: true,
          showtimes: _generateShowtimes('de_004', 13.00),
        ),
        Movie(
          id: 'de_005',
          title: 'Perfume: The Story of a Murderer',
          titleDe: 'Das Parfum',
          synopsis:
              'Jean-Baptiste Grenouille, born with a superior olfactory sense, creates the world\'s finest perfume but becomes a murderer in the process.',
          synopsisDe:
              'Jean-Baptiste Grenouille besitzt einen außergewöhnlichen Geruchssinn und strebt danach, das vollkommene Parfüm zu schaffen – koste es, was es wolle.',
          posterUrl:
              'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1588392382834-a891154bca4d?w=1280&h=720&fit=crop',
          director: 'Tom Tykwer',
          cast: ['Ben Whishaw', 'Dustin Hoffman', 'Alan Rickman'],
          genres: ['Drama', 'Thriller', 'Krimi'],
          language: 'Deutsch / English',
          durationMinutes: 147,
          rating: 7.5,
          releaseDate: '2006',
          isGerman: true,
          showtimes: _generateShowtimes('de_005', 12.50),
        ),

        // ─── INTERNATIONAL FILMS ────────────────────────────────────────
        Movie(
          id: 'int_001',
          title: 'Oppenheimer',
          titleDe: 'Oppenheimer',
          synopsis:
              'The story of American scientist J. Robert Oppenheimer and his role in the development of the atomic bomb during World War II.',
          synopsisDe:
              'Die Geschichte von J. Robert Oppenheimer und der Entwicklung der Atombombe im Zweiten Weltkrieg.',
          posterUrl:
              'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1536440136628-849c177e76a1?w=1280&h=720&fit=crop',
          director: 'Christopher Nolan',
          cast: ['Cillian Murphy', 'Emily Blunt', 'Matt Damon', 'Robert Downey Jr.'],
          genres: ['Biography', 'Drama', 'History'],
          language: 'English',
          durationMinutes: 180,
          rating: 8.9,
          releaseDate: '2023',
          isGerman: false,
          isFeatured: true,
          showtimes: _generateShowtimes('int_001', 16.00),
        ),
        Movie(
          id: 'int_002',
          title: 'Dune: Part Two',
          titleDe: 'Dune: Teil Zwei',
          synopsis:
              'Paul Atreides unites with Chani and the Fremen while seeking revenge against the conspirators who destroyed his family.',
          synopsisDe:
              'Paul Atreides verbündet sich mit den Fremen und sucht Rache an den Verschwörern, die seine Familie zerstört haben.',
          posterUrl:
              'https://images.unsplash.com/photo-1446941303997-3f7c62b27d4d?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1446941303997-3f7c62b27d4d?w=1280&h=720&fit=crop',
          director: 'Denis Villeneuve',
          cast: ['Timothée Chalamet', 'Zendaya', 'Rebecca Ferguson'],
          genres: ['Sci-Fi', 'Adventure', 'Action'],
          language: 'English',
          durationMinutes: 166,
          rating: 8.6,
          releaseDate: '2024',
          isGerman: false,
          isFeatured: true,
          showtimes: _generateShowtimes('int_002', 16.00),
        ),
        Movie(
          id: 'int_003',
          title: 'The Zone of Interest',
          titleDe: 'Zone of Interest',
          synopsis:
              'The commandant of Auschwitz and his wife strive to build a dream life for their family in a house next to the camp.',
          synopsisDe:
              'Der Kommandant von Auschwitz und seine Frau versuchen, ihr Traumleben direkt neben dem Lager aufzubauen.',
          posterUrl:
              'https://images.unsplash.com/photo-1560169897-fc0cdbdfa4d5?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1560169897-fc0cdbdfa4d5?w=1280&h=720&fit=crop',
          director: 'Jonathan Glazer',
          cast: ['Christian Friedel', 'Sandra Hüller'],
          genres: ['Drama', 'History'],
          language: 'Deutsch / English',
          durationMinutes: 105,
          rating: 7.9,
          releaseDate: '2023',
          isGerman: false,
          showtimes: _generateShowtimes('int_003', 13.00),
        ),
        Movie(
          id: 'int_004',
          title: 'Poor Things',
          titleDe: 'Arme Dinge',
          synopsis:
              'The incredible tale about the fantastical evolution of Bella Baxter, a young woman brought back to life by the brilliant and unorthodox scientist Dr. Godwin Baxter.',
          synopsisDe:
              'Die außergewöhnliche Geschichte der jungen Bella Baxter, die vom exzentrischen Wissenschaftler Dr. Godwin Baxter zum Leben erweckt wird.',
          posterUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=1280&h=720&fit=crop',
          director: 'Yorgos Lanthimos',
          cast: ['Emma Stone', 'Mark Ruffalo', 'Willem Dafoe'],
          genres: ['Comedy', 'Drama', 'Fantasy'],
          language: 'English',
          durationMinutes: 141,
          rating: 8.0,
          releaseDate: '2023',
          isGerman: false,
          showtimes: _generateShowtimes('int_004', 14.50),
        ),
        Movie(
          id: 'int_005',
          title: 'All Quiet on the Western Front',
          titleDe: 'Im Westen nichts Neues',
          synopsis:
              'A young German soldier experiences the horrors of World War I on the western front.',
          synopsisDe:
              'Der junge Paul Bäumer erlebt den Ersten Weltkrieg hautnah an der Westfront – eine erschütternde Antikriegs-Geschichte.',
          posterUrl:
              'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1587174486073-ae5e5cff23aa?w=1280&h=720&fit=crop',
          director: 'Edward Berger',
          cast: ['Felix Kammerer', 'Albrecht Schuch', 'Aaron Hilmer'],
          genres: ['War', 'Drama'],
          language: 'Deutsch',
          durationMinutes: 147,
          rating: 7.8,
          releaseDate: '2022',
          isGerman: false,
          isFeatured: true,
          showtimes: _generateShowtimes('int_005', 14.00),
        ),
        Movie(
          id: 'int_006',
          title: 'Past Lives',
          titleDe: 'Vergangene Leben',
          synopsis:
              'Two childhood friends in Korea grow apart but reconnect over 20 years across continents.',
          synopsisDe:
              'Zwei Kindheitsfreunde in Korea wachsen getrennt auf und finden sich nach 20 Jahren über Kontinente hinweg wieder.',
          posterUrl:
              'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1553361371-9b22f78e8b1d?w=1280&h=720&fit=crop',
          director: 'Celine Song',
          cast: ['Greta Lee', 'Teo Yoo', 'John Magaro'],
          genres: ['Drama', 'Romance'],
          language: 'English / Korean',
          durationMinutes: 106,
          rating: 7.9,
          releaseDate: '2023',
          isGerman: false,
          showtimes: _generateShowtimes('int_006', 12.50),
        ),
        Movie(
          id: 'de_006',
          title: 'Head Full of Honey',
          titleDe: 'Honig im Kopf',
          synopsis:
              'When his grandfather develops Alzheimer\'s, young Tilda takes him on a spontaneous road trip to Venice.',
          synopsisDe:
              'Als ihr Großvater an Alzheimer erkrankt, bricht die kleine Tilda mit ihm spontan zu einer Reise nach Venedig auf.',
          posterUrl:
              'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1493246507139-91e8fad9978e?w=1280&h=720&fit=crop',
          director: 'Til Schweiger',
          cast: ['Til Schweiger', 'Emma Schweiger', 'Dieter Hallervorden'],
          genres: ['Komödie', 'Drama'],
          language: 'Deutsch',
          durationMinutes: 139,
          rating: 6.6,
          releaseDate: '2014',
          isGerman: true,
          showtimes: _generateShowtimes('de_006', 11.00),
        ),
        Movie(
          id: 'int_007',
          title: 'Anatomy of a Fall',
          titleDe: 'Anatomie eines Falls',
          synopsis:
              'A woman is suspected of her husband\'s murder when he is found dead below their house in the French Alps.',
          synopsisDe:
              'Eine Frau wird verdächtig, ihren Mann ermordet zu haben, nachdem er tot unter ihrem Chalet in den französischen Alpen gefunden wird.',
          posterUrl:
              'https://images.unsplash.com/photo-1508193638397-1c4234db14d8?w=400&h=600&fit=crop',
          backdropUrl:
              'https://images.unsplash.com/photo-1508193638397-1c4234db14d8?w=1280&h=720&fit=crop',
          director: 'Justine Triet',
          cast: ['Sandra Hüller', 'Swann Arlaud', 'Milo Machado-Graner'],
          genres: ['Drama', 'Thriller', 'Crime'],
          language: 'Français / Deutsch',
          durationMinutes: 152,
          rating: 8.0,
          releaseDate: '2023',
          isGerman: false,
          showtimes: _generateShowtimes('int_007', 13.50),
        ),
      ];

  static List<Showtime> _generateShowtimes(String movieId, double price) {
    final now = DateTime.now();
    final cinemas = ['Cinestar Berlin', 'UCI Kinowelt', 'Filmpalast München', 'CinemaXX Hamburg'];
    final halls = ['Saal 1', 'Saal 2', 'Saal 3 (IMAX)', 'Saal 4 (VIP)'];
    final times = [
      const Duration(hours: 10, minutes: 30),
      const Duration(hours: 13, minutes: 0),
      const Duration(hours: 15, minutes: 45),
      const Duration(hours: 18, minutes: 15),
      const Duration(hours: 20, minutes: 30),
      const Duration(hours: 22, minutes: 45),
    ];

    final List<Showtime> showtimes = [];
    int i = 0;

    for (int day = 0; day < 4; day++) {
      final date = now.add(Duration(days: day));
      for (final time in times) {
        final cinema = cinemas[i % cinemas.length];
        final hall = halls[i % halls.length];
        final actualPrice = hall.contains('IMAX')
            ? price + 4.0
            : hall.contains('VIP')
                ? price + 6.0
                : price;

        showtimes.add(Showtime(
          id: '${movieId}_st_$i',
          movieId: movieId,
          cinemaName: cinema,
          dateTime: DateTime(date.year, date.month, date.day,
              time.inHours, time.inMinutes % 60),
          hall: hall,
          price: actualPrice,
          bookedSeats: _randomBookedSeats(i),
        ));
        i++;
      }
    }
    return showtimes;
  }

  static List<String> _randomBookedSeats(int seed) {
    final rows = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];
    final booked = <String>[];
    final count = (seed % 5) * 3 + 5;
    for (int j = 0; j < count; j++) {
      final row = rows[(seed + j) % rows.length];
      final seat = ((seed * j + j) % 10) + 1;
      final seatId = '$row$seat';
      if (!booked.contains(seatId)) booked.add(seatId);
    }
    return booked;
  }

  static List<Movie> getFeaturedMovies() =>
      movies.where((m) => m.isFeatured).toList();

  static List<Movie> getGermanMovies() =>
      movies.where((m) => m.isGerman).toList();

  static List<Movie> getInternationalMovies() =>
      movies.where((m) => !m.isGerman).toList();

  static Movie? getMovieById(String id) {
    try {
      return movies.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }

  static List<Movie> searchMovies(String query) {
    final q = query.toLowerCase();
    return movies
        .where((m) =>
            m.title.toLowerCase().contains(q) ||
            m.titleDe.toLowerCase().contains(q) ||
            m.director.toLowerCase().contains(q) ||
            m.genres.any((g) => g.toLowerCase().contains(q)))
        .toList();
  }
}
