import 'dart:math';
import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // УВЕЛИЧИВАЕМ пропорции для эллипса (больше и выше)
    final ellipseWidth = screenWidth * (4500 / 375); // Было 450, теперь 600
    final ellipseHeight = ellipseWidth * (12000 / 583); // Было 994, теперь 1200
    final visibleHeight = screenHeight * 1.2; // Больше видимой части
    final hiddenHeight = ellipseHeight - visibleHeight;

    final int totalBooks = 24;
    final int readBooks = 12;
    final int totalPagesRead = 3847;
    
    // Топ авторов
    final List<String> topAuthors = [
      'Джоан Роулинг',
      'Рэй Брэдбери',
      'Джонатан Фоер'
    ];
    
    // Данные для круговой диаграммы
    final List<GenreData> genreData = [
      GenreData(name: 'Фэнтези', count: 4, color: const Color(0xFF978670)),
      GenreData(name: 'Приключения', count: 2, color: const Color(0xFFDAB27B)),
      GenreData(name: 'Мистика', count: 1, color: const Color(0xFFFADAAD)),
    ];
    
    // Данные для столбчатой диаграммы (книг по месяцам)
    final List<MonthData> monthData = [
      MonthData(month: 'Я', books: 3), // Январь
      MonthData(month: 'Ф', books: 2), // Февраль
      MonthData(month: 'М', books: 4), // Март
      MonthData(month: 'А', books: 1), // Апрель
      MonthData(month: 'М', books: 3), // Май
      MonthData(month: 'И', books: 5), // Июнь
      MonthData(month: 'И', books: 2), // Июль
      MonthData(month: 'А', books: 3), // Август
      MonthData(month: 'С', books: 4), // Сентябрь
      MonthData(month: 'О', books: 2), // Октябрь
      MonthData(month: 'Н', books: 3), // Ноябрь
      MonthData(month: 'Д', books: 1), // Декабрь
    ];
    
    // Рассчитываем проценты для круговой диаграммы
    final totalGenres = genreData.fold(0, (sum, genre) => sum + genre.count);
    for (var genre in genreData) {
      genre.percentage = (genre.count / totalGenres * 100).toInt();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4ECE1),
      body: Stack(
        children: [
          // КОРИЧНЕВЫЙ ОВАЛ (увеличенный и сдвинут вправо)
          Positioned(
            top: -hiddenHeight * 0.7, // Поднимаем выше, чтобы не было видно низа
            right: -ellipseWidth * 0.4, // Сдвигаем еще больше вправо
            child: Container(
              width: ellipseWidth,
              height: ellipseHeight,
              decoration: BoxDecoration(
                color: const Color(0xFF765745),
                borderRadius: BorderRadius.vertical(
                  top: Radius.elliptical(ellipseWidth * 0.1, ellipseHeight * 0.1), // Более плавные кривые
                  bottom: Radius.elliptical(ellipseWidth * 0.1, ellipseHeight * 0.1),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Кастомный AppBar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30),
                        color: Colors.white,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            'Статистика',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Основной контент
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Первый раздел: Всего книг
                        Container(
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 250,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Всего книг в вашей библиотеке',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -30,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFD9D9D9),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        readBooks.toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF432706),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Второй раздел: Страниц прочитано
                        Container(
                          height: 140,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 250,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'Страниц прочитано итого',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -30,
                                  child: Container(
                                    width: 80,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        totalPagesRead.toString(),
                                        style: const TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF432706),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Третий раздел: Топ авторов
                        Container(
                          height: 180,
                          margin: const EdgeInsets.only(bottom: 80),
                          child: Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 250,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD9D9D9).withOpacity(0.4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.only(top: 20),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Text(
                                        'Топ ваших любимых авторов',
                                        style: TextStyle(
                                          fontFamily: 'Montserrat',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: -50,
                                  child: Container(
                                    width: 200,
                                    height: 100,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color.fromRGBO(0, 0, 0, 0.15),
                                          blurRadius: 6,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        for (int i = 0; i < topAuthors.length; i++)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Text(
                                                  '${i + 1}. ',
                                                  style: const TextStyle(
                                                    fontFamily: 'Montserrat',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF432706),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    topAuthors[i],
                                                    style: const TextStyle(
                                                      fontFamily: 'Montserrat',
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w500,
                                                      color: Color(0xFF432706),
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Четвертый раздел: Часто читаемые жанры
                        Center(
                          child: Container(
                            width: 350,
                            height: 180,
                            margin: const EdgeInsets.only(bottom: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFF251608).withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Часто читаемые жанры:',
                                      style: TextStyle(
                                        fontFamily: 'Montserrat',
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  
                                  Expanded(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 100,
                                          height: 100,
                                          child: CustomPaint(
                                            painter: PieChartPainter(genreData: genreData),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              for (var genre in genreData)
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 8),
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 12,
                                                        height: 12,
                                                        margin: const EdgeInsets.only(right: 8),
                                                        decoration: BoxDecoration(
                                                          color: genre.color,
                                                          shape: BoxShape.circle,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${genre.name} - ${genre.count} ${_getBookWord(genre.count)}',
                                                        style: const TextStyle(
                                                          fontFamily: 'Montserrat',
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Пятый раздел: Столбчатая диаграмма
                        const SizedBox(height: 20),
                        const Align(
                          alignment: Alignment.center,
                          child: Text(
                            'Количество книг, прочитанных за год',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Контейнер для столбчатой диаграммы с горизонтальной прокруткой
                        Container(
                          height: 240,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Container(
                              width: 650,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: BarChartWidget(monthData: monthData),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Вспомогательный метод для склонения слова "книга"
  String _getBookWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'книга';
    if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return 'книги';
    }
    return 'книг';
  }
}

// Модель данных для жанров
class GenreData {
  final String name;
  final int count;
  final Color color;
  int percentage = 0;
  
  GenreData({
    required this.name,
    required this.count,
    required this.color,
  });
}

// Модель данных для месяцев
class MonthData {
  final String month;
  final int books;
  
  MonthData({
    required this.month,
    required this.books,
  });
}

// Виджет столбчатой диаграммы
class BarChartWidget extends StatelessWidget {
  final List<MonthData> monthData;
  
  const BarChartWidget({Key? key, required this.monthData}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Находим максимальное значение для масштабирования
    final maxBooks = monthData.map((m) => m.books).reduce(max);
    
    return Container(
      height: 220,
      child: CustomPaint(
        painter: BarChartPainter(monthData: monthData, maxValue: maxBooks),
        size: Size(600, 220),
      ),
    );
  }
}

// Painter для столбчатой диаграммы
class BarChartPainter extends CustomPainter {
  final List<MonthData> monthData;
  final int maxValue;
  
  BarChartPainter({required this.monthData, required this.maxValue});
  
  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 25.0;
    final barSpacing = 20.0;
    final chartHeight = size.height * 0.7;
    final bottomPadding = size.height * 0.15;
    final topPadding = size.height * 0.1;
    final chartAreaHeight = chartHeight - bottomPadding - topPadding;
    
    // Рисуем ось Y (вертикальная линия слева)
    final axisPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    final yAxisStart = Offset(30, topPadding);
    final yAxisEnd = Offset(30, chartHeight - bottomPadding);
    canvas.drawLine(yAxisStart, yAxisEnd, axisPaint);
    
    // Рисуем ось X (горизонтальная линия внизу)
    final xAxisStart = Offset(30, chartHeight - bottomPadding);
    final xAxisEnd = Offset(size.width - 30, chartHeight - bottomPadding);
    canvas.drawLine(xAxisStart, xAxisEnd, axisPaint);
    
    // Рисуем деления на оси Y
    final divisions = maxValue > 5 ? 5 : maxValue;
    for (int i = 0; i <= divisions; i++) {
      final value = (maxValue / divisions * i).toInt();
      final y = topPadding + chartAreaHeight - (chartAreaHeight / divisions * i);
      
      // Деление (короткая линия влево от оси)
      final tickPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      final tickStart = Offset(25, y);
      final tickEnd = Offset(35, y);
      canvas.drawLine(tickStart, tickEnd, tickPaint);
      
      // Подпись значения (нежирный)
      final textSpan = TextSpan(
        text: value.toString(),
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      );
      
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.right,
        textDirection: TextDirection.ltr,
      )..layout();
      
      textPainter.paint(
        canvas,
        Offset(15 - textPainter.width, y - textPainter.height / 2),
      );
    }
    
    // Рисуем столбцы и подписи месяцев
    for (int i = 0; i < monthData.length; i++) {
      final month = monthData[i];
      final x = 50 + i * (barWidth + barSpacing);
      final barHeight = (month.books / maxValue) * chartAreaHeight;
      final barY = chartHeight - bottomPadding - barHeight;
      
      // Рисуем столбец
      final barPaint = Paint()
        ..color = const Color(0xFFFFE7C5)
        ..style = PaintingStyle.fill;
      
      final barRect = Rect.fromLTWH(x, barY, barWidth, barHeight);
      canvas.drawRect(barRect, barPaint);
      
      // Обводка столбца
      final borderPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawRect(barRect, borderPaint);
      
      // Деление на оси X (вертикальная линия вниз от оси)
      final xTickPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      
      final xTickStart = Offset(x + barWidth / 2, chartHeight - bottomPadding);
      final xTickEnd = Offset(x + barWidth / 2, chartHeight - bottomPadding + 6);
      canvas.drawLine(xTickStart, xTickEnd, xTickPaint);
      
      // Подпись месяца (под делениями)
      final monthTextSpan = TextSpan(
        text: month.month,
        style: const TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      );
      
      final monthTextPainter = TextPainter(
        text: monthTextSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      
      monthTextPainter.paint(
        canvas,
        Offset(x + barWidth / 2 - monthTextPainter.width / 2, chartHeight - bottomPadding + 10),
      );
      
      // Число книг над столбцом (нежирный)
      if (month.books > 0) {
        final countTextSpan = TextSpan(
          text: month.books.toString(),
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        );
        
        final countTextPainter = TextPainter(
          text: countTextSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        
        countTextPainter.paint(
          canvas,
          Offset(x + barWidth / 2 - countTextPainter.width / 2, barY - countTextPainter.height - 2),
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Кастомный Painter для круговой диаграммы с процентами в секторах
class PieChartPainter extends CustomPainter {
  final List<GenreData> genreData;
  
  PieChartPainter({required this.genreData});

  @override
  void paint(Canvas canvas, Size size) {
    final total = genreData.fold(0, (sum, genre) => sum + genre.count);
    if (total == 0) return;
    
    double startAngle = -90 * (pi / 180);
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    // Общая обводка круга
    final circlePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    canvas.drawCircle(center, radius, circlePaint);
    
    // Рисуем секторы
    for (var genre in genreData) {
      final sweepAngle = 360 * (genre.count / total) * (pi / 180);
      final percentage = (genre.count / total * 100).toInt();
      
      // Основной цвет сектора
      final fillPaint = Paint()
        ..color = genre.color
        ..style = PaintingStyle.fill;
      
      final rect = Rect.fromCircle(center: center, radius: radius);
      
      // Рисуем сектор
      canvas.drawArc(rect, startAngle, sweepAngle, true, fillPaint);
      
      // Добавляем текст с процентом в центр сектора
      if (percentage > 0) {
        final textSpan = TextSpan(
          text: '$percentage%',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
        
        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        
        final midAngle = startAngle + sweepAngle / 2;
        final textRadius = radius * 0.6;
        final textX = center.dx + textRadius * cos(midAngle) - textPainter.width / 2;
        final textY = center.dy + textRadius * sin(midAngle) - textPainter.height / 2;
        
        canvas.save();
        canvas.translate(textX, textY);
        textPainter.paint(canvas, Offset.zero);
        canvas.restore();
      }
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}