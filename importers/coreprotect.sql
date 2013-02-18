-- DECLARE @world TABLE( id INT(1), name VARCHAR(13) ); -- We'll just make a table to get the world by it's id to avoid messy CASE code.
-- INSERT INTO @world (id, name) VALUES (1, "world"); -- If you are a user, you can change these world names to your world names. If you use
-- INSERT INTO @world (id, name) VALUES (2, "world_nether"); -- the default world names, you can leave this as-is.
-- INSERT INTO @world (id, name) VALUES (3, "world_the_end"); -- You can add more of these lines with more names if you have more than 3 worlds.

-- DEV
TRUNCATE TABLE prism_actions;

-- Dev notes:
-- Actions:
-- 0 = break
-- 1 = place
-- 2 = use

-- Import block breaks and placements
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data) -- The stuff
	SELECT FROM_UNIXTIME(`co_blocks`.time), -- Time
		CASE WHEN `co_blocks`.action = 1 THEN -- Placing things
				(CASE WHEN `co_blocks`.type NOT LIKE 51 THEN -- Fire placement
						(CASE WHEN `co_blocks`.type NOT LIKE 8 THEN -- Water placement
								(CASE WHEN `co_blocks`.type NOT LIKE 10 THEN -- It's a lava placement, lava bucket
										'block-place'  -- It's not any of the `special` places, so it's just a block place 
								ELSE 'lava-bucket' END)
						ELSE 'water-bucket' END) 
				ELSE 'lighter' END) 
		ELSE 'block-break' END,
		`co_blocks`.user, -- Username.
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END,  -- The world. At the moment we just have 1=world, 2=world_nether, 3=world_the_end
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE (`co_blocks`.user NOT LIKE '%#%') AND (`co_blocks`.action < 2 ) ORDER BY id ASC;

-- Import explosions (tnt)
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'tnt-explode', 
		'TNT', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END,
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#tnt' AND `co_blocks`.action = 0 ORDER BY id ASC;

-- Import creeper explosions
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'creeper-explode', 
		'creeper', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END,
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#creeper' AND `co_blocks`.action = 0 ORDER BY id ASC;

-- Import vines growing
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'block-form', 
		'vine', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#vine' AND `co_blocks`.action = 1 ORDER BY id ASC;

-- Import signs placed
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_signs`.time), 
		'sign-change', 
		`co_signs`.user, 
		CASE WHEN `co_signs`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_signs`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END,
		SUBSTRING_INDEX( `co_signs`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_signs`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_signs`.bcords , '.', 3 ),'.', -1), -- Z
		-- {"lines":["1","2","3","4"],"sign_type"="SIGN_POST","facing"="NORTH"}  CO doesn't track the stuff like type and facing, so we just add that last part in.
		CONCAT("{\"lines\":[\"", `co_signs`.line1, "\",\"", `co_signs`.line2, "\",\"", `co_signs`.line3, "\",\"", `co_signs`.line4, "\"],\"sign_type\"=\"SIGN_POST\",\"facing\"=\"NORTH\"}")
	FROM `co_signs`
	WHERE 1=1 ORDER BY id ASC;
	
-- Enderman Pickup/place
	-- (CASE WHEN LEN(@str) > 0 THEN "yes" ELSE "no" END);
	-- Enderman-pickup/drop
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time),
		CASE WHEN `co_blocks`.action = 0 THEN 'enderman-pickup' ELSE 'enderman-drop' END, 
		'enderman',
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END,
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE (`co_blocks`.user LIKE '#enderman') AND (`co_blocks`.action < 2 ) ORDER BY id ASC;

-- Import blocks fading
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'block-fade', 
		'Environment', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#decay' AND `co_blocks`.action = 0 ORDER BY id ASC;
	
-- Import blocks burning
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'block-burn', 
		'Environment', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#fire' AND `co_blocks`.action = 0 ORDER BY id ASC;
	
-- Import block-use
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'block-use', 
		`co_blocks`.user, 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user NOT LIKE '%#%' AND `co_blocks`.action = 2 ORDER BY id ASC;
	
	
-- CoreProtect tracks piston moving with three actions; a remove from the original spot, 
-- a place at the original spot, and a place at the new spot.
-- Prism only tracks a place at the new spot, and that's all we need.
-- So, we need to ignore the other two.
-- Import block-shift
DROP TABLE IF EXISTS co_pistons;
CREATE TABLE co_pistons
	LIKE co_blocks;
	
ALTER TABLE co_pistons
	ADD isFrom boolean;

ALTER TABLE co_pistons
	ADD x int(11);
ALTER TABLE co_pistons
	ADD y int(11);
