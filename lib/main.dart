import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor:
            const Color.fromARGB(255, 107, 105, 105), // Фон для примера
        body: Stack(
          children: [
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Dock(
                  items: const [
                    Icons.folder,
                    Icons.music_note,
                    Icons.chrome_reader_mode,
                    Icons.calendar_today,
                    Icons.notes,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Dock extends StatefulWidget {
  final List<IconData> items;

  const Dock({super.key, required this.items});

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int _hoveredIndex = -1;
  int? _draggedIndex;

  @override
  void initState() {
    super.initState();
    // Создаем изменяемую копию списка, чтобы избежать ошибок с removeAt
    _items = List.of(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(8), // Слегка скругленные края
      ),
      height: 90, // Высота Dock
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final icon = entry.value;
          final distance = (_hoveredIndex - index).abs();
          final scale = distance == 0
              ? 1.5 // Максимальное увеличение для текущей иконки
              : distance == 1
                  ? 1.2 // Умеренное увеличение для соседних иконок
                  : 1.0; // Остальные иконки остаются без изменений

          return DragTarget<int>(
            onAccept: (fromIndex) {
              setState(() {
                final draggedItem = _items.removeAt(fromIndex);
                _items.insert(index, draggedItem);
                _draggedIndex = null; // Сбрасываем draggedIndex
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Visibility(
                visible:
                    _draggedIndex != index, // Скрываем перетаскиваемый элемент
                child: Draggable<int>(
                  data: index,
                  feedback: Transform.scale(
                    scale: 1.5,
                    child: _buildContainer(icon, scale: 1.5),
                  ),
                  childWhenDragging:
                      const SizedBox.shrink(), // Убираем элемент из вида
                  onDragStarted: () => setState(() {
                    _hoveredIndex = index;
                    _draggedIndex = index; // Устанавливаем draggedIndex
                  }),
                  onDragCompleted: () => setState(() {
                    _hoveredIndex = -1;
                    _draggedIndex = null;
                  }),
                  onDraggableCanceled: (_, __) => setState(() {
                    _hoveredIndex = -1;
                    _draggedIndex = null;
                  }),
                  child: MouseRegion(
                    onEnter: (_) => setState(() => _hoveredIndex = index),
                    onExit: (_) => setState(() => _hoveredIndex = -1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      width: 48 * scale,
                      height: 48 * scale,
                      child: _buildContainer(icon, scale: scale),
                    ),
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContainer(IconData icon, {required double scale}) {
    return Container(
      constraints: BoxConstraints(minWidth: 48 * scale),
      height: 48 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.primaries[icon.hashCode % Colors.primaries.length],
      ),
      child: Center(
        child: Icon(
          icon,
          size: 24 * scale,
          color: Colors.white,
        ),
      ),
    );
  }
}
