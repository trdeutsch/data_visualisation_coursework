-- CTE to calculate wins per club per season
with wins as(
	-- Main select for wins aggregation
	select
	name                    -- Club name from clubs table
	, club_id              -- Club ID for joining
	, season               -- Season for temporal analysis
	, count(is_win) win    -- Count of wins in the season
	from(
			-- Subquery to get raw win data
			select
			c.name         -- Club name from clubs table
			, c.club_id    -- Club ID for joining
			, season       -- Season from games table
			, is_win       -- Boolean win indicator
			from transfermarkt.clubs c
			join transfermarkt.club_games cg
			on c.club_id=cg.club_id                -- Link clubs to their games
			join transfermarkt.games g
			on cg.game_id=g.game_id                -- Link club_games to game details
			join transfermarkt.competitions co
			on g.competition_id=co.competition_id   -- Link games to competition info
			where co.name='premier-league'          -- Filter for Premier League only
			and season between 2012 and 2022        -- Season range filter
			and is_win=1                           -- Only count wins
			order by season                        -- Order results by season
		)
	group by name, club_id, season                 -- Group for win counting
)
-- CTE to calculate transfer spending per club per season
, transfer_fee as(
	-- Main select for transfer fee aggregation
	select
	to_club_name                                   -- Receiving club name
	, to_club_id                                   -- Receiving club ID
	, sum(transfer_fee)/1000000 transfer_fee       -- Sum of transfers in millions
	, transfer_season                              -- Season of transfers
	from(
		-- Subquery to prepare transfer data
		select
		to_club_name                               -- Receiving club name
		, to_club_id                               -- Receiving club ID
		, transfer_fee                             -- Individual transfer amount
		, cast(concat(20, substring(transfer_season, 1, 2)) as numeric) transfer_season  -- Convert season format to year
		from transfermarkt.transfers
		where transfer_season in ('12/13', '13/14', '14/15', '15/16',   -- Filter seasons
		'16/17', '17/18', '18/19', '19/20', '20/21', '21/22', '22/23')
		and (transfer_fee is not null and transfer_fee!=0)               -- Exclude null/zero transfers
		order by transfer_season                                         -- Order by season
	)
	group by to_club_name, to_club_id, transfer_season                  -- Group for fee summation
)

-- Final result set combining wins and transfer data
select
name                                               -- Club name
, transfer_fee                                     -- Total transfer spending
, win                                             -- Number of wins
, season                                          -- Season
from wins
join transfer_fee
on wins.club_id=transfer_fee.to_club_id           -- Join on club ID
and wins.season=transfer_fee.transfer_season       -- And matching season
order by name, transfer_fee desc, win desc         -- Order by club, spending, wins