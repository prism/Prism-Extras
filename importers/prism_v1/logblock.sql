
-- PRISM Import Script
-- for LogBlock
--
-- This script is NOT a straight SQL file, but instead a template for generating a full
-- downloadable script through the discover-prism.com website.


-- block-break
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "block-break", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.type = 0
  AND `{fromDatabase}`.`lb-players`.playername NOT IN ("Creeper","Fire","TNT","WaterFlow","LavaFlow","LeavesDecay");

-- water-flow
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "water-flow", "Water", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, '{"block_id":9,"block_subid":0}'
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "WaterFlow"
  WHERE {fromTable}.type IN (8,9) AND {fromTable}.replaced = 0;

-- water-break
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "water-break", "Water", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "WaterFlow"
  WHERE {fromTable}.type IN (8,9) AND {fromTable}.replaced != 0;

-- lava-flow
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "lava-flow", "Lava", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, '{"block_id":11,"block_subid":0}'
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "LavaFlow"
  WHERE {fromTable}.type IN (10,11) AND {fromTable}.replaced = 0;

-- lava-break
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "lava-break", "Lava", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "LavaFlow"
  WHERE {fromTable}.type IN (10,11);

-- creeper-explode
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "creeper-explode", "creeper", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "Creeper"
  WHERE {fromTable}.type = 0;

-- tnt-explode
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "creeper-explode", "tnt", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "TNT"
  WHERE {fromTable}.type = 0;

-- block-place
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "block-place", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.replaced IN (0, 8, 9, 10, 11, 78);

-- tree-grow
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "tree-grow", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.type IN (17,18) AND {fromTable}.replaced = 0;

-- @todo mushroom grow

-- leaf-decay
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "leaf-decay", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.replaced = 18 AND {fromTable}.type = 0;

-- lighter
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "lighter", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.replaced = 0 AND {fromTable}.type = 51;

-- block-burn
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "block-burn", "Environment", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "Fire"
  WHERE {fromTable}.type = 0;

-- lava-bucket
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "lava-bucket", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, '{"block_id":0,"block_subid":0}'
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.type = 11 AND {fromTable}.replaced = 0;

-- water-bucket
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "water-bucket", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, '{"block_id":0,"block_subid":0}'
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.type = 9 AND {fromTable}.replaced = 0;

-- block-form
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "block-form", "Environment", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":0}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "SnowForm"
  WHERE {fromTable}.type IN (78,79) AND {fromTable}.replaced = 0;

-- enderman-pickup
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "enderman-pickup", "enderman", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.replaced,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "Enderman"
  WHERE {fromTable}.type = 0;

-- enderman-place
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "enderman-place", "enderman", "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid AND `{fromDatabase}`.`lb-players`.playername = "Enderman"
  WHERE {fromTable}.replaced IN (0, 8, 9, 10, 11, 78);

-- @todo item-insert
-- @todo item-remove

-- block-use
INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
  SELECT {fromTable}.date, "block-use", `{fromDatabase}`.`lb-players`.playername, "{world}", {fromTable}.x, {fromTable}.y, {fromTable}.z, CONCAT('{"block_id":',{fromTable}.type,',"block_subid":',{fromTable}.data,'}')
  FROM {fromTable}
  JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = {fromTable}.playerid
  WHERE {fromTable}.type = {fromTable}.replaced;

-- Sign changes are stored in a way that we really can't do much with. LB merges
-- each line into a single line so I'm not sure the best way to handle that.

-- player-chat
-- We can't properly import player chat because there are no coordinates associated.
-- Uncomment this to load chat, but with fake coords.
-- INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
--   SELECT `lb-chat`.date, "player-chat", `{fromDatabase}`.`lb-players`.playername, "{world}", 0, 0, 0, `lb-chat`.message
--   FROM `lb-chat`
--   JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = `lb-chat`.playerid
--   WHERE LEFT(`lb-chat`.message, 1) != "/";

-- player-command
-- We can't properly import player commands because there are no coordinates associated.
-- Uncomment this to load commands, but with fake coords.
-- INSERT INTO `{toDatabase}`.`prism_actions` (action_time,action_type,player,world,x,y,z,data)
--   SELECT `lb-chat`.date, "player-chat", `{fromDatabase}`.`lb-players`.playername, "{world}", 0, 0, 0, `lb-chat`.message
--   FROM `lb-chat`
--   JOIN `{fromDatabase}`.`lb-players` ON `{fromDatabase}`.`lb-players`.playerid = `lb-chat`.playerid
--   WHERE LEFT(`lb-chat`.message, 1) = "/";


-- During development, it appears that logblock does not track
-- the following events, which Prism does:

-- block-fall
-- block-shift
-- bonemeal-use
-- container-access
-- crop-trample
-- entity-break
-- entity-follow
-- entity-kill
-- entity-spawn
-- entity-shear
-- fireball: true
-- hangingitem-break
-- hangingitem-place
-- item-drop
-- item-pickup
-- lava-ignite
-- lightning
-- player-death (they seem to only record kills, not all deaths)
-- player-join
-- player-quit
-- sheep-eat
-- spawnegg-use
-- tnt-prime