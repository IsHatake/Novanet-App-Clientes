import 'dart:convert';
import 'package:app_cliente_novanet/utils/colornotifire.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PagosPage extends StatefulWidget {
const PagosPage({
    Key? key,
  }) : super(key: key);

  @override
  _PagosPageState createState() => _PagosPageState();
}

class _PagosPageState extends State<PagosPage> {
  List<Map<String, dynamic>> listadodepagos = [];
  late List<Map<String, dynamic>> listadodepagosoriginal;
  String selectedMonth = '1';
  late ColorNotifire notifire;
  int currentPage = 1;
  final int itemsPerPage = 5; // Number of items per page

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String pagos = prefs.getString('datalogin[4]') ?? '[]';
    setState(() {
      listadodepagosoriginal = jsonDecode(pagos).cast<Map<String, dynamic>>();
      _applyFilter();
    });
  }

  void _applyFilter() {
    DateTime now = DateTime.now();
    DateTime firstDayOfMonth = DateTime(now.year, now.month, 1);
    DateTime threeMonthsAgo = firstDayOfMonth.subtract(const Duration(days: 90));
    DateTime sixMonthsAgo = firstDayOfMonth.subtract(const Duration(days: 180));

    List<Map<String, dynamic>> filteredList = selectedMonth == '1'
        ? List.from(listadodepagosoriginal)
        : selectedMonth == '2'
            ? listadodepagosoriginal.where((pago) {
                DateTime fecha = DateTime.parse(pago['fdFechaTransaccion']);
                return fecha.isAfter(threeMonthsAgo) || fecha.isAtSameMomentAs(firstDayOfMonth);
              }).toList()
            : listadodepagosoriginal.where((pago) {
                DateTime fecha = DateTime.parse(pago['fdFechaTransaccion']);
                return fecha.isAfter(sixMonthsAgo) || fecha.isAtSameMomentAs(firstDayOfMonth);
              }).toList();

    setState(() {
      listadodepagos = filteredList;
      currentPage = 1; // Reset to first page on filter change
    });
  }

  void _filtrarPagos(String? mes) {
    if (mes != null) {
      setState(() {
        selectedMonth = mes;
        _applyFilter();
      });
    }
  }

  String _getMonthName(int op) {
    switch (op) {
      case 1:
        return 'Todos los Pagos';
      case 2:
        return 'Últimos 3 Meses';
      case 3:
        return 'Últimos 6 Meses';
      default:
        return '';
    }
  }

  List<Map<String, dynamic>> _getPaginatedItems() {
    final startIndex = (currentPage - 1) * itemsPerPage;
    final endIndex = startIndex + itemsPerPage;
    return listadodepagos.sublist(
      startIndex,
      endIndex > listadodepagos.length ? listadodepagos.length : endIndex,
    );
  }

  Widget _buildFilters(double width, double height) => Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.015),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedMonth == '1' ? _getMonthName(1) : 'Pagos ${_getMonthName(int.parse(selectedMonth))}',
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.022,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedMonth,
                dropdownColor: notifire.getbackcolor,
                icon: Icon(Icons.arrow_drop_down, color: notifire.getorangeprimerycolor),
                onChanged: _filtrarPagos,
                items: List.generate(3, (i) => (i + 1).toString())
                    .map((value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            _getMonthName(int.parse(value)),
                            style: TextStyle(
                              fontFamily: "Gilroy Medium",
                              color: notifire.getdarkscolor,
                              fontSize: height * 0.018,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    notifire = Provider.of<ColorNotifire>(context);
    final paginatedItems = _getPaginatedItems();
    final totalPages = (listadodepagos.length / itemsPerPage).ceil();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilters(width, height),
        SizedBox(height: height * 0.02),
        listadodepagos.isEmpty
            ? _buildEmptyState(height)
            : Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paginatedItems.length,
                    itemBuilder: (context, index) => _buildPaymentCard(paginatedItems[index], width, height),
                  ),
                  if (totalPages > 1) _buildPaginationControls(width, height, totalPages),
                ],
              ),
      ],
    );
  }

  Widget _buildEmptyState(double height) => SizedBox(
        height: height * 0.4,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "images/sin-dinero.png",
                color: notifire.getorangeprimerycolor.withOpacity(0.7),
                height: height * 0.12,
              ),
              SizedBox(height: height * 0.02),
              Text(
                "Sin Pagos Realizados",
                style: TextStyle(
                  fontFamily: "Gilroy Bold",
                  color: notifire.getdarkscolor,
                  fontSize: height * 0.024,
                ),
              ),
              SizedBox(height: height * 0.01),
              Text(
                "No hay pagos registrados en este período",
                style: TextStyle(
                  fontFamily: "Gilroy Medium",
                  color: notifire.getdarkscolor.withOpacity(0.6),
                  fontSize: height * 0.016,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildPaymentCard(Map<String, dynamic> item, double width, double height) => Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: height * 0.008),
        child: Card(
          color: notifire.getbackcolor,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.withOpacity(0.15), width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(width * 0.03),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: height * 0.06,
                  width: height * 0.06,
                  decoration: BoxDecoration(
                    color: notifire.getprimerycolor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Image.asset(
                      "images/logos.png",
                      height: height * 0.03,
                    ),
                  ),
                ),
                SizedBox(width: width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['fiIDTransaccion'] ?? ''} - ${item['fcOperacion'] ?? ''}',
                              style: TextStyle(
                                fontFamily: "Gilroy Bold",
                                color: notifire.getdarkscolor,
                                fontSize: height * 0.018,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            NumberFormat.currency(
                              locale: 'en',
                              symbol: item['fiIDMoneda'] == 1 ? 'L' : '\$',
                              decimalDigits: 2,
                            ).format(double.tryParse(item['fnValorAbonado']?.toString() ?? '0') ?? 0),
                            style: TextStyle(
                              fontFamily: "Gilroy Bold",
                              color: notifire.getorangeprimerycolor,
                              fontSize: height * 0.02,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: height * 0.008),
                      Text(
                        item['fcLugarResidencia'] ?? 'Sin ubicación',
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.7),
                          fontSize: height * 0.015,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: height * 0.005),
                      Text(
                        DateFormat('dd/MM/yyyy').format(
                          DateTime.parse(item['fdFechaTransaccion'] ?? DateTime.now().toIso8601String()),
                        ),
                        style: TextStyle(
                          fontFamily: "Gilroy Medium",
                          color: notifire.getdarkscolor.withOpacity(0.7),
                          fontSize: height * 0.015,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildPaginationControls(double width, double height, int totalPages) => Padding(
        padding: EdgeInsets.symmetric(vertical: height * 0.015),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: currentPage > 1 ? notifire.getorangeprimerycolor : Colors.grey),
              onPressed: currentPage > 1
                  ? () => setState(() => currentPage--)
                  : null,
            ),
            Text(
              'Página $currentPage de $totalPages',
              style: TextStyle(
                fontFamily: "Gilroy Medium",
                color: notifire.getdarkscolor,
                fontSize: height * 0.018,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: currentPage < totalPages ? notifire.getorangeprimerycolor : Colors.grey),
              onPressed: currentPage < totalPages
                  ? () => setState(() => currentPage++)
                  : null,
            ),
          ],
        ),
      );
}