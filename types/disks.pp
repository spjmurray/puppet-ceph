type Ceph::Disks = Hash[Variant[Enum['defaults'], Ceph::Disk], Struct[{
  Optional[journal] => Ceph::Disk,
  Optional[db]      => Ceph::Disk,
  Optional[wal]     => Ceph::Disk,
  Optional[params]  => Hash[String[1], Optional[String[1]]],
}]]