ALTER TABLE co_pistons
	ADD z int(11);
	
INSERT INTO co_pistons (id, cx, cz, time, user, bcords, type, data, action, rb, wid, isFrom, x, y, z)
	SELECT `co_blocks`.id,
		`co_blocks`.cx,
		`co_blocks`.cz,
		`co_blocks`.time,
		`co_blocks`.user,
		`co_blocks`.bcords,
		`co_blocks`.type,
		`co_blocks`.data,
		`co_blocks`.action,
		`co_blocks`.rb,
		`co_blocks`.wid,
		False,
		0,
		0,
		0
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE "#piston" ORDER BY id ASC;
	
UPDATE co_pistons 
	SET isFrom = True
	WHERE EXISTS(
		SELECT id FROM `co_blocks` WHERE
			`co_blocks`.user LIKE '#piston'
			AND time < (`co_blocks`.time + 20) 
			AND time > (`co_blocks`.time - 20) 
			AND `co_blocks`.bcords LIKE `co_pistons`.bcords 
			AND `co_blocks`.action = 0 
			AND `co_pistons`.id != `co_blocks`.id
	) 
	AND action = 1;
	
DELIMITER $$ -- Change our delimiter
DROP FUNCTION IF EXISTS getCoords;
CREATE FUNCTION getCoords (coords VARCHAR(23))
RETURNS VARCHAR(23)
DETERMINISTIC
BEGIN
	DECLARE x1 int(11);
	DECLARE y1 int(11);
	DECLARE z1 int(11);
	
	SET x1 = SUBSTRING_INDEX( coords , '.', 1 ); -- This will get the X coordinate of this action
	SET y1 = SUBSTRING_INDEX(SUBSTRING_INDEX( coords , '.', 2 ),'.', -1); -- Y coordinate
	SET z1 = SUBSTRING_INDEX(SUBSTRING_INDEX( coords , '.', 3 ),'.', -1); -- Z
	
	RETURN (SELECT bcords FROM `co_pistons` WHERE
		-- THIS CODE WILL BE MESSY. RUN.
		(
			(x1 + 1 = SUBSTRING_INDEX( `co_pistons`.bcords , '.', 1 ) OR x1 - 1 = SUBSTRING_INDEX( `co_pistons`.bcords , '.', 1 )) AND
			SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 2 ),'.', -1) = y1 AND
			SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 3 ),'.', -1) = z1
		) OR (
			SUBSTRING_INDEX( `co_pistons`.bcords , '.', 1 ) = x1 AND
			(y1 + 1 = SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 2 ),'.', -1) OR y1 - 1 =  SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 2 ),'.', -1)) AND
			SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 3 ),'.', -1) = z1
		) OR (
			SUBSTRING_INDEX( `co_pistons`.bcords , '.', 1 ) = x1 AND
			SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 2 ),'.', -1) = y1 AND
			(z1 + 1 = SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 3 ),'.', -1) OR z1 - 1 = SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 3 ),'.', -1))
		)
		LIMIT 1
	);
		
END$$

DELIMITER ; -- Change it back

DELETE FROM co_pistons
	WHERE action = 0;

UPDATE `co_pistons`
	SET `co_pistons`.x = SUBSTRING_INDEX( getCoords(`co_pistons`.bcords) , '.', 1 )
	WHERE (`co_pistons`.isFrom = 0);
	
UPDATE `co_pistons`
	SET y = SUBSTRING_INDEX(SUBSTRING_INDEX( getCoords(`co_pistons`.bcords) , '.', 2 ),'.', -1)
	WHERE NOT `co_pistons`.isFrom;
	
UPDATE `co_pistons`
	SET z = SUBSTRING_INDEX(SUBSTRING_INDEX( getCoords(`co_pistons`.bcords) , '.', 3 ),'.', -1)
	WHERE NOT `co_pistons`.isFrom;
	

