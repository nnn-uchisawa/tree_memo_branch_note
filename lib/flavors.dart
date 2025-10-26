enum Flavor { local, dev, prod }

class F {
  static late final Flavor appFlavor;

  static String get name => appFlavor.name;

  static String get title {
    switch (appFlavor) {
      case Flavor.local:
        return 'Tree(local)';
      case Flavor.dev:
        return 'Tree(dev)';
      case Flavor.prod:
        return 'Tree';
    }
  }
}
