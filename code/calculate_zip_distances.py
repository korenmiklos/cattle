import os
from dbfpy import dbf
import csv
from geopy import distance

class Point(object):
	def __init__(self,name,lat,lng):
		self.name = str(name)
		self.lat = float(lat)
		self.lng = float(lng)

	def distance(self,point):
		# distance in kms
		return distance.distance((self.lat,self.lng),(point.lat,point.lng)).km

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
cities = csv.reader(open('../data/census/cbp/urban.csv', 'rb'))

zipout = csv.writer(open('../data/census/cbp/zip.csv','wb'))


msa_points = []
for row in msas:
	try:
		msa_points.append(Point(row[0],float(row[1]), float(row[2])))
	except:
		pass

city_points = []
for row in cities:
	try:
		city_points.append(Point(row[0],float(row[1]), float(row[2])))
	except:
		pass


zipout.writerow(['zip', 'area', 'lat', 'lng', 'msa', 'msadistance', 'city', 'citydistance'])
for record in zips:
	print record['GEOID10']
	zip_point = Point(record['GEOID10'],float(record['INTPTLAT10']), float(record['INTPTLON10']))
	msaclosest = zip_point.find_closest(msa_points)
	msadistance = zip_point.distance(msaclosest)
	cityclosest = zip_point.find_closest(city_points)
	citydistance = zip_point.distance(cityclosest)
	zipout.writerow([int(record['GEOID10']), 
		int(record['ALAND10']), 
		float(record['INTPTLAT10']), 
		float(record['INTPTLON10']),
		msaclosest.name,
		msadistance,
		cityclosest.name,
		citydistance])




