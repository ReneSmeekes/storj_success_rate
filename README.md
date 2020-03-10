# Success Rate Tool

This script calculates success rates for audits, downloads, uploads and repair traffic on Linux systems.

Alexey built a similar [script for windows](https://github.com/AlexeyALeonov/success_rate) users.

## How to use it

If your operating system can run _bash shell scripts_ you can run the script directly. Otherwise you can run it with the official [_bash_ docker image](https://hub.docker.com/_/bash).

The script accepts one optional argument, which is:

- a) The name of the docker storage node docker container.
- b) The path to a storage node log file.

When the argument isn't provided, then it defauls to option (a) using _storagenode_ as a container name.

### Examples running it directly

Passing a docker container name: `./successrate.sh storjv3`

Passing a log file: `./successrate.sh /data/storagenode.log`


### Examples running it through docker

Unfortunately, running it through a docker container you can only run it with option (b), passing a log file.

```
docker run --rm --mount "type=bind,source=<<path to successrate.sh folder>>,target=/tools,readonly" --mount "type=bind,source=<<path to the log file folder>>,target=/data,readonly" bash /tools/successrate.sh /data/storagenode.log
```

Remember to update the "<< path...>>" place holders in the above instruction to your correct local paths.


## Locale error fix
If you see errors like `./successrate.sh: line 68: printf: 99.8048: invalid number` try running the script with
```
LC_ALL=C ./successrate.sh
```

Example output:
```
========== AUDIT ==============
Critically failed:     0
Critical Fail Rate:    0.000%
Recoverable failed:    0
Recoverable Fail Rate: 0.000%
Successful:            14
Success Rate:          100.000%
========== DOWNLOAD ===========
Failed:                0
Fail Rate:             0.000%
Canceled:              3
Cancel Rate:           1.000%
Successful:            297
Success Rate:          99.000%
========== UPLOAD =============
Rejected:              0
Acceptance Rate:       100.000%
---------- accepted -----------
Failed:                0
Fail Rate:             0.000%
Canceled:              553
Cancel Rate:           28.417%
Successful:            1393
Success Rate:          71.583%
========== REPAIR DOWNLOAD ====
Failed:                0
Fail Rate:             0.000%
Canceled:              0
Cancel Rate:           0.000%
Successful:            0
Success Rate:          0.000%
========== REPAIR UPLOAD ======
Failed:                0
Fail Rate:             0.000%
Canceled:              0
Cancel Rate:           0.000%
Successful:            2
Success Rate:          100.000%
```
