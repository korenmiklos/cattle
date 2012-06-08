import pysal
import os
from dbfpy import dbf
import csv
from geopy import geocoders

def find_folder(data_path):
	dir = os.path.abspath(os.getcwd())
	while True:
	  candidate = os.path.join(dir, data_path)
	  if os.path.isdir(candidate):
	     return candidate
	  # go up
	  parent = os.path.dirname(dir)
	  print parent
	  is_root = (len(dir) <= len(parent))
	  if is_root:
	     raise IOError('Data path not found: {0}'.format(data_path))
	  dir = parent

shapefiles = find_folder('SparkleShare/County-Business-Patterns/shapefiles')
msas = dbf.Dbf('%s/msa2010/tl_2010_us_csa10.dbf' % shapefiles)
gm = geocoders.Yahoo(app_id='EuuQAJ36')
msaout = csv.writer(open('../data/census/cbp/msa.csv','wb'))

msaout.writerow(['msa', 'lat', 'lng'])
for record in msas:
	name = record['NAME10']
	state = name.split(',')[1].split('-')[0]
	# skip puerto rico
	if not state.strip()=='PR':
		firstcity = name.split(',')[0].split('-')[0]
		results = gm.geocode('%s, %s, United States' % (firstcity, state), exactly_one=False)
		place, (lat, lng) = results[0]
		msaout.writerow(['%s, %s' % (firstcity, state), lat, lng])


