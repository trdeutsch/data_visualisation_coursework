-- Define a CTE named fee_23 to get transfer data for 23/24 season
with fee_23 as(
	-- Start selecting relevant columns for player transfers
	select
	player_id -- Unique identifier for each player
	, player_name -- Name of the player
	, t.to_club_name club_name -- Destination club name, aliased as club_name
	, transfer_fee -- Fee paid for the transfer
	, g.game_id -- Unique identifier for each game
	from transfermarkt.clubs c -- Start from clubs table
	join transfermarkt.transfers t -- Join with transfers table
	on c.club_id=t.to_club_id -- Match clubs with their transfers
	join transfermarkt.club_games cg -- Join with club_games to get match data
	on c.club_id=cg.club_id -- Match clubs with their games
	join transfermarkt.games g -- Join with games table
	on cg.game_id=g.game_id -- Match club_games with actual games
	join transfermarkt.competitions co -- Join with competitions table
	on g.competition_id=co.competition_id -- Match games with their competitions
	where co.name='premier-league' -- Filter for Premier League only
	and g.season=2023 -- Filter for 2023 season
	and transfer_season='23/24' -- Filter for 23/24 transfer window
	and transfer_fee is not null -- Only include transfers with a fee
	group by t.player_id, t.player_name, club_name, transfer_fee, g.game_id, transfer_season -- Group by relevant columns
	order by club_name, t.player_name -- Sort by club and player names
)
-- Main query to get player statistics
select
player_name -- Player's name
, club_name -- Club name
, transfer_fee -- Transfer fee paid
, sum(goals) goals -- Total goals scored
, sum(assists) assists -- Total assists made
, sum(minutes_played) minutes_played
, position -- Player's position
from(
	-- Subquery to join transfer data with player stats
	select
	fee_23.player_name -- Player name from fee_23 CTE
	, fee_23.club_name -- Club name from fee_23 CTE
	, fee_23.transfer_fee/1000000 transfer_fee -- Convert transfer fee to millions
	, goals -- Goals scored
	, assists -- Assists made
	, minutes_played
	, position -- Player's position
	from fee_23 -- Use the fee_23 CTE
	join transfermarkt.players p -- Join with players table
	on fee_23.player_id=p.player_id -- Match players with their transfer data
	join transfermarkt.appearances a -- Join with appearances table
	on (fee_23.player_id=a.player_id and fee_23.game_id=a.game_id) -- Match players with their game appearances
)
-- Group final results by player details
group by player_name, club_name, transfer_fee, position
-- Sort by club name, then goals (descending), then assists (descending)
order by club_name, goals desc, assists desc