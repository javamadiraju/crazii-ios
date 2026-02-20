import 'package:flutter/material.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_footer.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_home/crazii_header.dart';
import 'package:freebankingapp/freebankingapp/freebankingapp_pages/crazii_charts/select_chart/selectchart.dart';
class TradingChartInfo extends StatelessWidget {
  const TradingChartInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [ 
              CraziiHeader(productName: ' Crazii Charts'),    
            // Description text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22.0),
              child: Text(
                'Streamline your trading with CRAZII Charts, the ultimate monitoring tool tailored to your needs.',
                style: TextStyle(
                  fontFamily: 'Exo',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),

            // White card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose The Market and The Strategies For Monitoring',
                    style: TextStyle(
                      fontFamily: 'Exo',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose Your Market and Strategy: Select from 6+ markets and 3 proven strategies for focused analysis.\nCredit-Based Access: Activate a chart for just 1 credit—simple and affordable.\nReal-Time Notifications: Stay informed with instant alerts when your selected strategy is triggered.\nContinuous Monitoring: Gain full access to the chart until the market closes, ensuring you never miss an opportunity.\n\nWhether you are tracking stocks, forex, or other assets, CRAZII Charts ensures you are always in control.',
                    style: TextStyle(
                      fontFamily: 'Exo',
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '1 Credits',
                    style: TextStyle(
                      fontFamily: 'Exo',
                      fontSize: 16,
                      color: Color(0xFFB38F3F),
                    ),
                  ),
                ],
              ),
            ),

            // Buy button
             Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          child: ElevatedButton(
            onPressed: () {
              // Navigate to the new screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SelectChart()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB38F3F),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'BUY THIS PRODUCT',
              style: TextStyle(
                fontFamily: 'Exo',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

            const Spacer(),

             
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false, // Avoid adding top padding
        child: CraziiFooter(selectedIndex: 0),
      ),
    );
  }

  Widget _buildNavItem(String label, String iconUrl) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.network(
          iconUrl,
          width: 32,
          height: 32,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Exo',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