-- Block-shift
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_pistons`.time), 
		'block-shift', 
		'Piston', 
		CASE WHEN `co_pistons`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_pistons`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_pistons`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_pistons`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_pistons`.type, ",\"block_data\":", `co_pistons`.data, ',"x"=', `co_pistons`.x, ',"y"=', `co_pistons`.y, ',"z"=', `co_pistons`.z, '}')
	FROM `co_pistons`
	WHERE NOT isFrom
	ORDER BY id ASC;

DROP TABLE co_pistons;

-- Import chest transactions
-- First let's make a function for enchantments:
DELIMITER $$ -- Change our delimiter
DROP FUNCTION IF EXISTS getEnchantments;
CREATE FUNCTION getEnchantments (enchantments VARCHAR(23))
RETURNS VARCHAR(64)
DETERMINISTIC
BEGIN
	-- "enchs":["12:3","45:6"]
	DECLARE reply VARCHAR(64);
	SET reply = "";
	WHILE (LENGTH(enchantments)) != 0 AND (enchantments LIKE '%,%') DO
		IF LENGTH(SUBSTRING_INDEX(enchantments, ',', '1')) = 0 THEN SET enchantments = SUBSTRING(enchantments, 2); END IF;
		IF reply = "" THEN
			SET reply = CONCAT(',"enchs":["', SUBSTRING_INDEX(enchantments, ',', '1'), ':', SUBSTRING_INDEX(SUBSTRING_INDEX(enchantments, ',', 2), ',', -1), '"');
		ELSE
			SET reply = CONCAT(reply, ',"', SUBSTRING_INDEX(enchantments, ',', '1'), ':', SUBSTRING_INDEX(SUBSTRING_INDEX(enchantments, ',', 2), ',', -1), '"');
		END IF;
		SET enchantments = REPLACE(enchantments, SUBSTRING_INDEX(enchantments, ',', '2'), '');
	END WHILE;
	SET reply = CASE WHEN reply = "" THEN "" ELSE CONCAT(reply, ']') END;
	RETURN reply;
END$$

DELIMITER ; -- Change it back

-- Chest transactions
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_containers`.time), 
		(CASE WHEN `co_containers`.action = 1 THEN "item-insert" ELSE "item-remove" END),
		`co_containers`.user, 
		CASE WHEN `co_containers`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_containers`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_containers`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_containers`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_containers`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT('{"block_id":', `co_containers`.type, ',"block_data":', `co_containers`.data, ',"amt":', `co_containers`.amount, ',"color":0', getEnchantments(`co_containers`.enchantments), '}')
	FROM `co_containers`
	WHERE `co_containers`.user NOT LIKE '%#%' AND `co_containers`.action < 2 ORDER BY id ASC;

-- Import blocks exploding
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'block-explode', 
		'Environment', 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '#explosion' AND `co_blocks`.action = 0 ORDER BY id ASC;

-- Import any other entity breaks
INSERT INTO prism_actions (action_time, action_type, player, world, x, y, z, data)
	SELECT FROM_UNIXTIME(`co_blocks`.time), 
		'entity-break', 
		SUBSTRING(`co_blocks`.user, '2'), 
		CASE WHEN `co_blocks`.wid = 1 THEN 'world' ELSE (CASE WHEN `co_blocks`.wid = 2 THEN 'world_nether' ELSE 'world_the_end' END) END, 
		SUBSTRING_INDEX( `co_blocks`.bcords , '.', 1 ), -- This will get the X coordinate of this action
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 2 ),'.', -1), -- Y coordinate
		SUBSTRING_INDEX(SUBSTRING_INDEX( `co_blocks`.bcords , '.', 3 ),'.', -1), -- Z
		CONCAT("{\"block_id\":", `co_blocks`.type, ",\"block_data\":", `co_blocks`.data, "}")
	FROM `co_blocks`
	WHERE `co_blocks`.user LIKE '%#%' AND 
	(`co_blocks`.user NOT LIKE '#explosion' 
	AND `co_blocks`.user NOT LIKE '#piston' 
	AND `co_blocks`.user NOT LIKE '#fire' 
	AND `co_blocks`.user NOT LIKE '#decay' 
	AND `co_blocks`.user NOT LIKE '#enderman' 
	AND `co_blocks`.user NOT LIKE '#creeper'
	AND `co_blocks`.user NOT LIKE '#tnt') AND `co_blocks`.action = 0 ORDER BY id ASC;

	
	-- water-flow - same as lava
	-- water-break - same as lava
	-- lava-flow -- shown as placements
	-- lava-break -- shows as the person who placed the lava broke it.
	-- growing stuff - Shown as placements.
	-- block form
	-- chat/command
	
	-- block-fall -- Not only does it not track blocks falling, but it doesn't track the placing of the falling blocks either! 
	-- http://is.gd/mso07z
	-- bonemeal-use
	-- container-access
	-- crop-trample
	-- entity-break
-- entity-follow
-- entity-kill
-- entity-spawn
-- entity-shear
-- fireball
-- hangingitem-break/place -- Tracked as block-break or block-place; there would be no point in making it this because I have no direction to use.
-- item-drop
-- item-pickup
-- lava-ignite
-- lightning
-- player-death
-- player-join
-- player-quit
-- sheep-eat
-- spawnegg-use
-- tnt-prime