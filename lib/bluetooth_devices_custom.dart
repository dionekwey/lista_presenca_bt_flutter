class BluetoothDeviceCustom {
  String name;
  String address;
  List<String> presences = [];

  BluetoothDeviceCustom(this.name, this.address);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BluetoothDeviceCustom &&
          runtimeType == other.runtimeType &&
          address == other.address;

  @override
  int get hashCode => name.hashCode ^ address.hashCode;

  Map<String, dynamic> toMap() {
    return {'name': name, 'address': address};
  }

  @override
  String toString() {
    return 'BluetoothDevice{name: $name, address: $address, presences: $presences}';
  }

}
