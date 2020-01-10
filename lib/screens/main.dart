import 'package:fast_shopping/i18n/i18n.dart';
import 'package:fast_shopping/models/models.dart' as models;
import 'package:fast_shopping/widgets/widgets.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _items = [
    Item(models.Item('Herbatniki duża paczka')),
    Item(models.Item('3x bita śmietana (proszek)')),
    Item(models.Item('0,5l śmietany 30% karton')),
    Item(models.Item('Krem karpatka proszek', true, DateTime.now())),
    Item(models.Item(
        'Masa kajmakowa/krówkowa (puszka) albo mleko skondensowane jak nie będzie')),
    Item(models.Item('Kapusta czerwona 2x średnie')),
    Item(models.Item('6 cebul czerwonych')),
  ];

  bool _shouldShowFab(BuildContext context) =>
      MediaQuery.of(context).viewInsets.bottom == 0;

  bool _shouldShowArchiveBanner() => _items.every((item) => item.item.done);

  void _deleteItem(BuildContext context, Item item) {
    setState(() => item.item.removed = true);
    item.key.currentState.collapse();

    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context)
        .showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('item_removed_snackbar_message'.i18n),
            action: SnackBarAction(
              textColor: PrimaryFlatButton.buttonColor,
              label: 'item_removed_snackbar_undo'.i18n,
              onPressed: () {
                setState(() => item.item.removed = false);
              },
            ),
          ),
        )
        .closed
        .then((reason) {
      if (reason != SnackBarClosedReason.action) {
        setState(() => _items.remove(item));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.i18n),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: _shouldShowFab(context)
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () async {
                final result = await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AddItemDialog(),
                );

                if (result != null) {
                  setState(() {
                    _items.add(Item(models.Item(result as String)));
                  });
                }
              },
            )
          : null,
      body: ListView.builder(
        itemCount: _items.length + 1,
        itemBuilder: (context, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AnimatedCrossFade(
                firstCurve: Curves.ease,
                secondCurve: Curves.ease,
                sizeCurve: Curves.ease,
                duration: const Duration(milliseconds: 300),
                crossFadeState: _shouldShowArchiveBanner()
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                firstChild: ArchiveBanner(
                  onArchiveTap: () {},
                ),
                secondChild: const SizedBox(width: double.infinity),
              ),
            );
          }

          final item = _items[i - 1];

          return AnimatedCrossFade(
            key: ObjectKey(item),
            firstCurve: Curves.ease,
            secondCurve: Curves.ease,
            sizeCurve: Curves.ease,
            duration: const Duration(milliseconds: 300),
            crossFadeState: item.item.removed
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: ListItemTile(
                key: item.key,
                title: item.item.title,
                done: item.item.done,
                doneAt: item.item.doneAt,
                onDoneTap: (value) {
                  setState(() {
                    item.item.done = value;
                    if (value) {
                      item.item.doneAt = DateTime.now();
                    } else {
                      item.item.doneAt = null;
                    }
                  });
                },
                onTitleEdited: (newTitle) {
                  setState(() => item.item.title = newTitle);
                },
                onDeleteTap: () => _deleteItem(context, item),
                onExpand: () {
                  _items.where((a) => a != item).forEach((otherItem) {
                    otherItem.key.currentState?.collapse();
                  });
                },
                dragHandler: ListItemDragHandler(
                  onDragStart: (details) {
                    debugPrint(details.toString());
                  },
                  onDragUpdate: (details) {
                    debugPrint(details.toString());
                  },
                  onDragEnd: (details) {
                    debugPrint(details.toString());
                  },
                ),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          );
        },
      ),
    );
  }
}

class Item {
  final models.Item item;
  final GlobalKey<ListItemTileState> key;

  Item(this.item) : key = GlobalKey();
}