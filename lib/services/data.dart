import 'package:diginews/models/category_model.dart';

List<CategoryModel> getCategories() {
  List<CategoryModel> category = [];

  CategoryModel categoryModel = CategoryModel();
  categoryModel.categoryName = "Cranky-Lounge";

  category.add(categoryModel);

  categoryModel = CategoryModel();
  categoryModel.categoryName = "Setup";
  category.add(categoryModel);

  categoryModel = CategoryModel();
  categoryModel.categoryName = "Review";
  category.add(categoryModel);

  categoryModel = CategoryModel();
  categoryModel.categoryName = "Tip";
  category.add(categoryModel);

  return category;
}
