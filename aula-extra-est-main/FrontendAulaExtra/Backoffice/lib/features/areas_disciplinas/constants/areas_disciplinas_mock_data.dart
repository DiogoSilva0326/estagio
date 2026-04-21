import 'package:flutter/material.dart';

import '../models/area_disciplinas_item.dart';

const areasDisciplinasMockData = <AreaDisciplinasItem>[
  AreaDisciplinasItem(
    nome: 'Matemática',
    explicadores: 145,
    disciplinas: ['Matemática A', 'Matemática B', 'MACS'],
    icon: Icons.calculate_rounded,
    iconBackgroundColor: Color(0x2641A7D7),
    iconColor: Color(0xFF41A7D7),
  ),
  AreaDisciplinasItem(
    nome: 'Ciências',
    explicadores: 120,
    disciplinas: ['Física e Química A', 'Biologia e Geologia'],
    icon: Icons.biotech_outlined,
    iconBackgroundColor: Color(0x26FB7B02),
    iconColor: Color(0xFFFB7B02),
  ),
  AreaDisciplinasItem(
    nome: 'Línguas',
    explicadores: 98,
    disciplinas: ['Português', 'Inglês', 'Espanhol'],
    icon: Icons.menu_book_rounded,
    iconBackgroundColor: Color(0x80FFBDC0),
    iconColor: Color(0xFFF15C64),
  ),
];
