#!/bin/sh

FRONTEND_PID=`jps | grep ProdServerStart | cut -d' ' -f1`
if [ $FRONTEND_PID ]; then 
  kill $FRONTEND_PID
  echo "killed frontend PID " $FRONTEND_PID
else 
  echo "FRONTEND is not running"
fi

for pid in `jps | grep Launcher  | cut -d' ' -f1`
do
   echo "killing PID ${pid}"
   kill -9 ${pid}
done

