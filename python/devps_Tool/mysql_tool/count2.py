#!/usr/bin/env python
# -*- coding: utf-8 -*- 

###install model###
####pip install MySQL-python###
###yum install MySQL-python####
import  MySQLdb
import datetime 


class Pymyql:
    error_code ='' #MySQL锟斤拷锟斤拷锟斤拷锟�

    _instance = None #锟斤拷锟斤拷锟绞碉拷锟�
    _conn = None # 锟斤拷锟捷匡拷conn
    _cur = None #锟轿憋拷

    _TIMEOUT = 30 #默锟较筹拷时30锟斤拷
    _timecount = 0
    def __init__(self,dbconfig):
        try:
            self._conn = MySQLdb.connect(host=dbconfig['host'],
                                         port=dbconfig['port'],
                                         user=dbconfig['user'],
                                         passwd=dbconfig['passwd'],
                                         db=dbconfig['db'])
        except MySQLdb.Error ,e:
            self.error_code = e.args[0]
            error_msg = 'MySQL error!',e.args[0],e.args[1]
            print error_msg
        self._cur = self._conn.cursor()
    def query(self,sql):
        try:
            result = self._cur.execute(sql)
        except MySQLdb.Error, e:
            self.error_code = e.args[0]
            print "锟斤法锟斤拷锟斤拷",e.args[0],e.args[1]
            result = False
        return result
    def fetchAllRows(self):
        return self._cur.fetchall()
    def fetchRowCount(self):
        return self._cur.rowcount
    def fetchoneRow(self):
        return self._cur.fetchone() 
    
    
    def __del__(self):
        try:
            self._cur.close()
            self._conn.close()
        except:
            pass
    def close(self):
        self.__del__()
       
       
       
def countsss(time,dbconfig):
        sql = "select conn_user,conn_pwd,conn_ip,conn_database,conn_port from mj_server_database_conn where server_id in(select server_id from  mj_server_list where iftest=2 and server_status=1) and conn_handle='DB_LOG_CONN'"
        db = Pymyql(dbconfig)
        db.query(sql)
        result  = db.fetchAllRows()
        db.close()
        all_money = 0
        select_money = "select sum(money) as m  from recharge where ptime >=UNIX_TIMESTAMP('%s 00:00:00')" % time
  #      print db_config,select_money
        for i in range(0,len(result)):
         game_config = {'host':result[i][2],'port':result[i][4],'user':result[i][0],'passwd':result[i][1],'db':result[i][3]}
      #   print game_config
         gamedb = Pymyql(game_config)
         gamedb.query(select_money)
         money = gamedb.fetchAllRows()
         money =money[0][0]
      #   print money
         if money == None:
               money = 0
         all_money = all_money + int(money)
         gamedb.close()
        print all_money
    
dbconfig = {'host':'127.0.0.1','port':3306,'user':'root','passwd':'mengJIA#!2015*NB','db':'crystalgames'} 
### sql = "select conn_user,conn_pwd,conn_ip,conn_database,conn_port from mj_server_database_conn where server_id in(select server_id from  mj_server_list where iftest=2 and ifmerge=1) and conn_handle='DB_LOG_CONN'"   already merge###
now = datetime.datetime.now().strftime('%Y-%m-%d')
countsss(now,dbconfig)
