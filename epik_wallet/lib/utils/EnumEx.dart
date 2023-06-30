
extension EnumBaseEx on Enum{

  static String describeEnum(Enum enumEntry) {
    if(enumEntry!=null)
    {
      final String description = enumEntry.toString();
      final int indexOfDot = description.indexOf('.');
      assert(indexOfDot != -1 && indexOfDot < description.length - 1);
      return description.substring(indexOfDot + 1);
    }
  }

  String get enumName
  {
    return describeEnum(this);
  }

}