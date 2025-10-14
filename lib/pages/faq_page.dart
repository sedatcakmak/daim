import 'package:flutter/material.dart';
import 'package:daim/widgets/bottom.dart';
import 'package:daim/widgets/header.dart';

class FAQ extends StatefulWidget {
  const FAQ({super.key});

  @override
  State<StatefulWidget> createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  List<Map<String, String>> faqList = [
    {
      "question": "Yıldız nasıl kazanılır?",
      "answer":
          "Kasanın yanında duran cihazdaki QR kodu okutarak veya çalışanın kendi uygulamasından göstereceği QR kodu okutarak yıldız kazanabilirsiniz.",
    },
    {
      "question": "Yıldız nasıl harcanır?",
      "answer":
          "Uygulama üzerinden yıldızlarınızı harcamak için sipariş QR'ını okutabilir veya hesabınızın QR kodunu çalışana göstererek hesabınızdaki yıldızı kullandırabilirsiniz.",
    },
    {
      "question": "Hesap QR kodu ne işe yarar?",
      "answer":
          "Hesap QR kodunuzu çalışana göstererek hesabınızdaki yıldız miktarını arttırabilir veya azaltabilirsiniz.",
    },
    {
      "question": "Kampanyalar nasıl görüntülenir?",
      "answer":
          "Uygulamanın 'Kampanyalar' bölümünden tüm güncel kampanyaları ve yıldız karşılıklarını görebilirsiniz.",
    },
    {
      "question": "Yıldızlarım ne kadar süre geçerli?",
      "answer": "Kazanılan yıldızlar hesabınızda süresiz şekilde kalır.",
    },
    {
      "question": "Uygulamayı nereden indirebilirim?",
      "answer":
          "Uygulamamız App Store ve Google Play üzerinden ücretsiz olarak indirilebilir.",
    },
    {
      "question": "QR kodum çalışmıyor, ne yapmalıyım?",
      "answer":
          "Telefon kamerasını ve internet bağlantınızı kontrol edin. Sorun devam ederse uygulama içinden 'Destek' bölümünden bize ulaşabilirsiniz.",
    },
  ];

  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    isExpandedList = List.generate(faqList.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Sık Sorulan Sorular"),
      bottomNavigationBar: CustomBottomNavBar(currentIndex: -1),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: ListView.builder(
          itemCount: faqList.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  isExpandedList[index] = !isExpandedList[index];
                });
              },
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              faqList[index]["question"]!,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(
                            isExpandedList[index]
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                      if (isExpandedList[index]) ...[
                        SizedBox(height: 8),
                        Text(
                          faqList[index]["answer"]!,
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
