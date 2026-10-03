/// The four Kakeibo spending categories. (Flutter already exports `Category`.)
enum SpendCategory {
  needs('Needs'),
  wants('Wants'),
  culture('Culture'),
  extra('Extra');

  const SpendCategory(this.label);
  final String label;
}

enum ReflectionType { weekly, monthly }

enum Frequency { weekly, monthly }
