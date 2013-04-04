-- PRISM Import Script
-- for Hawkeye Reloaded
--
-- This script has to modify the hawkeye data slightly
-- so we can import it properly. Please BACKUP your
-- hawkeye table.
--
-- Run this script in your MySQL server console, or an application
-- that runs SQL queries, like phpMyAdmin, etc.
--


-- Normalize the hawkeye data so we can avoid a ton of conditions
UPDATE hawkeye SET hawkeye.data = CONCAT(hawkeye.data, ':0') WHERE LOCATE(":", hawkeye.data) = 0 AND hawkeye.action IN (0,1,10,11,14,15,17,18,20,23,24,25,26,27,34);

-- block-break
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "block-break", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(hawkeye.data,':',1), SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 0;

-- block-place
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "block-place", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 1;

-- tree-grow
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "tree-grow", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 34;

-- creeper-explode
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "creeper-explode", "creeper", hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(hawkeye.data,':',1),SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 17 AND hawk_players.player = "Creeper";

-- tnt-explode
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "tnt-explode", "creeper", hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(hawkeye.data,':',1),SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 17 AND hawk_players.player = "TNT";

-- lighter
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "lighter", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 13;

-- block-burn
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "block-burn", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z,SUBSTRING_INDEX(hawkeye.data,':',1),SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 18;

-- leaf-decay
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "leaf-decay", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(hawkeye.data,':',1),SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 20;

-- player-chat
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,data)
  SELECT hawkeye.date, "player-chat", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, hawkeye.data
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 3;

-- player-command
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,data)
  SELECT hawkeye.date, "player-command", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, hawkeye.data
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 4;

-- player-join
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z)
  SELECT hawkeye.date, "player-join", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 5;

-- player-quit
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z)
  SELECT hawkeye.date, "player-quit", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 6;

-- lava-bucket
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z)
  SELECT hawkeye.date, "lava-bucket", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 8;

-- water-bucket
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z)
  SELECT hawkeye.date, "water-bucket", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 9;

-- lava-flow
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "lava-flow", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 26;

-- water-flow
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "water-flow", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 27;


-- container-access
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "container-access", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 10;

-- block-use
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "block-use", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',1),SUBSTRING_INDEX(SUBSTRING_INDEX(hawkeye.data,'-',-1),':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 11 OR hawkeye.action = 14 OR hawkeye.action = 15;

-- item-drop
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid,data)
  SELECT hawkeye.date, "item-drop", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, (SELECT SUBSTRING_INDEX( SUBSTRING_INDEX(hawkeye.data,'x ',-1), ':', 1) FROM hawkeye WHERE action = 23),SUBSTRING_INDEX( SUBSTRING_INDEX(hawkeye.data,'x ',-1), ':', -1),':',-1), '{"amt":',SUBSTRING_INDEX(hawkeye.data,'x ',1),'}')
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 23;

-- item-pickup
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid,data)
  SELECT hawkeye.date, "item-pickup", hawk_players.player, hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, (SELECT SUBSTRING_INDEX( SUBSTRING_INDEX(hawkeye.data,'x ',-1), ':', 1) FROM hawkeye WHERE action = 23),SUBSTRING_INDEX( SUBSTRING_INDEX(hawkeye.data,'x ',-1), ':', -1),':',-1), '{"amt":',SUBSTRING_INDEX(hawkeye.data,'x ',1),'}')
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 24;

-- block-fade
INSERT INTO prism_actions (action_time,action_type,player,world,x,y,z,block_id,block_subid)
  SELECT hawkeye.date, "block-fade", "Environment", hawk_worlds.world, hawkeye.x, hawkeye.y, hawkeye.z, SUBSTRING_INDEX(hawkeye.data,':',1),SUBSTRING_INDEX(hawkeye.data,':',-1)
  FROM hawkeye
  JOIN hawk_players ON hawkeye.player_id = hawk_players.player_id
  JOIN hawk_worlds ON hawkeye.world_id = hawk_worlds.world_id
  WHERE hawkeye.action = 25 AND hawk_players.player = "Environment";




