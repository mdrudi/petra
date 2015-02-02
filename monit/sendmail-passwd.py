import smtplib, sys
from email.mime.multipart import MIMEMultipart, MIMEBase
from email.mime.text import MIMEText
from email.utils import formatdate

def find(input_list1,input_list2,value1,value2):
        out_list=[]
        for ind, itm in enumerate(input_list1):
           if itm == value1 and input_list2[ind]==value2:
              out_list.append(ind)
        return out_list
              
def send_mail(send_from,send_to, subject, html, host,user,passwd,server):
   COMMASPACE = ', '
   msg = MIMEMultipart('alternative')
   msg['From'] = host +' <'+send_from+'>'
   msg['To'] = COMMASPACE.join(send_to)
   msg['Date'] = formatdate(localtime=True)
   msg['Subject'] = subject
   
   
   part1 = MIMEText(html, 'html')
   #part2 = MIMEText(text, 'plain')
   
   msg.attach(part1)
   #msg.attach(part2)
   #sys.exit(0)
   
   try:
     smtpObj = smtplib.SMTP(server)
     smtpObj.ehlo()
     smtpObj.starttls()
     smtpObj.login(user,passwd)  
     for index in range(0,len(send_to)):
       for receiver in send_to[index].split(',') :
         smtpObj.sendmail(send_from, receiver, msg.as_string())    
     smtpObj.close()
     print "Successfully sent email to:", COMMASPACE.join(send_to)
     sys.exit(0) 
   except smtplib.SMTPException:
     print "Error: unable to send email" 
     sys.exit(1)



if __name__=='__main__':
    import os, inspect 
    cmd_subfolder = os.path.realpath(os.path.abspath(os.path.join(os.path.split(inspect.getfile( inspect.currentframe() ))[0],"HTML.py-0.04/")))
    if cmd_subfolder not in sys.path:
        sys.path.insert(0, cmd_subfolder)
    import csv 
    import HTML
    sender = 'info.products@bo.ingv.it'
    receivers = ['giacomo.girardi@bo.ingv.it','info.products@bo.ingv.it']

    try:
        textfile=sys.argv[1]    #'/tmp/mfstest2/monit_log/mail-drudi@bo.ingv.it.txt'
        module=sys.argv[2]      # MFS_SYS4D 
        passfile=sys.argv[3]    #pass.txt
    except:
        print "Insert mail body .txt for reading failed events"
        sys.exit(1)
    #print 'Reading: ',textfile
    fp=[] ; NEW=[]    
    PDAY=[]  ; LINE=[] ; EVENT=[] ; TTIME=[] ; RECIP=[] ; NOTE=[]
    
    if not os.path.exists(textfile):
            print "No mail to send: exit"
            sys.exit(0) 
    with open(passfile, 'rb') as txtfile:
       names = txtfile.read().splitlines()
    server = filter(lambda x:'server' in x , (item.split(',')  for item in names))[0][1].strip()
    username=filter(lambda x:'username' in x , (item.split(',')  for item in names))[0][1].strip()
    password=filter(lambda x:'password' in x , (item.split(',')  for item in names))[0][1].strip()
    host=filter(lambda x:'sendfrom' in x , (item.split(',')  for item in names))[0][1].strip()
    update=filter(lambda x:'update' in x , (item.split(',')  for item in names))[0][1].strip()

    with open(textfile, 'rb') as csvfile:
       spamreader = csv.reader(csvfile, delimiter=';', quotechar='|')
       for row in spamreader:
          fp.append(row[1:])
       
    for i in range(0,len(fp)):
         #print "i=",i
         if i>=1 and len(find(EVENT,PDAY,fp[i][5],fp[i][0])) > 0 :
                #print "skip",find(EVENT,PDAY,fp[i][5],fp[i][0])
                pass
         else:
           #print "append",fp[i][5]
           PDAY.append(fp[i][0])
           LINE.append(fp[i][1])
           EVENT.append(fp[i][5])
           TTIME.append(fp[i][3])
           RECIP.append(fp[i][4])
           #print PDAY , EVENT , LINE , TTIME , RECIP
           #print len(fp[i]) , fp[i]
           #print i,NOTE
           if (len(fp[i]) -1 ) > 5 :
             NOTE.append(fp[i][6])
           else:
             NOTE.append('')   

    
    for i in xrange(0,len(EVENT)):
         NEW.append([ PDAY[i],EVENT[i],TTIME[i],RECIP[i],NOTE[i] ])
    receivers=[RECIP[0]]    
    NEW.insert(0,['ProcDay','Event','Target Time','recipients','Note'])
    htmlcode = HTML.table(NEW)
    
    htmlhead = """\
<html>
 <head></head>
 <body>
   <p>{code} check every {time}':<br>
                  <br>
   </p>
 </body>
    """.format(code=module,time=update)
    htmlend  ="""
</html>"""
    
    htmlcode=htmlhead+htmlcode+htmlend   
    #print htmlcode
    send_mail(sender,receivers,module+" monit e-mail ",htmlcode,host,username,password,server)
