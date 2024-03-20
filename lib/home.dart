import 'package:flutter/material.dart';
import 'package:gphil/init/sanity.dart';
import 'package:gphil/library/score.dart';
import 'package:gphil/library_item.dart';
import 'package:gphil/library_item_card.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<dynamic> scores;

  @override
  void initState() {
    super.initState();
    scores = fetchScores();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('G-Phil Project'),
        centerTitle: true,
        backgroundColor: Colors.purple[800],
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        titleSpacing: double.minPositive,
      ),
      body: FutureBuilder(
        future: scores,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Score(
                            item: snapshot.data![index],
                          ),
                        ),
                      );
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    tileColor: Colors.purple[50],
                    title: Text(snapshot.data![index].shortTitle),
                    subtitle: Text(snapshot.data![index].composer),
                    // leading: LibraryItemCard(item: snapshot.data![index])
                  );
                },
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

const String query =
    '*[_type == "score" && private != true && complete>0] | order(title asc)';
const String params =
    "{_id,_updatedAt,_rev,composer,instrument,pathName,private,ready,complete,shortTitle,'slug': slug.current, layers}";

Future fetchScores() async {
  final response = await sanityClient.fetch(query + params);
  if (response == null) {
    return [];
  }
  return response.map((e) => LibraryItem.fromJson(e)).toList();
}
