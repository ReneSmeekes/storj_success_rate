# Success Rate Tool

This script calculates success rates for audits, downloads, uploads and repair traffic.

## How to use it

If your operative system can run _bash shell scripts_ then you can run directly the script, otherwise you can run it with the official [_bash_ docker image](https://hub.docker.com/_/bash).

The script accept one optinal argument which is:

a. The name of the docker storage node docker container.
b. The path to a storage node log file.

When the argument isn't provided, then it defauls to option (a) using _storagenode_ as a container name.

### Examples running it directly

Passing a docker container name: `./successrate.sh storjv3`

Passing a log file: `./successrate.sh /data/storagenode.log`


### Examples running it through docker

Unfortunately, running it through a docker container you can only run it with option (b), passing a log file.

```
docker run --rm -v "<<path to successrate.sh folder>>:/tools" -v "<<path to the log file folder>>:/data" bash /tools/successrate.sh /data/storagenode.log
```

Remember to update the "<< path...>>" place holders of the above instruction to your correct local path directories.


## Locale error fix
If you see errors like `./successrate.sh: line 68: printf: 99.8048: invalid number` try running the script with
```
LC_ALL=C ./successrate.sh
```

Example output:
```
========== AUDIT =============
Successful:           27035
Recoverable failed:   398
Unrecoverable failed: 0
Success Rate Min:     98.549%
Success Rate Max:     100.000%
========== DOWNLOAD ==========
Successful:           757353
Failed:               5079
Success Rate:         99.334%
========== UPLOAD ============
Successful:           1366111
Rejected:             1936
Failed:               154270
Acceptance Rate:      99.858%
Success Rate:         89.853%
========== REPAIR DOWNLOAD ===
Successful:           4124
Failed:               11337
Success Rate:         26.674%
========== REPAIR UPLOAD =====
Successful:           24366
Failed:               5884
Success Rate:         80.549%
```
