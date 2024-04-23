import pandas as pd
from os import path

# change this to the directory where the csv files that come with the book are
# stored
# on Windows it might be something like 'C:/mydir'

DATA_DIR = '/Users/artur/Dropbox/Football/Football_Analytics/ltcws_football/code-soccer-files-main/data/'

pg = pd.read_csv(path.join(DATA_DIR, 'player_match.csv'))  # player-game
games = pd.read_csv(path.join(DATA_DIR, 'matches.csv'))  # game info
player = pd.read_csv(path.join(DATA_DIR, 'players.csv')) # player info

# player game data
pg[['player_id', 'match_id', 'name', 'team', 'shot', 'goal', 'assist']].head(5)

# game table
player[['player_id', 'player_name', 'pos', 'team', 'birth_date']].head()

# Merge Question 1. What columns are you joining on?
pd.merge(pg, player[['player_id', 'birth_date']], on='player_id').head(5)

pass_df = pg[['match_id', 'player_id', 'pass', 'assist']]
shot_df = pg[['match_id', 'player_id', 'shot', 'goal']]

combined = pd.merge(pass_df, shot_df, on=['match_id', 'player_id'])
combined.head()

# Merge Question 2. Are you doing a 1:1, 1:many (or many:1), or many:many
# join?player.head()

player['player_id'].duplicated().any()

combined['player_id'].duplicated().any()

pd.merge(combined, player[['player_id', 'player_name', 'pos', 'team']]).head()

# pd.merge(combined, games, validate='1:1')  # this will fail since it's 1:m

# Merge Question 3. What are you doing with unmatched observations?
goal_df = pg.loc[pg['goal'] > 0, ['match_id', 'player_id', 'goal']]

assist_df = pg.loc[pg['assist'] > 0, ['match_id', 'player_id', 'assist']]

goal_df.shape
assist_df.shape

comb_inner = pd.merge(goal_df, assist_df)
comb_inner.shape

comb_inner.head()

comb_left = pd.merge(goal_df, assist_df, how='left')
comb_left.shape

comb_left.head()

comb_outer = pd.merge(goal_df, assist_df, how='outer', indicator=True)
comb_outer.shape

comb_outer['_merge'].value_counts()

comb_outer.query("_merge == 'both'")['player_id'].value_counts()

player.query("player_id == 25776")[['player_name', 'pos', 'team']]

# More on pd.merge
# left_on and right_on
goal_df = pg.loc[pg['goal'] > 0, ['match_id', 'player_id', 'goal']]
goal_df.columns = ['match_id', 'scorer_id', 'goal']

assist_df = pg.loc[pg['assist'] > 0, ['match_id', 'player_id', 'assist']]
assist_df.columns = ['match_id', 'passer_id', 'assist']

pd.merge(goal_df, assist_df, left_on=['match_id', 'scorer_id'],
         right_on=['match_id', 'passer_id']).head()

# merging on index
max_goals = (goal_df
               .groupby('scorer_id')
               .agg(max_goals = ('goal', 'max')))

max_goals.head()

max_goals.value_counts(normalize=True)

pd.merge(goal_df, max_goals, left_on='scorer_id', right_index=True).head()

#############
# pd.concat()
#############
goal_df = (pg.loc[pg['goal'] > 0, ['match_id', 'player_id', 'goal']]
           .set_index(['match_id', 'player_id']))

assist_df = (pg.loc[pg['assist'] > 0, ['match_id', 'player_id', 'assist']]
             .set_index(['match_id', 'player_id']))

goal_df.head()

pd.concat([goal_df, assist_df], axis=1).head()

tackle_df = (pg.loc[pg['tackle'] > 0, ['match_id', 'player_id', 'tackle']]
           .set_index(['match_id', 'player_id']))

pd.concat([goal_df, assist_df, tackle_df], axis=1).head()

#### Combining DataFrames Vertically
mids = pg.loc[pg['pos'] == 'MID']
fwds = pg.loc[pg['pos'] == 'FWD']

mids.shape
fwds.shape

pd.concat([mids, fwds]).shape

mids_reset = mids.reset_index(drop=True)
fwds_reset = fwds.reset_index(drop=True)

mids_reset.head()

pd.concat([mids_reset, fwds_reset]).sort_index().head()

pd.concat([mids_reset, fwds_reset], ignore_index=True).sort_index().head()

# Exercises

DATA_DIR_Problems = '/Users/artur/Dropbox/Football/Football_Analytics/ltcws_football/code-soccer-files-main/data/problems/combine1/'

d_name = pd.read_csv(path.join(DATA_DIR_Problems, 'name.csv'))
d_ob = pd.read_csv(path.join(DATA_DIR_Problems, 'ob.csv'))
d_pass = pd.read_csv(path.join(DATA_DIR_Problems, 'pass.csv'))
d_shot = pd.read_csv(path.join(DATA_DIR_Problems, 'shot.csv'))


df_comb1 = pd.merge(d_name, d_ob, how = 'left')
df_comb1 = pd.merge(df_comb1, d_pass, how = 'left')
df_comb1 = pd.merge(df_comb1, d_shot, how = 'left')
df_comb1 = df_comb1.fillna(0)


df_comb2 = pd.concat([d_name.set_index(['player_id', 'match_id']),
                     d_ob.set_index(['player_id', 'match_id']),
                     d_pass.set_index(['player_id', 'match_id']),
                     d_shot.set_index(['player_id', 'match_id'])],
                     join = 'outer', axis = 1)

df_comb2 = df_comb2.fillna(0)

DATA_DIR_Problems2 = '/Users/artur/Dropbox/Football/Football_Analytics/ltcws_football/code-soccer-files-main/data/problems/combine2/'

d_def = pd.read_csv(path.join(DATA_DIR_Problems2,'def.csv'))
d_fwd = pd.read_csv(path.join(DATA_DIR_Problems2,'fwd.csv'))
d_mid = pd.read_csv(path.join(DATA_DIR_Problems2,'mid.csv'))

d_comb = pd.concat([d_def, d_fwd,d_mid], ignore_index=True)

d_teams = pd.read_csv(path.join(DATA_DIR, 'teams.csv'))

groups = ['A', 'B', 'C', 'D', 'E', 'F','G','H']

for group in groups:
    (d_teams.query(f"grouping == '{group}'")).to_csv(path.join(DATA_DIR, f"d_teams_{group}.csv"), 
                                                     index = False)
    

df_combined = pd.concat([pd.read_csv(path.join(DATA_DIR, f'd_teams_{group}.csv')) for group in groups], ignore_index=True)





