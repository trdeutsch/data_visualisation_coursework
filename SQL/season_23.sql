-- CTE naming follows pattern: [purpose]_[year]
with fee_23 as(
	-- Consistent column selection pattern: entity_name, entity_id, calculated_field
	select
	name
	, club_id
	, sum(transfer_fee)/1000000 transfer_fee_23  -- Naming pattern: [metric]_[year]
	from
	(
		-- Consistent column selection: entity attributes before calculated fields
		select
		distinct
		c.name
		, c.club_id
		, transfer_fee
		-- Consistent table aliasing: first letter of table name
		from transfermarkt.clubs c
		-- Logical join order: main entity -> related entities
		join transfermarkt.transfers t
		on c.club_id=t.to_club_id
		join transfermarkt.club_games cg
		on c.club_id=cg.club_id
		join transfermarkt.games g
		on cg.game_id=g.game_id
		join transfermarkt.competitions co
		on g.competition_id=co.competition_id
		-- Filter conditions ordered: static filters first, then dynamic
		where co.name='premier-league'
		and g.season=2023
		and transfer_season='23/24'
		and (transfer_fee is not null and transfer_fee!=0)
		-- Consistent ordering by entity name
		order by c.name
	)
	-- Group by follows select column order
	group by name, club_id
)
-- Consistent CTE naming pattern continued
, is_win_23 as(
	-- Similar structure to previous CTE
	select
	name
	, club_id
	, count(is_win) win_23  -- Consistent naming: [metric]_[year]
	from
	(
		-- Maintains same column selection pattern
		select
		c.name
		, c.club_id
		, is_win
		-- Same table aliasing pattern
		from transfermarkt.clubs c
		join transfermarkt.club_games cg
		on c.club_id=cg.club_id
		join transfermarkt.games g
		on cg.game_id=g.game_id
		join transfermarkt.competitions co
		on g.competition_id=co.competition_id
		-- Similar filter pattern
		where co.name='premier-league'
		and g.season=2023
		and is_win=1
		order by c.name
	)
	group by name, club_id
)
-- Final select maintains column selection pattern
select
f23.name
, transfer_fee_23 transfer_fee  -- Alias removes year for cleaner output
, win_23 win                    -- Consistent alias pattern
-- CTE aliases follow [purpose][year] pattern
from fee_23 f23
join is_win_23 w23
on f23.club_id=w23.club_id
-- Ordering by metrics in descending order of importance
order by transfer_fee desc, win desc