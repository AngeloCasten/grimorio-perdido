import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/game_models.dart';
import '../widgets/grimorio_widgets.dart';
import '../services/ai_service.dart';

class TelaAdmin extends StatefulWidget {
  final String? initialEraId;
  final PalavraMestra? palavraParaEditar;
  
  const TelaAdmin({super.key, this.initialEraId, this.palavraParaEditar});

  @override
  State<TelaAdmin> createState() => _TelaAdminState();
}

class _TelaAdminState extends State<TelaAdmin> {
  final _formKey = GlobalKey<FormState>();
  late String _selectedEraId;
  
  // Controllers
  final _termoController = TextEditingController();
  final _definicaoController = TextEditingController();
  final _etimologiaController = TextEditingController();
  final _classeController = TextEditingController();
  final _fraseController = TextEditingController();
  final _autorController = TextEditingController();
  final _perguntaController = TextEditingController();
  final _opcoesController = TextEditingController();
  final _indexCorretocontroller = TextEditingController();
  final _explicacaoController = TextEditingController();
  final _desafioController = TextEditingController();
  final _flexoesController = TextEditingController();
  final _xpController = TextEditingController(text: "200");

  bool _isGeneratingAI = false;

  @override
  void initState() {
    super.initState();
    _selectedEraId = widget.initialEraId ?? "era_quinhentismo";
    
    if (widget.palavraParaEditar != null) {
      final p = widget.palavraParaEditar!;
      _termoController.text = p.termoPrincipal;
      _definicaoController.text = p.definicao;
      _etimologiaController.text = p.etimologia;
      _classeController.text = p.classeGramatical;
      _fraseController.text = p.fraseLacuna;
      _autorController.text = p.autorCitacao;
      _perguntaController.text = p.perguntaQuiz;
      _opcoesController.text = p.opcoesQuiz.join(', ');
      _indexCorretocontroller.text = p.indexCorretoQuiz.toString();
      _explicacaoController.text = p.explicacaoErro;
      _desafioController.text = p.desafioCriativo;
      _flexoesController.text = p.aceitasFlexoes.join(', ');
      _xpController.text = p.xpValor.toString();
    }
  }

  void _simularGeracaoIA() async {
    if (_termoController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Digite o termo primeiro!")));
      return;
    }
    
    setState(() => _isGeneratingAI = true);
    final data = await AIService.generateWordContent(_termoController.text);
    
    if (data != null && mounted) {
      _definicaoController.text = data['definicao'] ?? "";
      _etimologiaController.text = data['etimologia'] ?? "";
      _classeController.text = data['classe_gramatical'] ?? "";
      _fraseController.text = data['frase_lacuna'] ?? "";
      _autorController.text = data['autor_citacao'] ?? "";
      _perguntaController.text = data['pergunta_quiz'] ?? "";
      _opcoesController.text = (data['opcoes_quiz'] as List).join(', ');
      _indexCorretocontroller.text = data['index_correto_quiz'].toString();
      _explicacaoController.text = data['explicacao_erro'] ?? "";
      _desafioController.text = data['desafio_criativo'] ?? "";
      _flexoesController.text = (data['aceitas_flexoes'] as List).join(', ');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("A IA falhou ou falta a chave AI_KEY.")));
    }

    if (mounted) setState(() => _isGeneratingAI = false);
  }

  void _salvarPalavra() {
    if (_formKey.currentState!.validate()) {
      final game = Provider.of<GameProvider>(context, listen: false);
      
      final palavra = PalavraMestra(
        id: widget.palavraParaEditar?.id ?? "custom_${DateTime.now().millisecondsSinceEpoch}",
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
        xpValor: int.tryParse(_xpController.text) ?? 200,
      );

      if (widget.palavraParaEditar != null) {
        game.atualizarPalavra(_selectedEraId, palavra);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sabedoria atualizada!")));
      } else {
        game.adicionarPalavra(_selectedEraId, palavra);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Sabedoria adicionada ao Grimório!")));
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final isEditing = widget.palavraParaEditar != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "EDITAR SABEDORIA" : "FORJA DE CONHECIMENTO", style: const TextStyle(color: Colors.redAccent, fontSize: 16)),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: _isGeneratingAI ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.auto_awesome, color: Colors.amber),
            onPressed: isEditing ? null : _simularGeracaoIA,
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
              Text(isEditing ? "AJUSTAR REGISTRO EXISTENTE" : "CONFIGURAR NOVA PALAVRA MESTRA", style: const TextStyle(color: Colors.white54, fontSize: 10)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _selectedEraId,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("ERA DESTINO"),
                items: game.eras.map((era) {
                  return DropdownMenuItem(value: era.id, child: Text(era.nome));
                }).toList(),
                onChanged: isEditing ? null : (val) => setState(() => _selectedEraId = val!),
              ),
              
              const SizedBox(height: 15),
              _buildField(_termoController, "TERMO (EX: EFÊMERO)"),
              _buildField(_classeController, "CLASSE GRAMATICAL"),
              _buildField(_xpController, "XP OBTIDO NO DOMÍNIO (EX: 200)", keyboardType: TextInputType.number),
              _buildField(_definicaoController, "DEFINIÇÃO COMPLETA", maxLines: 2),
              _buildField(_etimologiaController, "ETIMOLOGIA/ORIGEM"),
              _buildField(_fraseController, "FRASE COM LACUNA (USE ___)"),
              _buildField(_autorController, "AUTOR DA CITAÇÃO"),
              _buildField(_perguntaController, "PERGUNTA DO QUIZ"),
              _buildField(_opcoesController, "OPÇÕES DO QUIZ (SEPARADAS POR VÍRGULA)"),
              _buildField(_indexCorretocontroller, "INDEX DA RESPOSTA CORRETA (0-3)", keyboardType: TextInputType.number),
              _buildField(_explicacaoController, "EXPLICAÇÃO EM CASO DE ERRO"),
              _buildField(_desafioController, "DESAFIO CRIATIVO"),
              _buildField(_flexoesController, "SINÔNIMOS ACEITOS (SEPARADOS POR VÍRGULA)"),
              
              const SizedBox(height: 30),
              BotaoMagico(
                texto: isEditing ? "ATUALIZAR REGISTRO" : "FORJAR PALAVRA",
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

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
