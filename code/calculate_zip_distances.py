import pysal
import os
from dbfpy import dbf
import csv
from scipy import sin, cos, arccos

class Point(object):
	def __init__(self,name,lat,lng):
		self.name = str(name)
		self.lat = float(lat)
		self.lng = float(lng)

	def distance(self,point):
		# distance in kms
		return 6378 * arccos(sin(point.lng/180) * sin(self.lng/180) + cos(point.lng/180) * cos(self.lng/180) * cos(point.lat/180 - self.lat/180))

	def find_closest(self,points):
		distance = 99999
		closest = None
		for point in points:
			dst = self.distance(point)
			if dst < distance:
				distance = dst
				closest = point
		return closest

	def distance_to_closest(self,points):
		closest = self.find_closest(points)
		return self.distance(closest)

def find_folder(data_path):
	dir = os.path.abspath(os.getcwd())
	while True:
	  candidate = os.path.join(dir, data_path)
	  if os.path.isdir(candidate):
	     return candidate
	  # go up
	  parent = os.path.dirname(dir)
	  is_root = (len(dir) <= len(parent))
	  if is_root:
	     raise IOError('Data path not found: {0}'.format(data_path))
	  dir = parent

shapefiles = find_folder('SparkleShare/County-Business-Patterns/shapefiles')
zips = dbf.Dbf('%s/zip2010/tl_2010_us_zcta510.dbf' % shapefiles)
msas = csv.reader(open('../data/census/cbp/msa.csv', 'rb'))

zipout = csv.writer(open('../data/census/cbp/zip.csv','wb'))


msa_points = []
for row in msas:
	try:
		msa_points.append(Point(row[0],float(row[1]), float(row[2])))
	except:
		pass


zipout.writerow(['zip', 'area', 'lat', 'lng', 'msa', 'distance'])
for record in zips:
	zip_point = Point(record['GEOID10'],float(record['INTPTLAT10']), float(record['INTPTLON10']))
	closest = zip_point.find_closest(msa_points)
	distance = zip_point.distance_to_closest(msa_points)
	zipout.writerow([int(record['GEOID10']), 
		int(record['ALAND10']), 
		float(record['INTPTLAT10']), 
		float(record['INTPTLON10']),
		closest.name,
		distance])




