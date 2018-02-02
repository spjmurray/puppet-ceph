type Ceph::Disk = Pattern[
  /\A\/dev\/[\w\d]+\Z/,
  /\A\d+:\d+:\d+:\d+\Z/,
  /\ASLOT \d{3}\Z/,
  /\ASlot \d{2}\Z/,
  /\ADISK\d{2}\Z/,
]
