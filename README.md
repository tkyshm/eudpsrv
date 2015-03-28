# Echo Server on UDP
## Requirements
* erlang 17.3

## Create a release package 
```
 make all
```

## Start server by console mode
```
 ./console_rel.sh
```

## Test echo
```
 echo "Hello World!" | nc -u 127.0.0.1 -P 8888
```
