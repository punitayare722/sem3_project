import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final List<Map<String, dynamic>> plants = [
    {
      'name': 'Aloe Vera',
      'image': 'assets/images/aloevera.jpg',
      'description':
          'Aloe Vera is a succulent plant species of the genus Aloe.',
      'growthGuide': 'Grows best in sandy soil with a lot of sunlight.',
      'wateringDetails': 'Water every 3 weeks, let soil dry in between.',
      'sunlightInfo': 'Needs direct sunlight for at least 6 hours daily.'
    },
    {
      'name': 'Cactus',
      'image': 'assets/images/cactus.jpg',
      'description':
          'Cactus is a family of flowering plants in the order Caryophyllales.',
      'growthGuide': 'Grows well in dry soil and requires minimal watering.',
      'wateringDetails': 'Water only once a week or when the soil is dry.',
      'sunlightInfo': 'Requires full sun exposure.'
    },
    {
      'name': 'Snake Plant',
      'image': 'assets/images/snakeplant.jpg',
      'description': 'Snake plants are resilient, low-maintenance plants.',
      'growthGuide': 'Can grow in both low and bright light conditions.',
      'wateringDetails': 'Water once every 2-3 weeks.',
      'sunlightInfo': 'Prefers indirect sunlight but tolerates low light.'
    },
    {
      'name': 'Rose',
      'image': 'assets/images/rose.jpg',
      'description':
          'Roses are perennial plants known for their beautiful flowers.',
      'growthGuide': 'Requires well-drained soil and consistent watering.',
      'wateringDetails': 'Water frequently but ensure the soil is not soggy.',
      'sunlightInfo': 'Needs 4-6 hours of direct sunlight daily.'
    },
    {
      'name': 'Basil',
      'image': 'assets/images/basil.jpg',
      'description': 'Basil is a culinary herb used in many dishes.',
      'growthGuide': 'Prefers moist, well-drained soil and regular trimming.',
      'wateringDetails': 'Water once the topsoil feels dry.',
      'sunlightInfo': 'Requires at least 6 hours of sunlight daily.'
    },
    // Add other plants with similar information
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant Guide'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green, Colors.teal],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: PlantSearchDelegate(plants: plants),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final plant = plants[index];
            return GestureDetector(
              onTap: () {
                // Navigate to the plant details page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlantDetailsPage(plant: plant),
                  ),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.asset(
                          plant['image'],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            plant['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PlantDetailsPage extends StatelessWidget {
  final Map<String, dynamic> plant;

  const PlantDetailsPage({Key? key, required this.plant}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          plant['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                plant['image'],
                fit: BoxFit.cover,
                height: 250,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Description'),
            _buildTextSection(plant['description']),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Growth Guide'),
            _buildTextSection(plant['growthGuide']),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Watering Details'),
            _buildTextSection(plant['wateringDetails']),
            const SizedBox(height: 16),
            _buildSectionTitle(context, 'Sunlight Information'),
            _buildTextSection(plant['sunlightInfo']),
            const SizedBox(height: 32),
            _buildBuyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextSection(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildBuyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _launchURL,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
      child: const Text(
        'Buy Now',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Method to launch the URL
  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://nurserylive.com/collections/gardening');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }
}

class PlantSearchDelegate extends SearchDelegate {
  final List<Map<String, dynamic>> plants;

  PlantSearchDelegate({required this.plants});

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Map<String, dynamic>> results = plants
        .where((plant) =>
            plant['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final plant = results[index];
        return GestureDetector(
          onTap: () {
            // Navigate to the plant details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantDetailsPage(plant: plant),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      plant['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Map<String, dynamic>> suggestions = plants
        .where((plant) =>
            plant['name'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final plant = suggestions[index];
        return GestureDetector(
          onTap: () {
            // Navigate to the plant details page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlantDetailsPage(plant: plant),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      plant['image'],
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text('₹${plant['price']}',
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
