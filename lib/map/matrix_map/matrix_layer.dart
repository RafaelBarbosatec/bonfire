class MatrixLayer {
  final bool axisInverted;
  final List<List<double>> matrix;

  MatrixLayer({
    required this.matrix,
    this.axisInverted = false,
  });
}
