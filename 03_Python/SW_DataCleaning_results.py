# Data cleaning for the results of the StreetWidth intersection
# By Duccio Aiazzi
import pandas as pd
from sqlalchemy import create_engine
import pandas.io.sql as psql
pd.set_option('display.width', 640)


root_dir = '/Users/duccioa/CLOUD/01_Cloud/01_Work/04_Projects/0026_LondonDensity'
engine = create_engine('postgresql://postgres:postgres@localhost:5432/msc')
res = pd.read_sql_query('SELECT gid, w_avg_h, side, iteration FROM london_streetwidth.results '
                        'WHERE iteration != 0 AND iteration != 1 AND iteration != -1', engine)

for i in res.gid:
	df_right=res.loc[(res['gid']==i) & (res['side'].bool)] # Select segment and side
	print(df)

