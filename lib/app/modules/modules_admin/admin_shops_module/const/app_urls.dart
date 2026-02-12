class AppUrl {
  static String baseURL = 'https://api.libanbuy.com/';
  static String shopData = 'api/shops';
  static String CarsData =
      'api/products?with=thumbnail,shop&filterByColumns[filterJoin]=AND&filterByColumns[columns][0][column]=product_group&filterByColumns[columns][0][value]=car&filterByColumns[columns][0][operator]=%3D&filterByColumns[columns][1][column]=status&filterByColumns[columns][1][operator]=%3D';
}
