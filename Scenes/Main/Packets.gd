extends Node

enum CtfTeam {TEAM_A, TEAM_B}

# Ctf status packet > [player_id, team_id, status]
# enum FlagStatus {FLAG_TAKEN, FLAG_DROPPED, FLAG_CAPTURED}
# enum StatusPacket {PLAYER_ID, TEAM_ID, STATUS}


enum Type {PICKUP_FLAG, DROP_FLAG, CAPTURE_FLAG, SPAWN_PLAYER, PLAYER_DEATH, DROP_ITEM}

enum PickupFlag {PACKET_ID, PLAYER_ID, FLAG_ID}
# enum DropFlag {}
enum CaptureFlag {PACKET_ID, PLAYER_ID, FLAG_ID}
enum SpawnPlayer {PACKET_ID, PLAYER_ID, SPAWN_LOCATION}
enum PlayerDeath {PACKET_ID, PLAYER_ID}

enum DropItem {PACKET_ID, ITEM_TYPE, ITEM_ID, DROP_LOCATION, PLAYER_ID} # If player dropped the item 

# TODO Note: Packets can be further optimized by giving each player short int / unsigned char

signal gamemode_started(receivers, starting_time : float)
signal gamemode_update(receivers, packet, status_time : float)

const PACKET_ID : int = 0


func server_time() -> float:
	return Time.get_unix_time_from_system()
