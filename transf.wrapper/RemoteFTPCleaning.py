#! /usr/bin/python
import ftplib
from subprocess import Popen, PIPE
import os, inspect,sys #time
cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"ftputil-2.2.3/")))
if cmd_subfolder not in sys.path:
        sys.path.insert(0, cmd_subfolder)
import ftputil

"""example:
$python RemoteFTPCleaning.py pack_ftp_upload_20130910_0.clean pack_ftp_upload_20130910_0.net 

$ cat pack_ftp_upload_20130910_0.clean
/webdev/test/queue1.txt
/webdev/test/dirvuota
$ cat pack_ftp_upload_20130910_0.net 
host mfs.s.cmcc.bo.it
user girardi
pass XXXXXXX

"""
def findSentence(list,sentence):
   result=False
   for item in list:
       if sentence in item :  
              result=True
   return result
   
def getConfig(list,string):
        for i in xrange(0,len(list)):
            if string in list[i]:
               return list[i][1]

try:
        filename=sys.argv[1]
        filenet=sys.argv[2]    
except:
        print sys.argv[0],"requires:"
        print "                   1) file names list "
        print "                   2) file network config "
        sys.exit(1)

BODY=[]
for line in open(filenet):
                 BODY.append(line.split())

host1=getConfig(BODY,'host')
user=getConfig(BODY,'user')
passwd=getConfig(BODY,'pass')


host = ftputil.FTPHost(host1, user, passwd, session_factory=ftplib.FTP)
host.stat_cache.enable()
#host.stat_cache.resize(200000000)
host.stat_cache.max_age = 60 * 60


if os.path.getsize(filename) == 0:
       print "no files to remove"
       #sys.exit(2)
retCode=0       
dir=['']
LIST=[]
for name in open(filename):
   if not filter(lambda x: os.path.dirname(name) in x, dir ):    
      dir.append(os.path.dirname(name))
    
if '' in dir:
  dir.remove('')
for dirname in dir:
    if not host.path.exists(dirname) :
           print dirname, " : No such directory !!!"
           retCode=1
           sys.exit(1) 
    #else:
    #       for i in host.listdir(dirname):
    #             LIST.append(dirname+'/'+i)
######
for name in open(filename):
    #host.chdir(os.path.dirname(name.strip()))
    #if host.path.getmtime(name) < (now - (7 * 86400)):
    """
    try: 
         host.path.exists(name.strip())
    except ftputil.ftp_error.TemporaryError:
           print name.strip(), ": No such file or directory !!!" 
           retCode=1 #sys.exit(1)  
    """
    mylst = map(lambda each:each.replace('//', '/'), [name])
    mystg = mylst[0].strip()
    """
    if not filter(lambda x: mystg in x, LIST ): 
           print "missing file/dir ",mystg," : return exit code 1"
           retCode=1 # sys.exit(1)
    else:
       if host.path.isfile(mystg):  ### time-consuming with large directory
        print "removing file -> ",mystg 
        #host.remove(name.strip()) ### time-consuming with large directory
        argList=[ user,passwd,host1,os.path.dirname(mystg),os.path.basename(mystg) ,'>>/dev/null' ]
        os.system(os.path.dirname(os.path.realpath(__file__))+'/RemoteRM.sh %s' % ' '.join(argList))
       else:
         if  host.path.isdir(mystg): 
            print "removing empty dir ->",mystg
            try:
              host.rmdir(mystg)
            except ftputil.ftp_error.PermanentError:
              print "dir not empty !"
              retCode=1 #sys.exit(1) 
    """
    #if not findSentence(LIST,mystg):
    #if not filter(lambda x: mystg in x, LIST ): 
    #       print "missing file/dir ",mystg," : return exit code 1"
    #       retCode=1 # sys.exit(1)
    #else:
    argList=[ user,passwd,host1,os.path.dirname(mystg),os.path.basename(mystg) ,'>>/dev/null' ]
    p=Popen([os.path.dirname(os.path.realpath(__file__))+'/RemoteFileRM.sh', filenet, argList[3], argList[4],argList[5]], stdout=PIPE, stderr=PIPE, stdin=PIPE)
    output = p.stdout.read().rstrip('\n').splitlines() 
    #print output 
    if findSentence(output,"Is a directory") or findSentence(output,"Usage: rm [-r]"):
              print "removing empty dir ->",mystg
              argList=[ user,passwd,host1,mystg,'>>/dev/null' ]
              p=Popen([os.path.dirname(os.path.realpath(__file__))+'/RemoteDirRM.sh', filenet, argList[3], argList[4]], stdout=PIPE, stderr=PIPE, stdin=PIPE)
              output = p.stdout.read().rstrip('\n').splitlines() 
              if findSentence(output,"Directory not empty"):
                     print "Directory not empty ",mystg," : return exit code 1"
                     retCode=1 # sys.exit(1)
              """
              try:
                host.rmdir(mystg)
              except ftputil.ftp_error.PermanentError:
                print "dir not empty !"
                retCode=1 #sys.exit(1) 
              """
    else:    
              if findSentence(output,"No such file or directory"):
                     print "missing file/dir ",mystg," : return exit code 1"
                     retCode=1 # sys.exit(1)
              else: 
                     print "removing file -> ",mystg 
 
    
print 'Closing FTP connection'
host.close()
if retCode == 1:
   sys.exit(1) 
