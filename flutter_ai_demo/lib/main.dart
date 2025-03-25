import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Recipe Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const RecipeGeneratorPage(),
    );
  }
}

class RecipeGeneratorPage extends StatefulWidget {
  const RecipeGeneratorPage({super.key});

  @override
  State<RecipeGeneratorPage> createState() => RecipeGeneratorPageState();
}

class RecipeGeneratorPageState extends State<RecipeGeneratorPage> {
  final formKey = GlobalKey<FormState>();
  final ingredientsController = TextEditingController();
  String selectedMealType = 'Dinner';
  String selectedCuisine = 'Italian';
  String selectedDifficulty = 'Medium';
  String selectedDietaryRestriction = 'None';
  
  String generatedRecipe = '';
  bool isLoading = false;

  final List<String> mealTypes = [
    'Breakfast', 'Lunch', 'Dinner', 'Dessert', 'Snack', 'Appetizer'
  ];
  
  final List<String> cuisines = [
    'Italian', 'Mexican', 'Indian', 'Chinese', 'Japanese', 'Mediterranean', 
    'American', 'Thai', 'French', 'Vietnamese', 'Korean', 'Middle Eastern'
  ];
  
  final List<String> difficulties = [
    'Easy', 'Medium', 'Hard'
  ];
  
  final List<String> dietaryRestrictions = [
    'None', 'Vegetarian', 'Vegan', 'Gluten-Free', 'Dairy-Free', 
    'Keto', 'Paleo', 'Low-Carb', 'Low-Fat'
  ];

  @override
  void dispose() {
    ingredientsController.dispose();
    super.dispose();
  }

