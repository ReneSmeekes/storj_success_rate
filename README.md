# Success Rate Tool

This script calculates success rates for audits, downloads, uploads and repair traffic.

_Note: If your container name is different from the default 'storagenode' you can pass it as an argument to the script. Example:_ `./successrate.sh storjv3`

_Note 2: If you have redirected the docker logs to a file you can change the LOG parameter to a cat command. Example can be found in the script._

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
