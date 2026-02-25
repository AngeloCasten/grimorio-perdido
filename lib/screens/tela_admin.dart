import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/grimorio_widgets.dart';

class TelaAdmin extends StatefulWidget {
  const TelaAdmin({super.key});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final _formKey = GlobalKey<FormState>();
  String _selectedEraId = "era_quinhentismo";
  
  // Controllers
  final _termoController = TextEditingController();
  final _definicaoController = TextEditingController();
  final _etimologiaController = TextEditingController();
  final _classeController = TextEditingController();
  final _fraseController = TextEditingController();
  final _autorController = TextEditingController();
  final _perguntaController = TextEditingController();
  final _opcoesController = TextEditingController(); // Separadas por vírgula
  final _indexCorretocontroller = TextEditingController();
  final _explicacaoController = TextEditingController();
  final _desafioController = TextEditingController();
  final _flexoesController = TextEditingController();

  bool _isGeneratingAI = false;

  void _simularGeracaoIA() async {
    setState(() => _isGeneratingAI = true);
    
    // Simulação de chamada de IA (aqui eu, o Assistente, "opero")
    await Future.delayed(const Duration(seconds: 2));
    
    // Exemplo de palavra gerada: "EFULGENTE"
    _termoController.text = "EFULGENTE";
    _definicaoController.text = "Que brilha muito; resplandecente, brilhante.";
    _etimologiaController.text = "Do latim: effulgere (brilhar intensamente).";
    _classeController.text = "Adjetivo";
    _fraseController.text = "Sua inteligência era ___, iluminando toda a sala.";
    _autorController.text = "Castro Alves (Simulado)";
    _perguntaController.text = "Qual o significado de efulgente?";
    _opcoesController.text = "Fosco, Brilhante, Escuro, Pequeno";
    _indexCorretocontroller.text = "1";
    _explicacaoController.text = "Efulgente vem de brilho intenso, como o sol.";
    _desafioController.text = "Descreva um momento efulgente da sua vida.";
    _flexoesController.text = "brilhante, radiante, luz";

    if (mounted) setState(() => _isGeneratingAI = false);
  }

  void _salvarPalavra() {
    if (_formKey.currentState!.validate()) {
      final game = Provider.of<GameProvider>(context, listen: false);
      
      final novaPalavra = PalavraMestra(
        id: "custom_${DateTime.now().millisecondsSinceEpoch}",
        termoPrincipal: _termoController.text,
        definicao: _definicaoController.text,
        etimologia: _etimologiaController.text,
        classeGramatical: _classeController.text,
        fraseLacuna: _fraseController.text,
        autorCitacao: _autorController.text,
        perguntaQuiz: _perguntaController.text,
        opcoesQuiz: _opcoesController.text.split(',').map((e) => e.trim()).toList(),
        indexCorretoQuiz: int.tryParse(_indexCorretocontroller.text) ?? 0,
        explicacaoErro: _explicacaoController.text,
        desafioCriativo: _desafioController.text,
        aceitasFlexoes: _flexoesController.text.split(',').map((e) => e.trim()).toList(),
      );

      game.adicionarPalavra(_selectedEraId, novaPalavra);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sabedoria adicionada ao Grimório!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FORJA DE CONHECIMENTO", style: TextStyle(color: Colors.redAccent, fontSize: 16)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _isGeneratingAI ? const CircularProgressIndicator() : const Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: _simularGeracaoIA,
            tooltip: "Pedir auxílio da IA",
          )
        ],
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text("CONFIGURAR NOVA PALAVRA MESTRA", style: TextStyle(color: Colors.white54, fontSize: 10)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedEraId,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("ERA DESTINO"),
                items: game.eras.map((era) {
                  return DropdownMenuItem(value: era.id, child: Text(era.nome));
                }).toList(),
                onChanged: (val) => setState(() => _selectedEraId = val!),
              ),
              
              const SizedBox(height: 15),
              _buildField(_termoController, "TERMO (EX: EFÊMERO)"),
              _buildField(_classeController, "CLASSE GRAMATICAL"),
              _buildField(_definicaoController, "DEFINIÇÃO COMPLETA", maxLines: 2),
              _buildField(_etimologiaController, "ETIMOLOGIA/ORIGEM"),
              _buildField(_fraseController, "FRASE COM LACUNA (USE ___)"),
              _buildField(_autorController, "AUTOR DA CITAÇÃO"),
              _buildField(_perguntaController, "PERGUNTA DO QUIZ"),
              _buildField(_opcoesController, "OPÇÕES DO QUIZ (SEPARADAS POR VÍRGULA)"),
              _buildField(_indexCorretocontroller, "INDEX DA RESPOSTA CORRETA (0-3)"),
              _buildField(_explicacaoController, "EXPLICAÇÃO EM CASO DE ERRO"),
              _buildField(_desafioController, "DESAFIO CRIATIVO"),
              _buildField(_flexoesController, "SINÔNIMOS ACEITOS (SEPARADOS POR VÍRGULA)"),
              
              const SizedBox(height: 30),
              BotaoMagico(
                texto: "FORJAR PALAVRA",
                cor: Colors.redAccent,
                onPressed: _salvarPalavra,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white, fontSize: 13),
        decoration: _inputDecoration(label),
        validator: (val) => val == null || val.isEmpty ? "Campo obrigatório" : null,
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white38, fontSize: 10),
      enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white10)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
    );
  }
}
