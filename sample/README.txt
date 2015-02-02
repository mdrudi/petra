Esempio di un sistema di produzione

con questi plugin :
event
proc
download

come esempio c'e' definita una queue : queue-tutto.txt

due comandi da utilizzare per eseguire la coda di esempio 
questi possono essere eseguiti tutti i giorni a frequenza stabilita, garantendo l'esecuzione continua degli ultimi due giorni di produzione.

Richiede:
/tmp/[user]/scheduler_log
/tmp/[user]/transf.indata_log
/tmp/[user]/transf.file_log
/tmp/eventmng/[user]
/tmp/[user]/scheduler_work


Per i singoli handler 

PO.download.sh
/home/[user]/transf.indata/PO

river_po.proc.sh
/home/[user]/transf.indata/MFS_INDATA

PO_READY.event2file.sh
/home/[user]/workdir/event2file


HCMRIndex.download.sh
/home/[user]/transf.indata/HCMRIndex

ARGO.download.sh
/home/[user]/transf.indata/ARGO/

