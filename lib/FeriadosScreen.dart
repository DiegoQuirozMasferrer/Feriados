import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FeriadosScreen extends StatefulWidget {
  @override
  _FeriadosScreenState createState() => _FeriadosScreenState();
}

class _FeriadosScreenState extends State<FeriadosScreen> {
  List<Feriado> feriados = [];
  String year = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    fetchFeriados(year);
  }

  Future<void> fetchFeriados(String year) async {
    final url = Uri.parse('https://apis.digital.gob.cl/fl/feriados/$year');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        feriados = data.map((json) => Feriado.fromJson(json)).toList();
      });
    } else {
      throw Exception('Failed to load holidays');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feriados $year')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: year,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    year = value;
                    fetchFeriados(year);
                  });
                }
              },
              items: List.generate(
                5,
                    (index) => DropdownMenuItem(
                  value: (DateTime.now().year - index).toString(),
                  child: Text((DateTime.now().year - index).toString()),
                ),
              ),
            ),
          ),
          Expanded(
            child: feriados.isEmpty
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
              itemCount: feriados.length,
              itemBuilder: (context, index) {
                final feriado = feriados[index];
                return ListTile(
                  title: Text(feriado.nombre),
                  subtitle: Text(feriado.fecha),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Feriado {
  final String nombre;
  final String fecha;

  Feriado({required this.nombre, required this.fecha});

  factory Feriado.fromJson(Map<String, dynamic> json) {
    return Feriado(
      nombre: json['nombre'],
      fecha: json['fecha'],
    );
  }
}
