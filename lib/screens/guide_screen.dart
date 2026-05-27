import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('NASIL KILINIR?'),
          bottom: const TabBar(
            indicatorColor: Color(0xFFD4AF37),
            labelColor: Color(0xFFD4AF37),
            unselectedLabelColor: Colors.white60,
            tabs: [
              Tab(icon: Icon(Icons.info_outline), text: 'Genel Bilgi'),
              Tab(icon: Icon(Icons.looks_one), text: '1. Rekat'),
              Tab(icon: Icon(Icons.looks_two), text: '2. Rekat'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _GeneralInfoTab(),
            _FirstRekatTab(),
            _SecondRekatTab(),
          ],
        ),
      ),
    );
  }
}

class _GeneralInfoTab extends StatelessWidget {
  const _GeneralInfoTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFD4AF37)),
                    SizedBox(width: 8),
                    Text(
                      'Bayram Namazı Hükmü',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bayram namazı, kendilerine cuma namazı farz olan kimselere vaciptir. Yılda iki defa (Ramazan ve Kurban bayramlarında) cemaatle kılınır. Ezan ve kamet getirilmez.',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const Divider(height: 30, color: Color(0x33D4AF37)),
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFD4AF37)),
                    SizedBox(width: 8),
                    Text(
                      'Normal Namazdan Farkı',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Bayram namazını diğer namazlardan ayıran en önemli özellik, her iki rekatında kılınırken alınan fazladan "Zaid Tekbirler"dir (toplamda 6 fazla tekbir alınır ve eller kulaklara kaldırılır).',
                  style: TextStyle(fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0x11D4AF37),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0x33D4AF37)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Color(0xFFD4AF37)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kısaca Formül: İki Sallama Bir Bağlama, Üç Sallama Bir Eğilme!',
                          style: TextStyle(
                            color: Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
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
    );
  }
}

class _FirstRekatTab extends StatelessWidget {
  const _FirstRekatTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStepCard(
          stepNumber: '1',
          title: 'Niyet Edilir',
          desc: 'İmamın arkasında niyet edilir:\n"Niyet ettim Allah rızası için vacip olan Ramazan/Kurban Bayramı namazını kılmaya, uydum hazır olan imama."',
        ),
        _buildStepCard(
          stepNumber: '2',
          title: 'İftitah Tekbiri Alınır',
          desc: 'İmamla birlikte "Allahu Ekber" diyerek eller kulak hizasına kaldırılır ve göbek hizasında bağlanır. Sessizce "Sübhaneke" duası okunur.',
        ),
        _buildStepCard(
          stepNumber: '3',
          title: '1. Zaid Tekbir (Kulaklar Serbest)',
          desc: 'İmam "Allahu Ekber" der. Eller kulaklara kaldırılır ve yanlara salınır (bağlanmaz).',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '4',
          title: '2. Zaid Tekbir (Kulaklar Serbest)',
          desc: 'İmam tekrar "Allahu Ekber" der. Eller kulaklara kaldırılır ve yine yanlara salınır.',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '5',
          title: '3. Zaid Tekbir (Eller Bağlanır)',
          desc: 'İmam üçüncü kez "Allahu Ekber" der. Eller kulaklara kaldırılır ve bu sefer göbek hizasında bağlanır.',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '6',
          title: 'Kıraat, Rükû ve Secde',
          desc: 'İmam içinden euzü-besmele çeker, dışından Fatiha suresi ve bir zammı sure okur. Ardından "Allahu Ekber" diyerek rükûa gidilir, peşinden secdeler yapılarak 2. rekata doğrulunur.',
        ),
      ],
    );
  }
}

class _SecondRekatTab extends StatelessWidget {
  const _SecondRekatTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildStepCard(
          stepNumber: '1',
          title: 'Kıraat (Okuma)',
          desc: 'İkinci rekata kalkınca imam içinden besmele çeker, dışından Fatiha suresi ve zammı sure okur. Rükuya gitmeden önce durulur.',
        ),
        _buildStepCard(
          stepNumber: '2',
          title: '1. Zaid Tekbir (Kulaklar Serbest)',
          desc: 'İmam "Allahu Ekber" der. Eller kaldırılır ve yanlara salınır.',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '3',
          title: '2. Zaid Tekbir (Kulaklar Serbest)',
          desc: 'İmam tekrar "Allahu Ekber" der. Eller kaldırılır ve yanlara salınır.',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '4',
          title: '3. Zaid Tekbir (Kulaklar Serbest)',
          desc: 'İmam bir daha "Allahu Ekber" der. Eller kaldırılır ve yanlara salınır.',
          isExtra: true,
        ),
        _buildStepCard(
          stepNumber: '5',
          title: 'Rükûa Gidiş Tekbiri (Eğilme)',
          desc: 'Dördüncü kez "Allahu Ekber" denilince eller kaldırılmadan doğrudan rükûa gidilir.',
        ),
        _buildStepCard(
          stepNumber: '6',
          title: 'Secde, Tahiyyat ve Selam',
          desc: 'Secdelere gidilir. Son oturuşta (Ka\'de-i Ahire) sırasıyla Ettehıyyatü, Salli-Barik ve Rabbena duaları okunur. Önce sağa sonra sola selam verilerek bayram namazı tamamlanır.',
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String desc,
    bool isExtra = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: isExtra ? const Color(0xFFD4AF37) : const Color(0xFF0F4C3A),
              foregroundColor: isExtra ? const Color(0xFF071B15) : Colors.white,
              radius: 16,
              child: Text(
                stepNumber,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isExtra ? const Color(0xFFD4AF37) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  if (isExtra) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0x22D4AF37),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0x66D4AF37)),
                      ),
                      child: const Text(
                        'İlave (Zaid) Tekbir',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFD4AF37),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
