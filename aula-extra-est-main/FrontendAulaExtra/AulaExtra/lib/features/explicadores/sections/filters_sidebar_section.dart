import 'package:flutter/material.dart';

class FiltersSidebarSection extends StatelessWidget {
  const FiltersSidebarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 344,
      padding: const EdgeInsets.only(
        left: 26.668,
        right: 44.447,
        top: 26.668,
        bottom: 26.668,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.111),
        borderRadius: BorderRadius.circular(17.408),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.tune, size: 22.223, color: Color(0xFF0A0A0A)),
                  SizedBox(width: 8.889),
                  Text(
                    'Filtros',
                    style: TextStyle(
                      fontSize: 26.668,
                      height: 35.557 / 26.668,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
              Row(
                children: const [
                  Icon(Icons.refresh, size: 17.779, color: Color(0xFF6A7282)),
                  SizedBox(width: 6),
                  Text(
                    'Limpar',
                    style: TextStyle(
                      fontSize: 15.556,
                      height: 22.223 / 15.556,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF6A7282),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Preço por hora'),
          const SizedBox(height: 13.334),
          Row(
            children: [
              const SizedBox(width: 10.851),
              Container(
                width: 47,
                height: 38,
                padding: const EdgeInsets.symmetric(horizontal: 8.889, vertical: 4.445),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DC), width: 1.111),
                  borderRadius: BorderRadius.circular(4.445),
                ),
                child: const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '5€',
                    style: TextStyle(
                      fontSize: 17.779,
                      height: 26.668 / 17.779,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 13.334),
          const _FakeSlider(),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Nível de Ensino'),
          const SizedBox(height: 13.334),
          const _OptionList(options: [
            _Option('1º Ciclo', selected: true),
            _Option('2º Ciclo'),
            _Option('3º Ciclo'),
            _Option('Secundário'),
            _Option('Universidade'),
          ]),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Disponibilidade'),
          const SizedBox(height: 13.334),
          const _OptionList(options: [
            _Option('Qualquer horário'),
            _Option('Manhãs'),
            _Option('Tardes'),
            _Option('Noites', selected: true),
            _Option('Fins de semana', selected: true),
          ]),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('País de Origem'),
          const SizedBox(height: 13.334),
          Container(
            height: 43.336,
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DC), width: 1.111),
              borderRadius: BorderRadius.circular(11.112),
            ),
          ),
          const SizedBox(height: 26.668),
          const _Divider(),
          const SizedBox(height: 13.334),
          const _Title('Especializações'),
          const SizedBox(height: 13.334),
          const _OptionList(options: [
            _Option('Conversação'),
            _Option('Gramática'),
            _Option('Business English', selected: true),
            _Option('IELTS'),
            _Option('TOEFL'),
            _Option('Cambridge'),
            _Option('Inglês para Iniciantes'),
            _Option('Inglês Avançado'),
          ]),
          const SizedBox(height: 26.668),
          const _Title('Avaliação Mínima'),
          const SizedBox(height: 13.334),
          const _OptionList(options: [
            _Option('4.5+ estrelas'),
            _Option('4+ estrelas'),
            _Option('3.5+ estrelas'),
            _Option('Qualquer avaliação'),
          ]),
          const SizedBox(height: 26.668),
          Container(
            height: 53.336,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3B94EF), Color(0xFF2563EB)],
              ),
              borderRadius: BorderRadius.circular(11.112),
            ),
            child: const Center(
              child: Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 17.779,
                  height: 26.668 / 17.779,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(height: 1.111, width: double.infinity, color: const Color(0xFFE5E7EB));
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20.001,
        height: 30.002 / 20.001,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0A0A0A),
      ),
    );
  }
}

class _FakeSlider extends StatelessWidget {
  const _FakeSlider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 17.779,
      child: Stack(
        children: [
          Positioned(
            left: 5.33,
            right: 0,
            top: 15.77,
            child: Container(height: 4, color: const Color(0xFFE5E7EB)),
          ),
          Positioned(
            left: 5.33,
            top: 15.77,
            child: Container(width: 38, height: 4, color: const Color(0xFFFC9039)),
          ),
          const Positioned(
            left: 37.33,
            top: 7.99,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: SizedBox(
                width: 11,
                height: 11,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFFC9039), shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Option {
  const _Option(this.text, {this.selected = false});

  final String text;
  final bool selected;
}

class _OptionList extends StatelessWidget {
  const _OptionList({required this.options});

  final List<_Option> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options
          .map(
            (o) => Padding(
              padding: const EdgeInsets.only(bottom: 8.889),
              child: Row(
                children: [
                  _Dot(selected: o.selected),
                  const SizedBox(width: 8.889),
                  Text(
                    o.text,
                    style: const TextStyle(
                      fontSize: 15.556,
                      height: 22.223 / 15.556,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17.779,
      height: 17.779,
      child: Center(
        child: Container(
          width: 13.334,
          height: 13.334,
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFC9039) : const Color(0xFF8F8F8F),
            border: Border.all(color: const Color(0xFF8F8F8F), width: selected ? 0.87 : 0),
            borderRadius: BorderRadius.circular(18642298),
          ),
        ),
      ),
    );
  }
}
