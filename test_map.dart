void main() {
  List<String> deps = ['A', 'B'];
  final List<Map<String, dynamic>> list = deps.map((p) => <String, dynamic>{
    'name': p,
    'opt': false,
  }).toList();
  print(list.runtimeType);
}
