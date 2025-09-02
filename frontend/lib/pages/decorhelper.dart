import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

class DecorHelper {
  Widget buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final borderRadius = BorderRadius.circular(12);

    return GFTextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: const Color.fromARGB(255, 113, 128, 150)),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: borderRadius,
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
      ),
    );
  }

  Widget buildGradientButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 45,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 102, 126, 234),
            Color.fromARGB(255, 118, 75, 160),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
    bool showArrow = true,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        //color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromARGB(255, 179, 178, 178)),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 242, 242, 242),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            //color: (iconColor ?? Colors.blue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor ?? Colors.blue.shade600, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
        ),
        trailing: showArrow
            ? Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              )
            : null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.blue.shade600, size: 20),
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
                    color: const Color.fromARGB(255, 85, 84, 84),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'Not set' : value,
                  style: TextStyle(
                    fontSize: 16,
                    color: value.isEmpty
                        ? Colors.grey.shade400
                        : Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String generateLocationDescription(String city, String country) {
    if (city.toLowerCase() == 'kathmandu') {
      return '''Kathmandu, the capital of Nepal, is a vibrant city known for its rich history, temples, and cultural heritage. It is home to UNESCO World Heritage Sites like Swayambhunath (Monkey Temple) and Pashupatinath Temple. The city serves as a gateway to the Himalayas, attracting trekkers and mountaineers from around the world. Kathmandu is also a hub for arts, crafts, and traditional Nepali culture. It is the political, cultural, and economic center of Nepal.''';
    } else if (city.toLowerCase() == 'lalitpur') {
      return '''Lalitpur, also known as Patan, is one of the major cities of Nepal, located just south of Kathmandu. It is famous for its rich history, ancient temples, and Newar culture. Patan Durbar Square, a UNESCO World Heritage Site, showcases impressive architecture, art, and sculptures. The city is known for its craftsmanship, especially in metalwork and wood carving, and is home to the beautiful Patan Museum, which houses many religious and cultural artifacts.''';
    } else if (city.toLowerCase() == 'bhaktapur') {
      return '''Bhaktapur, an ancient city located east of Kathmandu, is renowned for its well-preserved medieval architecture and culture. The city is home to Bhaktapur Durbar Square, a UNESCO World Heritage Site, with stunning temples, courtyards, and shrines. Bhaktapur is famous for its festivals, arts, and crafts, particularly pottery. The city has a slower pace of life compared to Kathmandu, offering a glimpse into Nepal's traditional heritage.''';
    } else if (city.toLowerCase() == 'dhulikhel') {
      return '''Dhulikhel, a scenic town located about 30 kilometers east of Kathmandu, is known for its breathtaking views of the Himalayas, including peaks like Mount Everest and Langtang. It is a popular destination for trekking, hiking, and cultural experiences. Dhulikhel offers a glimpse of rural Nepali life, with its traditional Newar houses and temples. It is a peaceful getaway from the bustling Kathmandu Valley.''';
    } else if (city.toLowerCase() == 'pokhara') {
      return '''Pokhara, one of Nepal's most popular tourist destinations, is located in the central region of the country. Known for its stunning lakes like Phewa Lake and incredible views of the Annapurna mountain range, Pokhara is a hub for adventure tourism, including trekking, paragliding, and boating. The city is also famous for its vibrant atmosphere, with numerous restaurants, cafes, and shops catering to trekkers and tourists.''';
    } else if (city.toLowerCase() == 'lumbini') {
      return '''Lumbini, the birthplace of Lord Buddha, is located in the southwestern region of Nepal. It is a significant pilgrimage site for Buddhists from all over the world. The Lumbini Garden, where the Maya Devi Temple stands, is home to sacred monuments and peaceful surroundings. The site attracts thousands of visitors each year, who come to learn about Buddha's life and teachings.''';
    } else if (city.toLowerCase() == 'chitwan') {
      return '''Chitwan, located in the southern part of Nepal, is famous for the Chitwan National Park, a UNESCO World Heritage Site. The park is home to a diverse range of wildlife, including the endangered one-horned rhinoceros and Bengal tigers. Chitwan also offers opportunities for jungle safaris, bird watching, and canoeing in the Rapti River. It is a popular destination for nature lovers and wildlife enthusiasts.''';
    } else if (city.toLowerCase() == 'biratnagar') {
      return '''Biratnagar, located in the southeastern region of Nepal, is the second-largest city in the country. It is an industrial hub, with a growing economy based on agriculture, textiles, and manufacturing. Biratnagar is also known for its cultural diversity, with a mix of Hindu, Buddhist, and Muslim communities. The city is close to the border with India and serves as an important trade and commerce center.''';
    } else if (city.toLowerCase() == 'itahari') {
      return '''Itahari, a fast-growing city in the eastern region of Nepal, is known for its strategic location near the East-West Highway. It is an important commercial and transportation hub for the eastern part of the country. The city has a growing population and offers a range of services, including schools, hospitals, and shopping centers. Itahari is known for its pleasant climate and vibrant local markets.''';
    } else if (city.toLowerCase() == 'himalaya') {
      return '''The Himalayas, the world's highest mountain range, stretch across Nepal and several other countries in South Asia. Known for its towering peaks, including Mount Everest, the Himalayas are a paradise for trekkers, mountaineers, and nature enthusiasts. The region offers stunning landscapes, unique wildlife, and a rich cultural heritage, with many ethnic communities living in the foothills and valleys. The Himalayas attract adventurers from around the world.''';
    } else {
      return 'No detailed description available for this location.';
    }
  }
}
