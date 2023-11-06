extends Node

enum CtfTeam {TEAM_A, TEAM_B}

# Ctf status packet > [player_id, team_id, status]
# enum FlagStatus {FLAG_TAKEN, FLAG_DROPPED, FLAG_CAPTURED}
# enum StatusPacket {PLAYER_ID, TEAM_ID, STATUS}

enum Type {PICKUP_FLAG, DROP_FLAG, CAPTURE_FLAG}

enum PickupFlag {PACKET_ID, PLAYER_ID, FLAG_ID}
# enum DropFlag {}
enum CaptureFlag {PACKET_ID, PLAYER_ID, FLAG_ID}

# TODO Note: Packets can be further optimized by giving each player short int / unsigned char

signal gamemode_started(receivers, starting_time : float)
signal gamemode_update(receivers, packet, status_time : float)

const PACKET_ID : int = 0
