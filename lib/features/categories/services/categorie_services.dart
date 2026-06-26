import '../../../core/constants/supabase_client.dart';
import '../model/categorie_model.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    final response = await supabase.from('categories').select().order('name');

    return response.map<Category>((e) => Category.fromJson(e)).toList();
  }

  Future<void> addCategory(String name) async {
    await supabase.from('categories').insert({'name': name});
  }

  Future<void> deleteCategory(String id) async {
    await supabase.from('categories').delete().eq('id', id);
  }
}
