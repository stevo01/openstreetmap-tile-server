# Benchmark Results
## Import OSM Data into postgresql database

| Version       | System                               | Import            |  volume   | Time      | log       |
| ------------- | ------------------------------------ | ----------------- | --- |--------- | --------- |
| [ca32b80](https://github.com/stevo01/openstreetmap-tile-server/commit/87a5ba06729f46553c021fef09099f2bbb62f211)        | AMD Ryzon 8 core / 64GByte RAM / SSD | Berlin 53 MB        | 3.5 GB   | 91 s      | none      |
| [ca32b80](https://github.com/stevo01/openstreetmap-tile-server/commit/87a5ba06729f46553c021fef09099f2bbb62f211)        | AMD Ryzon 8 core / 64GByte RAM / SSD | Germany 3.0 GB      | 75.23 GB   | 3.3 std   | [link](Benchmarks/osm-import/import_germany-latest.log) |
| [ca32b80](https://github.com/stevo01/openstreetmap-tile-server/commit/87a5ba06729f46553c021fef09099f2bbb62f211)        | AMD Ryzon 8 core / 64GByte RAM / NVMe | Berlin 53 MB        | 3.5 GB   | 78 s      | none      |
| [ca32b80](https://github.com/stevo01/openstreetmap-tile-server/commit/87a5ba06729f46553c021fef09099f2bbb62f211)        | AMD Ryzon 8 core / 64GByte RAM / NVMe | Europa 19.4 GB        | 498 GB   | 17.25 std      | [link](Benchmarks/osm-import/europa_002/import_europa-latest_002.log)      |
| [tag 0.1](https://github.com/stevo01/openstreetmap-tile-server/tree/0.1)        | AMD Ryzon 8 core / 64GByte RAM / NVMe | Planet 44,61 GB        | 1.087TB   | 41.71 std      | [link](Benchmarks/osm-import/planet_004/logfile.txt)      |
| [tag 0.2](https://github.com/stevo01/openstreetmap-tile-server/tree/0.2)        | AMD Ryzon 8 core / 64GByte RAM / NVMe | Planet 44,61 GB        | 1.087TB   | 82.07 std      | [link](Benchmarks/osm-import/import_germany-latest.log)      |

## I/O performance

| Disc                                 | Interface         | rndrw          |  rndrd       | log                                                   |
| ------------------------------------ | ----------------- | ---------------|------------- | ----------------------------------------------------- |
| Samsung SSD 860 EVO 500GB (RVT01B6Q) | SATA III          | 57.023Mb/sec   | 492.03Mb/sec | [20190319_SSD.txt](Benchmarks/IO/20190319_SSD.txt)    |
| WDC WD20EFRX-68EUZN0 (82.00A82)      | SATA III          | 4.0889Mb/sec   | 98.531Mb/sec | [20190319_HD.txt](Benchmarks/IO/20190319_HD.txt)     |
| Samsung EVO Plus V-NAND SSD      | M.2          | 40.397Mb/sec   | 1.2803Gb/sec | [20190319_HD.txt](Benchmarks/osm-import/planet_005/import.log)     |

+ rndrw : random read write
+ rndrd : random read
