import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../screens/add_place_screen.dart';
import '../providers/user_places.dart';
import '../screens/place_detail_screen.dart';

enum PopupMenuOptions {
  ShowFavorites,
  ShowAll,
  SequenceEarlierAhead,
  SequenceLaterAhead,
  SequenceShuffle,
  SequenceNone,
}

// TODO add in menu or Drawer: Save in Preferences choise for list order (emum SequencePlacesList),
// and <_filterPlacesListBy> NONE, FAVORITE, TITLE, LOCATION (enum FilterPlacesListBy)

/// Provides showing the list of the places
class PlacesListScreen extends StatefulWidget {
  static const String MAIN_TAG = '## PlacesListScreen';
  @override
  _PlacesListScreenState createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  SequencePlacesList _sequencePlacesList = SequencePlacesList.EARLIER_AHEAD;
  FilterPlacesListBy _filterPlacesListBy = FilterPlacesListBy.NONE;

  @override
  Widget build(BuildContext context) {
    // Provider.of<UserPlaces>(context, listen: false).fetchAndSetPlaces();
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            onSelected: (PopupMenuOptions option) {
              setState(() {
                switch (option) {
                  case PopupMenuOptions.ShowFavorites:
                    {
                      _filterPlacesListBy = FilterPlacesListBy.FAVORITE;
                      break;
                    }
                  case PopupMenuOptions.ShowAll:
                    {
                      _filterPlacesListBy = FilterPlacesListBy.NONE;
                      break;
                    }
                  case PopupMenuOptions.SequenceEarlierAhead:
                    {
                      _sequencePlacesList = SequencePlacesList.EARLIER_AHEAD;
                      break;
                    }
                  case PopupMenuOptions.SequenceLaterAhead:
                    {
                      _sequencePlacesList = SequencePlacesList.LATER_AHEAD;
                      break;
                    }
                  case PopupMenuOptions.SequenceShuffle:
                    {
                      _sequencePlacesList = SequencePlacesList.SHUFFLE;
                      break;
                    }
                  case PopupMenuOptions.SequenceNone:
                    {
                      _sequencePlacesList = SequencePlacesList.NONE;
                      break;
                    }
                  default:
                    {
                      _filterPlacesListBy = FilterPlacesListBy.NONE;
                      _sequencePlacesList = SequencePlacesList.NONE;
                    }
                }
              });
            },
            itemBuilder: (ctx) => <PopupMenuEntry<PopupMenuOptions>>[
              PopupMenuItem(child: Text('--- Show List ---')),
              PopupMenuItem(
                value: PopupMenuOptions.ShowFavorites,
                child: Text('Only Favorits'),
              ),
              // PopupMenuDivider(height: 4.0),
              PopupMenuItem(
                value: PopupMenuOptions.ShowAll,
                child: Text('All places'),
              ),
              PopupMenuDivider(height: 16.0),
              PopupMenuItem(child: Text('--- Sort List ---')),
              PopupMenuItem(
                value: PopupMenuOptions.SequenceEarlierAhead,
                child: Text('Earlier Ahead'),
              ),
              PopupMenuItem(
                value: PopupMenuOptions.SequenceLaterAhead,
                child: Text('Later Ahead'),
              ),
              PopupMenuItem(
                value: PopupMenuOptions.SequenceShuffle,
                child: Text('Shuffle'),
              ),
              PopupMenuItem(
                value: PopupMenuOptions.SequenceNone,
                child: Text('None'),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(
              AddPlaceScreen.routeName,
            ),
            icon: Icon(Icons.add),
          ),
        ],
        centerTitle: true,
        title: Text('Your Places'),
      ),
      body: FutureBuilder(
        future:
            Provider.of<UserPlaces>(context, listen: false).fetchAndSetPlaces(
          filterBy: _filterPlacesListBy,
          listSequence: _sequencePlacesList,
        ),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(child: CircularProgressIndicator())
            : Consumer<UserPlaces>(
                child: Center(
                  child: const Text('Got no Places yet, start adding some!'),
                ),
                builder: (context, userPlaces, ch) => userPlaces.items.length <=
                        0
                    ? ch
                    : ListView.builder(
                        itemCount: userPlaces.items.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(width: 2.0),
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            elevation: 8.0,
                            margin:
                                const EdgeInsets.only(left: 5.0, right: 5.0),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: ListTile(
                                trailing: SizedBox(
                                  width: 40,
                                ),
                                // leading: CircleAvatar(
                                //   radius: 100.0,
                                //   backgroundImage:
                                //       FileImage(userPlaces.items[index].image),
                                leading: Image.file(
                                  userPlaces.items[index].image,
                                ),
                                title: Text('${userPlaces.items[index].title}'),
                                subtitle: Text(
                                    '${userPlaces.items[index].location.address}'),
                                onTap: () => Navigator.of(context).pushNamed(
                                    PlaceDetailScreen.routeName,
                                    arguments: userPlaces.items[index].id),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
      ),
    );
  }
}
