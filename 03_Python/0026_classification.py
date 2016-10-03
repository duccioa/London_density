import pandas as pd
from sqlalchemy import create_engine
import pandas.io.sql as psql
pd.set_option('display.width', 640)
#### Create common variables ####
engine = create_engine('postgresql://postgres:postgres@localhost:5432/msc')
gsi_legend = {'low coverage': (0, 0.188), 'medium coverage': (0.1881, 0.277), 'high coverage': (0.2771, 1)} # quantiles
building_height_legend = {'low rise': (0, 2.5), 'mid-low rise': (2.5, 6.5), 'mid-high rise': (6.5, 12.5), 'high rise': (12.5, 200)}

#### Load Data ####
# Create csv from sql query (reading query takes too long, easier to write/read csv)
psql.execute('''copy (SELECT t1.block_id,
				t1.gsi,
				t1.total_floor_surface AS total_floor_surface_h300,
				t1.fsi AS fsi_h300,
				t1.w_avg_nfloors AS w_avg_nfloors_h300,
				t2.total_floor_surface350 AS total_floor_surface_h350,
				t2.fsi350 AS fsi_h350,
				t2.w_avg_nfloors350 AS w_avg_nfloors_h350,
				label AS label_h300,
				t1.caz
				FROM london_index.block_cluster_labels AS t1
				INNER JOIN support.block350h AS t2
				ON (t1.block_id=t2.block_id)
				)
				To '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/00_DbDump/block_h350.csv' HEADER CSV;''',
                engine)
df = pd.read_csv('/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity/05_Data/00_DbDump/block_h350.csv')
########################################### BLOCK CLASSIFICATION ###########################################
####### Single blocks #######
index = df.loc[(df.gsi <= 1) & (df.fsi>0)]


building_height_labels=[]
for i in index.w_avg_nfloors:
	for key, values in building_height_legend.items():
		if i >= min(values) and i <max(values):
			building_height_labels.append(key)
print(len(building_height_labels))
gsi_labels=[]
for i in index.gsi:
	for key, values in gsi_legend.items():
		if i >= min(values) and i <max(values)+0.0001:
			gsi_labels.append(key)
print(len(gsi_labels))
classification=[]
for i in range(0,len(gsi_labels)):
	st = building_height_labels[i] + ' - ' + gsi_labels[i]
	classification.append(st)
print(len(classification))

classification=pd.DataFrame({'block_id':index.block_id, 'label':classification}, index=index.index)
index = pd.merge(index, classification)
index.replace('NaN', 0, inplace=True)
index = index[~index.block_id.isin([60762, 30571, 60769, 30497])]
summary = index.groupby('label').describe()
summary.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_summary.csv')
index.to_csv('/Users/duccioa/CLOUD/C07_UCL_SmartCities/08_Dissertation/03_Data/DbDump/block_classification.csv', index=False, index_label=False)
