Yesterday=`dirname $0`/../aux/yesterday.py
day=`$Yesterday`
echo $day
sh `dirname $0`/../scheduler/sched_queue.sh `dirname $0`/queue-tutto.txt $day
