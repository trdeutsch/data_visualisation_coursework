# Import required libraries for data manipulation and visualization
library(tidyverse)    # Load tidyverse package for data manipulation and visualization
library(ggrepel)      # Load ggrepel for better label positioning in plots

# Data Import
all_season=read.csv('/Users/tranduc/Documents/Data Visualisation/Data/all_seasons.csv')    # Import historical season data
View(all_season)      # Display the historical seasons data in a viewer window

season_23=read.csv('/Users/tranduc/Documents/Data Visualisation/Data/season_23.csv')       # Import 2023 season specific data
View(season_23)       # Display the 2023 season data in a viewer window

players_23=read.csv('/Users/tranduc/Documents/Data Visualisation/Data/players_23.csv')     # Import player statistics for 2023
View(players_23)      # Display the player data in a viewer window

# Transfer Fee Analysis
# Filter data for Chelsea and Manchester City clubs
all_season=all_season[all_season[, 'name']=='Manchester City Football Club'|
                        all_season[, 'name']=='Chelsea Football Club', ]

# Create line plot for transfer fees over seasons
ggplot(all_season, 
       aes(x=season))+ # Set x-axis to seasons
geom_line(data=all_season[all_season[, 'name']=='Chelsea Football Club', ], 
          aes(y=transfer_fee, col='Chelsea Football Club'))+ # Add Chelsea's transfer fee line
geom_line(data=all_season[all_season[, 'name']=='Manchester City Football Club', ], 
          aes(y=transfer_fee, col='Manchester City Football Club'))+ # Add Man City's transfer fee line
scale_x_continuous(breaks=seq(min(all_season['season']), max(all_season['season']), by=1))+ # Set x-axis breaks to show all years
scale_colour_manual(name='Team', 
                   values=c('Chelsea Football Club'='darkblue', 
                           'Manchester City Football Club'='lightblue'))+ # Set custom colors for teams
labs(title='Transfer Fee (2012-2022)', 
     x='Season', 
     y='Transfer Fee (million Euro)', 
     caption='Transfermarkt dataset') # Set plot labels

# Winning Analysis
# Filter 2023 season data for Chelsea and Manchester City
season_23=season_23[season_23[, 'name']=='Chelsea Football Club'|
                      season_23[, 'name']=='Manchester City Football Club', ]
season_23    # Display filtered data

# Create bar plot for wins comparison
ggplot(season_23,
       aes(reorder(name, win, decreasing=TRUE), win, fill=name))+ # Set up bar plot with teams ordered by wins
geom_bar(stat='identity')+ # Create bars
geom_text(aes(y=win, label=win), vjust=-0.3)+ # Add win counts above bars
scale_fill_manual(name='Team', values=c('darkblue', 'lightblue'))+ # Set custom colors
labs(title='Number of Wins (2023)', 
     x='Team', 
     y='Number of Wins', 
     caption='Transfermarkt dataset') # Set plot labels

# Transfer Fee Distribution Analysis
# Filter and summarize player data by club and position
players_23=players_23[players_23[, 'club_name']=='Chelsea'|
                        players_23[, 'club_name']=='Man City', ]
players_23=summarise(group_by(players_23, club_name, position), 
                    transfer_fee=mean(transfer_fee)) # Calculate mean transfer fee by position and club

# Create grouped bar plot for transfer fees by position
ggplot(players_23, 
       aes(reorder(position, transfer_fee, decreasing=TRUE), 
           transfer_fee, fill=club_name))+ # Set up grouped bar plot
geom_bar(stat='identity', position='dodge')+ # Create grouped bars
scale_fill_manual(name='Team', values=c('darkblue', 'lightblue'))+ # Set custom colors
labs(title='Distribution of Transfer Fee across different Positions (2023)', 
     x='Position', 
     y='Transfer Fee (million Euro)', 
     caption='Transfermarkt dataset') # Set plot labels

# Cost per Minute Analysis
# Calculate and summarize cost per minute played
players_23=players_23[players_23[, 'club_name']=='Chelsea'|
                        players_23[, 'club_name']=='Man City', ]
players_23['cost_per_min']=round((players_23[, 'transfer_fee']*1000000)/players_23[, 'minutes_played']) # Calculate cost per minute
players_23=summarise(group_by(players_23, club_name, position), 
                    cost_per_min=mean(cost_per_min)) # Calculate mean cost per minute by position and club
players_23    # Display calculated data

# Create stacked bar plot for cost per minute
ggplot(players_23, 
       aes(club_name, cost_per_min, fill=position))+ # Set up stacked bar plot
geom_bar(stat='identity')+ # Create stacked bars
scale_fill_manual(name='Position', 
                  values=c('red', 'green', 'yellow', 'purple'))+ # Set custom colors for positions
labs(title='Cost per Minute for New Positions (2023)', 
     x='Team', 
     y='Cost per Minute (thousand Euro)', 
     caption='Transfermarkt dataset') # Set plot labels