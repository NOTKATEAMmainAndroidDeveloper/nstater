[![pub package](https://img.shields.io/pub/v/nstater.svg)](https://pub.dev/packages/nstater)
[![pub points](https://img.shields.io/pub/points/nstater)](https://pub.dev/packages/nstater)
[![likes](https://img.shields.io/pub/likes/nstater)](https://pub.dev/packages/nstater)

# NStater — lightweight state management with zero dependencies

**NStater** is a minimal and fast way to manage state in Flutter. You control the lifecycle of controllers and reactive values yourself, using your own types and subscriptions.

## 📦 Features

- **NVar** — a typed reactive variable that notifies listeners about changes
- **NField** — a widget that listens to an `NVar` and rebuilds only when the value actually changes
- **NController** — a base state controller class
- **NState** —  widget that creates a controller and manages its lifecycle

---

## 📦📦 Another Features

- **Custom equality** — control when values are considered equal to optimize rebuilds
- **Selective rebuilds** — rebuild only when specific parts of state change
- No dependency on `ChangeNotifier`/`ValueNotifier`
- You can combine multiple `NVar` or `NController` instances on a single screen

---

## 🔍 Quick API

### `NVar<T>`
Reactive value with subscribe / unsubscribe:

```dart
final n = NVar<int>(0);
n.addListener((v) => print('new value: $v'));
// new value: 0
n.value = 42;
print(n.value);
// 42
```

**Custom equality:**

```dart
// Use custom comparison for complex objects
final items = NVar<List<String>>(
  ['a', 'b'],
  isEqual: (old, new) => ListEquality().equals(old, new),
);
items.value = ['a', 'b']; // Won't notify listeners (content is equal)
```

### `NField<T>`
A widget that listens to an `NVar` and rebuilds only when the value actually changes:

```dart
NField<int>(
  data: counter,
  builder: (v) => Text('$v'),
);
```

**Selective rebuilds:**

```dart
class User {
  final String name;
  final int age;
  User(this.name, this.age);
}

final userVar = NVar<User>(User('John', 30));

// Rebuild ONLY when name changes, ignore age updates
NField<User>(
  data: userVar,
  shouldRebuild: (prev, curr) => prev.name != curr.name,
  builder: (user) => Text(user.name),
);
```

### `NController`
Base controller class with subscriptions and no dependencies:

```dart
class CounterController extends NController<CounterController> {
  int count = 0;

  void increment() {
    count++;
    update(); // Notify all listeners
  }

  @override
  void onInit() {
    // Called when widget is created
    print('Controller initialized');
  }

  @override
  void onReady() {
    // Called after first build
    print('Controller ready');
  }

  @override
  void dispose() {
    // Clean up resources
    print('Controller disposed');
    super.dispose();
  }
  
  @override
  void beforeMount() {
    // Call before widget mount, its called before [onInit]
    print('Controller before mount');
    super.beforeMount();
  }
}
```


### `NState<C extends NController>`
Builds UI based on a controller and automatically creates and disposes it:

```dart
NState<CounterController>(
  create: () => CounterController(),
  builder: (controller) => Column(
    children: [
      Text('Count: ${controller.count}'),
      ElevatedButton(
        onPressed: controller.increment,
        child: Text('Increment'),
      ),
    ],
  ),
);
```

### `NVarCombiner<R>`
Combine multiple `NVar` sources into a single computed value that automatically updates when any source changes:

```dart
final firstName = NVar<String>('John');
final lastName = NVar<String>('Doe');

// Combine two sources
final fullName = NVarCombiner(
  [firstName, lastName],
      () => '${firstName.value} ${lastName.value}',
);

print(fullName.value); // John Doe

firstName.value = 'Jane';
print(fullName.value); // Jane Doe
```

**Form validation example:**

```dart
final email = NVar<String>('');
final password = NVar<String>('');
final acceptTerms = NVar<bool>(false);

final isFormValid = NVarCombiner(
  [email, password, acceptTerms], () => 
        email.value.contains('@') && 
        password.value.length >= 6 
        && acceptTerms.value,
);

// Use in UI
NField<bool>(
  data: isFormValid,
  builder: (isValid) => ElevatedButton(
    onPressed: isValid ? _submit : null,
    child: Text('Submit'),
  ),
);
```

---

## ⚡ Performance Tips

1. **Use `shouldRebuild` in `NField`** to prevent unnecessary rebuilds when only specific parts of data change
2. **Use `isEqual` in `NVar`** for deep equality checks on complex objects (lists, maps)
3. **Dispose resources** — always call `super.dispose()` in controllers and `dispose()` on `NVar` instances
4. **Combine multiple `NVar`** — use separate reactive variables for independent state instead of one large object

---

## 📚 Lifecycle Methods

### NController
- `beforeMount()` — called before widget mount
- `onInit()` — called when widget is created (analog of `initState`)
- `onReady()` — called after first build is complete
- `dispose()` — called when widget is removed from tree

### NVar / NVarCombiner
- `dispose()` — unsubscribe from all listeners and clean up resources

---

## 📄 License

MIT License — see [LICENSE](LICENSE) file for details.

---

## 🤝 Contributing

Issues and pull requests are welcome!
Visit [GitHub repository](https://github.com/NOTKATEAMmainAndroidDeveloper/nstater).