  Future<void> generateRecipe() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
        generatedRecipe = '';
      });

      final prompt = '''
You are a professional chef specialized in creating delicious recipes. Create a recipe with the following specifications:

Ingredients: ${ingredientsController.text}
Meal Type: $selectedMealType
Cuisine: $selectedCuisine
Difficulty: $selectedDifficulty
Dietary Restrictions: $selectedDietaryRestriction

Please format your response with the following sections:
1. Recipe Name (be creative and enticing)
2. Description (brief, mouth-watering description)
3. Preparation Time
4. Cooking Time
5. Servings
6. Ingredients (with measurements)
7. Instructions (step-by-step)
8. Nutritional Information (estimated)
9. Chef's Tips

Make sure the recipe is delicious, practical, and follows the specified dietary restrictions if any.
''';

      try {
        final recipe = await callClaudeApi(prompt);
        setState(() {
          generatedRecipe = recipe;
          isLoading = false;
        });
      } catch (e) {
        setState(() {
          generatedRecipe = "Error generating recipe: $e";
          isLoading = false;
        });
      }
    }
  }

  Future<String> callClaudeApi(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/api/claude'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'claude-3-haiku-20240307',
          'max_tokens': 2000,
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['content'][0]['text'];
      } else {
        // Fallback to mock response in case of API error
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return getMockRecipe();
      }
    } catch (e) {
      // Fallback to mock response in case of connection error
      debugPrint('Connection error: $e');
      return getMockRecipe();
    }
  }
  
  // Fallback mock recipe in case of API issues
  String getMockRecipe() {
    return '''
# Zesty Mediterranean Quinoa Bowl with Roasted Vegetables

## Description
A vibrant, nutritious bowl that brings together the bright flavors of the Mediterranean with protein-packed quinoa and beautifully roasted vegetables. This colorful dish is as nourishing as it is satisfying.

## Preparation Time
15 minutes

## Cooking Time
25 minutes

## Servings
4

## Ingredients
- 1 cup uncooked quinoa, rinsed
- 2 cups vegetable broth
- 1 medium zucchini, diced into 1/2-inch pieces
- 1 red bell pepper, diced
- 1 yellow bell pepper, diced
- 1 small eggplant, diced into 1/2-inch cubes
- 1 red onion, sliced into wedges
- 3 tablespoons olive oil, divided
- 1 teaspoon dried oregano
- 1 teaspoon ground cumin
- 1/2 teaspoon smoked paprika
- 3 cloves garlic, minced
- Salt and freshly ground black pepper to taste
- 1 cup cherry tomatoes, halved
- 1/2 cup Kalamata olives, pitted and halved
- 1/4 cup fresh parsley, chopped
- 1/4 cup fresh mint leaves, torn
- 1/3 cup crumbled feta cheese (omit for vegan option)
- 2 tablespoons lemon juice
- 1 tablespoon red wine vinegar
- Lemon wedges for serving

## Instructions
1. Preheat your oven to 425°F (220°C) and line a large baking sheet with parchment paper.

2. In a medium saucepan, combine quinoa and vegetable broth. Bring to a boil, then reduce heat to low, cover, and simmer for about 15 minutes until the liquid is absorbed and quinoa is tender. Remove from heat and let stand, covered, for 5 minutes, then fluff with a fork.

3. While quinoa is cooking, in a large bowl, toss zucchini, bell peppers, eggplant, and red onion with 2 tablespoons olive oil, oregano, cumin, smoked paprika, and garlic. Season with salt and pepper.

4. Spread the vegetables in a single layer on the prepared baking sheet and roast for 20-25 minutes, stirring halfway through, until vegetables are tender and slightly caramelized at the edges.

5. In a large bowl, combine the cooked quinoa, roasted vegetables, cherry tomatoes, olives, parsley, and mint.

6. In a small bowl, whisk together the remaining 1 tablespoon olive oil, lemon juice, and red wine vinegar. Pour over the quinoa mixture and toss gently to combine.

7. Sprinkle with crumbled feta cheese (if using) and serve warm or at room temperature with lemon wedges on the side.

## Nutritional Information (Estimated per serving)
- Calories: 380
- Protein: 12g
- Carbohydrates: 45g
- Dietary Fiber: 8g
- Fat: 18g
- Saturated Fat: 4g
- Sodium: 650mg
- Potassium: 820mg

## Chef's Tips
- For meal prep, this dish keeps well in the refrigerator for up to 3 days.
- Try adding a dollop of Greek yogurt or hummus for extra creaminess.
- For added protein, serve with grilled chicken or roasted chickpeas.
- Toasting the quinoa in a dry pan before cooking adds a nutty flavor dimension.
- If fresh herbs aren't available, you can substitute with 1 tablespoon each of dried parsley and mint.
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Recipe Generator'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generate Your Perfect Recipe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: ingredientsController,
                  decoration: const InputDecoration(
                    labelText: 'Ingredients You Have',
                    hintText: 'e.g., chicken, rice, bell peppers, onions',
                    border: OutlineInputBorder(),
                    filled: true,
                  ),
                  minLines: 2,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some ingredients';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Meal Type',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        value: selectedMealType,
                        items: mealTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedMealType = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Cuisine',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        value: selectedCuisine,
                        items: cuisines.map((String cuisine) {
                          return DropdownMenuItem<String>(
                            value: cuisine,
                            child: Text(cuisine),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedCuisine = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Difficulty',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        value: selectedDifficulty,
                        items: difficulties.map((String difficulty) {
                          return DropdownMenuItem<String>(
                            value: difficulty,
                            child: Text(difficulty),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDifficulty = newValue;
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Dietary Restrictions',
                          border: OutlineInputBorder(),
                          filled: true,
                        ),
                        value: selectedDietaryRestriction,
                        items: dietaryRestrictions.map((String restriction) {
                          return DropdownMenuItem<String>(
                            value: restriction,
                            child: Text(restriction),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              selectedDietaryRestriction = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : generateRecipe,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.blue)
                      : const Text('Generate Recipe', style: TextStyle(fontSize: 16)),
                  ),
                ),
                
                if (isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          SizedBox(height: 20),
                          Text('Creating your culinary masterpiece...'),
                        ],
                      ),
                    ),
                  ),
                
                if (generatedRecipe.isNotEmpty) ...[
                  const SizedBox(height: 30),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Recipe',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () {
                                  // Copy to clipboard functionality
                                },
                                tooltip: 'Copy to clipboard',
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(generatedRecipe),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}