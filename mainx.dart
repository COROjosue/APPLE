import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Directorio de Personas',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: const Color(0xFFE8EEF1),
      ),
      home: PersonasScreen(),
    );
  }
}

class PersonasScreen extends StatefulWidget {
  @override
  _PersonasScreenState createState() => _PersonasScreenState();
}

class _PersonasScreenState extends State<PersonasScreen> {
  List personas = [];
  List filteredPersonas = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPersonas();
  }

  Future<void> fetchPersonas() async {
    try {
      final response = await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);

        // Convertimos datos de la API a nuestro formato
        List apiPersonas = data.map((item) {
          return {
            "persona": item["name"],
            "sexo": "No especificado",
            "telefono": item["phone"] ?? "N/A",
            "acerca_de": item["company"]["catchPhrase"] ?? "Sin descripción",
          };
        }).toList();

        // Datos locales adicionales (los 5 registros nuevos)
        List localPersonas = [
          {
            "persona": "Carlos Jiménez",
            "sexo": "Masculino",
            "telefono": "0987456123",
            "acerca_de": "Ingeniero en sistemas con pasión por la robótica."
          },
          {
            "persona": "María Torres",
            "sexo": "Femenino",
            "telefono": "0998765432",
            "acerca_de": "Diseñadora UX/UI enfocada en accesibilidad digital."
          },
          {
            "persona": "Andrés Pérez",
            "sexo": "Masculino",
            "telefono": "0981122334",
            "acerca_de": "Desarrollador backend con experiencia en APIs REST."
          },
          {
            "persona": "Luisa Gómez",
            "sexo": "Femenino",
            "telefono": "0976543211",
            "acerca_de": "Project Manager con certificación Scrum Master."
          },
          {
            "persona": "Pedro Cevallos",
            "sexo": "Masculino",
            "telefono": "0983344556",
            "acerca_de": "Técnico de soporte especializado en redes y hardware."
          },
        ];

        setState(() {
          personas = [...apiPersonas, ...localPersonas];
          filteredPersonas = personas;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error al cargar datos: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSearch(String query) {
    final results = personas.where((persona) {
      final nombre = persona["persona"].toLowerCase();
      final buscar = query.toLowerCase();
      return nombre.contains(buscar);
    }).toList();

    setState(() {
      filteredPersonas = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Directorio de Personas"),
        centerTitle: true,
        backgroundColor: Colors.blueGrey.shade700,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: TextField(
                    onChanged: filterSearch,
                    decoration: InputDecoration(
                      hintText: 'Buscar persona...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredPersonas.length,
                    itemBuilder: (context, index) {
                      final persona = filteredPersonas[index];
                      return Card(
                        color: Colors.white,
                        elevation: 3,
                        margin:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueGrey.shade300,
                            child: Text(
                              persona["persona"][0],
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            persona["persona"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text("Sexo: ${persona["sexo"]}"),
                              Text("Teléfono: ${persona["telefono"]}"),
                              Text("Acerca de: ${persona["acerca_de"]}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
