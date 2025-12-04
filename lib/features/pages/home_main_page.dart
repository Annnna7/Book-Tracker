library;

import 'package:flutter/material.dart';

class HomeMainPage extends StatelessWidget {
  const HomeMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4ECE1), // Бежевый фон страницы
      body: SafeArea(
        child: Stack(
          children: [
            // Вытянутый эллипс - смещен еще больше влево и цвет C8C8C8
            Positioned(
              left: -MediaQuery.of(context).size.width * 0.5, // Еще больше смещение влево
              bottom: -MediaQuery.of(context).size.height * 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width * 1.4,
                height: MediaQuery.of(context).size.height * 1.0,
                decoration: BoxDecoration(
                  color: const Color(0xFFC8C8C8), // Новый цвет C8C8C8
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    topRight: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    bottomLeft: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                    bottomRight: Radius.circular(MediaQuery.of(context).size.width * 0.7),
                  ),
                ),
              ),
            ),

            // Контент
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Выравнивание влево как карточки
                children: [
                  // Заголовок Welcome - с таким же отступом слева как карточки
                  const Padding(
                    padding: EdgeInsets.only(top: 10.0, bottom: 30.0, left: 16.0),
                    child: Text(
                      'Welcome! :)',
                      style: TextStyle(
                        fontFamily: 'Allura',
                        fontSize: 33,
                        fontWeight: FontWeight.normal,
                        color: Colors.black87,
                      ),
                    ),
                  ),


                  // Центрируем карточки с фиксированной шириной
                  Center(
                    child: SizedBox(
                      width: 310, // Фиксированная ширина как в Figma
                      child: Column(
                        children: [
                          _buildFeatureCard(
                            context,
                            title: 'Добавьте книгу',
                            subtitle: 'Есть ли книга, которую вы читаете сейчас? Отмечайте прогресс и следите за ним',
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFeatureCard(
                            context,
                            title: 'Вишлист',
                            subtitle: 'Есть ли книга, которую вы хотите прочитать? Так она не потеряется в заметках :)',
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFeatureCard(
                            context,
                            title: 'Прочитанные',
                            subtitle: 'Уже прочитали книгу? Добавьте, чтобы собрать личную библиотеку и знать, что советовать другим',
                            onTap: () {},
                          ),
                          const SizedBox(height: 20),
                          
                          _buildFeatureCard(
                            context,
                            title: 'Статистика',
                            subtitle: 'Хотите узнать сколько книг вы прочитали? Тогда переходите сюда и узнавайте всё о вашем чтении',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF4ECE1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(30),
        ),
        side: BorderSide(
          color: const Color(0xFFC8C8C8).withOpacity(0.5), // Рамка цвета C8C8C8
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(30),
        ),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                  height: 1.4,
                ),
                maxLines: 4,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
