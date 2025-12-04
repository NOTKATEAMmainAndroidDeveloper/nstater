# NStater — lightweight state management with zero dependencies

**NStater** is a minimal and fast way to manage state in Flutter. You control the lifecycle of controllers and reactive values yourself, using your own types and subscriptions.

## 📦 Features

- **NVar** — a typed reactive variable that notifies listeners about changes
- **NField** — a widget that listens to an `NVar` and rebuilds only when the value actually changes
- **NController** — a base state controller class
- **NState** —  widget that creates a controller and manages its lifecycle
- No dependency on `ChangeNotifier`/`ValueNotifier`
- You can combine multiple `NVar` щк `NController` instances on a single screen

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

### `NField<T>`
A widget that listens to an `NVar` and rebuilds only when the value actually changes:

```dart
NField<int>(
  data: counter,
  builder: (v) => Text('$v'),
);
```


### `NController`
Base controller class with subscriptions and no dependencies:

```dart
class MyController extends NController {
  int count = 0;
  void inc() {
    count++;
    notify();
  }
}
```


### `NState<C extends NController>`
Builds UI based on a controller and automatically creates and disposes it:

```dart
NState<MyController>(
  create: () => MyController(),
  builder: (c) => Text('${c.count}'),
);
```