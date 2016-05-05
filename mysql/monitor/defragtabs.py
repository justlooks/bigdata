#!/usr/bin/python
#
# usage :   defragtabs.py --host localhost --user root --password
#
############################

import MySQLdb
import getopt
import sys

sql_str = '''SELECT CONCAT(CONCAT(TABLE_SCHEMA, '.'), TABLE_NAME),Data_free FROM information_schema.TABLES WHERE TABLE_SCHEMA NOT IN ('information_schema','performance_schema', 'mysql') AND Data_free > 0 AND NOT ENGINE='MEMORY' order by Data_free desc'''

def usage():
	print "yes"

try:
	long_options = ['host=', 'password=', 'user=']
   	opts, args = getopt.getopt(sys.argv[1:], "h:p:u:", long_options)
except getopt.GetoptError as err:
   	# Print help information and exit
	usage()
	sys.exit(2)


for o, a in opts:
	if o in ['-h','--host']:
		host = a
	if o in ['-u','--user']:
		user = a
	if o in ['-p','--password']:
		ssap = a

print 'i get ' + host + ' ' + user + ' ' + ssap
db = MySQLdb.connect(host,user,ssap,"information_schema",unix_socket="/tmp/mysql.sock")
cursor = db.cursor()
try:
	cursor.execute(sql_str)
#	cursor.execute('select version()')
	'''
	data = cursor.fetchone()
	print "Database version : %s " % data
	'''
	results = cursor.fetchall()
	for row in results:
		tabname = row[0]
		datafree = row[1]
		if datafree > 1000000:
			print 'defrag ' + tabname + '...'
			cursor.execute('OPTIMIZE TABLE ' + tabname)
except:
   print "Error: unable to fecth data"
cursor.close()
db.close()
