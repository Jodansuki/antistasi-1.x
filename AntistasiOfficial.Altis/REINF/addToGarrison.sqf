private ["_posicionTel","_cercano","_cosa","_grupo","_unidades","_salir"];
openMap true;
posicionTel = [];
_cosa = _this select 0;

onMapSingleClick "posicionTel = _pos";

hint "Select the zone on which sending the selected troops as garrison";

waitUntil {sleep 0.5; (count posicionTel > 0) or (not visiblemap)};
onMapSingleClick "";

if (!visibleMap) exitWith {};

_posicionTel = posicionTel;

_cercano = [markers,_posicionTel] call BIS_fnc_nearestPosition;

if !(_posicionTel inArea _cercano) exitWith {hint "You must click near a marked zone"};

if (not(_cercano in mrkFIA)) exitWith {hint "That zone does not belong to Syndikat"};

if ((_cercano in puestosFIA) and !(isOnRoad getMarkerPos _cercano)) exitWith {hint "You cannot manage garrisons on this kind of zone"};

_cosa = _this select 0;

_grupo = grpNull;
_unidades = objNull;

if ((_cosa select 0) isEqualType grpNull) then
	{
	_grupo = _cosa select 0;
	_unidades = units _grupo;
	}
else
	{
	_unidades = _cosa;
	};

_salir = false;

{
if ((typeOf _x == guer_POW) or (typeOf _x in CIV_units) or (!alive _x)) exitWith {_salir = true}
} forEach _unidades;

if (_salir) exitWith {hint "Static crewman, prisoners, refugees or dead units cannot be added to any garrison"};

if ((groupID _grupo == "MineSw") or (groupID _grupo == "Watch") or (isPlayer(leader _grupo))) exitWith {hint "You cannot garrison player led, Watchpost, Roadblocks or Minefield building squads"};


if (isNull _grupo) then
	{
	_grupo = createGroup side_blue;
	_unidades joinSilent _grupo;
	hint "Adding units to garrison";
	{arrayids pushBackUnique (name _x)} forEach _unidades;
	}
else
	{
	hint format ["Adding %1 squad to garrison", groupID _grupo];
	};

_garrison = [];
_garrison = _garrison + (garrison getVariable [_cercano,[]]);
{_garrison pushBack (typeOf _x)} forEach _unidades;
garrison setVariable [_cercano,_garrison,true];
[_cercano] call  AS_fnc_markerUpdate;

_noBorrar = false;

if (spawner getVariable _cercano) then
	{
	{deleteWaypoint _x} forEach waypoints _grupo;
	_wp = _grupo addWaypoint [(getMarkerPos _cercano), 0];
	_wp setWaypointType "MOVE";
	{
	_x setVariable ["marcador",_cercano,true];
	_x addEventHandler ["killed",
		{
		_muerto = _this select 0;
		_marcador = _muerto getVariable "marcador";
		if (!isNil "_marcador") then
			{
			if (_marcador in mrkFIA) then
				{
				_garrison = [];
				_garrison = _garrison + (garrison getVariable [_marcador,[]]);
				if (_garrison isEqualType []) then
					{
					for "_i" from 0 to (count _garrison -1) do
						{
						if (typeOf _muerto == (_garrison select _i)) exitWith {_garrison deleteAt _i};
						};
					garrison setVariable [_marcador,_garrison,true];
					};
				[_marcador] call AS_fnc_markerUpdate;
				_muerto setVariable [_marcador,nil,true];
				};
			};
		}];
	} forEach _unidades;

	waitUntil {sleep 1; (!(spawner getVariable _cercano) or !(_cercano in mrkFIA))};
	if (!(_cercano in mrkFIA)) then {_noBorrar = true};
	};

if (!_noBorrar) then
	{
	{
	if (alive _x) then
		{
		deleteVehicle _x
		};
	} forEach _unidades;
	deleteGroup _grupo;
	}
else
	{
	//añadir el grupo al HC y quitarles variables
	{
	if (alive _x) then
		{
		_x setVariable ["marcador",nil,true];
		_x removeAllEventHandlers "killed";
		_x addEventHandler ["killed", {
			_muerto = _this select 0;
			_killer = _this select 1;
			[_muerto] remoteExec ["postmortem",2];
			if ((isPlayer _killer) and (side _killer == side_blue)) then
				{
				if (!isMultiPlayer) then
					{
					_nul = [0,20] remoteExec ["resourcesFIA",2];
					_killer addRating 1000;
					};
				}; /* Stef, will do later
			else
				{
				if (side _killer == side_green) then
					{
					_nul = [0.25,0,getPos _muerto] remoteExec ["citySupportChange",2];
					[-0.25,0] remoteExec ["prestige",2];
					}
				else
					{
					if (side _killer == muyMalos) then {[0,-0.25] remoteExec ["prestige",2]};
					};
				};*/
			_muerto setVariable ["BLUFORSpawn",nil,true];
			}];
		};
	} forEach _unidades;
	Slowhand hcSetGroup [_grupo];
	hint format ["Group %1 is back to HC control because the zone which was pointed to garrison has been lost",groupID _grupo];
	};

