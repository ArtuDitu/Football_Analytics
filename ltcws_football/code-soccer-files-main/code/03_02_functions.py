import pandas as pd
import numpy as np
from os import path

# change this to the directory where the csv files that come with the book are
# stored
# on Windows it might be something like 'C:/mydir'

DATA_DIR = '/Users/artur/Dropbox/Football/Football_Analytics/ltcws_football/code-soccer-files-main/data/'

# load adp data
pg = pd.read_csv(path.join(DATA_DIR, 'player_match.csv'))
# shot = pd.read_csv(path.join(SO, 'shots.csv'))

pg[['match_id', 'player_id', 'date']] = (
    pg[['match_id', 'player_id', 'date']].astype(str))

# book picks up here:

pg.mean()
pg.max()

# Axis
pg[['shot', 'goal', 'assist', 'pass']].mean(axis=0)
pg[['shot', 'goal', 'assist', 'pass']].mean(axis=1).head()

# Summary functions on boolean columns
pg['defender_scored'] = (pg['pos'] == 'DEF') & (pg['goal'] > 0)

pg['defender_scored'].mean()
pg['defender_scored'].sum()

(pg['pass'] > 100).any()
(pg['pass'] > 0).all()

(pg[['air_duel_won', 'interception']] > 5).any(axis=1)

(pg[['air_duel_won', 'interception']] > 5).any(axis=1).sum()

(pg[['air_duel_won', 'interception']] > 5).all(axis=1).sum()

# Other misc built-in summary functions
pg['team'].value_counts()

pg['team'].value_counts(normalize=True)

pd.crosstab(pg['team'], pg['pos'])

### Exercises
pm = pd.read_csv(path.join(DATA_DIR, 'player_match.csv'))
pm['named_pass1'] = pm['clearance'] + pm['cross'] + pm['assist'] + pm['keypass']
pm['named_pass2'] = pm[['clearance', 'cross', 'assist', 'keypass']].sum(axis = 1)

(pm['named_pass1'] == pm['named_pass2']).all()

pm[['shot', 'assist', 'pass']].mean()
((pm['goal'] > 0) & (pm['assist'] > 0)).sum()

((pm['goal'] > 0) & (pm['assist'] > 0)).sum()/pm.shape[0]

pm['own_goal'].sum()

pm['pos'].value_counts()












