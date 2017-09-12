type Ceph::Keys = Hash[String[1], Struct[{
  key                => String[1],
  Optional[caps]     => Struct[{
    Optional[mon] => String[1],
    Optional[osd] => String[1],
    Optional[mds] => String[1],
    Optional[mgr] => String[1],
  }],
  Optional[path]     => String[1],
}]]
