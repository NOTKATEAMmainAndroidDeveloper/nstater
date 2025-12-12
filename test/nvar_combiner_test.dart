import 'package:flutter_test/flutter_test.dart';
import 'package:nstater/nstater.dart';

void main() {
  group('NVarCombiner', () {
    test('initializes with correct initial value', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      expect(fullName.value, 'John Doe');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('updates when first source changes', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      firstName.value = 'Peter';

      expect(fullName.value, 'Peter Doe');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('updates when second source changes', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      lastName.value = 'Smith';

      expect(fullName.value, 'John Smith');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('updates when any source changes', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      firstName.value = 'Peter';
      expect(fullName.value, 'Peter Doe');

      lastName.value = 'Johnson';
      expect(fullName.value, 'Peter Johnson');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('notifies its listeners on update', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      int callCount = 0;
      String? receivedValue;

      fullName.addListener((newValue) {
        callCount++;
        receivedValue = newValue;
      });

      firstName.value = 'Peter';

      expect(callCount, 1);
      expect(receivedValue, 'Peter Doe');

      fullName.dispose();
      firstName.dispose();
      lastName.dispose();
    });

    test('works with three sources', () {
      final email = NVar<String>('test@mail.com');
      final password = NVar<String>('123456');
      final acceptTerms = NVar<bool>(true);

      final isFormValid = NVarCombiner([
        email,
        password,
        acceptTerms,
      ], () => email.value.contains('@') && password.value.length >= 6 && acceptTerms.value);

      expect(isFormValid.value, true);

      email.value = 'invalid';
      expect(isFormValid.value, false);

      email.value = 'valid@mail.com';
      expect(isFormValid.value, true);

      password.value = '123';
      expect(isFormValid.value, false);

      password.value = 'password123';
      expect(isFormValid.value, true);

      acceptTerms.value = false;
      expect(isFormValid.value, false);

      isFormValid.dispose();
      email.dispose();
      password.dispose();
      acceptTerms.dispose();
    });

    test('works with multiple sources (5+)', () {
      final price = NVar<double>(100.0);
      final quantity = NVar<int>(2);
      final discount = NVar<double>(0.1); // 10%
      final tax = NVar<double>(0.2); // 20%
      final deliveryFee = NVar<double>(50.0);

      final total = NVarCombiner([price, quantity, discount, tax, deliveryFee], () {
        final subtotal = price.value * quantity.value;
        final afterDiscount = subtotal * (1 - discount.value);
        final withTax = afterDiscount * (1 + tax.value);
        return withTax + deliveryFee.value;
      });

      // (100 * 2) * (1 - 0.1) * (1 + 0.2) + 50 = 200 * 0.9 * 1.2 + 50 = 216 + 50 = 266
      expect(total.value, 266.0);

      quantity.value = 3;
      // (100 * 3) * 0.9 * 1.2 + 50 = 324 + 50 = 374
      expect(total.value, 374.0);

      discount.value = 0.2; // 20%
      // (100 * 3) * 0.8 * 1.2 + 50 = 288 + 50 = 338
      expect(total.value, 338.0);

      total.dispose();
      price.dispose();
      quantity.dispose();
      discount.dispose();
      tax.dispose();
      deliveryFee.dispose();
    });

    test('works with list filtering', () {
      final items = NVar<List<String>>(['Apple', 'Banana', 'Orange', 'Pineapple']);
      final searchQuery = NVar<String>('');

      final filteredItems = NVarCombiner([items, searchQuery], () {
        if (searchQuery.value.isEmpty) return items.value;
        return items.value.where((item) => item.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
      });

      expect(filteredItems.value.length, 4);

      searchQuery.value = 'an';
      expect(filteredItems.value, ['Banana', 'Orange']);

      searchQuery.value = 'ora';
      expect(filteredItems.value, ['Orange']);

      searchQuery.value = '';
      expect(filteredItems.value.length, 4);

      filteredItems.dispose();
      items.dispose();
      searchQuery.dispose();
    });

    test('works with numeric calculations', () {
      final a = NVar<int>(10);
      final b = NVar<int>(20);
      final c = NVar<int>(30);

      final result = NVarCombiner([a, b, c], () => (a.value + b.value) * c.value);

      expect(result.value, (10 + 20) * 30); // 900

      a.value = 5;
      expect(result.value, (5 + 20) * 30); // 750

      b.value = 10;
      expect(result.value, (5 + 10) * 30); // 450

      c.value = 2;
      expect(result.value, (5 + 10) * 2); // 30

      result.dispose();
      a.dispose();
      b.dispose();
      c.dispose();
    });

    test('dispose unsubscribes from all sources', () {
      final firstName = NVar<String>('John');
      final lastName = NVar<String>('Doe');
      int combinedCallCount = 0;

      final fullName = NVarCombiner([firstName, lastName], () => '${firstName.value} ${lastName.value}');

      fullName.addListener((_) => combinedCallCount++);

      fullName.dispose();

      // After dispose, changes should not trigger updates
      firstName.value = 'Peter';
      lastName.value = 'Smith';

      expect(combinedCallCount, 0);

      firstName.dispose();
      lastName.dispose();
    });

    test('works with single source', () {
      final counter = NVar<int>(0);

      final doubled = NVarCombiner([counter], () => counter.value * 2);

      expect(doubled.value, 0);

      counter.value = 5;
      expect(doubled.value, 10);

      counter.value = 100;
      expect(doubled.value, 200);

      doubled.dispose();
      counter.dispose();
    });

    test('works with empty source list', () {
      final constant = NVarCombiner<String>([], () => 'Constant');

      expect(constant.value, 'Constant');

      // Value doesn't change as there are no sources
      expect(constant.value, 'Constant');

      constant.dispose();
    });

    test('multiple listeners receive updates', () {
      final a = NVar<int>(1);
      final b = NVar<int>(2);

      final sum = NVarCombiner([a, b], () => a.value + b.value);

      int callCount1 = 0;
      int callCount2 = 0;
      int? received1;
      int? received2;

      sum.addListener((v) {
        callCount1++;
        received1 = v;
      });
      sum.addListener((v) {
        callCount2++;
        received2 = v;
      });

      a.value = 10;

      expect(callCount1, 1);
      expect(callCount2, 1);
      expect(received1, 12);
      expect(received2, 12);

      sum.dispose();
      a.dispose();
      b.dispose();
    });

    test('works with different data types', () {
      final name = NVar<String>('Product');
      final price = NVar<double>(99.99);
      final inStock = NVar<bool>(true);

      final productInfo = NVarCombiner([
        name,
        price,
        inStock,
      ], () => '${name.value}: \$${price.value} ${inStock.value ? "In Stock" : "Out of Stock"}');

      expect(productInfo.value, 'Product: \$99.99 In Stock');

      inStock.value = false;
      expect(productInfo.value, 'Product: \$99.99 Out of Stock');

      price.value = 79.99;
      expect(productInfo.value, 'Product: \$79.99 Out of Stock');

      name.value = 'New Product';
      expect(productInfo.value, 'New Product: \$79.99 Out of Stock');

      productInfo.dispose();
      name.dispose();
      price.dispose();
      inStock.dispose();
    });

    test('cascading updates work correctly', () {
      final a = NVar<int>(1);
      final b = NVar<int>(2);

      final sum = NVarCombiner([a, b], () => a.value + b.value);

      final doubled = NVarCombiner([sum], () => sum.value * 2);

      expect(sum.value, 3);
      expect(doubled.value, 6);

      a.value = 5;
      expect(sum.value, 7);
      expect(doubled.value, 14);

      b.value = 10;
      expect(sum.value, 15);
      expect(doubled.value, 30);

      doubled.dispose();
      sum.dispose();
      a.dispose();
      b.dispose();
    });
  });
}
