import 'package:flutter/material.dart';

class SearchPlaceholderCard extends StatelessWidget {
  const SearchPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, // Add a subtle shadow
      margin: const EdgeInsets.all(16), // Add some margin around the card
      child: Padding(
        padding: const EdgeInsets.all(24), // Add padding inside the card
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Important: Use min to avoid stretching
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 16,
          children: const [
            Icon(
              Icons.album,
              size: 64, // Make the icon larger
              color: Colors.grey,
            ),
            Text(
              'No results yet ...',
              textAlign: TextAlign.center, // Center the text
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
