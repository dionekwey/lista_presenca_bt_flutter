class BluetoothDeviceCustom {
  String name;
  String address;
  bool paired;
  bool nearby;
  List<String> presencas = [];

  BluetoothDeviceCustom(this.name, this.address, Set<bool> set,
      {this.nearby = false, this.paired = false});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDeviceCustom &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;

  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address};
  }

  @override
  String toString() {
    return 'BluetoothDevice{name: $name, address: $address, paired: $paired, nearby: $nearby, presencas: $presencas}';
  }
}
