import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musify/API/musify.dart';
import 'package:musify/extensions/l10n.dart';
import 'package:musify/main.dart';
import 'package:musify/style/app_themes.dart';
import 'package:musify/widgets/playlist_cube.dart';
import 'package:musify/widgets/spinner.dart';

class PlaylistsPage extends StatefulWidget {
  @override
  _PlaylistsPageState createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final TextEditingController _searchBar = TextEditingController();
  final FocusNode _inputNode = FocusNode();
  String _searchQuery = '';
  bool _showOnlyAlbums = false;

  Future<void> search() async {
    _searchQuery = _searchBar.text;
    setState(() {});
  }

  void toggleShowOnlyAlbums(bool value) {
    setState(() {
      _showOnlyAlbums = value;
    });
  }

  @override
  void dispose() {
    _searchBar.dispose();
    _inputNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.l10n!.playlists,
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            child: TextField(
              onSubmitted: (String value) {
                search();
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textInputAction: TextInputAction.search,
              controller: _searchBar,
              focusNode: _inputNode,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.primary,
              ),
              cursorColor: Colors.green[50],
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                  borderSide: BorderSide(color: colorScheme.primary),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    FluentIcons.search_24_regular,
                    color: colorScheme.primary,
                  ),
                  color: colorScheme.primary,
                  onPressed: () {
                    search();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                ),
                labelText: '${context.l10n!.search}...',
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Switch(
                value: _showOnlyAlbums,
                onChanged: toggleShowOnlyAlbums,
                thumbIcon: MaterialStateProperty.resolveWith<Icon?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return const Icon(
                        Icons.album,
                      );
                    }
                    return const Icon(
                      Icons.all_out,
                    );
                  },
                ),
              ),
            ],
          ),
          Expanded(
            child: FutureBuilder(
              future: _searchQuery.isEmpty
                  ? getPlaylists()
                  : getPlaylists(query: _searchQuery),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Spinner();
                } else if (snapshot.hasError) {
                  logger.log('Error on playlists page:  ${snapshot.error}');
                  return Center(
                    child: Text(context.l10n!.error),
                  );
                }

                late List _playlists;

                if (_showOnlyAlbums) {
                  _playlists = (snapshot.data as List)
                      .where((element) => element['isAlbum'] == true)
                      .toList();
                } else {
                  _playlists = snapshot.data as List;
                }

                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                  ),
                  itemCount: _playlists.length,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                  itemBuilder: (BuildContext context, index) {
                    final playlist = _playlists[index];

                    return Center(
                      child: PlaylistCube(
                        id: playlist['ytid'],
                        image: playlist['image'],
                        title: playlist['title'].toString(),
                        isAlbum: playlist['isAlbum'],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
