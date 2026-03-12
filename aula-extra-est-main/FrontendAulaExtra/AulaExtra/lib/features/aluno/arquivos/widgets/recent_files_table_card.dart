import 'package:aula_extra/features/aluno/arquivos/constants/arquivos_mock_data.dart';
import 'package:flutter/material.dart';

class RecentFilesTableCard extends StatelessWidget {
  const RecentFilesTableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(1.393),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.292),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.393),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 4.18,
          ),
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.10),
            offset: Offset(0, 1.393),
            blurRadius: 2.786,
            spreadRadius: -1.393,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.9),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: 990.662,
            child: Column(
              children: [
                const _TableHeaderRow(),
                for (int i = 0; i < ArquivosMockData.recentFiles.length; i++)
                  _FileRow(
                    data: ArquivosMockData.recentFiles[i],
                    hasBottomBorder: i != ArquivosMockData.recentFiles.length - 1,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56.426,
      color: const Color(0xFFF9FAFB),
      child: const Row(
        children: [
          _HeaderCell(width: 397.978, text: 'NOME'),
          _HeaderCell(width: 127.221, text: 'TUTOR'),
          _HeaderCell(width: 111.699, text: 'DATA'),
          _HeaderCell(width: 154.465, text: 'TAMANHO'),
          _HeaderCell(width: 199.299, text: 'AÇÕES'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({required this.width, required this.text});

  final double width;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.only(left: 33.44),
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16.719,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A5565),
          letterSpacing: 0.8359,
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({required this.data, required this.hasBottomBorder});

  final ArquivoRecenteRowData data;
  final bool hasBottomBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 129.572,
      decoration: BoxDecoration(
        border: Border(
          bottom: hasBottomBorder
              ? const BorderSide(color: Color(0xFFE5E7EB), width: 1.393)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 397.978,
            child: Padding(
              padding: const EdgeInsets.only(left: 33.44),
              child: Row(
                children: [
                  Container(
                    width: 55.73,
                    height: 55.73,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(13.932),
                    ),
                    child: Center(
                      child: Icon(data.icon, size: 27.865, color: const Color(0xFF101828)),
                    ),
                  ),
                  const SizedBox(width: 16.719),
                  Expanded(
                    child: SizedBox(
                      height: 55.73,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            data.fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 22.292,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF101828),
                              height: 33.438 / 22.292,
                            ),
                          ),
                          Text(
                            data.fileType,
                            style: const TextStyle(
                              fontSize: 16.719,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF6A7282),
                              height: 22.292 / 16.719,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _BodyCell(width: 127.221, text: data.tutor),
          _BodyCell(width: 111.699, text: data.date),
          _BodyCell(width: 154.465, text: data.sizeLabel, alignCenterVertically: true),
          SizedBox(
            width: 199.299,
            child: Padding(
              padding: const EdgeInsets.only(left: 33.44),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _DownloadButton(onTap: () {}),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BodyCell extends StatelessWidget {
  const _BodyCell({
    required this.width,
    required this.text,
    this.alignCenterVertically = false,
  });

  final double width;
  final String text;
  final bool alignCenterVertically;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(left: 33.44),
        child: Align(
          alignment: alignCenterVertically ? Alignment.centerLeft : Alignment.topLeft,
          child: Padding(
            padding: EdgeInsets.only(top: alignCenterVertically ? 0 : 36.22),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 19.505,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A5565),
                height: 27.865 / 19.505,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DownloadButton extends StatelessWidget {
  const _DownloadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.157,
      width: 132.424,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.932),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.only(left: 22.292),
            child: Row(
              children: const [
                Icon(Icons.download_rounded, size: 22.292, color: Color(0xFF364153)),
                SizedBox(width: 16.719),
                Text(
                  'Baixar',
                  style: TextStyle(
                    fontSize: 19.505,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF364153),
                    height: 27.865 / 19.505,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
